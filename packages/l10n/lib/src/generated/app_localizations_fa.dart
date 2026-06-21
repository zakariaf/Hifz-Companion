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
  String get actionSave => 'ذخیره';

  @override
  String get actionCancel => 'انصراف';

  @override
  String get actionConfirm => 'تأیید';

  @override
  String get actionUndo => 'واگرد';

  @override
  String get actionRetry => 'تلاش دوباره';

  @override
  String get actionClose => 'بستن';

  @override
  String get actionBack => 'بازگشت';

  @override
  String get actionNext => 'بعدی';

  @override
  String get mushafRiwayahLabel => 'روایت حفص از عاصم — مصحف مدینه';

  @override
  String juzLabel(String juz) {
    return 'جزء $juz';
  }

  @override
  String pagesDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحه برای مرور',
      one: '$count صفحه برای مرور',
    );
    return '$_temp0';
  }

  @override
  String trackFar(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'levant': 'منزل',
        'subcontinent': 'دور',
        'other': 'منزل',
      },
    );
    return '$_temp0';
  }

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

  @override
  String get sectionInPreparation => 'این بخش در حال آماده‌سازی است.';

  @override
  String get onboardingCoverageTitle => 'اجزایی که حفظ دارید';

  @override
  String get onboardingCoverageInstruction =>
      'اجزایی را که حفظ دارید انتخاب کنید.';

  @override
  String get onboardingConfidenceTitle => 'هر جزء چقدر استوار است؟';

  @override
  String get confidenceSolid => 'استوار';

  @override
  String get confidenceShaky => 'متزلزل';

  @override
  String get confidenceRusty => 'نیازمند مرور';

  @override
  String get onboardingContinue => 'ادامه';

  @override
  String get onboardingDone => 'پایان';

  @override
  String get onboardingRetry => 'تلاش دوباره';

  @override
  String get onboardingHeld => 'حفظ‌شده';

  @override
  String get onboardingNotHeld => 'حفظ‌نشده';

  @override
  String get todayEmpty => 'در حال حاضر صفحه‌ای برای مرور نیست.';

  @override
  String get commonRetry => 'تلاش دوباره';

  @override
  String pageNumber(String pageNumber) {
    return 'صفحهٔ $pageNumber';
  }

  @override
  String get trackNewLabel => 'سبق';

  @override
  String get trackNearLabel => 'سبقی';

  @override
  String get trackFarLabel => 'منزل';

  @override
  String get gradeAgain => 'دوباره';

  @override
  String get gradeHard => 'سخت';

  @override
  String get gradeGood => 'خوب';

  @override
  String get gradeEasy => 'آسان';

  @override
  String get decayNeedsRevision => 'نیازمند مرور';

  @override
  String get decaySteady => 'پایدار';

  @override
  String get a11yAnnounceCatchUpReady => 'برنامهٔ مرور آماده است.';

  @override
  String get a11yAnnouncePageGraded => 'ارزیابی ثبت شد.';

  @override
  String get a11yAnnounceSignOffRecorded => 'تأیید استاد ثبت شد.';

  @override
  String get stateDue => 'موعد مرور';

  @override
  String get stateWeak => 'ضعیف';

  @override
  String get stateSignedOff => 'تأیید استاد';
}
