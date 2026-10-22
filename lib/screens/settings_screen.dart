import 'package:flutter/material.dart';

// This is a placeholder for the Settings screen until its controls are built.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The AppBar adds a back button at the top left automatically.
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings')),
    );
  }
}
