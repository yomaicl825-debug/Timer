import 'package:flutter/material.dart';

import '../../domain/timer/timer_state.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
    required this.phase,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
    required this.onNext,
    required this.onFinishBreak,
  });
  final TimerPhase phase;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;
  final VoidCallback onNext;
  final VoidCallback onFinishBreak;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 16,
    children: [
      if (phase == TimerPhase.focus || phase == TimerPhase.breakTime)
        TextButton(onPressed: onPause, child: const Text('暂停')),
      if (phase == TimerPhase.pausedFocus || phase == TimerPhase.pausedBreak)
        TextButton(onPressed: onResume, child: const Text('继续')),
      if (phase == TimerPhase.breakTime || phase == TimerPhase.pausedBreak)
        TextButton(onPressed: onFinishBreak, child: const Text('提前结束休息')),
      if (phase == TimerPhase.waiting)
        FilledButton(onPressed: onNext, child: const Text('下一轮')),
      if (phase != TimerPhase.ended)
        TextButton(onPressed: onEnd, child: const Text('结束')),
    ],
  );
}
