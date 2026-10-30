import 'package:flutter/material.dart';

import 'countdown_ring.dart';

// This reusable card shows the rest countdown and the exercise coming next.
class RestCard extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;
  final String nextExerciseName;

  const RestCard({
    super.key,
    required this.secondsLeft,
    required this.totalSeconds,
    required this.nextExerciseName,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rest',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                CountdownRing(
                  secondsLeft: secondsLeft,
                  totalSeconds: totalSeconds,
                ),
                const SizedBox(height: 20),
                Text('Next: $nextExerciseName', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
