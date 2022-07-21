import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';

class PodcastImage extends StatelessWidget {
  final double? height;
  final double? width;
  final String imageURL;

  const PodcastImage({
    Key? key,
    this.height = 120,
    this.width = 120,
    required this.imageURL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(kRadius)),
      child: FancyShimmerImage(
        height: height!,
        width: width!,
        imageUrl: CachedNetworkImageProvider(imageURL).url,
        errorWidget: const Center(child: Icon(BootstrapIcons.image)),
      ),
    );
  }
}
