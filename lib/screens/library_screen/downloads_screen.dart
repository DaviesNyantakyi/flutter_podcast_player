import 'package:audio_service/audio_service.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/episode_model.dart';
import 'package:flutter_podcast_player/widgets/episode_tile.dart';
import 'package:hive_flutter/adapters.dart';

import '../../providers/audio_provider.dart';
import '../../utilities/constant.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ValueListenableBuilder<Box<EpisodeModel>>(
        valueListenable: Hive.box<EpisodeModel>('downloads').listenable(),
        builder: (context, box, _) {
          final downloadBox = box.values.toList();

          if (downloadBox.isEmpty) {
            return _buildNoSubscriptionsText();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(kContentSpacing16),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: downloadBox.length,
            separatorBuilder: (conext, index) {
              return const SizedBox(height: kContentSpacing8);
            },
            itemBuilder: (conext, index) {
              if (downloadBox.isEmpty) {
                return _buildNoSubscriptionsText();
              }
              return EpisodeTile(
                episode: downloadBox[index],
                onPressed: () => showPlayer(
                  context: conext,
                  mediaItem: MediaItem(
                    id: downloadBox[index].id,
                    title: downloadBox[index].title ?? '',
                    artist: downloadBox[index].author,
                    duration: Duration(
                      seconds: downloadBox[index].duration ?? 0,
                    ),
                    displayDescription: downloadBox[index].description,
                    artUri: downloadBox[index].image != null
                        ? Uri.parse(downloadBox[index].image!)
                        : null,
                    extras: {
                      'audio': downloadBox[index].audio,
                      'downloadPath': downloadBox[index].downloadPath,
                      'pubDate': downloadBox[index].pubDate,
                      'pageLink': downloadBox[index].pageLink
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  dynamic _buildAppBar() {
    return AppBar(
      toolbarHeight: 74,
      title: Text(
        'Downloads',
        style: Theme.of(context).textTheme.headline6?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(BootstrapIcons.arrow_left),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildNoSubscriptionsText() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            BootstrapIcons.arrow_down_circle,
            size: 64,
          ),
          const SizedBox(height: kContentSpacing14),
          Text(
            'No downloaded episode',
            style: Theme.of(context)
                .textTheme
                .headline6
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Tap this button on any podcast to see',
            style: Theme.of(context).textTheme.bodyText1?.copyWith(),
          ),
          Text(
            'new episodes at a glance',
            style: Theme.of(context).textTheme.bodyText1?.copyWith(),
          ),
        ],
      ),
    );
  }
}
