import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/workout_session.dart';

// This reusable card shows one workout session in the History list.
class SessionCard extends StatelessWidget {
  final WorkoutSession session;

  // This runs when the pen icon is pressed.
  final VoidCallback onEdit;

  const SessionCard({super.key, required this.session, required this.onEdit});

  // This method writes a date and time such as "Oct 30, 2026 at 5:42 PM".
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} '
        'at $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final setCount = session.sets.length;
    final setWord = setCount == 1 ? 'set' : 'sets';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.planTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(session.startedAt),
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$setCount $setWord · ${session.durationMinutes} min',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  // The chip shows the status as a word, not only a color.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: session.finished
                          ? AppColors.mint
                          : AppColors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      session.finished ? 'Finished' : 'Not finished',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit ${session.planTitle} session',
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
