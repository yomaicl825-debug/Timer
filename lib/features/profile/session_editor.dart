import 'package:flutter/material.dart';

import '../../app.dart';
import '../../domain/records/session.dart';
import '../launcher/task_row.dart';

Future<void> showSessionEditor(
  BuildContext context,
  AppServices services,
  FocusSession session,
) async {
  String? selectedTask = session.taskId;
  final duration = session.creditedDuration;
  String durationText = TaskRow.formatDuration(duration);
  String? error;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, update) => AlertDialog(
        title: const Text('编辑记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String?>(
              initialValue: selectedTask,
              decoration: const InputDecoration(labelText: '任务'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('未归类'),
                ),
                for (final task in services.tasks)
                  DropdownMenuItem<String?>(
                    value: task.id,
                    child: Text(task.name),
                  ),
              ],
              onChanged: (value) => update(() => selectedTask = value),
            ),
            TextFormField(
              initialValue: durationText,
              onChanged: (value) => durationText = value,
              decoration: InputDecoration(
                labelText: '计入时长 HH:MM:SS',
                errorText: error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await services.updateSession(
                session.copyWith(
                  deletedAt: services.clock().toUtc(),
                  revision: session.revision + 1,
                ),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('删除记录'),
          ),
          FilledButton(
            onPressed: () async {
              final parts = durationText.trim().split(':');
              final values = parts.map(int.tryParse).toList();
              if (parts.length != 3 ||
                  values.any((v) => v == null) ||
                  values[0]! < 0 ||
                  values[1]! < 0 ||
                  values[1]! > 59 ||
                  values[2]! < 0 ||
                  values[2]! > 59) {
                update(() => error = '请输入 HH:MM:SS');
                return;
              }
              final credited = Duration(
                hours: values[0]!,
                minutes: values[1]!,
                seconds: values[2]!,
              );
              await services.updateSession(
                session.copyWith(
                  taskId: selectedTask,
                  creditedOverride: credited,
                  revision: session.revision + 1,
                ),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    ),
  );
}
