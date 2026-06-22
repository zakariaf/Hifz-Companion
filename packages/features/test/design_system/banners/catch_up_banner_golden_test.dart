// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T08 — the catch-up banner across fa/ckb/ar × the four appearances + 200%
// reflow: a short plan and a longer plan (incl. a mandatory FAR row), proving the
// calm surface (no red fill) and the decay-as-receding-green hint. Linux lane.

import 'package:features/features.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

PageCardViewData _item(int page, TrackFamily track, DecayLevel decay) =>
    PageCardViewData(
      page: page,
      juz: 13,
      track: track,
      trackLabel: track == TrackFamily.far ? 'TRACK_FAR' : 'TRACK_NEAR',
      decay: decay,
      decayLabel: 'DECAY',
      state: CardState.dueToday,
    );

CatchUpBanner _banner(BuildContext context, CatchUpPlan plan) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context);
  return CatchUpBanner(
    plan: plan,
    empathy: l10n.catchUpEmpathy,
    factLine: toLocaleNumerals(l10n.catchUpMissedDays(plan.missedDays), locale),
    pathLine: toLocaleNumerals(l10n.catchUpPlanLine(plan.planDays), locale),
    startLabel: l10n.catchUpStartPlan,
    adjustLabel: l10n.catchUpAdjust,
    deferLabel: l10n.catchUpDefer,
    onChoice: (_) {},
  );
}

ComponentStateMatrix _matrix() => ComponentStateMatrix(
      component: 'catch_up_banner',
      specimens: [
        ComponentSpecimen(
          name: 'short',
          build: (context) => _banner(
            context,
            CatchUpPlan(
              missedDays: 1,
              planDays: 2,
              items: [_item(253, TrackFamily.far, DecayLevel.needsRevision)],
            ),
          ),
        ),
        ComponentSpecimen(
          name: 'longer',
          build: (context) => _banner(
            context,
            CatchUpPlan(
              missedDays: 5,
              planDays: 7,
              items: [
                _item(253, TrackFamily.far, DecayLevel.needsRevision),
                _item(254, TrackFamily.near, DecayLevel.holding),
                _item(255, TrackFamily.near, DecayLevel.solid),
              ],
            ),
          ),
        ),
      ],
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('catch-up banner across locale × appearance', (tester) async {
    await pumpComponentMatrix(
      tester,
      matrix: _matrix(),
      surfaceSize: const Size(390, 1200),
    );
  });
}
