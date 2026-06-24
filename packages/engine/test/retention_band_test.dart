// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The Progress heat-map's decay-band semantics (E15-T01): the R → band
// classifier, the MIN-LEANING juz roll-up (PRD §10.3 — never a mean), and the
// per-card source confidence the VSUP muting reads. Pure `package:test`, no
// clock. The band cut-offs are golden-pinned here so they cannot silently drift
// — the heat-map's honesty depends on them. The min-leaning vector is the
// release-blocking "one weak page is never averaged into a green juz" rule.

import 'package:engine/engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  group('retentionBand — golden-pinned cut-offs', () {
    test('boundary values map to the documented bands', () {
      expect(retentionBand(1.0), RetentionBand.strong);
      expect(retentionBand(0.95), RetentionBand.strong);
      expect(retentionBand(0.9499), RetentionBand.good);
      expect(retentionBand(0.90), RetentionBand.good);
      expect(retentionBand(0.8999), RetentionBand.fair);
      expect(retentionBand(0.80), RetentionBand.fair);
      expect(retentionBand(0.7999), RetentionBand.weak);
      expect(retentionBand(0.70), RetentionBand.weak);
      expect(retentionBand(0.6999), RetentionBand.faded);
      expect(retentionBand(0.0), RetentionBand.faded);
    });

    test('cases are ordered weakest → strongest by index', () {
      expect(RetentionBand.faded.index, 0);
      expect(RetentionBand.weak.index, lessThan(RetentionBand.fair.index));
      expect(RetentionBand.fair.index, lessThan(RetentionBand.good.index));
      expect(RetentionBand.good.index, lessThan(RetentionBand.strong.index));
    });
  });

  group('minLeaningBand — the honest juz aggregate (never a mean)', () {
    test('a juz of mostly-strong pages with ONE weak page leans weak', () {
      final bands = <RetentionBand>[
        RetentionBand.strong,
        RetentionBand.strong,
        RetentionBand.good,
        RetentionBand.weak, // the single rotting page
        RetentionBand.strong,
      ];
      // A mean would land ~good/strong and hide it; min-leaning surfaces it.
      expect(minLeaningBand(bands), RetentionBand.weak);
    });

    test('a single faded page fades the whole juz roll-up', () {
      expect(
        minLeaningBand([RetentionBand.strong, RetentionBand.faded]),
        RetentionBand.faded,
      );
    });

    test('all-strong stays strong; empty juz is null (untouched)', () {
      expect(
        minLeaningBand([RetentionBand.strong, RetentionBand.strong]),
        RetentionBand.strong,
      );
      expect(minLeaningBand(const <RetentionBand>[]), isNull);
    });
  });

  group('sourceConfidenceOf — VSUP muting input', () {
    test('a teacher-signed page is vivid (1.0), self-rating is muted', () {
      expect(sourceConfidenceOf(testCard(signoffs: 1)), 1.0);
      expect(sourceConfidenceOf(testCard()), kSelfConfidence);
    });
  });
}
