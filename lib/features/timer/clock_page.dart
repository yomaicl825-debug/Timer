import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../../app.dart';
import '../../ui/app_appearance.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({
    super.key,
    required this.services,
    this.now,
    this.onClose,
    this.onToggleCompact,
  });
  final AppServices services;
  final DateTime Function()? now;
  final VoidCallback? onClose;
  final VoidCallback? onToggleCompact;
  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  static bool _zonesReady = false;
  late String timezoneId;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    if (!_zonesReady) {
      timezone_data.initializeTimeZones();
      _zonesReady = true;
    }
    timezoneId = widget.services.clockTimezone;
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  Future<void> _chooseTimezone() async {
    final controller = TextEditingController(text: timezoneId);
    String? error;
    final chosen = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('时区'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'IANA timezone',
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                try {
                  controller.text.trim() == 'UTC'
                      ? tz.UTC
                      : tz.getLocation(controller.text.trim());
                  Navigator.pop(dialogContext, controller.text.trim());
                } catch (_) {
                  update(() => error = '无效时区');
                }
              },
              child: const Text('应用'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (chosen != null && mounted) setState(() => timezoneId = chosen);
  }

  @override
  Widget build(BuildContext context) {
    final instant = (widget.now ?? widget.services.clock)().toUtc();
    final local = tz.TZDateTime.from(
      instant,
      timezoneId == 'UTC' ? tz.UTC : tz.getLocation(timezoneId),
    );
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final date = '${local.year} / ${_two(local.month)} / ${_two(local.day)}';
    final time =
        '${_two(local.hour)}:${_two(local.minute)}:${_two(local.second)}';
    final foreground = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  onPressed: _chooseTimezone,
                  child: Text(timezoneId, style: TextStyle(color: foreground)),
                ),
              ),
            ),
            if (widget.onToggleCompact != null)
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  tooltip: '切换窗口大小',
                  icon: const Icon(Icons.open_in_full),
                  onPressed: widget.onToggleCompact,
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 76, 24, 48),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: (MediaQuery.sizeOf(context).width * 0.22)
                                .clamp(140.0, 360.0),
                            fontFamily: AppAppearance.digitFont(
                              widget.services.fontStyle,
                            ),
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.w300,
                            color: foreground,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        date,
                        style: TextStyle(fontSize: 28, color: foreground),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weekdays[local.weekday - 1],
                        style: TextStyle(fontSize: 22, color: foreground),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: IconButton(
                tooltip: '返回',
                icon: const Icon(Icons.close),
                onPressed: widget.onClose ?? () => Navigator.maybePop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
