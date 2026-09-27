import 'dart:async';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../domain/timer/timer_state.dart';
import 'timer_controls.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({
    super.key,
    required this.services,
    this.onEnded,
    this.onClose,
    this.onToggleCompact,
  });
  final AppServices services;
  final VoidCallback? onEnded;
  final VoidCallback? onClose;
  final VoidCallback? onToggleCompact;
  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _tick;
  bool _advancing = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  Future<void> _onTick() async {
    if (_advancing || !mounted) return;
    final state = widget.services.activeTimer;
    if (state == null || state.phase == TimerPhase.ended) return;
    _advancing = true;
    try {
      await widget.services.advanceTimer();
    } finally {
      _advancing = false;
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  static String formatDuration(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final hours = safe.inHours.toString().padLeft(2, '0');
    final minutes = (safe.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (safe.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _display(TimerState state, DateTime now) {
    if (state.mode == TimerMode.elapsed) {
      return formatDuration(state.creditedFocusAt(now));
    }
    if (state.phase == TimerPhase.waiting || state.phase == TimerPhase.ended) {
      return '00:00:00';
    }
    if (state.pausedRemaining != null) {
      return formatDuration(state.pausedRemaining!);
    }
    return formatDuration(state.deadlineAt!.difference(now.toUtc()));
  }

  Future<void> _end() async {
    await widget.services.endTimer();
    widget.onEnded?.call();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.services,
    builder: (context, _) {
      final state = widget.services.activeTimer;
      if (state == null) {
        return const Scaffold(body: Center(child: Text('没有进行中的计时')));
      }
      final now = widget.services.clock();
      final projected = widget.services.engine.advance(state, at: now);
      final displayNow = now.toUtc().isBefore(projected.lastObservedAt)
          ? projected.lastObservedAt
          : now;
      final phase = projected.phase;
      final label = switch (phase) {
        TimerPhase.breakTime || TimerPhase.pausedBreak => 'BREAK',
        TimerPhase.waiting => '等待下一轮',
        TimerPhase.ended => '已结束',
        _ => state.mode == TimerMode.pomodoro ? 'FOCUS' : 'ELAPSED',
      };
      final foreground = Theme.of(context).colorScheme.onSurface;
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (widget.onClose != null)
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    tooltip: '关闭计时窗口',
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ),
              if (widget.onToggleCompact != null)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    tooltip: '切换窗口大小',
                    icon: const Icon(Icons.open_in_full),
                    onPressed: widget.onToggleCompact,
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        letterSpacing: 4,
                        fontSize: 14,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _display(projected, displayNow),
                        style: TextStyle(
                          fontSize: 112,
                          fontWeight: FontWeight.w300,
                          fontFamily: switch (widget.services.fontStyle) {
                            1 => 'monospace',
                            2 => 'serif',
                            _ => null,
                          },
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: foreground,
                        ),
                      ),
                    ),
                    if (projected.clockWarning)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text('系统时间发生回拨，请校准时间后继续'),
                      ),
                    if (phase == TimerPhase.waiting)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text('休息已结束，准备好后开始下一轮'),
                      ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TimerControls(
                    phase: phase,
                    onPause: () => widget.services.pauseTimer(),
                    onResume: () => widget.services.resumeTimer(),
                    onEnd: _end,
                    onNext: () => widget.services.nextRound(),
                    onFinishBreak: () => widget.services.finishBreak(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
