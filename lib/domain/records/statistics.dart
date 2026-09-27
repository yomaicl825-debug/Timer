import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import 'session.dart';

class StatisticsSnapshot {
  StatisticsSnapshot({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.perTask,
    required this.total,
  });
  final Map<String, Duration> daily;
  final Map<String, Duration> weekly;
  final Map<String, Duration> monthly;
  final Map<String, Duration> perTask;
  final Duration total;
}

class _Slice {
  _Slice(this.date, this.microseconds);
  final tz.TZDateTime date;
  final int microseconds;
}

class Statistics {
  static bool _initialized = false;

  static StatisticsSnapshot calculate(
    Iterable<FocusSession> sessions,
    String timezoneId,
  ) {
    if (!_initialized) {
      timezone_data.initializeTimeZones();
      _initialized = true;
    }
    final location = timezoneId == 'UTC' ? tz.UTC : tz.getLocation(timezoneId);
    final daily = <String, Duration>{};
    final weekly = <String, Duration>{};
    final monthly = <String, Duration>{};
    final perTask = <String, Duration>{};
    var total = Duration.zero;
    for (final session in sessions.where((s) => s.deletedAt == null)) {
      final slices = <_Slice>[];
      for (final segment in session.focusSegments) {
        var cursor = segment.start;
        while (cursor.isBefore(segment.end)) {
          final local = tz.TZDateTime.from(cursor, location);
          final nextMidnight = tz.TZDateTime(
            location,
            local.year,
            local.month,
            local.day + 1,
          ).toUtc();
          final end = segment.end.isBefore(nextMidnight)
              ? segment.end
              : nextMidnight;
          slices.add(_Slice(local, end.difference(cursor).inMicroseconds));
          cursor = end;
        }
      }
      final raw = slices.fold<int>(0, (sum, slice) => sum + slice.microseconds);
      final credited = session.creditedDuration.inMicroseconds;
      if (raw == 0) continue;
      var allocated = 0;
      for (var index = 0; index < slices.length; index++) {
        final slice = slices[index];
        final micros = index == slices.length - 1
            ? credited - allocated
            : credited * slice.microseconds ~/ raw;
        allocated += micros;
        final value = Duration(microseconds: micros);
        final local = slice.date;
        final dayKey = _date(local.year, local.month, local.day);
        final weekStart = DateTime.utc(
          local.year,
          local.month,
          local.day,
        ).subtract(Duration(days: local.weekday - DateTime.monday));
        final weekKey = _date(weekStart.year, weekStart.month, weekStart.day);
        final monthKey = '${local.year}-${_two(local.month)}';
        daily.update(dayKey, (old) => old + value, ifAbsent: () => value);
        weekly.update(weekKey, (old) => old + value, ifAbsent: () => value);
        monthly.update(monthKey, (old) => old + value, ifAbsent: () => value);
      }
      final value = Duration(microseconds: credited);
      total += value;
      final taskKey = session.taskId ?? '';
      perTask.update(taskKey, (old) => old + value, ifAbsent: () => value);
    }
    return StatisticsSnapshot(
      daily: daily,
      weekly: weekly,
      monthly: monthly,
      perTask: perTask,
      total: total,
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _date(int year, int month, int day) =>
      '$year-${_two(month)}-${_two(day)}';
}
