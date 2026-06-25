// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hands an exported `.hifzbackup` to the OS share sheet (E17 §9). The app
/// transmits NOTHING — the OS moves the file. A side-effect boundary: the real
/// impl (`share_plus`, in `app`) is wired in `main`; tests inject a fake.
abstract interface class BackupShareService {
  /// Writes [bytes] to a temp file named [suggestedFileName], then opens the OS
  /// share sheet over it (no app-owned transport).
  Future<void> shareBackup(Uint8List bytes, String suggestedFileName);
}

/// Lets the user pick a `.hifzbackup` to import (E17 §9) — its bytes, or null if
/// they cancelled. The real impl (`file_picker`, in `app`) is wired in `main`.
abstract interface class BackupFilePicker {
  /// Opens the OS file picker; returns the chosen file's bytes, or null on cancel.
  Future<Uint8List?> pickBackupBytes();
}

/// Erases the entire local store — the `.sqlite` + `-wal` + `-shm` siblings and
/// the secure-storage DB key (E17 §9). Right-to-be-forgotten by construction,
/// irreversible. The real impl (in `app`) is wired in `main`.
abstract interface class LocalStoreEraser {
  /// Closes the store and deletes every on-device trace of the user's data.
  Future<void> eraseEverything();
}

/// The OS share-sheet seam — wired in `main` (`share_plus`), faked in tests;
/// throws until overridden so a stray read never silently no-ops.
final backupShareServiceProvider = Provider<BackupShareService>(
  (ref) => throw UnimplementedError(
    'backupShareServiceProvider is wired only in main (share_plus).',
  ),
);

/// The file-picker seam — wired in `main` (`file_picker`), faked in tests.
final backupFilePickerProvider = Provider<BackupFilePicker>(
  (ref) => throw UnimplementedError(
    'backupFilePickerProvider is wired only in main (file_picker).',
  ),
);

/// The local-store erase seam — wired in `main`, faked in tests.
final localStoreEraserProvider = Provider<LocalStoreEraser>(
  (ref) => throw UnimplementedError(
    'localStoreEraserProvider is wired only in main.',
  ),
);
