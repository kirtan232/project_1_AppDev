import 'package:flutter/material.dart';

// This reusable strip shows the weekly session count and the total reps.
class StatsStrip extends StatelessWidget {
  final int sessionsThisWeek;
  final int totalReps;

  const StatsStrip({
    super.key,
    required this.sessionsThisWeek,
    required this.totalReps,
  });

  // This method builds one number with its label underneath.
  Widget _stat(BuildContext context, int value, String label) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            _stat(context, sessionsThisWeek, 'Sessions this week'),
            _stat(context, totalReps, 'Total reps'),
          ],
        ),
      ),
    );
  }
}
