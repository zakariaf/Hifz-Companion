// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ckb.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ckb'),
    Locale('fa')
  ];

  /// The application name, shown on the placeholder launch screen. Inert placeholder copy with no factual claim; full transcreation for ar/fa/ckb lands in E09.
  ///
  /// In ar, this message translates to:
  /// **'Hifz Companion'**
  String get appTitle;

  /// Short qualifier appended to a Hijri date, naming the variant as the Umm al-Qurā civil calendar so a Hijri date is never shown as 'the Hijri date' in the absolute. Kept as the romanized proper noun across locales pending E09/E19 review of whether to localize the script. needs-scholarly-review (E19); register as a CLAIMS row — no id, grade, or citation here.
  ///
  /// In ar, this message translates to:
  /// **'(Umm al-Qurā)'**
  String get hijriUmmAlQuraQualifier;

  /// Standing one-line honesty note rendered near a Hijri date or the calendar picker: the Hijri date is a civil (Umm al-Qurā) approximation and an observance's start may differ by a day by moon sighting. Sect/madhhab-neutral; issues no fiqh or sighting ruling and bakes in no regional offset. needs-scholarly-review (E19); hand to domain-claims-register-and-science-screen to register and grade as a [TRAD]/text CLAIMS row — no id, grade, or citation invented here. Transcreations (fa/ckb) are best-effort pending native-speaker + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ الهجري تقويم مدني تقريبي (أم القرى)؛ وقد يختلف بدء بعض المناسبات يوماً واحداً بحسب رؤية الهلال.'**
  String get hijriCivilApproximationCaveat;

  /// Bottom-nav label for the Today tab (IA, PRD §12). Navigation copy; transcreations fa/ckb are best-effort pending E09 review.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get navToday;

  /// Bottom-nav label for the Muṣḥaf (reader) tab. Best-effort fa/ckb pending E09.
  ///
  /// In ar, this message translates to:
  /// **'المصحف'**
  String get navMushaf;

  /// Bottom-nav label for the Mutashābihāt (similar-verses) tab. Best-effort fa/ckb pending E09.
  ///
  /// In ar, this message translates to:
  /// **'المتشابهات'**
  String get navMutashabihat;

  /// Bottom-nav label for the Progress tab. Best-effort fa/ckb pending E09.
  ///
  /// In ar, this message translates to:
  /// **'التقدّم'**
  String get navProgress;

  /// Bottom-nav label for the Settings tab. Best-effort fa/ckb pending E09.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// Appearance switcher: follow the OS light/dark setting. Best-effort fa/ckb pending E09.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get appearanceFollowSystem;

  /// Appearance switcher: the Light appearance. Best-effort fa/ckb pending E09.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get appearanceLight;

  /// Appearance switcher: the Sepia (warm paper) appearance. Best-effort fa/ckb pending E09.
  ///
  /// In ar, this message translates to:
  /// **'سيبيا'**
  String get appearanceSepia;

  /// Appearance switcher: the Dark appearance. Best-effort fa/ckb pending E09.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get appearanceDark;

  /// Appearance switcher: the Night (warm-dim) appearance — no sleep claim. Best-effort fa/ckb pending E09.
  ///
  /// In ar, this message translates to:
  /// **'ليلي'**
  String get appearanceNight;

  /// Calm, inert body line shown under each not-yet-built section title in the E07 walking skeleton (Today/Muṣḥaf/Mutashābihāt/Progress/Settings placeholders). Reverent and plain: no claim, no number, no guilt/fear, no exclamation/emoji. Best-effort fa/ckb pending E09 native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'هذا القسم قيد الإعداد.'**
  String get sectionInPreparation;

  /// Title of the cold-start coverage step: the ḥāfiẓ marks which juz they hold. Calm, no guilt. PROVISIONAL — onboarding copy needs native + scholarly review (E11/E19); best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'الأجزاء التي تحفظها'**
  String get onboardingCoverageTitle;

  /// Instruction under the coverage grid. Plain self-report; un-held juz are not failure. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'اختر الأجزاء التي تحفظها.'**
  String get onboardingCoverageInstruction;

  /// Title of the per-juz confidence step (Solid/Shaky/Rusty self-report). No score, no praise. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'ما مدى رسوخ كل جزء؟'**
  String get onboardingConfidenceTitle;

  /// Self-report confidence: the juz is held firmly. Maps to JuzConfidence.solid. Register is honest self-report, never praise/score. PROVISIONAL — term-set-adjacent, needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'راسخ'**
  String get confidenceSolid;

  /// Self-report confidence: the juz wobbles, needs regular revision. Maps to JuzConfidence.shaky. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'متذبذب'**
  String get confidenceShaky;

  /// Self-report confidence: the juz has gone rusty / needs reactivation. Maps to JuzConfidence.rusty. Calm, never 'lost'/'failed'. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'بحاجة للمراجعة'**
  String get confidenceRusty;

  /// Button advancing from coverage capture to the confidence step. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get onboardingContinue;

  /// Button committing the cold-start seed (then the first day is generated). No celebration register. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get onboardingDone;

  /// Calm retry shown if the seed write fails — never a guilt/error-shame message. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get onboardingRetry;

  /// Accessibility/state word for a held juz cell. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'محفوظ'**
  String get onboardingHeld;

  /// Accessibility/state word for an un-held juz cell — calm, never 'missing'/'0%'. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'غير محفوظ'**
  String get onboardingNotHeld;

  /// Calm Today empty state when no page is due right now — neutral, never 'done'/'safe to stop'/'all caught up' celebration (nothing is ever safe to drop). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد صفحات مستحقة الآن.'**
  String get todayEmpty;

  /// Generic calm retry action for a failed local read (e.g. the Today queue) — never a guilt/error-shame message. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// A muṣḥaf page label on a Today row. {pageNumber} is pre-formatted in locale numerals by the caller (numberFormatFor). One card = one of 604 pages (C-031). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {pageNumber}'**
  String pageNumber(String pageNumber);

  /// Track chip for a NEW page (today's new lesson) — the classical term-set 'sabaq'. TERM-SET vocabulary: scholar-reviewed + swappable (E16). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'سبق'**
  String get trackNewLabel;

  /// Track chip for a NEAR page (recent revision) — the classical term-set 'sabqi'. TERM-SET vocabulary. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'سبقي'**
  String get trackNearLabel;

  /// Track chip for a FAR page (consolidated revision) — the classical term-set 'manzil'. TERM-SET vocabulary. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'منزل'**
  String get trackFarLabel;

  /// Grade band: Again (the page needs re-revision). Calm self-assessment, never failure/shame. The full reveal-on-tap band is E12. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'إعادة'**
  String get gradeAgain;

  /// Grade band: Hard. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'صعب'**
  String get gradeHard;

  /// Grade band: Good. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get gradeGood;

  /// Grade band: Easy. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'سهل'**
  String get gradeEasy;

  /// Calm decay indicator label for a weak page — needs revision, never 'failing'/'lost'/alarm. Paired with a distinct glyph (not colour alone). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج مراجعة'**
  String get decayNeedsRevision;

  /// Calm decay indicator label for a steady page. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'ثابت'**
  String get decaySteady;

  /// Screen-reader announcement (SemanticsService.announce, RTL) when the missed-day catch-up plan is ready on Today. Calm, supportive, located-revisit framing — never 'you are behind'/overdue/shame, never a celebration. Consumed by E11/E12; the key + announce path exist now. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'خطة المراجعة جاهزة.'**
  String get a11yAnnounceCatchUpReady;

  /// Screen-reader announcement (RTL) fired once after a page's grade is durably committed on Today. Calm receipt — no praise/score/celebration. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل التقييم.'**
  String get a11yAnnouncePageGraded;

  /// Screen-reader announcement (RTL) when a teacher (talaqqī) sign-off is recorded. Servant-to-the-teacher register; no celebration. Consumed by E12/E16; the key + announce path exist now. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل اعتماد المعلّم.'**
  String get a11yAnnounceSignOffRecorded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'ckb', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ckb':
      return AppLocalizationsCkb();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
