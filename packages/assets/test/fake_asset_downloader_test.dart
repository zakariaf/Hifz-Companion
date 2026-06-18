// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:assets/assets.dart';
import 'package:assets/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

void main() {
  // The fake never touches the network — keep the throwing offline guard.
  useOfflineTestPolicy();

  late Directory tempDir;
  setUp(() => tempDir = Directory.systemTemp.createTempSync('hifz_fake_test'));
  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('writes the mapped bytes to a temp .part and emits one progress tick',
      () async {
    final dl = FakeAssetDownloader(
      bytesByName: const {
        'a.bin': [1, 2, 3],
      },
      tempDirectory: tempDir,
    );
    final ticks = <int>[];
    final file = await dl.fetchToTemp(
      'a.bin',
      cancel: CancelToken(),
      onProgress: (received, total) => ticks.add(received),
    );
    expect(file.path, '${tempDir.path}/a.bin.part');
    expect(await file.readAsBytes(), [1, 2, 3]);
    expect(ticks, [3]);
  });

  test('throws the configured failure for a failWith name', () async {
    final dl = FakeAssetDownloader(
      bytesByName: const {},
      failWith: const {'bad.bin': AssetDownloadException.offlineAtFirstRun()},
      tempDirectory: tempDir,
    );
    await expectLater(
      () => dl.fetchToTemp('bad.bin', cancel: CancelToken()),
      throwsA(isA<OfflineAtFirstRun>()),
    );
  });

  test('an unmapped name behaves like a 404', () async {
    final dl =
        FakeAssetDownloader(bytesByName: const {}, tempDirectory: tempDir);
    await expectLater(
      () => dl.fetchToTemp('missing.bin', cancel: CancelToken()),
      throwsA(isA<HttpStatus>().having((e) => e.statusCode, 'code', 404)),
    );
  });

  test('an already-cancelled token throws cancelled', () async {
    final dl = FakeAssetDownloader(
      bytesByName: const {
        'a.bin': [1],
      },
      tempDirectory: tempDir,
    );
    final cancel = CancelToken()..cancel();
    await expectLater(
      () => dl.fetchToTemp('a.bin', cancel: cancel),
      throwsA(isA<DownloadCancelled>()),
    );
  });
}
