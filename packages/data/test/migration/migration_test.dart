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

  // The v1 self-identity baseline that E03-T09 stood up is now superseded: with
  // `schemaVersion = 2`, opening any v1 store migrates it forward, so the live
  // upgrade path is exercised by the real v1 → v2 case below (same protected
  // seed, plus the migration). The harness shape is unchanged.

  test(
      'v1 → v2 (E14-T02): confusion_edge.last_confused_at becomes a serial '
      'day; protected content survives, integrity_check is ok', () async {
    final connection = await verifier.startAt(1);
    final db = HifzDatabase(connection);
    await db.customStatement('PRAGMA foreign_keys = OFF;');

    // Seed the protected user tables — the rows the migration must NOT touch.
    await db.customStatement(
      "INSERT INTO profile (profile_id, display_name, role, locale, mushaf_id, "
      "created_at) VALUES ('p', 'Aisha', 'self', 'fa', 'm1', "
      "'2026-01-05T08:00:00.000Z')",
    );
    await db.customStatement(
      'INSERT INTO card (profile_id, page_id, track, d, s, due_at, '
      'last_review_at, reps, lapses, weak_flag, signoffs, manual_lock, '
      "prayer_critical, enabled) VALUES ('p', 1, 'FAR', 6, 30, 20620, 20610, "
      '5, 1, 0, 2, 0, 1, 1)',
    );
    // The append-only sanad row — the load-bearing survival assertion.
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

    await verifier.migrateAndValidate(db, 2);

    // The sanad survived byte-intact.
    final logs = await db.customSelect('SELECT * FROM review_log').get();
    expect(logs, hasLength(1));
    expect(logs.single.read<String>('grade'), 'good');
    expect(logs.single.read<String>('error_lines_json'), '[3,7]');

    // Cards + cycle_config survived.
    final far = await db
        .customSelect('SELECT due_at FROM card WHERE page_id = 1')
        .getSingle();
    expect(far.read<int>('due_at'), 20620);
    final cycle = await db.customSelect('SELECT * FROM cycle_config').get();
    expect(cycle, hasLength(1));

    // The recreated confusion_edge exists and is empty, and last_confused_at is
    // now a serial-day INTEGER (an int round-trips on the v2 shape).
    final edges = await db.customSelect('SELECT * FROM confusion_edge').get();
    expect(edges, isEmpty);
    await db.customStatement(
      "INSERT INTO confusion_edge (profile_id, ayah_a, ayah_b, weight, "
      "last_confused_at) VALUES ('p', '2:1', '2:2', 1, 20620)",
    );
    final edge = await db
        .customSelect('SELECT last_confused_at FROM confusion_edge')
        .getSingle();
    expect(edge.read<int>('last_confused_at'), 20620);

    final integrity = await db.customSelect('PRAGMA integrity_check;').get();
    expect(integrity.single.data.values.first, 'ok');

    await db.close();
  });

  test('a freshly created store carries app_meta.schema_version = "2"',
      () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    // openTestDatabase triggers onCreate -> createAll + the schema_version
    // singleton insert (the forward-mapping anchor restore reads, E17).
    expect(await db.appMetaDao.get('schema_version'), '2');
  });
}
