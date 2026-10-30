import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/exercise_info.dart';
import '../models/training_log.dart';
import '../models/workout_session.dart';
import 'amount_dialog.dart';
import 'exercise_picker_sheet.dart';

// This bottom sheet corrects a saved session.
// The user can change an amount, add a missed set, or delete sets or the session.
class SessionEditSheet extends StatefulWidget {
  final WorkoutSession session;

  const SessionEditSheet({super.key, required this.session});

  @override
  State<SessionEditSheet> createState() => _SessionEditSheetState();
}

class _SessionEditSheetState extends State<SessionEditSheet> {
  late List<TrainingLog> _sets;

  // This is true while a change is being written to the database.
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sets = widget.session.sets;
  }

  // This method runs one database change and then reloads the sets.
  // The error is shown in the sheet because a snackbar would sit behind it.
  Future<void> _change(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      final sets = await DatabaseHelper.instance.getLogsForSession(
        widget.session.sessionKey,
      );
      if (!mounted) return;
      // Removing the last set removes the session, so the sheet closes.
      if (sets.isEmpty) {
        Navigator.of(context).pop();
        return;
      }
      setState(() {
        _sets = sets;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not save the change. Please try again.';
      });
    }
  }

  // This method asks the user to confirm before something is deleted.
  Future<bool> _confirm(String title, String message) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
    return confirmed == true;
  }

  // This method corrects the amount on one set.
  Future<void> _editSet(TrainingLog set) async {
    final int? amount = await showDialog<int>(
      context: context,
      builder: (context) => AmountDialog(
        title: set.exerciseLabel,
        unit: set.unit,
        initialAmount: set.amount,
      ),
    );
    if (amount == null || !mounted) return;
    await _change(
      () => DatabaseHelper.instance.updateLogAmount(set.id!, amount),
    );
  }

  // This method deletes one set after asking first.
  Future<void> _deleteSet(TrainingLog set) async {
    final confirmed = await _confirm(
      'Delete this set?',
      '${set.exerciseLabel}, ${set.amount} ${set.unit}',
    );
    if (!confirmed || !mounted) return;
    await _change(() => DatabaseHelper.instance.deleteLog(set.id!));
  }

  // This method adds a set the user forgot to log during the workout.
  Future<void> _addSet() async {
    final ExerciseInfo? picked = await showModalBottomSheet<ExerciseInfo>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ExercisePickerSheet(),
    );
    if (picked == null || !mounted) return;

    final unit = picked.type == 'timed' ? 'sec' : 'reps';
    final int? amount = await showDialog<int>(
      context: context,
      builder: (context) => AmountDialog(title: picked.name, unit: unit),
    );
    if (amount == null || !mounted) return;

    // The new set copies the session's time so its date and length do not change.
    final log = TrainingLog(
      workoutId: widget.session.workoutId,
      sessionKey: widget.session.sessionKey,
      exerciseLabel: picked.name,
      amount: amount,
      unit: unit,
      loggedAt: _sets.last.loggedAt,
      sessionFinished: widget.session.finished,
    );
    await _change(() => DatabaseHelper.instance.insertLog(log));
  }

  // This method deletes every set in the session after asking first.
  Future<void> _deleteSession() async {
    final confirmed = await _confirm(
      'Delete this session?',
      'This deletes all ${_sets.length} saved sets.',
    );
    if (!confirmed || !mounted) return;
    await _change(
      () => DatabaseHelper.instance.deleteSession(widget.session.sessionKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.session.planTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _sets.length,
                  itemBuilder: (context, index) {
                    final set = _sets[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(set.exerciseLabel),
                      subtitle: Text('${set.amount} ${set.unit}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Change ${set.exerciseLabel}',
                            onPressed: _busy ? null : () => _editSet(set),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete ${set.exerciseLabel}',
                            onPressed: _busy ? null : () => _deleteSet(set),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              FilledButton.icon(
                onPressed: _busy ? null : _addSet,
                icon: const Icon(Icons.add),
                label: const Text('Add missed set'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _busy ? null : _deleteSession,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete session'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
