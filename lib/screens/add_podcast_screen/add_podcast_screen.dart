import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:flutter_podcast_player/widgets/elevated_button.dart';
import 'package:flutter_podcast_player/widgets/text_form_field.dart';

class AddPodcastScreen extends StatefulWidget {
  const AddPodcastScreen({Key? key}) : super(key: key);

  @override
  State<AddPodcastScreen> createState() => _AddPodcastScreenState();
}

class _AddPodcastScreenState extends State<AddPodcastScreen> {
  final TextEditingController urlCntlr = TextEditingController();

  // Future<void> addPodcast() async {
  //   try {
  //     // final podcastServices = Provider.of<PodcastProvider>(
  //     //   context,
  //     //   listen: false,
  //     // );
  //     FocusScope.of(context).unfocus();
  //     if (urlCntlr.text.isNotEmpty) {
  //       final String? message =
  //           await podcastServices.addPodcast(url: urlCntlr.text);
  //       if (message != null && mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text(message)),
  //         );
  //       }
  //     }

  //     urlCntlr.clear();
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kContentSpacing16),
          child: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: kContentSpacing24),
              _buildAddButton()
            ],
          ),
        ),
      ),
    );
  }

  dynamic _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Add Podcast',
        style: Theme.of(context)
            .textTheme
            .headline6
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  CustomTextFormField _buildSearchField() {
    return CustomTextFormField(
      controller: urlCntlr,
      hintText: 'RssFeed',
      suffix: IconButton(
        tooltip: 'Clear',
        constraints: const BoxConstraints(), // Removes padding around button.
        padding: EdgeInsets.zero,
        onPressed: () {
          FocusScope.of(context).unfocus();
          urlCntlr.clear();
        },
        icon: const Icon(
          BootstrapIcons.trash,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return CustomElevatedButton(
      width: double.infinity,
      onPressed: () {},
      child: Text(
        'Add Podcast',
        style: Theme.of(context)
            .textTheme
            .bodyText1
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
