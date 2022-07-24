import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/models/podcast_model.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/utilities/hive_boxes.dart';
import 'package:flutter_podcast_player/widgets/podcast_card.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/audio_provider.dart';
import '../podcast_detail_screen/podcast_detail_screen.dart';

class SubScriptionsScreen extends StatefulWidget {
  const SubScriptionsScreen({Key? key}) : super(key: key);

  @override
  State<SubScriptionsScreen> createState() => _SubScriptionsScreenState();
}

class _SubScriptionsScreenState extends State<SubScriptionsScreen> {
  final hiveBoxes = HiveBoxes();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ValueListenableBuilder<Box<PodcastModel>>(
        valueListenable: Hive.box<PodcastModel>('subscriptions').listenable(),
        builder: (context, box, _) {
          final subBox = box.values.toList();

          if (subBox.isEmpty) {
            return _buildNoSubscriptionsText();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(kContentSpacing16),
            shrinkWrap: true,
            itemCount: subBox.length,
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
                podcast: subBox[index],
                onTap: () async {
                  final audioProvider =
                      Provider.of<AudioProvider>(context, listen: false);
                  Navigator.push(context, CupertinoPageRoute(
                    builder: (context) {
                      return ChangeNotifierProvider.value(
                        value: audioProvider,
                        child: PodcastDetailScreen(
                          podcast: subBox[index],
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
    );
  }

  Widget _buildNoSubscriptionsText() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            BootstrapIcons.folder_plus,
            size: 64,
          ),
          const SizedBox(height: kContentSpacing14),
          Text(
            'No subscriptions',
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

  dynamic _buildAppBar() {
    return AppBar(
      toolbarHeight: 74,
      title: Text(
        'Subscriptions',
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
}
