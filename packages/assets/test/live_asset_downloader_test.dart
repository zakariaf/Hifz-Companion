// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:assets/assets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'test_setup.dart';

void main() {
  // The live downloader is driven through an in-memory MockClient, which never
  // creates a real HttpClient — so the throwing offline guard stays installed
  // and untripped, and zero real network calls are made.
  useOfflineTestPolicy();

  late Directory tempDir;
  setUp(() => tempDir = Directory.systemTemp.createTempSync('hifz_dl_test'));
  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  LiveAssetDownloader withHandler(
    Future<http.Response> Function(http.Request) handler,
  ) =>
      LiveAssetDownloader.withClient(
        () => MockClient((req) => handler(req)),
        tempDirectory: tempDir,
      );

  group('no-identifier request (the privacy assertion, C-048)', () {
    test('GETs the exact pinned URL and leaks no identifier', () async {
      late http.Request captured;
      final dl = withHandler((req) async {
        captured = req;
        return http.Response.bytes([1, 2, 3], 200);
      });

      await dl.fetchToTemp('QCF_P001.ttf', cancel: CancelToken());

      expect(
        captured.url.toString(),
        'https://github.com/hifz-companion/quran-assets/releases/download/'
        'core-v1.0.0/QCF_P001.ttf',
      );
      expect(captured.method, 'GET');
      expect(captured.url.hasQuery, isFalse);
      expect(captured.headers.containsKey('authorization'), isFalse);
      expect(captured.headers.containsKey('cookie'), isFalse);
      // We attach no custom User-Agent fingerprint.
      expect(captured.headers.containsKey('user-agent'), isFalse);
    });
  });

  group('temp .part target', () {
    test('a 200 writes the body to <temp>/<name>.part and returns it',
        () async {
      final body = [10, 20, 30, 40];
      final dl = withHandler((_) async => http.Response.bytes(body, 200));

      final file =
          await dl.fetchToTemp('layout-qul.json', cancel: CancelToken());

      expect(file.path, '${tempDir.path}/layout-qul.json.part');
      expect(await file.readAsBytes(), body);
    });

    test('reports progress as bytes arrive', () async {
      final dl =
          withHandler((_) async => http.Response.bytes([1, 2, 3, 4], 200));
      var lastReceived = 0;
      await dl.fetchToTemp(
        'x.bin',
        cancel: CancelToken(),
        onProgress: (received, _) => lastReceived = received,
      );
      expect(lastReceived, 4);
    });
  });

  group('transport-failure mapping (no DioException/ClientException escapes)',
      () {
    test('a connection failure with no bytes ⇒ offlineAtFirstRun', () async {
      final dl = withHandler((_) async => throw http.ClientException('no net'));
      await expectLater(
        () => dl.fetchToTemp('x.bin', cancel: CancelToken()),
        throwsA(isA<OfflineAtFirstRun>()),
      );
    });

    test('a non-200 ⇒ httpStatus(code), carrying the code', () async {
      final dl = withHandler((_) async => http.Response('nope', 404));
      await expectLater(
        () => dl.fetchToTemp('x.bin', cancel: CancelToken()),
        throwsA(
          isA<HttpStatus>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('an already-cancelled token ⇒ cancelled, no request made', () async {
      var handlerCalled = false;
      final dl = withHandler((_) async {
        handlerCalled = true;
        return http.Response.bytes([1], 200);
      });
      final cancel = CancelToken()..cancel();
      await expectLater(
        () => dl.fetchToTemp('x.bin', cancel: cancel),
        throwsA(isA<DownloadCancelled>()),
      );
      expect(handlerCalled, isFalse);
    });
  });

  group('timeouts are bounded (not a hung spinner)', () {
    test('the default downloader carries connect/receive timeouts', () {
      const dl = LiveAssetDownloader();
      expect(dl.connectTimeout, const Duration(seconds: 30));
      expect(dl.receiveTimeout, const Duration(minutes: 10));
    });
  });

  group('no TLS weakening anywhere in assets source', () {
    test('no badCertificateCallback / pinned SecurityContext is constructed',
        () {
      // `flutter test` may run with CWD at the package or the workspace root.
      final libDir = [
        Directory('lib'),
        Directory('packages/assets/lib'),
      ].firstWhere(
        (d) => d.existsSync(),
        orElse: () => fail('could not locate the assets lib directory'),
      );
      final offenders = <String>[];
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        // Strip comment lines so a doc comment that *names* these APIs to say
        // "we never use them" is not a false positive — only real code counts.
        final code = entity
            .readAsLinesSync()
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        if (code.contains('badCertificateCallback') ||
            code.contains('SecurityContext(')) {
          offenders.add(entity.path);
        }
      }
      expect(offenders, isEmpty, reason: 'TLS must use the platform default');
    });
  });
}
