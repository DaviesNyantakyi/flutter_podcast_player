import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podcast_player/screens/collection_screen/collection_screen.dart';
import 'package:flutter_podcast_player/screens/home_screen/home_screen.dart';
import 'package:flutter_podcast_player/screens/search_screen/explore_screen.dart';
import 'package:flutter_podcast_player/utilities/constant.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int selectedIndex = 0;

  List<Widget> screens = const [
    HomeScreen(),
    ExploreScreen(),
    CollectionScreen(),
  ];

  final List<BottomNavigationBarItem> bottomNavItems = [
    const BottomNavigationBarItem(
      label: 'Home',
      tooltip: 'Home',
      icon: Icon(BootstrapIcons.house),
    ),
    const BottomNavigationBarItem(
      label: 'Explore',
      tooltip: 'Explore',
      icon: Icon(BootstrapIcons.search),
    ),
    const BottomNavigationBarItem(
      label: 'Library',
      tooltip: 'Library',
      icon: Icon(BootstrapIcons.collection),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kBlack,
        currentIndex: selectedIndex,
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        unselectedItemColor: kGrey,
        selectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: bottomNavItems,
        onTap: (value) {
          selectedIndex = value;
          setState(() {});
        },
      ),
    );
  }
}
