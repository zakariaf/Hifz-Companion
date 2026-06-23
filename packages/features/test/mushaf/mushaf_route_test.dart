// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The deep-link parse/clamp is correctness-critical: an off-by-one on a sacred
// page boundary or a wrong-page landing enters here. Pure unit, no pump.

import 'package:features/features.dart'
    show MushafReaderRoute, mushafReaderRouteFromUri;
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

MushafReaderRoute parse(String location) =>
    mushafReaderRouteFromUri(Uri.parse(location));

void main() {
  useOfflineTestPolicy();

  group('legal ranges are accepted and carried through', () {
    test('a valid page lands directly', () {
      expect(parse('/mushaf?page=255').page, 255);
    });

    test('boundary values pass intact (resolution deferred to T04)', () {
      expect(parse('/mushaf?page=1').page, 1);
      expect(parse('/mushaf?page=604').page, 604);
      expect(parse('/mushaf?juz=30').juz, 30);
      expect(parse('/mushaf?hizb=60').hizb, 60);
      expect(parse('/mushaf?surah=114').surah, 114);
      expect(parse('/mushaf?juz=1').juz, 1);
    });
  });

  group('out-of-range or unparseable params are dropped (never clamped)', () {
    test('page above/below the range drops to null', () {
      expect(parse('/mushaf?page=605').page, isNull);
      expect(parse('/mushaf?page=0').page, isNull);
    });

    test('juz / sūrah out of range drop to null', () {
      expect(parse('/mushaf?juz=31').juz, isNull);
      expect(parse('/mushaf?surah=0').surah, isNull);
      expect(parse('/mushaf?surah=115').surah, isNull);
      expect(parse('/mushaf?hizb=61').hizb, isNull);
    });

    test('a non-numeric value never throws and drops to null', () {
      expect(parse('/mushaf?page=abc').page, isNull);
      expect(parse('/mushaf?juz=').juz, isNull);
    });

    test('a dropped param leaves no target (the screen uses the default page)',
        () {
      expect(parse('/mushaf?page=605').hasTarget, isFalse);
    });
  });

  group('no param → no deep-link target', () {
    test('a bare /mushaf carries nothing', () {
      final route = parse('/mushaf');
      expect(route.page, isNull);
      expect(route.juz, isNull);
      expect(route.hizb, isNull);
      expect(route.surah, isNull);
      expect(route.hasTarget, isFalse);
    });
  });
}
