import 'package:flutter/material.dart';

import '../../app.dart';
import '../../platform/timer_window.dart';
import '../../data/sync/sync_conflict.dart';
import '../../domain/timer/timer_state.dart';
import '../profile/profile_page.dart';
import 'task_editor.dart';
import 'task_row.dart';

class LauncherPage extends StatelessWidget {
  const LauncherPage({
    super.key,
    required this.services,
    this.onAccount,
    this.onSync,
    this.conflicts = const [],
    this.onResolveConflict,
    this.onResolveRevision,
  });
  final AppServices services;
  final Future<void> Function(BuildContext)? onAccount;
  final Future<void> Function()? onSync;
  final List<SyncConflict> conflicts;
  final Future<void> Function(String, String)? onResolveConflict;
  final Future<void> Function(bool)? onResolveRevision;

  Future<void> _start(
    BuildContext context,
    Future<void> Function() start,
  ) async {
    try {
      await start();
      if (context.mounted) {
        await TimerWindow(services).open(TimerViewArgs.timer, context: context);
      }
    } on StateError {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('已有计时正在进行，请先结束后重试')));
      }
    }
  }

  Future<void> _chooseMode(BuildContext context, String taskId) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('正数计时'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _start(
                  context,
                  () async => services.startElapsed(taskId),
                );
              },
            ),
            ListTile(
              title: const Text('番茄钟'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _start(
                  context,
                  () async => services.startPomodoro(taskId),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = services.tasks;
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              const SizedBox(height: 36),
              Text('YOUR TASKS', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 28),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text('添加任务，开始专注'))
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskRow(
                            task: task,
                            duration: services.totalForTask(task.id),
                            onTap: () => _chooseMode(context, task.id),
                          );
                        },
                      ),
              ),
              const Divider(),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (services.activeTimer != null &&
                      services.activeTimer!.phase != TimerPhase.ended)
                    FilledButton(
                      onPressed: () =>
                          TimerWindow(services)
                              .open(TimerViewArgs.timer, context: context),
                      child: const Text('继续当前计时'),
                    ),
                  TextButton(
                    onPressed: () => showTaskEditor(context, services),
                    child: const Text('新建任务'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _start(
                        context,
                        () async => services.startElapsed(null),
                      );
                    },
                    child: const Text('开始学习'),
                  ),
                  TextButton(
                    onPressed: () =>
                        TimerWindow(services)
                            .open(TimerViewArgs.clock, context: context),
                    child: const Text('全屏时钟'),
                  ),
                  if (onAccount != null)
                    TextButton(
                      onPressed: () => onAccount!(context),
                      child: Text(services.ownerId == 'local' ? '账号' : '退出账号'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ProfilePage(
                          services: services,
                          onSync: onSync,
                          conflicts: conflicts,
                          onResolveConflict: onResolveConflict,
                          onResolveRevision: onResolveRevision,
                        ),
                      ),
                    ),
                    child: const Text('个人主页'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
