// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Central Kurdish (Sorani, `ckb`) Material/Cupertino/Widgets framework chrome.
// Flutter ships no `ckb` localization, so a `MaterialApp` listing `ckb` would
// otherwise fall back to a default language for OK/Cancel/date-picker labels.
//
// `CkbMaterialLocalizations` extends `GlobalMaterialLocalizations` and overrides
// the high-visibility, Sorani-distinct labels (OK/Cancel/Close/Back/Next, …) in
// canonical Sorani (U+06D5 ە, U+06A9 ک); the long tail of rarely-seen strings
// (license-page text, "rows X–Y of Z", semantic labels) is forwarded to a
// wrapped Arabic base — both are RTL Arabic-script, an honest provisional
// adaptation until a native Sorani Material set is reviewed. All Sorani chrome
// here is PROVISIONAL — needs native + scholar review (design 11 §9); it is a
// transcreation, never a literal/machine translation, and states no ruling.
//
// Direction is NOT sourced here: `textDirection => rtl` satisfies the framework
// contract for this delegate's own chrome only; app-wide RTL comes from the
// locale resolving via GlobalWidgetsLocalizations (engineering 12 §2, §3).

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'generated/app_localizations.dart';

/// The closest intl locale with full Material data: Sorani has none, so the
/// wrapped base and the date/number formats use Arabic (both RTL Arabic-script).
const String _intlBase = 'ar';

/// The Sorani (`ckb`) Material localizations. PROVISIONAL Sorani chrome.
class CkbMaterialLocalizations extends GlobalMaterialLocalizations {
  CkbMaterialLocalizations._(this._base, {required super.localeName})
      : super(
          fullYearFormat: intl.DateFormat.y(_intlBase),
          compactDateFormat: intl.DateFormat.yMd(_intlBase),
          shortDateFormat: intl.DateFormat.yMMMd(_intlBase),
          mediumDateFormat: intl.DateFormat.MMMEd(_intlBase),
          longDateFormat: intl.DateFormat.yMMMMEEEEd(_intlBase),
          yearMonthFormat: intl.DateFormat.yMMMM(_intlBase),
          shortMonthDayFormat: intl.DateFormat.MMMd(_intlBase),
          decimalFormat: intl.NumberFormat.decimalPattern(_intlBase),
          twoDigitZeroPaddedFormat: intl.NumberFormat('00', _intlBase),
        );

  /// The Arabic base whose long-tail chrome strings this class forwards.
  final GlobalMaterialLocalizations _base;

  /// The localizations delegate for `ckb` Material chrome.
  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _CkbMaterialLocalizationsDelegate();

  // ── High-visibility Sorani overrides (canonical encoding). ──
  @override
  String get okButtonLabel => 'باشە';
  @override
  String get cancelButtonLabel => 'هەڵوەشاندنەوە';
  @override
  String get closeButtonLabel => 'داخستن';
  @override
  String get backButtonTooltip => 'گەڕانەوە';
  @override
  String get nextMonthTooltip => 'مانگی داهاتوو';
  @override
  String get previousMonthTooltip => 'مانگی پێشوو';
  @override
  String get saveButtonLabel => 'پاشەکەوت';

