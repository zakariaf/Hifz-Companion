// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/connection.dart';
import 'package:data/src/persistence_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  // SQLITE_NOTADB (26): "file is encrypted or is not a database".
  const sqliteNotADb = 26;
  // SQLITE_CORRUPT (11): a genuine corruption code — must NOT be treated as a
  // key problem (and a key problem must never be reported as corruption).
  const sqliteCorrupt = 11;

  test('SQLITE_NOTADB maps to WrongDatabaseKeyException, not corruption', () {
    final mapped = classifyOpenFailure(
      SqliteException(sqliteNotADb, 'file is encrypted or is not a database'),
    );
    // A wrong/missing key surfaces a key-recovery intent — the typed error is
    // WrongDatabaseKeyException, never a corruption-typed error. The calm,
    // non-"corrupted" copy a ḥāfiẓ reads is authored in l10n (E16/E17).
    expect(mapped, isA<WrongDatabaseKeyException>());
  });

  test('a non-NOTADB SQLite error is not classified as a key problem', () {
    final mapped = classifyOpenFailure(
      SqliteException(sqliteCorrupt, 'database disk image is malformed'),
    );
    // null -> the caller rethrows it unchanged; it is never silently turned
    // into a wrong-key (or any) PersistenceException.
    expect(mapped, isNull);
  });

  test('a non-SQLite error is not classified', () {
    expect(classifyOpenFailure(StateError('unrelated')), isNull);
  });
}
