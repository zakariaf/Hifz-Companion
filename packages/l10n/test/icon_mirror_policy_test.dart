// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E09-T04 — the curated directional-icon mirror policy (design 12 §2). The
// classification IS the contract: directional roles flip, fixed-convention
// glyphs never do, and scripture is structurally un-mirrorable.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test('every IconRole has exactly one policy entry (total map)', () {
    for (final role in IconRole.values) {
      expect(iconMirrorPolicy.containsKey(role), isTrue, reason: '$role');
    }
    expect(iconMirrorPolicy.length, IconRole.values.length);
  });

  test('directional roles mirror', () {
    for (final role in const [
      IconRole.back,
      IconRole.next,
      IconRole.chevron,
      IconRole.progress,
      IconRole.signOffFlow,
      IconRole.pageTurnDirection,
    ]) {
      expect(mirrorBehaviorOf(role), MirrorBehavior.mirror, reason: '$role');
    }
  });

  test('fixed real-world glyphs never mirror', () {
    for (final role in const [
      IconRole.mediaPlay,
      IconRole.clock,
      IconRole.phone,
      IconRole.numeralGlyph,
    ]) {
      expect(
        mirrorBehaviorOf(role),
        MirrorBehavior.neverMirror,
        reason: '$role',
      );
    }
  });

  test('scripture roles are neverMirrorSacred', () {
    for (final role in const [
      IconRole.mushafPage,
      IconRole.ayahEndMarker,
      IconRole.sajdaSign,
    ]) {
      expect(
        mirrorBehaviorOf(role),
        MirrorBehavior.neverMirrorSacred,
        reason: '$role',
      );
    }
  });

  test('mirror roles resolve to the auto-mirroring Icons.arrow_* family', () {
    expect(autoMirroringIconFor(IconRole.back), Icons.arrow_back);
    expect(autoMirroringIconFor(IconRole.next), Icons.arrow_forward);
    // The framework flips these by ambient direction (matchTextDirection).
    expect(Icons.arrow_back.matchTextDirection, isTrue);
    expect(Icons.arrow_forward.matchTextDirection, isTrue);
  });

  test('the policy exposes NO mirror API for a sacred or fixed role', () {
    // The refusal is structural: there is no Transform-returning API at all, and
    // autoMirroringIconFor throws for any non-mirroring role — scripture and
    // fixed glyphs can never be handed a flip.
    for (final role in const [
      IconRole.mushafPage,
      IconRole.ayahEndMarker,
      IconRole.sajdaSign,
      IconRole.mediaPlay,
      IconRole.clock,
    ]) {
      expect(
        () => autoMirroringIconFor(role),
        throwsA(anything),
        reason: '$role must never resolve to a mirroring glyph',
      );
    }
  });
}
