// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show SecretKeyStore;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The opt-in at-rest encryption key store seam (05 §5).
///
/// Its default body **throws** so a forgotten wiring is a loud failure rather
/// than a silently-missing key. It is bound to a `FlutterSecureKeyStore` only
/// in the **encryption build flavor**'s composition root; the default
/// (unencrypted) flavor never reads it — encryption is off by default with zero
/// cost. Tests override it with `InMemorySecretKeyStore`
/// (`package:data/testing.dart`).
final secretKeyStoreProvider = Provider<SecretKeyStore>(
  (ref) => throw StateError(
    'secretKeyStoreProvider was read without an override. It is wired only in '
    'the encryption build flavor; the default flavor stores no key.',
  ),
);
