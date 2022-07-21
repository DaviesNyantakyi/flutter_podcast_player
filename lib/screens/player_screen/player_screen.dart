import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/episode_model.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/utilities/formal_dates.dart';
import 'package:flutter_podcast_player/widgets/bottomsheet.dart';
import 'package:flutter_podcast_player/widgets/podcast_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class PlayerScreen extends StatefulWidget {
  final EpisodeModel episode;
  const PlayerScreen({Key? key, required this.episode}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool isPlaying = false;

  double sliderValue = 0.0;

  @override
  void initState() {
    initAudio();
    super.initState();
  }

  Future<void> initAudio() async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    if (widget.episode.audio != null) {
      await audioProvider.initPlayer(url: widget.episode.audio!);
    }
  }

  Future<void> showDescription({required EpisodeModel episode}) async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    showCustomBottomSheet(
      context: context,
      height: MediaQuery.of(context).size.height * 0.90,
      header: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Description',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(BootstrapIcons.chevron_down),
        ),
      ),
      child: ChangeNotifierProvider.value(
        value: audioProvider,
        child: GestureDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.episode.title ?? '',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                'by ${widget.episode.author ?? ''}',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(height: kContentSpacing8),
              Text(
                widget.episode.description ?? '',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
          onTap: () {},
        ),
      ),
    );
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
                  tooltip: 'Shuffle',
                  iconSize: 20,
                  icon: const Icon(BootstrapIcons.shuffle),
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
                      tooltip: 'Skip Previous',
                      iconSize: 32,
                      onPressed: audioProvider.skipToPrevious,
                      icon: const Icon(BootstrapIcons.skip_start),
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
                      tooltip: 'Skip Next',
                      iconSize: 32,
                      onPressed: audioProvider.skipToNext,
                      icon: const Icon(BootstrapIcons.skip_end),
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
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PodcastImage(
            height: 350,
            width: 300,
            imageURL: widget.episode.image ?? '',
          ),
          const SizedBox(height: kContentSpacing24),
          Column(
            children: [
              Text(
                widget.episode.title ?? '',
                style: Theme.of(context).textTheme.headline6,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              _buildAuthor(),
            ],
          ),
        ],
      ),
      onTap: () => showDescription(episode: widget.episode),
    );
  }

  Widget _buildAuthor() {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        String text = widget.episode.author ?? '';

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
