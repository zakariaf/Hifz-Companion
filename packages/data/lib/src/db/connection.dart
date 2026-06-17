// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';

import '../persistence_exception.dart';

/// The SQLite `SQLITE_NOTADB` primary result code (26) — "file is encrypted or
/// is not a database": a wrong/missing key, never corruption (05 §5).
const int _sqliteNotADb = 26;

/// A raw-key must be pure hex before it is interpolated into a `PRAGMA key`
/// BLOB literal — defence-in-depth against a malformed/tampered key store
/// breaking the statement (the key is always valid hex from `generateDbKeyHex`).
final RegExp _hexKeyPattern = RegExp(r'^[0-9a-fA-F]+$');

/// Applies the fixed crash-safe connection pragmas on the raw `sqlite3` handle,
/// in order, **before** drift touches the database (05 §1, §3).
///
/// Pragmas are per-connection and not persisted in the file, so this runs on
/// **every** open — first launch, relaunch, and each test. `synchronous=FULL`
/// (never `NORMAL`) is the floor, not a tunable: a teacher sign-off — a *sanad*
/// act — must survive power loss, so the WAL is fsync'd on every commit.
///
/// Opt-in at-rest encryption (05 §5): when [encryptionKeyHex] is non-null (the
/// encryption build flavor — `hooks: user_defines: sqlite3: source: sqlite3mc`,
/// ChaCha20-Poly1305), `PRAGMA key` is fed on the raw handle **before** these
/// pragmas, then the hard cipher-liveness guard refuses a store that only looks
/// encrypted. When it is null (the default flavor) the whole block is skipped
/// and the open path is byte-identical to the unencrypted floor — **zero cost
/// when off**.
void applyConnectionSetup(CommonDatabase database, {String? encryptionKeyHex}) {
  final keyHex = encryptionKeyHex;
  if (keyHex != null) {
    // Validate the key is pure hex BEFORE interpolating it (no SQL injection
    // even if the key store is ever compromised). The message never includes
    // the key (§17).
    if (!_hexKeyPattern.hasMatch(keyHex)) {
      throw const FormatException('encryption key is not a valid hex string');
    }
    // Raw-key BLOB literal — full-entropy keystore material, skips PBKDF2.
    database.execute('PRAGMA key = "x\'$keyHex\'";');
    // HARD GUARD: a plaintext store that only LOOKS encrypted must never open.
    final cipherIsLive = database.select('PRAGMA cipher;').isNotEmpty;
    assertCipherLive(cipherIsLive: cipherIsLive);
  }
  database.execute('PRAGMA journal_mode = WAL;'); // crash-safe journal (§3)
  database.execute('PRAGMA synchronous = FULL;'); // durable across power loss
  database.execute('PRAGMA foreign_keys = ON;'); // SQLite leaves FKs OFF
  database.execute('PRAGMA busy_timeout = 5000;'); // wait, don't throw, on lock
}

/// The real release guard (never `kDebugMode`-gated): if the encryption flavor
/// is active but the cipher is not live, refuse to open (05 §5).
///
/// An empty `PRAGMA cipher;` means `source: sqlite3mc` is not in effect — the
/// toggle fell back to stock SQLite and `PRAGMA key` was a no-op. Failing
/// loudly here is the only thing that prevents shipping a plaintext store that
/// looks encrypted.
void assertCipherLive({required bool cipherIsLive}) {
  if (!cipherIsLive) throw const EncryptionNotLiveException();
}

/// Classifies an open-time failure: a `SQLITE_NOTADB` is a wrong/missing key,
/// mapped to [WrongDatabaseKeyException] so the feature layer shows a calm
/// key-recovery flow — **never** a "your data is corrupted" message (05 §5).
///
/// Returns null for any other error so the caller rethrows it unchanged.
/// Detection is by the typed `package:sqlite3` result code, never a message
/// string-match. The key-recovery copy a ḥāfiẓ reads is authored in `l10n` at
/// the Settings/backup feature layer (E16/E17), not here.
PersistenceException? classifyOpenFailure(Object error) {
  if (error is SqliteException && error.resultCode == _sqliteNotADb) {
    return const WrongDatabaseKeyException();
  }
  return null;
}

/// The single live-store open path: a lazily-opened, background-isolate
/// `NativeDatabase` over `hifz.sqlite` in the app documents directory (05 §1).
///
/// This is the only place that opens the on-device store; tests open an
/// in-memory `NativeDatabase.memory()` instead (E03-T05). `path_provider` is
/// local file IO — never a network socket (C1). [encryptionKeyHex] is null in
/// the default flavor (unencrypted, zero cost); the encryption flavor resolves
/// it from the `SecretKeyStore` and threads it through. **Key rotation is never
/// in place on WAL** (`PRAGMA rekey` is refused) — it routes to E17's
/// export-to-freshly-keyed checkpointed pipeline; there is no decoy/duress
/// isolation, and erase destroys the key (cryptographic unrecoverability, never
/// a physical-secure-erase claim).
LazyDatabase openConnection({String? encryptionKeyHex}) {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'hifz.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (raw) =>
          applyConnectionSetup(raw, encryptionKeyHex: encryptionKeyHex),
    );
  });
}
