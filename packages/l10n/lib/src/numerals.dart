// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:intl/intl.dart';

/// Returns a [NumberFormat] that renders digits in the locale's numeral set:
/// Extended Arabic-Indic (۰۱۲) for fa and ckb, Arabic-Indic (٠١٢) for ar.
///
/// Stub: `intl` carries no ckb number data, so ckb borrows fa's (both render
/// Extended Arabic-Indic). E09 finalizes the per-locale numeral policy.
NumberFormat numberFormatFor(String localeCode) {
  final effectiveLocale = localeCode == 'ckb' ? 'fa' : localeCode;
  return NumberFormat.decimalPattern(effectiveLocale);
}
