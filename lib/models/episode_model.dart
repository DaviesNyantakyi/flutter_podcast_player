class EpisodeModel {
  final String id;
  final String? image;
  final String? title;
  final String? description;
  final String? pageLink;
  final String? audio;
  final String? author;
  final Duration? duration;
  final DateTime? pubDate;
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
  });
}
