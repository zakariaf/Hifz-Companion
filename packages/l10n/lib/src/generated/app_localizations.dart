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

  /// E15 juz roll-up tile label. {juz} is an already locale-numeral, bidi-isolated token. PROVISIONAL — pending native + scholarly review.
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

  /// Calm landing line on the Mutashābihāt trainer: drilling similar passages side by side REDUCES confusing them — an aid to revision, never a claim of being 'cured'/'resolved'/'safe to drop', no number, no fiqh ruling. NEEDS scholarly + native fa/ckb review (E14-T11); ckb falls back to this until then.
  ///
  /// In ar, this message translates to:
  /// **'درّب على المواضع المتشابهة جنبًا إلى جنب ليقلّ الخلط بينها.'**
  String get mutashabihatTrainerIntro;

  /// Generic back / return affordance label.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get commonBack;

  /// Reveal affordance + Semantics label on a hidden drill branch: tap to reveal the muṣḥaf page AFTER reciting the continuation from memory (retrieval practice). NEEDS native fa/ckb review (E14-T11); ckb falls back to ar.
  ///
  /// In ar, this message translates to:
  /// **'اكشف الصفحة'**
  String get mutashabihatDrillReveal;

  /// Calm group position 'branch {position} of {total}'. Both are pre-formatted locale-numeral, bidi-isolated String tokens — never raw ints, never concatenated. No score/streak.
  ///
  /// In ar, this message translates to:
  /// **'{position} من {total}'**
  String mutashabihatDrillProgress(String position, String total);

  /// Quiet advance to the next sibling in the same drill session (back-to-back, no interstitial). NEEDS native fa/ckb review (E14-T11).
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get mutashabihatDrillNext;

  /// Calm terminal line after the last sibling — never a celebration, never 'cured'/'safe to drop'/'safe to stop'. NEEDS scholarly + native fa/ckb review (E14-T11).
  ///
  /// In ar, this message translates to:
  /// **'أتممتَ هذه المجموعة.'**
  String get mutashabihatDrillComplete;

  /// Objective-wording label for a mutashābihāt group of word-for-word identical passages. NEEDS native fa/ckb review (E14-T11).
  ///
  /// In ar, this message translates to:
  /// **'متطابقة'**
  String get mutashabihTypeIdentical;

  /// Objective-wording label for a near-identical mutashābihāt group (differ in a few words). NEEDS native fa/ckb review (E14-T11).
  ///
  /// In ar, this message translates to:
  /// **'شبه متطابقة'**
  String get mutashabihTypeNearIdentical;

  /// Objective-wording label for a structurally-parallel mutashābihāt group. NEEDS native fa/ckb review (E14-T11).
  ///
  /// In ar, this message translates to:
  /// **'متوازية البنية'**
  String get mutashabihTypeStructural;

  /// An āyah identity 'Surah S · Ayah A'. surah/ayah are pre-formatted locale-numeral, bidi-isolated String tokens — never raw ints. (Page+juz lands when reference data ships; bundle-first the hotspot row names the pair by āyah identity.) NEEDS native fa/ckb review (E14-T11).
  ///
  /// In ar, this message translates to:
  /// **'سورة {surah} · آية {ayah}'**
  String ayahRefLabel(String surah, String ayah);

  /// Screen-reader phrase for a confusion-hotspot row naming the pair + the drill action. first/second are āyah identities. Calm, never a score/guilt. NEEDS native fa/ckb review (E14-T11).
  ///
  /// In ar, this message translates to:
  /// **'كثيرًا ما تخلط بين {first} و{second} — انقر للتمرين'**
  String mutashabihatHotspotSemantic(String first, String second);

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

  /// Settings group header: display and presentation preferences (UI language, calendar, numerals, term-set, theme, font size, muṣḥaf edition). UI chrome, not religious copy. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'العرض'**
  String get settingsSectionDisplay;

  /// Settings group header: the revision-cycle preset, Pure-cycle mode, and daily time budget. Writes engine config only, never a retention dial. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'دورة المراجعة'**
  String get settingsSectionCycle;

  /// Settings group header: the one calm, opt-in, off-by-default daily reminder and the optional catch-up note (PRD §14). Local notifications only, no push/server, no guilt/fear/streak. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات'**
  String get settingsSectionReminders;

  /// Settings group header: device-local profiles (self, student, child) and the active-profile switcher. A profile is a typed display name only, with no account and no PII. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'الملفات الشخصية'**
  String get settingsSectionProfiles;

  /// Settings group header: local, offline backup export and restore, with no cloud and no account. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get settingsSectionBackup;

  /// Settings group header: app information and the offline science screen. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get settingsSectionAbout;

  /// Display-settings sub-group label above the UI-language picker (fa/ckb/ar). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguageLabel;

  /// Display-settings sub-group label above the theme picker (light/sepia/dark). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsThemeLabel;

  /// Display-settings sub-group label above the calendar-system picker. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'التقويم'**
  String get settingsCalendarLabel;

  /// Calendar-system option: Solar Hijri (Jalālī), the default for Persian. A display calendar only; never feeds scheduling. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'الهجري الشمسي'**
  String get calendarJalali;

  /// Calendar-system option: lunar Hijri, Umm al-Qurā civil reckoning. A civil-courtesy display date that issues no observance ruling (the standing caveat is shown). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'الهجري (أم القرى)'**
  String get calendarUmmAlQura;

  /// Calendar-system option: Gregorian. A display calendar only. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'الميلادي'**
  String get calendarGregorian;

  /// Live preview under the calendar picker: today's date rendered in the chosen calendar (a display transform over the unchanged stored instant). {date} is a pre-formatted, bidi-isolated date string. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'اليوم: {date}'**
  String settingsCalendarToday(String date);

  /// Display-settings sub-group label above the term-set (regional sabaq/sabqi/manzil vocabulary) picker. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'المصطلحات'**
  String get settingsTermSetLabel;

  /// Term-set region option: the general/default vocabulary set. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get termSetRegionOther;

  /// Term-set region option: the Levant (al-Shām) vocabulary set. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'الشام'**
  String get termSetRegionLevant;

  /// Term-set region option: the Indian-subcontinent vocabulary set (e.g. dhor for far-revision). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'شبه القارة'**
  String get termSetRegionSubcontinent;

  /// Caption shown under the term-set picker when the UI language is Kurdish (Sorani): the ckb terms are provisional pending native-speaker + scholarly review (PRD §13.4); no fiqh ruling. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'المصطلحات الكوردية مبدئية، بانتظار مراجعة متحدث أصلي وعالم.'**
  String get termSetProvisionalNote;

  /// Display-settings sub-group label above the muṣḥaf/riwāyah picker (names the edition and states the riwāyah explicitly; never calls it 'the Quran' in the absolute). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'المصحف'**
  String get settingsMushafLabel;

  /// Title of the Profiles screen — the device-local multi-profile switcher + create. No account, no PII beyond the typed display name (PRD §17). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'الملفات الشخصية'**
  String get profilesScreenTitle;

  /// Settings Profiles row subtitle: tap to switch or manage device-local profiles. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'بدّل أو أدِر الملفات الشخصية'**
  String get profilesManageSubtitle;

  /// Button to create a new device-local profile (a typed display name + role; no PII). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ملف'**
  String get profilesAddButton;

  /// Text-field hint for a new profile's display name — the only PII. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الظاهر'**
  String get profilesNameHint;

  /// Accessibility/visual label marking the currently active profile in the switcher (selection is shape+label, never colour alone). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get profilesActiveLabel;

  /// Profile role: the device owner (self). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'أنا'**
  String get profileRoleSelf;

  /// Profile role: a student a teacher signs off in halaqa mode. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'طالب'**
  String get profileRoleStudent;

  /// Profile role: a parent-managed child profile (calm, no gamification). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'طفل'**
  String get profileRoleChild;

  /// Profile row menu action: rename a profile (change the display name). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تسمية'**
  String get profilesRename;

  /// Profile row menu action: delete a profile (opens the cancel-primary confirmation). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get profilesDelete;

  /// The plainer, secondary destructive trigger label in the delete-profile confirmation (top-start corner; the safe Keep action is the primary, focused button). Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'حذف الملف'**
  String get deleteProfileConfirm;

  /// The concrete, irreversible consequence in the delete-profile confirmation: it names the profile and states the loss honestly — no fear/loss leverage, no fiqh ruling; explicitly distinct from erase-all (E17). {name} is the bidi-isolated display name. Best-effort fa/ckb pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'حذف {name} يزيل سجل مراجعته نهائيًا. لا يمكن التراجع، وهذا غير مسح كل البيانات.'**
  String deleteProfileConsequence(String name);

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

  /// Optional 'when memorized' invitation under a juz confidence row — genuinely skippable, never a required field or a nag (E11-T07). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'متى حفظته؟ (اختياري)'**
  String get whenMemorizedOptionalLabel;

  /// Shows the chosen 'when memorized' date. {date} arrives ALREADY converted to the user's calendar and digit-remapped + bidi-isolated (CalendarPresenter) — never concatenated/re-formatted here. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ: {date}'**
  String whenMemorizedSetLabel(String date);

  /// Clears the optional 'when memorized' date back to the skipped state. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get whenMemorizedClear;

  /// Coarse 'when memorized' band: within this year. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'هذا العام'**
  String get staleBandThisYear;

  /// Coarse 'when memorized' band: about one to two years ago. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'قبل سنة أو سنتين'**
  String get staleBandOneToTwoYears;

  /// Coarse 'when memorized' band: about three to five years ago (digits in the locale numeral set). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'قبل ٣ إلى ٥ سنوات'**
  String get staleBandThreeToFiveYears;

  /// Coarse 'when memorized' band: more than five years ago (digits in the locale numeral set). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'أكثر من ٥ سنوات'**
  String get staleBandMoreThanFiveYears;

  /// Cycle-preset step heading (calm noun). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'دورة المراجعة'**
  String get onboardingCyclePresetStepTitle;

  /// Cycle-preset step helper — a named tradition a teacher recognises, not a retention dial; pick a named preset or Custom. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'إيقاعٌ يعرفه معلّمك — اختره أو خصّصه.'**
  String get onboardingCyclePresetStepBody;

  /// Label for the daily revision time-budget stepper. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'وقت المراجعة اليومي'**
  String get dailyBudgetLabel;

  /// The daily budget rendered as minutes — ICU plural with all six Arabic CLDR categories. {count} is locale-numeral-shaped downstream (intl #197). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا دقائق} one{دقيقة واحدة} two{دقيقتان} few{{count} دقائق} many{{count} دقيقة} other{{count} دقيقة}}'**
  String dailyBudgetMinutes(int count);

  /// Custom-cycle field: far-cycle length in days (the cycle ceiling). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'طول الدورة (أيام)'**
  String get customFarCycleDays;

  /// Custom-cycle field: near-window size in juz. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'نافذة القريب (أجزاء)'**
  String get customNearWindowJuz;

  /// Custom-cycle field: new lines introduced per day. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'أسطر جديدة يومياً'**
  String get customNewLinesPerDay;

  /// The calm placement-commit summary (C-009): the schedule is ready; we revise everything once, then adjust. NOT a celebration — no streak/badge/%/readiness verdict. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'جدولك جاهز — سنراجع كل ما تحفظه مرّة، ثم نضبط حسب تلاوتك.'**
  String get onboardingPlacementSummary;

  /// Calm, non-blaming message when the placement commit fails (nothing was saved); paired with a Retry. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ إعدادك.'**
  String get onboardingPlacementError;

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

  /// The screen-reader container label for the Today list ('Revise today') — names the daily revision surface; calm, never a scoreboard or count. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة اليوم'**
  String get todaySemanticTitle;

  /// The Far section header on the Today list — the far/manzil revision group, recited first. TERM-SET vocabulary (scholar-reviewed, swappable by region); distinct from the per-row track chip. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, levant{المنزل} subcontinent{الدور} other{المنزل}}'**
  String sectionFarManzil(String region);

  /// The Near section header on the Today list — the near/sabqi revision group. TERM-SET vocabulary. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{السبقي}}'**
  String sectionNearSabqi(String region);

  /// The New section header on the Today list — today's new sabaq lesson group, recited last. TERM-SET vocabulary. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'{region, select, other{السبق}}'**
  String sectionNewSabaq(String region);

  /// One calm informational line on Today when the chosen scope exceeds the daily time budget — states the fact and invites a choice; never an alarm, never guilt, never silently dropping pages (FAR/manzil is always kept). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'اليوم أوسع من وقتك المتاح. لك أن تختار:'**
  String get budgetOverflowLine;

  /// An autonomy-supportive choice on the budget-feedback line: raise the daily time budget. A quiet option, not a command. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'زيادة وقت المراجعة اليومي'**
  String get budgetRaiseBudget;

  /// An autonomy-supportive choice on the budget-feedback line: lengthen the revision cycle — a wider cycle is less daily work for the same lasting result, not laziness (CLAIMS C-008). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'إطالة مدّة الدورة'**
  String get budgetLengthenCycle;

  /// An autonomy-supportive choice on the budget-feedback line: defer today's new sabaq so revision fits — a deferred new lesson, never a dropped revision page. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تأجيل السبق الجديد'**
  String get budgetPauseNewSabaq;

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

  /// The calm middle decay band on a Today row — a page that is holding (between solid/steady and needs-revision), neither alarming nor 'safe to drop'. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'مستقرّ'**
  String get decayHolding;

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

  /// The calm exit/abort on the recite screen's leading (start) edge — leaves the recite flow without grading. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get reciteExit;

  /// The tap-to-reveal affordance on a masked line — reveal happens only AFTER the recall attempt (no teleprompter). PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'اكشف السطر التالي'**
  String get reciteRevealHint;

  /// The screen-reader label for a revealed line's stumble-mark toggle. {line} is the 1-based line number pre-formatted in locale numerals. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'السطر {line}'**
  String reciteStumbleLineLabel(String line);

  /// Undo a just-committed grade — a fat-fingered sacred-text grade is recoverable; reverses through the single write path. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get reciteUndo;

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

  /// The daily local-notification body (PRD §14) — ONE calm neutral line, 'Your revision for today is ready.' Never guilt/fear/loss, no countdown, no exclamation, no streak (C-043; voice 11 §3 'Daily session ready' row). Fired by flutter_local_notifications, local only; the scheduler is handed this already-localized string. Consumed by E18. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'مراجعتك لليوم جاهزة.'**
  String get reminderNotificationBody;

  /// The calm, non-obstructive denied state shown when the reminder is on but the OS blocks notifications (E18-T08; privacy 10 §6/§11). Explains and points to system settings — never forces, nags, or re-prompts. No guilt/fear, no exclamation, no mandate ('you can', not 'you must'). Consumed by E18. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات مُعطَّلة لهذا التطبيق في إعدادات جهازك. يمكنك تفعيلها هناك لتصلك هذه التذكيرة.'**
  String get reminderPermissionDeniedNote;

  /// The OPTIONAL catch-up notification body (PRD §14; E18-T09), used in place of the daily line ONLY when the catch-up note is on AND a missed-gap backlog exists. Framed as HELP — a calm plan to resume — never blame, never 'N days lost', never a countdown/streak/exclamation (C-042, C-043; voice 11 §4 empathy-then-path). The re-spread plan itself is shown in-app (E12); this only invites the user back. Consumed by E18. PROVISIONAL — needs native + scholarly review; best-effort fa/ckb.
  ///
  /// In ar, this message translates to:
  /// **'خطة هادئة لاستئناف مراجعتك جاهزة.'**
  String get reminderCatchUpBody;

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

  /// Title of the muṣḥaf reader's jump-to picker (E13-T04). PROVISIONAL — best-effort fa/ckb, native + scholarly review in T09.
  ///
  /// In ar, this message translates to:
  /// **'الانتقال إلى'**
  String get mushafJumpTitle;

  /// Jump-to unit label: juz. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'جزء'**
  String get mushafUnitJuz;

  /// Jump-to unit label: ḥizb. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'حزب'**
  String get mushafUnitHizb;

  /// Jump-to unit label: sūrah. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'سورة'**
  String get mushafUnitSurah;

  /// Jump-to unit label: page. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'صفحة'**
  String get mushafUnitPage;

  /// Reader toggle: show the weak-line diagnostic overlay. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'الأسطر الضعيفة'**
  String get mushafOverlayWeakLines;

  /// Reader toggle: show the mutashābihāt-anchor overlay. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'المتشابهات'**
  String get mushafOverlayMutashabihat;

  /// Reader zoom-in (+) control. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'تكبير'**
  String get mushafZoomIn;

  /// Reader zoom-out (−) control. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'تصغير'**
  String get mushafZoomOut;

  /// Reader theme: light. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get mushafThemeLight;

  /// Reader theme: sepia. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'بنّي'**
  String get mushafThemeSepia;

  /// Reader theme: dark. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get mushafThemeDark;

  /// Reader About/Credits entry + sheet title. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'حول هذا المصحف'**
  String get mushafAboutTitle;

  /// About/Credits: Tanzil text attribution. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'النص العثماني: تنزيل (tanzil.net) — منسوخ حرفياً ومنسوب، CC BY 3.0.'**
  String get mushafAboutTanzil;

  /// About/Credits: QUL page-layout attribution. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'تخطيط الصفحات: QUL.'**
  String get mushafAboutQul;

  /// About/Credits: KFGQPC fonts attribution. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'الخطوط: مجمع الملك فهد (KFGQPC) — مُعاد توزيعها دون تعديل.'**
  String get mushafAboutFonts;

  /// About/Credits: byte-for-byte SHA-256 checksum guarantee. PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'يُتحقَّق من النص ومن خط كل صفحة ببصمة SHA-256 مثبَّتة قبل عرضها؛ وأي ملف غير مُتحقَّق منه يُرفَض.'**
  String get mushafAboutChecksum;

  /// About/Credits: offline + no-microphone covenant (C-048). PROVISIONAL — best-effort fa/ckb, review in T09.
  ///
  /// In ar, this message translates to:
  /// **'يعمل التطبيق دون اتصال بالكامل بعد التنزيل الأول المُتحقَّق منه، ولا يسجّل صوتك.'**
  String get mushafAboutOffline;

  /// E15 heat-map band label: a strongly-retained page (calm state, never a trophy). PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'محكمة'**
  String get progressBandStrong;

  /// E15 heat-map band label: a well-retained page. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'جيدة'**
  String get progressBandGood;

  /// E15 heat-map band label: a softening page (approaching due). Calm, never alarming. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'تَلين'**
  String get progressBandFair;

  /// E15 heat-map band label: a page ready for revision (decayed past target). Loss-prevention register, never 'failing'. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'للمراجعة'**
  String get progressBandWeak;

  /// E15 heat-map band label: a most-decayed memorized page (the muted neutral end). PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'خافتة'**
  String get progressBandFaded;

  /// E15 heat-map cell label for a page not yet part of the user's hifz (faded). PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'لم تبدأ'**
  String get progressNotStarted;

  /// E15 heat-map cell value placeholder when there is no retrievability to show (a non-memorized page). A dash glyph.
  ///
  /// In ar, this message translates to:
  /// **'—'**
  String get progressNoValue;

  /// E15 retrievability percentage. {pct} is an already locale-numeral, bidi-isolated token (localeDigits + isolateLtr) — never a raw int. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'{pct}٪'**
  String progressPercent(String pct);

  /// E15 page-detail retrievability RANGE (never a single false-precise percent). {low}/{high} are already locale-numeral, bidi-isolated tokens. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'{low}–{high}٪'**
  String progressDetailRange(String low, String high);

  /// E15 page-detail basis: an estimate from the cold-start prior, never recited (honest about prediction). PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'تقدير — لم تُتلَ بعد'**
  String get progressDetailRangeEstimated;

  /// E15 page-detail retrievability range from self-rating. {range} is the already-built progressDetailRange token. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'نحو {range}، من تقييمك الذاتي'**
  String progressDetailRangeSelf(String range);

  /// E15 page-detail retrievability range confirmed by a teacher sign-off. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'نحو {range}، بتأكيد معلّمك'**
  String progressDetailRangeTeacher(String range);

  /// E15 page-detail next-due line. {date} is the already-localized CalendarPresenter date label. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'المراجعة القادمة: {date}'**
  String progressNextDue(String date);

  /// E15 page-detail: no scheduled revision yet. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'لا موعد مراجعة محدّد بعد'**
  String get progressNoNextDue;

  /// E15 page-detail recent review_log history heading. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'آخر المراجعات'**
  String get progressHistoryTitle;

  /// E15 page-detail: no review history yet (calm, never a nag). PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'لا مراجعات مسجّلة بعد'**
  String get progressNoHistory;

  /// E15 page-detail history row: a localized date and the grade label. {date} already localized, {grade} a grade label. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'{date} · {grade}'**
  String progressHistoryRow(String date, String grade);

  /// E15 empty/first-run Progress state title (welcoming, never guilt). PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'خريطة حفظك'**
  String get progressEmptyTitle;

  /// E15 empty Progress body: the map fills as pages are held and revised. Calm, no streaks/pressure. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'تمتلئ هذه الخريطة بصفحات حفظك وتُظهر بهدوء أين يحتاج قرآنك إلى مراجعة.'**
  String get progressEmptyBody;

  /// E15 weakest-pages list heading ('where to look first') — informational, surfaces the weak link, never shaming. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ من هنا'**
  String get progressWeakestTitle;

  /// E15 upcoming-load forecast heading (a calm planning aid, never a deadline pile). PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'الأيام القادمة'**
  String get progressForecastTitle;

  /// E17 backup card: states BOTH halves of ownership — a local file the app moves nowhere, and the user holds the only copy (no cloud). PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'النسخة الاحتياطية ملفّ تحتفظ به أنت على هذا الجهاز؛ لا يرسله التطبيق إلى أي مكان، ولأنه لا توجد سحابة فأنت صاحب النسخة الوحيدة.'**
  String get backupOwnershipLine;

  /// E17 backup status line when no backup has been made — a neutral fact, never a scold. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نسخة احتياطية بعد.'**
  String get backupNoBackupYet;

  /// E17 backup card: the export (save-a-backup) action label. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'حفظ نسخة احتياطية'**
  String get backupExportAction;

  /// E17 backup card: the import (restore-from-a-file) action label. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'الاستعادة من ملف'**
  String get backupImportAction;

  /// E17 erase entry-point label (opens the two-step confirmation). PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'محو كل البيانات'**
  String get eraseAllDataAction;

  /// E17 export progress note — real CPU/crypto work, never a fake sync. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحضير النسخة الاحتياطية…'**
  String get backupPreparing;

  /// E17 export failure note. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحضير النسخة الاحتياطية.'**
  String get backupExportFailed;

  /// E17 restore success note — quiet, no fanfare. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'تمت الاستعادة.'**
  String get backupRestored;

  /// E17 cross-muṣḥaf refusal (R2) — refused clearly, never coerced. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'أُنشئت هذه النسخة لمصحف مختلف، فلا يمكن استعادتها هنا.'**
  String get backupCrossMushaf;

  /// E17 import: prompt title for an encrypted backup's password. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة سر النسخة الاحتياطية'**
  String get backupPassphrasePromptTitle;

  /// E17 password field hint. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'كلمة السر'**
  String get backupPassphraseHint;

  /// E17 import: unlock-with-password action. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'فتح'**
  String get backupUnlockAction;

  /// E17 restore error: not a Hifz backup file. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'هذا الملف ليس نسخة احتياطية لحِفظ.'**
  String get backupErrorNotBackup;

  /// E17 restore error: the backup is newer than this app version. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'أُنشئت هذه النسخة بإصدار أحدث من التطبيق؛ يُرجى التحديث لفتحها.'**
  String get backupErrorNewer;

  /// E17 restore error: integrity check failed (damaged/truncated). PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'هذا الملف تالف أو غير مكتمل.'**
  String get backupErrorDamaged;

  /// E17 restore error: wrong password or corrupt ciphertext — indistinguishable. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'كلمة السر غير صحيحة، أو الملف تالف.'**
  String get backupErrorWrongPassword;

  /// E17 restore error: malformed payload. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت قراءة هذا الملف.'**
  String get backupErrorUnreadable;

  /// E17 export sheet: the no-recovery tradeoff as a CHECKABLE FACT, empathy-then-fact, never 'your data is safe'. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'إذا فقدت هذا الهاتف وفقدت ملف النسخة الاحتياطية، فلن يمكن استرجاع سجلك؛ لا توجد سحابة ولا حساب يستعيده.'**
  String get backupNoRecoveryTradeoff;

  /// E17 export sheet: the optional-encryption switch (protective default on). PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'تشفير هذه النسخة'**
  String get backupEncryptToggle;

  /// E17 encryption one-line explanation. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'يقفل الملف بكلمة سر تملكها وحدك.'**
  String get backupEncryptOneLiner;

  /// E17 export sheet: a forgotten passphrase is unrecoverable; never stored. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'إن نسيت كلمة السر فلن يمكن فتح الملف؛ ولا تُحفظ في أي مكان.'**
  String get backupPassphraseUnrecoverable;

  /// E17 export sheet: plain honesty that an unencrypted backup is readable by anyone. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'النسخة غير المشفّرة يمكن لأي من يفتح الملف قراءتها.'**
  String get backupUnencryptedReadable;

  /// E17 export sheet: the confirm-and-save action. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'حفظ النسخة'**
  String get backupSaveAction;

  /// E17 restore: the merge option label (teacher↔student transfer). PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'الإضافة إلى سجلي'**
  String get backupMergeOption;

  /// E17 restore: merge consequence — adds, keeps both. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'تضيف المراجعات المستوردة إلى سجلك الحالي مع الإبقاء على الاثنين.'**
  String get backupMergeConsequence;

  /// E17 restore: the replace option label. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'استبدال كل البيانات'**
  String get backupReplaceOption;

  /// E17 restore: replace consequence — wipes and rebuilds from the file. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'تستبدل كل البيانات الموجودة الآن في رفيق الحفظ بمحتوى الملف.'**
  String get backupReplaceConsequence;

  /// E17 erase gate: concrete irreversible consequence; any backup file becomes the only copy. PROVISIONAL — pending native + scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'يمحو هذا نهائيًا كل ملف شخصي وكل سجل مراجعة على هذا الجهاز. وأي ملف نسخة احتياطية حفظته يصبح حينها النسخة الوحيدة الباقية. لا يمكن التراجع.'**
  String get eraseConsequence;

  /// E17 erase gate: step-1 destructive trigger label. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'محو كل شيء'**
  String get eraseConfirmFirst;

  /// E17 erase gate: the SAFE primary (cancel) label. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'الإبقاء على بياناتي'**
  String get eraseKeepData;

  /// E17 erase gate: step-2 consequence. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'هذا نهائي ولا يمكن التراجع عنه.'**
  String get eraseConsequenceSecond;

  /// E17 erase gate: step-2 destructive trigger label. PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'محو الآن'**
  String get eraseConfirmSecond;

  /// E19 science screen title + the Settings/About nav row. Calm, no marketing.
  ///
  /// In ar, this message translates to:
  /// **'العِلم الذي نتبعه'**
  String get scienceTitle;

  /// E19 science screen intro: renders the sourced register; no retention promise (C-025/C-047). PROVISIONAL.
  ///
  /// In ar, this message translates to:
  /// **'كلُّ ما هنا مبنيٌّ على مصدرٍ مذكورٍ ودرجةِ قوّة، نعرضه لتطمئنّ إلى ما يقوم عليه التطبيق. ليس وعدًا بشأن حِفظك، بل بيانٌ لِما نستند إليه.'**
  String get scienceIntro;

  /// E19 expansion header for a claim's named source(s) + grade.
  ///
  /// In ar, this message translates to:
  /// **'الدليل'**
  String get scienceEvidenceLabel;

  /// E19 label above a claim's on-device citation list.
  ///
  /// In ar, this message translates to:
  /// **'المصادر'**
  String get scienceSourcesLabel;

  /// E19 note on a [TRAD]/methodology row awaiting named scholarly sign-off (science doc §8; PRD §21).
  ///
  /// In ar, this message translates to:
  /// **'بحاجة إلى مراجعة علمية'**
  String get scienceNeedsReview;

  /// E19 external-link hint: the optional source URL leaves the app; harmless offline.
  ///
  /// In ar, this message translates to:
  /// **'يُفتح في متصفّحك'**
  String get scienceOpensInBrowser;

  /// E19 CLAIMS group A header.
  ///
  /// In ar, this message translates to:
  /// **'الذاكرة والنسيان'**
  String get scienceGroupA;

  /// E19 CLAIMS group B header.
  ///
  /// In ar, this message translates to:
  /// **'المباعدة والجدولة'**
  String get scienceGroupB;

  /// E19 CLAIMS group C header (engine math, glossed plainly).
  ///
  /// In ar, this message translates to:
  /// **'كيف يعمل جدول المراجعة'**
  String get scienceGroupC;

  /// E19 CLAIMS group D header (retrieval practice).
  ///
  /// In ar, this message translates to:
  /// **'الاستظهار من الذاكرة'**
  String get scienceGroupD;

  /// E19 CLAIMS group E header (interference).
  ///
  /// In ar, this message translates to:
  /// **'المتشابهات'**
  String get scienceGroupE;

  /// E19 CLAIMS group F header (serial recall / the page unit).
  ///
  /// In ar, this message translates to:
  /// **'الصفحة وحدةً واحدة'**
  String get scienceGroupF;

  /// E19 CLAIMS group G header (overlearning / lifelong retention).
  ///
  /// In ar, this message translates to:
  /// **'الرسوخ مدى العمر'**
  String get scienceGroupG;

  /// E19 CLAIMS group H header (traditional methodology; sect-neutral, no ruling).
  ///
  /// In ar, this message translates to:
  /// **'المنهج التقليدي'**
  String get scienceGroupH;

  /// E19 CLAIMS group I header (motivation without coercion).
  ///
  /// In ar, this message translates to:
  /// **'الدافع بلا ضغط'**
  String get scienceGroupI;

  /// E19 CLAIMS group J header (cross-cutting honesty & privacy).
  ///
  /// In ar, this message translates to:
  /// **'الصدق والخصوصية'**
  String get scienceGroupJ;

  /// C-001 [EXP/CS]: Memory fades on a predictable curve — steep at first, then slowly.
  ///
  /// In ar, this message translates to:
  /// **'الذاكرة تخفت وفق منحنًى متوقَّع: سريعًا في البداية ثم ببطء.'**
  String get scienceClaimC001Headline;

  /// C-002 [EXP/TEXT]: A 'forgotten' page is not lost — re-reciting is far cheaper than first memorizing.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة التي «نسيتها» ليست ضائعة؛ إعادةُ تسميعها أيسرُ بكثير من حفظها أوّل مرّة.'**
  String get scienceClaimC002Headline;

  /// C-003 [EXP]: A single stumble does not mean you've lost the page.
  ///
  /// In ar, this message translates to:
  /// **'تعثُّرٌ واحد لا يعني أنّك فقدتَ الصفحة.'**
  String get scienceClaimC003Headline;

  /// C-004 [TEXT/MA]: A night's sleep helps fix what you revised today into lasting memory.
  ///
  /// In ar, this message translates to:
  /// **'نومُ الليلة يُعين على تثبيت ما راجعتَه اليوم في الذاكرة الراسخة.'**
  String get scienceClaimC004Headline;

  /// C-004 honest caveat: the app schedules in whole days and does not track sleep.
  ///
  /// In ar, this message translates to:
  /// **'يجدول التطبيق بالأيام كاملةً، ولا يتتبّع نومك.'**
  String get scienceClaimC004Caveat;

  /// C-005 [OBS]: Deeply, repeatedly recited material can reach a near-flat retention plateau lasting decades.
  ///
  /// In ar, this message translates to:
  /// **'ما يُسمَّع بعمقٍ وتَكرارٍ يبلغ مستوًى شبهَ ثابتٍ من الرسوخ يدوم عقودًا.'**
  String get scienceClaimC005Headline;

  /// C-006 [MA]: Spaced revision retains far better than re-reading in one sitting.
  ///
  /// In ar, this message translates to:
  /// **'المراجعةُ بفواصلَ متباعدةٍ تُرسِّخ أكثرَ بكثيرٍ من القراءة المتكرِّرة في جلسةٍ واحدة.'**
  String get scienceClaimC006Headline;

  /// C-007 [MA/EXP]: The best gap grows as a page strengthens — daily, then weekly, then monthly.
  ///
  /// In ar, this message translates to:
  /// **'أفضلُ فاصلٍ بين المراجعات يطول كلما رسخت الصفحة: يوميًّا، ثم أسبوعيًّا، ثم شهريًّا.'**
  String get scienceClaimC007Headline;

  /// C-008 [CS]: Wider gaps mean less daily work for the same lasting result — not laziness.
  ///
  /// In ar, this message translates to:
  /// **'الفواصلُ الأوسع تعني عملًا يوميًّا أقلَّ لنتيجةٍ راسخةٍ ذاتِها، لا تكاسلًا.'**
  String get scienceClaimC008Headline;

  /// C-009 [EXP]: Reviewing a little early costs minutes; too late can lose it — so we err early.
  ///
  /// In ar, this message translates to:
  /// **'مراجعةُ الصفحة مبكِّرًا قليلًا تكلِّف دقائق، والتأخُّر قد يُفقِدها؛ لذا نميل إلى التبكير.'**
  String get scienceClaimC009Headline;

  /// C-010 [TEXT]: The app models how recall fades with a standard, open spaced-repetition curve.
  ///
  /// In ar, this message translates to:
  /// **'يُحاكي التطبيقُ خفوتَ الاستذكار بمنحنى تكرارٍ متباعدٍ قياسيٍّ ومفتوح.'**
  String get scienceClaimC010Headline;

  /// C-010 honest caveat: the constants are a starting prior tuned from the user's own logs (no ML, no network).
  ///
  /// In ar, this message translates to:
  /// **'هذه الثوابتُ تقديرٌ مبدئيٌّ يُضبَط من مراجعاتك، لا قاعدةً جامدة.'**
  String get scienceClaimC010Caveat;

  /// C-011 [TEXT/EXP]: Each on-time review makes a page hold longer before it needs revising again.
  ///
  /// In ar, this message translates to:
  /// **'كلُّ مراجعةٍ في وقتها تجعل الصفحةَ تصمد أطولَ قبل أن تحتاج مراجعةً جديدة.'**
  String get scienceClaimC011Headline;

  /// C-012 [TEXT/EXP]: Reviewing a page when slightly weaker strengthens it more than while still fresh.
  ///
  /// In ar, this message translates to:
  /// **'مراجعةُ الصفحة وهي أضعفُ قليلًا تقوّيها أكثرَ من مراجعتها وهي ما تزال طريّة.'**
  String get scienceClaimC012Headline;

  /// C-013 [EXP]: Spreading revision across days and nights holds better than cramming.
  ///
  /// In ar, this message translates to:
  /// **'توزيعُ المراجعة على أيّامٍ (ولياليها) يثبُت أكثرَ من حشرها في جلسةٍ واحدة.'**
  String get scienceClaimC013Headline;

  /// C-014 [OBS]: The traditional cycle already is spaced repetition; the app only re-orders within it.
  ///
  /// In ar, this message translates to:
  /// **'دورةُ المراجعة التقليدية هي أصلًا تكرارٌ متباعد؛ والتطبيقُ يعيد الترتيبَ داخلها فحسب.'**
  String get scienceClaimC014Headline;

  /// C-016 [EXP/TRAD]: Every page is guaranteed a revision at least once per chosen cycle — the trust clamp.
  ///
  /// In ar, this message translates to:
  /// **'كلُّ صفحةٍ مضمونةٌ مراجعةً مرّةً على الأقلّ في كلِّ دورةٍ تختارها — يمكن للتطبيق أن يراجعها أكثر، لا أقلّ.'**
  String get scienceClaimC016Headline;

  /// C-016 honest caveat: the guarantee is structural (cycle ceiling), not a probability.
  ///
  /// In ar, this message translates to:
  /// **'هذا ضمانٌ بنيويّ — كلُّ صفحةٍ تعود ضمن دورتك — لا احتمالٌ رقميّ.'**
  String get scienceClaimC016Caveat;

  /// C-017 [TEXT]: We don't chase a near-perfect retention number — it multiplies daily load.
  ///
  /// In ar, this message translates to:
  /// **'لا نُطارد رقمًا مثل «مئةٍ في المئة»؛ فذلك يضاعِف عملَك اليوميَّ ويكسِر الدورةَ التي تقدر عليها.'**
  String get scienceClaimC017Headline;

  /// C-017 honest caveat: stakes-tiered targets; the cost curve explodes toward 1.0.
  ///
  /// In ar, this message translates to:
  /// **'يستعمل التطبيقُ أهدافًا لطيفةً؛ ومطاردةُ رقمٍ قريبٍ من الكمال تُضاعِف عملَك اليوميّ.'**
  String get scienceClaimC017Caveat;

  /// C-018 [MA/EXP]: Reciting from memory protects your hifz far more than re-reading.
  ///
  /// In ar, this message translates to:
  /// **'التسميعُ عن ظهر قلبٍ يحفظ حِفظَك أكثرَ بكثيرٍ من إعادة القراءة.'**
  String get scienceClaimC018Headline;

  /// C-019 [EXP]: A strong page never becomes 'done' — only continued recitation keeps it (PRD §7.12).
  ///
  /// In ar, this message translates to:
  /// **'الصفحةُ القويّة لا تُصبح «منتهيةً» أبدًا؛ دوامُ التسميع وحده يُبقيها.'**
  String get scienceClaimC019Headline;

  /// C-020 [MA/EXP]: Let recitation finish before correcting — feedback works best after the full attempt.
  ///
  /// In ar, this message translates to:
  /// **'دَعِ التسميعَ يكتمل قبل التصحيح؛ فالتقويمُ أنفعُ بعد المحاولة كاملةً.'**
  String get scienceClaimC020Headline;

  /// C-021 [MA/TRAD]: A teacher who hears and corrects strengthens a page more than self-rating. PROVISIONAL — needs scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'المعلِّمُ الذي يسمع تسميعَك ويصحِّحه يقوّي الصفحةَ أكثرَ من تقييمك نفسَك.'**
  String get scienceClaimC021Headline;

  /// C-022 [EXP/OBS]: Re-reading feels best, but reciting from memory is what actually holds.
  ///
  /// In ar, this message translates to:
  /// **'إعادةُ القراءة تبدو الأنجع، لكنّ التسميعَ عن ظهر قلبٍ هو ما يثبُت فعلًا.'**
  String get scienceClaimC022Headline;

  /// C-023 [EXP]: Lasting hifz comes from re-reciting over time, not extra reps on memorizing day.
  ///
  /// In ar, this message translates to:
  /// **'الحِفظُ الراسخ يأتي من إعادة التسميع عبر الزمن، لا من تكرارٍ إضافيٍّ يومَ الحفظ.'**
  String get scienceClaimC023Headline;

  /// C-024 [EXP/OBS]: Reciting a page until effortless makes it far harder to lose.
  ///
  /// In ar, this message translates to:
  /// **'تسميعُ الصفحة حتى تَسهُلَ بلا كُلفةٍ يجعل فقدانَها أصعبَ بكثير.'**
  String get scienceClaimC024Headline;

  /// C-025 [OBS]: We can't promise you'll never forget a page — retention comes from regular revision, not a number.
  ///
  /// In ar, this message translates to:
  /// **'لا نَعِدُك بألَّا تنسى صفحةً أبدًا؛ فالرسوخُ يأتي من المراجعة المنتظمة لا من رقمٍ سحري.'**
  String get scienceClaimC025Headline;

  /// C-025 honest caveat: a grade describes the evidence, never the user's own Quran.
  ///
  /// In ar, this message translates to:
  /// **'الدرجةُ تصف قوّةَ الدليل، لا وعدًا بشأن حِفظك.'**
  String get scienceClaimC025Caveat;

  /// C-026 [CS]: Most forgetting comes from interference between similar passages, not the passing of time.
  ///
  /// In ar, this message translates to:
  /// **'أكثرُ النسيان من التداخل بين المواضع المتشابهة، لا من مرور الزمن وحده.'**
  String get scienceClaimC026Headline;

  /// C-027 [CS]: The more alike two passages, the more they interfere — repetition alone won't fix them.
  ///
  /// In ar, this message translates to:
  /// **'كلما زاد تشابهُ موضعين زاد تداخلُهما؛ ولذا لا يكفي التكرارُ وحده لتمييزهما.'**
  String get scienceClaimC027Headline;

  /// C-028 [EXP]: To stop confusing two similar passages, practice them back-to-back to tell them apart.
  ///
  /// In ar, this message translates to:
  /// **'لتكفَّ عن الخلط بين موضعين متشابهين، مرِّنهما متتاليين حتى تميِّز بينهما.'**
  String get scienceClaimC028Headline;

  /// C-029 [EXP]: Drilling only one of a confusable pair can weaken its twin — so we practice the whole group.
  ///
  /// In ar, this message translates to:
  /// **'تمرينُ أحد المتشابهين وحده قد يُضعِف قرينَه؛ لذا نمرِّن المجموعةَ كاملةً.'**
  String get scienceClaimC029Headline;

  /// C-030 [CS/TRAD/OBS]: Confusing similar verses tends to get harder the more of the Quran you hold. PROVISIONAL — needs scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'الخلطُ بين الآيات المتشابهة يزداد صعوبةً كلما زاد ما تحفظه من القرآن.'**
  String get scienceClaimC030Headline;

  /// C-031 [CS]: You memorize and recite in flowing pages, not separate cards — so we revise the same way.
  ///
  /// In ar, this message translates to:
  /// **'تحفظُ القرآنَ وتُسمِّعه صفحاتٍ متّصلةً لا بطاقاتٍ منفصلة؛ فنراجعه بالطريقة نفسها.'**
  String get scienceClaimC031Headline;

  /// C-032 [CS]: Re-reciting the same page in its fixed order is exactly what cements it.
  ///
  /// In ar, this message translates to:
  /// **'إعادةُ تسميع الصفحة نفسها بترتيبها الثابت هي ما يُرسِّخها تمامًا.'**
  String get scienceClaimC032Headline;

  /// C-033 [EXP]: We grade the whole page but pinpoint exactly where you stumbled.
  ///
  /// In ar, this message translates to:
  /// **'نقيِّمُ الصفحةَ كاملةً لكن نحدِّد بدقّةٍ موضعَ تعثُّرك.'**
  String get scienceClaimC033Headline;

  /// C-034 [TRAD]: Hifz revision is traditionally three tracks — sabaq, sabqi, manzil. PROVISIONAL — needs scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'تُنظَّم مراجعةُ الحِفظ تقليديًّا في ثلاثة مساراتٍ: الجديد (السبق)، والقريب (السبقي)، والبعيد (المنزل).'**
  String get scienceClaimC034Headline;

  /// C-035 [TRAD]: The decay axiom (meaning of Ṣaḥīḥ al-Bukhārī 5032), framed as methodology, never a threat. PROVISIONAL — needs scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'تحثُّ السنّةُ على دوام المراجعة: فالقرآنُ أسرعُ تفلُّتًا من الإبل في عُقُلها.'**
  String get scienceClaimC035Headline;

  /// C-036 [TRAD]: The seven manazil divide the Quran for a weekly khatm. PROVISIONAL — needs scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'المنازلُ السبعُ تقسِّم القرآنَ لخَتمةٍ أسبوعية: مراجعةُ كلِّ ما تحفظ مرّةً في الأسبوع على الأقلّ.'**
  String get scienceClaimC036Headline;

  /// C-037 [MA/TEXT]: The masters reached spaced, expanding-interval revision centuries before the experiments.
  ///
  /// In ar, this message translates to:
  /// **'بلَغ المتقنون المراجعةَ المتباعدةَ المتوسِّعةَ قبل قرونٍ من تأكيد التجارب لها.'**
  String get scienceClaimC037Headline;

  /// C-038 [TRAD]: The Quran is learned face-to-face from a teacher (talaqqi), in a chain to the Prophet ﷺ. PROVISIONAL — needs scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'يُتلقَّى القرآنُ ويُصحَّح مشافهةً عن معلِّمٍ (تلقّيًا)، بسندٍ متّصلٍ إلى النبيِّ ﷺ.'**
  String get scienceClaimC038Headline;

  /// C-039 [TRAD]: The tradition reviews the whole corpus periodically; the ʿarda precedent (Bukhārī 4998). PROVISIONAL — needs scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'يراجع التقليدُ كلَّ المحفوظ دوريًّا؛ فقد كان جبريلُ يعارض النبيَّ ﷺ بالقرآن كلَّ عام.'**
  String get scienceClaimC039Headline;

  /// C-040 [TRAD]: Traditional methods overlearn then cycle everything, rather than chase a number. PROVISIONAL — needs scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'تُفرِط الطرقُ التقليدية في إتقان النصِّ — مئاتُ التكرارات — ثم تُدوِّر كلَّ المحفوظ، لا أن تُلاحق رقمًا.'**
  String get scienceClaimC040Headline;

  /// C-041 [MA/EXP]: We deliberately avoid streaks, badges, and guilt — they don't build lasting habits and can undermine intrinsic motivation.
  ///
  /// In ar, this message translates to:
  /// **'نتجنّب عمدًا السلاسلَ والشاراتِ والشعورَ بالذنب: فالبحثُ يبيّن أنها لا تبني عادةً راسخة وقد تُضعِف الدافعَ الذي يأتي بك إلى المراجعة.'**
  String get scienceClaimC041Headline;

  /// C-042 [OBS]: Missing one day doesn't undo your progress.
  ///
  /// In ar, this message translates to:
  /// **'تفويتُ يومٍ واحدٍ لا يمحو تقدُّمَك.'**
  String get scienceClaimC042Headline;

  /// C-043 [MA/TEXT]: Reminders stay calm and blameless — never guilt or loss framing.
  ///
  /// In ar, this message translates to:
  /// **'التذكيراتُ تبقى هادئةً بلا لومٍ: «مراجعةُ اليوم جاهزة»، لا «ستفقد حِفظك».'**
  String get scienceClaimC043Headline;

  /// C-044 [MA/TEXT]: Your progress is your own — a calm map, never a ranking against others.
  ///
  /// In ar, this message translates to:
  /// **'تقدُّمُك مِلكُك — يُعرَض خريطةً هادئةً لكلِّ قرآنك، لا ترتيبًا مقارنةً بالآخرين.'**
  String get scienceClaimC044Headline;

  /// C-045 [TRAD/CS]: Actions are by intentions — we never turn revision into reward-chasing. PROVISIONAL — needs scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'إنما الأعمالُ بالنيّات — فلا نحوِّل المراجعةَ إلى مطاردةِ مكافأة.'**
  String get scienceClaimC045Headline;

  /// C-046 [TRAD]: An aid to revision and a servant to your teacher — not a replacement for oral correction, and not a fatwa. PROVISIONAL — needs scholarly review.
  ///
  /// In ar, this message translates to:
  /// **'هذا عونٌ على المراجعة وخادمٌ لمعلِّمك — لا بديلٌ عن التصحيح الشفهيّ، ولا فتوى.'**
  String get scienceClaimC046Headline;

  /// C-047 [OBS]: Where the science is uncertain or simplified, we say so — and name and date every source.
  ///
  /// In ar, this message translates to:
  /// **'حيثُ يكون العلمُ غيرَ مؤكَّدٍ أو يُبسِّط التطبيق، نقول ذلك — ونُسمّي ونؤرّخ كلَّ مصدر.'**
  String get scienceClaimC047Headline;

  /// C-047 honest caveat: simplifications are disclosed openly.
  ///
  /// In ar, this message translates to:
  /// **'نُفصِح عن كلِّ تبسيطٍ: «يستعمل التطبيق كذا؛ والبحثُ يبيّن كذا–كذا».'**
  String get scienceClaimC047Caveat;

  /// C-048 [TRAD-equivalent project rule]: The app works fully offline and never records your voice or sends your data anywhere (PRD C1/C2).
  ///
  /// In ar, this message translates to:
  /// **'يعمل التطبيقُ بلا إنترنت تمامًا، ولا يسجِّل صوتَك ولا يُرسِل بياناتِك إلى أيِّ مكان.'**
  String get scienceClaimC048Headline;
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
