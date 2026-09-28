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

enum _Section { calendar, tasks, history, settings }

class ProfilePage extends StatefulWidget {
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
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  _Section selected = _Section.calendar;
  bool collapsed = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  AppServices get services => widget.services;
  static const labels = ['日历统计', '任务管理', '历史记录', '设置'];
  static const icons = [
    Icons.calendar_month_outlined,
    Icons.checklist,
    Icons.history,
    Icons.tune,
  ];
  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _date(DateTime date) =>
      '${date.year}-${_two(date.month)}-${_two(date.day)}';

  @override
  void initState() {
    super.initState();
    timezone_data.initializeTimeZones();
  }

  Future<void> _rename(TaskRecord task) async {
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
    final session = services.sessions.where((s) => s.id == id).firstOrNull;
    if (session == null) return id.substring(0, id.length < 8 ? id.length : 8);
    final name =
        services.tasks.where((t) => t.id == session.taskId).firstOrNull?.name ??
        '未归类';
    return '$name · ${TaskRow.formatDuration(session.creditedDuration)}';
  }

  Widget _navigation({required bool drawer}) {
    final compact = !drawer && collapsed;
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
              child: Row(
                children: [
                  if (!compact)
                    Expanded(
                      child: Text(
                        '个人主页',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  if (!drawer)
                    IconButton(
                      key: Key(compact ? 'profile-expand' : 'profile-collapse'),
                      tooltip: compact ? '展开导航' : '收起导航',
                      onPressed: () => setState(() => collapsed = !collapsed),
                      icon: Icon(
                        compact ? Icons.menu_open : Icons.chevron_left,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final section in _Section.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Tooltip(
                        message: compact ? labels[section.index] : '',
                        child: Material(
                          color: selected == section
                              ? Theme.of(context).colorScheme.onSurface
                                    .withValues(alpha: 0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            key: Key('profile-nav-${section.name}'),
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() => selected = section);
                              if (drawer) Navigator.pop(context);
                            },
                            child: Semantics(
                              selected: selected == section,
                              button: true,
                              label: labels[section.index],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment: compact
                                      ? MainAxisAlignment.center
                                      : MainAxisAlignment.start,
                                  children: [
                                    Icon(icons[section.index], size: 24),
                                    if (!compact) ...[
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(labels[section.index]),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!compact)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Timer · V0.2',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _calendar() {
    final local = tz.TZDateTime.from(
      services.clock().toUtc(),
      tz.getLocation(services.statisticsTimezone),
    );
    final date = DateTime.utc(local.year, local.month, local.day);
    final stats = services.statistics;
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            for (final entry in {
              '今日': stats.daily[_date(date)] ?? Duration.zero,
              '本周':
                  stats.weekly[_date(
                    date.subtract(Duration(days: local.weekday - 1)),
                  )] ??
                  Duration.zero,
              '本月':
                  stats.monthly['${local.year}-${_two(local.month)}'] ??
                  Duration.zero,
            }.entries)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${entry.key} ${TaskRow.formatDuration(entry.value)}',
                ),
              ),
          ],
        ),
        const SizedBox(height: 32),
        CalendarView(services: services),
      ],
    );
  }

  List<Widget> _conflicts() => [
    if (services.revisionConflict != null) ...[
      Text('同一记录在两台设备上被修改', style: Theme.of(context).textTheme.titleMedium),
      Text('本机：${_sessionSummary(services.revisionConflict!.sessionId)}'),
      Text(
        '云端：${TaskRow.formatDuration(services.revisionConflict!.remote.creditedDuration)}',
      ),
      Wrap(
        children: [
          TextButton(
            onPressed: widget.onResolveRevision == null
                ? null
                : () => widget.onResolveRevision!(true),
            child: const Text('保留本机版本'),
          ),
          TextButton(
            onPressed: widget.onResolveRevision == null
                ? null
                : () => widget.onResolveRevision!(false),
            child: const Text('保留云端版本'),
          ),
        ],
      ),
      const SizedBox(height: 24),
    ],
    if (services.syncConflicts.isNotEmpty) ...[
      Text('待处理的重叠记录', style: Theme.of(context).textTheme.titleMedium),
      for (final conflict in services.syncConflicts)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('两台设备的离线学习时间重叠，请选择保留哪一条。'),
                for (final id in [
                  conflict.firstSessionId,
                  conflict.secondSessionId,
                ])
                  TextButton(
                    onPressed: widget.onResolveConflict == null
                        ? null
                        : () => widget.onResolveConflict!(conflict.id, id),
                    child: Text('保留 ${_sessionSummary(id)}'),
                  ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 24),
    ],
  ];

  Widget _history() {
    final sessions =
        services.visibleSessions.where((s) => s.deletedAt == null).toList()
          ..sort(
            (a, b) =>
                (b.focusSegments.firstOrNull?.start ??
                        DateTime.fromMillisecondsSinceEpoch(0))
                    .compareTo(
                      a.focusSegments.firstOrNull?.start ??
                          DateTime.fromMillisecondsSinceEpoch(0),
                    ),
          );
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        ..._conflicts(),
        if (sessions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('暂无历史记录')),
          ),
        for (final session in sessions)
          ListTile(
            key: Key('session-${session.id}'),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            title: Text(
              services.tasks
                      .where((t) => t.id == session.taskId)
                      .firstOrNull
                      ?.name ??
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
            trailing: Text(TaskRow.formatDuration(session.creditedDuration)),
            onTap: () => showSessionEditor(context, services, session),
          ),
      ],
    );
  }

  Widget _tasks() => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      if (services.tasks.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text('暂无任务，请从主任务页新建')),
        ),
      for (final task in services.tasks)
        ListTile(
          title: Text(task.name),
          subtitle: Text(
            TaskRow.formatDuration(services.totalForTask(task.id)),
          ),
          trailing: PopupMenuButton<String>(
            tooltip: '管理任务',
            onSelected: (value) =>
                value == 'rename' ? _rename(task) : services.deleteTask(task),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('重命名')),
              PopupMenuItem(value: 'delete', child: Text('删除任务')),
            ],
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: services,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 720;
        final panel = switch (selected) {
          _Section.calendar => _calendar(),
          _Section.tasks => _tasks(),
          _Section.history => _history(),
          _Section.settings => PreferencesPage(
            services: services,
            embedded: true,
          ),
        };
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(labels[selected.index]),
            leading: desktop
                ? BackButton(onPressed: () => Navigator.maybePop(context))
                : IconButton(
                    tooltip: '打开导航',
                    icon: const Icon(Icons.menu),
                    onPressed: () => scaffoldKey.currentState!.openDrawer(),
                  ),
            actions: [
              if (!desktop)
                IconButton(
                  tooltip: '返回任务页',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.maybePop(context),
                ),
              if (widget.onSync != null)
                TextButton(onPressed: widget.onSync, child: const Text('同步')),
            ],
          ),
          drawer: desktop
              ? null
              : Drawer(width: 280, child: _navigation(drawer: true)),
          body: Row(
            children: [
              if (desktop)
                SizedBox(
                  width: collapsed
                      ? 76
                      : (constraints.maxWidth * 0.2).clamp(220.0, 300.0),
                  child: _navigation(drawer: false),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (services.syncMessage != null ||
                        services.syncConflicts.isNotEmpty ||
                        services.revisionConflict != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (services.syncMessage != null)
                              Text(services.syncMessage!),
                            if (services.syncConflicts.isNotEmpty ||
                                services.revisionConflict != null)
                              TextButton(
                                onPressed: () =>
                                    setState(() => selected = _Section.history),
                                child: const Text('处理记录冲突'),
                              ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1040),
                          child: KeyedSubtree(
                            key: ValueKey(selected),
                            child: panel,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
