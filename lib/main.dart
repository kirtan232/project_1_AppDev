import 'package:flutter/material.dart';

import 'app_theme.dart';

// The app starts here and shows the root widget.
void main() {
  runApp(const HomeFitApp());
}

// This is the root widget of HomeFit Quest.
class HomeFitApp extends StatelessWidget {
  const HomeFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeFit Quest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // The phone setting picks the theme until the Settings screen is built.
      themeMode: ThemeMode.system,
      home: const ThemePreviewScreen(),
    );
  }
}

// This temporary screen shows the theme and is replaced in the next step.
class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Preview')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Easy 5-Minute Workout',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('5 min · 6 exercises'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: () {}, child: const Text('Start Workout')),
          const SizedBox(height: 16),
          // Status chips always show a word, not only a color.
          const Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text('Finished'),
                backgroundColor: AppColors.mint,
              ),
              Chip(
                label: Text('Not finished'),
                backgroundColor: AppColors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
