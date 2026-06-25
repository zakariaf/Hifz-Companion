// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E17-T02 — the §3 container codec, test-first: the exact header byte offsets,
// the structural round-trip, and a distinct BackupError at each stage of the
// normative restore-side parse order. The body digest's *verification* is §5/T04;
// here the codec only places and extracts it.

import 'dart:convert';
import 'dart:typed_data';

import 'package:backup/backup.dart';
import 'package:backup/src/container.dart';
import 'package:test/test.dart';

void main() {
  // A valid container = 16-byte prefix + 32-byte digest + body.
  Uint8List validFile(BackupMode mode, Uint8List body, {List<int>? digest}) =>
      Uint8List.fromList(<int>[
        ...writeHeaderPrefix(mode, body.length),
        ...digest ?? List<int>.filled(kDigestLen, 0xAB),
        ...body,
      ]);

  final body = Uint8List.fromList(utf8.encode('{"schemaVersion":2}')); // 19 bytes

  group('writeHeaderPrefix — the §3 byte layout', () {
    test('magic, separator, format, mode sit at their offsets (plaintext)', () {
      final h = writeHeaderPrefix(BackupMode.plaintextJson, 5);
      expect(h, hasLength(16));
      expect(h.sublist(0, 6), equals(<int>[0x48, 0x49, 0x46, 0x5A, 0x42, 0x4B]));
      expect(h[6], 0x1F); // separator
      expect(h[7], 0x01); // format version
      expect(h[8], 0x01); // mode = plaintext
    });

    test('the mode byte is 0x02 for an encrypted container', () {
      expect(writeHeaderPrefix(BackupMode.encryptedJson, 0)[8], 0x02);
    });

    test('body length is UInt32 big-endian at offset 9; 13..15 are reserved zeros', () {
      final h = writeHeaderPrefix(BackupMode.plaintextJson, 0x01020304);
      expect(h.sublist(9, 13), equals(<int>[0x01, 0x02, 0x03, 0x04]));
      expect(h.sublist(13, 16), equals(<int>[0, 0, 0]));
    });
  });

  group('readContainerHeader — round-trip + structure', () {
    test('round-trips mode, body length, digest, and the 16-byte AAD', () {
      final digest = List<int>.generate(kDigestLen, (i) => i);
      final file = validFile(BackupMode.encryptedJson, body, digest: digest);
      final h = readContainerHeader(file);
      expect(h.mode, BackupMode.encryptedJson);
      expect(h.bodyLength, body.length);
      expect(h.storedDigest, equals(digest));
      expect(h.headerBytes, equals(file.sublist(0, 16))); // the AAD
      expect(containerBody(file), equals(body));
    });
  });

  group('readContainerHeader — normative parse order, distinct errors', () {
    BackupError errorOf(Uint8List file) {
      try {
        readContainerHeader(file);
      } on BackupException catch (e) {
        return e.error;
      }
      fail('expected a BackupException');
    }

    test('step 1 — a file under 49 bytes ⇒ notAHifzBackup', () {
      expect(errorOf(Uint8List(48)), BackupError.notAHifzBackup);
    });

    test('step 2 — wrong magic ⇒ notAHifzBackup', () {
      final f = validFile(BackupMode.plaintextJson, body)..[0] = 0x00;
      expect(errorOf(f), BackupError.notAHifzBackup);
    });

    test('step 2 — wrong separator ⇒ notAHifzBackup', () {
      final f = validFile(BackupMode.plaintextJson, body)..[6] = 0x20;
      expect(errorOf(f), BackupError.notAHifzBackup);
    });

    test('step 3 — a newer format byte ⇒ newerFormat', () {
      final f = validFile(BackupMode.plaintextJson, body)..[7] = 0x02;
      expect(errorOf(f), BackupError.newerFormat);
    });

    test('step 3 — format 0x00 ⇒ notAHifzBackup (not "newer")', () {
      final f = validFile(BackupMode.plaintextJson, body)..[7] = 0x00;
      expect(errorOf(f), BackupError.notAHifzBackup);
    });

    test('step 4 — an unknown mode byte ⇒ unknownMode', () {
      final f = validFile(BackupMode.plaintextJson, body)..[8] = 0x03;
      expect(errorOf(f), BackupError.unknownMode);
    });

    test('step 5 — a non-zero reserved byte ⇒ notAHifzBackup', () {
      final f = validFile(BackupMode.plaintextJson, body)..[15] = 0x01;
      expect(errorOf(f), BackupError.notAHifzBackup);
    });

    test('step 5 — a declared body length that disagrees with the file ⇒ notAHifzBackup', () {
      final f = validFile(BackupMode.plaintextJson, body)..[12] = 0x14; // 19 → 20
      expect(errorOf(f), BackupError.notAHifzBackup);
    });

    test('a clean file parses without error', () {
      expect(
        () => readContainerHeader(validFile(BackupMode.plaintextJson, body)),
        returnsNormally,
      );
    });
  });
}
