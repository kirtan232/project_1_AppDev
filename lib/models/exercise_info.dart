// This class is one exercise from the bundled pick list in exercises.json.
class ExerciseInfo {
  final String name;

  // The focus area is "Full Body", "Upper", "Lower", "Core", or "Cardio".
  final String focusArea;

  // The type is "reps" for counted moves or "timed" for held moves.
  final String type;

  // These are the step-by-step instructions shown on the back of a card.
  final List<String> steps;

  // This is the asset path of the exercise animation GIF.
  final String gif;

  const ExerciseInfo({
    required this.name,
    required this.focusArea,
    required this.type,
    required this.steps,
    required this.gif,
  });

  // This constructor builds an exercise from one entry in the JSON file.
  factory ExerciseInfo.fromJson(Map<String, dynamic> json) {
    return ExerciseInfo(
      name: json['name'] as String,
      focusArea: json['focusArea'] as String,
      type: json['type'] as String,
      steps: (json['steps'] as List<dynamic>).cast<String>(),
      gif: json['gif'] as String,
    );
  }
}
