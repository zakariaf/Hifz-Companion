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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// The application name, shown on the placeholder launch screen. A proper noun; intentionally identical across locales (not transcreated).
  ///
  /// In ar, this message translates to:
  /// **'Hifz Companion'**
  String get appTitle;

  /// Universal action verb (masdar form, not a command): commit/save the current change. Reused across the app. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get actionSave;

  /// Universal action verb: dismiss without committing. Reused across the app. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get actionCancel;

  /// Universal action verb: confirm an intended action. Reused across the app. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get actionConfirm;

  /// Universal action verb: reverse the last action (e.g. an undo affordance after a grade). Reused across the app. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get actionUndo;

  /// Universal action verb: retry a failed local read/write — calm, never a guilt/error-shame message. Reused across the app. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get actionRetry;

  /// Universal action verb: close a sheet/dialog. Reused across the app. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get actionClose;

  /// Universal action verb: go back one step. Logical 'previous' — the directional icon mirrors by locale, the word does not (engineering 12 §2). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get actionBack;

  /// Universal action verb: advance one step. Logical 'next' — the directional icon mirrors by locale, the word does not. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get actionNext;

  /// Chrome label naming the muṣḥaf edition the app renders — the riwāyah (Ḥafṣ ʿan ʿĀṣim) and the muṣḥaf (Madani, 15-line). Names the CHROME edition only; it never speaks for the Quran 'in the absolute', and no localization mechanism (numerals, bidi, mirror, font) ever reaches a muṣḥaf glyph (design 12 §8). The proper nouns Ḥafṣ/ʿĀṣim are kept in Arabic script across locales; fa/ckb transcreate only the surrounding chrome words. needs-scholarly-review. Best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'رواية حفص عن عاصم — مصحف المدينة'**
  String get mushafRiwayahLabel;

  /// A juz label in chrome (e.g. a Today section header or progress roll-up). {juz} is an ALREADY locale-numeral-formatted, bidi-isolated token from numberFormatFor(locale)/bidi.dart — never a raw int and never concatenated (engineering 12 §4, §5). Demonstrates the foundation 'format → isolate → inject' discipline. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'الجزء {juz}'**
  String juzLabel(String juz);

  /// The muṣḥaf page-card headline 'Page N · Juz M' (design 07 §2). {page} and {juz} are ALREADY locale-numeral-formatted AND FSI/PDI-isolated tokens from localizedPageJuz (the numerals/bidi primitive, E10-T01) — never a raw int, never concatenated (engineering 12 §4–§5). The '·' separator and the page-before-juz order are the translator's. A CHROME label, never a muṣḥaf glyph. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {page} · الجزء {juz}'**
  String pageJuz(String page, String juz);

  /// Retention heat-map: the weakest page named by a juz roll-up tile's badge, spoken in the cell's merged Semantics phrase (design 08 §6). MIN-LEANING honesty — one weak page is what fails the juz, never averaged away (C-019). {page} is an ALREADY locale-numeral-formatted token (localeDigits, E10-T01), never a raw int. Calm maintenance register, never alarm/shame. Consumed by E15. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'أضعف صفحة {page}'**
  String heatmapWeakestPage(String page);

  /// Count of muṣḥaf pages due for revision (a Today/heat-map summary line). ICU plural with ALL SIX Arabic CLDR categories (zero/one/two/few/many/other) — a missing category is a grammatical defect, not a cosmetic gap (engineering 12 §6); the static six-category completeness check is E09-T07. Calm loss-prevention register: pages 'due for revision', never 'overdue'/'behind'/guilt. {count} is locale-numeral-shaped by the generated formatter. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا صفحات مستحقة للمراجعة} one{صفحة واحدة مستحقة للمراجعة} two{صفحتان مستحقتان للمراجعة} few{{count} صفحات مستحقة للمراجعة} many{{count} صفحة مستحقة للمراجعة} other{{count} صفحة مستحقة للمراجعة}}'**
  String pagesDue(int count);

  /// Count of days in the missed-day catch-up plan (the ui-catch-up-banner). ICU plural with all six Arabic CLDR categories. Calm, supportive, located-revisit register — never 'behind'/'overdue'/guilt; the zero form is a neutral fact, not a celebration. {count} is locale-numeral-shaped before placement. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا أيام للتدارك} one{يوم واحد في خطة التدارك} two{يومان في خطة التدارك} few{{count} أيام في خطة التدارك} many{{count} يوماً في خطة التدارك} other{{count} يوم في خطة التدارك}}'**
  String catchUpDays(int count);

  /// Count of teacher (talaqqī) sign-offs (the teacher/halaqa surface). ICU plural with all six Arabic CLDR categories. Servant-to-the-teacher register; neutral, no score/badge/celebration. {count} is locale-numeral-shaped before placement. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا اعتمادات} one{اعتماد واحد} two{اعتمادان} few{{count} اعتمادات} many{{count} اعتماداً} other{{count} اعتماد}}'**
  String signOffCount(int count);

  /// Far-revision track label (the consolidated-revision track); varies by regional tradition — 'manzil' in the Levant/Arab term-set, 'dhor' (دور) in the subcontinent. ICU select over a region key, seeding the one-file term-set swap shape E09-T09 builds out (the full sabaq/sabqi/manzil + grade-verb term-sets are E09-T09). TERM-SET vocabulary: NEEDS scholar review and ships provisional; no track/grade/cycle word is hard-coded in any widget. Best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, levant{منزل} subcontinent{دور} other{منزل}}'**
  String trackFar(String region);

  /// TERM-SET: the New-lesson track label (classical 'sabaq'). ICU select over a region key so a whole vocabulary swaps as one data file, never code. NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{سبق}}'**
  String trackNewSabaq(String region);

  /// TERM-SET: the Near-revision track label (classical 'sabqi'). NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{سبقي}}'**
  String trackNearSabqi(String region);

  /// TERM-SET: the Far-revision track label; varies by region — 'manzil' (Levant/Arab) vs 'dhor' (subcontinent). NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, levant{منزل} subcontinent{دور} other{منزل}}'**
  String trackFarManzil(String region);

  /// TERM-SET: the general-Revision label. NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{مراجعة}}'**
  String trackRevisionGeneral(String region);

  /// TERM-SET: the traditional grade verb for Grade.again (PRD §6.3 'needed help'). The localized VERB only — never the enum name, never a number; the engine signal is unchanged. NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{احتجت مساعدة}}'**
  String gradeAgainVerb(String region);

  /// TERM-SET: the traditional grade verb for Grade.hard (PRD §6.3 'minor mistakes'). NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{أخطاء يسيرة}}'**
  String gradeHardVerb(String region);

  /// TERM-SET: the traditional grade verb for Grade.good (PRD §6.3 'recited clean'). Calm — never 'mastered'. NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{تلاوة سليمة}}'**
  String gradeGoodVerb(String region);

  /// TERM-SET: the traditional grade verb for Grade.easy (PRD §6.3 'effortless'). NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{بيُسر}}'**
  String gradeEasyVerb(String region);

  /// TERM-SET: the 7-Manzil weekly-khatm cycle name (PRD §15.1). The count is part of the transcreated phrase per locale, never a spliced ASCII digit. NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{ختمة المنازل الأسبوعية}}'**
  String cycleWeeklyKhatm(String region);

  /// TERM-SET: the 1-juz/day cycle name (PRD §15.1). NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{جزء واحد يومياً}}'**
  String cycleOneJuzPerDay(String region);

  /// TERM-SET: the ½-juz/day cycle name (PRD §15.1). NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{نصف جزء يومياً}}'**
  String cycleHalfJuzPerDay(String region);

  /// TERM-SET: the 2-juz/day cycle name (PRD §15.1). NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{جزآن يومياً}}'**
  String cycleTwoJuzPerDay(String region);

  /// TERM-SET: the Custom cycle name (PRD §15.1). NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{مخصّص}}'**
  String cycleCustom(String region);

  /// TERM-SET: the Pure-cycle mode name (PRD §15.2). NEEDS scholar review; ckb provisional needs native + scholar review.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{الوضع الدوري الخالص}}'**
  String cyclePureMode(String region);

  /// Subtitle under the Pure-cycle toggle — framed as FIDELITY ('follow your cycle exactly — no reordering'), servant-to-the-teacher (C-014); NEVER 'disable smart features'/'make the app worse', no command/urgency. The longer/pure cycle is never 'permission to stop revising' (C-019, PRD §7.11–§7.12). Consumed by E11/E16. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'اتّبع دورتك تماماً — دون إعادة ترتيب'**
  String get cyclePureModeSubtitle;

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

  /// Screen-reader announcement for the Solid option — the word plus its plain meaning. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'راسخ — أحفظه بثبات'**
  String get confidenceSolidSemantics;

  /// Screen-reader announcement for the Shaky option — the word plus its plain meaning. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'متذبذب — يحتاج مراجعة منتظمة'**
  String get confidenceShakySemantics;

  /// Screen-reader announcement for the Rusty option — the word plus its plain meaning; calm, never 'lost'/'failed'. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'بحاجة للمراجعة — صار بعيدًا'**
  String get confidenceRustySemantics;

  /// Calm conservative-bias note (C-009) shown at the foot of the confidence step — we revise everything once, then adjust to your recitation. Carries NO readiness number, no seeded D/S/R, no percentage. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'سنراجع كل ما تحفظه مرّة، ثم نضبط حسب تلاوتك.'**
  String get confidenceBiasNote;

  /// Button advancing from coverage capture to the confidence step. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get onboardingContinue;

  /// Onboarding chrome Back affordance — returns to the previous step without losing captured values. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get onboardingBack;

  /// Welcome step intent line — the app is offered free as ṣadaqah jāriyah; no transactional/upgrade framing. Methodology/religious — PROVISIONAL, needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'هذا التطبيق هديةٌ مجانية، صدقةٌ جارية، ليعينك على حفظ ما حفظت.'**
  String get onboardingWelcomeIntent;

  /// Welcome privacy fact (C-048): no account / no sign-in. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'بلا حساب ولا تسجيل دخول.'**
  String get onboardingWelcomePrivacyNoAccount;

  /// Welcome privacy fact (C-048): never records audio / no microphone — stated as a protection, not a silent gap. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'لا يسجّل صوتك، ولا ميكروفون فيه.'**
  String get onboardingWelcomePrivacyNoMic;

  /// Welcome privacy fact (C-048): nothing about the user leaves the device; no telemetry. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'لا شيء عنك يغادر هذا الجهاز.'**
  String get onboardingWelcomePrivacyOnDevice;

  /// Welcome privacy fact (C-048): works fully offline (the core muṣḥaf is bundled in the app), try airplane mode. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'يعمل بلا إنترنت؛ يمكنك إبقاؤه في وضع الطيران.'**
  String get onboardingWelcomePrivacyOfflineAfter;

  /// Welcome servant-to-the-teacher framing (C-046): an aid to revision and a servant to the teacher, not a replacement for oral correction (talaqqī), not a fatwa. Methodology/religious — PROVISIONAL, needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'هو عونٌ لمراجعتك وخادمٌ لمعلّمك، لا بديلٌ عن التلقّي، وليس فتوى.'**
  String get onboardingWelcomeServant;

  /// Language-pick step heading (calm noun, not an imperative). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get onboardingLanguageStepTitle;

  /// Language-pick step helper — the choice applies live as a display transform. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تُطبَّق فورًا على شاشات الإعداد.'**
  String get onboardingLanguageStepBody;

  /// Persian language endonym — the same in every UI locale (a language's own name), shown as the fa option.
  ///
  /// In ar, this message translates to:
  /// **'فارسی'**
  String get languageNameFa;

  /// Central Kurdish (Sorani) language endonym — the same in every UI locale, shown as the ckb option. PROVISIONAL — needs native review.
  ///
  /// In ar, this message translates to:
  /// **'کوردیی ناوەندی'**
  String get languageNameCkb;

  /// Arabic language endonym — the same in every UI locale, shown as the ar option.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageNameAr;

  /// Riwāyah/muṣḥaf confirmation step heading (calm noun). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'المصحف'**
  String get onboardingRiwayahStepTitle;

  /// Riwāyah step helper — names the bundled edition as fact, notes it is swappable later in Settings and that the scheduler is text-agnostic; issues no ruling on which riwāyah is correct (R2). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'هذا هو المصحف المضمَّن؛ يمكن تبديله لاحقًا من الإعدادات. الجدول لا يتعلّق بنصّ بعينه.'**
  String get onboardingRiwayahStepBody;

  /// Core-preparation step — the bundled muṣḥaf is being verified and prepared (not a network download). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحضير المصحف'**
  String get onboardingCorePreparingTitle;

  /// Core-preparation helper — verifying the bundled muṣḥaf files. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'نتحقّق من ملفات المصحف المضمَّنة.'**
  String get onboardingCorePreparingBody;

  /// Core-preparation done — quiet confirmation, never a celebration. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'المصحف جاهز'**
  String get onboardingCoreReadyTitle;

  /// Core-ready airplane-mode-after proof (C-048): everything is on the device now; works in airplane mode. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'كلّ شيء على جهازك الآن؛ يعمل في وضع الطيران.'**
  String get onboardingCoreReadyBody;

  /// Core-preparation fail-closed heading — could not verify the muṣḥaf. Calm, non-blaming, no exclamation. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحقّق من المصحف'**
  String get onboardingCoreIntegrityFailureTitle;

  /// Core-preparation fail-closed body — the files did not match, so the text is not shown to preserve its accuracy (R1, §11.1.1). Honest, never punitive; no skip is offered. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'لم تتطابق ملفات المصحف، فلا يُعرَض النصّ حفاظًا على دقّته.'**
  String get onboardingCoreIntegrityFailureBody;

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

  /// Screen-reader label for one juz coverage cell, composing the juz numeral and its held/not-held state. Both parts arrive ALREADY localized — {juz} pre-formatted in locale numerals (numberFormatFor) and {state} from onboardingHeld/onboardingNotHeld — so the composition (and its separator) live in ARB, never concatenated in a widget (engineering 12 §4). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'{juz} — {state}'**
  String onboardingCoverageCellLabel(String juz, String state);

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

  /// State-chip label: the page is due for revision (never-color-alone redundant encoding, E08-T06 — paired with a distinct shape glyph). Calm, neutral; no guilt. Consumed by E12/E15. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'مستحقة'**
  String get stateDue;

  /// State-chip label: the page is weak / needs strengthening — never 'failing'/'lost', never 'safe to drop'. Paired with a distinct shape glyph (not colour alone). Consumed by E12/E15. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'ضعيفة'**
  String get stateWeak;

  /// State-chip label: a teacher (talaqqī) sign-off is recorded for the page. Servant-to-the-teacher register; no score/badge. Paired with a distinct shape glyph. Consumed by E12/E16. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'معتمدة من المعلّم'**
  String get stateSignedOff;

  /// Page-card state, spoken in the merged Semantics phrase: the page has been revised in TODAY'S session — explicitly today-scoped and calm. NEVER 'mastered'/'done forever'/'safe to drop' — a page is never safe to stop revising (C-019, PRD §7.12). Paired with a distinct check glyph, never colour alone. Consumed by E12. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تمت مراجعتها اليوم'**
  String get stateDone;

  /// Page-card state, spoken in the merged Semantics phrase: the page is locked by a teacher's manual_lock — a human (talaqqī) override, servant-to-the-teacher, never an alarm or punishment. Paired with a distinct lock glyph, never colour alone. Consumed by E12/E16. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'مقفلة من المعلّم'**
  String get stateLocked;

  /// Screen-reader phrase for the AGAIN grade button — verdict + consequence. The consequence is the CALM 'for review soon': a located weak join to revisit, NEVER 'you failed'/'lost the page' (C-003). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'احتجت إلى مساعدة — للمراجعة قريباً'**
  String get gradeAgainSemantics;

  /// Screen-reader phrase for the HARD grade — verdict + calm consequence (revisited sooner). Never shame. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'أخطاء يسيرة — للمراجعة عن قرب'**
  String get gradeHardSemantics;

  /// Screen-reader phrase for the GOOD grade — verdict + calm consequence (kept on its usual schedule). No praise/celebration (C-045). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تلاوة سليمة — في موعدها'**
  String get gradeGoodSemantics;

  /// Screen-reader phrase for the EASY grade — verdict + calm consequence (revision spaces out). NEVER 'mastered'/'safe to drop' (C-019). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'بلا تكلّف — بمباعدة أطول'**
  String get gradeEasySemantics;

  /// Calm hint shown when the grade band is disabled before the page is revealed (reveal-on-tap, E12) — styled as WAITING, not an error or a dead button (design 07 §6). 'Reveal the page to grade it.' PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'اكشف الصفحة لتقييمها'**
  String get gradeBandWaitingHint;

  /// Label for the teacher (talaqqī) sign-off Switch — 'Teacher present'. OFF by default. Servant-to-the-teacher (C-021, C-038). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'المعلّم حاضر'**
  String get teacherSignoffLabel;

  /// Autonomy-supportive supporting copy under the teacher sign-off Switch — 'for your teacher to confirm'. NEVER commanding ('you must have a teacher'); the app is servant, not authority (C-046). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'ليؤكّدها معلّمك'**
  String get teacherSignoffSupporting;

  /// Screen-reader prefix read before an evidence-certainty phrase, so the grade is conveyed as TEXT, never colour (science 11 §5, §7; C-047). 'Strength of the evidence:'. The label describes certainty ABOUT THE EVIDENCE, never about the user's own Quran. Consumed by E19. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'قوة الدليل: '**
  String get certaintyEvidencePrefix;

  /// Evidence-certainty lay phrase for grade [MA] (meta-analysis) — 'among the best-established findings in memory science' (science 11 §5). Describes the EVIDENCE only; NEVER 'proven'/a star/a percentage/a Quran-retention promise (C-016, C-017). Consumed by E19. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'من أرسخ نتائج علم الذاكرة'**
  String get certaintyMaPhrase;

  /// Evidence-certainty lay phrase shared by grades [RCT] and [EXP] — 'a single controlled study' (science 11 §5). Evidence only; no 'proven'/star/percentage. Consumed by E19. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'دراسة محكومة واحدة'**
  String get certaintyRctExpPhrase;

  /// Evidence-certainty lay phrase for grade [CS] — 'a classic foundational study' (science 11 §5). Evidence only. Consumed by E19. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'دراسة تأسيسية كلاسيكية'**
  String get certaintyCsPhrase;

  /// Evidence-certainty lay phrase for grade [OBS] — 'an observational / field study' (science 11 §5). Evidence only; calm, never a weakness to be ashamed of. Consumed by E19. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'دراسة ميدانية رصدية'**
  String get certaintyObsPhrase;

  /// Evidence-certainty lay phrase for grade [TEXT] — 'an expert review / algorithm documentation' (science 11 §5). Evidence only. Consumed by E19. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة خبير أو توثيق منهجي'**
  String get certaintyTextPhrase;

  /// Evidence-certainty lay phrase for grade [TRAD] — 'traditional scholarship, source named below' (science 11 §5). Named scholarship paired with its source; issues NO fiqh ruling and is NOT ranked above the empirical grades; defers to the teacher and the sanad (C-046, CLAIMS scope clause). Consumed by E19. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'علم نقلي، مصدره مذكور أدناه'**
  String get certaintyTradPhrase;

  /// Title of the always-reachable plain-words evidence-certainty legend (science 11 §3, §5). 'The strength of the evidence we rely on.' Consumed by E19. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'قوة الأدلة التي نستند إليها'**
  String get certaintyLegendTitle;

  /// The EMPATHY line that opens the missed-day catch-up banner (voice 11 §4 empathy→fact→path→choice). Calm, non-blaming acknowledgment — NEVER 'you're behind'/'you let this slip'/guilt. A missed gap is never a streak reset (C-042, C-043). Consumed by E12. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'لا حرج — لنتدارك بهدوء'**
  String get catchUpEmpathy;

  /// The honest-FACT line of the catch-up banner — 'N days passed without revision' (voice 11 §4). Neutral statement of fact, NEVER 'N days lost'/'you're behind'/shame (C-042). ICU plural with ALL SIX Arabic CLDR categories; {count} is locale-numeral-shaped downstream by the caller (intl #197). Consumed by E12. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لم تمضِ أيام دون مراجعة} one{مضى يوم واحد دون مراجعة} two{مضى يومان دون مراجعة} few{مضت {count} أيام دون مراجعة} many{مضى {count} يوماً دون مراجعة} other{مضى {count} يوم دون مراجعة}}'**
  String catchUpMissedDays(num count);

  /// The PATH line of the catch-up banner — 'a plan over N days that still completes your cycle' (voice 11 §4; PRD §7.9). Reassuring, the cycle still completes; FAR/manzil items are never dropped to shorten it. ICU plural, six Arabic categories; {count} locale-shaped downstream. Consumed by E12. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{خطة تُكمل دورتك} one{خطة ليوم واحد تُكمل دورتك} two{خطة ليومين تُكمل دورتك} few{خطة على {count} أيام تُكمل دورتك} many{خطة على {count} يوماً تُكمل دورتك} other{خطة على {count} يوم تُكمل دورتك}}'**
  String catchUpPlanLine(num count);

  /// Catch-up banner CHOICE — start the re-spread plan (the user-owned primary choice, never a mandate). Consumed by E12. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الخطة'**
  String get catchUpStartPlan;

  /// Catch-up banner CHOICE — adjust the plan. Invite, never command. Consumed by E12. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'عدّل الخطة'**
  String get catchUpAdjust;

  /// Catch-up banner CHOICE — defer / decide later. The user owns the choice; deferring is blameless. Consumed by E12. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get catchUpDefer;

  /// First-run empty state — the calm fact, framed as invitation, never shaming the absence (ui-empty-state). Consumed by E11/E12. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر مراجعتك هنا بعد أن تبدأ'**
  String get emptyFirstRunBody;

  /// First-run empty state — the one gentle next-step label (invitation into cold-start, owned by E11). NEVER 'come back tomorrow'/FOMO/urgency. Consumed by E11/E12. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get emptyFirstRunAction;

  /// All-done / nothing-due terminal state — one calm closing line in color.text.secondary, INFORMATIONAL, never confetti/streak/badge/exclamation/celebration (design 07 §1; PRD R3, C6). Today-scoped completion, never 'safe to drop'/'mastered' (C-019). Consumed by E12. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت مراجعة اليوم'**
  String get emptyAllDone;

  /// Reminder-row toggle label — a single daily reminder, OFF by default, one tap to opt in / silence (privacy 10 §9–§10). Consumed by E16/E18. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تذكير يومي'**
  String get reminderToggleLabel;

  /// Reminder-row time-picker label, shown only when the reminder is enabled; the time renders in the user's calendar + locale numerals (T01). Consumed by E16/E18. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'وقت التذكير'**
  String get reminderTimeLabel;

  /// Reminder-row optional catch-up-note toggle — framed as HELP, never blame ('N days lost'), never a streak (C-042, C-043). Fully optional and silenceable. Consumed by E16/E18. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه لطيف عند تراكم بضعة أيام'**
  String get reminderCatchUpNoteLabel;

  /// The one honest local-only line under the reminder row — a neutral reminder, silenceable anytime, nothing sent (no server/push, C-043). Calm, no guilt/fear/loss, no exclamation. Consumed by E16/E18. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تذكير محايد في وقت تختاره؛ يمكنك إسكاته في أي وقت — لا يُرسَل شيء'**
  String get reminderHonestLine;

  /// The SAFE primary action of the destructive-confirm gate — Cancel / Keep my data (the visually-primary, default-focused button; privacy 10 §9, §11). Never buried. Consumed by E16/E17. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'احتفظ ببياناتي'**
  String get destructiveKeepData;

  /// Erase-all concrete, irreversible consequence (privacy 10 §8) — what is erased, permanent, nothing recoverable elsewhere (no server). Never a bare 'Are you sure?', never 'you'll lose your hifz' fear-framing. Consumed by E16/E17. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'سيمحو هذا نهائياً جميع سجلات الحفظ لكل الملفات على هذا الجهاز؛ لا يمكن التراجع، ولأنه لا يوجد خادم فلا شيء قابل للاسترجاع في مكان آخر.'**
  String get destructiveEraseAllConsequence;

  /// Erase-all step-1 destructive trigger (advances to the second deliberate confirm). A plainer secondary affordance in the hard-to-reach top-start corner, never the bright/default button. Consumed by E16/E17. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'متابعة المحو'**
  String get destructiveEraseAllConfirm;

  /// Erase-all step-2 final consequence — the second deliberate gesture sized to the whole-device blast radius (privacy 10 §11). Consumed by E16/E17. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد أخير: سيُمحى كل شيء الآن نهائياً.'**
  String get destructiveEraseAllSecondConsequence;

  /// Erase-all step-2 destructive trigger — fires the confirmed intent only after the second deliberate gesture. Consumed by E16/E17. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'امحُ كل شيء نهائياً'**
  String get destructiveEraseAllSecondConfirm;

  /// Wipe-single-profile concrete, irreversible consequence (privacy 10 §8). Consumed by E16. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'سيمحو هذا نهائياً سجلات هذا الملف على هذا الجهاز؛ لا يمكن التراجع.'**
  String get destructiveWipeProfileConsequence;

  /// Wipe-single-profile destructive trigger (one consequence step — minimum gesture for its blast radius). Consumed by E16. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'امحُ هذا الملف'**
  String get destructiveWipeProfileConfirm;

  /// Abort-and-discard concrete, irreversible consequence (privacy 10 §8). Consumed by E11/E16. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'سيتجاهل هذا المسودة الحالية؛ لا يمكن التراجع.'**
  String get destructiveAbortConsequence;

  /// Abort-and-discard destructive trigger (one consequence step). Consumed by E11/E16. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل المسودة'**
  String get destructiveAbortConfirm;
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
