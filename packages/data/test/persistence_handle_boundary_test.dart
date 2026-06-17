// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

/// The seam must not leak a Drift symbol — the determinism boundary depends on
/// no `package:drift`/`sqlite3` type crossing into the shell. The interface
/// (and the repository interfaces it exposes) reference `models` value types
/// only; the CI banned-import gate enforces drift/sqlite3 live only in `data`.
void main() {
  useOfflineTestPolicy();

  File locate(String relativePath) {
    return [File(relativePath), File('packages/data/$relativePath')].firstWhere(
      (f) => f.existsSync(),
      orElse: () => fail('could not locate $relativePath from '
          '${Directory.current.path}'),
    );
  }

  test('PersistenceHandle and its repositories leak no Drift/Flutter/IO symbol',
      () {
    final sources = <File>[
      locate('lib/src/persistence_handle.dart'),
      locate('lib/src/repositories/repositories.dart'),
    ];
    for (final file in sources) {
      final source = file.readAsStringSync();
      for (final banned in const [
        'package:drift',
        'package:sqlite3',
        'package:flutter',
        'dart:io',
      ]) {
        // Match real import statements only — a doc comment that *names* a
        // banned package (to explain the rule) is not a leak.
        expect(
          source.contains("import '$banned"),
          isFalse,
          reason: '$banned must not be imported by ${file.path} — the '
              'persistence boundary exposes value types only (no Drift leak)',
        );
      }
    }
  });
}
