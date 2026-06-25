// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart' show CouldNotRollBackException;
import 'package:engine/engine.dart'
    show EngineConfig, ReviewInput, ReviewUpdate, SchedulingEngine, TrustClamp;
import 'package:models/models.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../db/database.dart';
import '../persistence_exception.dart';

/// The backup-restore write path (E17-T06; domain-backup-format §7). The shell
/// decodes a `.hifzbackup` into `models` value types and hands one profile's rows
/// here; this writes them back through the Drift store in ONE transaction, then
/// rebuilds each touched card's D/S/`dueAt` from the (merged) append-only
/// `review_log` and re-clamps it to **this** device's cycle ceiling (§7.6).
/// Replace and merge are separately confirmed by the caller; each is
/// all-or-nothing (a mid-import failure rolls back to the exact pre-import state).
abstract interface class RestoreRepository {
  /// REPLACE one profile: wipe its in-scope rows (FK cascade — `review_log` and
  /// `confusion_edge` have no per-row delete, so cascade is the only wipe) and
  /// insert the snapshot verbatim, re-clamping each card's `dueAt` to the local
  /// cycle ceiling. The Quran reference tables are never touched (R1).
  Future<void> replaceProfile({
    required Profile profile,
    required CycleConfig cycleConfig,
    required List<Card> cards,
    required List<LineBlock> lineBlocks,
    required List<ReviewLog> reviewLog,
    required List<ConfusionEdge> confusionEdges,
    required CalendarDate today,
  });

  /// MERGE one profile: a content-addressed **set union** over the append-only
  /// `review_log` by `logId` (idempotent — never an overwrite, never a duplicated
  /// sign-off), a union of line-blocks + confusion edges, then a rebuild of every
  /// card whose log gained a row, from the merged log. A profile absent locally
  /// is treated as a replace.
  Future<void> mergeProfile({
    required Profile profile,
    required CycleConfig cycleConfig,
    required List<Card> cards,
    required List<LineBlock> lineBlocks,
    required List<ReviewLog> reviewLog,
    required List<ConfusionEdge> confusionEdges,
    required CalendarDate today,
  });
}

/// The live [RestoreRepository] over the Drift [HifzDatabase] (E17-T06).
///
/// One outer `db.transaction` per restore with every query awaited (the
/// cold-start precedent), so a mid-import failure rolls back whole. The engine
/// recompute rides the same transaction — `data` already depends on `engine` —
/// so D/S/`dueAt` are rebuilt and re-clamped before the commit, never in a later
/// pass.
final class LiveRestoreRepository implements RestoreRepository {
  /// Creates the repository over the Drift [database].
  LiveRestoreRepository(this._database);

  final HifzDatabase _database;

  @override
  Future<void> replaceProfile({
    required Profile profile,
    required CycleConfig cycleConfig,
    required List<Card> cards,
    required List<LineBlock> lineBlocks,
    required List<ReviewLog> reviewLog,
    required List<ConfusionEdge> confusionEdges,
    required CalendarDate today,
  }) =>
      _guarded(
        () => _database.transaction(
          () => _replaceBody(
            profile: profile,
            cycleConfig: cycleConfig,
            cards: cards,
            lineBlocks: lineBlocks,
            reviewLog: reviewLog,
            confusionEdges: confusionEdges,
            today: today,
          ),
        ),
      );

  @override
  Future<void> mergeProfile({
    required Profile profile,
    required CycleConfig cycleConfig,
    required List<Card> cards,
    required List<LineBlock> lineBlocks,
    required List<ReviewLog> reviewLog,
    required List<ConfusionEdge> confusionEdges,
    required CalendarDate today,
  }) =>
      _guarded(
        () => _database.transaction(() async {
          final exists =
              await _database.profileDao.byId(profile.profileId) != null;
          if (!exists) {
            // A profile absent locally is a full restore — insert it whole.
            await _replaceBody(
              profile: profile,
              cycleConfig: cycleConfig,
              cards: cards,
              lineBlocks: lineBlocks,
              reviewLog: reviewLog,
              confusionEdges: confusionEdges,
              today: today,
            );
            return;
          }
          await _mergeBody(
            profileId: profile.profileId,
            cards: cards,
            lineBlocks: lineBlocks,
            reviewLog: reviewLog,
            confusionEdges: confusionEdges,
            today: today,
          );
        }),
      );

