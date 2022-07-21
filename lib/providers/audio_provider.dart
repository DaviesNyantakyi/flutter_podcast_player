import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioProvider> initAudioSerivce() async {
  return await AudioService.init(
    builder: () => AudioProvider(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.flutter_podcast_player',
      androidNotificationChannelName: 'Podcast Player',
      fastForwardInterval: Duration(seconds: 30),
      rewindInterval: Duration(seconds: 30),
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

  // Notifies the UI for any changes in the playList
  List<MediaItem> _playListNotifier = [];

  // Just audio playList
  final _playList = ConcatenatingAudioSource(children: []);

  PlayerState? get playerState => _playerState;
  Duration get currentPostion => _currentPostion;
  Duration get totalDuration => _totalDuration;
  AudioServiceRepeatMode get repeatMode => _repeatMode;
  List<MediaItem> get playListNotifier => _playListNotifier;

  AudioProvider() {
    _loadEmptyPlayList();
    _playListChangeStream();
    _postionStream();
    _totalDurationStream();

    playingStateStream();
  }

  Future<void> initPlayer({required String url}) async {
    playbackState.add(PlaybackState(
      processingState: AudioProcessingState.loading,
      systemActions: {
        MediaAction.seek,
      },
    ));
    await _justAudio.setUrl(url);
    playbackState.add(PlaybackState(
      playing: false,
      controls: [
        MediaControl.rewind,
        MediaControl.play,
        MediaControl.fastForward
      ],
      processingState: AudioProcessingState.ready,
      systemActions: {
        MediaAction.seek,
      },
    ));
    await play();
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
  Future<void> skipToNext() async {
    await _justAudio.seekToNext();
    return super.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await _justAudio.seekToPrevious();
    return super.skipToPrevious();
  }

  @override
  Future<void> seek(Duration position) async {
    await _justAudio.seek(position);

    return super.seek(position);
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

  UriAudioSource _createAudioSource({required MediaItem mediaItem}) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['audio']),
      tag: mediaItem,
    );
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // Manage justAudio
    final audioSources = mediaItems.map((mediaItem) {
      return _createAudioSource(mediaItem: mediaItem);
    }).toList();
    await _playList.addAll(audioSources);

    // Notify System
    queue.value.addAll(mediaItems);
    notifyListeners();
    return super.addQueueItems(mediaItems);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    if (queue.value.contains(mediaItem)) {
      queue.value.remove(mediaItem);
    } else {
      // Manage justAudio
      final audioSource = _createAudioSource(mediaItem: mediaItem);
      await _playList.add(audioSource);

      // Notify System
      queue.value.add(mediaItem);
      super.addQueueItem(mediaItem);
    }
    notifyListeners();
  }

  Future<void> _loadEmptyPlayList() async {
    // Empty playlist when the UI is started for the first time

    try {
      await _justAudio.setAudioSource(_playList);
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  void _playListChangeStream() {
    // Listen to playlist changes
    queue.listen((playList) {
      _playListNotifier = playList;
      notifyListeners();
    });
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
