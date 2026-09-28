import 'package:flutter/widgets.dart';

enum AppLanguage {
  zh,
  en;

  Locale get locale => Locale(name);
}

AppLanguage resolveLanguage(String? saved, Locale systemLocale) =>
    switch (saved) {
      'zh' => AppLanguage.zh,
      'en' => AppLanguage.en,
      _ =>
        systemLocale.languageCode.toLowerCase() == 'zh'
            ? AppLanguage.zh
            : AppLanguage.en,
    };
