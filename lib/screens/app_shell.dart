import 'package:flutter/material.dart';

import 'history_screen.dart';
import 'home_screen.dart';
import 'personal_plans_screen.dart';
import 'settings_screen.dart';

// This screen holds the top bar and the bottom navigation for the three main tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // This number remembers which tab is selected, starting with Home.
  int _selectedIndex = 0;

  // These titles match the tabs in the same order.
  final List<String> _titles = ['Home', 'Personal Plans', 'History'];

  // This method returns the screen for the selected tab.
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const PersonalPlansScreen();
      case 2:
        return const HistoryScreen();
      default:
        return const HomeScreen();
    }
  }

  // This method opens the Settings screen on top of the current tab.
  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Personal Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
