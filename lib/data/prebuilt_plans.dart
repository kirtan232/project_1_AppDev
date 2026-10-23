import '../logic/plan_rules.dart';
import '../models/plan_exercise.dart';
import '../models/workout_plan.dart';

// This file lists the three plans that come with the app.
class PrebuiltPlans {
  // The default rest time is used to estimate how long each plan takes.
  static const int defaultRestSeconds = 20;

  // This method builds one exercise and sets its target from the difficulty.
  static PlanExercise _exercise(String name, String type, String difficulty) {
    return PlanExercise(
      name: name,
      difficulty: difficulty,
      type: type,
      target: PlanRules.targetFor(difficulty, type),
    );
  }

  // This method builds a full plan and calculates its estimated minutes.
  static WorkoutPlan _plan(
    String title,
    String description,
    List<PlanExercise> exercises,
  ) {
    return WorkoutPlan(
      title: title,
      description: description,
      focusArea: 'Full Body',
      exercises: exercises,
      estMinutes: PlanRules.estimateMinutes(exercises, defaultRestSeconds),
      isPrebuilt: true,
      createdAt: DateTime.now(),
    );
  }

  // This method returns the Easy, Medium, and Hard plans in that order.
  static List<WorkoutPlan> all() {
    return [
      _plan('Easy 5-Minute Workout', 'A gentle full-body start.', [
        _exercise('Jumping Jack', 'timed', 'Easy'),
        _exercise('Wall Push-up', 'reps', 'Easy'),
        _exercise('Split Squat', 'reps', 'Easy'),
        _exercise('Glute Bridge', 'reps', 'Easy'),
        _exercise('Calf Raise', 'reps', 'Easy'),
        _exercise('Crunch', 'reps', 'Easy'),
        _exercise('High Knees', 'timed', 'Easy'),
        _exercise('Side Plank', 'timed', 'Easy'),
      ]),
      _plan('Medium 10-Minute Workout', 'A steady full-body routine.', [
        _exercise('Jumping Jack', 'timed', 'Medium'),
        _exercise('Push-up', 'reps', 'Medium'),
        _exercise('Jump Squat', 'reps', 'Medium'),
        _exercise('Forward Lunge', 'reps', 'Medium'),
        _exercise('Mountain Climber', 'timed', 'Medium'),
        _exercise('Glute Bridge', 'reps', 'Medium'),
        _exercise('Russian Twist', 'reps', 'Medium'),
        _exercise('Bicycle Crunch', 'reps', 'Medium'),
        _exercise('Skater Hops', 'timed', 'Medium'),
        _exercise('Chair Dip', 'reps', 'Medium'),
        _exercise('Flutter Kicks', 'timed', 'Medium'),
      ]),
      _plan('Hard 15-Minute Workout', 'A tougher full-body challenge.', [
        _exercise('Burpee', 'reps', 'Difficult'),
        _exercise('Diamond Push-up', 'reps', 'Difficult'),
        _exercise('Jump Squat', 'reps', 'Difficult'),
        _exercise('Mountain Climber', 'timed', 'Difficult'),
        _exercise('Forward Lunge', 'reps', 'Difficult'),
        _exercise('Superman Push-up', 'reps', 'Difficult'),
        _exercise('Skater Hops', 'timed', 'Difficult'),
        _exercise('Sit-up', 'reps', 'Difficult'),
        _exercise('Side Plank', 'timed', 'Difficult'),
        _exercise('Bear Crawl', 'timed', 'Difficult'),
        _exercise('Inchworm', 'reps', 'Difficult'),
        _exercise('High Knees', 'timed', 'Difficult'),
        _exercise('Wall Sit March', 'timed', 'Difficult'),
        _exercise('Russian Twist', 'reps', 'Difficult'),
      ]),
    ];
  }
}
