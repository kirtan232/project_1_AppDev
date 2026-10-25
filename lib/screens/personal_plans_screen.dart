import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/workout_plan.dart';
import '../widgets/plan_card.dart';
import 'plan_editor_screen.dart';

// This screen lists the user's own plans and has a button to make a new one.
class PersonalPlansScreen extends StatefulWidget {
  const PersonalPlansScreen({super.key});

  @override
  State<PersonalPlansScreen> createState() => _PersonalPlansScreenState();
}

class _PersonalPlansScreenState extends State<PersonalPlansScreen> {
  List<WorkoutPlan> _plans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  // This method reads the user's own plans from the database.
  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans = await DatabaseHelper.instance.getPersonalPlans();
      // The screen may have closed while the database was busy.
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your plans. Please try again.';
        _loading = false;
      });
    }
  }

  // This method shows a short message at the bottom of the screen.
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // This method opens the form for a new plan, or for editing when a plan is given.
  // The list reloads after the form reports that it saved or deleted.
  Future<void> _openEditor([WorkoutPlan? plan]) async {
    final String? result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => PlanEditorScreen(plan: plan)),
    );
    if (!mounted) return;
    if (result == 'saved') {
      _showMessage('Plan saved.');
      await _loadPlans();
    } else if (result == 'deleted') {
      _showMessage('Plan deleted.');
      await _loadPlans();
    }
  }

  // This method builds the middle of the screen based on the current state.
  Widget _buildList() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loadPlans, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_plans.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Text(
          'No plans yet. Tap + New Plan to build your first workout.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        for (final plan in _plans)
          PlanCard(
            plan: plan,
            // The workout player is connected in a later step.
            onTap: () => _showMessage('${plan.title} will open the player.'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit ${plan.title}',
              onPressed: () => _openEditor(plan),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // This large button matches the "+ New Plan" box in the wireframe.
        FilledButton.icon(
          onPressed: () => _openEditor(),
          icon: const Icon(Icons.add),
          label: const Text('New Plan'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        ),
        const SizedBox(height: 20),
        _buildList(),
      ],
    );
  }
}
