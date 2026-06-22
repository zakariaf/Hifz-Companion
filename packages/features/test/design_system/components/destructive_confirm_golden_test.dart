// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T09 — the destructive-confirm gate across fa/ckb/ar × the four appearances
// + 200% reflow: eraseAll (step 1), wipeProfile, abortDiscard — the safe-path-
// primary artifact (Cancel filled + focused; destructive plainer, top-start). The
// eraseAll step-2 frame is interaction-driven and asserted in the widget test.
// Linux lane only.

import 'package:features/features.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

DestructiveConfirmStrings _stringsFor(
  AppLocalizations l10n,
  DestructiveAction action,
) =>
    switch (action) {
      DestructiveAction.eraseAll => DestructiveConfirmStrings(
          consequence: l10n.destructiveEraseAllConsequence,
          confirmLabel: l10n.destructiveEraseAllConfirm,
          cancelLabel: l10n.destructiveKeepData,
          secondConsequence: l10n.destructiveEraseAllSecondConsequence,
          secondConfirmLabel: l10n.destructiveEraseAllSecondConfirm,
        ),
      DestructiveAction.wipeProfile => DestructiveConfirmStrings(
          consequence: l10n.destructiveWipeProfileConsequence,
          confirmLabel: l10n.destructiveWipeProfileConfirm,
          cancelLabel: l10n.destructiveKeepData,
        ),
      DestructiveAction.abortDiscard => DestructiveConfirmStrings(
          consequence: l10n.destructiveAbortConsequence,
          confirmLabel: l10n.destructiveAbortConfirm,
          cancelLabel: l10n.destructiveKeepData,
        ),
    };

ComponentSpecimen _spec(String name, DestructiveAction action) =>
    ComponentSpecimen(
      name: name,
      build: (context) => DestructiveConfirmSheet(
        action: action,
        strings: _stringsFor(AppLocalizations.of(context), action),
        onConfirmed: () {},
        onCancelled: () {},
      ),
    );

ComponentStateMatrix _matrix() => ComponentStateMatrix(
      component: 'destructive_confirm',
      specimens: [
        _spec('erase_all', DestructiveAction.eraseAll),
        _spec('wipe_profile', DestructiveAction.wipeProfile),
        _spec('abort_discard', DestructiveAction.abortDiscard),
      ],
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('destructive confirm across locale × appearance', (tester) async {
    await pumpComponentMatrix(tester, matrix: _matrix());
  });
}
