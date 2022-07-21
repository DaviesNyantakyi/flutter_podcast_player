import 'dart:async';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_podcast_player/models/episode_model.dart';
import 'package:flutter_podcast_player/models/podcast_model.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_podcast_player/utilities/parse_html.dart';

class ListenNotesAPI {
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

  Future<List<PodcastModel>?> featchSearchPodcast({
    required String query,
  }) async {
    try {
      final url =
          "$_baseURL/api/1.0/search/byterm?q=${Uri.encodeComponent(query)}";

      final headers = _initHeader();

      final response = await _dio.get(url, options: Options(headers: headers));

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
      debugPrint(e.toString());
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
              duration: Duration(seconds: item['duration']),
              pubDate: DateTime.fromMicrosecondsSinceEpoch(
                item['datePublished'],
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

  Future<List<PodcastModel>?> fetchTrending({String? max}) async {
    try {
      final url =
          '$_baseURL/api/1.0/podcasts/trending?&max=${Uri.encodeComponent(max ?? '10')}&pretty';

      final header = _initHeader();

      final response = await _dio.get(
        url,
        options: Options(headers: header),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.toString());
        List<dynamic>? feeds = data['feeds'];

        if (feeds != null) {
          final podcasts = feeds.map((feed) async {
            final id = feed['id'].toString();
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
      debugPrint(e.toString());
    }
    return null;
  }

  Future<PodcastModel?> fetchbyFeedURL() async {
    try {
      final url =
          '$_baseURL/api/1.0/podcasts/byfeedurl?url=${Uri.encodeComponent('https://feeds.redcircle.com/ef5caef7-c00e-4dcf-9bac-90b60a2db406')}&pretty';

      final header = _initHeader();

      final response = await _dio.get(
        url,
        options: Options(headers: header),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.toString());
        Map<String, dynamic> feed = data['feed'];

        final id = feed['id'].toString();
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
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
