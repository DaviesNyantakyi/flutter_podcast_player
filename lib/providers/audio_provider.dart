import 'package:audio_service/audio_service.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/episode_model.dart';
import 'package:flutter_podcast_player/widgets/bottomsheet.dart';
import 'package:flutter_podcast_player/widgets/episode_tile.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../screens/player_screen/player_screen.dart';
import '../utilities/constant.dart';

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
    // _currentIndexStream();
    playingStateStream();
  }

  Future<void> initPlayer({required EpisodeModel episode}) async {
    if (episode.audio != null) {
      await _justAudio.setUrl(episode.audio!);

      await play();
    }

    notifyListeners();
  }

  @override
  Future<void> play() async {
    // if (_justAudio.processingState == ProcessingState.completed) {
    //   await seek(Duration.zero);
    // }
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

  // void _currentIndexStream() {
  //   // Listen for the current media item
  //   _justAudio.currentIndexStream.listen((index) {
  //     final currentPlayList = queue.value;

  //     if (index == null || currentPlayList.isEmpty) {
  //       return;
  //     }
  //     mediaItem.add(currentPlayList[index]);
  //   });
  // }

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

Future<void> addToQueue({
  required BuildContext context,
  required EpisodeModel episode,
}) async {
  try {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    final mediaItem = MediaItem(
      id: episode.id,
      title: episode.title ?? '',
      artist: episode.author,
      duration: episode.duration,
      displayDescription: episode.description,
      artUri: episode.image != null ? Uri.parse(episode.image!) : null,
      extras: {
        'audio': episode.audio,
        'pubDate': episode.pubDate,
        'pageLink': episode.pageLink,
      },
    );

    await audioProvider.addQueueItem(mediaItem);
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<void> showQueue({required BuildContext context}) async {
  final audioProvider = Provider.of<AudioProvider>(context, listen: false);

  showCustomBottomSheet(
    context: context,
    height: MediaQuery.of(context).size.height * 0.90,
    header: AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'Queue',
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
    child: ChangeNotifierProvider<AudioProvider>.value(
      value: audioProvider,
      child: Consumer<AudioProvider>(
        builder: (context, audioProvider, _) {
          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: audioProvider.playListNotifier.length,
            separatorBuilder: (context, index) => const SizedBox(
              height: kContentSpacing8,
            ),
            itemBuilder: (context, index) {
              final episode = EpisodeModel(
                id: audioProvider.playListNotifier[index].id,
                image: audioProvider.playListNotifier[index].artUri.toString(),
                title: audioProvider.playListNotifier[index].title,
                author: audioProvider.playListNotifier[index].artist,
                description:
                    audioProvider.playListNotifier[index].displayDescription,
                pageLink:
                    audioProvider.playListNotifier[index].extras?['pageLink'],
                duration: audioProvider.playListNotifier[index].duration,
                audio: audioProvider.playListNotifier[index].extras?['audio'],
              );
              return EpisodeTile(
                key: ObjectKey(episode),
                episode: episode,
                addQueueOnPressed: () =>
                    addToQueue(episode: episode, context: context),
                downloadOnPressed: () {},
                onPressed: () {},
              );
            },
          );
        },
      ),
    ),
  );
}

Future<void> showPlayer({
  required BuildContext context,
  required EpisodeModel episode,
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
          tooltip: 'Queue',
          onPressed: () => showQueue(context: context),
          icon: const Icon(BootstrapIcons.music_note_list),
        ),
      ],
    ),
    child: ChangeNotifierProvider<AudioProvider>.value(
      value: audioProvider,
      child: PlayerScreen(
        episode: episode,
      ),
    ),
  );
}
