import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/workout_plan.dart';
import 'plan_icon.dart';

// This reusable card shows one workout plan and runs onTap when it is pressed.
class PlanCard extends StatelessWidget {
  final WorkoutPlan plan;
  final VoidCallback onTap;

  // This optional widget is shown on the right, such as an edit button.
  final Widget? trailing;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.trailing,
  });

  // This method picks a color for the difficulty chip.
  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppColors.mint;
      case 'Medium':
        return AppColors.amber;
      case 'Difficult':
        return AppColors.coral;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final difficulty = plan.difficultyLabel;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // The round icon gives each card a clear starting point.
              PlanIcon(plan: plan, size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // The description is shown on one line only when it is not empty.
                    if (plan.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        plan.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${plan.estMinutes} min · '
                      '${plan.exercises.length} exercises',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    // The chip shows the difficulty as a word, not only a color.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _difficultyColor(difficulty),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        difficulty,
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // The question mark adds the extra widget only when it is not null.
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
