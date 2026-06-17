// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/database.dart';
import 'package:data/src/persistence_exception.dart';
import 'package:data/src/repositories/review_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  const profileId = ProfileId('p');

  late HifzDatabase db;
  late LiveReviewRepository repository;

  setUp(() async {
    db = openTestDatabase();
    // Isolate the transaction semantics from referential integrity: the CHECK
    // that the rollback case trips still applies (E03-T03 owns the FK cascade).
    await db.customStatement('PRAGMA foreign_keys = OFF;');
    repository = LiveReviewRepository(db);
  });
  tearDown(() async => db.close());

  ReviewLog logRow(String id, int pageId) => ReviewLog(
        logId: LogId(id),
        profileId: profileId,
        pageId: pageId,
        reviewedAtInstant: DateTime.utc(2026, 6, 17, 21),
        trackAtReview: ReviewTrack.far,
        grade: ReviewGrade.good,
        elapsedDays: 7,
        source: GradeSource.self,
      );

  Card card(int pageId, {double difficulty = 6}) => Card(
        profileId: profileId,
        pageId: pageId,
        track: ReviewTrack.far,
        difficulty: difficulty,
        stabilityDays: 20,
        lastReviewedDay: CalendarDate.ymd(2026, 6, 17),
        dueAt: CalendarDate.ymd(2026, 6, 24),
        reps: 5,
      );

  ReviewOutcome outcome(
    String logId,
    int pageId, {
    double difficulty = 6,
    List<LineBlock> blocks = const [],
    List<ConfusionEdge> bumps = const [],
  }) =>
      ReviewOutcome(
        logRow: logRow(logId, pageId),
        cardUpdate: card(pageId, difficulty: difficulty),
        newLineBlocks: blocks,
        confusionBumps: bumps,
      );

  Future<List<ReviewLog>> logsForProfile() =>
      db.reviewLogDao.forProfile(profileId);
  Future<List<ReviewLog>> logsForPage(int p) =>
      db.reviewLogDao.forCard(profileId, p);

  test('a thrown step rolls back fully — nothing is committed', () async {
    // The card upsert (step 2) trips CHECK (d BETWEEN 1 AND 10); step 1 (the
    // review_log append) must roll back with it.
    await expectLater(
      repository.commitReview(outcome('l1', 1, difficulty: 11)),
      throwsA(isA<ReviewWriteException>()),
    );

    expect(await logsForProfile(), isEmpty);
    expect(await db.cardDao.byId(profileId, 1), isNull);
    expect(await db.lineBlockDao.forCard(profileId, 1), isEmpty);
    expect(await db.confusionEdgeDao.forProfile(profileId), isEmpty);
  });

  test('the happy path commits the audit row, card, line-block, and edge',
      () async {
    await repository.commitReview(
      outcome(
        'l1',
        1,
        blocks: const [
          LineBlock(
            blockId: BlockId('b1'),
            profileId: profileId,
            pageId: 1,
            lineStart: 1,
            lineEnd: 5,
            errorCount: 1,
          ),
        ],
        bumps: [
          ConfusionEdge.between(profileId, '2:1', '2:2', weight: 1),
        ],
      ),
    );

    expect(await logsForPage(1), hasLength(1));
    final stored = await db.cardDao.byId(profileId, 1);
    if (stored == null) fail('card was not committed');
    // Consume-not-recompute: due_at equals the outcome's verbatim.
    expect(stored.dueAt, CalendarDate.ymd(2026, 6, 24));
    expect(stored.difficulty, closeTo(6, 1e-6));
    expect(stored.reps, 5);
    expect(await db.lineBlockDao.forCard(profileId, 1), hasLength(1));
    expect(await db.confusionEdgeDao.forProfile(profileId), hasLength(1));
  });

  test('empty optionals write neither line_block nor confusion_edge', () async {
    await repository.commitReview(outcome('l1', 1));
    expect(await db.lineBlockDao.forCard(profileId, 1), isEmpty);
    expect(await db.confusionEdgeDao.forProfile(profileId), isEmpty);
    expect(await logsForPage(1), hasLength(1));
  });

  test('append-only: a second review for the same page adds a new row',
      () async {
    await repository.commitReview(outcome('l1', 1));
    await repository.commitReview(outcome('l2', 1));
    final logs = await logsForPage(1);
    expect(
      logs.map((l) => l.logId).toSet(),
      {const LogId('l1'), const LogId('l2')},
    );
  });

  test('memory is never newer than disk: a failed commit leaves last state',
      () async {
    await repository.commitReview(outcome('l1', 1));
    // A failing commit for page 2 must not alter the committed page-1 state.
    await expectLater(
      repository.commitReview(outcome('l2', 2, difficulty: 11)),
      throwsA(isA<ReviewWriteException>()),
    );

    expect(await logsForProfile(), hasLength(1));
    expect(await db.cardDao.byId(profileId, 1), isNotNull);
    expect(await db.cardDao.byId(profileId, 2), isNull);
  });
}
