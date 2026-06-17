// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:intl/intl.dart';

final Map<String, NumberFormat> _formatsByLocale = <String, NumberFormat>{};

/// Returns a [NumberFormat] that renders digits in the locale's numeral set:
/// Extended Arabic-Indic (۰۱۲) for fa and ckb, Arabic-Indic (٠١٢) for ar.
///
/// Instances are cached per effective locale — this is called per cell on the
/// heat-map and per page card, where re-creating a formatter each call would be
/// a needless cost. Stub: `intl` carries no ckb number data, so ckb borrows
/// fa's (both render Extended Arabic-Indic). E09 finalizes the numeral policy.
NumberFormat numberFormatFor(String localeCode) {
  final effectiveLocale = localeCode == 'ckb' ? 'fa' : localeCode;
  return _formatsByLocale.putIfAbsent(
    effectiveLocale,
    () => NumberFormat.decimalPattern(effectiveLocale),
  );
}
