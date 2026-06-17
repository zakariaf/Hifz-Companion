// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/connection.dart';
import 'package:data/src/persistence_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  setUpAll(ensureTestSqlite3Loaded);

  group('the cipher-liveness guard decision', () {
    test('a live cipher passes', () {
      expect(() => assertCipherLive(cipherIsLive: true), returnsNormally);
    });

    test('a non-live cipher is refused (EncryptionNotLiveException)', () {
      expect(
        () => assertCipherLive(cipherIsLive: false),
        throwsA(isA<EncryptionNotLiveException>()),
      );
    });
  });

  group('applyConnectionSetup on the real (stock-SQLite) build', () {
    test(
        'a non-null key against stock SQLite is refused — never opens plaintext',
        () {
      // The default build bundles stock SQLite (no sqlite3mc): PRAGMA key is a
      // no-op and PRAGMA cipher; is empty, so a store that only LOOKS encrypted
      // is refused at open — the load-bearing proof a silently-plaintext build
      // cannot ship.
      final raw = sqlite3.openInMemory();
      addTearDown(raw.dispose);
      expect(
        () => applyConnectionSetup(raw, encryptionKeyHex: 'ab' * 32),
        throwsA(isA<EncryptionNotLiveException>()),
      );
    });

    test('the off-flavor path (no key) opens with the crash-safe floor', () {
      final raw = sqlite3.openInMemory();
      addTearDown(raw.dispose);
      // No key -> the key+guard block is skipped entirely (zero cost when off);
      // the WAL/synchronous/foreign_keys floor is applied as on the plaintext
      // store.
      applyConnectionSetup(raw);
      expect(raw.select('PRAGMA foreign_keys;').first.values.first, 1);
      expect(raw.select('PRAGMA synchronous;').first.values.first, 2);
    });

    test('a non-hex key is rejected before it reaches PRAGMA key', () {
      final raw = sqlite3.openInMemory();
      addTearDown(raw.dispose);
      // Defence-in-depth: a malformed/injection-y key never reaches the SQL.
      expect(
        () =>
            applyConnectionSetup(raw, encryptionKeyHex: "x'; DROP TABLE card"),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
