// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show activeProfileProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' show PageGeometry;

import 'overlay_markers.dart';

/// The bundled per-word geometry for a page — the box source E05's
/// `MushafOverlayPainter` resolves each `WordRef` against (never measured from
/// shaped text). **Bundle-first:** the geometry arrives with the verified asset
/// pack, so today it is empty (an overlay over it draws nothing); the seam is
/// here so the reader composes correctly when the asset data lands.
final mushafPageGeometryProvider =
    Provider.autoDispose.family<PageGeometry, int>(
  (ref, pageNumber) => PageGeometry(pageNumber: pageNumber),
);

/// The active profile's weak line ranges on a page — projected from the
/// `line_block` rows E04's reviews lazily create for a repeatedly-lapsing page
/// (R1: the reader reads them, never computes `weak_flag`/`error_count`). Keyed
/// by page and re-read on profile switch (it watches [activeProfileProvider]).
/// **Bundle-first:** no review has produced a `line_block` yet, so this is empty
/// today — the read surface lands with E04's review-produced blocks.
final profileWeakLinesProvider =
    Provider.autoDispose.family<List<WeakLineBlock>, int>(
  (ref, pageNumber) {
    final profile = ref.watch(activeProfileProvider);
    if (profile == null) return const [];
    // Seam: read line_block(profile, pageNumber) → WeakLineBlock list.
    return const [];
  },
);

/// The mutashābihāt anchors on a page — the distinguishing word(s) of each
/// confusable member whose āyah falls on the page, from the read-only scholar-
/// reviewed dataset (E14 owns *which* words; the reader only surfaces the static
/// prior). **Bundle-first:** the confusables dataset is empty today.
final pageConfusablesProvider =
    Provider.autoDispose.family<List<ConfusableAnchor>, int>(
  (ref, pageNumber) => const [],
);

/// Whether the **weak-line** overlay would paint at least one marker on
/// [pageNumber] — the active profile has a weak `line_block` there **and** the
/// bundled per-word [mushafPageGeometryProvider] can place it. The reader's
/// weak-line toggle is enabled only when this is true, so the control never
/// flips a state that paints nothing: until the data + geometry land it stays an
/// honest, disabled-with-a-reason affordance, then lights up by itself.
/// **Bundle-first:** false on every page today (the geometry is empty).
final weakLineOverlayAvailableProvider = Provider.autoDispose.family<bool, int>(
  (ref, pageNumber) {
    if (ref.watch(mushafPageGeometryProvider(pageNumber)).wordBoxes.isEmpty) {
      return false;
    }
    return ref.watch(profileWeakLinesProvider(pageNumber)).isNotEmpty;
  },
);

/// Whether the **mutashābihāt** overlay would paint at least one anchor on
/// [pageNumber] — the scholar-reviewed dataset names a distinguishing word here
/// **and** the bundled geometry can place it. Gates the reader's mutashābihāt
/// toggle for the same honesty reason as [weakLineOverlayAvailableProvider].
/// **Bundle-first:** false on every page today (no dataset, empty geometry).
final mutashabihatOverlayAvailableProvider =
    Provider.autoDispose.family<bool, int>(
  (ref, pageNumber) {
    if (ref.watch(mushafPageGeometryProvider(pageNumber)).wordBoxes.isEmpty) {
      return false;
    }
    return ref
        .watch(pageConfusablesProvider(pageNumber))
        .any((anchor) => anchor.words.isNotEmpty);
  },
);
