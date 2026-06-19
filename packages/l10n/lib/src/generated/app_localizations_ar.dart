// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Hifz Companion';

  @override
  String get hijriUmmAlQuraQualifier => '(Umm al-Qurā)';

  @override
  String get hijriCivilApproximationCaveat =>
      'التاريخ الهجري تقويم مدني تقريبي (أم القرى)؛ وقد يختلف بدء بعض المناسبات يوماً واحداً بحسب رؤية الهلال.';

  @override
  String get navToday => 'اليوم';

  @override
  String get navMushaf => 'المصحف';

  @override
  String get navMutashabihat => 'المتشابهات';

  @override
  String get navProgress => 'التقدّم';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get appearanceFollowSystem => 'تلقائي';

  @override
  String get appearanceLight => 'فاتح';

  @override
  String get appearanceSepia => 'سيبيا';

  @override
  String get appearanceDark => 'داكن';

  @override
  String get appearanceNight => 'ليلي';

  @override
  String get sectionInPreparation => 'هذا القسم قيد الإعداد.';
}
