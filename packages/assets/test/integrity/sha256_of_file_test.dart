// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:assets/assets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  // The fixed, publishable FIPS 180-4 anchors any auditor can confirm.
  const emptySha =
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
  const abcSha =
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';

  late Directory tempDir;
  setUp(() => tempDir = Directory.systemTemp.createTempSync('hifz_sha_test'));
  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('sha256OfBytes anchors', () {
    test('empty input', () => expect(sha256OfBytes(const []), emptySha));
    test('"abc"', () => expect(sha256OfBytes('abc'.codeUnits), abcSha));
  });

  group('sha256OfFile anchors (streamed)', () {
    test('empty file', () async {
      final f = File('${tempDir.path}/empty')..writeAsBytesSync(const []);
      expect(await sha256OfFile(f), emptySha);
    });

    test('"abc" file', () async {
      final f = File('${tempDir.path}/abc')..writeAsStringSync('abc');
      expect(await sha256OfFile(f), abcSha);
    });

    test('streaming matches one-shot for a multi-chunk file', () async {
      final bytes = List<int>.generate(200000, (i) => i % 256);
      final f = File('${tempDir.path}/big')..writeAsBytesSync(bytes);
      expect(await sha256OfFile(f), sha256OfBytes(bytes));
    });
  });

  group('digestMatches', () {
    test('exact lower-case hex equality', () {
      expect(digestMatches(abcSha, abcSha), isTrue);
      expect(digestMatches(abcSha, emptySha), isFalse);
      // Case-sensitive: the canonical form is lower-case.
      expect(digestMatches(abcSha.toUpperCase(), abcSha), isFalse);
    });
  });
}
