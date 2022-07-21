import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/podcast_model.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/screens/podcast_detail_screen/podcast_detail_screen.dart';
import 'package:flutter_podcast_player/services/listen_notes_api.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/widgets/podcast_card.dart';
import 'package:flutter_podcast_player/widgets/text_form_field.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController searchCntlr = TextEditingController();

  ListenNotesAPI listenNotes = ListenNotesAPI();
  late final getTrending = ListenNotesAPI().fetchTrending();

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
          padding: const EdgeInsets.all(kContentSpacing16),
          child: Column(
            children: [
              _buildSearch(),
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
    return Column(
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
    );
  }

  Widget _buildResults() {
    if (isLoading) {
      return const CircularProgressIndicator();
    }
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
          onTap: () async {
            FocusScope.of(context).unfocus();
            final audioProvider =
                Provider.of<AudioProvider>(context, listen: false);

            // List<EpisodeModel>? episodes = await ListenNotesAPI().fetchEpisodes(
            //   id: podcasts[index].id,
            //   rss: podcasts[index].rss,
            // );
            // if (episodes != null) {
            //   podcasts[index].episodes?.addAll(episodes);
            // }
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
