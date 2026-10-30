import 'dart:async';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/database_helper.dart';
import '../data/exercise_library.dart';
import '../models/plan_exercise.dart';
import '../models/training_log.dart';
import '../models/workout_plan.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/exercise_card.dart';
import '../widgets/rep_stepper.dart';

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

  // This is how many reps the user says they did on the current card.
  int _repsDone = 0;

  // These track the countdown for a timed card.
  Timer? _timer;
  int _secondsLeft = 0;

  // Every set in this workout shares this key, so they count as one session.
  late final String _sessionKey;

  // These are the cards already saved, so a card can never be logged twice.
  final Set<int> _loggedCards = {};

  // This is true while a set is being written to the database.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // The plan id and the start time together make the key unique.
    final startTime = DateTime.now().millisecondsSinceEpoch;
    _sessionKey = '${widget.plan.id}-$startTime';
    _resetForCard(0);
  }

  // The timer is stopped here so it never keeps running after the screen closes.
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // This getter returns the exercise on the card that is showing.
  PlanExercise get _current => widget.plan.exercises[_index];

  // This getter is true when the last card is on screen.
  bool get _isLastCard => _index == widget.plan.exercises.length - 1;

  // This getter is true while the countdown is running.
  bool get _timerRunning => _timer?.isActive ?? false;

  // This method stops any timer and sets the values for a new card.
  // It does not call setState, so callers wrap it when the screen must redraw.
  void _resetForCard(int index) {
    _timer?.cancel();
    _timer = null;
    final exercise = widget.plan.exercises[index];
    _repsDone = exercise.target;
    _secondsLeft = exercise.target;
  }

  // This method starts the countdown, or pauses it if it is already running.
  void _toggleTimer() {
    if (_timerRunning) {
      setState(() {
        _timer?.cancel();
      });
      return;
    }
    // A finished timer starts again from the full time.
    if (_secondsLeft == 0) _secondsLeft = _current.target;

    setState(() {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // The check stops a late tick from updating a closed screen.
        if (!mounted) return;
        setState(() {
          _secondsLeft--;
          if (_secondsLeft <= 0) {
            _secondsLeft = 0;
            timer.cancel();
          }
        });
      });
    });
  }

  // This method returns the amount to save for the card on screen.
  int _amountToLog() {
    if (_current.type != 'timed') return _repsDone;

    // A timed card saves the seconds that passed on the countdown.
    final secondsDone = _current.target - _secondsLeft;

    // If the timer was never used, the user is trusted to have done the full time.
    return secondsDone > 0 ? secondsDone : _current.target;
  }

  // This method saves the current card as a set and then moves on.
  Future<void> _onDone() async {
    // A second tap is ignored while the first save is still running.
    if (_saving) return;

    // A card that is already saved just moves on, so no duplicate row is made.
    if (_loggedCards.contains(_index)) {
      _goToNext();
      return;
    }

    final int cardIndex = _index;
    final log = TrainingLog(
      workoutId: widget.plan.id!,
      sessionKey: _sessionKey,
      exerciseLabel: _current.name,
      amount: _amountToLog(),
      unit: _current.unit,
      loggedAt: DateTime.now(),
      sessionFinished: false,
    );

    _timer?.cancel();
    setState(() {
      _saving = true;
    });
    try {
      await DatabaseHelper.instance.insertLog(log);
      if (!mounted) return;
      setState(() {
        _loggedCards.add(cardIndex);
        _saving = false;
      });
      _goToNext();
    } catch (e) {
      if (!mounted) return;
      // The card stays on screen so the user can press Done again.
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this set. Please try again.'),
        ),
      );
    }
  }

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

  // This method picks the main button text based on whether the card is saved.
  String _doneButtonLabel() {
    if (!_loggedCards.contains(_index)) return 'Done';
    return _isLastCard ? 'Finish' : 'Next';
  }

  // This method picks the timer button text for each state of the countdown.
  String _timerButtonLabel() {
    if (_timerRunning) return 'Pause';
    if (_secondsLeft == _current.target) return 'Start';
    if (_secondsLeft == 0) return 'Restart';
    return 'Resume';
  }

  // This method builds the stepper for rep cards or the ring for timed cards.
  Widget _buildControl() {
    // A saved card shows a word instead of controls, so it cannot be logged again.
    if (_loggedCards.contains(_index)) {
      return const Column(
        children: [
          Icon(Icons.check_circle, size: 48, color: AppColors.mint),
          SizedBox(height: 8),
          Text('Set saved'),
        ],
      );
    }

    if (_current.type != 'timed') {
      return RepStepper(
        value: _repsDone,
        onChanged: (value) {
          setState(() {
            _repsDone = value;
          });
        },
      );
    }

    return Column(
      children: [
        CountdownRing(secondsLeft: _secondsLeft, totalSeconds: _current.target),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: _toggleTimer,
          icon: Icon(_timerRunning ? Icons.pause : Icons.play_arrow),
          label: Text(_timerButtonLabel()),
        ),
      ],
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
                // Swiping is turned off during a save so the card cannot change.
                physics: _saving ? const NeverScrollableScrollPhysics() : null,
                // A new card stops the old timer and starts from its own target.
                onPageChanged: (page) {
                  setState(() {
                    _index = page;
                    _showSteps = false;
                    _resetForCard(page);
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
                      // Only the card on screen gets the working controls.
                      control: i == _index ? _buildControl() : null,
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
                    // Skip moves on without saving a set.
                    child: OutlinedButton(
                      onPressed: _saving ? null : _goToNext,
                      child: const Text('Skip'),
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
                          : Text(_doneButtonLabel()),
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
