// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:data/src/db/connection.dart';
import 'package:data/src/db/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  // WAL is only observable on a file-backed store (`:memory:` coerces the
  // journal mode), so the pragma assertions run over a temp file opened through
  // the SAME `applyConnectionSetup` the live store uses.
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('hifz_conn'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  File dbFile() => File('${tempDir.path}/hifz.sqlite');

  HifzDatabase openFileDatabase() =>
      HifzDatabase(NativeDatabase(dbFile(), setup: applyConnectionSetup));

  Future<int> pragmaInt(HifzDatabase db, String pragma) async {
    final row = await db.customSelect('PRAGMA $pragma;').getSingle();
    return row.data.values.first! as int;
  }

  Future<String> pragmaText(HifzDatabase db, String pragma) async {
    final row = await db.customSelect('PRAGMA $pragma;').getSingle();
    return (row.data.values.first! as String).toLowerCase();
  }

  test('WAL is the active journal mode on a fresh open', () async {
    final db = openFileDatabase();
    addTearDown(db.close);
    expect(await pragmaText(db, 'journal_mode'), 'wal');
  });

  test('synchronous is FULL (2), never NORMAL (1)', () async {
    final db = openFileDatabase();
    addTearDown(db.close);
    expect(await pragmaInt(db, 'synchronous'), 2);
  });

  test('busy_timeout is 5000', () async {
    final db = openFileDatabase();
    addTearDown(db.close);
    expect(await pragmaInt(db, 'busy_timeout'), 5000);
  });

  test('foreign keys are enforced on a fresh open', () async {
    final db = openFileDatabase();
    addTearDown(db.close);
    expect(await pragmaInt(db, 'foreign_keys'), 1);
    // A review_log row with no parent profile must be rejected — proof the
    // per-connection FK pragma is live, not merely set.
    await expectLater(
      db.customStatement(
        'INSERT INTO review_log (log_id, profile_id, page_id, reviewed_at, '
        'track_at_review, grade, elapsed_days, source) '
        "VALUES ('l', 'ghost', 1, 't', 'FAR', 'good', 1, 'self')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('pragmas re-assert on a re-open (per-connection, not persisted)',
      () async {
    final first = openFileDatabase();
    // touch the DB so it is created and pragmas applied, then close.
    expect(await pragmaInt(first, 'foreign_keys'), 1);
    await first.close();

    final second = openFileDatabase();
    addTearDown(second.close);
    expect(await pragmaInt(second, 'foreign_keys'), 1);
    expect(await pragmaInt(second, 'synchronous'), 2);
  });
}
