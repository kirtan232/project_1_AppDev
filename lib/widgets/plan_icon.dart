import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/workout_plan.dart';

// This round icon flies from a plan card to the workout player.
// Both screens use the same Hero tag, which is how Flutter connects them.
class PlanIcon extends StatelessWidget {
  final WorkoutPlan plan;
  final double size;

  const PlanIcon({super.key, required this.plan, required this.size});

  @override
  Widget build(BuildContext context) {
    // HeroMode turns the flight off when the phone asks for less motion.
    return HeroMode(
      enabled: !MediaQuery.disableAnimationsOf(context),
      child: Hero(
        tag: 'plan-icon-${plan.id}',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.coral.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.fitness_center,
            size: size * 0.45,
            color: AppColors.coral,
          ),
        ),
      ),
    );
  }
}
