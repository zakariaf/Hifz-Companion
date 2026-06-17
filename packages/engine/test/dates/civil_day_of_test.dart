// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Pure-engine suite for the instant->civil-day boundary `civilDayOf` (07 §3).
// `package:test` only — no flutter_test, no widget binding, no wall clock; every
// instant is a constructed `DateTime` literal and every expectation a
// `CalendarDate.ymd(...)` literal. The engine bans dart:io, so the offline guard
// is structural (no socket reachable), not installed here.
//
// Written TEST-FIRST: the T10 23:00-local pin and the UTC-vs-local divergence
// cases existed and failed before the `civilDayOf` body — the "revised tonight
// -> tomorrow's UTC date" off-by-one is pinned, not patched (07 §7 T10).
//
// Host-zone discipline (07 §7): the divergence cases below build instants from
// LOCAL wall-clock literals near midnight, so on any non-UTC host the persisted
// UTC instant lands on a different calendar day than the local one — exactly the
// condition that catches a no-`.toLocal()` implementation. CI re-runs the suite
// under TZ=Asia/Tehran / Pacific/Kiritimati / UTC (E02-T08/T10); it is never
// considered green from a TZ=UTC-only run.

import 'package:engine/engine.dart';
import 'package:test/test.dart';

void main() {
  group('T10 — a 23:00-local review lands on the local day', () {
    test('23:00 local, persisted UTC, converts to the local date', () {
      // 23:00 LOCAL on 2026-06-16. On a positive-offset host its UTC instant is
      // earlier the same day; on a negative-offset host it has already rolled
      // over to 2026-06-17 in UTC. Either way the civil day is the local date.
      final storedUtc = DateTime(2026, 6, 16, 23).toUtc(); // 23:00 local
      expect(civilDayOf(storedUtc), CalendarDate.ymd(2026, 6, 16));
    });

    test('documented +03:30 example: 19:30 UTC is 23:00 local, still June 16',
        () {
      // Tehran (+03:30): DateTime.utc(2026,6,16,19,30) == 2026-06-16 23:00 local.
      // The civil day always follows local; asserting against the instant's own
      // .toLocal() keeps this host-zone-independent (07 §7).
      final inst = DateTime.utc(2026, 6, 16, 19, 30);
      final local = inst.toLocal();
      expect(
        civilDayOf(inst),
        CalendarDate.ymd(local.year, local.month, local.day),
      );
    });
  });

  group('the civil day follows LOCAL, not UTC, in both directions', () {
    test('just before local midnight -> the earlier (local) day', () {
      final storedUtc = DateTime(2026, 6, 16, 23, 59).toUtc();
      expect(civilDayOf(storedUtc), CalendarDate.ymd(2026, 6, 16));
    });

    test('just after local midnight -> the later (local) day', () {
      final storedUtc = DateTime(2026, 6, 17, 0, 1).toUtc();
      expect(civilDayOf(storedUtc), CalendarDate.ymd(2026, 6, 17));
    });

    test('whenever local (y,m,d) differs from UTC (y,m,d), local wins', () {
      final inst = DateTime(2026, 6, 16, 23, 30).toUtc();
      final local = inst.toLocal();
      if (local.day != inst.day) {
        // Host genuinely diverges (non-UTC): the naive UTC-field day is wrong.
        expect(
          civilDayOf(inst),
          isNot(CalendarDate.ymd(inst.year, inst.month, inst.day)),
        );
      }
      expect(
        civilDayOf(inst),
        CalendarDate.ymd(local.year, local.month, local.day),
      );
    });
  });

  group('depends only on the moment + local zone, not the isUtc flag', () {
    test('civilDayOf is identical for the same moment however it is stored',
        () {
      final inst = DateTime(2026, 6, 16, 23); // a real local moment, 23:00
      expect(civilDayOf(inst), civilDayOf(inst.toUtc()));
      expect(civilDayOf(inst), civilDayOf(inst.toLocal()));
    });
  });

  group('totality — never throws for any representable instant', () {
    test('a sweep of extreme instants each yields a CalendarDate', () {
      final instants = <DateTime>[
        DateTime.utc(1970), // the Unix epoch
        DateTime.utc(1900, 3),
        DateTime.utc(2024, 2, 29, 12), // leap day
        DateTime.utc(2026, 12, 31, 23, 59, 59),
        DateTime.utc(2100),
        DateTime.utc(9999, 12, 31),
      ];
      for (final inst in instants) {
        expect(civilDayOf(inst), isA<CalendarDate>());
      }
    });
  });

  group('the passed instant is read-only (review_log stays untouched)', () {
    test('the DateTime is value-equal before and after the call', () {
      final inst = DateTime.utc(2026, 6, 16, 19, 30);
      final before = inst;
      civilDayOf(inst);
      expect(inst, before);
      expect(inst.isUtc, isTrue);
      expect(inst.millisecondsSinceEpoch, before.millisecondsSinceEpoch);
    });
  });
}
