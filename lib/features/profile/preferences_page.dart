import 'package:flutter/material.dart';

import '../../app.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key, required this.services});
  final AppServices services;
  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late final TextEditingController focus;
  late final TextEditingController rest;
  late final TextEditingController statsZone;
  late final TextEditingController clockZone;
  String? error;

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
      setState(() => error = '时长必须大于 0');
      return;
    }
    await widget.services.setDurations(
      Duration(minutes: focusMinutes),
      Duration(minutes: restMinutes),
    );
    setState(() => error = null);
  }

  Future<void> _saveZones() async {
    try {
      await widget.services.setStatisticsTimezone(statsZone.text.trim());
      await widget.services.setClockTimezone(clockZone.text.trim());
      setState(() => error = null);
    } catch (_) {
      setState(() => error = '时区名称无效');
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.services,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text('深色模式'),
            value: widget.services.darkMode,
            onChanged: widget.services.setDarkMode,
          ),
          ListTile(
            title: const Text('数字字体'),
            subtitle: Text(['轻细', '等宽', '衬线'][widget.services.fontStyle]),
            onTap: () async {
              final selected = await showModalBottomSheet<int>(
                context: context,
                builder: (sheetContext) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < 3; index++)
                        ListTile(
                          title: Text(['轻细', '等宽', '衬线'][index]),
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
          const SizedBox(height: 20),
          TextField(
            key: const Key('focus-minutes'),
            controller: focus,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '专注分钟'),
          ),
          TextField(
            key: const Key('break-minutes'),
            controller: rest,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '休息分钟'),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _saveDurations, child: const Text('保存时长')),
          const SizedBox(height: 20),
          TextField(
            controller: statsZone,
            decoration: const InputDecoration(labelText: '统计时区'),
          ),
          TextField(
            controller: clockZone,
            decoration: const InputDecoration(labelText: '时钟默认时区'),
          ),
          TextButton(onPressed: _saveZones, child: const Text('保存时区')),
          if (error != null) Text(error!),
        ],
      ),
    ),
  );
}
