// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:models/models.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../db/database.dart';
import '../persistence_exception.dart';

/// The weight a confusion edge is created with on the **first** logged swap of a
/// pair (PRD §10.2; science 05 §7).
const double kInitialConfusionWeight = 1;

/// The fixed increment a repeat swap of the same pair adds (plain bookkeeping —
/// no ML, no inference).
const double kConfusionWeightIncrement = 1;

/// The saturation ceiling for a confusion edge's weight, so the running count
/// stays bounded and monotonic (the engine clamps the resulting `D` bump to
/// `[1,10]` regardless, E14-T04 — this keeps the stored value honest).
const double kMaxConfusionWeight = 10;

/// The next weight for a pair already confused [prior] times — a small pure,
/// monotonic, bounded function of the user's **own** logged-swap history.
///
/// `min(prior + kConfusionWeightIncrement, kMaxConfusionWeight)`. Deterministic
/// and never an inferred/trained value (no decay-over-time here — that would be a
/// separate, explicitly-scoped change).
double nextConfusionWeight(double prior) =>
    math.min(prior + kConfusionWeightIncrement, kMaxConfusionWeight);

/// The single write path for a wrong-branch **swap** between two āyāt — the
/// personal confusion log grown from the user's own logged swaps (PRD §9.1,
/// §10.2; 06 §4).
abstract interface class ConfusionRepository {
  /// Records a wrong-branch swap between [ayahX] and [ayahY] for [profileId],
  /// strengthening (or creating) the single canonical-ordered `confusion_edge`
  /// at **full strength regardless of source** — only the engine's stability
  /// move is source-scaled (06 §4); this weight never is.
  ///
  /// The pair is ordered into `(ayah_a < ayah_b)` form internally, so the same
  /// swap logged in either direction strengthens the **same** row.
  /// `last_confused_at` is stamped from the injected [today] (a `CalendarDate`),
  /// never a wall clock. One `db.transaction`, committed before the `Future`
  /// resolves (persist-before-republish). Throws a [ConfusionWriteException] and
  /// commits nothing on failure.
  Future<void> logSwap({
    required ProfileId profileId,
    required String ayahX,
    required String ayahY,
    required CalendarDate today,
  });

  /// The reactive per-profile confusion-edge stream, ranked most-confused first
  /// (`weight` DESC, then `last_confused_at` DESC) — the calm hotspots read
  /// model (E14-T06/T10). It re-emits after every committed [logSwap], so the
  /// View rebuilds from the durable store, never a second cache.
  Stream<List<ConfusionEdge>> watchEdgesForProfile(ProfileId profileId);
}

/// The live [ConfusionRepository] over the Drift [HifzDatabase] (05 §3).
///
/// Pure bookkeeping layered on the one write path: it reads the existing edge,
/// computes the next [nextConfusionWeight], and upserts — no FSRS state, no `D`/
/// `S`/`dueAt` mutation, no sibling massing (those are E14-T04 / E14-T05). The
/// returned `Future` resolves only after the durable commit, so the controller
/// republishes strictly after; the `confusion_edge` `StreamProvider` re-emits on
/// its own (E14-T06).
final class LiveConfusionRepository implements ConfusionRepository {
  /// Creates the repository over the Drift [database].
  LiveConfusionRepository(this._database);

  final HifzDatabase _database;

  @override
  Future<void> logSwap({
    required ProfileId profileId,
    required String ayahX,
    required String ayahY,
    required CalendarDate today,
  }) async {
    assert(ayahX != ayahY, 'a swap is between two distinct āyāt');
    // Canonical ordering inside the method — the same swap in either direction
    // lands on one row (the CHECK (ayah_a < ayah_b) is the storage backstop).
    final ordered = ayahX.compareTo(ayahY) <= 0;
    final ayahA = ordered ? ayahX : ayahY;
    final ayahB = ordered ? ayahY : ayahX;
    try {
      await _database.transaction(() async {
        final existing = await _database.confusionEdgeDao.edgeFor(
          profileId: profileId,
          ayahOne: ayahA,
          ayahTwo: ayahB,
        );
        // Full strength regardless of source: the weight has no source input.
        final weight = existing == null
            ? kInitialConfusionWeight
            : nextConfusionWeight(existing.weight);
        await _database.confusionEdgeDao.upsert(
          ConfusionEdge(
            profileId: profileId,
            ayahA: ayahA,
            ayahB: ayahB,
            weight: weight,
            lastConfusedAt: today,
          ),
        );
      });
    } on CouldNotRollBackException {
      throw const ConfusionRollbackFailed();
    } on SqliteException {
      throw const ConfusionConstraintViolated();
    } on Exception {
      throw const ConfusionTransactionFailed();
    }
  }

  @override
  Stream<List<ConfusionEdge>> watchEdgesForProfile(ProfileId profileId) =>
      _database.confusionEdgeDao.watchEdgesForProfile(profileId);
}
