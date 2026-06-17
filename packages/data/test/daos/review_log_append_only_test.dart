// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

/// The audit trail is append-only — nothing decays silently. The property is
/// enforced by the *absence* of any mutation method on [ReviewLogDao]; there is
/// no API to mutate or remove an appended row. The only sanctioned bulk touch
/// is export / one-tap erase (E17).
void main() {
  useOfflineTestPolicy();

  test('ReviewLogDao declares no update/delete/replace/clear mutation method',
      () {
    final dao = [
      File('lib/src/db/daos/review_log_dao.dart'),
      File('packages/data/lib/src/db/daos/review_log_dao.dart'),
    ].firstWhere(
      (f) => f.existsSync(),
      orElse: () => fail('review_log_dao.dart not found from '
          '${Directory.current.path}'),
    );
    final source = dao.readAsStringSync();
    // A method-declaration form for a mutation that must not exist on the DAO.
    for (final forbidden in const [
      'update(',
      'delete(',
      'deleteWhere(',
      'replace(',
      'clear(',
      'deleteAll(',
    ]) {
      expect(
        source.contains(forbidden),
        isFalse,
        reason: 'ReviewLogDao must expose no "$forbidden" — the review_log is '
            'append-only (sanad); enforced by absence (PRD §10.3)',
      );
    }
  });

  test(
      'insert then forCard returns the appended row (insert is the only write)',
      () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    await db.customStatement('PRAGMA foreign_keys = OFF;');

    await db.reviewLogDao.insert(
      ReviewLog(
        logId: const LogId('l1'),
        profileId: const ProfileId('p'),
        pageId: 1,
        reviewedAtInstant: DateTime.utc(2026, 6, 17),
        trackAtReview: ReviewTrack.far,
        grade: ReviewGrade.good,
        elapsedDays: 7,
        source: GradeSource.self,
      ),
    );
    final rows = await db.reviewLogDao.forCard(const ProfileId('p'), 1);
    expect(rows, hasLength(1));
    expect(rows.single.logId, const LogId('l1'));
  });
}
