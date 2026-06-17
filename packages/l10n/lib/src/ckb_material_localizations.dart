// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/app_localizations.dart';

/// Central Kurdish (Sorani, `ckb`) is right-to-left but is not in Flutter's
/// built-in `GlobalMaterialLocalizations` / `GlobalCupertinoLocalizations` /
/// `GlobalWidgetsLocalizations` sets, so a `MaterialApp` listing `ckb` would
/// warn that no framework delegate supports it. These delegates supply the
/// framework strings for `ckb` by reusing the Arabic (`ar`) data — both are RTL
/// — until E09 ships reviewed native ckb framework strings. The app's own
/// strings (`AppLocalizations`) are already proper ckb.
const Locale _frameworkFallback = Locale('ar');

class _CkbMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _CkbMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(_frameworkFallback);

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
      GlobalCupertinoLocalizations.delegate.load(_frameworkFallback);

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
      GlobalWidgetsLocalizations.delegate.load(_frameworkFallback);

  @override
  bool shouldReload(_CkbWidgetsLocalizationsDelegate old) => false;
}

/// The full localization delegate set for Hifz Companion: the app's generated
/// [AppLocalizations] delegates plus the custom `ckb` framework delegates, so
/// every supported locale (ar, fa, ckb) is covered by every delegate type.
final List<LocalizationsDelegate<dynamic>> hifzLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
  const _CkbMaterialLocalizationsDelegate(),
  const _CkbCupertinoLocalizationsDelegate(),
  const _CkbWidgetsLocalizationsDelegate(),
  ...AppLocalizations.localizationsDelegates,
];
