import 'package:audio_service/audio_service.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/podcast_model.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/utilities/custom_scroll_behavior.dart';
import 'package:flutter_podcast_player/utilities/hive_boxes.dart';
import 'package:flutter_podcast_player/utilities/url_launcher.dart';
import 'package:flutter_podcast_player/widgets/elevated_button.dart';
import 'package:flutter_podcast_player/widgets/episode_tile.dart';
import 'package:flutter_podcast_player/widgets/podcast_image.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
                _buildPlayButton(),
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
            mediaItem: MediaItem(
              id: widget.podcast.episodes![index].id,
              title: widget.podcast.episodes![index].title ?? '',
              artist: widget.podcast.episodes![index].author,
              duration: Duration(
                seconds: widget.podcast.episodes![index].duration ?? 0,
              ),
              displayDescription: widget.podcast.episodes![index].description,
              artUri: widget.podcast.episodes![index].image != null
                  ? Uri.parse(widget.podcast.episodes![index].image!)
                  : null,
              extras: {
                'audio': widget.podcast.episodes![index].audio,
                'downloadPath': widget.podcast.episodes![index].downloadPath,
                'pubDate': widget.podcast.episodes![index].pubDate,
                'pageLink': widget.podcast.episodes![index].pageLink
              },
            ),
          ),
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
          tooltip: 'RSS Feed',
          icon: const Icon(
            BootstrapIcons.rss,
          ),
          onPressed: () => launchLink(url: widget.podcast.rss ?? ''),
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
              _buildIcons(),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildIcons() {
    return ValueListenableBuilder<Box<PodcastModel>>(
        valueListenable: Hive.box<PodcastModel>('subscriptions').listenable(),
        builder: (context, subBox, _) {
          bool subScribed = false;

          final x = subBox.values.cast<PodcastModel>();
          for (var podcast in x) {
            if (podcast.id == widget.podcast.id) {
              subScribed = true;
            }
          }

          return Row(
            children: [
              IconButton(
                tooltip: subScribed ? 'Subscribed' : 'Subscribe',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  subScribed
                      ? BootstrapIcons.check_circle_fill
                      : BootstrapIcons.folder_plus,
                ),
                onPressed: () async {
                  final subBox = HiveBoxes().getSubScriptions();
                  if (subScribed) {
                    subBox.delete(widget.podcast.id);
                  } else {
                    // If you
                    PodcastModel podModel = PodcastModel(
                      id: widget.podcast.id,
                      image: widget.podcast.image,
                      title: widget.podcast.title,
                      description: widget.podcast.description,
                      author: widget.podcast.author,
                      pageLink: widget.podcast.pageLink,
                      rss: widget.podcast.rss,
                      episodes: widget.podcast.episodes,
                    );

                    await subBox.put(widget.podcast.id, podModel);
                  }
                },
              ),
              const SizedBox(width: kContentSpacing16),
              IconButton(
                tooltip: 'Link',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  BootstrapIcons.globe,
                ),
                onPressed: () async {
                  await launchLink(url: widget.podcast.pageLink ?? '');
                },
              ),
            ],
          );
        });
  }

  Widget _buildPlayButton() {
    return CustomElevatedButton(
      onPressed: () async {
        if (widget.podcast.episodes != null) {
          await showPlayer(
            context: context,
            mediaItem: MediaItem(
              id: widget.podcast.episodes?.first.id ?? '',
              title: widget.podcast.episodes?.first.title ?? '',
              artist: widget.podcast.episodes?.first.author,
              duration: Duration(
                seconds: widget.podcast.episodes?.first.duration ?? 0,
              ),
              displayDescription: widget.podcast.episodes?.first.description,
              artUri: widget.podcast.episodes?.first.image != null
                  ? Uri.parse(widget.podcast.episodes!.first.image!)
                  : null,
              extras: {
                'audio': widget.podcast.episodes?.first.audio,
                'downloadPath': widget.podcast.episodes?.first.downloadPath,
                'pubDate': widget.podcast.episodes?.first.pubDate,
                'pageLink': widget.podcast.episodes?.first.pageLink
              },
            ),
          );
        }
      },
      backgroundColor: Colors.white,
      height: 42,
      width: null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            BootstrapIcons.play,
            color: kBlack,
          ),
          const SizedBox(width: kContentSpacing8),
          Text(
            'Play',
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  color: kBlack,
                ),
          )
        ],
      ),
    );
  }
}
