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
@DriftAccessor(tables: [ConfusionEdges])
class ConfusionEdgeDao extends DatabaseAccessor<HifzDatabase>
    with _$ConfusionEdgeDaoMixin {
  /// Creates the DAO over [db].
  ConfusionEdgeDao(super.db);

  /// Inserts or bumps the edge for its `(profileId, ayahA, ayahB)` key.
  Future<void> upsert(ConfusionEdge edge) =>
      into(confusionEdges).insertOnConflictUpdate(_toCompanion(edge));

  /// All confusion edges for a profile.
  Future<List<ConfusionEdge>> forProfile(ProfileId profileId) async {
    final query = select(confusionEdges)
      ..where((e) => e.profileId.equals(profileId.value));
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  ConfusionEdge _toModel(ConfusionEdgeRow row) {
    final lastConfusedAt = row.lastConfusedAt;
    return ConfusionEdge(
      profileId: ProfileId(row.profileId),
      ayahA: row.ayahA,
      ayahB: row.ayahB,
      weight: row.weight,
      lastConfusedAtInstant:
          lastConfusedAt == null ? null : instantFromWire(lastConfusedAt),
    );
  }

  ConfusionEdgesCompanion _toCompanion(ConfusionEdge edge) {
    final lastConfusedAt = edge.lastConfusedAtInstant;
    return ConfusionEdgesCompanion(
      profileId: Value(edge.profileId.value),
      ayahA: Value(edge.ayahA),
      ayahB: Value(edge.ayahB),
      weight: Value(edge.weight),
      lastConfusedAt: Value(
        lastConfusedAt == null ? null : instantToWire(lastConfusedAt),
      ),
    );
  }
}
