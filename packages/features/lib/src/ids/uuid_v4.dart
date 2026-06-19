// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'dart:typed_data';

/// Generates an RFC 4122 version-4 UUID string from [random] (default
/// [Random.secure]) — dependency-free, used as the `review_log` primary key
/// (the *sanad* audit row id).
///
/// The randomness is the only non-determinism in the write path, so it is
/// injectable: production uses `Random.secure()`; a test passes a seeded
/// [Random] (or injects a fixed id generator into the recorder) to assert
/// deterministically. It reads no clock and opens no IO.
String uuidV4([Random? random]) {
  final rnd = random ?? Random.secure();
  final bytes = Uint8List(16);
  for (var i = 0; i < 16; i++) {
    bytes[i] = rnd.nextInt(256);
  }
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 1 (RFC 4122)
  final hex = [
    for (final b in bytes) b.toRadixString(16).padLeft(2, '0'),
  ].join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
