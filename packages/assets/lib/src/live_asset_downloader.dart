// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'asset_downloader.dart';
import 'cancel_token.dart';
import 'pack_coordinates.dart';

/// The live optional-pack downloader — the **only** file in the whole app that
/// imports a networking package (`package:http`; engineering 09 §2, Decision
/// log #8). One plain HTTPS GET to the pinned exact-tag asset URL, streamed to a
/// temp `.part` file, carrying **no** auth, cookie, identifier, custom
/// User-Agent, query param, or beacon — the request leaks nothing (C-048).
///
/// TLS is the platform default (1.2+/1.3, platform trust store): no
/// `SecurityContext`, no `badCertificateCallback`, no validation-disabling
/// client (engineering 09 §5). Verification and promotion are not here
/// (E05-T03/T04) — this returns unverified bytes.
class LiveAssetDownloader implements AssetDownloader {
  /// Creates the production downloader (a fresh `http.Client` per fetch).
  const LiveAssetDownloader({
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(minutes: 10),
  })  : _clientFactory = null,
        _tempDirectory = null;

  /// Test-only constructor injecting a [clientFactory] (e.g. an in-memory
  /// `MockClient`) and a [tempDirectory], so the request can be introspected
  /// with zero real network and no platform-channel temp lookup.
  @visibleForTesting
  LiveAssetDownloader.withClient(
    http.Client Function() clientFactory, {
    Directory? tempDirectory,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(minutes: 10),
  })  : _clientFactory = clientFactory,
        _tempDirectory = tempDirectory;

  /// How long to wait for the connection/response headers.
  final Duration connectTimeout;

  /// How long the body stream may take (large reciter packs over slow links).
  final Duration receiveTimeout;

  final http.Client Function()? _clientFactory;
  final Directory? _tempDirectory;

  @override
  Future<File> fetchToTemp(
    String fileName, {
    required CancelToken cancel,
    void Function(int received, int total)? onProgress,
  }) async {
    if (cancel.isCancelled) throw const AssetDownloadException.cancelled();

    final client = (_clientFactory ?? http.Client.new)();
    var received = 0;
    IOSink? sink;
    File? tmp;
    try {
      // No headers attached: the GET carries only the public asset URL.
      final request = http.Request('GET', PackCoordinates.assetUrl(fileName));
      final response = await client.send(request).timeout(connectTimeout);
      if (response.statusCode != 200) {
        throw AssetDownloadException.httpStatus(response.statusCode);
      }

      final dir = _tempDirectory ?? await getTemporaryDirectory();
      tmp = File(p.join(dir.path, '$fileName.part'));
      sink = tmp.openWrite();
      final total = response.contentLength ?? 0;

      await response.stream.timeout(receiveTimeout).forEach((chunk) {
        if (cancel.isCancelled) {
          throw const AssetDownloadException.cancelled();
        }
        sink!.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      });

      await sink.close();
      sink = null;
      return tmp;
    } on AssetDownloadException {
      await _cleanUp(sink, tmp);
      rethrow;
    } on TimeoutException {
      await _cleanUp(sink, tmp);
      throw _transportFailure(received);
    } on http.ClientException {
      await _cleanUp(sink, tmp);
      throw _transportFailure(received);
    } on SocketException {
      await _cleanUp(sink, tmp);
      throw _transportFailure(received);
    } catch (_) {
      // Any unexpected throw (e.g. a platform-channel exception from
      // getTemporaryDirectory) must still clean up the sink/.part — never leak.
      await _cleanUp(sink, tmp);
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Before any byte arrived ⇒ treat as offline; mid-stream ⇒ interrupted.
  AssetDownloadException _transportFailure(int received) => received == 0
      ? const AssetDownloadException.offlineAtFirstRun()
      : const AssetDownloadException.interrupted();

  Future<void> _cleanUp(IOSink? sink, File? tmp) async {
    await sink?.close();
    if (tmp != null && tmp.existsSync()) {
      try {
        await tmp.delete();
      } on FileSystemException {
        // Best-effort: a leftover .part is never read as Quran regardless.
      }
    }
  }
}
