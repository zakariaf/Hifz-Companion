// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The opt-in at-rest encryption key store — a side-effect boundary over the
/// platform secret store (05 §5).
///
/// The raw 32-byte database key is generated **once** and never leaves the
/// device: it lives in the OS Keychain / Android KeyStore, `first_unlock_this_
/// device` and non-syncing, so it never reaches a cloud backup or another
/// device. The injected `SecretKeyStore` Provider is wired live only at the
/// composition root; tests inject an in-memory fake. This is local platform IO
/// — it opens no socket (C1).
abstract interface class SecretKeyStore {
  /// Returns the hex-encoded 32-byte DB key, generating and persisting it once
  /// on first call and returning the same value on every later call.
  Future<String> readOrCreateDbKeyHex();

  /// Destroys the key. When encryption is on, one-tap erase (E17) calls this so
  /// the at-rest data is cryptographically unrecoverable — the honest
  /// guarantee, never a physical-secure-erase claim (05 §5).
  Future<void> deleteDbKey();
}

/// The secret-store key under which the DB key is held.
const String dbKeyName = 'hifz_db_key';

/// Generates a fresh hex-encoded 32-byte (256-bit) key from [random].
///
/// Pass `Random.secure()` in production; a seeded `Random` only in a test that
/// must be reproducible. Full-entropy raw key material — supplied to `PRAGMA
/// key` as a BLOB literal, skipping PBKDF2 (05 §5).
String generateDbKeyHex(Random random) {
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// The live [SecretKeyStore] over `flutter_secure_storage` (05 §5).
final class FlutterSecureKeyStore implements SecretKeyStore {
  /// Creates the live key store. [storage] defaults to the
  /// `first_unlock_this_device`, non-syncing configuration.
  FlutterSecureKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              // first_unlock_this_device + non-syncing: the key stays off cloud
              // backups and other devices. Android's default storage is
              // KeyStore-backed and device-local (the deprecated
              // `encryptedSharedPreferences` flag is removed in fss 10).
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  // The in-flight read-or-create is cached so concurrent first-launch calls
  // share one Future: without this, two callers could each see `null`, generate
  // two keys, and the DB could be opened with one while the store persists the
  // other — permanently locking the user out.
  Future<String>? _keyFuture;

  @override
  Future<String> readOrCreateDbKeyHex() => _keyFuture ??= _readOrCreate();

  Future<String> _readOrCreate() async {
    final existing = await _storage.read(key: dbKeyName);
    if (existing != null) return existing;
    final created = generateDbKeyHex(Random.secure());
    await _storage.write(key: dbKeyName, value: created); // first launch only
    return created;
  }

  @override
  Future<void> deleteDbKey() async {
    _keyFuture = null;
    await _storage.delete(key: dbKeyName);
  }
}
