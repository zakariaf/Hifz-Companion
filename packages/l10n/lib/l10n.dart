// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The localization API for Hifz Companion: the generated [AppLocalizations]
/// for the fa/ckb/ar locale set, [hifzLocalizationsDelegates] (which adds the
/// custom ckb framework delegate), the per-locale numeral formatter
/// ([numberFormatFor]), and the bidi isolation helper ([isolate]). The full
/// transcreation and the finalized numeral/bidi policy land in E09.
library;

export 'src/bidi.dart';
export 'src/ckb_material_localizations.dart' show hifzLocalizationsDelegates;
export 'src/generated/app_localizations.dart';
export 'src/numerals.dart';
