import 'training_log.dart';

// This class groups the sets that share a session key into one workout.
// It is built from training_logs rows, so it is not a third database table.
class WorkoutSession {
  final String sessionKey;
  final int workoutId;
  final String planTitle;

  // The sets are stored oldest first.
  final List<TrainingLog> sets;

  const WorkoutSession({
    required this.sessionKey,
    required this.workoutId,
    required this.planTitle,
    required this.sets,
  });

  // This getter returns the time of the first set.
  DateTime get startedAt => sets.first.loggedAt;

  // This getter is true when the session was finished.
  bool get finished => sets.any((set) => set.sessionFinished);

  // This getter returns the minutes between the first and last set, at least one.
  int get durationMinutes {
    final minutes = sets.last.loggedAt
        .difference(sets.first.loggedAt)
        .inMinutes;
    return minutes < 1 ? 1 : minutes;
  }

  // This method turns database rows into sessions, with the newest first.
  // Each row must also have a plan_title value from the workout_plans table.
  static List<WorkoutSession> groupRows(List<Map<String, dynamic>> rows) {
    final Map<String, List<TrainingLog>> groups = {};
    final Map<String, String> titles = {};

    for (final row in rows) {
      final log = TrainingLog.fromMap(row);
      groups.putIfAbsent(log.sessionKey, () => []).add(log);
      titles[log.sessionKey] = row['plan_title'] as String;
    }

    final sessions = groups.entries.map((entry) {
      return WorkoutSession(
        sessionKey: entry.key,
        workoutId: entry.value.first.workoutId,
        planTitle: titles[entry.key]!,
        sets: entry.value,
      );
    }).toList();

    // Two sessions at the same time are ordered by their key so the list is stable.
    sessions.sort((a, b) {
      final byTime = b.startedAt.compareTo(a.startedAt);
      return byTime != 0 ? byTime : a.sessionKey.compareTo(b.sessionKey);
    });
    return sessions;
  }
}
