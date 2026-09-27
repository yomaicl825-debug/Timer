import 'package:flutter/material.dart';

import '../../app.dart';

Future<void> showTaskEditor(BuildContext context, AppServices services) async {
  String name = '';
  String? error;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('新建任务'),
        content: TextFormField(
          onChanged: (value) => name = value,
          autofocus: true,
          decoration: InputDecoration(labelText: '任务名', errorText: error),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await services.createTask(name);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } on ArgumentError catch (exception) {
                setState(
                  () => error = exception.message == 'Task name already exists'
                      ? '任务名称已存在'
                      : '请输入任务名',
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    ),
  );
}
