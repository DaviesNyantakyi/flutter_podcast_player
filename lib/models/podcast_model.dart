import 'package:flutter_podcast_player/models/episode_model.dart';

class PodcastModel {
  final String id;
  final String? image;
  final String? title;
  final String? description;
  final String? author;
  final String? pageLink;
  final String? rss;
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

  @override
  String toString() {
    return 'PodcastModel(id: $id, image: $image, title: $title, description: $description, author: $author, pageLink: $pageLink, rss: $rss, episodes: $episodes)';
  }
}
