// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T03 — the page card's six-state set across fa/ckb/ar × the four
// appearances on the real bundled fonts (never Ahem, never a QPC glyph), plus a
// 200% reflow pass: the weak frame is a calm warning outline (not red),
// pulled-forward is byte-identical to due, and done reads as dimmed status.
// Reuses the T02 pumpComponentMatrix — no re-implemented loop. Linux lane only.

import 'package:features/features.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

ComponentStateMatrix _pageCardMatrix() => ComponentStateMatrix(
      component: 'page_card',
      specimens: [
        for (final (name, state) in const [
          ('default', CardState.defaultState),
          ('weak', CardState.weak),
          ('dueToday', CardState.dueToday),
          ('pulledForward', CardState.pulledForward),
          ('done', CardState.done),
          ('locked', CardState.locked),
        ])
          ComponentSpecimen(
            name: name,
            build: (context) {
              final l10n = AppLocalizations.of(context);
              return MihrabPageCard(
                data: PageCardViewData(
                  page: 253,
                  juz: 13,
                  track: TrackFamily.far,
                  trackLabel: l10n.trackFarLabel,
                  decay: DecayLevel.needsRevision,
                  decayLabel: l10n.decayNeedsRevision,
                  state: state,
                  supportingHint:
                      state == CardState.weak ? l10n.decayNeedsRevision : null,
                ),
                onOpen: () {},
              );
            },
          ),
      ],
    );

void main() {
  useOfflineTestPolicy();

  setUpAll(loadMihrabUiFonts);

  testWidgets('page card six-state matrix across locale × appearance',
      (tester) async {
    await pumpComponentMatrix(tester, matrix: _pageCardMatrix());
  });
}
