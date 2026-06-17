// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../db/test_database.dart';
import '../test_setup.dart';
import 'schema/schema.dart';

/// The release-blocking migration fixture harness. It is the one code path that
/// touches every user's entire hifz history, so it carries the strongest test
/// discipline: a populated `v(n−1)` database is migrated through the real
/// `stepByStep` strategy, its schema is validated against the committed
/// snapshot, every seeded row is asserted to have **survived**, and
/// `PRAGMA integrity_check` must return `ok`.
///
/// At v1 the harness runs against the `startAt(1)` self-identity baseline so the
/// first real migration in a later epic plugs into a harness already proven.
/// Each future version bump adds ONE identically-shaped test:
///   `startAt(n-1)` → seed → `migrateAndValidate(db, n)` → survival + integrity.
/// The harness shape never changes. Restore (E17 / .hifzbackup) does NOT replay
/// these SQL migrations — it maps any supported payload version forward onto the
/// current schema, so this harness governs the live-DB upgrade path only.
void main() {
  useOfflineTestPolicy();

  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test(
      'v1 baseline: a populated store validates, content survives, '
      'integrity_check is ok', () async {
    final connection = await verifier.startAt(1);
    final db = HifzDatabase(connection);
    // Seed with FK off so the user rows need no reference fixture — this test
    // proves content/schema survival, not referential integrity (E03-T03).
    await db.customStatement('PRAGMA foreign_keys = OFF;');

    await db.customStatement(
      "INSERT INTO profile (profile_id, display_name, role, locale, mushaf_id, "
      "created_at) VALUES ('p', 'Aisha', 'self', 'fa', 'm1', "
      "'2026-01-05T08:00:00.000Z')",
    );
    // A memorized FAR card (due_at non-null) and an UNMEMORIZED card (due null).
    await db.customStatement(
      'INSERT INTO card (profile_id, page_id, track, d, s, due_at, '
      'last_review_at, reps, lapses, weak_flag, signoffs, manual_lock, '
      "prayer_critical, enabled) VALUES ('p', 1, 'FAR', 6, 30, 20620, 20610, "
      '5, 1, 0, 2, 0, 1, 1)',
    );
    await db.customStatement(
      'INSERT INTO card (profile_id, page_id, track, d, s, due_at, '
      'last_review_at, reps, lapses, weak_flag, signoffs, manual_lock, '
      "prayer_critical, enabled) VALUES ('p', 2, 'UNMEMORIZED', 5, 0, NULL, "
      'NULL, 0, 0, 0, 0, 0, 0, 1)',
    );
    // The append-only sanad audit row — the highest-stakes content to preserve.
    await db.customStatement(
      'INSERT INTO review_log (log_id, profile_id, page_id, reviewed_at, '
      'track_at_review, grade, error_lines_json, elapsed_days, source) '
      "VALUES ('l1', 'p', 1, '2026-06-17T21:30:00.000Z', 'FAR', 'good', "
      "'[3,7]', 18, 'self')",
    );
    await db.customStatement(
      'INSERT INTO cycle_config (profile_id, cycle_type, new_lines_per_day, '
      'near_window_juz, far_target_per_day, far_cycle_days, '
      'daily_budget_minutes, pure_cycle_mode, term_label_set) '
      "VALUES ('p', '7_manzil', 0, 3, 4, 7, 45, 0, 'classical')",
    );
    await db.customStatement(
      'INSERT INTO confusion_edge (profile_id, ayah_a, ayah_b, weight) '
      "VALUES ('p', '2:1', '2:2', 1)",
    );

    // Migrate (self-identity at v1) and validate the schema against the
    // committed v1 snapshot.
    await verifier.migrateAndValidate(db, 1);

    // CONTENT survived, byte-intact — especially the review_log sanad row.
    final logs = await db.customSelect('SELECT * FROM review_log').get();
    expect(logs, hasLength(1));
    final log = logs.single;
    expect(log.read<String>('grade'), 'good');
    expect(log.read<String>('source'), 'self');
    expect(log.read<String>('reviewed_at'), '2026-06-17T21:30:00.000Z');
    expect(log.read<int>('elapsed_days'), 18);
    expect(log.read<String>('error_lines_json'), '[3,7]');

    final cards = await db.customSelect('SELECT * FROM card').get();
    expect(cards, hasLength(2));
    final far = await db
        .customSelect("SELECT due_at FROM card WHERE page_id = 1")
        .getSingle();
    expect(far.read<int>('due_at'), 20620); // serial-day intact

    final integrity = await db.customSelect('PRAGMA integrity_check;').get();
    expect(integrity.single.data.values.first, 'ok');

    await db.close();
  });

  test('a freshly created store carries app_meta.schema_version = "1"',
      () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    // openTestDatabase triggers onCreate -> createAll + the schema_version
    // singleton insert (the forward-mapping anchor restore reads, E17).
    expect(await db.appMetaDao.get('schema_version'), '1');
  });
}
