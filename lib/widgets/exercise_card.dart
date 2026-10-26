import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/exercise_info.dart';
import '../models/plan_exercise.dart';

// This reusable card is one flashcard in the workout player.
// The front shows the GIF, name, and target, and the back shows the steps.
class ExerciseCard extends StatelessWidget {
  final PlanExercise exercise;

  // The info holds the GIF and steps, and is null if the name is not in the list.
  final ExerciseInfo? info;

  // This is true when the step-by-step instructions are showing.
  final bool showSteps;
  final VoidCallback onToggleSteps;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.info,
    required this.showSteps,
    required this.onToggleSteps,
  });

  // This tile is shown when an exercise has no GIF or the GIF cannot load.
  Widget _fallbackTile() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightBlue, AppColors.mint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.fitness_center, size: 64, color: AppColors.white),
      ),
    );
  }

  // This method builds the GIF with its required credit line underneath.
  Widget _buildPicture(BuildContext context) {
    final gif = info?.gif;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 180,
            height: 180,
            child: gif == null
                ? _fallbackTile()
                : Image.asset(
                    gif,
                    fit: BoxFit.cover,
                    semanticLabel: '${exercise.name} animation',
                    // A missing or broken file shows the fallback tile instead.
                    errorBuilder: (context, error, stack) => _fallbackTile(),
                  ),
          ),
        ),
        if (gif != null) ...[
          const SizedBox(height: 4),
          Text(
            '© Gym visual — https://gymvisual.com/',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  // This method builds the numbered instruction steps for the back of the card.
  Widget _buildSteps(BuildContext context) {
    final steps = info?.steps ?? [];
    if (steps.isEmpty) {
      return const Text('No instructions are available for this exercise.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('${i + 1}. ${steps[i]}'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (showSteps)
                _buildSteps(context)
              else ...[
                _buildPicture(context),
                const SizedBox(height: 16),
                Text(
                  exercise.name,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(exercise.difficulty, style: textTheme.bodyMedium),
                const SizedBox(height: 12),
                Text(
                  exercise.targetLabel,
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onToggleSteps,
                icon: Icon(showSteps ? Icons.image : Icons.menu_book),
                label: Text(showSteps ? 'Back to exercise' : 'How to'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
