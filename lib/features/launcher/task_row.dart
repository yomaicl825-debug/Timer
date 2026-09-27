import 'package:flutter/material.dart';

import '../../domain/records/task.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.task,
    required this.duration,
    required this.onTap,
  });
  final TaskRecord task;
  final Duration duration;
  final VoidCallback onTap;

  static String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(task.name),
    trailing: Text(
      formatDuration(duration),
      style: Theme.of(context).textTheme.titleMedium,
    ),
    onTap: onTap,
  );
}
