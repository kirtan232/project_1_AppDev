import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'screens/app_shell.dart';

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
      home: const AppShell(),
    );
  }
}
