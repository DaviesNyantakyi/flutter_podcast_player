import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final Widget? suffix;
  final String? hintText;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;

  const CustomTextFormField({
    Key? key,
    this.controller,
    this.suffix,
    this.onTap,
    this.readOnly = false,
    this.textInputAction,
    this.onFieldSubmitted,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      readOnly: readOnly,
      style: Theme.of(context).textTheme.bodyText1?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
      cursorColor: kBlue,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        suffix: suffix,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(kRadius),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(kRadius),
          ),
        ),
        hintStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
              color: Colors.black.withOpacity(
                0.5,
              ),
              fontWeight: FontWeight.bold,
            ),
        hintText: hintText,
      ),
    );
  }
}
