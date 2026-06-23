// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// The safe page the reader opens on when a deep link carries no legal target
/// (PRD §6.1) — the first muṣḥaf page. A dropped or out-of-range param lands
/// here, never on a guessed neighbouring (wrong) sacred boundary.
const int kDefaultReaderPage = 1;

/// A parsed, range-validated muṣḥaf-reader deep link (PRD §6.1 ranges:
/// `page∈1..604`, `juz∈1..30`, `ḥizb∈1..60`, `sūrah∈1..114`).
///
/// Each field is either a legal target index or null: an absent, unparseable,
/// or out-of-range param is **dropped to null** — never clamped onto a
/// neighbouring page, because an off-by-one on a sacred boundary is the failure
/// this validation exists to prevent. The juz/ḥizb/sūrah → page *resolution*
/// from the fixed bundled structure is E13-T04's; this value only carries a
/// validated target through to the screen.
@immutable
class MushafReaderRoute {
  /// Creates a route from already-validated targets (any may be null).
  const MushafReaderRoute({this.page, this.juz, this.hizb, this.surah});

  /// The deep-linked page (1..604), or null.
  final int? page;

  /// The deep-linked juz (1..30), or null — resolved to a page by T04.
  final int? juz;

  /// The deep-linked ḥizb (1..60), or null — resolved to a page by T04.
  final int? hizb;

  /// The deep-linked sūrah (1..114), or null — resolved to a page by T04.
  final int? surah;

  /// Whether any legal deep-link target survived parsing.
  bool get hasTarget =>
      page != null || juz != null || hizb != null || surah != null;

  @override
  bool operator ==(Object other) =>
      other is MushafReaderRoute &&
      other.page == page &&
      other.juz == juz &&
      other.hizb == hizb &&
      other.surah == surah;

  @override
  int get hashCode => Object.hash(page, juz, hizb, surah);
}

/// Parses the optional `page`/`juz`/`hizb`/`surah` query params off a `/mushaf`
/// [uri] into a range-validated [MushafReaderRoute]. Every param goes through
/// `int.tryParse` and a legal-range check; an unparseable or out-of-range value
/// is dropped to null (never thrown, never clamped onto a neighbouring page).
/// Pure — no router, no `BuildContext`, no IO — so the parse/clamp is unit
/// tested without a pump.
MushafReaderRoute mushafReaderRouteFromUri(Uri uri) {
  final params = uri.queryParameters;
  return MushafReaderRoute(
    page: _inRange(params['page'], 1, 604),
    juz: _inRange(params['juz'], 1, 30),
    hizb: _inRange(params['hizb'], 1, 60),
    surah: _inRange(params['surah'], 1, 114),
  );
}

int? _inRange(String? raw, int min, int max) {
  if (raw == null) return null;
  final value = int.tryParse(raw);
  if (value == null || value < min || value > max) return null;
  return value;
}
