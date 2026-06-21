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
  String get onboardingContinue => 'متابعة';

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
}
