import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../launcher/task_row.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key, required this.services});
  final AppServices services;
  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime month;
  String? selectedDay;

  @override
  void initState() {
    super.initState();
    timezone_data.initializeTimeZones();
    final now = tz.TZDateTime.from(
      widget.services.clock().toUtc(),
      tz.getLocation(widget.services.statisticsTimezone),
    );
    month = DateTime.utc(now.year, now.month);
  }

  static String _key(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _changeMonth(int delta) => setState(() {
    month = DateTime.utc(month.year, month.month + delta);
    selectedDay = null;
  });

  @override
  Widget build(BuildContext context) {
    final totals = widget.services.statistics.daily;
    final first = DateTime.utc(month.year, month.month);
    final leading = first.weekday - DateTime.monday;
    final start = first.subtract(Duration(days: leading));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => _changeMonth(-1),
              icon: const Icon(Icons.chevron_left),
              tooltip: '上个月',
            ),
            Text('${month.year} / ${month.month.toString().padLeft(2, '0')}'),
            IconButton(
              onPressed: () => _changeMonth(1),
              icon: const Icon(Icons.chevron_right),
              tooltip: '下个月',
            ),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('M'),
            Text('T'),
            Text('W'),
            Text('T'),
            Text('F'),
            Text('S'),
            Text('S'),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 48,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final date = start.add(Duration(days: index));
            final key = _key(date);
            final duration = totals[key] ?? Duration.zero;
            final inMonth = date.month == month.month;
            return Tooltip(
              message: '$key · ${TaskRow.formatDuration(duration)}',
              child: InkWell(
                key: Key('day-$key'),
                onTap: () => setState(() => selectedDay = key),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontWeight: duration > Duration.zero
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: inMonth
                          ? null
                          : Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (selectedDay != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '$selectedDay · ${TaskRow.formatDuration(totals[selectedDay] ?? Duration.zero)}',
            ),
          ),
      ],
    );
  }
}
