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
  String get actionSave => 'حفظ';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionUndo => 'تراجع';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionNext => 'التالي';

  @override
  String get mushafRiwayahLabel => 'رواية حفص عن عاصم — مصحف المدينة';

  @override
  String juzLabel(String juz) {
    return 'الجزء $juz';
  }

  @override
  String pageJuz(String page, String juz) {
    return 'صفحة $page · الجزء $juz';
  }

  @override
  String heatmapWeakestPage(String page) {
    return 'أضعف صفحة $page';
  }

  @override
  String pagesDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحة مستحقة للمراجعة',
      many: '$count صفحة مستحقة للمراجعة',
      few: '$count صفحات مستحقة للمراجعة',
      two: 'صفحتان مستحقتان للمراجعة',
      one: 'صفحة واحدة مستحقة للمراجعة',
      zero: 'لا صفحات مستحقة للمراجعة',
    );
    return '$_temp0';
  }

  @override
  String catchUpDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم في خطة التدارك',
      many: '$count يوماً في خطة التدارك',
      few: '$count أيام في خطة التدارك',
      two: 'يومان في خطة التدارك',
      one: 'يوم واحد في خطة التدارك',
      zero: 'لا أيام للتدارك',
    );
    return '$_temp0';
  }

  @override
  String signOffCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اعتماد',
      many: '$count اعتماداً',
      few: '$count اعتمادات',
      two: 'اعتمادان',
      one: 'اعتماد واحد',
      zero: 'لا اعتمادات',
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
        'other': 'سبقي',
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
        'other': 'مراجعة',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeAgainVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'احتجت مساعدة',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeHardVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'أخطاء يسيرة',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeGoodVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'تلاوة سليمة',
      },
    );
    return '$_temp0';
  }

  @override
  String gradeEasyVerb(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'بيُسر',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleWeeklyKhatm(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'ختمة المنازل الأسبوعية',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleOneJuzPerDay(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'جزء واحد يومياً',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleHalfJuzPerDay(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'نصف جزء يومياً',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleTwoJuzPerDay(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'جزآن يومياً',
      },
    );
    return '$_temp0';
  }

  @override
  String cycleCustom(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'مخصّص',
      },
    );
    return '$_temp0';
  }

  @override
  String cyclePureMode(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'الوضع الدوري الخالص',
      },
    );
    return '$_temp0';
  }

  @override
  String get cyclePureModeSubtitle => 'اتّبع دورتك تماماً — دون إعادة ترتيب';

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
  String get mutashabihatTrainerIntro =>
      'درّب على المواضع المتشابهة جنبًا إلى جنب ليقلّ الخلط بينها.';

  @override
  String get commonBack => 'رجوع';

  @override
  String get mutashabihatDrillReveal => 'اكشف الصفحة';

  @override
  String mutashabihatDrillProgress(String position, String total) {
    return '$position من $total';
  }

  @override
  String get mutashabihatDrillNext => 'التالي';

  @override
  String get mutashabihatDrillComplete => 'أتممتَ هذه المجموعة.';

  @override
  String get mutashabihTypeIdentical => 'متطابقة';

  @override
  String get mutashabihTypeNearIdentical => 'شبه متطابقة';

  @override
  String get mutashabihTypeStructural => 'متوازية البنية';

  @override
  String ayahRefLabel(String surah, String ayah) {
    return 'سورة $surah · آية $ayah';
  }

  @override
  String mutashabihatHotspotSemantic(String first, String second) {
    return 'كثيرًا ما تخلط بين $first و$second — انقر للتمرين';
  }

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

  @override
  String get settingsSectionDisplay => 'العرض';

  @override
  String get settingsSectionCycle => 'دورة المراجعة';

  @override
  String get settingsSectionReminders => 'التذكيرات';

  @override
  String get settingsSectionProfiles => 'الملفات الشخصية';

  @override
  String get settingsSectionBackup => 'النسخ الاحتياطي';

  @override
  String get settingsSectionAbout => 'حول التطبيق';

  @override
  String get settingsLanguageLabel => 'اللغة';

  @override
  String get settingsThemeLabel => 'المظهر';

  @override
  String get settingsCalendarLabel => 'التقويم';

  @override
  String get calendarJalali => 'الهجري الشمسي';

  @override
  String get calendarUmmAlQura => 'الهجري (أم القرى)';

  @override
  String get calendarGregorian => 'الميلادي';

  @override
  String settingsCalendarToday(String date) {
    return 'اليوم: $date';
  }

  @override
  String get settingsTermSetLabel => 'المصطلحات';

  @override
  String get termSetRegionOther => 'عام';

  @override
  String get termSetRegionLevant => 'الشام';

  @override
  String get termSetRegionSubcontinent => 'شبه القارة';

  @override
  String get termSetProvisionalNote =>
      'المصطلحات الكوردية مبدئية، بانتظار مراجعة متحدث أصلي وعالم.';

  @override
  String get settingsMushafLabel => 'المصحف';

  @override
  String get profilesScreenTitle => 'الملفات الشخصية';

  @override
  String get profilesManageSubtitle => 'بدّل أو أدِر الملفات الشخصية';

  @override
  String get profilesAddButton => 'إضافة ملف';

  @override
  String get profilesNameHint => 'الاسم الظاهر';

  @override
  String get profilesActiveLabel => 'نشط';

  @override
  String get profileRoleSelf => 'أنا';

  @override
  String get profileRoleStudent => 'طالب';

  @override
  String get profileRoleChild => 'طفل';

  @override
  String get profilesRename => 'إعادة تسمية';

  @override
  String get profilesDelete => 'حذف';

  @override
  String get deleteProfileConfirm => 'حذف الملف';

  @override
  String deleteProfileConsequence(String name) {
    return 'حذف $name يزيل سجل مراجعته نهائيًا. لا يمكن التراجع، وهذا غير مسح كل البيانات.';
  }

  @override
  String get onboardingCoverageTitle => 'الأجزاء التي تحفظها';

  @override
  String get onboardingCoverageInstruction => 'اختر الأجزاء التي تحفظها.';

  @override
  String get onboardingConfidenceTitle => 'ما مدى رسوخ كل جزء؟';

  @override
  String get confidenceSolid => 'راسخ';

  @override
  String get confidenceShaky => 'متذبذب';

  @override
  String get confidenceRusty => 'بحاجة للمراجعة';

  @override
  String get confidenceSolidSemantics => 'راسخ — أحفظه بثبات';

  @override
  String get confidenceShakySemantics => 'متذبذب — يحتاج مراجعة منتظمة';

  @override
  String get confidenceRustySemantics => 'بحاجة للمراجعة — صار بعيدًا';

  @override
  String get confidenceBiasNote =>
      'سنراجع كل ما تحفظه مرّة، ثم نضبط حسب تلاوتك.';

  @override
  String get whenMemorizedOptionalLabel => 'متى حفظته؟ (اختياري)';

  @override
  String whenMemorizedSetLabel(String date) {
    return 'حُفظ: $date';
  }

  @override
  String get whenMemorizedClear => 'مسح';

  @override
  String get staleBandThisYear => 'هذا العام';

  @override
  String get staleBandOneToTwoYears => 'قبل سنة أو سنتين';

  @override
  String get staleBandThreeToFiveYears => 'قبل ٣ إلى ٥ سنوات';

  @override
  String get staleBandMoreThanFiveYears => 'أكثر من ٥ سنوات';

  @override
  String get onboardingCyclePresetStepTitle => 'دورة المراجعة';

  @override
  String get onboardingCyclePresetStepBody =>
      'إيقاعٌ يعرفه معلّمك — اختره أو خصّصه.';

  @override
  String get dailyBudgetLabel => 'وقت المراجعة اليومي';

  @override
  String dailyBudgetMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      many: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
      zero: 'لا دقائق',
    );
    return '$_temp0';
  }

  @override
  String get customFarCycleDays => 'طول الدورة (أيام)';

  @override
  String get customNearWindowJuz => 'نافذة القريب (أجزاء)';

  @override
  String get customNewLinesPerDay => 'أسطر جديدة يومياً';

  @override
  String get onboardingPlacementSummary =>
      'جدولك جاهز — سنراجع كل ما تحفظه مرّة، ثم نضبط حسب تلاوتك.';

  @override
  String get onboardingPlacementError => 'تعذّر حفظ إعدادك.';

  @override
  String get onboardingContinue => 'متابعة';

  @override
  String get onboardingBack => 'رجوع';

  @override
  String get onboardingWelcomeIntent =>
      'هذا التطبيق هديةٌ مجانية، صدقةٌ جارية، ليعينك على حفظ ما حفظت.';

  @override
  String get onboardingWelcomePrivacyNoAccount => 'بلا حساب ولا تسجيل دخول.';

  @override
  String get onboardingWelcomePrivacyNoMic =>
      'لا يسجّل صوتك، ولا ميكروفون فيه.';

  @override
  String get onboardingWelcomePrivacyOnDevice => 'لا شيء عنك يغادر هذا الجهاز.';

  @override
  String get onboardingWelcomePrivacyOfflineAfter =>
      'يعمل بلا إنترنت؛ يمكنك إبقاؤه في وضع الطيران.';

  @override
  String get onboardingWelcomeServant =>
      'هو عونٌ لمراجعتك وخادمٌ لمعلّمك، لا بديلٌ عن التلقّي، وليس فتوى.';

  @override
  String get onboardingLanguageStepTitle => 'لغة التطبيق';

  @override
  String get onboardingLanguageStepBody => 'تُطبَّق فورًا على شاشات الإعداد.';

  @override
  String get languageNameFa => 'فارسی';

  @override
  String get languageNameCkb => 'کوردیی ناوەندی';

  @override
  String get languageNameAr => 'العربية';

  @override
  String get onboardingRiwayahStepTitle => 'المصحف';

  @override
  String get onboardingRiwayahStepBody =>
      'هذا هو المصحف المضمَّن؛ يمكن تبديله لاحقًا من الإعدادات. الجدول لا يتعلّق بنصّ بعينه.';

  @override
  String get onboardingCorePreparingTitle => 'جارٍ تحضير المصحف';

  @override
  String get onboardingCorePreparingBody => 'نتحقّق من ملفات المصحف المضمَّنة.';

  @override
  String get onboardingCoreReadyTitle => 'المصحف جاهز';

  @override
  String get onboardingCoreReadyBody =>
      'كلّ شيء على جهازك الآن؛ يعمل في وضع الطيران.';

  @override
  String get onboardingCoreIntegrityFailureTitle => 'تعذّر التحقّق من المصحف';

  @override
  String get onboardingCoreIntegrityFailureBody =>
      'لم تتطابق ملفات المصحف، فلا يُعرَض النصّ حفاظًا على دقّته.';

  @override
  String get onboardingDone => 'تم';

  @override
  String get onboardingRetry => 'إعادة المحاولة';

  @override
  String get onboardingHeld => 'محفوظ';

  @override
  String get onboardingNotHeld => 'غير محفوظ';

  @override
  String onboardingCoverageCellLabel(String juz, String state) {
    return '$juz — $state';
  }

  @override
  String get todayEmpty => 'لا توجد صفحات مستحقة الآن.';

  @override
  String get todaySemanticTitle => 'مراجعة اليوم';

  @override
  String sectionFarManzil(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'levant': 'المنزل',
        'subcontinent': 'الدور',
        'other': 'المنزل',
      },
    );
    return '$_temp0';
  }

  @override
  String sectionNearSabqi(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'السبقي',
      },
    );
    return '$_temp0';
  }

  @override
  String sectionNewSabaq(String region) {
    String _temp0 = intl.Intl.selectLogic(
      region,
      {
        'other': 'السبق',
      },
    );
    return '$_temp0';
  }

  @override
  String get budgetOverflowLine => 'اليوم أوسع من وقتك المتاح. لك أن تختار:';

  @override
  String get budgetRaiseBudget => 'زيادة وقت المراجعة اليومي';

  @override
  String get budgetLengthenCycle => 'إطالة مدّة الدورة';

  @override
  String get budgetPauseNewSabaq => 'تأجيل السبق الجديد';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String pageNumber(String pageNumber) {
    return 'صفحة $pageNumber';
  }

  @override
  String get trackNewLabel => 'سبق';

  @override
  String get trackNearLabel => 'سبقي';

  @override
  String get trackFarLabel => 'منزل';

  @override
  String get gradeAgain => 'إعادة';

  @override
  String get gradeHard => 'صعب';

  @override
  String get gradeGood => 'جيد';

  @override
  String get gradeEasy => 'سهل';

  @override
  String get decayNeedsRevision => 'يحتاج مراجعة';

  @override
  String get decaySteady => 'ثابت';

  @override
  String get decayHolding => 'مستقرّ';

  @override
  String get a11yAnnounceCatchUpReady => 'خطة المراجعة جاهزة.';

  @override
  String get a11yAnnouncePageGraded => 'تم تسجيل التقييم.';

  @override
  String get a11yAnnounceSignOffRecorded => 'تم تسجيل اعتماد المعلّم.';

  @override
  String get stateDue => 'مستحقة';

  @override
  String get stateWeak => 'ضعيفة';

  @override
  String get stateSignedOff => 'معتمدة من المعلّم';

  @override
  String get stateDone => 'تمت مراجعتها اليوم';

  @override
  String get stateLocked => 'مقفلة من المعلّم';

  @override
  String get gradeAgainSemantics => 'احتجت إلى مساعدة — للمراجعة قريباً';

  @override
  String get gradeHardSemantics => 'أخطاء يسيرة — للمراجعة عن قرب';

  @override
  String get gradeGoodSemantics => 'تلاوة سليمة — في موعدها';

  @override
  String get gradeEasySemantics => 'بلا تكلّف — بمباعدة أطول';

  @override
  String get reciteExit => 'إغلاق';

  @override
  String get reciteRevealHint => 'اكشف السطر التالي';

  @override
  String reciteStumbleLineLabel(String line) {
    return 'السطر $line';
  }

  @override
  String get reciteUndo => 'تراجع';

  @override
  String get gradeBandWaitingHint => 'اكشف الصفحة لتقييمها';

  @override
  String get teacherSignoffLabel => 'المعلّم حاضر';

  @override
  String get teacherSignoffSupporting => 'ليؤكّدها معلّمك';

  @override
  String get certaintyEvidencePrefix => 'قوة الدليل: ';

  @override
  String get certaintyMaPhrase => 'من أرسخ نتائج علم الذاكرة';

  @override
  String get certaintyRctExpPhrase => 'دراسة محكومة واحدة';

  @override
  String get certaintyCsPhrase => 'دراسة تأسيسية كلاسيكية';

  @override
  String get certaintyObsPhrase => 'دراسة ميدانية رصدية';

  @override
  String get certaintyTextPhrase => 'مراجعة خبير أو توثيق منهجي';

  @override
  String get certaintyTradPhrase => 'علم نقلي، مصدره مذكور أدناه';

  @override
  String get certaintyLegendTitle => 'قوة الأدلة التي نستند إليها';

  @override
  String get catchUpEmpathy => 'لا حرج — لنتدارك بهدوء';

  @override
  String catchUpMissedDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مضى $count يوم دون مراجعة',
      many: 'مضى $count يوماً دون مراجعة',
      few: 'مضت $count أيام دون مراجعة',
      two: 'مضى يومان دون مراجعة',
      one: 'مضى يوم واحد دون مراجعة',
      zero: 'لم تمضِ أيام دون مراجعة',
    );
    return '$_temp0';
  }

  @override
  String catchUpPlanLine(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'خطة على $count يوم تُكمل دورتك',
      many: 'خطة على $count يوماً تُكمل دورتك',
      few: 'خطة على $count أيام تُكمل دورتك',
      two: 'خطة ليومين تُكمل دورتك',
      one: 'خطة ليوم واحد تُكمل دورتك',
      zero: 'خطة تُكمل دورتك',
    );
    return '$_temp0';
  }

  @override
  String get catchUpStartPlan => 'ابدأ الخطة';

  @override
  String get catchUpAdjust => 'عدّل الخطة';

  @override
  String get catchUpDefer => 'لاحقاً';

  @override
  String get emptyFirstRunBody => 'ستظهر مراجعتك هنا بعد أن تبدأ';

  @override
  String get emptyFirstRunAction => 'ابدأ';

  @override
  String get emptyAllDone => 'اكتملت مراجعة اليوم';

  @override
  String get reminderToggleLabel => 'تذكير يومي';

  @override
  String get reminderTimeLabel => 'وقت التذكير';

  @override
  String get reminderCatchUpNoteLabel => 'تنبيه لطيف عند تراكم بضعة أيام';

  @override
  String get reminderHonestLine =>
      'تذكير محايد في وقت تختاره؛ يمكنك إسكاته في أي وقت — لا يُرسَل شيء';

  @override
  String get reminderNotificationBody => 'مراجعتك لليوم جاهزة.';

  @override
  String get reminderPermissionDeniedNote =>
      'الإشعارات مُعطَّلة لهذا التطبيق في إعدادات جهازك. يمكنك تفعيلها هناك لتصلك هذه التذكيرة.';

  @override
  String get reminderCatchUpBody => 'خطة هادئة لاستئناف مراجعتك جاهزة.';

  @override
  String get destructiveKeepData => 'احتفظ ببياناتي';

  @override
  String get destructiveEraseAllConsequence =>
      'سيمحو هذا نهائياً جميع سجلات الحفظ لكل الملفات على هذا الجهاز؛ لا يمكن التراجع، ولأنه لا يوجد خادم فلا شيء قابل للاسترجاع في مكان آخر.';

  @override
  String get destructiveEraseAllConfirm => 'متابعة المحو';

  @override
  String get destructiveEraseAllSecondConsequence =>
      'تأكيد أخير: سيُمحى كل شيء الآن نهائياً.';

  @override
  String get destructiveEraseAllSecondConfirm => 'امحُ كل شيء نهائياً';

  @override
  String get destructiveWipeProfileConsequence =>
      'سيمحو هذا نهائياً سجلات هذا الملف على هذا الجهاز؛ لا يمكن التراجع.';

  @override
  String get destructiveWipeProfileConfirm => 'امحُ هذا الملف';

  @override
  String get destructiveAbortConsequence =>
      'سيتجاهل هذا المسودة الحالية؛ لا يمكن التراجع.';

  @override
  String get destructiveAbortConfirm => 'تجاهل المسودة';

  @override
  String get mushafJumpTitle => 'الانتقال إلى';

  @override
  String get mushafUnitJuz => 'جزء';

  @override
  String get mushafUnitHizb => 'حزب';

  @override
  String get mushafUnitSurah => 'سورة';

  @override
  String get mushafUnitPage => 'صفحة';

  @override
  String get mushafOverlayWeakLines => 'الأسطر الضعيفة';

  @override
  String get mushafOverlayMutashabihat => 'المتشابهات';

  @override
  String get mushafZoomIn => 'تكبير';

  @override
  String get mushafZoomOut => 'تصغير';

  @override
  String get mushafThemeLight => 'فاتح';

  @override
  String get mushafThemeSepia => 'بنّي';

  @override
  String get mushafThemeDark => 'داكن';

  @override
  String get mushafAboutTitle => 'حول هذا المصحف';

  @override
  String get mushafAboutTanzil =>
      'النص العثماني: تنزيل (tanzil.net) — منسوخ حرفياً ومنسوب، CC BY 3.0.';

  @override
  String get mushafAboutQul => 'تخطيط الصفحات: QUL.';

  @override
  String get mushafAboutFonts =>
      'الخطوط: مجمع الملك فهد (KFGQPC) — مُعاد توزيعها دون تعديل.';

  @override
  String get mushafAboutChecksum =>
      'يُتحقَّق من النص ومن خط كل صفحة ببصمة SHA-256 مثبَّتة قبل عرضها؛ وأي ملف غير مُتحقَّق منه يُرفَض.';

  @override
  String get mushafAboutOffline =>
      'يعمل التطبيق دون اتصال بالكامل بعد التنزيل الأول المُتحقَّق منه، ولا يسجّل صوتك.';

  @override
  String get progressBandStrong => 'محكمة';

  @override
  String get progressBandGood => 'جيدة';

  @override
  String get progressBandFair => 'تَلين';

  @override
  String get progressBandWeak => 'للمراجعة';

  @override
  String get progressBandFaded => 'خافتة';

  @override
  String get progressNotStarted => 'لم تبدأ';

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
  String get progressDetailRangeEstimated => 'تقدير — لم تُتلَ بعد';

  @override
  String progressDetailRangeSelf(String range) {
    return 'نحو $range، من تقييمك الذاتي';
  }

  @override
  String progressDetailRangeTeacher(String range) {
    return 'نحو $range، بتأكيد معلّمك';
  }

  @override
  String progressNextDue(String date) {
    return 'المراجعة القادمة: $date';
  }

  @override
  String get progressNoNextDue => 'لا موعد مراجعة محدّد بعد';

  @override
  String get progressHistoryTitle => 'آخر المراجعات';

  @override
  String get progressNoHistory => 'لا مراجعات مسجّلة بعد';

  @override
  String progressHistoryRow(String date, String grade) {
    return '$date · $grade';
  }

  @override
  String get progressEmptyTitle => 'خريطة حفظك';

  @override
  String get progressEmptyBody =>
      'تمتلئ هذه الخريطة بصفحات حفظك وتُظهر بهدوء أين يحتاج قرآنك إلى مراجعة.';

  @override
  String get progressWeakestTitle => 'ابدأ من هنا';

  @override
  String get progressForecastTitle => 'الأيام القادمة';

  @override
  String get backupOwnershipLine =>
      'النسخة الاحتياطية ملفّ تحتفظ به أنت على هذا الجهاز؛ لا يرسله التطبيق إلى أي مكان، ولأنه لا توجد سحابة فأنت صاحب النسخة الوحيدة.';

  @override
  String get backupNoBackupYet => 'لا توجد نسخة احتياطية بعد.';

  @override
  String get backupExportAction => 'حفظ نسخة احتياطية';

  @override
  String get backupImportAction => 'الاستعادة من ملف';

  @override
  String get eraseAllDataAction => 'محو كل البيانات';

  @override
  String get backupPreparing => 'جارٍ تحضير النسخة الاحتياطية…';

  @override
  String get backupExportFailed => 'تعذّر تحضير النسخة الاحتياطية.';

  @override
  String get backupRestored => 'تمت الاستعادة.';

  @override
  String get backupCrossMushaf =>
      'أُنشئت هذه النسخة لمصحف مختلف، فلا يمكن استعادتها هنا.';

  @override
  String get backupPassphrasePromptTitle => 'أدخل كلمة سر النسخة الاحتياطية';

  @override
  String get backupPassphraseHint => 'كلمة السر';

  @override
  String get backupUnlockAction => 'فتح';

  @override
  String get backupErrorNotBackup => 'هذا الملف ليس نسخة احتياطية لحِفظ.';

  @override
  String get backupErrorNewer =>
      'أُنشئت هذه النسخة بإصدار أحدث من التطبيق؛ يُرجى التحديث لفتحها.';

  @override
  String get backupErrorDamaged => 'هذا الملف تالف أو غير مكتمل.';

  @override
  String get backupErrorWrongPassword => 'كلمة السر غير صحيحة، أو الملف تالف.';

  @override
  String get backupErrorUnreadable => 'تعذّرت قراءة هذا الملف.';

  @override
  String get backupNoRecoveryTradeoff =>
      'إذا فقدت هذا الهاتف وفقدت ملف النسخة الاحتياطية، فلن يمكن استرجاع سجلك؛ لا توجد سحابة ولا حساب يستعيده.';

  @override
  String get backupEncryptToggle => 'تشفير هذه النسخة';

  @override
  String get backupEncryptOneLiner => 'يقفل الملف بكلمة سر تملكها وحدك.';

  @override
  String get backupPassphraseUnrecoverable =>
      'إن نسيت كلمة السر فلن يمكن فتح الملف؛ ولا تُحفظ في أي مكان.';

  @override
  String get backupUnencryptedReadable =>
      'النسخة غير المشفّرة يمكن لأي من يفتح الملف قراءتها.';

  @override
  String get backupSaveAction => 'حفظ النسخة';

  @override
  String get backupMergeOption => 'الإضافة إلى سجلي';

  @override
  String get backupMergeConsequence =>
      'تضيف المراجعات المستوردة إلى سجلك الحالي مع الإبقاء على الاثنين.';

  @override
  String get backupReplaceOption => 'استبدال كل البيانات';

  @override
  String get backupReplaceConsequence =>
      'تستبدل كل البيانات الموجودة الآن في رفيق الحفظ بمحتوى الملف.';

  @override
  String get eraseConsequence =>
      'يمحو هذا نهائيًا كل ملف شخصي وكل سجل مراجعة على هذا الجهاز. وأي ملف نسخة احتياطية حفظته يصبح حينها النسخة الوحيدة الباقية. لا يمكن التراجع.';

  @override
  String get eraseConfirmFirst => 'محو كل شيء';

  @override
  String get eraseKeepData => 'الإبقاء على بياناتي';

  @override
  String get eraseConsequenceSecond => 'هذا نهائي ولا يمكن التراجع عنه.';

  @override
  String get eraseConfirmSecond => 'محو الآن';
}
