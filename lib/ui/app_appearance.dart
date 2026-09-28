import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppTheme { light, dark, gray }

class AppAppearance {
  static AppTheme parseTheme(String? value) =>
      AppTheme.values.where((theme) => theme.name == value).firstOrNull ??
      AppTheme.light;

  static const fallback = [
    'Microsoft YaHei',
    'Noto Sans CJK SC',
    'Noto Sans SC',
    'PingFang SC',
  ];
  static String get interfaceFont =>
      defaultTargetPlatform == TargetPlatform.windows
      ? 'Microsoft YaHei'
      : 'Noto Sans CJK SC';

  static String? digitFont(int style) => switch (style) {
    1 =>
      defaultTargetPlatform == TargetPlatform.windows
          ? 'Consolas'
          : 'monospace',
    2 => defaultTargetPlatform == TargetPlatform.windows ? 'Georgia' : 'serif',
    _ => defaultTargetPlatform == TargetPlatform.windows ? 'Segoe UI' : null,
  };

  static ThemeData themeFor(AppTheme choice) {
    final dark = choice != AppTheme.light;
    final background = switch (choice) {
      AppTheme.light => Colors.white,
      AppTheme.dark => Colors.black,
      AppTheme.gray => const Color(0xff333333),
    };
    final foreground = dark ? Colors.white : Colors.black;
    final scheme = (dark ? const ColorScheme.dark() : const ColorScheme.light())
        .copyWith(
          primary: foreground,
          onPrimary: background,
          secondary: foreground,
          onSecondary: background,
          surface: background,
          onSurface: foreground,
          surfaceContainerLow: choice == AppTheme.gray
              ? const Color(0xff2b2b2b)
              : dark
              ? const Color(0xff141414)
              : const Color(0xfff3f3f3),
          surfaceContainerHighest: dark
              ? const Color(0xff454545)
              : const Color(0xffeeeeee),
          onSurfaceVariant: foreground.withValues(alpha: 0.75),
        );
    TextStyle text(double size, {bool heading = false}) => TextStyle(
      fontFamily: interfaceFont,
      fontFamilyFallback: fallback,
      fontSize: size,
      fontWeight: heading ? FontWeight.w600 : FontWeight.w400,
      color: foreground,
      height: 1.35,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: interfaceFont,
      fontFamilyFallback: fallback,
      textTheme: TextTheme(
        displayLarge: text(64, heading: true),
        displayMedium: text(52, heading: true),
        displaySmall: text(42, heading: true),
        headlineLarge: text(36, heading: true),
        headlineMedium: text(32, heading: true),
        headlineSmall: text(28, heading: true),
        titleLarge: text(26, heading: true),
        titleMedium: text(22, heading: true),
        titleSmall: text(18, heading: true),
        bodyLarge: text(20),
        bodyMedium: text(18),
        bodySmall: text(16),
        labelLarge: text(18),
        labelMedium: text(17),
        labelSmall: text(15),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text(26, heading: true),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: text(18),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: text(18),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: text(20),
        subtitleTextStyle: text(16),
      ),
      popupMenuTheme: PopupMenuThemeData(textStyle: text(18)),
      tooltipTheme: TooltipThemeData(
        textStyle: text(16).copyWith(color: background),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: text(18),
        hintStyle: text(18),
      ),
    );
  }
}
