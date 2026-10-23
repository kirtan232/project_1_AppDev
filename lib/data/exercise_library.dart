import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/exercise_info.dart';

// This class reads the bundled exercise list once and keeps it in memory.
class ExerciseLibrary {
  static List<ExerciseInfo> _exercises = [];

  // This getter gives every screen the same list after it is loaded.
  static List<ExerciseInfo> get all => _exercises;

  // This method reads assets/data/exercises.json, which is packed inside the app.
  static Future<void> load() async {
    final text = await rootBundle.loadString('assets/data/exercises.json');
    final List<dynamic> list = jsonDecode(text) as List<dynamic>;
    _exercises = list
        .map((item) => ExerciseInfo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // This method finds an exercise by its name, or returns null if it is not found.
  static ExerciseInfo? findByName(String name) {
    for (final exercise in _exercises) {
      if (exercise.name == name) return exercise;
    }
    return null;
  }
}
