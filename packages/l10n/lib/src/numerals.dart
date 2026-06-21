// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart' show Locale;
import 'package:intl/intl.dart';

/// Extended Arabic-Indic zero (`۰`, U+06F0) — the fa/ckb digit block.
const int _extendedArabicIndicZero = 0x06F0;

/// Arabic-Indic zero (`٠`, U+0660) — the ar digit block.
const int _arabicIndicZero = 0x0660;

final Map<String, NumberFormat> _formatsByLocale = <String, NumberFormat>{};

/// The intl decimal-pattern locale this app uses for [locale]'s structure
/// (grouping/decimal symbols). `intl` ships no `ckb`, so Sorani borrows `fa`
/// (both render Extended Arabic-Indic); `ar` borrows the bare `ar` pattern (its
/// *digits* are pinned downstream by [toLocaleNumerals], see [formatLocaleNumber]).
String _intlTag(Locale locale) => switch (locale.languageCode) {
      'fa' => 'fa',
      'ckb' => 'fa',
      'ar' => 'ar',
      _ => 'en',
    };

/// The decimal [NumberFormat] for [locale]'s grouping/decimal structure, cached
/// per effective tag (re-creating one per heat-map cell / page card would be a
/// needless cost).
///
/// NOTE: this is the structural formatter only. Its *digit glyphs* are NOT a
/// reliable numeral-block source — `intl` 0.20.x renders `ar` in Latin and
/// ignores the `-u-nu-arab` extension (dart-lang/i18n #197). Use
/// [formatLocaleNumber] for any user-facing number, which pins the block.
NumberFormat numberFormatFor(Locale locale) {
  final tag = _intlTag(locale);
  return _formatsByLocale.putIfAbsent(
    tag,
    () => NumberFormat.decimalPattern(tag),
  );
}

/// THE single chrome numeral path: formats [value] with [locale]'s decimal
/// pattern, then pins the digit BLOCK explicitly — Extended Arabic-Indic
/// (`۰۱۲…`, U+06F0..) for fa/ckb, Arabic-Indic (`٠١٢…`, U+0660..) for ar —
/// via [toLocaleNumerals], because `intl` 0.20.x is inconsistent between date
/// and number formatting and renders `ar` in Latin (dart-lang/i18n #197). The
/// two blocks are distinct and never cross: `ar` never shows `۴`, fa/ckb never
/// show `٤`.
///
/// CHROME ONLY — never the muṣḥaf's printed ayah numbers, juz/ḥizb markers, or
/// sajda signs, which are the immutable glyph layer (E05), never re-rendered by
/// `intl` (engineering 12 §5; design 12 §4, §8). A formatted number is a
/// known-direction run: isolate it with `bidi.dart`'s `isolateLtr` before
/// injecting into an ICU placeholder — this function never concatenates.
String formatLocaleNumber(Locale locale, num value) =>
    toLocaleNumerals(numberFormatFor(locale).format(value), locale);

/// Remaps the ASCII digits in [latin] to the active locale's numeral block —
/// the downstream numeral pass shared by [formatLocaleNumber] and the
/// calendar-display layer (engineering 12 §5; PRD §13.3).
///
/// fa/ckb → Extended Arabic-Indic (U+06F0–U+06F9); ar → Arabic-Indic
/// (U+0660–U+0669); other locales pass through. It substitutes ONLY the ASCII
/// digit code points (`0x30`–`0x39`), so a month name, a grouping separator, or
/// the "(Umm al-Qurā)" tag passes through verbatim, and it is idempotent: a
/// string already in a locale block has no ASCII to remap.
String toLocaleNumerals(String latin, Locale locale) {
  final blockStart = switch (locale.languageCode) {
    'fa' || 'ckb' => _extendedArabicIndicZero,
    'ar' => _arabicIndicZero,
    _ => null,
  };
  if (blockStart == null) return latin;
  const asciiZero = 0x30, asciiNine = 0x39;
  return String.fromCharCodes([
    for (final code in latin.codeUnits)
      if (code >= asciiZero && code <= asciiNine)
        blockStart + (code - asciiZero)
      else
        code,
  ]);
}
