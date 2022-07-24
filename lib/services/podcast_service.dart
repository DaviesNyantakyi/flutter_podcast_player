import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_podcast_player/models/episode_model.dart';
import 'package:flutter_podcast_player/models/podcast_model.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_podcast_player/utilities/hive_boxes.dart';
import 'package:flutter_podcast_player/utilities/parse_html.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../utilities/custom_path_provider.dart';

class PodcastService {
  final _podIndexApiKey = dotenv.env['PODCASTINDEXAPIKEY'];
  final _podIndexSecret = dotenv.env['PODCASTINDEXSECRET'];
  final String _baseURL = 'https://api.podcastindex.org';

  final _dio = Dio();

  Map<String, String> _initHeader() {
    final unixTime = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000)
        .round()
        .toString();

    final firstChunk = utf8.encode(_podIndexApiKey.toString());
    final secondChunk = utf8.encode(_podIndexSecret.toString());
    final thirdChunk = utf8.encode(unixTime);
    var output = AccumulatorSink<Digest>();
    var input = sha1.startChunkedConversion(output);
    input.add(firstChunk);
    input.add(secondChunk);
    input.add(thirdChunk);
    input.close();
    var digest = output.events.single;

    var headers = <String, String>{
      "X-Auth-Date": unixTime,
      "X-Auth-Key": _podIndexApiKey.toString(),
      "Authorization": digest.toString(),
      "User-Agent": "flutter_podcast_player/1.0"
    };
    return headers;
  }

  Future<List<PodcastModel>?> fetchTrending({
    int? max,
    required bool reload,
  }) async {
    try {
      final url =
          '$_baseURL/api/1.0/podcasts/trending?&max=${Uri.encodeComponent('$max')}&pretty';

      final podBox = HiveBoxes().getPodcasts();

      if (reload) {
        await podBox.clear();
      }
      if (podBox.values.isNotEmpty) {
        return podBox.values.toList();
      }
      final podcasts = await _fetchPodcast(url: url);

      if (podcasts != null) {
        await Future.wait(
          podcasts.map(
            (podcast) => podBox.put(podcast.id, podcast),
          ),
        );
      }
      return podcasts;
    } on DioError catch (e) {
      debugPrint(e.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<List<PodcastModel>?> featchSearchPodcast({
    required String query,
  }) async {
    try {
      final url =
          "$_baseURL/api/1.0/search/byterm?q=${Uri.encodeComponent(query)}";
      return await _fetchPodcast(url: url);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<PodcastModel>?> _fetchPodcast({required String url}) async {
    try {
      final header = _initHeader();

      final response = await _dio.get(url, options: Options(headers: header));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.toString());
        List<dynamic>? feeds = data['feeds'];

        if (feeds != null) {
          final podcasts = feeds.map((feed) async {
            final String id = feed['id'].toString();
            final episodes = await fetchEpisodes(id: id, rss: feed);

            return PodcastModel(
              id: id,
              image: feed['image'],
              title: feed['title'],
              description: feed['description'],
              author: feed['author'],
              pageLink: feed['link'],
              rss: feed['url'],
              episodes: episodes,
              // randomNumber: Random().nextInt(1000),
            );
          }).toList();

          // List<Future<PodcastModel>>  to List<PodcastModels>
          List<PodcastModel> mappedPodcast = await Future.wait(
            podcasts.map((podcast) async => await podcast),
          );

          return mappedPodcast;
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<List<EpisodeModel>?> fetchEpisodes({
    required String id,
    required dynamic rss,
  }) async {
    try {
      final url =
          '$_baseURL/api/1.0/episodes/byfeedid?id=${Uri.encodeComponent(id)}&pretty';

      final header = _initHeader();
      final response = await _dio.get(
        url,
        options: Options(headers: header),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.toString());
        List<dynamic>? feedsItems = data['items'];

        if (feedsItems != null) {
          final episodes = feedsItems.map((item) {
            return EpisodeModel(
              id: item['id'].toString(),
              image: item['feedImage'],
              title: item['title'],
              description: parseHtml(item: item['description']),
              audio: item['enclosureUrl'],
              author: rss['author'],
              pageLink: item['link'],
              duration: item['duration'],
              pubDate: DateTime.fromMillisecondsSinceEpoch(
                item['datePublished'] * 1000,
              ),
            );
          }).toList();

          return episodes;
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> savePodcast({required PodcastModel podcast}) async {
    try {
      final subBox = HiveBoxes().getSubScriptions();
      await subBox.put(podcast.id, podcast);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> downloadEpisode({
    required EpisodeModel episode,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final downloadsDir = await CustomPathProvider().getDownloadsDirectory();

      final downloadBox = HiveBoxes().getDownloads();
      final file = await CustomPathProvider()
          .getFile(path: '${downloadsDir.path}/${episode.title}.mp3');

      if (Hive.box<EpisodeModel>('downloads').values.contains(episode)) {
        await downloadBox.delete(episode.id);
        await file?.delete();
        return;
      }

      if (episode.audio != null) {
        final Response response = await _dio.get(
          episode.audio!,
          options: Options(
            responseType: ResponseType.bytes,
          ),
          onReceiveProgress: onReceiveProgress,
        );

        if (response.statusCode == 200) {
          File file = File('${downloadsDir.path}/${episode.title}.mp3');
          final randFile = file.openSync(mode: FileMode.write);

          randFile.writeFromSync(response.data);
          randFile.close();
          episode.downloadPath = file.path;
          await downloadBox.put(episode.id, episode);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Future<PodcastModel?> fetchbyFeedURL() async {
  //   try {
  //     final url =
  //         '$_baseURL/api/1.0/podcasts/byfeedurl?url=${Uri.encodeComponent('https://feeds.redcircle.com/ef5caef7-c00e-4dcf-9bac-90b60a2db406')}&pretty';

  //     final header = _initHeader();

  //     final response = await _dio.get(
  //       url,
  //       options: Options(headers: header),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.toString());
  //       Map<String, dynamic> feed = data['feed'];

  //       final id = feed['id'].toString();
  //       final episodes = await fetchEpisodes(id: id, rss: feed);

  //       return PodcastModel(
  //         id: id,
  //         image: feed['image'],
  //         title: feed['title'],
  //         description: feed['description'],
  //         author: feed['author'],
  //         pageLink: feed['link'],
  //         rss: feed['url'],
  //         episodes: episodes,
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   return null;
  // }

}
