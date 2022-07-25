import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/podcast_model.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/screens/podcast_detail_screen/podcast_detail_screen.dart';
import 'package:flutter_podcast_player/services/podcast_service.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/widgets/podcast_card.dart';
import 'package:flutter_podcast_player/widgets/text_form_field.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../utilities/custom_scroll_behavior.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController searchCntlr = TextEditingController();

  PodcastService listenNotes = PodcastService();

  List<PodcastModel> podcasts = [];

  bool isLoading = false;

  Future<void> search() async {
    try {
      if (searchCntlr.text.isNotEmpty) {
        isLoading = true;
        setState(() {});

        final results =
            await listenNotes.featchSearchPodcast(query: searchCntlr.text);
        if (results != null) {
          podcasts.clear();
          podcasts.addAll(results);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearch(),
              const SizedBox(height: kContentSpacing24),
              _buildPodcasts(context),
              const SizedBox(height: kContentSpacing24),
              _buildResults()
            ],
          ),
        ),
      ),
    );
  }

  dynamic _buildAppBar() {
    return AppBar(
      title: Text(
        'Search',
        style: Theme.of(context)
            .textTheme
            .headline6
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kContentSpacing16),
      child: Column(
        children: [
          CustomTextFormField(
            controller: searchCntlr,
            hintText: 'Podcast',
            textInputAction: TextInputAction.search,
            suffix: IconButton(
              tooltip: 'Search',
              constraints:
                  const BoxConstraints(), // Removes padding around button.
              padding: EdgeInsets.zero,
              icon: const Icon(
                BootstrapIcons.search,
                color: kBlack,
              ),
              onPressed: search,
            ),
            onFieldSubmitted: (value) => search(),
          ),
        ],
      ),
    );
  }

  Widget _buildPodcasts(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 170,
      child: ValueListenableBuilder<Box<PodcastModel>?>(
        valueListenable: Hive.box<PodcastModel>('podcasts').listenable(),
        builder: (context, podcastBox, _) {
          final podcasts = podcastBox?.values.toList() ?? [];

          if (podcasts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: kContentSpacing16,
              ),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: podcasts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: kContentSpacing8),
                  child: PodcastCard(
                    width: 100,
                    height: 100,
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildResults() {
    if (isLoading) {
      return const CircularProgressIndicator();
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: kContentSpacing16),
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
            FocusScope.of(context).unfocus();
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
  }
}
