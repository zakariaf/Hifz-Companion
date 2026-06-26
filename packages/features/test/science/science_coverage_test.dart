// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The typed twin of the tool/check_claims_coverage.dart gate: every rendered
// claim resolves to a non-empty localized headline in every locale (no orphan
// renders blank), every group has a header, and every caveat id resolves.

import 'package:features/src/science/claims_register.dart';
import 'package:features/src/science/science_copy.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();
  TestWidgetsFlutterBinding.ensureInitialized();

  const locales = [Locale('ar'), Locale('fa'), Locale('ckb')];

  test('every register claim has a non-empty headline in fa/ckb/ar', () async {
    for (final locale in locales) {
      final l10n = await AppLocalizations.delegate.load(locale);
      for (final claim in claimsRegister) {
        expect(
          scienceHeadline(l10n, claim.id),
          isNotEmpty,
          reason: '${claim.id} headline missing for $locale',
        );
      }
    }
  });

  test('every group in the register has a non-empty header in fa/ckb/ar',
      () async {
    for (final locale in locales) {
      final l10n = await AppLocalizations.delegate.load(locale);
      for (final group in claimGroupsInRegister) {
        expect(scienceGroupLabel(l10n, group), isNotEmpty,
            reason: '${group.letter} header missing for $locale');
      }
    }
  });

  test('caveats resolve where present and are null otherwise', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    // The six honesty rows carry a caveat; a non-caveat row returns null.
    for (final id in const ['C-004', 'C-010', 'C-016', 'C-017', 'C-025', 'C-047']) {
      expect(scienceCaveat(l10n, id), isNotNull, reason: '$id caveat');
    }
    expect(scienceCaveat(l10n, 'C-001'), isNull);
  });
}
