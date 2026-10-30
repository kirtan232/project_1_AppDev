import 'package:flutter/material.dart';

import '../models/workout_plan.dart';

// This bottom sheet shows a plan's exercises so the user can decide what to do.
// It closes with true only when the user presses Start Workout.
class PlanPreviewSheet extends StatelessWidget {
  final WorkoutPlan plan;

  const PlanPreviewSheet({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(plan.title, style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('${plan.focusArea} · ${plan.estMinutes} min'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: plan.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = plan.exercises[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(exercise.name),
                      subtitle: Text(
                        '${exercise.difficulty} · ${exercise.targetLabel}',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Start Workout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
