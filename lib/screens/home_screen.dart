import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/workout_plan.dart';
import '../widgets/plan_card.dart';
import '../widgets/stats_strip.dart';

// This screen shows the stats strip and the pre-built plans.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WorkoutPlan> _plans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  // This method reads the pre-built plans from the database.
  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans = await DatabaseHelper.instance.getPrebuiltPlans();
      // The screen may have closed while the database was busy.
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load plans. Please try again.';
        _loading = false;
      });
    }
  }

  // This method runs when a plan card is tapped.
  void _openPlan(WorkoutPlan plan) {
    // The workout player is added in a later step, so a message is shown for now.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${plan.title} will open the workout player.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loadPlans, child: const Text('Retry')),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // The real numbers are connected when History is built.
        const StatsStrip(sessionsThisWeek: 0, totalReps: 0),
        Text(
          'Pre-built plans',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        for (final plan in _plans)
          PlanCard(plan: plan, onTap: () => _openPlan(plan)),
      ],
    );
  }
}
