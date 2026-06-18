// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// A cooperative cancellation flag threaded into an optional-pack download
/// (engineering 09 §2). Framework-free: it carries no `http`/`dio` type, so the
/// download boundary stays quarantined.
///
/// The caller (E05-T04 owns one shared token across a whole pack) flips
/// [cancel]; the downloader checks [isCancelled] before starting and between
/// streamed chunks, then fails closed with `AssetDownloadException.cancelled`.
class CancelToken {
  bool _isCancelled = false;

  /// Whether cancellation has been requested.
  bool get isCancelled => _isCancelled;

  /// Requests cancellation. Idempotent.
  void cancel() => _isCancelled = true;
}
