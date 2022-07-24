import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchLink({String? url}) async {
  try {
    if (url != null) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}
