// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:data/data.dart'
    show
        installVerifiedCoreReference,
        kAppMetaKeyTextChecksumVerifiedAt,
        stampCoreVerified;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show kKfgqpcHafsMadaniV2Edition;

import '../db/test_database.dart';
import '../test_setup.dart';

/// Resolves the bundled-core asset dir relative to wherever the test runner's
/// CWD is (package root under `flutter test`, repo root under some CI configs).
/// Returns null when the LFS assets are not checked out, so this integration
/// test skips cleanly instead of failing a lean CI checkout.
Directory? _coreAssetsDir() {
  const candidates = <String>[
    'app/assets/quran',
    '../../app/assets/quran',
    '../../../app/assets/quran',
  ];
  for (final path in candidates) {
    final dir = Directory(path);
    if (File('${dir.path}/quran-data.xml').existsSync()) return dir;
  }
  return null;
}

void main() {
  useOfflineTestPolicy();
  setUpAll(ensureTestSqlite3Loaded);

  final assets = _coreAssetsDir();

  group('installVerifiedCoreReference over the real bundled core', () {
    test(
      'populates the reference tables so a page projects real glyph lines',
      () async {
        final dir = assets!;
        final handle = inMemoryPersistenceHandle();
        addTearDown(handle.close);

        await installVerifiedCoreReference(
          handle,
          edition: kKfgqpcHafsMadaniV2Edition,
          textXml: File('${dir.path}/quran-data.xml').readAsBytesSync(),
          layoutDb: File('${dir.path}/qpc-v2-15-lines.db').readAsBytesSync(),
          wordsDb: File('${dir.path}/qpc-v2.db').readAsBytesSync(),
          checksumSha256: 'test-verified',
        );

        // Page 1 (Al-Fātiḥa) projects its lines, and its āyah lines carry the
        // opaque concatenated glyph codes (never empty for an āyah line).
        final page1 = await handle.reference.linesForPage(1);
        expect(page1, isNotEmpty);
        final ayahLines1 =
            page1.where((l) => l.textGlyphRef.isNotEmpty).toList();
        expect(
          ayahLines1,
          isNotEmpty,
          reason: 'page 1 must have non-empty glyph lines',
        );

        // A page deep in the muṣḥaf also loads (not just the first page).
        final page255 = await handle.reference.linesForPage(255);
        expect(page255.where((l) => l.textGlyphRef.isNotEmpty), isNotEmpty);
      },
      skip: assets == null
          ? 'bundled core assets not checked out (Git LFS) — integration test '
              'skipped'
          : null,
    );

    test(
      'is idempotent and stampable (re-run after a load is a no-op)',
      () async {
        final dir = assets!;
        final handle = inMemoryPersistenceHandle();
        addTearDown(handle.close);

        Future<void> install() => installVerifiedCoreReference(
              handle,
              edition: kKfgqpcHafsMadaniV2Edition,
              textXml: File('${dir.path}/quran-data.xml').readAsBytesSync(),
              layoutDb: File('${dir.path}/qpc-v2-15-lines.db').readAsBytesSync(),
              wordsDb: File('${dir.path}/qpc-v2.db').readAsBytesSync(),
              checksumSha256: 'test-verified',
            );

        await install();
        // A second run must not throw or duplicate.
        await install();
        await stampCoreVerified(handle, 'test-verified');

        final stamp = await handle.meta.read(kAppMetaKeyTextChecksumVerifiedAt);
        expect(stamp, isNotNull);
      },
      skip: assets == null
          ? 'bundled core assets not checked out (Git LFS) — integration test '
              'skipped'
          : null,
    );
  });
}

