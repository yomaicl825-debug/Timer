import 'l10n/app_text.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'data/cloud/cloudbase_gateway.dart';
import 'data/local/app_database.dart';
import 'data/local/local_repository.dart';
import 'data/sync/sync_coordinator.dart';
import 'data/sync/sync_conflict.dart';
import 'features/auth/auth_page.dart';
import 'platform/timer_window.dart';

class AppHost extends StatefulWidget {
  const AppHost({
    super.key,
    required this.database,
    required this.initialServices,
    this.gateway,
    this.onServicesChanged,
    this.closeAccountWindows,
  });
  final AppDatabase database;
  final AppServices initialServices;
  final CloudGateway? gateway;
  final ValueChanged<AppServices>? onServicesChanged;
  final Future<void> Function(String)? closeAccountWindows;

  @override
  State<AppHost> createState() => _AppHostState();
}

class _AppHostState extends State<AppHost> {
  late AppServices services;
  SyncCoordinator? sync;
  Timer? syncTimer;
  bool syncBusy = false;
  List<SyncConflict> conflicts = [];

  @override
  void initState() {
    super.initState();
    services = widget.initialServices;
    _configureSync();
    syncTimer = Timer.periodic(const Duration(seconds: 30), (_) => _sync());
    if (sync != null) scheduleMicrotask(_sync);
  }

  void _configureSync() {
    final gateway = widget.gateway;
    final repository = services.repository;
    sync = gateway == null || repository == null || services.ownerId == 'local'
        ? null
        : SyncCoordinator(repository, gateway);
  }

  Future<void> _sync() async {
    if (syncBusy || sync == null) return;
    syncBusy = true;
    final currentSync = sync!;
    final currentServices = services;
    try {
      await currentServices.reconcileCloudLock();
      final report = await currentSync.syncNow();
      if (sync != currentSync || services != currentServices) return;
      services.setSyncMessage(
        report.offline
            ? '网络暂不可用，记录保存在本机'
            : report.conflicted > 0
            ? '有同步冲突待处理'
            : report.queued > 0
            ? '有记录等待同步'
            : '已同步',
      );
      await services.load();
      final currentConflicts = await currentSync.unresolvedConflicts();
      if (mounted) setState(() => conflicts = currentConflicts);
      services.setSyncConflicts(
        currentConflicts,
        revision: currentSync.revisionConflict,
      );
    } catch (_) {
      if (services == currentServices) {
        services.setSyncMessage('同步失败，记录保存在本机');
      }
    } finally {
      syncBusy = false;
    }
  }

  Future<void> _resolveConflict(String conflictId, String winnerId) async {
    await sync?.resolveOverlap(conflictId, winnerId);
    await _sync();
  }

  Future<void> _resolveRevision(bool keepLocal) async {
    try {
      await sync?.resolveRevisionConflict(keepLocal: keepLocal);
    } on StateError {
      services.setSyncMessage('记录已更新，请重新选择冲突处理方式');
    }
    await _sync();
  }

  Future<void> _switchOwner(String ownerId) async {
    if (ownerId.isEmpty || ownerId == services.ownerId) return;
    final replacement = AppServices(
      language: services.language,
      repository: LocalRepository(widget.database, ownerId: ownerId),
      cloud: ownerId == 'local' ? null : widget.gateway,
      ownerId: ownerId,
    );
    await replacement.load();
    await replacement.setLanguage(replacement.language);
    await replacement.restoreCloudLock();
    await (widget.closeAccountWindows ?? TimerWindow.closeForOwner)(
      services.ownerId,
    );
    await widget.database.setLastAccount(ownerId);
    if (!mounted) return;
    setState(() {
      services = replacement;
      _configureSync();
      conflicts = [];
    });
    widget.onServicesChanged?.call(replacement);
    await _sync();
  }

  Future<void> _account(BuildContext context) async {
    final gateway = widget.gateway;
    if (gateway == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, '云端账号尚未配置；本机计时可以正常使用'))),
      );
      return;
    }
    if (services.ownerId != 'local') {
      await gateway.signOut();
      await _switchOwner('local');
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (authContext) => AuthPage(
          gateway: gateway,
          onAuthenticated: (ownerId) {
            Navigator.of(authContext).pop();
            _switchOwner(ownerId);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TimerApp(
    services: services,
    onAccount: _account,
    onSync: sync == null ? null : _sync,
    conflicts: conflicts,
    onResolveConflict: sync == null ? null : _resolveConflict,
    onResolveRevision: sync == null ? null : _resolveRevision,
  );
}
