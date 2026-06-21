// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

/// Whether a directional icon mirrors under RTL — the curated policy from
/// design-system 12 §2, authored once here instead of decided per widget
/// ("mirroring everything is as wrong as mirroring nothing").
///
/// The authoritative table (design 12 §2):
///
/// - **mirror** — back · next · chevron · progress · sign-off flow · page-turn
///   *direction*. These follow reading direction, so they flip under RTL. They
///   are drawn with the auto-mirroring `Icons.arrow_*` family
///   (`matchTextDirection: true`), so the framework flips them by ambient
///   direction — this policy *documents* that, it never re-implements it with a
///   `Transform`/`Matrix4`.
/// - **neverMirror** — media-play · clock · phone · numeral glyphs. These are
///   fixed real-world conventions; a flipped play/clock/phone is a
///   recognizability bug, and numerals are shaped by the numeral set, never
///   mirrored.
/// - **neverMirrorSacred** — the muṣḥaf glyph page · the ayah-end marker · the
///   sajda sign. These are scripture: never mirrored, flipped, rotated, or
///   reflected for any visual goal. The page-turn *direction* may be RTL, but
///   the page *content* is E05's immutable glyph layer. This category exists to
///   make the refusal grep-visible and structural.
enum MirrorBehavior {
  /// Follows reading direction — flips under RTL via `Icons.arrow_*`.
  mirror,

  /// A fixed real-world glyph — never flipped.
  neverMirror,

  /// Scripture — never mirrored, flipped, rotated, or reflected.
  neverMirrorSacred,
}

/// A semantic icon role whose RTL mirror behavior is fixed by [iconMirrorPolicy]
/// (design 12 §2). Code refers to the role, never to a per-widget mirror guess.
enum IconRole {
  /// "Back" navigation affordance.
  back,

  /// "Next" / forward navigation affordance.
  next,

  /// A disclosure / list chevron.
  chevron,

  /// A directional progress affordance.
  progress,

  /// The teacher sign-off flow's directional affordance.
  signOffFlow,

  /// The muṣḥaf page-turn *direction* (not the page content).
  pageTurnDirection,

  /// A media play glyph (fixed real-world convention).
  mediaPlay,

  /// A clock glyph (fixed real-world convention).
  clock,

  /// A phone glyph (fixed real-world convention).
  phone,

  /// A numeral glyph (shaped by the numeral set, never mirrored).
  numeralGlyph,

  /// The immutable muṣḥaf glyph page — scripture.
  mushafPage,

  /// The ayah-end marker on the page — scripture.
  ayahEndMarker,

  /// The sajda sign on the page — scripture.
  sajdaSign,
}

/// The curated mirror policy (design 12 §2). The single source of truth for
/// whether an icon role flips under RTL.
const Map<IconRole, MirrorBehavior> iconMirrorPolicy =
    <IconRole, MirrorBehavior>{
  IconRole.back: MirrorBehavior.mirror,
  IconRole.next: MirrorBehavior.mirror,
  IconRole.chevron: MirrorBehavior.mirror,
  IconRole.progress: MirrorBehavior.mirror,
  IconRole.signOffFlow: MirrorBehavior.mirror,
  IconRole.pageTurnDirection: MirrorBehavior.mirror,
  IconRole.mediaPlay: MirrorBehavior.neverMirror,
  IconRole.clock: MirrorBehavior.neverMirror,
  IconRole.phone: MirrorBehavior.neverMirror,
  IconRole.numeralGlyph: MirrorBehavior.neverMirror,
  IconRole.mushafPage: MirrorBehavior.neverMirrorSacred,
  IconRole.ayahEndMarker: MirrorBehavior.neverMirrorSacred,
  IconRole.sajdaSign: MirrorBehavior.neverMirrorSacred,
};

/// The [MirrorBehavior] for [role] (total over [IconRole]).
MirrorBehavior mirrorBehaviorOf(IconRole role) => iconMirrorPolicy[role]!;

/// Resolves a [MirrorBehavior.mirror] [role] to an auto-mirroring `Icons.arrow_*`
/// glyph (`matchTextDirection: true`) so the framework — not a `Transform` —
/// flips it under RTL. Throws for any non-mirroring role: a `neverMirror` /
/// `neverMirrorSacred` role has, by design, no mirror-transform API at all.
IconData autoMirroringIconFor(IconRole role) {
  assert(
    mirrorBehaviorOf(role) == MirrorBehavior.mirror,
    'autoMirroringIconFor is only valid for a mirror role; $role is '
    '${mirrorBehaviorOf(role)} — a non-directional/sacred icon is never flipped.',
  );
  switch (role) {
    case IconRole.back:
      return Icons.arrow_back; // matchTextDirection: true
    case IconRole.next:
    case IconRole.chevron:
    case IconRole.progress:
    case IconRole.signOffFlow:
    case IconRole.pageTurnDirection:
      return Icons.arrow_forward; // matchTextDirection: true
    case IconRole.mediaPlay:
    case IconRole.clock:
    case IconRole.phone:
    case IconRole.numeralGlyph:
    case IconRole.mushafPage:
    case IconRole.ayahEndMarker:
    case IconRole.sajdaSign:
      throw ArgumentError.value(role, 'role', 'not a mirroring role');
  }
}
