import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/workout_plan.dart';
import '../models/workout_stats.dart';
import '../widgets/plan_card.dart';
import '../widgets/stats_strip.dart';
import 'workout_player_screen.dart';

// This screen shows the stats strip and the pre-built plans.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WorkoutPlan> _plans = [];
  WorkoutStats _stats = const WorkoutStats(sessionsThisWeek: 0, totalReps: 0);
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  // This method reads the pre-built plans and the stats from the database.
  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans = await DatabaseHelper.instance.getPrebuiltPlans();
      final stats = await DatabaseHelper.instance.getStats();
      // The screen may have closed while the database was busy.
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _stats = stats;
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

  // This method saves an editable copy of a pre-built plan to Personal Plans.
  // The pre-built plan itself can never be edited or deleted.
  Future<void> _copyToMyPlans(WorkoutPlan plan) async {
    final copy = WorkoutPlan(
      title: '${plan.title} (copy)',
      description: plan.description,
      focusArea: plan.focusArea,
      exercises: List.of(plan.exercises),
      estMinutes: plan.estMinutes,
      isPrebuilt: false,
      createdAt: DateTime.now(),
    );
    try {
      await DatabaseHelper.instance.insertPlan(copy);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Copied to My Plans.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not copy the plan. Please try again.'),
        ),
      );
    }
  }

  // This method opens the workout player and refreshes the stats afterward.
  Future<void> _openPlan(WorkoutPlan plan) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => WorkoutPlayerScreen(plan: plan)),
    );
    if (mounted) await _loadPlans();
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
        StatsStrip(
          sessionsThisWeek: _stats.sessionsThisWeek,
          totalReps: _stats.totalReps,
        ),
        Text('Pre-built plans', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final plan in _plans)
          PlanCard(
            plan: plan,
            onTap: () => _openPlan(plan),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy ${plan.title} to My Plans',
              onPressed: () => _copyToMyPlans(plan),
            ),
          ),
      ],
    );
  }
}
