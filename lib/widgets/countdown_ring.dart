import 'package:flutter/material.dart';

// This reusable ring shows how many seconds are left in a timed exercise.
// The ring empties as the time runs out, and the number is shown in the middle.
class CountdownRing extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;

  const CountdownRing({
    super.key,
    required this.secondsLeft,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = totalSeconds == 0 ? 0.0 : secondsLeft / totalSeconds;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: '$secondsLeft seconds left',
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The ring glides between seconds unless the phone asks for less motion.
            SizedBox.expand(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: fraction),
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(seconds: 1),
                builder: (context, value, child) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  );
                },
              ),
            ),
            // ExcludeSemantics stops the number being read twice.
            ExcludeSemantics(
              child: Text(
                '$secondsLeft',
                style: Theme.of(context).textTheme.displaySmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
