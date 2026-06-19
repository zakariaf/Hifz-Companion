// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Central Kurdish (`ckb`).
class AppLocalizationsCkb extends AppLocalizations {
  AppLocalizationsCkb([String locale = 'ckb']) : super(locale);

  @override
  String get appTitle => 'Hifz Companion';

  @override
  String get hijriUmmAlQuraQualifier => '(Umm al-Qurā)';

  @override
  String get hijriCivilApproximationCaveat =>
      'ڕێکەوتی کۆچیی مانگی ساڵنامەیەکی مەدەنیی نزیکەییە (ئوم القورا)؛ لەوانەیە دەستپێکی هەندێک بۆنە بەپێی بینینی مانگ بە ڕۆژێک جیاواز بێت.';

  @override
  String get navToday => 'ئەمڕۆ';

  @override
  String get navMushaf => 'موسحەف';

  @override
  String get navMutashabihat => 'هاوشێوەکان';

  @override
  String get navProgress => 'پێشکەوتن';

  @override
  String get navSettings => 'ڕێکخستنەکان';

  @override
  String get appearanceFollowSystem => 'سیستەم';

  @override
  String get appearanceLight => 'ڕووناک';

  @override
  String get appearanceSepia => 'سیپیا';

  @override
  String get appearanceDark => 'تاریک';

  @override
  String get appearanceNight => 'شەو';

  @override
  String get sectionInPreparation => 'ئەم بەشە لە ئامادەکردندایە.';

  @override
  String get onboardingCoverageTitle => 'ئەو جوزانەی لەبەرتە';

  @override
  String get onboardingCoverageInstruction => 'ئەو جوزانە هەڵبژێرە کە لەبەرتە.';

  @override
  String get onboardingConfidenceTitle => 'هەر جوزێک چەند جێگیرە؟';

  @override
  String get confidenceSolid => 'جێگیر';

  @override
  String get confidenceShaky => 'لەرزۆک';

  @override
  String get confidenceRusty => 'پێویستی بە پێداچوونەوەیە';

  @override
  String get onboardingContinue => 'بەردەوامبوون';

  @override
  String get onboardingDone => 'تەواو';

  @override
  String get onboardingRetry => 'هەوڵدانەوە';

  @override
  String get onboardingHeld => 'لەبەرکراو';

  @override
  String get onboardingNotHeld => 'لەبەرنەکراو';

  @override
  String get todayEmpty => 'لە ئێستادا هیچ پەڕەیەک نییە بۆ پێداچوونەوە.';

  @override
  String get commonRetry => 'هەوڵدانەوە';
}
