import 'l10n/app_language.dart';
import 'l10n/generated/app_localizations.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'app_host.dart';
import 'data/cloud/cloudbase_gateway.dart';
import 'data/local/app_database.dart';
import 'data/local/local_repository.dart';
import 'domain/timer/timer_state.dart';
import 'features/timer/clock_page.dart';
import 'features/timer/timer_page.dart';
import 'platform/timer_window.dart';
import 'ui/app_appearance.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    final controller = await WindowController.fromCurrentEngine();
    if (controller.arguments.isNotEmpty) {
      final data = jsonDecode(controller.arguments) as Map<String, dynamic>;
      if (data['timerView'] == 'timer' || data['timerView'] == 'clock') {
        await _startTimerWindow(controller, data);
        return;
      }
    }
    await controller.setWindowMethodHandler((call) async {
      if (call.method == 'refresh') {
        await _mainServices?.load();
        final services = _mainServices;
        if (services?.activeTimer?.phase == TimerPhase.ended) {
          await services?.releaseCloudLockIfEnded();
        } else {
          await services?.updateCloudSnapshot();
        }
      }
    });
  }
  final database = AppDatabase.open();
  CloudGateway? gateway;
  if (const String.fromEnvironment('CLOUDBASE_ENV').isNotEmpty) {
    try {
      gateway = CloudGateway(await CloudBaseTransport.connect());
    } catch (_) {
      // Local study remains available while the cloud service is unavailable.
    }
  }
  final current = await gateway?.currentUser();
  final ownerId =
      current?.data ??
      (gateway != null && current?.status == CloudStatus.offline
          ? await database.getLastAccount()
          : null) ??
      'local';
  if (ownerId != 'local') await database.setLastAccount(ownerId);
  final services = AppServices(
    repository: LocalRepository(database, ownerId: ownerId),
    cloud: ownerId == 'local' ? null : gateway,
    ownerId: ownerId,
  );
  await services.load();
  await services.restoreCloudLock();
  _bindMainServices(services);
  runApp(
    AppHost(
      database: database,
      initialServices: services,
      gateway: gateway,
      onServicesChanged: _bindMainServices,
    ),
  );
}

AppServices? _mainServices;
VoidCallback? _appearanceListener;

void _bindMainServices(AppServices services) {
  final previous = _appearanceListener;
  if (previous != null) _mainServices?.removeListener(previous);
  _mainServices = services;
  var theme = services.theme;
  var fontStyle = services.fontStyle;
  var language = services.language;
  _appearanceListener = () {
    if (theme == services.theme &&
        fontStyle == services.fontStyle &&
        language == services.language) {
      return;
    }
    theme = services.theme;
    fontStyle = services.fontStyle;
    language = services.language;
    unawaited(TimerWindow(services).refreshAppearance());
  };
  services.addListener(_appearanceListener!);
}

Future<void> _startTimerWindow(
  WindowController controller,
  Map<String, dynamic> data,
) async {
  await windowManager.ensureInitialized();
  final ownerId = data['ownerId'] as String;
  final database = AppDatabase.open();
  final services = AppServices(
    repository: LocalRepository(database, ownerId: ownerId),
    ownerId: ownerId,
  );
  await services.load();
  final mainId = data['mainWindowId'] as String;
  final mainWindow = WindowController.fromWindowId(mainId);
  services.addListener(() async {
    try {
      await mainWindow.invokeMethod<void>('refresh');
    } catch (_) {}
  });
  await controller.setWindowMethodHandler((call) async {
    if (call.method == 'appearance') {
      final appearance = Map<String, dynamic>.from(call.arguments as Map);
      services.applyAppearance(
        theme: AppAppearance.parseTheme(appearance['theme'] as String?),
        fontStyle: appearance['fontStyle'] as int,
        language: resolveLanguage(
          appearance['language'] as String?,
          services.language.locale,
        ),
      );
    } else if (call.method == 'compact') {
      final compact = call.arguments == true;
      await windowManager.setFullScreen(!compact);
      if (compact) {
        await windowManager.setSize(const Size(560, 320));
        await windowManager.center();
      }
    } else if (call.method == 'close') {
      await windowManager.close();
    }
  });
  await windowManager.setFullScreen(true);
  var compact = false;
  Future<void> toggleCompact() async {
    compact = !compact;
    await windowManager.setFullScreen(!compact);
    if (compact) {
      await windowManager.setSize(const Size(560, 320));
      await windowManager.center();
    }
  }

  runApp(
    AnimatedBuilder(
      animation: services,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppAppearance.themeFor(services.theme),
        locale: services.language.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: data['timerView'] == 'clock'
            ? ClockPage(
                services: services,
                onClose: () => windowManager.close(),
                onToggleCompact: toggleCompact,
              )
            : TimerPage(
                services: services,
                onClose: () => windowManager.close(),
                onToggleCompact: toggleCompact,
                onEnded: () => windowManager.close(),
              ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final services = AppServices.fake();
  @override
  void dispose() {
    services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TimerApp(services: services);
}
