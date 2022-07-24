import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/podcast_model.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/services/podcast_service.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/utilities/custom_scroll_behavior.dart';
import 'package:flutter_podcast_player/widgets/mini_player.dart';
import 'package:flutter_podcast_player/widgets/podcast_card.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../podcast_detail_screen/podcast_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PodcastService podcastService = PodcastService();
  @override
  void initState() {
    getPodcasts();
    super.initState();
  }

  Future<void> getPodcasts() async {
    try {
      await podcastService.fetchTrending(reload: false);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(builder: (context, audioProvider, _) {
      return RefreshIndicator(
        onRefresh: () async {
          await PodcastService().fetchTrending(
            reload: true,
          );
          if (mounted) {
            setState(() {});
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(),
          body: SafeArea(
            child: _buildPodcasts(context),
          ),
          bottomNavigationBar: audioProvider.currentMediaItem != null
              ? MiniPlayer(
                  mediaItem: audioProvider.currentMediaItem!,
                )
              : null,
        ),
      );
    });
  }

  dynamic _buildAppBar() {
    return AppBar(
      title: Text(
        'Podcasts',
        style: Theme.of(context).textTheme.headline6?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildPodcasts(BuildContext context) {
    return ValueListenableBuilder<Box<PodcastModel>?>(
      valueListenable: Hive.box<PodcastModel>('podcasts').listenable(),
      builder: (context, podcastBox, _) {
        final podcasts = podcastBox?.values.toList() ?? [];
        if (podcasts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: kContentSpacing16),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: podcasts.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: kContentSpacing8,
                mainAxisExtent: 250,
              ),
              itemBuilder: (context, index) {
                return PodcastCard(
                  width: double.infinity,
                  height: 180,
                  podcast: podcasts[index],
                  onTap: () async {
                    final audioProvider =
                        Provider.of<AudioProvider>(context, listen: false);
                    Navigator.push(context, CupertinoPageRoute(
                      builder: (context) {
                        return ChangeNotifierProvider.value(
                          value: audioProvider,
                          child: PodcastDetailScreen(
                            podcast: podcasts[index],
                          ),
                        );
                      },
                    ));
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
