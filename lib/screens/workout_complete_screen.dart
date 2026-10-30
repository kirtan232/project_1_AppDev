import 'package:flutter/material.dart';

import '../app_theme.dart';

// This screen celebrates a finished workout and shows its totals.
class WorkoutCompleteScreen extends StatelessWidget {
  final int exerciseCount;
  final int totalReps;
  final int minutes;

  const WorkoutCompleteScreen({
    super.key,
    required this.exerciseCount,
    required this.totalReps,
    required this.minutes,
  });

  // This method builds the summary line, such as "8 exercises, 96 reps, 9 min".
  String _summary() {
    final exerciseWord = exerciseCount == 1 ? 'exercise' : 'exercises';
    final parts = ['$exerciseCount $exerciseWord'];

    // A plan with only timed exercises has no reps to show.
    if (totalReps > 0) parts.add('$totalReps reps');

    parts.add('$minutes min');
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 96, color: AppColors.mint),
                const SizedBox(height: 16),
                Text(
                  'Workout complete!',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _summary(),
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to plans'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
