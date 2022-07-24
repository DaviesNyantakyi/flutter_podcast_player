// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:hive_flutter/hive_flutter.dart';

part 'episode_model.g.dart';

@HiveType(typeId: 1)
class EpisodeModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? image;
  @HiveField(2)
  final String? title;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final String? pageLink;
  @HiveField(5)
  final String? audio;
  @HiveField(6)
  final String? author;
  @HiveField(7)
  final int? duration;
  @HiveField(8)
  final DateTime? pubDate;
  @HiveField(9)
  String? downloadPath;
  EpisodeModel({
    required this.id,
    this.image,
    this.title,
    this.description,
    this.pageLink,
    this.audio,
    this.author,
    this.duration,
    this.pubDate,
    this.downloadPath,
  });

  @override
  String toString() {
    return 'EpisodeModel(id: $id, image: $image, title: $title, description: $description, pageLink: $pageLink, audio: $audio, author: $author, duration: $duration, pubDate: $pubDate, downloadPath: $downloadPath)';
  }
}
