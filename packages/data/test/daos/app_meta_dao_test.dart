// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;
  setUp(() => db = openTestDatabase());
  tearDown(() async => db.close());

  test('set then get round-trips a String/String pair', () async {
    await db.appMetaDao.set('active_profile', 'p-123');
    expect(await db.appMetaDao.get('active_profile'), 'p-123');
  });

  test('set replaces an existing value', () async {
    await db.appMetaDao.set('encryption_enabled', 'false');
    await db.appMetaDao.set('encryption_enabled', 'true');
    expect(await db.appMetaDao.get('encryption_enabled'), 'true');
  });

  test('reading a missing key returns null, not a throw', () async {
    expect(await db.appMetaDao.get('never_set'), isNull);
  });
}
