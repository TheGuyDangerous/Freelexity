import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/library/library_screen.dart';
import '../../screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const SearchScreen(),
    const LibraryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Iconsax.search_normal),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.book_1),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.setting_2),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
