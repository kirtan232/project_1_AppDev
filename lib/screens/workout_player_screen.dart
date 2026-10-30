import 'dart:async';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/database_helper.dart';
import '../data/exercise_library.dart';
import '../logic/app_settings.dart';
import '../logic/workout_feedback.dart';
import '../models/plan_exercise.dart';
import '../models/training_log.dart';
import '../models/workout_plan.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/exercise_card.dart';
import '../widgets/plan_icon.dart';
import '../widgets/rep_stepper.dart';
import '../widgets/rest_card.dart';
import 'workout_complete_screen.dart';

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

  // These are used for the totals on the completion screen.
  late final DateTime _startTime;
  int _totalReps = 0;

  // These track the rest countdown between exercises.
  Timer? _restTimer;
  bool _resting = false;
  int _restLeft = 0;
  int _restTotal = 0;

  @override
  void initState() {
    super.initState();
    // The plan id and the start time together make the key unique.
    _startTime = DateTime.now();
    _sessionKey = '${widget.plan.id}-${_startTime.millisecondsSinceEpoch}';
    _resetForCard(0);
  }

  // The timers are stopped here so they never keep running after the screen closes.
  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
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
            WorkoutFeedback.play();
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
        // Timed sets are in seconds, so only rep sets add to the rep total.
        if (log.unit == 'reps') _totalReps += log.amount;
        _saving = false;
      });
      // A rest comes between exercises, but not after the last one.
      if (_isLastCard) {
        _goToNext();
      } else {
        _startRest();
      }
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

  // This method starts the rest countdown using the time from Settings.
  void _startRest() {
    setState(() {
      _resting = true;
      _restTotal = AppSettings.instance.restSeconds;
      _restLeft = _restTotal;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // The check stops a late tick from updating a closed screen.
      if (!mounted) return;
      if (_restLeft <= 1) {
        WorkoutFeedback.play();
        _endRest();
        return;
      }
      setState(() {
        _restLeft--;
      });
    });
  }

  // This method ends the rest, either at zero or from the Skip Rest button.
  void _endRest() {
    _restTimer?.cancel();
    setState(() {
      _resting = false;
    });
    _goToNext();
  }

  // This method shows a short message at the bottom of the screen.
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // This method marks the session finished and opens the completion screen.
  Future<void> _finishWorkout() async {
    // A workout with no saved sets is not a session, so nothing is recorded.
    if (_loggedCards.isEmpty) {
      _showMessage('No sets were saved, so nothing was recorded.');
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _saving = true;
    });
    try {
      await DatabaseHelper.instance.finishSession(_sessionKey);
      if (!mounted) return;

      final minutes = DateTime.now().difference(_startTime).inMinutes;
      // The completion screen replaces the player, so back does not reopen it.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WorkoutCompleteScreen(
            exerciseCount: _loggedCards.length,
            totalReps: _totalReps,
            // A very short workout still shows as one minute.
            minutes: minutes < 1 ? 1 : minutes,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      _showMessage('Could not finish the workout. Please try again.');
    }
  }

  // This method runs for the phone's back button and the top back arrow.
  Future<void> _onQuit() async {
    if (_saving) return;

    // Nothing has been saved yet, so there is nothing to ask about.
    if (_loggedCards.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final String? choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit this workout?'),
        content: Text(
          'You have saved ${_loggedCards.length} '
          '${_loggedCards.length == 1 ? 'set' : 'sets'} so far.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('keep'),
            child: const Text('Keep Going'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('discard'),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: const Text('Save as Not Finished'),
          ),
        ],
      ),
    );
    if (!mounted) return;

    if (choice == 'save') {
      // The sets are already saved as not finished, so the player can just close.
      _showMessage('Saved as Not Finished.');
      Navigator.of(context).pop();
    } else if (choice == 'discard') {
      await _discardSession();
    }
  }

  // This method deletes the sets saved in this workout and closes the player.
  Future<void> _discardSession() async {
    setState(() {
      _saving = true;
    });
    try {
      await DatabaseHelper.instance.deleteSession(_sessionKey);
      if (!mounted) return;
      _showMessage('Workout discarded.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      _showMessage('Could not discard the workout. Please try again.');
    }
  }

  // This method moves to the next card, or finishes after the last one.
  void _goToNext() {
    if (_isLastCard) {
      _finishWorkout();
      return;
    }
    // The card changes at once when the phone asks for less motion.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(_index + 1);
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
    // PopScope stops the back button from leaving without asking.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onQuit();
      },
      child: _buildScaffold(context),
    );
  }

  // This method builds the progress bar, the cards, and the buttons.
  Widget _buildScaffold(BuildContext context) {
    final total = widget.plan.exercises.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.plan.title)),
      body: SafeArea(
        child: Column(
          children: [
            // The progress bar and the text both show how far the user is.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  // This is where the icon from the plan card lands.
                  PlanIcon(plan: widget.plan, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
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
                ],
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // The cards stay underneath so their place is kept during a rest.
                  ExcludeSemantics(excluding: _resting, child: _buildCards()),
                  if (_resting) _buildRestOverlay(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _resting ? _buildSkipRestButton() : _buildCardButtons(),
            ),
          ],
        ),
      ),
    );
  }

  // This method builds the swipeable cards, one for each exercise.
  Widget _buildCards() {
    final exercises = widget.plan.exercises;
    return PageView.builder(
      controller: _pageController,
      itemCount: exercises.length,
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
    );
  }

  // This method covers the cards with the rest countdown.
  Widget _buildRestOverlay() {
    return Positioned.fill(
      // AbsorbPointer stops touches from reaching the cards underneath.
      child: AbsorbPointer(
        child: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: RestCard(
            secondsLeft: _restLeft,
            totalSeconds: _restTotal,
            nextExerciseName: widget.plan.exercises[_index + 1].name,
          ),
        ),
      ),
    );
  }

  // This method builds the one button shown during a rest.
  Widget _buildSkipRestButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(onPressed: _endRest, child: const Text('Skip Rest')),
    );
  }

  // These buttons give the same moves as swiping, for anyone who cannot swipe.
  Widget _buildCardButtons() {
    return Row(
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
    );
  }
}
