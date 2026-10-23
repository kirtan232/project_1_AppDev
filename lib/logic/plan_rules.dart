import '../models/plan_exercise.dart';

// These rules turn a difficulty into a target and estimate how long a plan takes.
class PlanRules {
  // This is the guess for how many seconds one rep takes.
  static const int secondsPerRep = 3;

  // This method returns the target reps or seconds for a difficulty.
  // Easy is 8 reps or 20 seconds, Medium is 12 or 30, and Difficult is 16 or 45.
  static int targetFor(String difficulty, String type) {
    final bool timed = type == 'timed';
    switch (difficulty) {
      case 'Medium':
        return timed ? 30 : 12;
      case 'Difficult':
        return timed ? 45 : 16;
      default:
        return timed ? 20 : 8;
    }
  }

  // This method adds up the exercise time and the rests between exercises.
  // The result is rounded to whole minutes and is never less than one.
  static int estimateMinutes(List<PlanExercise> exercises, int restSeconds) {
    if (exercises.isEmpty) return 1;

    int totalSeconds = 0;
    for (final exercise in exercises) {
      if (exercise.type == 'timed') {
        totalSeconds += exercise.target;
      } else {
        totalSeconds += exercise.target * secondsPerRep;
      }
    }

    // There is one rest between each pair of exercises.
    totalSeconds += restSeconds * (exercises.length - 1);

    final minutes = (totalSeconds / 60).round();
    return minutes < 1 ? 1 : minutes;
  }
}
