// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart'
    show confusionRepositoryProvider, referenceRepositoryProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' as models;
import 'package:models/models.dart'
    show
        ConfusionEdge,
        MutashabihGroup,
        MutashabihGroupView,
        MutashabihMemberView,
        ProfileId;
import 'package:quran/quran.dart'
    show
        AnchorResolved,
        LineType,
        MushafLineRef,
        PageGeometry,
        WordRef,
        anchorWordRefs;

/// The read models the Mutashābihāt trainer binds to (E14-T06): two read-only
/// projections of the local store, reached through the injected repositories on
/// [persistenceProvider] / [confusionRepositoryProvider] — never a raw DAO and
/// never a `DateTime.now()`. The Views (E14-T07/T08/T10) `ref.watch` these and
/// render; they do not query, parse, or sort.

/// Every scholar-reviewed mutashābihāt group, for the calm browse list.
///
/// A `FutureProvider`, not a stream: the `mutashabih_*` reference tables are
/// **read-only and bundled once**, so the set is static after install — a Future
/// is the honest shape (the hotspots below are a stream because they re-emit on
/// every committed write). Empty until the dataset loads (bundle-first).
final mutashabihGroupsProvider =
    FutureProvider.autoDispose<List<MutashabihGroup>>(
  (ref) => ref.watch(referenceRepositoryProvider).allMutashabihGroups(),
);

/// One group's assembled view (members + page + distinguishing-word indices),
/// keyed by group id — the whole group the discrimination drill iterates
/// (group-not-node). Null if the group is absent.
final mutashabihGroupProvider =
    FutureProvider.autoDispose.family<MutashabihGroupView?, String>(
  (ref, groupId) =>
      ref.watch(referenceRepositoryProvider).mutashabihGroupView(groupId),
);

/// The active profile's confusion hotspots ("you keep swapping these two"),
/// ranked most-confused first (`weight` DESC, then `last_confused_at` DESC).
///
/// A `family`+`autoDispose` `StreamProvider` keyed by the stable [ProfileId] (no
/// global "current profile", zero leakage between students); it re-emits after a
/// committed `logSwap` so the View rebuilds from the durable store, never a
/// second cache. The ranking is data-supplied by the DAO, not view-computed.
final confusionHotspotsProvider =
    StreamProvider.autoDispose.family<List<ConfusionEdge>, ProfileId>(
  (ref, profileId) =>
      ref.watch(confusionRepositoryProvider).watchEdgesForProfile(profileId),
);

/// The verified per-page line refs the discrimination drill composes into an
/// immutable page (E14-T08). Reads only the checksum-verified reference `line`
/// rows for [pageNumber] and projects them into wall-safe [MushafLineRef]s; the
/// glyph assembly happens inside the `quran` package, so the feature never names
/// the glyph surface. Bundle-first: an empty reference projects to a blank page.
final drillPageLinesProvider =
    FutureProvider.autoDispose.family<List<MushafLineRef>, int>(
  (ref, pageNumber) async {
    final lines =
        await ref.watch(referenceRepositoryProvider).linesForPage(pageNumber);
    return [
      for (final line in lines)
        MushafLineRef(
          lineNumber: line.lineNumber,
          lineType: _toRenderLineType(line.lineType),
          textGlyphRef:
              line.textGlyphRef, // opaque — drawn straight, never text
        ),
    ];
  },
);

/// The per-page word geometry the anchor overlay resolves `WordRef`s into device
/// `Rect`s against (E14-T09). Bundle-first: an empty [PageGeometry] (so the
/// overlay draws nothing until the real per-word boxes ship with the asset pack).
final drillPageGeometryProvider =
    Provider.autoDispose.family<PageGeometry, int>(
  (ref, pageNumber) => PageGeometry(pageNumber: pageNumber),
);

/// Resolves a confusable member's `distinguishing_word_index_json` into the
/// page-relative [WordRef]s the anchor overlay highlights (E14-T09).
///
/// It runs the pure `quran` resolver over the **same** page geometry the glyphs
/// use — never reading or reconstructing verse text. A missing/out-of-range
/// mapping resolves to no words (the drill shows no anchor), never a guessed box.
/// Bundle-first: the geometry has no per-word boxes yet, so this draws nothing
/// until the real layout ships with the asset pack.
final drillAnchorWordsProvider =
    Provider<List<WordRef> Function(MutashabihMemberView)>(
  (ref) => (member) {
    final geometry = ref.read(drillPageGeometryProvider(member.pageNumber));
    final resolution = anchorWordRefs(
      member.ayahId,
      member.distinguishingWordIndices,
      geometry,
    );
    return resolution is AnchorResolved ? resolution.words : const <WordRef>[];
  },
);

/// Maps the persisted reference `LineType` to the render `LineType` (placement
/// only — never the glyphs); mirrors the muṣḥaf reader's projection.
LineType _toRenderLineType(models.LineType type) => switch (type) {
      models.LineType.ayah => LineType.ayah,
      models.LineType.surahHeader => LineType.surahName,
      models.LineType.basmala => LineType.basmala,
    };
