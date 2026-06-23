// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// TodaySession / TodayCatchUp are immutable value types: copyWith round-trips,
// value equality, unmodifiable sections, and a total listState derivation.

import 'package:features/features.dart'
    show TodayCatchUp, TodayListState, TodaySession;
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();

  test('empty session is all-done and holds no pages', () {
    const s = TodaySession.empty();
    expect(s.isEmpty, isTrue);
    expect(s.pageCount, 0);
    expect(s.listState, TodayListState.allDone);
    expect(s.catchUp, isNull);
  });

  test('a populated session is populated and counts its pages', () {
    final s = TodaySession(
      far: [dueFar(1), dueFar(2)],
      near: [dueNear(3)],
    );
    expect(s.listState, TodayListState.populated);
    expect(s.pageCount, 3);
  });

  test('sections are unmodifiable', () {
    final s = TodaySession(far: [dueFar(1)]);
    expect(() => s.far.add(dueFar(2)), throwsUnsupportedError);
    expect(() => s.near.add(dueNear(2)), throwsUnsupportedError);
  });

  test('copyWith replaces only the given fields, value-equal otherwise', () {
    final base = TodaySession(far: [dueFar(1)]);
    final overflow = base.copyWith(budgetOverflow: true);
    expect(overflow.budgetOverflow, isTrue);
    expect(overflow.far.map((c) => c.pageId), [1]);
    expect(base == TodaySession(far: [dueFar(1)]), isTrue);
    expect(base == overflow, isFalse);
  });

  test('TodayCatchUp is value-equal and unmodifiable', () {
    final a = TodayCatchUp(missedDays: 3, planDays: 5, items: [dueFar(1)]);
    final b = TodayCatchUp(missedDays: 3, planDays: 5, items: [dueFar(1)]);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(() => a.items.add(dueFar(2)), throwsUnsupportedError);
  });
}
