// This class is one row of the training_logs table, which is one logged set.
class TrainingLog {
  // The id is null until the set is saved to the database.
  final int? id;

  // This is the id of the workout plan that the set belongs to.
  final int workoutId;

  // All sets from one workout share the same session key.
  final String sessionKey;
  final String exerciseLabel;

  // The amount is the number of reps or seconds the user actually did.
  final int amount;

  // The unit is "reps" or "sec".
  final String unit;
  final DateTime loggedAt;

  // This is true when the session was finished and false when it was not.
  final bool sessionFinished;

  const TrainingLog({
    this.id,
    required this.workoutId,
    required this.sessionKey,
    required this.exerciseLabel,
    required this.amount,
    required this.unit,
    required this.loggedAt,
    required this.sessionFinished,
  });

  // This method turns the set into a map whose keys match the table columns.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'session_key': sessionKey,
      'exercise_label': exerciseLabel,
      'amount': amount,
      'unit': unit,
      'logged_at': loggedAt.toIso8601String(),
      // SQLite has no true or false, so 1 and 0 are used instead.
      'session_finished': sessionFinished ? 1 : 0,
    };
  }

  // This constructor rebuilds a set from a database row.
  factory TrainingLog.fromMap(Map<String, dynamic> map) {
    return TrainingLog(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      sessionKey: map['session_key'] as String,
      exerciseLabel: map['exercise_label'] as String,
      amount: map['amount'] as int,
      unit: map['unit'] as String,
      loggedAt: DateTime.parse(map['logged_at'] as String),
      sessionFinished: map['session_finished'] == 1,
    );
  }
}
