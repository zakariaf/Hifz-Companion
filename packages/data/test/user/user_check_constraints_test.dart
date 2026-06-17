// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;

  setUp(() async {
    db = openTestDatabase();
    // Isolate CHECK behaviour from referential integrity: FK off, so a row that
    // satisfies the CHECKs but references nothing still inserts.
    await db.customStatement('PRAGMA foreign_keys = OFF;');
  });
  tearDown(() async => db.close());

  final rejected = throwsA(isA<SqliteException>());

  // A valid card INSERT template; callers override the field under test.
  Future<void> insertCard({
    String track = 'FAR',
    String due = '20000',
    String d = '5',
    String s = '10',
    String reps = '0',
  }) {
    return db.customStatement(
      'INSERT INTO card (profile_id, page_id, track, d, s, due_at, reps, '
      'lapses, weak_flag, signoffs, manual_lock, prayer_critical, enabled) '
      "VALUES ('p', 1, '$track', $d, $s, $due, $reps, 0, 0, 0, 0, 0, 1)",
    );
  }

  group('profile enum CHECKs', () {
    test('role outside the set is rejected', () async {
      await expectLater(
        db.customStatement(
          "INSERT INTO profile (profile_id, display_name, role, locale, "
          "mushaf_id, created_at) VALUES ('p', 'A', 'imam', 'fa', 'm', 't')",
        ),
        rejected,
      );
    });
    test('locale outside the set is rejected', () async {
      await expectLater(
        db.customStatement(
          "INSERT INTO profile (profile_id, display_name, role, locale, "
          "mushaf_id, created_at) VALUES ('p', 'A', 'self', 'en', 'm', 't')",
        ),
        rejected,
      );
    });
  });

  group('card enum + range CHECKs', () {
    test('track / d / s out of range are rejected', () async {
      await expectLater(insertCard(track: 'GOLD'), rejected);
      await expectLater(insertCard(d: '0'), rejected);
      await expectLater(insertCard(d: '11'), rejected);
      await expectLater(insertCard(s: '-1'), rejected);
      await expectLater(insertCard(reps: '-1'), rejected);
    });

    test('the load-bearing memorized-card invariant', () async {
      // track != UNMEMORIZED with a NULL due_at is rejected...
      await expectLater(insertCard(track: 'NEW', due: 'NULL'), rejected);
      // ...while an UNMEMORIZED card with a NULL due_at is allowed.
      await insertCard(track: 'UNMEMORIZED', due: 'NULL');
      final count = await db
          .customSelect("SELECT COUNT(*) AS n FROM card WHERE track = "
              "'UNMEMORIZED'")
          .getSingle();
      expect(count.read<int>('n'), 1);
    });
  });

  group('review_log + line_block + cycle_config CHECKs', () {
    test('grade / source outside their sets are rejected', () async {
      Future<void> insertLog(String grade, String source) => db.customStatement(
            'INSERT INTO review_log (log_id, profile_id, page_id, reviewed_at, '
            'track_at_review, grade, elapsed_days, source) '
            "VALUES ('l', 'p', 1, 't', 'FAR', '$grade', 3, '$source')",
          );
      await expectLater(insertLog('perfect', 'self'), rejected);
      await expectLater(insertLog('good', 'app'), rejected);
    });

    test('line_start/line_end range and ordering are rejected', () async {
      Future<void> insertBlock(String start, String end) => db.customStatement(
            'INSERT INTO line_block (block_id, profile_id, page_id, line_start, '
            "line_end, error_count) VALUES ('b', 'p', 1, $start, $end, 0)",
          );
      await expectLater(insertBlock('0', '5'), rejected); // start < 1
      await expectLater(insertBlock('5', '3'), rejected); // end < start
      await expectLater(insertBlock('1', '16'), rejected); // end > 15
    });

    test('far_cycle_days and daily_budget_minutes must be > 0', () async {
      Future<void> insertConfig(String cycle, String budget) =>
          db.customStatement(
            'INSERT INTO cycle_config (profile_id, cycle_type, '
            'new_lines_per_day, near_window_juz, far_target_per_day, '
            'far_cycle_days, daily_budget_minutes, pure_cycle_mode, '
            "term_label_set) VALUES ('p', 'custom', 0, 1, 1, $cycle, "
            "$budget, 0, 'plain')",
          );
      await expectLater(insertConfig('0', '20'), rejected);
      await expectLater(insertConfig('7', '0'), rejected);
    });
  });

  group('confusion_edge canonical CHECK (ayah_a < ayah_b)', () {
    Future<void> insertEdge(String a, String b) => db.customStatement(
          'INSERT INTO confusion_edge (profile_id, ayah_a, ayah_b, weight) '
          "VALUES ('p', '$a', '$b', 0)",
        );
    test('reversed pair and self-loop are rejected; ordered pair allowed',
        () async {
      await expectLater(insertEdge('2:2', '2:1'), rejected);
      await expectLater(insertEdge('2:1', '2:1'), rejected);
      await insertEdge('2:1', '2:2');
      final count = await db
          .customSelect('SELECT COUNT(*) AS n FROM confusion_edge')
          .getSingle();
      expect(count.read<int>('n'), 1);
    });
  });

  group('boolean flag CHECK (col IN (0,1))', () {
    test('a flag set to 2 is rejected', () async {
      await expectLater(
        db.customStatement(
          'INSERT INTO card (profile_id, page_id, track, d, s, due_at, reps, '
          'lapses, weak_flag, signoffs, manual_lock, prayer_critical, enabled) '
          "VALUES ('p', 1, 'FAR', 5, 10, 20000, 0, 0, 2, 0, 0, 0, 1)",
        ),
        rejected,
      );
    });
  });
}
