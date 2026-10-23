import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'data/database_helper.dart';
import 'data/exercise_library.dart';
import 'screens/app_shell.dart';

// The app opens the database first and then shows the root widget.
Future<void> main() async {
  // Flutter must be ready before plugins such as sqflite can be used.
  WidgetsFlutterBinding.ensureInitialized();

  // This prints the table names in the Debug Console to prove they exist.
  final tables = await DatabaseHelper.instance.tableNames();
  debugPrint('Database tables: $tables');

  // The bundled exercise list is loaded once so every screen can use it.
  await ExerciseLibrary.load();
  debugPrint('Exercises loaded: ${ExerciseLibrary.all.length}');

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
