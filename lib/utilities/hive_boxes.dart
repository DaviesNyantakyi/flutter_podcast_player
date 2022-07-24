import 'package:flutter_podcast_player/models/episode_model.dart';
import 'package:flutter_podcast_player/models/podcast_model.dart';
import 'package:hive/hive.dart';

class HiveBoxes {
  Box<PodcastModel> getPodcasts() => Hive.box<PodcastModel>('podcasts');
  Box<EpisodeModel> getDownloads() => Hive.box<EpisodeModel>('downloads');
  Box<PodcastModel> getSubScriptions() => Hive.box<PodcastModel>(
        'subscriptions',
      );
}
