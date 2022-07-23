import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/podcast_model.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/screens/podcast_detail_screen/podcast_detail_screen.dart';
import 'package:flutter_podcast_player/services/listen_notes_api.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/utilities/custom_scroll_behavior.dart';
import 'package:flutter_podcast_player/widgets/podcast_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final getTrending = ListenNotesAPI().fetchTrending();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Podcasts',
          style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildRecentlyPlayed(context),
                const SizedBox(height: kContentSpacing24),
                _buildPodcasts(context),
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: _buildMiniPlayer(),
    );
  }

  // Widget _buildMiniPlayer() {
  //   return Consumer<AudioProvider>(
  //     builder: (context, audioProvider, _) {
  //       return GestureDetector(
  //         // onTap: () => showPlayer(context: context),
  //         child: Container(
  //           height: 64,
  //           decoration: const BoxDecoration(
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(kRadius),
  //               topRight: Radius.circular(kRadius),
  //             ),
  //           ),
  //           child: Padding(
  //             padding: const EdgeInsets.all(kContentSpacing8),
  //             child: Row(
  //               children: [
  //                 Expanded(
  //                   flex: 4,
  //                   child: Row(
  //                     children: [
  //                       const PodcastImage(
  //                         width: 50,
  //                         height: 70,
  //                         imageURL: '',
  //                       ),
  //                       const SizedBox(width: kContentSpacing8),
  //                       Expanded(
  //                         flex: 2,
  //                         child: _buildTitle(),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: IconButton(
  //                     tooltip: 'Play & Pause',
  //                     iconSize: 32,
  //                     onPressed: () async {
  //                       if (audioProvider.playerState?.playing == true) {
  //                         await audioProvider.pause();
  //                       } else {
  //                         await audioProvider.play();
  //                       }
  //                     },
  //                     //
  //                     icon: Icon(
  //                       audioProvider.playerState?.playing == false ||
  //                               audioProvider.playerState?.processingState ==
  //                                   ProcessingState.completed
  //                           ? BootstrapIcons.play_circle_fill
  //                           : BootstrapIcons.pause_circle_fill,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _buildTitle() {
  //   return Consumer<AudioProvider>(
  //     builder: (context, audioProvider, _) {
  //       String text = 'test';

  //       switch (audioProvider.playerState?.processingState) {
  //         case ProcessingState.loading:
  //           text = 'Loading...';
  //           break;
  //         case ProcessingState.buffering:
  //           text = 'Buffering...';
  //           break;
  //         default:
  //       }
  //       return Text(
  //         text,
  //         style: Theme.of(context).textTheme.bodyText1,
  //         overflow: TextOverflow.ellipsis,
  //       );
  //     },
  //   );
  // }

  // ignore: unused_element
  Widget _buildRecentlyPlayed(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kContentSpacing16,
            vertical: 16,
          ),
          child: Text(
            'Recently Played',
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: kContentSpacing16),
        SizedBox(
          height: 170,
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: const EdgeInsets.only(
                  left: kContentSpacing16, right: kContentSpacing16),
              physics: const PageScrollPhysics(),
              itemCount: 10,
              separatorBuilder: (context, index) {
                return const SizedBox(width: kContentSpacing16);
              },
              itemBuilder: (context, index) {
                return Container(
                  color: kBlue,
                  width: 100,
                  height: 100,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodcasts(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kContentSpacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<PodcastModel>?>(
            future: getTrending,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final podcasts = snapshot.data ?? [];
              return GridView.builder(
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
                    onTap: () {
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
              );
            },
          ),
        ],
      ),
    );
  }
}
