import 'package:flutter/material.dart';

// This reusable control shows a number with minus and plus buttons around it.
// The user sets how many reps they really did.
class RepStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const RepStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 500,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // A button is turned off when the value is already at its limit.
            IconButton.filledTonal(
              iconSize: 32,
              tooltip: 'One less rep',
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 100,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                semanticsLabel: '$value reps',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton.filledTonal(
              iconSize: 32,
              tooltip: 'One more rep',
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        Text('reps done', style: textTheme.bodyMedium),
      ],
    );
  }
}
