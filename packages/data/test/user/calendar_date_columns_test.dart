// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

/// The CalendarDate/UTC-string storage boundary at the schema level: scheduling
/// days are INTEGER serial columns; true instants are TEXT. (The end-to-end
/// value-type round-trip through E03-T01's `CalendarDate` is E03-T06.)
void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;

  setUp(() async {
    db = openTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = OFF;');
  });
  tearDown(() async => db.close());

  Future<String> declaredType(String table, String column) async {
    final rows = await db.customSelect("PRAGMA table_info('$table')").get();
    final row = rows.firstWhere((r) => r.read<String>('name') == column);
    return row.read<String>('type');
  }

  test('scheduling-day columns are INTEGER serial days', () async {
    expect(await declaredType('card', 'due_at'), 'INTEGER');
    expect(await declaredType('card', 'last_review_at'), 'INTEGER');
    expect(await declaredType('review_log', 'elapsed_days'), 'INTEGER');
    // A swap belongs to the civil day it happened on (E14-T02).
    expect(await declaredType('confusion_edge', 'last_confused_at'), 'INTEGER');
  });

  test('true-instant columns are TEXT (UTC ISO-8601)', () async {
    expect(await declaredType('review_log', 'reviewed_at'), 'TEXT');
    expect(await declaredType('profile', 'created_at'), 'TEXT');
  });

  test('a serial day round-trips through due_at unchanged', () async {
    const serialDay = 20620; // an epoch-day integer, e.g. 2026-06-17
    await db.customStatement(
      'INSERT INTO card (profile_id, page_id, track, d, s, due_at, reps, '
      'lapses, weak_flag, signoffs, manual_lock, prayer_critical, enabled) '
      "VALUES ('p', 1, 'FAR', 5, 10, $serialDay, 0, 0, 0, 0, 0, 0, 1)",
    );
    final row = await db
        .customSelect("SELECT due_at FROM card WHERE profile_id = 'p'")
        .getSingle();
    expect(row.read<int>('due_at'), serialDay);
  });

  test('a UTC ISO-8601 instant round-trips through reviewed_at unchanged',
      () async {
    const instant = '2026-06-17T21:30:00.000Z';
    await db.customStatement(
      'INSERT INTO review_log (log_id, profile_id, page_id, reviewed_at, '
      'track_at_review, grade, elapsed_days, source) '
      "VALUES ('l', 'p', 1, '$instant', 'FAR', 'good', 7, 'self')",
    );
    final row = await db
        .customSelect("SELECT reviewed_at FROM review_log WHERE log_id = 'l'")
        .getSingle();
    expect(row.read<String>('reviewed_at'), instant);
  });
}