  // ── REPLACE: wipe (cascade) + insert verbatim + re-clamp dueAt ──────────────
  Future<void> _replaceBody({
    required Profile profile,
    required CycleConfig cycleConfig,
    required List<Card> cards,
    required List<LineBlock> lineBlocks,
    required List<ReviewLog> reviewLog,
    required List<ConfusionEdge> confusionEdges,
    required CalendarDate today,
  }) async {
    final engine = _engineFor(cycleConfig);
    // Delete-then-reinsert: the FK cascade purges card/line_block/review_log/
    // confusion_edge/cycle_config; the immutable reference tables never cascade.
    await _database.profileDao.deleteProfile(profile.profileId);
    await _database.profileDao.upsert(profile);
    await _database.cycleConfigDao.upsert(cycleConfig);
    // A full restore trusts the snapshot's D/S — only the due date is re-clamped
    // to this device's ceiling (an unmemorized card keeps its null due).
    await _database.cardDao.insertAll([
      for (final c in cards) _reclamp(engine, c, today),
    ]);
    for (final b in lineBlocks) {
      await _database.lineBlockDao.upsert(b);
    }
    for (final r in reviewLog) {
      await _database.reviewLogDao.insert(r);
    }
    for (final e in confusionEdges) {
      await _database.confusionEdgeDao.upsert(e);
    }
  }

  // ── MERGE: set-union the log + blocks + edges, rebuild touched cards ────────
  Future<void> _mergeBody({
    required ProfileId profileId,
    required List<Card> cards,
    required List<LineBlock> lineBlocks,
    required List<ReviewLog> reviewLog,
    required List<ConfusionEdge> confusionEdges,
    required CalendarDate today,
  }) async {
    // The receiving device's cycle governs the re-clamp; merge keeps it.
    final localCycle = await _database.cycleConfigDao.byProfile(profileId);
    final engine = localCycle == null
        ? SchedulingEngine(EngineConfig.defaults())
        : _engineFor(localCycle);

    // 1. review_log set-union by logId — insert only the absent ones (idempotent;
    //    never an overwrite or a duplicate of an existing *sanad* sign-off).
    final localLog = await _database.reviewLogDao.forProfile(profileId);
    final localLogIds = {for (final r in localLog) r.logId.value};
    final newRows = [
      for (final r in reviewLog)
        if (!localLogIds.contains(r.logId.value)) r,
    ];
    for (final r in newRows) {
      await _database.reviewLogDao.insert(r);
    }

    // 2. line_block union by blockId — insert absent; present → errorCount = max.
    final localBlocks = {
      for (final b in await _database.lineBlockDao.forProfile(profileId))
        b.blockId.value: b,
    };
    for (final b in lineBlocks) {
      final local = localBlocks[b.blockId.value];
      if (local == null) {
        await _database.lineBlockDao.upsert(b);
      } else if (b.errorCount > local.errorCount) {
        await _database.lineBlockDao.upsert(b);
      }
    }

    // 3. confusion union by (ayahA, ayahB) — weight = MAX (idempotent; NOT a sum:
    //    summing would break merge-idempotence, re-doubling on every re-merge),
    //    lastConfusedAt = the later day.
    final localEdges = {
      for (final e in await _database.confusionEdgeDao.forProfile(profileId))
        '${e.ayahA}|${e.ayahB}': e,
    };
    for (final e in confusionEdges) {
      final local = localEdges['${e.ayahA}|${e.ayahB}'];
      if (local == null) {
        await _database.confusionEdgeDao.upsert(e);
      } else {
        await _database.confusionEdgeDao.upsert(
          ConfusionEdge(
            profileId: profileId,
            ayahA: e.ayahA,
            ayahB: e.ayahB,
            weight: local.weight >= e.weight ? local.weight : e.weight,
            lastConfusedAt: _laterDay(local.lastConfusedAt, e.lastConfusedAt),
          ),
        );
      }
    }

    // 4. Rebuild every card whose log gained a row, from the MERGED log.
    final touchedPages = {for (final r in newRows) r.pageId};
    if (touchedPages.isEmpty) return;
    final mergedByPage = <int, List<ReviewLog>>{};
    for (final r in await _database.reviewLogDao.forProfile(profileId)) {
      (mergedByPage[r.pageId] ??= <ReviewLog>[]).add(r);
    }
    final localCards = {
      for (final c in await _database.cardDao.forProfile(profileId)) c.pageId: c,
    };
    final incomingCards = {for (final c in cards) c.pageId: c};
    for (final pageId in touchedPages) {
      final fallback = localCards[pageId] ?? incomingCards[pageId];
      if (fallback == null) continue; // no card to anchor the rebuild
      await _database.cardDao.upsert(
        _rebuildCardFromLog(
          pageId,
          mergedByPage[pageId] ?? const <ReviewLog>[],
          engine,
          today,
          fallback,
        ),
      );
    }
  }

