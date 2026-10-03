import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../services/saved_chats_controller.dart';
import '../themes/theme_colors.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';

class BottomTabScreen extends StatefulWidget {
  const BottomTabScreen({super.key});

  @override
  State<BottomTabScreen> createState() => _BottomTabScreenState();
}

class _BottomTabScreenState extends State<BottomTabScreen> {
  int _index = 0;
  static const _pages = [HomeScreen(), SavedScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SavedChatsController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        height: 64,
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.surfaceAlt,
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Ask'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline_rounded), selectedIcon: Icon(Icons.bookmark_rounded), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
