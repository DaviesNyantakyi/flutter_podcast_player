import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/episode_model.dart';
import '../utilities/custom_path_provider.dart';
import '../utilities/hive_boxes.dart';

class Downloader {
  final Dio _dio = Dio();

  Future<void> downloadEpisode({
    required EpisodeModel episode,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final downloadsDir = await CustomPathProvider().getDownloadsDirectory();

      final downloadBox = HiveBoxes().getDownloads();
      final file = await CustomPathProvider()
          .getFile(path: '${downloadsDir.path}/${episode.title}.mp3');

      final downloadedEpisodes =
          Hive.box<EpisodeModel>('downloads').values.toList();

      for (var ep in downloadedEpisodes) {
        if (episode.id == ep.id) {
          await downloadBox.delete(episode.id);
          file?.deleteSync();
          return;
        }
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
}
