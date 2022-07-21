import 'package:flutter/material.dart';

import '../utilities/constant.dart';

Future<dynamic> showCustomBottomSheet({
  required BuildContext context,
  bool isDismissible = true,
  double? height,
  double? width,
  bool enableDrag = true,
  bool isScrollControlled = true,
  final Widget? header,
  Color? backgroundColor,
  required Widget child,
}) async {
  SizedBox _buildHeader() {
    return SizedBox(height: 64, child: header);
  }

  Expanded _buildBody() {
    return Expanded(
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }

  return showModalBottomSheet(
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    isScrollControlled: isScrollControlled,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(kRadius),
      ),
    ),
    context: context,
    builder: (context) {
      return SafeArea(
        child: SizedBox(
          height: height,
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(kContentSpacing16),
            child: Material(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(kRadius),
                topRight: Radius.circular(kRadius),
              ),
              color: backgroundColor,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildBody(),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
