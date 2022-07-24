import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/screens/library_screen/downloads_screen.dart';
import 'package:flutter_podcast_player/screens/library_screen/subscriptions_screen.dart';
import 'package:provider/provider.dart';

import '../../services/podcast_service.dart';
import '../../utilities/constant.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final getTrending = PodcastService().fetchTrending(reload: false);

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(builder: (context, audioProvider, _) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kContentSpacing16),
            child: Column(
              children: [
                _tile(
                  leading: const Icon(BootstrapIcons.folder),
                  title: Text(
                    'Subscriptions',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                        value: audioProvider,
                        child: const SubScriptionsScreen(),
                      ),
                    ),
                  ),
                ),
                _tile(
                  leading: const Icon(BootstrapIcons.arrow_down_circle),
                  title: Text(
                    'Downloads',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                        value: audioProvider,
                        child: const DownloadsScreen(),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  dynamic _buildAppBar() {
    return AppBar(
      title: Text(
        'Library',
        style: Theme.of(context).textTheme.headline6?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _tile({
    required Widget leading,
    required Widget title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: leading,
      title: title,
      onTap: onTap,
      trailing: IconButton(
        onPressed: onTap,
        icon: const Icon(BootstrapIcons.chevron_right),
      ),
    );
  }
}
