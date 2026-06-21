// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The canonical mixed-run callers (design 12 §3; engineering 12 §4–§5). Every
/// chrome run that splices a number into localized words goes through one of
/// these so the number is shaped to the locale digit block, FSI/PDI-isolated,
/// and injected as an [AppLocalizations] placeholder — never `"Page " + n` and
/// never a raw `int` passed into a `Text`. They are the single rendering path the
/// E10 components reuse (page card headline, due-count line) so a numeral/bidi
/// fix lands once for the whole library.
library;

import 'package:flutter/widgets.dart' show Locale;

import 'bidi.dart' show isolateLtr;
import 'generated/app_localizations.dart';
import 'numerals.dart' show localeDigits, toLocaleNumerals;

/// The "Page N · Juz M" muṣḥaf page-card headline (design 07 §2).
///
/// Formats each index via [localeDigits] (locale digit block, no grouping),
/// wraps each in [isolateLtr] (LRI…PDI — a digit run is a known-direction LTR
/// token; first-strong FSI mis-detects a run led by punctuation, engineering 12
/// §4), then injects the two isolated tokens into the [AppLocalizations.pageJuz]
/// ICU placeholder. The separator (`·`), the word order, and the bidi isolation
/// are the translator's, set once in the ARB — this never concatenates.
String localizedPageJuz({
  required int page,
  required int juz,
  required Locale locale,
  required AppLocalizations l10n,
}) =>
    l10n.pageJuz(
      isolateLtr(localeDigits(page, locale)),
      isolateLtr(localeDigits(juz, locale)),
    );

/// The "{n} pages due for revision" count line (a Today / heat-map summary).
///
/// Routes [count] through the [AppLocalizations.pagesDue] ICU `plural` so
/// Arabic's six CLDR categories select correctly, then shapes the embedded count
/// to the locale digit block **downstream** via [toLocaleNumerals] — `intl`
/// 0.20.x renders a plural's `{count}` in Latin and ignores the numbering-system
/// tag (dart-lang/i18n #197), so the block is pinned after formatting, the same
/// mechanism the calendar layer uses. Never `"$count pages"`. Calm
/// loss-prevention register: pages are "due for revision", never "overdue".
String localizedPagesDue({
  required int count,
  required Locale locale,
  required AppLocalizations l10n,
}) =>
    toLocaleNumerals(l10n.pagesDue(count), locale);
