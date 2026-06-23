// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart';

import '../database.dart';
import '../tables/user/confusion_edges.dart';
import 'mappers.dart';

part 'confusion_edge_dao.g.dart';

/// Reads and upserts `confusion_edge` rows as `models.ConfusionEdge` value
/// types — the canonical `ayahA < ayahB` ordering is the schema's job (05 §2).
///
/// Append-grow-only: there is no `delete`/`clear`/`update` method (the only bulk
/// touch is export/erase, E17). `last_confused_at` is a `CalendarDate` serial
/// day, never a `DateTime` instant (07 §1).
@DriftAccessor(tables: [ConfusionEdges])
class ConfusionEdgeDao extends DatabaseAccessor<HifzDatabase>
    with _$ConfusionEdgeDaoMixin {
  /// Creates the DAO over [db].
  ConfusionEdgeDao(super.db);

  /// Inserts or strengthens the edge for its `(profileId, ayahA, ayahB)` key
  /// (the create-or-strengthen primitive; the weight rule is E14-T03).
  Future<void> upsert(ConfusionEdge edge) =>
      into(confusionEdges).insertOnConflictUpdate(_toCompanion(edge));

  /// The single canonical-ordered edge for the unordered pair, or null.
  ///
  /// Orders `(ayahOne, ayahTwo)` into `(ayah_a < ayah_b)` form before the lookup
  /// so a pair queried in either direction resolves to the same row.
  Future<ConfusionEdge?> edgeFor({
    required ProfileId profileId,
    required String ayahOne,
    required String ayahTwo,
  }) async {
    final ordered = ayahOne.compareTo(ayahTwo) <= 0;
    final ayahA = ordered ? ayahOne : ayahTwo;
    final ayahB = ordered ? ayahTwo : ayahOne;
    final query = select(confusionEdges)
      ..where(
        (e) =>
            e.profileId.equals(profileId.value) &
            e.ayahA.equals(ayahA) &
            e.ayahB.equals(ayahB),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// All confusion edges for a profile.
  Future<List<ConfusionEdge>> forProfile(ProfileId profileId) async {
    final query = select(confusionEdges)
      ..where((e) => e.profileId.equals(profileId.value));
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  /// The reactive per-profile edge stream, ranked most-confused first
  /// (`weight` DESC, then `last_confused_at` DESC) — the calm hotspots ordering
  /// is data-supplied, not view-computed (E14-T06).
  Stream<List<ConfusionEdge>> watchEdgesForProfile(ProfileId profileId) {
    final query = select(confusionEdges)
      ..where((e) => e.profileId.equals(profileId.value))
      ..orderBy([
        (e) => OrderingTerm.desc(e.weight),
        (e) => OrderingTerm.desc(e.lastConfusedAt),
      ]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  ConfusionEdge _toModel(ConfusionEdgeRow row) => ConfusionEdge(
        profileId: ProfileId(row.profileId),
        ayahA: row.ayahA,
        ayahB: row.ayahB,
        weight: row.weight,
        lastConfusedAt: calendarDateFromSerial(row.lastConfusedAt),
      );

  ConfusionEdgesCompanion _toCompanion(ConfusionEdge edge) =>
      ConfusionEdgesCompanion(
        profileId: Value(edge.profileId.value),
        ayahA: Value(edge.ayahA),
        ayahB: Value(edge.ayahB),
        weight: Value(edge.weight),
        lastConfusedAt: Value(serialFromCalendarDate(edge.lastConfusedAt)),
      );
}
