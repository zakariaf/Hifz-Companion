// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import '../page_geometry.dart';
import '../render/overlay_marker.dart';

/// The result of resolving a mutashābihāt anchor against a page's word geometry
/// (E14-T09) — either the resolved [WordRef]s or a typed, total failure that the
/// drill renders as "no anchor available". The sacred surface fails **visibly**:
/// a missing/ambiguous mapping is never a silently dropped or guessed box.
sealed class AnchorResolution {
  const AnchorResolution();
}

/// The distinguishing words resolved to their page-relative [words].
final class AnchorResolved extends AnchorResolution {
  /// Wraps the resolved [words] (one or more — the divergence may be multi-word).
  const AnchorResolved(this.words);

  /// The page-relative refs of the distinguishing word(s), in dataset order.
  final List<WordRef> words;
}

/// No anchor could be resolved — the [reason] names the skew (developer-facing,
/// never shown to the user, never logged with verse text).
final class AnchorUnavailable extends AnchorResolution {
  /// Creates the unavailable result with a developer-facing [reason].
  const AnchorUnavailable(this.reason);

  /// Why the anchor could not be resolved.
  final String reason;
}

/// Resolves an āyah-relative distinguishing-word index list to page-relative
/// [WordRef]s using the **same** bundled QUL word geometry the glyphs are laid
/// out from (E14-T09; PRD §9.2, §11.2, R1).
///
/// Pure and total: it reads geometry only — no Drift, no IO, no clock, no
/// network — and **never** reads, reconstructs, re-typesets, normalizes, or
/// searches Quran text. It indexes into the āyah's words in their stored order;
/// a single āyah may straddle two lines, so two indices can resolve to different
/// `lineNumber`s. A missing āyah or an out-of-range index is an
/// [AnchorUnavailable] (fail loud), never a guessed box.
AnchorResolution anchorWordRefs(
  String ayahId,
  List<int> distinguishingWordIndices,
  PageGeometry geometry,
) {
  final words = geometry.wordsOfAyah(ayahId);
  if (words == null) {
    return AnchorUnavailable(
      'āyah "$ayahId" is absent from page ${geometry.pageNumber} geometry',
    );
  }
  final refs = <WordRef>[];
  for (final index in distinguishingWordIndices) {
    if (index < 0 || index >= words.length) {
      return AnchorUnavailable(
        'distinguishing word index $index is out of range for āyah "$ayahId" '
        '(${words.length} words)',
      );
    }
    refs.add(words[index]);
  }
  return AnchorResolved(refs);
}

/// Builds the single grouped `mutashabihAnchor` [OverlayMarker] for a member's
/// distinguishing words, or null when none resolve (E14-T09).
///
/// Exactly one marker carries all resolved words so the painter draws one calm
/// highlight group — never N markers, never a foreign [OverlayKind], never a
/// re-typeset. The painter (E05) owns the box colour/radius and the
/// Reduce-Motion-safe paint; this hands it coordinates only.
OverlayMarker? anchorMarker(
  String ayahId,
  List<int> distinguishingWordIndices,
  PageGeometry geometry,
) {
  final resolution =
      anchorWordRefs(ayahId, distinguishingWordIndices, geometry);
  if (resolution is AnchorResolved && resolution.words.isNotEmpty) {
    return OverlayMarker(
      kind: OverlayKind.mutashabihAnchor,
      words: resolution.words,
    );
  }
  return null;
}
