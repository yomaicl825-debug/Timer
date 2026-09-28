import '../../l10n/app_language.dart';
import '../../l10n/app_text.dart';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../ui/app_appearance.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({
    super.key,
    required this.services,
    this.embedded = false,
  });
  final AppServices services;
  final bool embedded;
  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late final TextEditingController focus;
  late final TextEditingController rest;
  late final TextEditingController statsZone;
  late final TextEditingController clockZone;
  String? durationError;
  String? zoneError;

  @override
  void initState() {
    super.initState();
    focus = TextEditingController(
      text: '${widget.services.focusDuration.inMinutes}',
    );
    rest = TextEditingController(
      text: '${widget.services.breakDuration.inMinutes}',
    );
    statsZone = TextEditingController(text: widget.services.statisticsTimezone);
    clockZone = TextEditingController(text: widget.services.clockTimezone);
  }

  @override
  void dispose() {
    focus.dispose();
    rest.dispose();
    statsZone.dispose();
    clockZone.dispose();
    super.dispose();
  }

  Future<void> _saveDurations() async {
    final focusMinutes = int.tryParse(focus.text.trim()) ?? 0;
    final restMinutes = int.tryParse(rest.text.trim()) ?? 0;
    if (focusMinutes <= 0 || restMinutes <= 0) {
      setState(() => durationError = '时长必须大于 0');
      return;
    }
    await widget.services.setDurations(
      Duration(minutes: focusMinutes),
      Duration(minutes: restMinutes),
    );
    if (mounted) setState(() => durationError = null);
  }

  Future<void> _saveZones() async {
    try {
      await widget.services.setStatisticsTimezone(statsZone.text.trim());
      await widget.services.setClockTimezone(clockZone.text.trim());
      if (mounted) setState(() => zoneError = null);
    } catch (_) {
      if (mounted) setState(() => zoneError = '时区名称无效');
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.services,
    builder: (context, _) {
      final content = ListView(
        key: const Key('preferences-list'),
        padding: const EdgeInsets.all(28),
        children: [
          Text(
            tr(context, '语言 / Language'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final language in AppLanguage.values)
            ListTile(
              title: Text(language == AppLanguage.zh ? '中文' : 'English'),
              selected: widget.services.language == language,
              trailing: widget.services.language == language
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => widget.services.setLanguage(language),
            ),
          const SizedBox(height: 20),
          Text(
            tr(context, '外观'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 12),
          for (final theme in AppTheme.values)
            ListTile(
              title: Text(switch (theme) {
                AppTheme.light => tr(context, '白底黑字'),
                AppTheme.dark => tr(context, '黑底白字'),
                AppTheme.gray => tr(context, '深灰底浅灰字'),
              }),
              leading: Icon(
                theme == AppTheme.light
                    ? Icons.light_mode_outlined
                    : theme == AppTheme.dark
                    ? Icons.dark_mode_outlined
                    : Icons.contrast,
              ),
              trailing: widget.services.theme == theme
                  ? Icon(Icons.check)
                  : null,
              selected: widget.services.theme == theme,
              onTap: () => widget.services.setTheme(theme),
            ),
          ListTile(
            title: Text(tr(context, '数字字体')),
            subtitle: Text(
              [
                tr(context, '轻细'),
                tr(context, '等宽'),
                tr(context, '衬线'),
              ][widget.services.fontStyle],
            ),
            onTap: () async {
              final selected = await showModalBottomSheet<int>(
                context: context,
                builder: (sheetContext) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < 3; index++)
                        ListTile(
                          title: Text(
                            [
                              tr(context, '轻细'),
                              tr(context, '等宽'),
                              tr(context, '衬线'),
                            ][index],
                          ),
                          onTap: () => Navigator.pop(sheetContext, index),
                        ),
                    ],
                  ),
                ),
              );
              if (selected != null) {
                await widget.services.setFontStyle(selected);
              }
            },
          ),
          SizedBox(height: 20),
          TextField(
            key: Key('focus-minutes'),
            controller: focus,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: tr(context, '专注分钟')),
          ),
          TextField(
            key: Key('break-minutes'),
            controller: rest,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: tr(context, '休息分钟')),
          ),
          SizedBox(height: 8),
          FilledButton(
            onPressed: _saveDurations,
            child: Text(tr(context, '保存时长')),
          ),
          if (durationError != null) Text(tr(context, durationError!)),
          SizedBox(height: 20),
          TextField(
            controller: statsZone,
            decoration: InputDecoration(labelText: tr(context, '统计时区')),
          ),
          TextField(
            controller: clockZone,
            decoration: InputDecoration(labelText: tr(context, '时钟默认时区')),
          ),
          TextButton(onPressed: _saveZones, child: Text(tr(context, '保存时区'))),
          if (zoneError != null) Text(tr(context, zoneError!)),
        ],
      );
      return widget.embedded
          ? content
          : Scaffold(
              appBar: AppBar(title: Text(tr(context, '设置'))),
              body: content,
            );
    },
  );
}
