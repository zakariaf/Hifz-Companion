// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show MushafEdition, ProfileId;

import 'mushaf_providers.dart';
import 'mushaf_route.dart';

/// The immutable reader-scaffold UI state (eng-create-riverpod-store §5). It
/// names the active [edition] (for the riwāyah chrome, R2 — never "the Quran"
/// absolutely) and the [initialPage] the reader opens on absent a deep link.
///
/// It is **display-only**: it carries no card, no `due_at`, no scheduling math.
/// The live current-page / zoom / theme / overlay-toggle state is owned by
/// E13-T02's reader-state store and read alongside this — the seam is kept.
@immutable
class MushafReaderScaffoldState {
  /// Creates the reader-scaffold state.
  const MushafReaderScaffoldState({
    required this.edition,
    this.initialPage = kDefaultReaderPage,
  });

  /// The active muṣḥaf edition whose `displayName`/`riwayah` the chrome names.
  final MushafEdition edition;

  /// The page the reader opens on when no deep-link target is supplied.
  final int initialPage;

  /// Returns a copy with the given fields replaced; omitted fields preserved.
  MushafReaderScaffoldState copyWith({MushafEdition? edition, int? initialPage}) =>
      MushafReaderScaffoldState(
        edition: edition ?? this.edition,
        initialPage: initialPage ?? this.initialPage,
      );

  @override
  bool operator ==(Object other) =>
      other is MushafReaderScaffoldState &&
      other.edition == edition &&
      other.initialPage == initialPage;

  @override
  int get hashCode => Object.hash(edition, initialPage);
}

/// The 1:1 reader view-model — `family` by `ProfileId` (the active profile the
/// weak-line overlay refs key on in T05), `autoDispose` (the heavy reader does
/// not outlive its screen on low-end Android). It reads the active
/// [MushafEdition] through an injected provider (E16 owns the swap; here it
/// reads whichever is active) and exposes one immutable [MushafReaderScaffoldState].
///
/// It reaches **no** DAO, calls **no** engine math, contains **no**
/// `DateTime.now()`, and mutates no persisted state (no `review_log` append, no
/// `due_at` re-derivation). The Quran route renders only behind the router's
/// verified-core redirect guard (R1) — this model opens no socket.
class MushafReaderViewModel extends AsyncNotifier<MushafReaderScaffoldState> {
  /// Creates the view-model for the active [profile] (the family key).
  MushafReaderViewModel(this.profile);

  /// The active profile this reader is keyed to (used by T05's weak-line refs).
  final ProfileId profile;

  @override
  Future<MushafReaderScaffoldState> build() async {
    final edition = ref.watch(activeEditionProvider);
    return MushafReaderScaffoldState(edition: edition);
  }
}
