import 'package:flutter/material.dart';

import '../logic/focus_match.dart';

// This reusable card shows the Focus Match suggestion and its explanation.
// The buttons leave the choice with the user, and nothing starts by itself.
class SuggestionCard extends StatelessWidget {
  final FocusMatchResult result;
  final VoidCallback onViewPlan;
  final VoidCallback onNotNow;

  const SuggestionCard({
    super.key,
    required this.result,
    required this.onViewPlan,
    required this.onNotNow,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final plan = result.plan;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The label says honestly that this is a rule, not a trained model.
            Text(
              'Focus Match · Simple AI',
              style: textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            if (plan != null)
              Text(
                'Try ${plan.title}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 4),
            Text(result.reason, style: textTheme.bodyMedium),
            if (result.notice != null) ...[
              const SizedBox(height: 4),
              Text(result.notice!, style: textTheme.bodySmall),
            ],
            if (plan != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onNotNow,
                      child: const Text('Not Now'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onViewPlan,
                      child: const Text('View Plan'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
