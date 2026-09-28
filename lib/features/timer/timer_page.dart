import '../../l10n/app_text.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../ui/app_appearance.dart';
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
    _tick = Timer.periodic(Duration(seconds: 1), (_) => _onTick());
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
        return Scaffold(body: Center(child: Text(tr(context, '没有进行中的计时'))));
      }
      final now = widget.services.clock();
      final projected = widget.services.engine.advance(state, at: now);
      final displayNow = now.toUtc().isBefore(projected.lastObservedAt)
          ? projected.lastObservedAt
          : now;
      final phase = projected.phase;
      final label = switch (phase) {
        TimerPhase.breakTime || TimerPhase.pausedBreak => tr(context, 'BREAK'),
        TimerPhase.waiting => tr(context, '等待下一轮'),
        TimerPhase.ended => tr(context, '已结束'),
        _ =>
          state.mode == TimerMode.pomodoro
              ? tr(context, 'FOCUS')
              : tr(context, 'ELAPSED'),
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
                    tooltip: tr(context, '关闭计时窗口'),
                    icon: Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ),
              if (widget.onToggleCompact != null)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    tooltip: tr(context, '切换窗口大小'),
                    icon: Icon(Icons.open_in_full),
                    onPressed: widget.onToggleCompact,
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 64, 24, 104),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            letterSpacing: 4,
                            fontSize: 18,
                            color: foreground,
                          ),
                        ),
                        SizedBox(height: 20),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _display(projected, displayNow),
                            style: TextStyle(
                              fontSize:
                                  (MediaQuery.sizeOf(context).width * 0.22)
                                      .clamp(140.0, 360.0),
                              fontWeight: FontWeight.w300,
                              fontFamily: AppAppearance.digitFont(
                                widget.services.fontStyle,
                              ),
                              fontFeatures: [FontFeature.tabularFigures()],
                              color: foreground,
                            ),
                          ),
                        ),
                        if (projected.clockWarning)
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(tr(context, '系统时间发生回拨，请校准时间后继续')),
                          ),
                        if (phase == TimerPhase.waiting)
                          Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: Text(tr(context, '休息已结束，准备好后开始下一轮')),
                          ),
                      ],
                    ),
                  ),
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
