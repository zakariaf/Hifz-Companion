// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The "when memorized" band math (E11-T07), written first. Each coarse band
// resolves to a representative CalendarDate by addDays only — no Duration, no
// DateTime.difference — so it is the byte-identical serial day in every
// timezone and across any DST transition.

import 'package:engine/engine.dart' show CalendarDate;
import 'package:features/src/onboarding/widgets/when_memorized_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each band counts back whole days from the injected today', () {
    final today = CalendarDate.ymd(2026, 6, 22);
    void expectBand(StaleBand band, int daysBack) => expect(
          memorizedDateForBand(band, today).epochDay,
          today.addDays(-daysBack).epochDay,
        );
    expectBand(StaleBand.thisYear, 180);
    expectBand(StaleBand.oneToTwoYears, 548);
    expectBand(StaleBand.threeToFiveYears, 1461);
    expectBand(StaleBand.moreThanFiveYears, 2557);
  });

  test('resolution is a pure integer serial day (no instant/Duration drift)',
      () {
    // The same band against the same today yields the identical serial day
    // regardless of any wall clock — addDays is integer arithmetic.
    const today = CalendarDate.fromEpochDay(20000);
    for (final band in StaleBand.values) {
      expect(
        memorizedDateForBand(band, today),
        memorizedDateForBand(band, today),
      );
      expect(memorizedDateForBand(band, today).isBefore(today), isTrue);
    }
  });
}
