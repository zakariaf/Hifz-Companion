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
  String get mutashabihatTrainerIntro =>
      'موارد متشابه را کنار هم تمرین کنید تا اشتباه میانشان کمتر شود.';

  @override
  String get commonBack => 'بازگشت';

  @override
  String get mutashabihatDrillReveal => 'نمایش صفحه';

  @override
  String mutashabihatDrillProgress(String position, String total) {
    return '$position از $total';
  }

  @override
  String get mutashabihatDrillNext => 'بعدی';

  @override
  String get mutashabihatDrillComplete => 'این گروه را تمام کردید.';

  @override
  String get mutashabihTypeIdentical => 'یکسان';

  @override
  String get mutashabihTypeNearIdentical => 'تقریباً یکسان';

  @override
  String get mutashabihTypeStructural => 'هم‌ساختار';

  @override
  String ayahRefLabel(String surah, String ayah) {
    return 'سوره $surah · آیه $ayah';
  }

  @override
  String mutashabihatHotspotSemantic(String first, String second) {
    return 'اغلب $first و $second را اشتباه می‌گیرید — برای تمرین لمس کنید';
  }

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
  String get settingsSectionDisplay => 'نمایش';

  @override
  String get settingsSectionCycle => 'چرخهٔ مرور';

  @override
  String get settingsSectionReminders => 'یادآوری‌ها';

  @override
  String get settingsSectionProfiles => 'نمایه‌ها';

  @override
  String get settingsSectionBackup => 'پشتیبان‌گیری';

  @override
  String get settingsSectionAbout => 'درباره';

  @override
  String get settingsLanguageLabel => 'زبان';

  @override
  String get settingsThemeLabel => 'ظاهر';

  @override
  String get settingsCalendarLabel => 'تقویم';

  @override
  String get calendarJalali => 'هجری شمسی';

  @override
  String get calendarUmmAlQura => 'هجری قمری (ام‌القری)';

  @override
  String get calendarGregorian => 'میلادی';

  @override
  String settingsCalendarToday(String date) {
    return 'امروز: $date';
  }

  @override
  String get settingsTermSetLabel => 'اصطلاحات';

  @override
  String get termSetRegionOther => 'عمومی';

  @override
  String get termSetRegionLevant => 'شام';

  @override
  String get termSetRegionSubcontinent => 'شبه‌قاره';

  @override
  String get termSetProvisionalNote =>
      'اصطلاحات کوردی موقتی‌اند و در انتظار بازبینی بومی و علمی هستند.';

  @override
  String get settingsMushafLabel => 'مصحف';

  @override
  String get profilesScreenTitle => 'نمایه‌ها';

  @override
  String get profilesManageSubtitle => 'تعویض یا مدیریت نمایه‌ها';

  @override
  String get profilesAddButton => 'افزودن نمایه';

  @override
  String get profilesNameHint => 'نام نمایشی';

  @override
  String get profilesActiveLabel => 'فعال';

  @override
  String get profileRoleSelf => 'خودم';

  @override
  String get profileRoleStudent => 'دانش‌آموز';

  @override
  String get profileRoleChild => 'کودک';

  @override
  String get profilesRename => 'تغییر نام';

  @override
  String get profilesDelete => 'حذف';

  @override
  String get deleteProfileConfirm => 'حذف نمایه';

  @override
  String deleteProfileConsequence(String name) {
    return 'حذف $name سابقهٔ مرور او را برای همیشه پاک می‌کند. بازگشت‌ناپذیر است و با پاک‌کردن همهٔ داده‌ها فرق دارد.';
  }

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
  String get onboardingPlacementSummary =>
      'برنامهٔ شما آماده است — هر آنچه از بر دارید را یک‌بار مرور می‌کنیم، سپس بر پایهٔ تلاوتتان تنظیم می‌کنیم.';

  @override
  String get onboardingPlacementError => 'ذخیرهٔ تنظیمات ممکن نشد.';

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
  String get todaySemanticTitle => 'مرور امروز';

  @override
  String sectionFarManzil(String region) {
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
  String sectionNearSabqi(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'سبقی',
      },
    );
    return '$_temp0';
  }

  @override
  String sectionNewSabaq(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'سبق',
      },
    );
    return '$_temp0';
  }

  @override
  String get budgetOverflowLine =>
      'امروز فراتر از زمان در دسترس شماست. می‌توانید انتخاب کنید:';

  @override
  String get budgetRaiseBudget => 'افزایش زمان روزانهٔ مرور';

  @override
  String get budgetLengthenCycle => 'طولانی‌تر کردن دورهٔ مرور';

  @override
  String get budgetPauseNewSabaq => 'به تعویق انداختن سبق تازه';

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
  String get decayHolding => 'روبه‌راه';

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
  String get reciteExit => 'بستن';

  @override
  String get reciteRevealHint => 'سطر بعد را آشکار کنید';

  @override
  String reciteStumbleLineLabel(String line) {
    return 'سطر $line';
  }

  @override
  String get reciteUndo => 'بازگردانی';

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
  String get reminderNotificationBody => 'مرور امروز شما آماده است.';

  @override
  String get reminderPermissionDeniedNote =>
      'اعلان‌ها برای این برنامه در تنظیمات دستگاهت خاموش است. می‌توانی آنجا روشنشان کنی تا این یادآوری به دستت برسد.';

  @override
  String get reminderCatchUpBody =>
      'برنامه‌ای آرام برای از سرگیری مرور آماده است.';

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

  @override
  String get mushafJumpTitle => 'رفتن به';

  @override
  String get mushafUnitJuz => 'جزء';

  @override
  String get mushafUnitHizb => 'حزب';

  @override
  String get mushafUnitSurah => 'سوره';

  @override
  String get mushafUnitPage => 'صفحه';

  @override
  String get mushafOverlayWeakLines => 'خط‌های ضعیف';

  @override
  String get mushafOverlayMutashabihat => 'متشابهات';

  @override
  String get mushafZoomIn => 'بزرگ‌نمایی';

  @override
  String get mushafZoomOut => 'کوچک‌نمایی';

  @override
  String get mushafThemeLight => 'روشن';

  @override
  String get mushafThemeSepia => 'سپیا';

  @override
  String get mushafThemeDark => 'تیره';

  @override
  String get mushafAboutTitle => 'درباره این مصحف';

  @override
  String get mushafAboutTanzil =>
      'متن عثمانی: تنزیل (tanzil.net) — حرف‌به‌حرف و دارای انتساب، CC BY 3.0.';

  @override
  String get mushafAboutQul => 'چیدمان صفحه‌ها: QUL.';

  @override
  String get mushafAboutFonts =>
      'قلم‌ها: مجتمع چاپ قرآن ملک فهد (KFGQPC) — بازتوزیع‌شده بدون تغییر.';

  @override
  String get mushafAboutChecksum =>
      'متن و قلم هر صفحه پیش از نمایش با اثر انگشت SHA-256 ثبت‌شده راستی‌آزمایی می‌شود؛ هر فایل راستی‌آزمایی‌نشده رد می‌شود.';

  @override
  String get mushafAboutOffline =>
      'برنامه پس از نخستین دانلودِ راستی‌آزمایی‌شده کاملاً برون‌خط کار می‌کند و صدای شما را ضبط نمی‌کند.';

  @override
  String get progressBandStrong => 'استوار';

  @override
  String get progressBandGood => 'خوب';

  @override
  String get progressBandFair => 'در حال کم‌رنگ‌شدن';

  @override
  String get progressBandWeak => 'آمادهٔ مرور';

  @override
  String get progressBandFaded => 'کم‌رنگ';

  @override
  String get progressNotStarted => 'آغازنشده';

  @override
  String get progressNoValue => '—';

  @override
  String progressPercent(String pct) {
    return '$pct٪';
  }

  @override
  String progressDetailRange(String low, String high) {
    return '$low–$high٪';
  }

  @override
  String get progressDetailRangeEstimated => 'برآورد — هنوز تلاوت نشده';

  @override
  String progressDetailRangeSelf(String range) {
    return 'حدود $range، از خودارزیابی شما';
  }

  @override
  String progressDetailRangeTeacher(String range) {
    return 'حدود $range، با تأیید استادتان';
  }

  @override
  String progressNextDue(String date) {
    return 'مرور بعدی: $date';
  }

  @override
  String get progressNoNextDue => 'هنوز زمان مروری تعیین نشده';

  @override
  String get progressHistoryTitle => 'مرورهای اخیر';

  @override
  String get progressNoHistory => 'هنوز مروری ثبت نشده';

  @override
  String progressHistoryRow(String date, String grade) {
    return '$date · $grade';
  }

  @override
  String get progressEmptyTitle => 'نقشهٔ حفظ شما';

  @override
  String get progressEmptyBody =>
      'این نقشه با صفحه‌های حفظ شما پر می‌شود و به‌آرامی نشان می‌دهد قرآن شما کجا به مرور نیاز دارد.';

  @override
  String get progressWeakestTitle => 'از اینجا آغاز کنید';

  @override
  String get progressForecastTitle => 'روزهای پیشِ‌رو';

  @override
  String get backupOwnershipLine =>
      'نسخهٔ پشتیبان فایلی است که خودتان روی این دستگاه نگه می‌دارید؛ برنامه آن را به جایی نمی‌فرستد و چون ابری در کار نیست، تنها نسخه نزد شماست.';

  @override
  String get backupNoBackupYet => 'هنوز نسخهٔ پشتیبانی گرفته نشده است.';

  @override
  String get backupExportAction => 'ذخیرهٔ نسخهٔ پشتیبان';

  @override
  String get backupImportAction => 'بازیابی از یک فایل';

  @override
  String get eraseAllDataAction => 'پاک‌کردن همهٔ داده‌ها';

  @override
  String get backupPreparing => 'در حال آماده‌سازی نسخهٔ پشتیبان…';

  @override
  String get backupExportFailed => 'آماده‌سازی نسخهٔ پشتیبان ممکن نشد.';

  @override
  String get backupRestored => 'بازیابی انجام شد.';

  @override
  String get backupCrossMushaf =>
      'این نسخه برای مصحف دیگری ساخته شده و اینجا قابل بازیابی نیست.';

  @override
  String get backupPassphrasePromptTitle =>
      'گذرواژهٔ نسخهٔ پشتیبان را وارد کنید';

  @override
  String get backupPassphraseHint => 'گذرواژه';

  @override
  String get backupUnlockAction => 'بازکردن';

  @override
  String get backupErrorNotBackup => 'این فایل یک نسخهٔ پشتیبان حِفظ نیست.';

  @override
  String get backupErrorNewer =>
      'این نسخه با نگارش تازه‌تری از برنامه ساخته شده است؛ برای بازکردن آن به‌روزرسانی کنید.';

  @override
  String get backupErrorDamaged => 'این فایل آسیب‌دیده یا ناقص است.';

  @override
  String get backupErrorWrongPassword =>
      'گذرواژه نادرست است یا فایل آسیب دیده است.';

  @override
  String get backupErrorUnreadable => 'خواندن این فایل ممکن نشد.';

  @override
  String get backupNoRecoveryTradeoff =>
      'اگر این گوشی و فایل پشتیبان را از دست بدهید، سابقهٔ شما بازیافتنی نیست؛ ابر یا حسابی برای بازگرداندن آن وجود ندارد.';

  @override
  String get backupEncryptToggle => 'رمزگذاری این نسخه';

  @override
  String get backupEncryptOneLiner =>
      'فایل را با گذرواژه‌ای که تنها نزد شماست قفل می‌کند.';

  @override
  String get backupPassphraseUnrecoverable =>
      'اگر این گذرواژه را فراموش کنید، فایل بازنمی‌شود؛ و هیچ‌جا ذخیره نمی‌شود.';

  @override
  String get backupUnencryptedReadable =>
      'نسخهٔ رمزگذاری‌نشده را هرکس فایل را باز کند می‌تواند بخواند.';

  @override
  String get backupSaveAction => 'ذخیرهٔ نسخه';

  @override
  String get backupMergeOption => 'افزودن به سابقهٔ من';

  @override
  String get backupMergeConsequence =>
      'مرورهای واردشده را به سابقهٔ کنونی شما می‌افزاید و هر دو را نگه می‌دارد.';

  @override
  String get backupReplaceOption => 'جایگزینی همهٔ داده‌ها';

  @override
  String get backupReplaceConsequence =>
      'همهٔ داده‌های کنونی در همراه حِفظ را با محتوای فایل جایگزین می‌کند.';

  @override
  String get eraseConsequence =>
      'این کار همهٔ نمایه‌ها و همهٔ سابقهٔ مرور را روی این دستگاه برای همیشه پاک می‌کند. آنگاه هر فایل پشتیبانی که ذخیره کرده‌اید تنها نسخهٔ باقی‌مانده است. این کار بازگشت‌پذیر نیست.';

  @override
  String get eraseConfirmFirst => 'پاک‌کردن همه‌چیز';

  @override
  String get eraseKeepData => 'داده‌هایم بماند';

  @override
  String get eraseConsequenceSecond => 'این کار همیشگی است و بازگشت‌پذیر نیست.';

  @override
  String get eraseConfirmSecond => 'اکنون پاک کن';

  @override
  String get scienceTitle => 'دانشی که دنبال می‌کنیم';

  @override
  String get scienceIntro =>
      'هر گفته در این صفحه بر پایهٔ منبعی نام‌برده و درجه‌ای از استواری است؛ آن را نشان می‌دهیم تا مبنای کار را بسنجید. این وعده‌ای دربارهٔ حفظ شما نیست، بلکه بیانِ آن چیزی است که بر آن تکیه می‌کنیم.';

  @override
  String get scienceEvidenceLabel => 'شواهد';

  @override
  String get scienceSourcesLabel => 'منابع';

  @override
  String get scienceNeedsReview => 'نیازمند بازبینی اهل علم';

  @override
  String get scienceOpensInBrowser => 'در مرورگر شما باز می‌شود';

  @override
  String get scienceGroupA => 'حافظه و فراموشی';

  @override
  String get scienceGroupB => 'فاصله‌گذاری و زمان‌بندی';

  @override
  String get scienceGroupC => 'سازوکار برنامهٔ مرور';

  @override
  String get scienceGroupD => 'بازخوانی از حافظه';

  @override
  String get scienceGroupE => 'آیات متشابه';

  @override
  String get scienceGroupF => 'صفحه همچون یک واحد';

  @override
  String get scienceGroupG => 'ماندگاری در درازمدت';

  @override
  String get scienceGroupH => 'روش سنّتی';

  @override
  String get scienceGroupI => 'انگیزه بدون فشار';

  @override
  String get scienceGroupJ => 'صداقت و حریم خصوصی';

  @override
  String get scienceClaimC001Headline =>
      'حافظه بر منحنی‌ای پیش‌بینی‌پذیر کم‌رنگ می‌شود؛ نخست تند، سپس آرام.';

  @override
  String get scienceClaimC002Headline =>
      'صفحه‌ای که «فراموش» کرده‌اید گم نشده است؛ بازخواندنش بسیار آسان‌تر از حفظ نخستین آن است.';

  @override
  String get scienceClaimC003Headline =>
      'یک لغزش به معنای از دست رفتن صفحه نیست.';

  @override
  String get scienceClaimC004Headline =>
      'خواب شب کمک می‌کند آنچه امروز مرور کرده‌اید در حافظهٔ ماندگار جای گیرد.';

  @override
  String get scienceClaimC004Caveat =>
      'برنامه بر پایهٔ روزهای کامل زمان‌بندی می‌کند و خوابِ شما را دنبال نمی‌کند.';

  @override
  String get scienceClaimC005Headline =>
      'آنچه ژرف و پیوسته بازخوانده شود به سطحی کمابیش ثابت می‌رسد که دهه‌ها می‌ماند.';

  @override
  String get scienceClaimC006Headline =>
      'مرور با فاصله‌های فزاینده بسیار بهتر از بازخوانی در یک نشست نگه می‌دارد.';

  @override
  String get scienceClaimC007Headline =>
      'بهترین فاصله میان مرورها با استوارتر شدن صفحه بیشتر می‌شود: روزانه، سپس هفتگی، سپس ماهانه.';

  @override
  String get scienceClaimC008Headline =>
      'فاصله‌های بازتر یعنی کار روزانهٔ کمتر برای همان نتیجهٔ ماندگار، نه تنبلی.';

  @override
  String get scienceClaimC009Headline =>
      'مرور کمی زودهنگام چند دقیقه هزینه دارد، اما دیرکرد ممکن است صفحه را ببرد؛ پس کمی زودتر را برمی‌گزینیم.';

  @override
  String get scienceClaimC010Headline =>
      'برنامه کم‌رنگ‌شدن یادآوری را با منحنیِ استانداردِ بازِ تکرارِ فاصله‌دار مدل می‌کند.';

  @override
  String get scienceClaimC010Caveat =>
      'این ثابت‌ها برآوردی آغازین‌اند که از مرورهای شما تنظیم می‌شوند، نه قاعده‌ای ثابت.';

  @override
  String get scienceClaimC011Headline =>
      'هر مرور به‌هنگام، صفحه را پیش از نیاز به مرور دوباره دیرپاتر می‌کند.';

  @override
  String get scienceClaimC012Headline =>
      'مرور صفحه هنگامی که اندکی سست‌تر است، آن را بیش از مرور در حالت تازه استوار می‌کند.';

  @override
  String get scienceClaimC013Headline =>
      'پخش‌کردن مرور در روزها (و شب‌ها) بهتر از فشردن آن در یک نشست می‌ماند.';

  @override
  String get scienceClaimC014Headline =>
      'چرخهٔ مرور سنّتی خود همان تکرارِ فاصله‌دار است؛ برنامه تنها درون آن بازچینش می‌کند.';

  @override
  String get scienceClaimC016Headline =>
      'هر صفحه دستِ‌کم یک‌بار در هر چرخه‌ای که برمی‌گزینید مرور می‌شود — برنامه می‌تواند بیشتر مرورش کند، نه کمتر.';

  @override
  String get scienceClaimC016Caveat =>
      'این تضمینی ساختاری است — هر صفحه درون چرخهٔ شما بازمی‌گردد — نه احتمالی عددی.';

  @override
  String get scienceClaimC017Headline =>
      'به دنبال عددی مانند «صد در صد» نمی‌رویم؛ این کار روزانهٔ شما را چند برابر می‌کند و چرخه‌ای را که از پسش برمی‌آیید می‌شکند.';

  @override
  String get scienceClaimC017Caveat =>
      'برنامه هدف‌هایی ملایم به کار می‌برد؛ دنبال‌کردن عددی نزدیک به کمال کار روزانه را چند برابر می‌کند.';

  @override
  String get scienceClaimC018Headline =>
      'از بر خواندن، حفظ شما را بسیار بیش از بازخوانی نگه می‌دارد.';

  @override
  String get scienceClaimC019Headline =>
      'صفحهٔ استوار هرگز «تمام‌شده» نمی‌شود؛ تنها تسمیعِ پیوسته آن را نگه می‌دارد.';

  @override
  String get scienceClaimC020Headline =>
      'بگذارید تسمیع کامل شود، سپس تصحیح؛ بازخورد پس از تلاشِ کامل بهترین اثر را دارد.';

  @override
  String get scienceClaimC021Headline =>
      'استادی که تسمیع شما را می‌شنود و تصحیح می‌کند، صفحه را بیش از خودسنجی استوار می‌کند.';

  @override
  String get scienceClaimC022Headline =>
      'بازخوانی به‌نظر بهترین می‌آید، اما آنچه به‌راستی می‌ماند از بر خواندن است.';

  @override
  String get scienceClaimC023Headline =>
      'حفظِ ماندگار از بازخواندن در گذر زمان می‌آید، نه از تکرارِ افزون در روزِ حفظ.';

  @override
  String get scienceClaimC024Headline =>
      'بازخواندن صفحه تا جایی که بی‌زحمت شود، از دست دادنش را بسیار دشوارتر می‌کند.';

  @override
  String get scienceClaimC025Headline =>
      'نمی‌توانیم وعده دهیم که هرگز صفحه‌ای را فراموش نکنید؛ ماندگاری از مرورِ منظم می‌آید، نه از عددی جادویی.';

  @override
  String get scienceClaimC025Caveat =>
      'درجه، استواریِ شواهد را وصف می‌کند، نه وعده‌ای دربارهٔ حفظ شما.';

  @override
  String get scienceClaimC026Headline =>
      'بیشتر فراموشی از درهم‌آمیختگی میان بخش‌های همانند است، نه صرفِ گذر زمان.';

  @override
  String get scienceClaimC027Headline =>
      'هرچه دو بخش همانندتر باشند بیشتر درهم می‌آمیزند؛ از این‌رو تنها تکرار آن‌ها را جدا نمی‌کند.';

  @override
  String get scienceClaimC028Headline =>
      'برای آنکه دو بخش همانند را اشتباه نگیرید، آن‌ها را پشت‌سرهم تمرین کنید تا تفاوتشان را دریابید.';

  @override
  String get scienceClaimC029Headline =>
      'تمرینِ تنها یکی از جفتِ همانند ممکن است همتایش را سست کند؛ پس همهٔ گروه را تمرین می‌کنیم.';

  @override
  String get scienceClaimC030Headline =>
      'اشتباهِ آیات همانند هرچه بیشتر از قرآن را در حفظ داشته باشید دشوارتر می‌شود.';

  @override
  String get scienceClaimC031Headline =>
      'قرآن را در صفحاتِ پیوسته حفظ و تسمیع می‌کنید، نه کارت‌های جدا؛ پس به همان شیوه مرور می‌کنیم.';

  @override
  String get scienceClaimC032Headline =>
      'بازخواندن همان صفحه به ترتیبِ ثابتش، همان چیزی است که آن را استوار می‌کند.';

  @override
  String get scienceClaimC033Headline =>
      'کل صفحه را درجه می‌دهیم، اما دقیقاً جای لغزش شما را نشان می‌دهیم.';

  @override
  String get scienceClaimC034Headline =>
      'مرورِ حفظ به‌طور سنّتی در سه مسیر سامان می‌یابد: نو (سبق)، نزدیک (سبقی)، و دور (منزل).';

  @override
  String get scienceClaimC035Headline =>
      'سنّت بر مرورِ پیوسته تأکید دارد: قرآن زودتر از شترانِ دربند از حافظه می‌گریزد.';

  @override
  String get scienceClaimC036Headline =>
      'هفت منزل، قرآن را برای ختمی هفتگی بخش می‌کند: مرورِ همهٔ آنچه حفظ دارید دستِ‌کم هفته‌ای یک‌بار.';

  @override
  String get scienceClaimC037Headline =>
      'استادان، قرن‌ها پیش از تأیید آزمایش‌ها به مرورِ فاصله‌دار و فزاینده رسیدند.';

  @override
  String get scienceClaimC038Headline =>
      'قرآن رودررو از استاد (تلقّی) آموخته و تصحیح می‌شود، با سندی پیوسته تا پیامبر ﷺ.';

  @override
  String get scienceClaimC039Headline =>
      'سنّت همهٔ آنچه را شخص در حفظ دارد دوره‌ای مرور می‌کند؛ جبرئیل هر سال قرآن را با پیامبر ﷺ عرضه می‌کرد.';

  @override
  String get scienceClaimC040Headline =>
      'روش‌های سنّتی متن را بسیار می‌آموزند — صدها تکرار — سپس همهٔ محفوظات را می‌گردانند، نه آنکه در پیِ عددی باشند.';

  @override
  String get scienceClaimC041Headline =>
      'آگاهانه از زنجیره‌ها، نشان‌ها و احساس گناه دوری می‌کنیم: پژوهش نشان می‌دهد اینها عادتِ ماندگار نمی‌سازند و می‌توانند انگیزه‌ای را که شما را به مرور می‌آورد سست کنند.';

  @override
  String get scienceClaimC042Headline =>
      'از دست رفتنِ یک روز پیشرفت شما را پاک نمی‌کند.';

  @override
  String get scienceClaimC043Headline =>
      'یادآوری‌ها آرام و بی‌سرزنش می‌مانند: «مرورِ امروز آماده است»، نه «حفظت را از دست می‌دهی».';

  @override
  String get scienceClaimC044Headline =>
      'پیشرفت شما از آنِ خود شماست — همچون نقشه‌ای آرام از همهٔ قرآنتان نشان داده می‌شود، نه رتبه‌بندی در برابر دیگران.';

  @override
  String get scienceClaimC045Headline =>
      'کارها به نیّت‌هاست — پس هرگز مرور را به دنبالِ پاداش بدل نمی‌کنیم.';

  @override
  String get scienceClaimC046Headline =>
      'این یاریگرِ مرور و خدمتگزارِ استادِ شماست — نه جایگزینِ تصحیحِ شفاهی، و نه فتوا.';

  @override
  String get scienceClaimC047Headline =>
      'هرجا دانش قطعی نباشد یا برنامه ساده‌سازی کند، آن را می‌گوییم — و نام و سالِ هر منبع را می‌آوریم.';

  @override
  String get scienceClaimC047Caveat =>
      'هر ساده‌سازی را آشکار می‌گوییم: «برنامه چنین به کار می‌برد؛ پژوهش چنین تا چنان نشان می‌دهد».';

  @override
  String get scienceClaimC048Headline =>
      'برنامه به‌طور کامل بدون اینترنت کار می‌کند و هرگز صدای شما را ضبط یا داده‌هایتان را به جایی ارسال نمی‌کند.';
}
