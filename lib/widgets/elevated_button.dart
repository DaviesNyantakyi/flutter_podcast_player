import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  final double? height;
  final double? width;
  final Color? backgroundColor;
  const CustomElevatedButton({
    Key? key,
    this.onPressed,
    this.height = 52,
    this.width = 100,
    this.backgroundColor,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(backgroundColor ?? kBlue),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
