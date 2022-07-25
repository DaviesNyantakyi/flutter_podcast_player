import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/utilities/formal_dates.dart';
import 'package:flutter_podcast_player/widgets/bottomsheet.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../screens/player_screen/player_screen.dart';

const seekDuration = Duration(seconds: 30);
Future<AudioProvider> initAudioSerivce() async {
  return await AudioService.init(
    builder: () => AudioProvider(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.flutter_podcast_player',
      androidNotificationChannelName: 'Podcast Player',
      fastForwardInterval: seekDuration,
      rewindInterval: seekDuration,
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class AudioProvider extends BaseAudioHandler with ChangeNotifier {
  final AudioPlayer _justAudio = AudioPlayer();

  PlayerState? _playerState;
  Duration _currentPostion = Duration.zero;
  Duration _totalDuration = Duration.zero;
  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;
  MediaItem? _currentMediaItem;

  PlayerState? get playerState => _playerState;
  Duration get currentPostion => _currentPostion;
  Duration get totalDuration => _totalDuration;
  AudioServiceRepeatMode get repeatMode => _repeatMode;
  MediaItem? get currentMediaItem => _currentMediaItem;

  AudioProvider() {
    _postionStream();
    _totalDurationStream();
    playingStateStream();
  }

  Future<void> initPlayer({required MediaItem mediaItem}) async {
    if (mediaItem.extras?['downloadPath'] != null) {
      final file = File(mediaItem.extras?['downloadPath']);
      await _justAudio.setAudioSource(AudioSource.uri(file.uri));
    } else {
      if (mediaItem.extras?['audio'] != null) {
        await _justAudio.setUrl(mediaItem.extras!['audio']);
      }
    }

    await play();

    _currentMediaItem = mediaItem;

    notifyListeners();
  }

  @override
  Future<void> play() async {
    if (_justAudio.processingState == ProcessingState.completed) {
      await seek(Duration.zero);
    }
    await _justAudio.play();
    await super.play();
  }

  @override
  Future<void> stop() async {
    await _justAudio.stop();
    return super.stop();
  }

  @override
  Future<void> pause() async {
    await _justAudio.pause();
    return super.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await _justAudio.seek(position);

    return super.seek(position);
  }

  @override
  Future<void> rewind() async {
    Duration newPostion = _currentPostion - seekDuration;
    if (newPostion < Duration.zero) {
      newPostion = Duration.zero;
    }
    await seek(newPostion);

    return super.rewind();
  }

  @override
  Future<void> fastForward() async {
    Duration newPostion = _currentPostion + seekDuration;
    if (newPostion > totalDuration) {
      newPostion = totalDuration;
    }
    await seek(newPostion);
    return super.fastForward();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    _repeatMode = repeatMode;

    if (repeatMode == AudioServiceRepeatMode.none) {
      await _justAudio.setLoopMode(LoopMode.off);
    } else {
      await _justAudio.setLoopMode(LoopMode.one);
    }

    notifyListeners();

    return super.setRepeatMode(repeatMode);
  }

  void playingStateStream() {
    // The state of the player.
    // You can listen for changes in both the processing state and the playing state from the audio player’s playerStateStream.
    // This stream provides the current PlayerState, which includes a Boolean playing property and a processingState property.
    _justAudio.playerStateStream.listen((state) {
      _playerState = state;

      notifyListeners();
    });
  }

  void _postionStream() {
    // Gets the current audio (slider) postion.
    _justAudio.positionStream.listen((position) {
      _currentPostion = position;
      notifyListeners();
    });
  }

  void _totalDurationStream() {
    // Gets the current audio (slider) postion.
    _justAudio.durationStream.listen((duration) {
      _totalDuration = duration ?? Duration.zero;

      notifyListeners();
    });
  }
}

Future<void> showPlayer({
  required BuildContext context,
  required MediaItem mediaItem,
}) async {
  final audioProvider = Provider.of<AudioProvider>(context, listen: false);
  showCustomBottomSheet(
    context: context,
    height: MediaQuery.of(context).size.height * 0.90,
    header: AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'Now Playing',
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
      actions: [
        IconButton(
          tooltip: 'About',
          onPressed: () => showDescription(
            context: context,
            mediaItem: mediaItem,
          ),
          icon: const Icon(BootstrapIcons.info_circle),
        ),
      ],
    ),
    child: ChangeNotifierProvider<AudioProvider>.value(
      value: audioProvider,
      child: PlayerScreen(
        mediaItem: mediaItem,
      ),
    ),
  );
}

Future<void> showDescription(
    {required BuildContext context, required MediaItem mediaItem}) async {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mediaItem.title,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          Text(
            'by ${mediaItem.artist ?? ''} • ${FormalDates.timeAgo(date: mediaItem.extras?['pubDate'])}',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          const SizedBox(height: kContentSpacing8),
          Text(
            mediaItem.displayDescription ?? '',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    ),
  );
}

class MyJABytesSource extends StreamAudioSource {
  final Uint8List _buffer;

  MyJABytesSource(this._buffer) : super(tag: 'MyAudioSource');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // Returning the stream audio response with the parameters
    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: (start ?? 0) - (end ?? _buffer.length),
      offset: start ?? 0,
      stream: Stream.fromIterable([_buffer.sublist(start ?? 0, end)]),
      contentType: 'audio/wav',
    );
  }
}