  // ── The replay: rebuild a card's D/S/dueAt from its review_log ──────────────
  // Seed from the first row's stored before-state (the log persists
  // stabilityDaysBefore/difficultyBefore for exactly this), fold onReview
  // forward, then re-clamp (onReview's last step) under the receiving device's
  // cycle, and preserve the user/config flags the log does not carry.
  Card _rebuildCardFromLog(
    int pageId,
    List<ReviewLog> mergedPageLog,
    SchedulingEngine engine,
    CalendarDate today,
    Card fallback,
  ) {
    if (mergedPageLog.isEmpty) return _reclamp(engine, fallback, today);
    final logs = [...mergedPageLog]
      ..sort((a, b) => a.reviewedAtInstant.compareTo(b.reviewedAtInstant));
    final first = logs.first;
    var card = Card(
      profileId: fallback.profileId,
      pageId: pageId,
      track: first.trackAtReview,
      difficulty: first.difficultyBefore ?? fallback.difficulty,
      stabilityDays: first.stabilityDaysBefore ?? fallback.stabilityDays,
    );
    for (final log in logs) {
      final errorLines = log.errorLineIndices ?? const <int>[];
      card = engine.onReview(
        card,
        ReviewInput(
          grade: log.grade,
          source: log.source,
          errorLines: errorLines,
          // missedOrAlteredWord defaults false: the sacred-text cap is already
          // baked into the stored grade, so a re-cap is a no-op (the flag is
          // not persisted).
        ),
        _dayOf(log.reviewedAtInstant),
        weakLineCount: errorLines.length,
      );
    }
    return card.copyWith(
      hasManualLock: fallback.hasManualLock,
      isPrayerCritical: fallback.isPrayerCritical,
      isEnabled: fallback.isEnabled,
    );
  }

  /// Re-clamps a memorized card's due date to this device's ceiling (§7.6); an
  /// unmemorized card (null due) passes through unchanged.
  Card _reclamp(SchedulingEngine engine, Card card, CalendarDate today) =>
      card.dueAt == null
          ? card
          : card.copyWith(dueAt: engine.trustClamp(card, today));

  /// Builds the engine from a persisted cycle config.
  // NOTE: duplicated from composition._engineConfigFor (data cannot import
  // composition); keep in sync.
  SchedulingEngine _engineFor(CycleConfig config) {
    final defaultNear = EngineConfig.defaults().nearCeilingDays;
    return SchedulingEngine(
      EngineConfig(
        farCycleDays: config.cycleCeilingDays,
        nearCeilingDays: config.cycleCeilingDays < defaultNear
            ? config.cycleCeilingDays
            : defaultNear,
        pureCycleMode: config.isPureCycleMode,
        dailyBudgetMinutes: config.dailyBudgetMinutes,
      ),
    );
  }

  CalendarDate _dayOf(DateTime instant) {
    final utc = instant.toUtc();
    return CalendarDate.ymd(utc.year, utc.month, utc.day);
  }

  CalendarDate? _laterDay(CalendarDate? a, CalendarDate? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.epochDay >= b.epochDay ? a : b;
  }

  Future<void> _guarded(Future<void> Function() body) async {
    try {
      await body();
    } on CouldNotRollBackException {
      throw const RestoreRollbackFailed();
    } on SqliteException {
      throw const RestoreConstraintViolated();
    } on Exception {
      throw const RestoreFailed();
    }
  }
}
