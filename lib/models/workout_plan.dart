import 'dart:convert';

import 'plan_exercise.dart';

// This class is one row of the workout_plans table.
class WorkoutPlan {
  // The id is null until the plan is saved to the database.
  final int? id;
  final String title;
  final String description;

  // The focus area is "Full Body", "Upper", "Lower", "Core", or "Cardio".
  final String focusArea;
  final List<PlanExercise> exercises;
  final int estMinutes;

  // This is true for the Easy, Medium, and Hard plans that come with the app.
  final bool isPrebuilt;
  final DateTime createdAt;

  const WorkoutPlan({
    this.id,
    required this.title,
    required this.description,
    required this.focusArea,
    required this.exercises,
    required this.estMinutes,
    required this.isPrebuilt,
    required this.createdAt,
  });

  // This method turns the plan into a map whose keys match the table columns.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'focus_area': focusArea,
      // The exercise list is stored as one JSON text column.
      'exercises_json': jsonEncode(exercises.map((e) => e.toMap()).toList()),
      'est_minutes': estMinutes,
      // SQLite has no true or false, so 1 and 0 are used instead.
      'is_prebuilt': isPrebuilt ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // This constructor rebuilds a plan from a database row.
  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    final List<dynamic> exerciseList =
        jsonDecode(map['exercises_json'] as String) as List<dynamic>;

    return WorkoutPlan(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      focusArea: map['focus_area'] as String,
      exercises: exerciseList
          .map((e) => PlanExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
      estMinutes: map['est_minutes'] as int,
      isPrebuilt: map['is_prebuilt'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
