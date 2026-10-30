import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/workout_session.dart';
import '../widgets/session_card.dart';
import '../widgets/session_edit_sheet.dart';

// This screen lists past workouts, with the newest first.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<WorkoutSession> _sessions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  // This method reads the saved sets and groups them into sessions.
  Future<void> _loadSessions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sessions = await DatabaseHelper.instance.getSessions();
      // The screen may have closed while the database was busy.
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your history. Please try again.';
        _loading = false;
      });
    }
  }

  // This method opens the edit sheet and reloads the list when it closes.
  Future<void> _editSession(WorkoutSession session) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SessionEditSheet(session: session),
    );
    if (mounted) await _loadSessions();
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
            FilledButton(onPressed: _loadSessions, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_sessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No workouts yet. Start one from Home.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // ListView.builder only builds the cards that are on screen.
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return SessionCard(
          session: session,
          onEdit: () => _editSession(session),
        );
      },
    );
  }
}
