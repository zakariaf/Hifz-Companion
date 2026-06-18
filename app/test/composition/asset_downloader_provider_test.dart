// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:app/composition/asset_downloader_provider.dart';
import 'package:assets/testing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test(
      'reading assetDownloaderProvider un-overridden throws a named StateError',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      () => container.read(assetDownloaderProvider),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isA<StateError>().having(
            (s) => s.message,
            'message',
            contains('without an override'),
          ),
        ),
      ),
    );
  });

  test('an override binds the offline fake downloader', () {
    final fake = FakeAssetDownloader(bytesByName: const {});
    final container = ProviderContainer(
      overrides: [assetDownloaderProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    expect(container.read(assetDownloaderProvider), same(fake));
  });
}
