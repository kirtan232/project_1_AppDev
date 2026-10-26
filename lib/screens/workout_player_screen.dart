import 'package:flutter/material.dart';

import '../data/exercise_library.dart';
import '../models/workout_plan.dart';
import '../widgets/exercise_card.dart';

// This screen plays a plan as flashcards, with one card per exercise.
// The user can swipe between cards or use the Next and Skip buttons.
class WorkoutPlayerScreen extends StatefulWidget {
  final WorkoutPlan plan;

  const WorkoutPlayerScreen({super.key, required this.plan});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  // The page controller moves the cards when a button is pressed.
  final _pageController = PageController();

  // This is the position of the card on screen, starting at zero.
  int _index = 0;

  // This is true when the current card is showing its instructions.
  bool _showSteps = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // This getter is true when the last card is on screen.
  bool get _isLastCard => _index == widget.plan.exercises.length - 1;

  // This method moves to the next card, or closes the player after the last one.
  void _goToNext() {
    if (_isLastCard) {
      // The completion screen is added in a later step.
      Navigator.of(context).pop();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.plan.exercises;
    final total = exercises.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.plan.title)),
      body: SafeArea(
        child: Column(
          children: [
            // The progress bar and the text both show how far the user is.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  Text('Card ${_index + 1} of $total'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_index + 1) / total,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    semanticsLabel: 'Workout progress',
                    semanticsValue: 'Card ${_index + 1} of $total',
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: total,
                // Swiping to a new card updates the counter and hides the steps.
                onPageChanged: (page) {
                  setState(() {
                    _index = page;
                    _showSteps = false;
                  });
                },
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ExerciseCard(
                      exercise: exercises[i],
                      info: ExerciseLibrary.findByName(exercises[i].name),
                      showSteps: i == _index && _showSteps,
                      onToggleSteps: () {
                        setState(() {
                          _showSteps = !_showSteps;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            // The buttons give the same moves as swiping, for anyone who cannot swipe.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToNext,
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _goToNext,
                      child: Text(_isLastCard ? 'Finish' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
