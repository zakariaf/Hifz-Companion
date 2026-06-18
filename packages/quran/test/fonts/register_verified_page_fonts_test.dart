// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart';

import '../test_setup.dart';

/// Records read order and throws for a configured bad page (a hash mismatch).
class _FakeAssetVault implements AssetVault {
  _FakeAssetVault(this.log, {this.throwOnPage});

  final List<String> log;
  final int? throwOnPage;

  @override
  Future<Uint8List> readVerified({
    required int page,
    required String expectedSha256,
  }) async {
    log.add('read-$page');
    if (page == throwOnPage) {
      throw StateError('hash mismatch for page $page'); // fail-closed
    }
    return Uint8List.fromList(utf8.encode('font-$page'));
  }
}

/// Records each registration (family + the exact bytes it was handed).
class _RecordingRegistrar implements PageFontRegistrar {
  _RecordingRegistrar(this.log);

  final List<String> log;
  final Map<String, Uint8List> received = {};

  @override
  Future<void> register(String family, Uint8List bytes) async {
    log.add('reg-$family');
    received[family] = bytes;
  }
}

void main() {
  useOfflineTestPolicy();

  Map<int, String> shas(int n) => {for (var p = 1; p <= n; p++) p: 'sha-$p'};

  test('verifies before registering, in page order', () async {
    final log = <String>[];
    final registrar = _RecordingRegistrar(log);
    await registerVerifiedPageFonts(
      pageCount: 3,
      fontSha256: shas(3),
      vault: _FakeAssetVault(log),
      registrar: registrar,
    );
    expect(log, [
      'read-1', 'reg-QPC_P001', //
      'read-2', 'reg-QPC_P002', //
      'read-3', 'reg-QPC_P003',
    ]);
  });

  test('registers each font under its QPC_P### family with the exact bytes',
      () async {
    final registrar = _RecordingRegistrar([]);
    await registerVerifiedPageFonts(
      pageCount: 2,
      fontSha256: shas(2),
      vault: _FakeAssetVault([]),
      registrar: registrar,
    );
    expect(utf8.decode(registrar.received['QPC_P001']!), 'font-1');
    expect(utf8.decode(registrar.received['QPC_P002']!), 'font-2');
  });

  test(
      'a hash mismatch refuses: throws and registers nothing past the bad page',
      () async {
    final log = <String>[];
    final registrar = _RecordingRegistrar(log);
    await expectLater(
      () => registerVerifiedPageFonts(
        pageCount: 4,
        fontSha256: shas(4),
        vault: _FakeAssetVault(log, throwOnPage: 2),
        registrar: registrar,
      ),
      throwsA(isA<StateError>()),
    );
    // Page 1 registered; page 2 read then threw; pages 3-4 never reached.
    expect(log, ['read-1', 'reg-QPC_P001', 'read-2']);
    expect(registrar.received.keys, ['QPC_P001']);
  });

  test('a missing pinned hash refuses before reading that page', () async {
    final log = <String>[];
    final registrar = _RecordingRegistrar(log);
    final shasMissing2 = {1: 'sha-1', 3: 'sha-3'}; // page 2 unpinned
    await expectLater(
      () => registerVerifiedPageFonts(
        pageCount: 3,
        fontSha256: shasMissing2,
        vault: _FakeAssetVault(log),
        registrar: registrar,
      ),
      throwsA(isA<StateError>()),
    );
    expect(log, ['read-1', 'reg-QPC_P001']); // stops at the unpinned page 2
  });
}
