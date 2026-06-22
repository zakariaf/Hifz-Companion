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
  String get actionSave => 'پاشەکەوت';

  @override
  String get actionCancel => 'پاشگەزبوونەوە';

  @override
  String get actionConfirm => 'پشتڕاستکردنەوە';

  @override
  String get actionUndo => 'گەڕاندنەوە';

  @override
  String get actionRetry => 'هەوڵدانەوە';

  @override
  String get actionClose => 'داخستن';

  @override
  String get actionBack => 'گەڕانەوە';

  @override
  String get actionNext => 'دواتر';

  @override
  String get mushafRiwayahLabel => 'ڕیوایەتی حەفس لە عاسم — موسحەفی مەدینە';

  @override
  String juzLabel(String juz) {
    return 'جوزی $juz';
  }

  @override
  String pageJuz(String page, String juz) {
    return 'پەڕەی $page · جوزی $juz';
  }

  @override
  String heatmapWeakestPage(String page) {
    return 'لاوازترین پەڕە $page';
  }

  @override
  String pagesDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پەڕە بۆ پێداچوونەوە',
      one: '$count پەڕە بۆ پێداچوونەوە',
    );
    return '$_temp0';
  }

  @override
  String catchUpDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ڕۆژ لە پلانی قەرەبووکردنەوە',
      one: '$count ڕۆژ لە پلانی قەرەبووکردنەوە',
    );
    return '$_temp0';
  }

  @override
  String signOffCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پەسەندکردن',
      one: '$count پەسەندکردن',
    );
    return '$_temp0';
  }

  @override
  String trackFar(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'levant': 'مەنزیل',
        'subcontinent': 'دەور',
        'other': 'مەنزیل',
      },
    );
    return '$_temp0';
  }

  @override
  String trackNewSabaq(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'سەبەق',
      },
    );
    return '$_temp0';
  }

  @override
  String trackNearSabqi(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'سەبقی',
      },
    );
    return '$_temp0';
  }

  @override
  String trackFarManzil(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'levant': 'مەنزیل',
        'subcontinent': 'دەور',
        'other': 'مەنزیل',
      },
    );
    return '$_temp0';
  }

  @override
  String trackRevisionGeneral(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'پێداچوونەوە',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeAgainVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'پێویستی بە یارمەتی',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeHardVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'هەڵەی بچووک',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeGoodVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'خوێندنەوەی ڕێک',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeEasyVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'بێ کۆسپ',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleWeeklyKhatm(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'ختمی هەفتانەی مەنزیل',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleOneJuzPerDay(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'یەک جوز لە ڕۆژێکدا',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleHalfJuzPerDay(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'نیو جوز لە ڕۆژێکدا',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleTwoJuzPerDay(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'دوو جوز لە ڕۆژێکدا',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleCustom(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'تایبەت',
      },
    );
    return '$_temp0';
  }

  @override
  String cyclePureMode(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'دۆخی خولی پوختە',
      },
    );
    return '$_temp0';
  }

  @override
  String get cyclePureModeSubtitle =>
      'بە تەواوی سووڕەکەت بکە — بەبێ ڕیزبەندی نوێ';

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
  String get onboardingBack => 'گەڕانەوە';

  @override
  String get onboardingWelcomeIntent =>
      'ئەم ئەپە دیارییەکی بەخۆڕاییە، سەدەقەیەکی بەردەوام، بۆ یارمەتیدانت لە پاراستنی ئەوەی لەبەرت کردووە.';

  @override
  String get onboardingWelcomePrivacyNoAccount =>
      'بەبێ هەژمار و بەبێ چوونەژوورەوە.';

  @override
  String get onboardingWelcomePrivacyNoMic =>
      'دەنگت تۆمار ناکات و مایکرۆفۆنی نییە.';

  @override
  String get onboardingWelcomePrivacyOnDevice =>
      'هیچ شتێک دەربارەی تۆ ئەم ئامێرە بەجێناهێڵێت.';

  @override
  String get onboardingWelcomePrivacyOfflineAfter =>
      'بەبێ ئینتەرنێت کار دەکات؛ دەتوانیت لە دۆخی فڕیندا بیهێڵیتەوە.';

  @override
  String get onboardingWelcomeServant =>
      'یارمەتیدەری پێداچوونەوەتە و خزمەتکاری مامۆستاکەتە، نە جێگرەوەی تەلەقین و نە فەتوا.';

  @override
  String get onboardingLanguageStepTitle => 'زمانی ئەپ';

  @override
  String get onboardingLanguageStepBody =>
      'دەستبەجێ لە شاشەکانی ڕێکخستندا دەردەکەوێت.';

  @override
  String get languageNameFa => 'فارسی';

  @override
  String get languageNameCkb => 'کوردیی ناوەندی';

  @override
  String get languageNameAr => 'العربية';

  @override
  String get onboardingRiwayahStepTitle => 'موسحەف';

  @override
  String get onboardingRiwayahStepBody =>
      'ئەمە موسحەفی پاڵپشتکراوە؛ دواتر لە ڕێکخستنەکان دەگۆڕدرێت. خشتەکە بە دەقێکی دیاریکراوەوە نووساو نییە.';

  @override
  String get onboardingCorePreparingTitle => 'ئامادەکردنی موسحەف';

  @override
  String get onboardingCorePreparingBody =>
      'فایلەکانی موسحەفی پاڵپشتکراو پشکنین دەکرێن.';

  @override
  String get onboardingCoreReadyTitle => 'موسحەف ئامادەیە';

  @override
  String get onboardingCoreReadyBody =>
      'ئێستا هەموو شتێک لەسەر ئامێرەکەتە؛ لە دۆخی فڕیندا کار دەکات.';

  @override
  String get onboardingCoreIntegrityFailureTitle =>
      'پشتڕاستکردنەوەی موسحەف نەکرا';

  @override
  String get onboardingCoreIntegrityFailureBody =>
      'فایلەکانی موسحەف یەک ناگرنەوە، بۆیە بۆ پاراستنی وردی، دەقەکە پیشان نادرێت.';

  @override
  String get onboardingDone => 'تەواو';

  @override
  String get onboardingRetry => 'هەوڵدانەوە';

  @override
  String get onboardingHeld => 'لەبەرکراو';

  @override
  String get onboardingNotHeld => 'لەبەرنەکراو';

  @override
  String onboardingCoverageCellLabel(String juz, String state) {
    return '$juz — $state';
  }

  @override
  String get todayEmpty => 'لە ئێستادا هیچ پەڕەیەک نییە بۆ پێداچوونەوە.';

  @override
  String get commonRetry => 'هەوڵدانەوە';

  @override
  String pageNumber(String pageNumber) {
    return 'پەڕەی $pageNumber';
  }

  @override
  String get trackNewLabel => 'سەبەق';

  @override
  String get trackNearLabel => 'سەبقی';

  @override
  String get trackFarLabel => 'مەنزیل';

  @override
  String get gradeAgain => 'دووبارە';

  @override
  String get gradeHard => 'قورس';

  @override
  String get gradeGood => 'باش';

  @override
  String get gradeEasy => 'ئاسان';

  @override
  String get decayNeedsRevision => 'پێویستی بە پێداچوونەوەیە';

  @override
  String get decaySteady => 'جێگیر';

  @override
  String get a11yAnnounceCatchUpReady => 'خشتەی پێداچوونەوە ئامادەیە.';

  @override
  String get a11yAnnouncePageGraded => 'هەڵسەنگاندن تۆمارکرا.';

  @override
  String get a11yAnnounceSignOffRecorded => 'پەسەندی مامۆستا تۆمارکرا.';

  @override
  String get stateDue => 'کاتی پێداچوونەوە';

  @override
  String get stateWeak => 'لاواز';

  @override
  String get stateSignedOff => 'پەسەندی مامۆستا';

  @override
  String get stateDone => 'ئەمڕۆ پێداچوونەوەی بۆ کرا';

  @override
  String get stateLocked => 'لەلایەن مامۆستاوە قوفڵکراوە';

  @override
  String get gradeAgainSemantics =>
      'پێویستم بە یارمەتی بوو — بۆ پێداچوونەوەی نزیک';

  @override
  String get gradeHardSemantics => 'هەڵەی بچووک — پێداچوونەوەی نزیکتر';

  @override
  String get gradeGoodSemantics => 'خوێندنەوەیەکی ڕێک — لە کاتی ئاسایی';

  @override
  String get gradeEasySemantics => 'بێ ماندووبوون — بە ماوەیەکی درێژتر';

  @override
  String get gradeBandWaitingHint => 'بۆ هەڵسەنگاندن، پەڕەکە دەربخە';

  @override
  String get teacherSignoffLabel => 'مامۆستا ئامادەیە';

  @override
  String get teacherSignoffSupporting => 'بۆ ئەوەی مامۆستاکەت پەسەندی بکات';

  @override
  String get certaintyEvidencePrefix => 'هێزی بەڵگە: ';

  @override
  String get certaintyMaPhrase => 'لە جێگیرترین دۆزینەوەکانی زانستی بیرەوەری';

  @override
  String get certaintyRctExpPhrase => 'تاقیکردنەوەیەکی کۆنترۆڵکراو';

  @override
  String get certaintyCsPhrase => 'تویژینەوەیەکی بنەڕەتی کلاسیک';

  @override
  String get certaintyObsPhrase => 'تویژینەوەیەکی مەیدانی/چاودێری';

  @override
  String get certaintyTextPhrase => 'پێداچوونەوەی شارەزا یان بەڵگەنامەی ڕێباز';

  @override
  String get certaintyTradPhrase =>
      'زانستی نەقلی؛ سەرچاوەکەی لە خوارەوە ناوبراوە';

  @override
  String get certaintyLegendTitle => 'هێزی ئەو بەڵگانەی پشتی پێدەبەستین';

  @override
  String get catchUpEmpathy => 'کێشە نییە — بەهێمنی قەرەبووی دەکەینەوە';

  @override
  String catchUpMissedDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ڕۆژ بەبێ پێداچوونەوە تێپەڕی',
      one: '$count ڕۆژ بەبێ پێداچوونەوە تێپەڕی',
    );
    return '$_temp0';
  }

  @override
  String catchUpPlanLine(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'پلانێک بۆ $count ڕۆژ کە سووڕەکەت تەواو دەکات',
      one: 'پلانێک بۆ $count ڕۆژ کە سووڕەکەت تەواو دەکات',
    );
    return '$_temp0';
  }

  @override
  String get catchUpStartPlan => 'دەستپێکی پلان';

  @override
  String get catchUpAdjust => 'ڕێکخستنی پلان';

  @override
  String get catchUpDefer => 'دواتر';

  @override
  String get emptyFirstRunBody =>
      'دوای دەستپێکردن، پێداچوونەوەکەت لێرە دەردەکەوێت';

  @override
  String get emptyFirstRunAction => 'دەستپێبکە';

  @override
  String get emptyAllDone => 'پێداچوونەوەی ئەمڕۆ تەواوبوو';

  @override
  String get reminderToggleLabel => 'بیرخستنەوەی ڕۆژانە';

  @override
  String get reminderTimeLabel => 'کاتی بیرخستنەوە';

  @override
  String get reminderCatchUpNoteLabel =>
      'تێبینییەکی هێمن کاتێک چەند ڕۆژێک تێدەپەڕێت';

  @override
  String get reminderHonestLine =>
      'بیرخستنەوەیەکی بێلایەن لە کاتێکدا کە خۆت هەڵیدەبژێریت؛ هەر کاتێک بتەوێت بێدەنگی بکە — هیچ نانێردرێت';

  @override
  String get destructiveKeepData => 'داتاکانم بهێڵەرەوە';

  @override
  String get destructiveEraseAllConsequence =>
      'ئەمە هەموو تۆمارەکانی حیفز بۆ هەموو پرۆفایلەکان لەسەر ئەم ئامێرە بۆ هەمیشە دەسڕێتەوە؛ ناگەڕێتەوە، و چونکە هیچ ڕاژەیەک نییە لە هیچ شوێنێکی تردا ناگەڕێتەوە.';

  @override
  String get destructiveEraseAllConfirm => 'بەردەوامبوون لە سڕینەوە';

  @override
  String get destructiveEraseAllSecondConsequence =>
      'دڵنیاکردنەوەی کۆتایی: ئێستا هەموو شتێک بۆ هەمیشە دەسڕێتەوە.';

  @override
  String get destructiveEraseAllSecondConfirm => 'هەموو شتێک بۆ هەمیشە بسڕەوە';

  @override
  String get destructiveWipeProfileConsequence =>
      'ئەمە تۆمارەکانی ئەم پرۆفایلە لەسەر ئەم ئامێرە بۆ هەمیشە دەسڕێتەوە؛ ناگەڕێتەوە.';

  @override
  String get destructiveWipeProfileConfirm => 'ئەم پرۆفایلە بسڕەوە';

  @override
  String get destructiveAbortConsequence =>
      'ئەمە ڕەشنووسی ئێستا فڕێدەدات؛ ناگەڕێتەوە.';

  @override
  String get destructiveAbortConfirm => 'ڕەشنووس فڕێبدە';
}
