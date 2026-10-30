// This class holds the two numbers shown in the stats strip.
class WorkoutStats {
  // Only finished sessions count, and each session counts once.
  final int sessionsThisWeek;

  // Only sets measured in reps count, because timed sets are in seconds.
  final int totalReps;

  const WorkoutStats({required this.sessionsThisWeek, required this.totalReps});

  // This method returns midnight on the Monday of the given date's week.
  static DateTime startOfWeek(DateTime date) {
    // Monday is weekday 1, so this subtracts zero days on a Monday.
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }
}