  // ── Long-tail chrome forwarded to the Arabic base (provisional). ──
  @override
  String get alertDialogLabel => _base.alertDialogLabel;
  @override
  String get anteMeridiemAbbreviation => _base.anteMeridiemAbbreviation;
  @override
  String get bottomSheetLabel => _base.bottomSheetLabel;
  @override
  String get calendarModeButtonLabel => _base.calendarModeButtonLabel;
  @override
  String get clearButtonTooltip => _base.clearButtonTooltip;
  @override
  String get closeButtonTooltip => _base.closeButtonTooltip;
  @override
  String get continueButtonLabel => _base.continueButtonLabel;
  @override
  String get copyButtonLabel => _base.copyButtonLabel;
  @override
  String get currentDateLabel => _base.currentDateLabel;
  @override
  String get cutButtonLabel => _base.cutButtonLabel;
  @override
  String get dateHelpText => _base.dateHelpText;
  @override
  String get dateInputLabel => _base.dateInputLabel;
  @override
  String get dateOutOfRangeLabel => _base.dateOutOfRangeLabel;
  @override
  String get datePickerHelpText => _base.datePickerHelpText;
  @override
  String get dateRangeEndLabel => _base.dateRangeEndLabel;
  @override
  String get dateRangePickerHelpText => _base.dateRangePickerHelpText;
  @override
  String get dateRangeStartLabel => _base.dateRangeStartLabel;
  @override
  String get dateSeparator => _base.dateSeparator;
  @override
  String get deleteButtonTooltip => _base.deleteButtonTooltip;
  @override
  String get dialModeButtonLabel => _base.dialModeButtonLabel;
  @override
  String get dialogLabel => _base.dialogLabel;
  @override
  String get drawerLabel => _base.drawerLabel;
  @override
  String get firstPageTooltip => _base.firstPageTooltip;
  @override
  String get hideAccountsLabel => _base.hideAccountsLabel;
  @override
  String get inputDateModeButtonLabel => _base.inputDateModeButtonLabel;
  @override
  String get inputTimeModeButtonLabel => _base.inputTimeModeButtonLabel;
  @override
  String get invalidDateFormatLabel => _base.invalidDateFormatLabel;
  @override
  String get invalidDateRangeLabel => _base.invalidDateRangeLabel;
  @override
  String get invalidTimeLabel => _base.invalidTimeLabel;
  @override
  String get keyboardKeyAlt => _base.keyboardKeyAlt;
  @override
  String get keyboardKeyAltGraph => _base.keyboardKeyAltGraph;
  @override
  String get keyboardKeyBackspace => _base.keyboardKeyBackspace;
  @override
  String get keyboardKeyCapsLock => _base.keyboardKeyCapsLock;
  @override
  String get keyboardKeyChannelDown => _base.keyboardKeyChannelDown;
  @override
  String get keyboardKeyChannelUp => _base.keyboardKeyChannelUp;
  @override
  String get keyboardKeyControl => _base.keyboardKeyControl;
  @override
  String get keyboardKeyDelete => _base.keyboardKeyDelete;
  @override
  String get keyboardKeyEject => _base.keyboardKeyEject;
  @override
  String get keyboardKeyEnd => _base.keyboardKeyEnd;
  @override
  String get keyboardKeyEscape => _base.keyboardKeyEscape;
  @override
  String get keyboardKeyFn => _base.keyboardKeyFn;
  @override
  String get keyboardKeyHome => _base.keyboardKeyHome;
  @override
  String get keyboardKeyInsert => _base.keyboardKeyInsert;
  @override
  String get keyboardKeyMeta => _base.keyboardKeyMeta;
  @override
  String get keyboardKeyMetaMacOs => _base.keyboardKeyMetaMacOs;
  @override
  String get keyboardKeyMetaWindows => _base.keyboardKeyMetaWindows;
  @override
  String get keyboardKeyNumLock => _base.keyboardKeyNumLock;
  @override
  String get keyboardKeyNumpadAdd => _base.keyboardKeyNumpadAdd;
  @override
  String get keyboardKeyNumpadComma => _base.keyboardKeyNumpadComma;
  @override
  String get keyboardKeyNumpadDecimal => _base.keyboardKeyNumpadDecimal;
  @override
  String get keyboardKeyNumpadDivide => _base.keyboardKeyNumpadDivide;
  @override
  String get keyboardKeyNumpadEnter => _base.keyboardKeyNumpadEnter;
  @override
  String get keyboardKeyNumpadEqual => _base.keyboardKeyNumpadEqual;
  @override
  String get keyboardKeyNumpadMultiply => _base.keyboardKeyNumpadMultiply;
  @override
  String get keyboardKeyNumpadParenLeft => _base.keyboardKeyNumpadParenLeft;
  @override
  String get keyboardKeyNumpadParenRight => _base.keyboardKeyNumpadParenRight;
  @override
  String get keyboardKeyNumpadSubtract => _base.keyboardKeyNumpadSubtract;
  @override
  String get keyboardKeyPageDown => _base.keyboardKeyPageDown;
  @override
  String get keyboardKeyPageUp => _base.keyboardKeyPageUp;
  @override
  String get keyboardKeyPower => _base.keyboardKeyPower;
  @override
  String get keyboardKeyPowerOff => _base.keyboardKeyPowerOff;
  @override
  String get keyboardKeyPrintScreen => _base.keyboardKeyPrintScreen;
  @override
  String get keyboardKeyScrollLock => _base.keyboardKeyScrollLock;
  @override
  String get keyboardKeySelect => _base.keyboardKeySelect;
  @override
  String get keyboardKeyShift => _base.keyboardKeyShift;
  @override
  String get keyboardKeySpace => _base.keyboardKeySpace;
  @override
  String get lastPageTooltip => _base.lastPageTooltip;
  @override
  String get licensesPageTitle => _base.licensesPageTitle;
  @override
  String get lookUpButtonLabel => _base.lookUpButtonLabel;
  @override
  String get menuBarMenuLabel => _base.menuBarMenuLabel;
  @override
  String get menuDismissLabel => _base.menuDismissLabel;
  @override
  String get modalBarrierDismissLabel => _base.modalBarrierDismissLabel;
  @override
  String get moreButtonTooltip => _base.moreButtonTooltip;
  @override
  String get nextPageTooltip => _base.nextPageTooltip;
  @override
  String get openAppDrawerTooltip => _base.openAppDrawerTooltip;
  @override
  String get pasteButtonLabel => _base.pasteButtonLabel;
  @override
  String get popupMenuLabel => _base.popupMenuLabel;
  @override
  String get postMeridiemAbbreviation => _base.postMeridiemAbbreviation;
  @override
  String get previousPageTooltip => _base.previousPageTooltip;
  @override
  String get refreshIndicatorSemanticLabel =>
      _base.refreshIndicatorSemanticLabel;
  // The reorderItem* getters moved to WidgetsLocalizations but remain abstract
  // on MaterialLocalizations, so a subclass must still provide them; forwarded.
  // ignore_for_file: deprecated_member_use
  @override
  String get reorderItemDown => _base.reorderItemDown;
  @override
  String get reorderItemLeft => _base.reorderItemLeft;
  @override
  String get reorderItemRight => _base.reorderItemRight;
  @override
  String get reorderItemToEnd => _base.reorderItemToEnd;
  @override
  String get reorderItemToStart => _base.reorderItemToStart;
  @override
  String get reorderItemUp => _base.reorderItemUp;
  @override
  String get rowsPerPageTitle => _base.rowsPerPageTitle;
  @override
  String get scanTextButtonLabel => _base.scanTextButtonLabel;
  @override
  String get scrimLabel => _base.scrimLabel;
  @override
  String get searchFieldLabel => _base.searchFieldLabel;
  @override
  String get searchWebButtonLabel => _base.searchWebButtonLabel;
  @override
  String get selectAllButtonLabel => _base.selectAllButtonLabel;
  @override
  String get selectedDateLabel => _base.selectedDateLabel;
  @override
  String get selectYearSemanticsLabel => _base.selectYearSemanticsLabel;
  @override
  String get shareButtonLabel => _base.shareButtonLabel;
  @override
  String get showAccountsLabel => _base.showAccountsLabel;
  @override
  String get showMenuTooltip => _base.showMenuTooltip;
  @override
  String get signedInLabel => _base.signedInLabel;
  @override
  String get timePickerDialHelpText => _base.timePickerDialHelpText;
  @override
  String get timePickerHourLabel => _base.timePickerHourLabel;
  @override
  String get timePickerHourModeAnnouncement =>
      _base.timePickerHourModeAnnouncement;
  @override
  String get timePickerInputHelpText => _base.timePickerInputHelpText;
  @override
  String get timePickerMinuteLabel => _base.timePickerMinuteLabel;
  @override
  String get timePickerMinuteModeAnnouncement =>
      _base.timePickerMinuteModeAnnouncement;
  @override
  String get unspecifiedDate => _base.unspecifiedDate;
  @override
  String get unspecifiedDateRange => _base.unspecifiedDateRange;
  @override
  String get viewLicensesButtonLabel => _base.viewLicensesButtonLabel;
  @override
  ScriptCategory get scriptCategory => _base.scriptCategory;
  @override
  String get aboutListTileTitleRaw => _base.aboutListTileTitleRaw;
  @override
  String get dateRangeEndDateSemanticLabelRaw =>
      _base.dateRangeEndDateSemanticLabelRaw;
  @override
  String get dateRangeStartDateSemanticLabelRaw =>
      _base.dateRangeStartDateSemanticLabelRaw;
  @override
  String get licensesPackageDetailTextOther =>
      _base.licensesPackageDetailTextOther;
  @override
  String get pageRowsInfoTitleApproximateRaw =>
      _base.pageRowsInfoTitleApproximateRaw;
  @override
  String get pageRowsInfoTitleRaw => _base.pageRowsInfoTitleRaw;
  @override
  String get remainingTextFieldCharacterCountOther =>
      _base.remainingTextFieldCharacterCountOther;
  @override
  String get scrimOnTapHintRaw => _base.scrimOnTapHintRaw;
  @override
  String get selectedRowCountTitleOther => _base.selectedRowCountTitleOther;
  @override
  String get tabLabelRaw => _base.tabLabelRaw;
  @override
  TimeOfDayFormat get timeOfDayFormatRaw => _base.timeOfDayFormatRaw;
  @override
  String get collapsedHint => _base.collapsedHint;
  @override
  String get collapsedIconTapHint => _base.collapsedIconTapHint;
  @override
  String get expandedHint => _base.expandedHint;
  @override
  String get expandedIconTapHint => _base.expandedIconTapHint;
  @override
  String get expansionTileCollapsedHint => _base.expansionTileCollapsedHint;
  @override
  String get expansionTileCollapsedTapHint =>
      _base.expansionTileCollapsedTapHint;
  @override
  String get expansionTileExpandedHint => _base.expansionTileExpandedHint;
  @override
  String get expansionTileExpandedTapHint => _base.expansionTileExpandedTapHint;
  @override
  String get keyboardKeyNumpad0 => _base.keyboardKeyNumpad0;
  @override
  String get keyboardKeyNumpad1 => _base.keyboardKeyNumpad1;
  @override
  String get keyboardKeyNumpad2 => _base.keyboardKeyNumpad2;
  @override
  String get keyboardKeyNumpad3 => _base.keyboardKeyNumpad3;
  @override
  String get keyboardKeyNumpad4 => _base.keyboardKeyNumpad4;
  @override
  String get keyboardKeyNumpad5 => _base.keyboardKeyNumpad5;
  @override
  String get keyboardKeyNumpad6 => _base.keyboardKeyNumpad6;
  @override
  String get keyboardKeyNumpad7 => _base.keyboardKeyNumpad7;
  @override
  String get keyboardKeyNumpad8 => _base.keyboardKeyNumpad8;
  @override
  String get keyboardKeyNumpad9 => _base.keyboardKeyNumpad9;
}

