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
