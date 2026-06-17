// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import '../encryption/secret_key_store.dart';

/// A deterministic in-memory [SecretKeyStore] for tests — no real Keychain /
/// KeyStore (eng-define-service-boundary).
///
/// It holds the generated key in memory and follows the same read-or-generate-
/// once flow as [FlutterSecureKeyStore], so the generate-once/stable/delete
/// behaviour is testable without a platform secret store. The [Random] is
/// injectable so a test can make the minted key reproducible.
final class InMemorySecretKeyStore implements SecretKeyStore {
  /// Creates the fake. Pass a seeded [random] for a reproducible test key;
  /// defaults to `Random.secure()`.
  InMemorySecretKeyStore({Random? random})
      : _random = random ?? Random.secure();

  final Random _random;
  String? _keyHex;

  @override
  Future<String> readOrCreateDbKeyHex() async {
    return _keyHex ??= generateDbKeyHex(_random);
  }

  @override
  Future<void> deleteDbKey() async {
    _keyHex = null;
  }
}
