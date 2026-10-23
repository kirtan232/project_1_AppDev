// This class is one exercise inside a workout plan, such as "Push-up (Easy)".
class PlanExercise {
  final String name;

  // The difficulty is "Easy", "Medium", or "Difficult".
  final String difficulty;

  // The type is "reps" for counted moves or "timed" for held moves.
  final String type;

  // The target is a number of reps or a number of seconds, based on the type.
  final int target;

  const PlanExercise({
    required this.name,
    required this.difficulty,
    required this.type,
    required this.target,
  });

  // This getter returns the unit word that is saved with each logged set.
  String get unit => type == 'timed' ? 'sec' : 'reps';

  // This getter returns readable text such as "12 reps" or "30 sec".
  String get targetLabel => '$target $unit';

  // This method turns the exercise into a map so it can be saved as JSON.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'difficulty': difficulty,
      'type': type,
      'target': target,
    };
  }

  // This constructor rebuilds an exercise from a saved map.
  factory PlanExercise.fromMap(Map<String, dynamic> map) {
    return PlanExercise(
      name: map['name'] as String,
      difficulty: map['difficulty'] as String,
      type: map['type'] as String,
      target: map['target'] as int,
    );
  }
}
