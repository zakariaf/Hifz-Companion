// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:assets/assets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  late Directory tempDir;
  late Directory docsDir;
  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('hifz_vp_tmp');
    docsDir = Directory.systemTemp.createTempSync('hifz_vp_docs');
  });
  tearDown(() {
    for (final d in [tempDir, docsDir]) {
      if (d.existsSync()) d.deleteSync(recursive: true);
    }
  });

  // The authoritative bytes and their pinned digest.
  final goodBytes = 'quran-uthmani-bytes'.codeUnits;
  final goodSha = sha256OfBytes(goodBytes);
  ManifestEntry entry() => ManifestEntry(
        name: 'quran-uthmani.db',
        sha256: goodSha,
        bytes: goodBytes.length,
        source: 'tanzil.net',
        license: 'verbatim+attribution',
      );

  File writeTemp(String name, List<int> bytes) =>
      File('${tempDir.path}/$name.part')..writeAsBytesSync(bytes);

  Future<File> promote(File verified) async {
    final dest = File('${docsDir.path}/${verified.uri.pathSegments.last}');
    return verified.rename(dest.path);
  }

  Future<VerifyOutcome> run(
    File downloaded, {
    required Future<File> Function() refetch,
  }) =>
      verifyAndPromote(
        entry: entry(),
        downloaded: downloaded,
        refetch: refetch,
        promote: promote,
      );

  test('match on first attempt → Promoted, no re-fetch', () async {
    var refetched = false;
    final outcome = await run(
      writeTemp('quran-uthmani.db', goodBytes),
      refetch: () async {
        refetched = true;
        return writeTemp('quran-uthmani.db', goodBytes);
      },
    );
    expect(outcome, isA<Promoted>());
    expect(refetched, isFalse);
    expect((outcome as Promoted).verified.path, startsWith(docsDir.path));
  });

  test('a single-byte-flipped copy is REJECTED (avalanche, proven)', () async {
    final flipped = List<int>.of(goodBytes)..[0] ^= 0x01;
    var refetchCount = 0;
    final outcome = await run(
      writeTemp('quran-uthmani.db', flipped),
      refetch: () async {
        refetchCount++;
        return writeTemp('quran-uthmani.db', flipped); // still tampered
      },
    );
    expect(outcome, isA<Refused>());
    expect((outcome as Refused).fileName, 'quran-uthmani.db');
    expect(refetchCount, 1, reason: 'exactly one re-fetch, never a loop');
  });

  test('a truncated download is REJECTED', () async {
    final truncated = goodBytes.sublist(0, goodBytes.length - 1);
    final outcome = await run(
      writeTemp('quran-uthmani.db', truncated),
      refetch: () async => writeTemp('quran-uthmani.db', truncated),
    );
    expect(outcome, isA<Refused>());
  });

  test('a missing/absent file is treated as a mismatch → Refused', () async {
    final missing = File('${tempDir.path}/nope.part'); // never created
    final outcome = await run(
      missing,
      refetch: () async => File('${tempDir.path}/still-nope.part'),
    );
    expect(outcome, isA<Refused>());
  });

  test('mismatch then a good re-fetch → Promoted (exactly one re-fetch)',
      () async {
    final flipped = List<int>.of(goodBytes)..[0] ^= 0x01;
    var refetchCount = 0;
    final outcome = await run(
      writeTemp('quran-uthmani.db', flipped),
      refetch: () async {
        refetchCount++;
        return writeTemp('quran-uthmani.db', goodBytes); // fixed on retry
      },
    );
    expect(outcome, isA<Promoted>());
    expect(refetchCount, 1);
  });
}
