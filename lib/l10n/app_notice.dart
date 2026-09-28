import 'app_language.dart';
import 'app_text.dart';

enum NoticeCode {
  timerNeedsReview('其他设备已有计时，当前本机计时待核对'),
  timerConflict('云端计时状态冲突，请检查其他设备'),
  offlineTimer('离线计时，稍后同步'),
  offlineRecords('网络暂不可用，记录保存在本机'),
  pendingConflict('有同步冲突待处理'),
  pendingSync('有记录等待同步'),
  synced('已同步'),
  syncFailed('同步失败，记录保存在本机'),
  conflictChanged('记录已更新，请重新选择冲突处理方式');

  const NoticeCode(this.source);
  final String source;
}

class AppNotice {
  const AppNotice(this.code);
  final NoticeCode code;

  static AppNotice? fromSource(String? source) {
    if (source == null) return null;
    final code = NoticeCode.values
        .where((value) => value.source == source)
        .firstOrNull;
    return AppNotice(code ?? NoticeCode.syncFailed);
  }

  String resolve(AppLanguage language) => translate(language, code.source);
}
