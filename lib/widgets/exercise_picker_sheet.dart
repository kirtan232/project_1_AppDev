import 'package:flutter/material.dart';

import '../data/exercise_library.dart';
import '../models/exercise_info.dart';

// This bottom sheet lists the bundled exercises and lets the user search them.
// It closes and returns the exercise that was tapped.
class ExercisePickerSheet extends StatefulWidget {
  const ExercisePickerSheet({super.key});

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only exercises whose name contains the search text are shown.
    final List<ExerciseInfo> results = ExerciseLibrary.all
        .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return SafeArea(
      child: SizedBox(
        // The sheet fills most of the screen so the list has room to scroll.
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search exercises',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value.trim();
                  });
                },
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No exercises match your search.'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final exercise = results[index];
                        return ListTile(
                          title: Text(exercise.name),
                          subtitle: Text(
                            '${exercise.focusArea} · '
                            '${exercise.type == 'timed' ? 'Timed' : 'Reps'}',
                          ),
                          onTap: () => Navigator.of(context).pop(exercise),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
