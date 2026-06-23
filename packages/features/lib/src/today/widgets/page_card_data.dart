// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show Card, ReviewTrack;
import 'package:l10n/l10n.dart';

import '../../design_system/page_card/page_card_view_data.dart';
import '../../l10n/term_set.dart';

/// Maps a domain [Card] into the domain-blind [PageCardViewData] the E10 page
/// card takes — the single feature-layer mapping shared by the daily-session
/// sections and the catch-up plan rows. Decay is read from persisted card flags
/// only (isWeak / lapses) — never a re-computed `R` in the View, and never any
/// D/S/R or "safe to drop" on the row (PRD §7.12).
PageCardViewData todayPageCardData({
  required Card card,
  required ReviewTrack track,
  required int juz,
  required AppLocalizations l10n,
  required String region,
}) {
  final family = switch (track) {
    ReviewTrack.far => TrackFamily.far,
    ReviewTrack.near => TrackFamily.near,
    ReviewTrack.newPage => TrackFamily.neww,
    ReviewTrack.unmemorized => TrackFamily.neww,
  };
  final decay = card.isWeak
      ? DecayLevel.needsRevision
      : (card.lapses > 0 ? DecayLevel.holding : DecayLevel.solid);
  final decayLabel = switch (decay) {
    DecayLevel.needsRevision => l10n.decayNeedsRevision,
    DecayLevel.holding => l10n.decayHolding,
    DecayLevel.solid => l10n.decaySteady,
  };
  final state = card.hasManualLock
      ? CardState.locked
      : (card.isWeak ? CardState.weak : CardState.dueToday);
  return PageCardViewData(
    page: card.pageId,
    juz: juz,
    track: family,
    trackLabel: trackLabel(l10n, track, region),
    decay: decay,
    decayLabel: decayLabel,
    state: state,
  );
}
