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

  Future<Set<String>> namesOfType(String type) async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = '$type'")
        .get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }

  Future<List<String>> primaryKeyColumns(String table) async {
    final rows = await db.customSelect("PRAGMA table_info('$table')").get();
    final pkRows = rows.where((r) => r.read<int>('pk') > 0).toList()
      ..sort((a, b) => a.read<int>('pk').compareTo(b.read<int>('pk')));
    return pkRows.map((r) => r.read<String>('name')).toList();
  }

  Future<String> createSqlFor(String table) async {
    final rows = await db
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = '$table'",
        )
        .get();
    return rows.single.read<String>('sql');
  }

  test('all seven user tables exist', () async {
    expect(
      await namesOfType('table'),
      containsAll(<String>[
        'profile',
        'card',
        'line_block',
        'review_log',
        'confusion_edge',
        'cycle_config',
        'app_meta',
      ]),
    );
  });

  test('the three user indices exist', () async {
    expect(
      await namesOfType('index'),
      containsAll(
        <String>['card_due', 'review_log_by_card', 'line_block_by_card'],
      ),
    );
  });

  test('every user table is STRICT', () async {
    for (final t in const [
      'profile',
      'card',
      'line_block',
      'review_log',
      'confusion_edge',
      'cycle_config',
      'app_meta',
    ]) {
      expect(await createSqlFor(t), contains('STRICT'), reason: '$t STRICT');
    }
  });

  group('primary keys match 05 §2', () {
    test('card PK is composite (profile_id, page_id)', () async {
      expect(await primaryKeyColumns('card'), ['profile_id', 'page_id']);
    });

    test('confusion_edge PK is (profile_id, ayah_a, ayah_b)', () async {
      expect(
        await primaryKeyColumns('confusion_edge'),
        ['profile_id', 'ayah_a', 'ayah_b'],
      );
    });

    test('cycle_config PK is the profile_id (also its FK)', () async {
      expect(await primaryKeyColumns('cycle_config'), ['profile_id']);
    });

    test('app_meta PK is key; single UUID PKs on profile/line_block/review_log',
        () async {
      expect(await primaryKeyColumns('app_meta'), ['key']);
      expect(await primaryKeyColumns('profile'), ['profile_id']);
      expect(await primaryKeyColumns('line_block'), ['block_id']);
      expect(await primaryKeyColumns('review_log'), ['log_id']);
    });
  });
}
