// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// The lifecycle track a muṣḥaf page sits in (design-system 07 §3). Names the
/// classical phase the teacher's term-set labels; carries no math.
enum TrackFamily {
  /// FAR — consolidated revision (manzil): the calm green *maintenance* family.
  far,

  /// NEAR — recent revision (sabqi): a secondary neutral-tinted family.
  near,

  /// NEW — today's new lesson (sabaq): a tertiary neutral-tinted family.
  ///
  /// Spelled `neww` because `new` is a Dart reserved word.
  neww,
}

/// The decay band a page renders — derived from `R` (rolled up min-leaning) by
/// the caller (E12) **before** it reaches the leaf, so the leaf has no number to
/// leak. There are **exactly three** levels: a page ranges only solid → needs
/// revision and is **never** "safe to drop" / "mastered" (C-019, PRD §7.12).
enum DecayLevel {
  /// Strong — the dark end of the single-hue ramp + a filled glyph.
  solid,

  /// Holding — the mid ramp step + a half glyph.
  holding,

  /// Needs revision — the muted-neutral faded end + a hollow glyph. Calm
  /// maintenance framing ("ready for revision"), never alarm or loss.
  needsRevision,
}

/// The page-card state, driving only border/surface emphasis + the indicator —
/// never the page art (design-system 07 §2). A *done*/dimmed row reads as
/// status, not broken; *pulled-forward* renders identically to any due item.
enum CardState {
  /// The resting state — plain `surface`, no emphasis.
  defaultState,

  /// Weak / needs strengthening — a quiet `color.semantic.warning` outline +
  /// a calm hint, never alarm-red shame (C-003).
  weak,

  /// Due for revision today — the ordinary due emphasis.
  dueToday,

  /// Pulled forward by the load balancer — shown **identically** to any due
  /// item (no "the algorithm chose this" affordance, no badge — C-016).
  pulledForward,

  /// Revised in today's session — checked, dimmed, removable; reads as status.
  /// Today-scoped, never "mastered" / "safe to stop" (C-019).
  done,

  /// Locked by a teacher's `manual_lock` — a small lock affordance, a human
  /// override, never an alarm.
  locked,
}

/// The display-blind data a [MihrabPageCard] renders — only what the row draws,
/// never an engine type and never a number it could leak.
///
/// It carries **no** `R`/D/S/`due_at`/percentage field: the [decay] band is
/// mapped from `R` (min-leaning) by E12 before it arrives, and [trackLabel] /
/// [decayLabel] are already localized (the regional term-set string and the
/// calm decay word) so the leaf stays domain-blind. [page] and [juz] are raw
/// ints — the locale-numeral formatting happens at render, never pre-baked ASCII.
@immutable
class PageCardViewData {
  /// Creates the row data for one muṣḥaf page.
  const PageCardViewData({
    required this.page,
    required this.juz,
    required this.track,
    required this.trackLabel,
    required this.decay,
    required this.decayLabel,
    required this.state,
    this.supportingHint,
  });

  /// The muṣḥaf page number (1–604) — formatted to locale numerals at render.
  final int page;

  /// The juz index (1–30) — formatted to locale numerals at render.
  final int juz;

  /// The lifecycle track family (drives the chip color family).
  final TrackFamily track;

  /// The already-localized regional term-set label for [track] (swappable;
  /// ckb's longer terms wrap, never truncate).
  final String trackLabel;

  /// The decay band (drives the swatch color + glyph).
  final DecayLevel decay;

  /// The already-localized calm decay word ("solid" / "holding" /
  /// "needs revision") spoken in the merged phrase.
  final String decayLabel;

  /// The card state (drives emphasis + indicator only, never the page art).
  final CardState state;

  /// An optional already-localized supporting hint ("next: in N days",
  /// "weak line N"), or null.
  final String? supportingHint;
}
