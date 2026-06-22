// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T08 — the empty-state family across fa/ckb/ar × the four appearances +
// 200% reflow: firstRun (calm invitation), allDone (calm secondary-text close,
// no celebration), silentResume (an empty frame — nothing rendered). Linux lane.

import 'package:features/features.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

ComponentStateMatrix _matrix() => ComponentStateMatrix(
      component: 'empty_state',
      specimens: [
        ComponentSpecimen(
          name: 'first_run',
          build: (context) {
            final l10n = AppLocalizations.of(context);
            return EmptyState(
              model: EmptyStateModel(
                kind: EmptyStateKind.firstRun,
                body: l10n.emptyFirstRunBody,
                actionLabel: l10n.emptyFirstRunAction,
                onAction: () {},
              ),
            );
          },
        ),
        ComponentSpecimen(
          name: 'all_done',
          build: (context) => EmptyState(
            model: EmptyStateModel(
              kind: EmptyStateKind.allDone,
              body: AppLocalizations.of(context).emptyAllDone,
            ),
          ),
        ),
        ComponentSpecimen(
          name: 'silent_resume',
          build: (context) => const EmptyState(
            model: EmptyStateModel(kind: EmptyStateKind.silentResume),
          ),
        ),
      ],
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('empty-state family across locale × appearance', (tester) async {
    await pumpComponentMatrix(tester, matrix: _matrix());
  });
}
