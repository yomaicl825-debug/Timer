import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../../app.dart';
import '../../domain/records/task.dart';
import '../../data/sync/sync_conflict.dart';
import '../launcher/task_row.dart';
import 'calendar_view.dart';
import 'preferences_page.dart';
import 'session_editor.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.services,
    this.onSync,
    this.conflicts = const [],
    this.onResolveConflict,
    this.onResolveRevision,
  });
  final AppServices services;
  final Future<void> Function()? onSync;
  final List<SyncConflict> conflicts;
  final Future<void> Function(String, String)? onResolveConflict;
  final Future<void> Function(bool)? onResolveRevision;

  static bool _zonesReady = false;
  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _date(DateTime date) =>
      '${date.year}-${_two(date.month)}-${_two(date.day)}';

  Future<void> _rename(BuildContext context, TaskRecord task) async {
    final controller = TextEditingController(text: task.name);
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('重命名任务'),
          content: TextField(controller: controller),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('保存'),
            ),
          ],
        ),
      );
      if (name != null) await services.renameTask(task, name);
    } finally {
      controller.dispose();
    }
  }

  String _sessionSummary(String id) {
    final session = services.sessions
        .where((item) => item.id == id)
        .firstOrNull;
    if (session == null) return id.substring(0, id.length < 8 ? id.length : 8);
    final task = services.tasks
        .where((item) => item.id == session.taskId)
        .firstOrNull;
    final name = task?.name ?? '未归类';
    return '$name · ${TaskRow.formatDuration(session.creditedDuration)}';
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: services,
    builder: (context, _) {
      if (!_zonesReady) {
        timezone_data.initializeTimeZones();
        _zonesReady = true;
      }
      final local = tz.TZDateTime.from(
        services.clock().toUtc(),
        tz.getLocation(services.statisticsTimezone),
      );
      final date = DateTime.utc(local.year, local.month, local.day);
      final week = date.subtract(
        Duration(days: local.weekday - DateTime.monday),
      );
      final today = _date(date);
      final weekKey = _date(week);
      final monthKey = '${local.year}-${_two(local.month)}';
      final stats = services.statistics;
      final unresolved = services.syncConflicts;
      final sessions =
          services.visibleSessions.where((s) => s.deletedAt == null).toList()
            ..sort(
              (a, b) =>
                  (b.focusSegments.firstOrNull?.start ??
                          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true))
                      .compareTo(
                        (a.focusSegments.firstOrNull?.start ??
                            DateTime.fromMillisecondsSinceEpoch(
                              0,
                              isUtc: true,
                            )),
                      ),
            );
      return Scaffold(
        appBar: AppBar(
          title: const Text('个人主页'),
          actions: [
            if (onSync != null)
              TextButton(onPressed: onSync, child: const Text('同步')),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => PreferencesPage(services: services),
                ),
              ),
              child: const Text('设置'),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Text(
                      '今日 ${TaskRow.formatDuration(stats.daily[today] ?? Duration.zero)}',
                    ),
                    Text(
                      '本周 ${TaskRow.formatDuration(stats.weekly[weekKey] ?? Duration.zero)}',
                    ),
                    Text(
                      '本月 ${TaskRow.formatDuration(stats.monthly[monthKey] ?? Duration.zero)}',
                    ),
                  ],
                ),
                if (services.syncMessage != null) Text(services.syncMessage!),
                const SizedBox(height: 20),
                CalendarView(services: services),
                const SizedBox(height: 20),
                if (services.revisionConflict != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    '同一记录在两台设备上被修改',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '本机：${_sessionSummary(services.revisionConflict!.sessionId)}',
                  ),
                  Text(
                    '云端：${TaskRow.formatDuration(services.revisionConflict!.remote.creditedDuration)}',
                  ),
                  Wrap(
                    children: [
                      TextButton(
                        onPressed: onResolveRevision == null
                            ? null
                            : () => onResolveRevision!(true),
                        child: const Text('保留本机版本'),
                      ),
                      TextButton(
                        onPressed: onResolveRevision == null
                            ? null
                            : () => onResolveRevision!(false),
                        child: const Text('保留云端版本'),
                      ),
                    ],
                  ),
                ],
                if (unresolved.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    '待处理的重叠记录',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final conflict in unresolved)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('两台设备的离线学习时间重叠，请选择保留哪一条。'),
                            for (final id in [
                              conflict.firstSessionId,
                              conflict.secondSessionId,
                            ])
                              TextButton(
                                onPressed: onResolveConflict == null
                                    ? null
                                    : () => onResolveConflict!(conflict.id, id),
                                child: Text('保留 ${_sessionSummary(id)}'),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
                Text('任务管理', style: Theme.of(context).textTheme.titleMedium),
                for (final task in services.tasks)
                  ListTile(
                    title: Text(task.name),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => value == 'rename'
                          ? _rename(context, task)
                          : services.deleteTask(task),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'rename', child: Text('重命名')),
                        PopupMenuItem(value: 'delete', child: Text('删除任务')),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Text('历史记录', style: Theme.of(context).textTheme.titleMedium),
                for (final session in sessions)
                  ListTile(
                    key: Key("session-${session.id}"),
                    title: Text(
                      services.tasks
                              .where((task) => task.id == session.taskId)
                              .map((task) => task.name)
                              .firstOrNull ??
                          '未归类',
                    ),
                    subtitle: Text(
                      session.focusSegments.isEmpty
                          ? ''
                          : _date(
                              tz.TZDateTime.from(
                                session.focusSegments.first.start,
                                tz.getLocation(services.statisticsTimezone),
                              ),
                            ),
                    ),
                    trailing: Text(
                      TaskRow.formatDuration(session.creditedDuration),
                    ),
                    onTap: () => showSessionEditor(context, services, session),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
