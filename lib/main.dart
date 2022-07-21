import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_podcast_player/providers/audio_provider.dart';
import 'package:flutter_podcast_player/screens/bottom_nav.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';
import 'package:provider/provider.dart';

late AudioProvider _audioProvider;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _audioProvider = await initAudioSerivce();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          headline6: TextStyle(fontWeight: FontWeight.normal),
          bodyText1: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          bodyText2: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        ),
        brightness: Brightness.dark,
        bottomSheetTheme: const BottomSheetThemeData(),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: kBlue,
          secondary: kBlue,
        ),
        appBarTheme: const AppBarTheme(elevation: 0, color: Colors.transparent),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(kBlue),
          ),
        ),
        sliderTheme: SliderThemeData(
          thumbColor: Colors.white,
          inactiveTrackColor: kGrey,
          overlayShape: SliderComponentShape.noOverlay,
        ),
      ),
      home: MultiProvider(
        providers: [
          // ChangeNotifierProvider<PodcastProvider>(
          //   create: (context) => PodcastProvider(),
          // ),
          ChangeNotifierProvider<AudioProvider>(
            create: (context) => _audioProvider,
          )
        ],
        child: const BottomNav(),
      ),
    );
  }
}