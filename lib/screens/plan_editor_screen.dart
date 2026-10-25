import 'package:flutter/material.dart';

import '../logic/plan_rules.dart';
import '../models/exercise_info.dart';
import '../models/plan_exercise.dart';
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

  // This method runs when Done is pressed.
  void _onDone() {
    // The form shows red error text under any field that is not valid.
    final fieldsValid = _formKey.currentState!.validate();
    setState(() {
      _showExerciseError = _exercises.isEmpty;
    });
    if (!fieldsValid || _exercises.isEmpty) return;

    // Saving to the database is added in a later step.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('The form is valid.')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _onDone,
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
