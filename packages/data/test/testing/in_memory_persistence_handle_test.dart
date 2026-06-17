// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/live_persistence_handle.dart';
import 'package:data/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test('inMemoryPersistenceHandle is a live store bearing the v1 schema',
      () async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);

    // The double is a real Drift store; verify the v1 schema materialised.
    final db = (handle as LivePersistenceHandle).database;
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final tables = rows.map((r) => r.read<String>('name')).toSet();
    expect(
      tables,
      containsAll(<String>['profile', 'card', 'review_log', 'mushaf', 'page']),
    );
  });

  test('foreign keys are live on the in-memory double (same setup as live)',
      () async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    final db = (handle as LivePersistenceHandle).database;
    final row = await db.customSelect('PRAGMA foreign_keys;').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('close completes cleanly', () async {
    final handle = inMemoryPersistenceHandle();
    await handle.close();
  });
}
