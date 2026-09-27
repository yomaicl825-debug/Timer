import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/domain/records/session.dart';
import 'package:study_timer/domain/records/statistics.dart';
import 'package:study_timer/domain/timer/timer_state.dart';

FocusSession session(
  String id,
  DateTime start,
  DateTime end, {
  String? taskId,
  Duration? override,
}) => FocusSession(
  id: id,
  ownerId: 'u',
  taskId: taskId,
  mode: TimerMode.elapsed,
  focusSegments: [FocusSegment(start: start, end: end)],
  creditedOverride: override,
  revision: 0,
);

void main() {
  test('Asia/Shanghai midnight splits focus, Monday week and month', () {
    final item = session(
      's',
      DateTime.utc(2026, 9, 30, 15, 30),
      DateTime.utc(2026, 9, 30, 16, 30),
      taskId: 't',
    );
    final result = Statistics.calculate([item], 'Asia/Shanghai');
    expect(result.daily['2026-09-30'], const Duration(minutes: 30));
    expect(result.daily['2026-10-01'], const Duration(minutes: 30));
    expect(result.monthly['2026-09'], const Duration(minutes: 30));
    expect(result.monthly['2026-10'], const Duration(minutes: 30));
    expect(result.weekly['2026-09-28'], const Duration(hours: 1));
    expect(result.perTask['t'], const Duration(hours: 1));
  });

  test('DST spring transition keeps true elapsed duration', () {
    final item = session(
      's',
      DateTime.utc(2026, 3, 8, 6, 30),
      DateTime.utc(2026, 3, 8, 7, 30),
    );
    final result = Statistics.calculate([item], 'America/New_York');
    expect(result.daily['2026-03-08'], const Duration(hours: 1));
    expect(result.total, const Duration(hours: 1));
  });

  test('credited override splits proportionally at midnight', () {
    final item = session(
      's',
      DateTime.utc(2026, 9, 30, 15, 30),
      DateTime.utc(2026, 9, 30, 16, 30),
      override: const Duration(minutes: 40),
    );
    final result = Statistics.calculate([item], 'Asia/Shanghai');
    expect(result.daily['2026-09-30'], const Duration(minutes: 20));
    expect(result.daily['2026-10-01'], const Duration(minutes: 20));
    expect(result.total, const Duration(minutes: 40));
  });

  test('deleted sessions do not count and task edit changes grouping', () {
    final original = session(
      's',
      DateTime.utc(2026, 1, 1),
      DateTime.utc(2026, 1, 1, 1),
      taskId: 'old',
    );
    final changed = original.copyWith(taskId: 'new');
    expect(
      Statistics.calculate([changed], 'UTC').perTask['new'],
      const Duration(hours: 1),
    );
    expect(Statistics.calculate([changed], 'UTC').perTask['old'], isNull);
    final deleted = changed.copyWith(deletedAt: DateTime.utc(2026, 1, 2));
    expect(Statistics.calculate([deleted], 'UTC').total, Duration.zero);
  });
}
