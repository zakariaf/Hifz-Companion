// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';
import 'package:test/test.dart';

void main() {
  const profileId = ProfileId('profile-1');

  group('ConfusionEdge canonical ordering (ayahA < ayahB)', () {
    test('between(...) keeps an already-ordered pair in order', () {
      final edge = ConfusionEdge.between(profileId, '2:1', '2:2');
      expect(edge.ayahA, '2:1');
      expect(edge.ayahB, '2:2');
    });

    test('between(...) normalizes a reversed pair so ayahA < ayahB', () {
      final edge = ConfusionEdge.between(profileId, '2:2', '2:1');
      expect(edge.ayahA, '2:1');
      expect(edge.ayahB, '2:2');
      expect(edge.ayahA.compareTo(edge.ayahB) < 0, isTrue);
    });

    test('two edges from the swapped pair are value-equal after normalizing',
        () {
      final forward = ConfusionEdge.between(profileId, '2:1', '2:2');
      final reversed = ConfusionEdge.between(profileId, '2:2', '2:1');
      expect(reversed, forward);
      expect(reversed.hashCode, forward.hashCode);
    });
  });

  group('ConfusionEdge fields', () {
    test('lastConfusedAt is a nullable CalendarDate (a day, not an instant)',
        () {
      final never = ConfusionEdge.between(profileId, '2:1', '2:2');
      expect(never.lastConfusedAt, isNull);
      final once = ConfusionEdge.between(
        profileId,
        '2:1',
        '2:2',
        weight: 4,
        lastConfusedAt: CalendarDate.ymd(2026, 6, 17),
      );
      // Static-type pin: a future `DateTime lastConfusedAt` fails to compile.
      final CalendarDate? day = once.lastConfusedAt;
      expect(day, CalendarDate.ymd(2026, 6, 17));
      expect(once.weight, isA<double>());
      expect(once.weight, 4);
    });

    test('no streak/score/health field on the public surface', () {
      final edge = ConfusionEdge.between(profileId, '2:1', '2:2', weight: 2);
      // The only stored authority is `weight` (a neutral bookkeeping count) and
      // the canonical pair — never a derived "cured"/"safe to drop" flag.
      expect(edge.weight, 2);
      expect(edge.ayahA, '2:1');
      expect(edge.ayahB, '2:2');
    });

    test('copyWith() with no args preserves every field', () {
      final edge = ConfusionEdge.between(
        profileId,
        '2:1',
        '2:2',
        weight: 4,
        lastConfusedAt: CalendarDate.ymd(2026, 6, 17),
      );
      expect(edge.copyWith(), edge);
    });

    test('copyWith(weight:) changes only weight', () {
      final edge = ConfusionEdge.between(
        profileId,
        '2:1',
        '2:2',
        weight: 4,
        lastConfusedAt: CalendarDate.ymd(2026, 6, 17),
      );
      final bumped = edge.copyWith(weight: 5);
      expect(bumped.weight, 5);
      expect(bumped.ayahA, edge.ayahA);
      expect(bumped.ayahB, edge.ayahB);
      expect(bumped.lastConfusedAt, edge.lastConfusedAt);
    });
  });
}
