// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../asset_downloader.dart';
import '../cancel_token.dart';

/// A deterministic, **offline** [AssetDownloader] for tests: it serves bytes
/// from an in-memory map to a real temp `.part` file, with no socket and no
/// networking import. E05-T04 and every downstream widget test install this via
/// `overrideWith`, so the suite stays offline by construction.
class FakeAssetDownloader implements AssetDownloader {
  /// Creates a fake serving [bytesByName]; [failWith] maps a file name to the
  /// [AssetDownloadException] its fetch should throw instead of succeeding.
  /// [tempDirectory] overrides the device temp dir (so tests need no
  /// platform-channel lookup).
  FakeAssetDownloader({
    required this.bytesByName,
    this.failWith = const {},
    this.tempDirectory,
  });

  /// File name → the bytes a successful fetch writes to the temp `.part`.
  final Map<String, List<int>> bytesByName;

  /// File name → the failure its fetch should throw (overrides success).
  final Map<String, AssetDownloadException> failWith;

  /// The temp directory to write `.part` files into; defaults to
  /// `getTemporaryDirectory()` when null.
  final Directory? tempDirectory;

  @override
  Future<File> fetchToTemp(
    String fileName, {
    required CancelToken cancel,
    void Function(int received, int total)? onProgress,
  }) async {
    if (cancel.isCancelled) throw const AssetDownloadException.cancelled();

    final failure = failWith[fileName];
    if (failure != null) throw failure;

    final bytes = bytesByName[fileName];
    if (bytes == null) {
      // An unmapped name behaves like a missing release asset (404).
      throw const AssetDownloadException.httpStatus(404);
    }

    final dir = tempDirectory ?? await getTemporaryDirectory();
    final tmp = File(p.join(dir.path, '$fileName.part'));
    await tmp.writeAsBytes(bytes, flush: true);
    onProgress?.call(bytes.length, bytes.length);
    return tmp;
  }
}
