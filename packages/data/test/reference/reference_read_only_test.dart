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
///
/// The lone sanctioned exception is the **one-shot core-reference build path**
/// (`src/reference/reference_db_builder.dart`, E05-T05): 05 §2 permits a single
/// install-time load — "never written *at runtime*; no *DAO* exposes a mutation"
/// — exactly as `review_log`'s append-only rule permits the backup/restore bulk
/// path. That file is exempted from the write-scan **and** asserted to be
/// unexported (so it can never become a feature-reachable runtime write DAO).
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

  // The single sanctioned writer of the reference tables (05 §2; E05-T05).
  const buildPath = 'reference/reference_db_builder.dart';

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

  test('no hand-written code writes a reference table outside the build path '
      '(R1)', () {
    // Every file EXCEPT the one sanctioned build path must be write-free.
    final scanned = handWrittenLibFiles
        .where((f) => !f.path.replaceAll(r'\', '/').endsWith(buildPath));
    for (final accessor in referenceAccessors) {
      final write =
          RegExp(r'(into|update|delete)\(\s*(db\.)?' + accessor + r'\b');
      for (final file in scanned) {
        final source = file.readAsStringSync();
        expect(
          write.hasMatch(source),
          isFalse,
          reason: 'a write against reference table "$accessor" appears in '
              '${file.path} — reference tables are read-only by construction '
              '(R1); only $buildPath may write them, and only at install.',
        );
      }
    }
  });

  test('the sanctioned build path exists and is the only exempted writer', () {
    // Defence against the exemption silently masking a moved/renamed file: the
    // build path must actually be present (else the exemption protects nothing).
    final present =
        handWrittenLibFiles.any((f) => f.path.replaceAll(r'\', '/').endsWith(buildPath));
    expect(
      present,
      isTrue,
      reason: 'the sanctioned reference writer $buildPath was not found — '
          'the R1 exemption must name a real file',
    );
  });

  test('the sanctioned build path is not exported (unreachable as a DAO)', () {
    // 05 §2 / E05-T05: the load is reached only through the install sequence,
    // never as a feature-callable surface. The barrel must not export it.
    final barrel = File('${libDir.path}/data.dart').readAsStringSync();
    expect(
      barrel.contains(buildPath),
      isFalse,
      reason: 'the one-shot reference build path must stay internal — exporting '
          'it would expose a runtime write surface on the reference tables',
    );
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
