import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'data/exercise_library.dart';
import 'logic/app_settings.dart';
import 'screens/app_shell.dart';

// The app loads the exercise list and the settings first, then shows the root widget.
Future<void> main() async {
  // Flutter must be ready before plugins such as sqflite can be used.
  WidgetsFlutterBinding.ensureInitialized();

  // The bundled exercise list is loaded once so every screen can use it.
  await ExerciseLibrary.load();

  // The saved settings are read before the first screen so the theme is right.
  await AppSettings.instance.load();

  runApp(const HomeFitApp());
}

// This is the root widget of HomeFit Quest.
class HomeFitApp extends StatelessWidget {
  const HomeFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The app redraws with the new theme as soon as dark mode is switched.
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'HomeFit Quest',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: AppSettings.instance.themeMode,
          home: const AppShell(),
        );
      },
    );
  }
}
