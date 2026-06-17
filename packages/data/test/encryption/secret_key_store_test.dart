// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test('the DB key is generated once, then stable across reads', () async {
    final store = InMemorySecretKeyStore();
    final first = await store.readOrCreateDbKeyHex();
    expect(first.length, 64); // 32 bytes, hex-encoded
    expect(RegExp(r'^[0-9a-f]+$').hasMatch(first), isTrue);

    final second = await store.readOrCreateDbKeyHex();
    expect(second, first); // generate-once, never regenerated per open
  });

  test('deleteDbKey clears it; the next read mints a fresh key', () async {
    final store = InMemorySecretKeyStore();
    final original = await store.readOrCreateDbKeyHex();

    await store.deleteDbKey();
    final minted = await store.readOrCreateDbKeyHex();
    expect(minted.length, 64);
    expect(minted, isNot(original)); // erase renders the old data unrecoverable
  });
}
