import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../logic/plan_rules.dart';
import '../models/exercise_info.dart';
import '../models/plan_exercise.dart';
import '../models/workout_plan.dart';
import '../widgets/exercise_picker_sheet.dart';

// This screen is the form for making a new workout plan.
class PlanEditorScreen extends StatefulWidget {
  const PlanEditorScreen({super.key});

  @override
  State<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends State<PlanEditorScreen> {
  // The form key lets the Done button check every field at once.
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _focusArea;

  // These are the exercises added to the plan, shown in the Types section.
  final List<PlanExercise> _exercises = [];

  // This becomes true when Done is pressed with no exercises added.
  bool _showExerciseError = false;

  // This is true while the plan is being written to the database.
  bool _saving = false;

  // Controllers hold memory, so they are cleaned up when the screen closes.
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // This method checks that the name is not blank and not too long.
  String? _validateTitle(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Please enter a plan name.';
    if (text.length > PlanRules.maxTitleLength) {
      return 'Use ${PlanRules.maxTitleLength} characters or fewer.';
    }
    return null;
  }

  // This method checks that a focus area was chosen.
  String? _validateFocus(String? value) {
    if (value == null) return 'Please choose a focus area.';
    return null;
  }

  // This method opens the exercise list, then asks for a difficulty.
  Future<void> _addExercise() async {
    final ExerciseInfo? picked = await showModalBottomSheet<ExerciseInfo>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ExercisePickerSheet(),
    );
    // Nothing is added if the sheet was closed without a choice.
    if (picked == null || !mounted) return;

    final String? difficulty = await _askDifficulty(picked);
    if (difficulty == null || !mounted) return;

    setState(() {
      _exercises.add(
        PlanExercise(
          name: picked.name,
          difficulty: difficulty,
          type: picked.type,
          target: PlanRules.targetFor(difficulty, picked.type),
        ),
      );
      _showExerciseError = false;
    });
  }

  // This method shows the Easy, Medium, and Difficult choices with their targets.
  Future<String?> _askDifficulty(ExerciseInfo exercise) {
    final unit = exercise.type == 'timed' ? 'sec' : 'reps';
    return showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(exercise.name),
        children: [
          for (final level in ['Easy', 'Medium', 'Difficult'])
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(level),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Text(
                '$level · ${PlanRules.targetFor(level, exercise.type)} $unit',
              ),
            ),
        ],
      ),
    );
  }

  // This method removes one exercise from the Types list.
  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  // This method builds the Types section with its rows and the add button.
  Widget _buildTypesSection() {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('Types', style: textTheme.titleMedium),
            ),
            for (int i = 0; i < _exercises.length; i++)
              ListTile(
                title: Text(
                  '${_exercises[i].name} (${_exercises[i].difficulty})',
                ),
                subtitle: Text(_exercises[i].targetLabel),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Remove ${_exercises[i].name}',
                  onPressed: () => _removeExercise(i),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add exercise'),
              onTap: _addExercise,
            ),
            if (_showExerciseError)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Please add at least one exercise.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // This getter is true when the user has typed or picked anything.
  bool get _hasChanges {
    return _titleController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty ||
        _focusArea != null ||
        _exercises.isNotEmpty;
  }

  // This method runs for the Cancel button and the phone's back button.
  Future<void> _onCancel() async {
    // An empty form can close right away because nothing would be lost.
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard this plan?'),
        content: const Text('Your changes will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  // This method runs when Done is pressed.
  Future<void> _onDone() async {
    // A second tap is ignored while the first save is still running.
    if (_saving) return;

    // The form shows red error text under any field that is not valid.
    final fieldsValid = _formKey.currentState!.validate();
    setState(() {
      _showExerciseError = _exercises.isEmpty;
    });
    if (!fieldsValid || _exercises.isEmpty) return;

    final plan = WorkoutPlan(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      focusArea: _focusArea!,
      exercises: List.of(_exercises),
      estMinutes: PlanRules.estimateMinutes(
        _exercises,
        PlanRules.defaultRestSeconds,
      ),
      isPrebuilt: false,
      createdAt: DateTime.now(),
    );

    setState(() {
      _saving = true;
    });
    try {
      await DatabaseHelper.instance.insertPlan(plan);
      if (!mounted) return;
      // Returning true tells the Personal Plans screen to reload its list.
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      // The form keeps everything the user typed so they can try again.
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the plan. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope stops the back button from closing the form without asking.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onCancel();
      },
      child: _buildScaffold(context),
    );
  }

  // This method builds the form, the Types section, and the bottom buttons.
  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Plan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              maxLength: PlanRules.maxTitleLength,
              textCapitalization: TextCapitalization.sentences,
              validator: _validateTitle,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLength: PlanRules.maxDescriptionLength,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _focusArea,
              decoration: const InputDecoration(
                labelText: 'Focus area',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final area in PlanRules.focusAreas)
                  DropdownMenuItem(value: area, child: Text(area)),
              ],
              onChanged: (value) {
                setState(() {
                  _focusArea = value;
                });
              },
              validator: _validateFocus,
            ),
            const SizedBox(height: 16),
            _buildTypesSection(),
          ],
        ),
      ),
      // The bottom bar matches the Cancel and Done boxes in the wireframe.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : _onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // The button is turned off and shows a spinner while saving.
                child: FilledButton(
                  onPressed: _saving ? null : _onDone,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
