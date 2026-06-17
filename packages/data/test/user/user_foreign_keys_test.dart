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
    await db.customStatement('PRAGMA foreign_keys = ON;');
  });
  tearDown(() async => db.close());

  final rejected = throwsA(isA<SqliteException>());

  Future<void> seedReferenceAndProfile() async {
    await db.customStatement(
      "INSERT INTO mushaf (mushaf_id, riwayah, name, line_count, page_count, "
      "font_family, checksum_sha256) "
      "VALUES ('m1', 'hafs_an_asim', 'Madani', 15, 604, 'QCF', 'abc')",
    );
    await db.customStatement(
      "INSERT INTO surah (surah_id, name_ar, revelation, ayah_count, "
      "bismillah_pre) VALUES (2, 'البقرة', 'medinan', 286, 1)",
    );
    await db.customStatement(
      'INSERT INTO page (page_id, juz, hizb, rub, surah_start, ayah_start, '
      "surah_end, ayah_end, line_count, qpc_font_name) "
      "VALUES (1, 1, 1, 1, 2, 1, 2, 5, 15, 'QCF_P001')",
    );
    await db.customStatement(
      "INSERT INTO ayah (ayah_id, surah, ayah, page_id, line_refs_json, sajda) "
      "VALUES ('2:1', 2, 1, 1, '[]', 0)",
    );
    await db.customStatement(
      "INSERT INTO ayah (ayah_id, surah, ayah, page_id, line_refs_json, sajda) "
      "VALUES ('2:2', 2, 2, 1, '[]', 0)",
    );
    await db.customStatement(
      "INSERT INTO profile (profile_id, display_name, role, locale, mushaf_id, "
      "created_at) VALUES ('p1', 'A', 'self', 'fa', 'm1', "
      "'2026-01-01T00:00:00Z')",
    );
  }

  Future<void> seedAllChildren() async {
    await db.customStatement(
      'INSERT INTO card (profile_id, page_id, track, d, s, due_at, reps, '
      'lapses, weak_flag, signoffs, manual_lock, prayer_critical, enabled) '
      "VALUES ('p1', 1, 'FAR', 5, 10, 20000, 1, 0, 0, 0, 0, 0, 1)",
    );
    await db.customStatement(
      'INSERT INTO line_block (block_id, profile_id, page_id, line_start, '
      "line_end, error_count) VALUES ('b1', 'p1', 1, 1, 5, 0)",
    );
    await db.customStatement(
      'INSERT INTO review_log (log_id, profile_id, page_id, reviewed_at, '
      'track_at_review, grade, elapsed_days, source) '
      "VALUES ('l1', 'p1', 1, '2026-06-17T00:00:00Z', 'FAR', 'good', 7, 'self')",
    );
    await db.customStatement(
      'INSERT INTO confusion_edge (profile_id, ayah_a, ayah_b, weight) '
      "VALUES ('p1', '2:1', '2:2', 1)",
    );
    await db.customStatement(
      'INSERT INTO cycle_config (profile_id, cycle_type, new_lines_per_day, '
      'near_window_juz, far_target_per_day, far_cycle_days, '
      'daily_budget_minutes, pure_cycle_mode, term_label_set) '
      "VALUES ('p1', '7_manzil', 0, 3, 4, 7, 45, 0, 'classical')",
    );
  }

  Future<int> countOf(String table) async {
    final row =
        await db.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle();
    return row.read<int>('n');
  }

  group('foreign keys reject dangling references', () {
    test('a child referencing a missing profile is rejected', () async {
      await seedReferenceAndProfile();
      await expectLater(
        db.customStatement(
          'INSERT INTO card (profile_id, page_id, track, d, s, due_at, reps, '
          'lapses, weak_flag, signoffs, manual_lock, prayer_critical, enabled) '
          "VALUES ('ghost', 1, 'FAR', 5, 10, 20000, 0, 0, 0, 0, 0, 0, 1)",
        ),
        rejected,
      );
    });

    test('a card referencing a missing page is rejected', () async {
      await seedReferenceAndProfile();
      await expectLater(
        db.customStatement(
          'INSERT INTO card (profile_id, page_id, track, d, s, due_at, reps, '
          'lapses, weak_flag, signoffs, manual_lock, prayer_critical, enabled) '
          "VALUES ('p1', 999, 'FAR', 5, 10, 20000, 0, 0, 0, 0, 0, 0, 1)",
        ),
        rejected,
      );
    });

    test('a confusion_edge referencing a missing ayah is rejected', () async {
      await seedReferenceAndProfile();
      await expectLater(
        db.customStatement(
          'INSERT INTO confusion_edge (profile_id, ayah_a, ayah_b, weight) '
          "VALUES ('p1', '2:1', '9:9', 0)",
        ),
        rejected,
      );
    });

    test('a profile referencing a missing mushaf is rejected', () async {
      await expectLater(
        db.customStatement(
          "INSERT INTO profile (profile_id, display_name, role, locale, "
          "mushaf_id, created_at) VALUES ('p2', 'B', 'self', 'fa', 'ghost', "
          "'2026-01-01T00:00:00Z')",
        ),
        rejected,
      );
    });
  });

  group('ON DELETE CASCADE for per-profile children', () {
    test('deleting a profile deletes all five children; reference rows survive',
        () async {
      await seedReferenceAndProfile();
      await seedAllChildren();
      expect(await countOf('card'), 1);
      expect(await countOf('line_block'), 1);
      expect(await countOf('review_log'), 1);
      expect(await countOf('confusion_edge'), 1);
      expect(await countOf('cycle_config'), 1);

      await db.customStatement("DELETE FROM profile WHERE profile_id = 'p1'");

      expect(await countOf('card'), 0);
      expect(await countOf('line_block'), 0);
      expect(await countOf('review_log'), 0);
      expect(await countOf('confusion_edge'), 0);
      expect(await countOf('cycle_config'), 0);

      // The immutable reference rows are untouched by a profile delete.
      expect(await countOf('page'), 1);
      expect(await countOf('ayah'), 2);
      expect(await countOf('mushaf'), 1);
    });
  });
}
