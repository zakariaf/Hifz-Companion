// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

// The §5 integrity primitive: a SHA-256 of the body, present in BOTH modes and
// verified fail-closed before any decode/decrypt. It is corruption detection,
// NOT tamper resistance (confidentiality/authenticity come only from turning on
// encryption, whose AEAD tag is authenticated). SHA-256 only — never MD5/SHA-1 —
// the same NIST primitive (and the same Dart-team `crypto` package) that pins the
// Quran asset packs.

/// The 32-byte SHA-256 digest of [body] (the JSON in plaintext mode, the whole
/// encryption envelope in encrypted mode).
List<int> bodyDigest(Uint8List body) => crypto.sha256.convert(body).bytes;

/// True iff [body]'s SHA-256 equals [stored] in both length and content. A
/// constant-time compare is unnecessary (the digest is not a secret), but a
/// full length-and-content check is required so a truncated transfer is caught.
bool verifyBody(Uint8List body, List<int> stored) {
  final actual = crypto.sha256.convert(body).bytes;
  if (actual.length != stored.length) return false;
  var ok = true;
  for (var i = 0; i < actual.length; i++) {
    ok = ok && actual[i] == stored[i];
  }
  return ok;
}
