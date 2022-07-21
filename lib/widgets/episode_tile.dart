import 'package:audio_service/audio_service.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/episode_model.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/utilities/formal_dates.dart';
import 'package:flutter_podcast_player/widgets/podcast_image.dart';
import 'package:provider/provider.dart';

class EpisodeTile extends StatefulWidget {
  final EpisodeModel episode;
  final VoidCallback? onPressed;
  final VoidCallback? downloadOnPressed;
  final VoidCallback? addQueueOnPressed;

  const EpisodeTile({
    Key? key,
    required this.episode,
    this.onPressed,
    this.downloadOnPressed,
    this.addQueueOnPressed,
  }) : super(key: key);

  @override
  State<EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<EpisodeTile> {
  MediaItem? mediaItem;

  @override
  void initState() {
    mediaItem = MediaItem(
      id: widget.episode.id,
      title: widget.episode.title ?? '',
      artist: widget.episode.author,
      duration: widget.episode.duration,
      displayDescription: widget.episode.description,
      artUri: widget.episode.image != null
          ? Uri.parse(widget.episode.image!)
          : null,
      extras: {
        'audio': widget.episode.audio,
        'pubDate': widget.episode.pubDate,
        'pageLink': widget.episode.pageLink,
      },
    );
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(kRadius),
        ),
      ),
      onTap: widget.onPressed,
      contentPadding: EdgeInsets.zero,
      leading: PodcastImage(
        imageURL: widget.episode.image ?? '',
        width: 60,
        height: 70,
      ),
      title: Text(
        widget.episode.title ?? '...',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        FormalDates.playerDuration(
          duration: widget.episode.duration ?? const Duration(seconds: 0),
        ),
      ),
      trailing: Consumer<AudioProvider>(
        builder: (context, audioProvider, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: audioProvider.playListNotifier.contains(mediaItem)
                    ? 'Remove from Queue'
                    : 'Add to Queue',
                icon: Icon(
                  audioProvider.playListNotifier.contains(mediaItem)
                      ? BootstrapIcons.check_circle_fill
                      : BootstrapIcons.music_note_list,
                ),
                onPressed: widget.addQueueOnPressed,
              ),
              IconButton(
                tooltip: 'Download',
                icon: const Icon(BootstrapIcons.arrow_down_circle),
                onPressed: widget.downloadOnPressed,
              ),
            ],
          );
        },
      ),
    );
  }
}
