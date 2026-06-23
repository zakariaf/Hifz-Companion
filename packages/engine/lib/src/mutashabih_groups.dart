// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';

import 'build_today.dart' show ConfusionSiblings;

/// The immutable in-engine projection of the bundled confusables dataset
/// (E14-T01): for each scheduling key (`pageId`), the set of sibling page ids in
/// its mutashābihāt group(s) (PRD §9.2; science 05 §5, §7).
///
/// Pure data — no Drift symbol, no JSON, no runtime "similar verses" inference.
/// The feature/data layer builds it once from the read-only dataset plus the
/// ayah→page map and injects it; the engine consumes it as a **static, bundled
/// prior**, never deriving similarity itself.
class MutashabihGroups {
  /// Wraps a `pageId → sibling pageIds (excluding self)` map.
  const MutashabihGroups(this._siblingsByPage);

  /// The empty projection (no confusables) — the conservative default.
  static const MutashabihGroups empty = MutashabihGroups({});

  final Map<int, Set<int>> _siblingsByPage;

  /// The sibling page ids of [pageId] (excluding itself); empty if it is in no
  /// confusable group.
  Set<int> siblingsOf(int pageId) => _siblingsByPage[pageId] ?? const {};
}

/// Builds the [ConfusionSiblings] lookup `buildToday` consumes from a static
/// [groups] projection and the profile's [allCards] (06 §7; PRD §9.2).
///
/// For a card, it resolves each sibling page id to its [Card] from [allCards] —
/// **including a not-yet-due sibling**, so `expandMutashabihat` can mass it into
/// today's session additively (massed contrast, never spaced apart; science 05
/// §5; CLAIMS C-028). Sibling ids are sorted, so the adjacency order is
/// deterministic. A page with no siblings (or a sibling absent from [allCards])
/// contributes nothing. This computes no schedule and mutates no card — it only
/// selects which existing cards recite back-to-back.
ConfusionSiblings confusionSiblingsFor(
  MutashabihGroups groups,
  List<Card> allCards,
) {
  final byPage = {for (final card in allCards) card.pageId: card};
  return (card) => [
        for (final siblingPage
            in groups.siblingsOf(card.pageId).toList()..sort())
          if (byPage[siblingPage] case final sibling?) sibling,
      ];
}
