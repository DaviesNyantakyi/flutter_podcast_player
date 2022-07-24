import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/utilities/formal_dates.dart';
import 'package:flutter_podcast_player/widgets/episode_tile.dart';
import 'package:flutter_podcast_player/widgets/podcast_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../models/episode_model.dart';

class PlayerScreen extends StatefulWidget {
  final MediaItem mediaItem;
  const PlayerScreen({Key? key, required this.mediaItem}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    initAudio();
    super.initState();
  }

  Future<void> initAudio() async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    if (audioProvider.currentMediaItem?.id == widget.mediaItem.id) {
      return;
    }

    await audioProvider.initPlayer(mediaItem: widget.mediaItem);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageTitle(),
        const SizedBox(height: kContentSpacing8),
        _buildSlider(context),
        const SizedBox(height: kContentSpacing14),
        _buildMediaControls()
      ],
    );
  }

  Widget _buildSlider(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Slider(
              value: min(
                // the min returns the lesser numnber.
                // If the currentPostion is greater then the totalDuration, the totalDuration will be returned.
                audioProvider.currentPostion.inSeconds.toDouble(),
                audioProvider.totalDuration.inSeconds.toDouble(),
              ),
              max: audioProvider.totalDuration.inSeconds.toDouble(),
              // This is called when slider value is changed.
              onChanged: (double value) {
                audioProvider.seek(Duration(seconds: value.toInt()));
              },
            ),
            const SizedBox(height: kContentSpacing8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FormalDates.playerDuration(
                      duration: audioProvider.currentPostion),
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  FormalDates.playerDuration(
                    duration: audioProvider.totalDuration,
                  ),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMediaControls() {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: SizedBox(
                height: 70,
                child: IconButton(
                  tooltip: 'Download',
                  icon: const Icon(
                    BootstrapIcons.arrow_down_circle,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Fast rewind',
                      iconSize: 32,
                      onPressed: () => audioProvider.rewind(),
                      icon: const Icon(Icons.replay_30_outlined),
                    ),
                    IconButton(
                      tooltip: 'Play & Pause',
                      iconSize: 52,
                      onPressed: () async {
                        if (audioProvider.playerState?.playing == true) {
                          await audioProvider.pause();
                        } else {
                          await audioProvider.play();
                        }
                      },
                      //
                      icon: Icon(
                        audioProvider.playerState?.playing == false ||
                                audioProvider.playerState?.processingState ==
                                    ProcessingState.completed
                            ? BootstrapIcons.play_circle_fill
                            : BootstrapIcons.pause_circle_fill,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fast foward',
                      iconSize: 32,
                      onPressed: () => audioProvider.fastForward(),
                      icon: const Icon(
                        Icons.forward_30_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 70,
                child: IconButton(
                  tooltip: 'Replay',
                  iconSize: 20,
                  icon: Icon(
                    BootstrapIcons.arrow_repeat,
                    color:
                        audioProvider.repeatMode == AudioServiceRepeatMode.one
                            ? kBlue
                            : Colors.white,
                  ),
                  onPressed: () async {
                    AudioServiceRepeatMode mode = audioProvider.repeatMode;
                    if (mode == AudioServiceRepeatMode.none) {
                      mode = AudioServiceRepeatMode.one;
                    } else {
                      mode = AudioServiceRepeatMode.none;
                    }
                    await audioProvider.setRepeatMode(
                      mode,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PodcastImage(
          height: 350,
          width: 300,
          imageURL: widget.mediaItem.artUri.toString(),
        ),
        const SizedBox(height: kContentSpacing24),
        Column(
          children: [
            Text(
              widget.mediaItem.title,
              style: Theme.of(context).textTheme.headline6,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            _buildAuthor(),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthor() {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        String text = widget.mediaItem.artist ?? '';

        switch (audioProvider.playerState?.processingState) {
          case ProcessingState.loading:
            text = 'Loading...';
            break;
          case ProcessingState.buffering:
            text = 'Buffering...';
            break;
          default:
        }
        return Text(
          text,
          style: Theme.of(context).textTheme.bodyText2,
          maxLines: 1,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
