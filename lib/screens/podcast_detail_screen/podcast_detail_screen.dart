import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/podcast_model.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/utilities/custom_scroll_behavior.dart';
import 'package:flutter_podcast_player/widgets/elevated_button.dart';
import 'package:flutter_podcast_player/widgets/episode_tile.dart';
import 'package:flutter_podcast_player/widgets/podcast_image.dart';

class PodcastDetailScreen extends StatefulWidget {
  final PodcastModel podcast;
  const PodcastDetailScreen({
    Key? key,
    required this.podcast,
  }) : super(key: key);

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kContentSpacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: kContentSpacing24),
                _buildPlayShuffleButton(),
                const SizedBox(height: kContentSpacing24),
                _buildEpisodes()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodes() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.podcast.episodes?.length ?? 0,
      separatorBuilder: (conext, index) {
        return const SizedBox(height: kContentSpacing8);
      },
      itemBuilder: (conext, index) {
        if (widget.podcast.episodes?[index] == null) {
          return Container();
        }
        return EpisodeTile(
          episode: widget.podcast.episodes![index],
          onPressed: () => showPlayer(
            context: conext,
            episode: widget.podcast.episodes![index],
          ),
          addQueueOnPressed: () => addToQueue(
              episode: widget.podcast.episodes![index], context: conext),
          downloadOnPressed: () {},
        );
      },
    );
  }

  dynamic _buildAppBar() {
    return AppBar(
      toolbarHeight: 74,
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(BootstrapIcons.arrow_left),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          tooltip: 'Search',
          icon: const Icon(
            BootstrapIcons.search,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PodcastImage(
          imageURL: widget.podcast.image ?? '',
          width: 140,
          height: 140,
        ),
        const SizedBox(width: kContentSpacing16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.podcast.episodes?.length ?? 0} episodes',
                style: Theme.of(context).textTheme.caption,
              ),
              const SizedBox(height: kContentSpacing8),
              Text(
                '${widget.podcast.title}',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: kContentSpacing8),
              Text(
                '${widget.podcast.author}',
                style: Theme.of(context).textTheme.caption,
              ),
              const SizedBox(height: kContentSpacing16),
              _buildCollectionDownloadButton(),
            ],
          ),
        )
      ],
    );
  }

  Row _buildCollectionDownloadButton() {
    return Row(
      children: [
        IconButton(
          tooltip: 'Add to collection',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(BootstrapIcons.folder_plus),
          onPressed: () {},
        ),
        const SizedBox(width: kContentSpacing16),
        IconButton(
          tooltip: 'Download',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            BootstrapIcons.arrow_down_circle,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPlayShuffleButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: _buildPlayButton(
            icon: BootstrapIcons.play,
            label: 'Play',
            onPressed: () async {
              if (widget.podcast.episodes != null) {
                await showPlayer(
                  context: context,
                  episode: widget.podcast.episodes!.first,
                );
              }
            },
          ),
        ),
        const SizedBox(width: kContentSpacing16),
        Expanded(
          child: _buildPlayButton(
            icon: BootstrapIcons.shuffle,
            label: 'Shuffel',
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return CustomElevatedButton(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      height: 42,
      width: null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: kBlack,
          ),
          const SizedBox(width: kContentSpacing8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  color: kBlack,
                ),
          )
        ],
      ),
    );
  }
}
