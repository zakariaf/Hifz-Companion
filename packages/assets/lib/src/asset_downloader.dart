// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'cancel_token.dart';

/// The single network boundary of the app: downloads one **optional**-pack file
/// (reciter audio, future alt-muṣḥaf) to a temporary `.part` file.
///
/// **Bundle-first (amended 2026-06-18):** the core muṣḥaf is bundled in the
/// binary, so this boundary is never on the critical path — it serves only
/// optional packs. Framework-free by design (no `http`/`dio` type in the
/// signature) so the networking import stays quarantined to the one live impl.
abstract interface class AssetDownloader {
  /// Downloads [fileName] from the pinned exact-tag release to a temp `.part`.
  ///
  /// Returns the **UNVERIFIED** temp file; the caller MUST verify it (E05-T03)
  /// before any byte is treated as Quran. Reports progress via [onProgress] and
  /// honours [cancel]. Throws [AssetDownloadException] on any transport failure
  /// or cancellation — never a raw networking-library exception.
  Future<File> fetchToTemp(
    String fileName, {
    required CancelToken cancel,
    void Function(int received, int total)? onProgress,
  });
}

/// A typed transport failure crossing the [AssetDownloader] boundary. It carries
/// **no** user-facing copy — E05-T04 maps it to the calm fa/ckb/ar onboarding
/// states. `sealed`, so a consumer's `switch` is exhaustive.
sealed class AssetDownloadException implements Exception {
  /// Const base constructor for the sealed hierarchy.
  const AssetDownloadException();

  /// The device had no connectivity (e.g. first run offline).
  const factory AssetDownloadException.offlineAtFirstRun() = OfflineAtFirstRun;

  /// The transfer was interrupted mid-stream.
  const factory AssetDownloadException.interrupted() = DownloadInterrupted;

  /// The server returned a non-200 status (e.g. a 404 on a pinned asset, which
  /// the caller treats as "keep the verified local copy").
  const factory AssetDownloadException.httpStatus(int statusCode) = HttpStatus;

  /// The shared [CancelToken] was cancelled.
  const factory AssetDownloadException.cancelled() = DownloadCancelled;
}

/// No connectivity (e.g. first run offline).
final class OfflineAtFirstRun extends AssetDownloadException {
  /// Creates an offline-at-first-run failure.
  const OfflineAtFirstRun();
}

/// The transfer was interrupted mid-stream.
final class DownloadInterrupted extends AssetDownloadException {
  /// Creates an interrupted-download failure.
  const DownloadInterrupted();
}

/// A non-200 HTTP status (the [statusCode] is carried for the caller's policy).
final class HttpStatus extends AssetDownloadException {
  /// Creates an HTTP-status failure for [statusCode].
  const HttpStatus(this.statusCode);

  /// The non-200 status code returned by the server.
  final int statusCode;

  @override
  bool operator ==(Object other) =>
      other is HttpStatus && other.statusCode == statusCode;

  @override
  int get hashCode => statusCode.hashCode;
}

/// The download was cancelled via its [CancelToken].
final class DownloadCancelled extends AssetDownloadException {
  /// Creates a cancellation failure.
  const DownloadCancelled();
}
