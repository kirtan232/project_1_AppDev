import '../models/workout_plan.dart';
import 'plan_rules.dart';

// This class holds what the helper returns to the screen.
class FocusMatchResult {
  // The plan is null when there are no plans to suggest.
  final WorkoutPlan? plan;

  // This text explains why the plan was suggested, or what to do next.
  final String reason;

  // This extra message is shown when the saved preference cannot be used.
  final String? notice;

  const FocusMatchResult({
    required this.plan,
    required this.reason,
    this.notice,
  });
}

// Focus Match is a rule-based smart helper, not a trained model.
// It only organizes the user's own plans and never gives fitness advice.
class FocusMatch {
  // This method applies the three rules from the proposal.
  // 1. Keep plans in the preferred focus, or all plans if there are none.
  // 2. Pick the plan finished longest ago, and a plan never done counts as oldest.
  // 3. If two plans tie, pick the lower plan id.
  static FocusMatchResult suggest({
    required List<WorkoutPlan> plans,
    required Map<int, DateTime> lastFinished,
    required String? preference,
    required DateTime now,
  }) {
    if (plans.isEmpty) {
      return const FocusMatchResult(plan: null, reason: 'Add a plan first.');
    }

    // A saved focus that is not on the list is treated as no preference.
    final bool invalid =
        preference != null && !PlanRules.focusAreas.contains(preference);
    final String? focus = invalid ? null : preference;

    final matching = plans.where((plan) => plan.focusArea == focus).toList();
    final bool usedFocus = matching.isNotEmpty;
    final candidates = usedFocus ? matching : List.of(plans);

    candidates.sort((a, b) {
      final timeA = lastFinished[a.id];
      final timeB = lastFinished[b.id];
      if (timeA == null && timeB == null) return a.id!.compareTo(b.id!);
      if (timeA == null) return -1;
      if (timeB == null) return 1;
      final byTime = timeA.compareTo(timeB);
      return byTime != 0 ? byTime : a.id!.compareTo(b.id!);
    });

    final plan = candidates.first;
    String reason =
        '${plan.focusArea} plan, ${_lastDoneText(lastFinished[plan.id], now)}';
    if (usedFocus) reason = '$reason, matches your focus';

    String? notice;
    if (invalid) {
      notice = 'Set your focus in Settings.';
    } else if (focus != null && !usedFocus) {
      notice = 'No $focus plans yet, so all plans were checked.';
    }

    return FocusMatchResult(plan: plan, reason: '$reason.', notice: notice);
  }

  // This baseline is the simple method the helper is compared with.
  // It keeps plans in the preferred focus and picks the lowest id, with no variety rule.
  static WorkoutPlan? baseline({
    required List<WorkoutPlan> plans,
    required String? preference,
  }) {
    if (plans.isEmpty) return null;
    final matching = plans
        .where((plan) => plan.focusArea == preference)
        .toList();
    final candidates = matching.isNotEmpty ? matching : List.of(plans);
    candidates.sort((a, b) => a.id!.compareTo(b.id!));
    return candidates.first;
  }

  // This method writes how long ago a plan was finished.
  static String _lastDoneText(DateTime? last, DateTime now) {
    if (last == null) return 'not done yet';
    final days = now.difference(last).inDays;
    if (days == 0) return 'last done today';
    return 'not done in $days ${days == 1 ? 'day' : 'days'}';
  }
}
