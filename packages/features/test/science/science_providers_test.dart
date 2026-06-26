// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/src/science/claim_row.dart';
import 'package:features/src/science/science_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test('scienceGroupsProvider exposes the register grouped A–J, in order', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final sections = container.read(scienceGroupsProvider);
    expect(sections, isNotEmpty);

    // Groups appear in enum (A–J) order with no empties.
    final groups = sections.map((s) => s.group).toList();
    expect(groups, orderedEquals(ClaimGroup.values.where(groups.contains)));
    for (final s in sections) {
      expect(s.claims, isNotEmpty, reason: '${s.group.letter} has claims');
    }

    // Grouping is total and lossless against the flat register.
    final grouped = [for (final s in sections) ...s.claims];
    final flat = container.read(scienceRegisterProvider);
    expect(grouped.length, flat.length);
    expect(grouped.map((c) => c.id).toSet(), flat.map((c) => c.id).toSet());
  });
}
