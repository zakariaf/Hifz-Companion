// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:features/src/ids/uuid_v4.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  final v4Shape = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  test('produces an RFC 4122 v4 UUID shape (version + variant nibbles)', () {
    expect(uuidV4(Random(1)), matches(v4Shape));
  });

  test('is deterministic for a seeded Random and varies across seeds', () {
    expect(uuidV4(Random(7)), uuidV4(Random(7)));
    expect(uuidV4(Random(7)), isNot(uuidV4(Random(8))));
  });
}
