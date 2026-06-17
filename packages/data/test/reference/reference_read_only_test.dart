// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

/// The correctness-critical guard for R1: a runtime write to the muṣḥaf is
/// **unrepresentable** in the data layer because no hand-written DAO/repository
/// performs one. This is enforced by the *absence* of any write call against a
/// reference table — the same enforced-by-absence rule the append-only
/// `review_log` relies on. (The generated `database.g.dart` carries drift's
/// generic write API, but `HifzDatabase` stays internal to `src` and is never
/// exported, so the rest of the app cannot reach it.)
void main() {
  useOfflineTestPolicy();

  const referenceAccessors = <String>[
    'mushafs',
    'surahs',
    'pages',
    'lines',
    'ayat',
    'mutashabihGroups',
    'mutashabihMembers',
  ];

  late Directory libDir;
  late List<File> handWrittenLibFiles;

  setUpAll(() {
    // cwd is the data package when run inside it, or the repo root when run as
    // `flutter test packages/data` — locate the data package's lib either way.
    libDir = [Directory('lib'), Directory('packages/data/lib')].firstWhere(
      (d) => d.existsSync() && File('${d.path}/data.dart').existsSync(),
      orElse: () => fail('could not locate packages/data/lib from '
          '${Directory.current.path}'),
    );
    handWrittenLibFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.endsWith('.g.dart'))
        .toList();
  });

  test('no hand-written code writes a reference table (R1)', () {
    for (final accessor in referenceAccessors) {
      final write =
          RegExp(r'(into|update|delete)\(\s*(db\.)?' + accessor + r'\b');
      for (final file in handWrittenLibFiles) {
        final source = file.readAsStringSync();
        expect(
          write.hasMatch(source),
          isFalse,
          reason: 'a write against reference table "$accessor" appears in '
              '${file.path} — reference tables are read-only by construction (R1)',
        );
      }
    }
  });

  test('the data barrel exports no database/DAO (only DTOs + repositories)',
      () {
    final barrel = File('${libDir.path}/data.dart').readAsStringSync();
    expect(
      barrel.contains("src/db/"),
      isFalse,
      reason: 'the public barrel must not export the HifzDatabase or any DAO; '
          'the raw schema stays internal to packages/data/lib/src/db/',
    );
  });
}
