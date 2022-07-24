// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive/hive.dart';

import 'package:flutter_podcast_player/models/episode_model.dart';

part 'podcast_model.g.dart';

@HiveType(typeId: 0)
class PodcastModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? image;
  @HiveField(2)
  final String? title;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final String? author;
  @HiveField(5)
  final String? pageLink;
  @HiveField(6)
  final String? rss;
  @HiveField(7)
  List<EpisodeModel>? episodes;

  PodcastModel({
    required this.id,
    this.image,
    this.title,
    this.description,
    this.author,
    this.rss,
    this.pageLink,
    this.episodes,
  });
}
