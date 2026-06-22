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
  String pageJuz(String page, String juz) {
    return 'صفحهٔ $page · جزء $juz';
  }

  @override
  String heatmapWeakestPage(String page) {
    return 'ضعیف‌ترین صفحه $page';
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
  String catchUpDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count روز در برنامهٔ جبران',
      one: '$count روز در برنامهٔ جبران',
    );
    return '$_temp0';
  }

  @override
  String signOffCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تأیید',
      one: '$count تأیید',
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
  String trackNewSabaq(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'سبق',
      },
    );
    return '$_temp0';
  }

  @override
  String trackNearSabqi(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'سبقی',
      },
    );
    return '$_temp0';
  }

  @override
  String trackFarManzil(String region) {
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
  String trackRevisionGeneral(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'مرور',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeAgainVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'نیازمند کمک',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeHardVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'اشتباهات جزئی',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeGoodVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'روان و درست',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeEasyVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'بی‌لغزش',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleWeeklyKhatm(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'ختم هفتگی منازل',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleOneJuzPerDay(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'یک جزء در روز',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleHalfJuzPerDay(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'نیم جزء در روز',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleTwoJuzPerDay(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'دو جزء در روز',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleCustom(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'سفارشی',
      },
    );
    return '$_temp0';
  }

  @override
  String cyclePureMode(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'حالت دوره‌ای خالص',
      },
    );
    return '$_temp0';
  }

  @override
  String get cyclePureModeSubtitle =>
      'دقیقاً از چرخهٔ خود پیروی کن — بدون ترتیب‌بندی مجدد';

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
  String get confidenceSolidSemantics => 'راسخ — استوار در یادم است';

  @override
  String get confidenceShakySemantics => 'متزلزل — به مرورِ منظم نیاز دارد';

  @override
  String get confidenceRustySemantics => 'نیازمند مرور — دور شده است';

  @override
  String get confidenceBiasNote =>
      'هر آنچه از بر دارید را یک‌بار مرور می‌کنیم، سپس بر پایهٔ تلاوتتان تنظیم می‌کنیم.';

  @override
  String get whenMemorizedOptionalLabel => 'کِی این را حفظ کردید؟ (اختیاری)';

  @override
  String whenMemorizedSetLabel(String date) {
    return 'حفظ‌شده: $date';
  }

  @override
  String get whenMemorizedClear => 'پاک‌کردن';

  @override
  String get staleBandThisYear => 'امسال';

  @override
  String get staleBandOneToTwoYears => 'یک تا دو سال پیش';

  @override
  String get staleBandThreeToFiveYears => '۳ تا ۵ سال پیش';

  @override
  String get staleBandMoreThanFiveYears => 'بیش از ۵ سال پیش';

  @override
  String get onboardingCyclePresetStepTitle => 'دورهٔ مرور';

  @override
  String get onboardingCyclePresetStepBody =>
      'آهنگی که معلّم‌تان می‌شناسد — انتخاب یا سفارشی‌سازی کنید.';

  @override
  String get dailyBudgetLabel => 'زمان مرور روزانه';

  @override
  String dailyBudgetMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقیقه',
      one: '$count دقیقه',
    );
    return '$_temp0';
  }

  @override
  String get customFarCycleDays => 'طول دوره (روز)';

  @override
  String get customNearWindowJuz => 'پنجرهٔ نزدیک (جزء)';

  @override
  String get customNewLinesPerDay => 'سطرهای تازه در روز';

  @override
  String get onboardingContinue => 'ادامه';

  @override
  String get onboardingBack => 'بازگشت';

  @override
  String get onboardingWelcomeIntent =>
      'این برنامه هدیه‌ای رایگان است، صدقه‌ای جاری، تا در نگه‌داشتِ آنچه از بر کرده‌اید یاری‌تان کند.';

  @override
  String get onboardingWelcomePrivacyNoAccount => 'بدون حساب و بدون ورود.';

  @override
  String get onboardingWelcomePrivacyNoMic =>
      'صدای شما را ضبط نمی‌کند و میکروفون ندارد.';

  @override
  String get onboardingWelcomePrivacyOnDevice =>
      'هیچ‌چیزی دربارهٔ شما این دستگاه را ترک نمی‌کند.';

  @override
  String get onboardingWelcomePrivacyOfflineAfter =>
      'بدون اینترنت کار می‌کند؛ می‌توانید آن را در حالت پرواز نگه دارید.';

  @override
  String get onboardingWelcomeServant =>
      'یاری‌رسانِ مرورِ شماست و خدمتگزارِ معلّم‌تان، نه جایگزینِ تلقّی و نه فتوا.';

  @override
  String get onboardingLanguageStepTitle => 'زبان برنامه';

  @override
  String get onboardingLanguageStepBody =>
      'بی‌درنگ بر صفحه‌های راه‌اندازی اعمال می‌شود.';

  @override
  String get languageNameFa => 'فارسی';

  @override
  String get languageNameCkb => 'کوردیی ناوەندی';

  @override
  String get languageNameAr => 'العربية';

  @override
  String get onboardingRiwayahStepTitle => 'مصحف';

  @override
  String get onboardingRiwayahStepBody =>
      'این مصحفِ همراهِ برنامه است؛ بعداً از تنظیمات قابلِ تعویض است. زمان‌بندی به متنِ خاصی وابسته نیست.';

  @override
  String get onboardingCorePreparingTitle => 'آماده‌سازی مصحف';

  @override
  String get onboardingCorePreparingBody =>
      'فایل‌های مصحفِ همراه بررسی می‌شوند.';

  @override
  String get onboardingCoreReadyTitle => 'مصحف آماده است';

  @override
  String get onboardingCoreReadyBody =>
      'همه‌چیز اکنون روی دستگاهِ شماست؛ در حالت پرواز کار می‌کند.';

  @override
  String get onboardingCoreIntegrityFailureTitle => 'تأییدِ مصحف ممکن نشد';

  @override
  String get onboardingCoreIntegrityFailureBody =>
      'فایل‌های مصحف مطابقت نداشتند، پس برای حفظِ دقّت، متن نمایش داده نمی‌شود.';

  @override
  String get onboardingDone => 'پایان';

  @override
  String get onboardingRetry => 'تلاش دوباره';

  @override
  String get onboardingHeld => 'حفظ‌شده';

  @override
  String get onboardingNotHeld => 'حفظ‌نشده';

  @override
  String onboardingCoverageCellLabel(String juz, String state) {
    return '$juz — $state';
  }

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

  @override
  String get stateDone => 'امروز مرور شد';

  @override
  String get stateLocked => 'قفل‌شده توسط معلم';

  @override
  String get gradeAgainSemantics => 'نیاز به کمک داشتم — برای مرور به‌زودی';

  @override
  String get gradeHardSemantics => 'اشتباه‌های جزئی — مرور نزدیک‌تر';

  @override
  String get gradeGoodSemantics => 'تلاوت روان — در موعد عادی';

  @override
  String get gradeEasySemantics => 'بی‌زحمت — با فاصلهٔ بیشتر';

  @override
  String get gradeBandWaitingHint => 'برای ارزیابی، صفحه را آشکار کنید';

  @override
  String get teacherSignoffLabel => 'استاد حاضر است';

  @override
  String get teacherSignoffSupporting => 'تا استادتان تأیید کند';

  @override
  String get certaintyEvidencePrefix => 'قوّت شواهد: ';

  @override
  String get certaintyMaPhrase => 'از استوارترین یافته‌های دانش حافظه';

  @override
  String get certaintyRctExpPhrase => 'یک پژوهش کنترل‌شده';

  @override
  String get certaintyCsPhrase => 'یک پژوهش بنیادی کلاسیک';

  @override
  String get certaintyObsPhrase => 'یک پژوهش میدانی/مشاهده‌ای';

  @override
  String get certaintyTextPhrase => 'بازبینی کارشناسی یا مستندات روش';

  @override
  String get certaintyTradPhrase => 'دانش نقلی؛ منبعش در زیر آمده است';

  @override
  String get certaintyLegendTitle => 'استواری شواهدی که بر آن تکیه می‌کنیم';

  @override
  String get catchUpEmpathy => 'ایرادی ندارد — با آرامش جبران می‌کنیم';

  @override
  String catchUpMissedDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count روز بدون مرور گذشت',
      one: '$count روز بدون مرور گذشت',
    );
    return '$_temp0';
  }

  @override
  String catchUpPlanLine(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'برنامه‌ای برای $count روز که چرخه‌ات را کامل می‌کند',
      one: 'برنامه‌ای برای $count روز که چرخه‌ات را کامل می‌کند',
    );
    return '$_temp0';
  }

  @override
  String get catchUpStartPlan => 'شروع برنامه';

  @override
  String get catchUpAdjust => 'تنظیم برنامه';

  @override
  String get catchUpDefer => 'بعداً';

  @override
  String get emptyFirstRunBody => 'پس از آغاز، مرور شما اینجا نمایان می‌شود';

  @override
  String get emptyFirstRunAction => 'آغاز';

  @override
  String get emptyAllDone => 'مرور امروز کامل شد';

  @override
  String get reminderToggleLabel => 'یادآوری روزانه';

  @override
  String get reminderTimeLabel => 'زمان یادآوری';

  @override
  String get reminderCatchUpNoteLabel => 'یادداشتی آرام وقتی چند روز جمع شود';

  @override
  String get reminderHonestLine =>
      'یادآوری بی‌طرف در زمانی که خودت انتخاب می‌کنی؛ هر وقت خواستی خاموشش کن — چیزی ارسال نمی‌شود';

  @override
  String get destructiveKeepData => 'داده‌هایم را نگه دار';

  @override
  String get destructiveEraseAllConsequence =>
      'این کار همهٔ سوابق حفظِ همهٔ نمایه‌ها را روی این دستگاه برای همیشه پاک می‌کند؛ قابل بازگشت نیست و چون سروری وجود ندارد، جایی دیگر قابل بازیابی نیست.';

  @override
  String get destructiveEraseAllConfirm => 'ادامهٔ پاک‌سازی';

  @override
  String get destructiveEraseAllSecondConsequence =>
      'تأیید نهایی: اکنون همه‌چیز برای همیشه پاک می‌شود.';

  @override
  String get destructiveEraseAllSecondConfirm => 'همه‌چیز را برای همیشه پاک کن';

  @override
  String get destructiveWipeProfileConsequence =>
      'این کار سوابق این نمایه را روی این دستگاه برای همیشه پاک می‌کند؛ قابل بازگشت نیست.';

  @override
  String get destructiveWipeProfileConfirm => 'این نمایه را پاک کن';

  @override
  String get destructiveAbortConsequence =>
      'این کار پیش‌نویس فعلی را دور می‌ریزد؛ قابل بازگشت نیست.';

  @override
  String get destructiveAbortConfirm => 'دور ریختن پیش‌نویس';
}
