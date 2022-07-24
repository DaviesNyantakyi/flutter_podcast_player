import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/episode_model.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/utilities/formal_dates.dart';
import 'package:flutter_podcast_player/widgets/podcast_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../services/podcast_service.dart';

class EpisodeTile extends StatefulWidget {
  final EpisodeModel episode;
  final VoidCallback? onPressed;

  const EpisodeTile({
    Key? key,
    required this.episode,
    this.onPressed,
  }) : super(key: key);

  @override
  State<EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<EpisodeTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(builder: (context, audioProvider, _) {
      return ListTile(
        onTap: widget.onPressed,
        leading: PodcastImage(
          imageURL: widget.episode.image ?? '',
          width: 60,
          height: 70,
        ),
        title: Text(
          widget.episode.title ?? '...',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                color: audioProvider.currentMediaItem?.id == widget.episode.id
                    ? kBlue
                    : Colors.white,
              ),
        ),
        subtitle: Text(
          FormalDates.playerDuration(
            duration: Duration(seconds: widget.episode.duration ?? 0),
          ),
          style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: audioProvider.currentMediaItem?.id == widget.episode.id
                    ? kBlue
                    : Colors.white,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DownloadButton(episode: widget.episode),
            audioProvider.currentMediaItem?.id == widget.episode.id
                ? IconButton(
                    tooltip: 'Play/Pause',
                    icon: audioProvider.playerState?.processingState ==
                                ProcessingState.buffering ||
                            audioProvider.playerState?.processingState ==
                                ProcessingState.loading
                        ? const LinearProgressIndicator(
                            color: kBlue,
                          )
                        : Icon(
                            audioProvider.playerState?.playing == false ||
                                    audioProvider
                                            .playerState?.processingState ==
                                        ProcessingState.completed
                                ? BootstrapIcons.play_circle_fill
                                : BootstrapIcons.pause_circle_fill,
                          ),
                    onPressed: () async {
                      if (audioProvider.playerState?.playing == true) {
                        await audioProvider.pause();
                      } else {
                        await audioProvider.play();
                      }
                    },
                  )
                : Container(),
          ],
        ),
      );
    });
  }
}

class DownloadButton extends StatefulWidget {
  final EpisodeModel episode;
  const DownloadButton({Key? key, required this.episode}) : super(key: key);

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  double percentage = 0.0;
  bool downloading = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<EpisodeModel>>(
      valueListenable: Hive.box<EpisodeModel>('downloads').listenable(),
      builder: (context, downloadBox, _) {
        final downloaded = downloadBox.values.contains(widget.episode);

        return IconButton(
          tooltip: 'Download',
          icon: downloading
              ? const CircularProgressIndicator()
              : Icon(
                  BootstrapIcons.arrow_down_circle,
                  color: downloaded ? Colors.green : Colors.white,
                ),
          onPressed: () {
            PodcastService().downloadEpisode(
              episode: widget.episode,
              onReceiveProgress: (recieved, total) {
                percentage = recieved / total;

                if (percentage == 1) {
                  downloading = false;
                } else {
                  downloading = true;
                }

                if (mounted) {
                  setState(() {});
                }
              },
            );
          },
        );
      },
    );
  }
}
