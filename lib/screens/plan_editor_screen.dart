import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../logic/plan_rules.dart';
import '../models/exercise_info.dart';
import '../models/plan_exercise.dart';
import '../models/workout_plan.dart';
import '../widgets/exercise_picker_sheet.dart';

// This screen is the form for making a new plan or editing an existing one.
// It closes with "saved" or "deleted" so the list knows what happened.
class PlanEditorScreen extends StatefulWidget {
  // The plan is null when making a new plan and filled in when editing.
  final WorkoutPlan? plan;

  const PlanEditorScreen({super.key, this.plan});

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

  // This getter is true when the screen was opened to edit a plan.
  bool get _isEditing => widget.plan != null;

  // The form starts with the plan's values when editing.
  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    if (plan != null) {
      _titleController.text = plan.title;
      _descriptionController.text = plan.description;
      _focusArea = plan.focusArea;
      _exercises.addAll(plan.exercises);
    }
  }

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
    final original = widget.plan;

    // A new plan has changes as soon as anything is filled in.
    if (original == null) {
      return _titleController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _focusArea != null ||
          _exercises.isNotEmpty;
    }

    // An edited plan has changes when any value is different from the saved one.
    return _titleController.text.trim() != original.title ||
        _descriptionController.text.trim() != original.description ||
        _focusArea != original.focusArea ||
        _exerciseText(_exercises) != _exerciseText(original.exercises);
  }

  // This method turns an exercise list into text so two lists are easy to compare.
  String _exerciseText(List<PlanExercise> list) {
    return list.map((e) => '${e.name}|${e.difficulty}').join(',');
  }

  // This method asks before deleting and warns how many logged sets go too.
  Future<void> _onDelete() async {
    final plan = widget.plan!;
    final int setCount;
    try {
      setCount = await DatabaseHelper.instance.countLogsForPlan(plan.id!);
    } catch (e) {
      if (!mounted) return;
      _showError('Could not check this plan. Please try again.');
      return;
    }
    if (!mounted) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${plan.title}"?'),
        content: Text(
          setCount == 0
              ? 'This plan has no logged sets.'
              : 'This also deletes $setCount logged '
                    '${setCount == 1 ? 'set' : 'sets'} from History.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _saving = true;
    });
    try {
      await DatabaseHelper.instance.deletePlan(plan.id!);
      if (!mounted) return;
      Navigator.of(context).pop('deleted');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      _showError('Could not delete the plan. Please try again.');
    }
  }

  // This method shows an error message at the bottom of the screen.
  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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

    // An edited plan keeps its id and creation date so it updates the same row.
    final plan = WorkoutPlan(
      id: widget.plan?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      focusArea: _focusArea!,
      exercises: List.of(_exercises),
      estMinutes: PlanRules.estimateMinutes(
        _exercises,
        PlanRules.defaultRestSeconds,
      ),
      isPrebuilt: false,
      createdAt: widget.plan?.createdAt ?? DateTime.now(),
    );

    setState(() {
      _saving = true;
    });
    try {
      if (_isEditing) {
        await DatabaseHelper.instance.updatePlan(plan);
      } else {
        await DatabaseHelper.instance.insertPlan(plan);
      }
      if (!mounted) return;
      // Returning "saved" tells the Personal Plans screen to reload its list.
      Navigator.of(context).pop('saved');
    } catch (e) {
      if (!mounted) return;
      // The form keeps everything the user typed so they can try again.
      setState(() {
        _saving = false;
      });
      _showError('Could not save the plan. Please try again.');
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
      appBar: AppBar(title: Text(_isEditing ? 'Edit Plan' : 'New Plan')),
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
            // The Delete Plan button only appears when editing a saved plan.
            if (_isEditing) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _saving ? null : _onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Plan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
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
