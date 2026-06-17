// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'Hifz Companion';

  @override
  String get hijriUmmAlQuraQualifier => '(Umm al-Qurā)';

  @override
  String get hijriCivilApproximationCaveat =>
      'تاریخ هجریِ قمری یک تقویم مدنیِ تقریبی (اُمّ‌القُرا) است؛ آغاز برخی مناسبت‌ها ممکن است بر پایهٔ رؤیت هلال یک روز متفاوت باشد.';

  @override
  String get navToday => 'امروز';

  @override
  String get navMushaf => 'مصحف';

  @override
  String get navMutashabihat => 'متشابهات';

  @override
  String get navProgress => 'پیشرفت';

  @override
  String get navSettings => 'تنظیمات';

  @override
  String get appearanceFollowSystem => 'سیستم';

  @override
  String get appearanceLight => 'روشن';

  @override
  String get appearanceSepia => 'سپیا';

  @override
  String get appearanceDark => 'تیره';

  @override
  String get appearanceNight => 'شب';
}
