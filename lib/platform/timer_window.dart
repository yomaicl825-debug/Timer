import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../features/timer/clock_page.dart';
import '../features/timer/timer_page.dart';

enum TimerViewArgs { timer, clock }

class TimerWindow {
  TimerWindow(this.services);
  final AppServices services;
  static WindowController? _controller;

  Future<void> open(TimerViewArgs args, {required BuildContext context}) async {
    if (!Platform.isWindows || !services.nativeWindows) {
      if (Platform.isAndroid) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
      if (!context.mounted) return;
      try {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (routeContext) => args == TimerViewArgs.clock
                ? ClockPage(services: services)
                : TimerPage(
                    services: services,
                    onClose: () => Navigator.pop(routeContext),
                    onEnded: () => Navigator.pop(routeContext),
                  ),
          ),
        );
      } finally {
        if (Platform.isAndroid) {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      }
      return;
    }
    final windows = await WindowController.getAll();
    for (final existing in windows) {
      try {
        final data = jsonDecode(existing.arguments) as Map<String, dynamic>;
        if (data['timerView'] == args.name &&
            data['ownerId'] == services.ownerId) {
          _controller = existing;
          await existing.show();
          return;
        }
      } catch (_) {
        // The launcher window has no timer arguments.
      }
    }
    final main = await WindowController.fromCurrentEngine();
    _controller = await WindowController.create(
      WindowConfiguration(
        arguments: jsonEncode({
          'timerView': args.name,
          'ownerId': services.ownerId,
          'mainWindowId': main.windowId,
        }),
        hiddenAtLaunch: true,
      ),
    );
    await _controller!.show();
  }

  static Future<void> closeForOwner(String ownerId) async {
    if (!Platform.isWindows) return;
    final windows = await WindowController.getAll();
    for (final window in windows) {
      Map<String, dynamic> data;
      try {
        data = jsonDecode(window.arguments) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      if (data['ownerId'] == ownerId && data['timerView'] != null) {
        await window.invokeMethod<void>('close');
      }
    }
    _controller = null;
  }

  Future<void> setCompact(bool compact) async {
    await _controller?.invokeMethod<void>('compact', compact);
  }

  Future<void> close() async {
    await _controller?.invokeMethod<void>('close');
    _controller = null;
  }
}
