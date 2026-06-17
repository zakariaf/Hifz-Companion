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
    test('lastConfusedAtInstant is a nullable DateTime', () {
      final never = ConfusionEdge.between(profileId, '2:1', '2:2');
      expect(never.lastConfusedAtInstant, isNull);
      final once = ConfusionEdge.between(
        profileId,
        '2:1',
        '2:2',
        weight: 4,
        lastConfusedAtInstant: DateTime.utc(2026, 6, 17),
      );
      final DateTime? instant = once.lastConfusedAtInstant;
      expect(instant?.isUtc, isTrue);
      expect(once.weight, 4);
    });

    test('copyWith() with no args preserves every field', () {
      final edge = ConfusionEdge.between(
        profileId,
        '2:1',
        '2:2',
        weight: 4,
        lastConfusedAtInstant: DateTime.utc(2026, 6, 17),
      );
      expect(edge.copyWith(), edge);
    });
  });
}
