import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/voice/voice_screen.dart';
import '../screens/vision/vision_screen.dart';
import '../screens/osint/osint_screen.dart';
import '../screens/creator/creator_screen.dart';
import '../screens/smart_call/smart_call_screen.dart';

class DynamicNavigation extends StatefulWidget {
  const DynamicNavigation({super.key});

  @override
  State<DynamicNavigation> createState() => _DynamicNavigationState();
}

class _DynamicNavigationState extends State<DynamicNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ChatScreen(),
    VoiceScreen(),
    VisionScreen(),
    OsintScreen(),
    CreatorScreen(),
    SmartCallScreen(),
  ];

  final List<_NavigationDestination> _destinations = const [
    _NavigationDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    _NavigationDestination(
      label: 'Chat',
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
    ),
    _NavigationDestination(
      label: 'Voice',
      icon: Icons.mic_none,
      selectedIcon: Icons.mic,
    ),
    _NavigationDestination(
      label: 'Vision',
      icon: Icons.visibility_outlined,
      selectedIcon: Icons.visibility,
    ),
    _NavigationDestination(
      label: 'OSINT',
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
    ),
    _NavigationDestination(
      label: 'Creator',
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
    ),
    _NavigationDestination(
      label: 'Call',
      icon: Icons.phone_outlined,
      selectedIcon: Icons.phone,
    ),
  ];

  void _selectScreen(int index) {
    if (index < 0 || index >= _screens.length) {
      return;
    }

    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _selectScreen,
      destinations: _destinations
          .map(
            (destination) => NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
          )
          .toList(),
    );
  }
}

class _NavigationDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