class _CkbMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _CkbMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    // The Arabic base initializes intl date symbols for `ar` and supplies the
    // long-tail chrome strings; it is wrapped with the Sorani overrides. `.then`
    // (not async/await) preserves the base's SynchronousFuture, so ckb Material
    // chrome resolves on the FIRST frame exactly like the Global delegates — no
    // loading flash, and widget tests need no extra settle.
    return GlobalMaterialLocalizations.delegate
        .load(const Locale(_intlBase))
        .then(
          (base) => CkbMaterialLocalizations._(
            base as GlobalMaterialLocalizations,
            localeName: locale.toString(),
          ),
        );
  }

  @override
  bool shouldReload(_CkbMaterialLocalizationsDelegate old) => false;
}

class _CkbCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CkbCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale(_intlBase));

  @override
  bool shouldReload(_CkbCupertinoLocalizationsDelegate old) => false;
}

class _CkbWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _CkbWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale(_intlBase));

  @override
  bool shouldReload(_CkbWidgetsLocalizationsDelegate old) => false;
}

/// The full localization delegate set for Hifz Companion: the app's generated
/// [AppLocalizations] delegates plus the custom `ckb` framework delegates, so
/// every supported locale (ar, fa, ckb) is covered by every delegate type. The
/// `ckb` Material delegate is registered LAST, after the `Global*` delegates, so
/// Flutter's absence of `ckb` chrome is filled rather than shadowed.
final List<LocalizationsDelegate<dynamic>> hifzLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
  ...AppLocalizations.localizationsDelegates,
  CkbMaterialLocalizations.delegate,
  const _CkbCupertinoLocalizationsDelegate(),
  const _CkbWidgetsLocalizationsDelegate(),
];
