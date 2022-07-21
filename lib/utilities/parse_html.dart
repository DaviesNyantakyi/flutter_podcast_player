import 'package:html/parser.dart';

String parseHtml({required String item}) {
  //Returns a rss description without the p tag.

  final doc = parse(item);
  String newText = doc.body!.text;

  return newText;
}
