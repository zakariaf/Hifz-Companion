// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:typed_data';

import 'package:composition/composition.dart'
    show BackupFilePicker, BackupShareService, LocalStoreEraser;
import 'package:data/data.dart' show FlutterSecureKeyStore, PersistenceHandle;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// The live [BackupShareService] (E17 §9): write the exported bytes to a temp
/// file, then hand it to the OS share sheet. NO app-owned transport — the OS
/// moves the file. Thin platform glue; untested (no device in CI).
final class ShareBackupService implements BackupShareService {
  /// Creates the share service.
  const ShareBackupService();

  @override
  Future<void> shareBackup(Uint8List bytes, String suggestedFileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$suggestedFileName');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(<XFile>[XFile(file.path)]);
  }
}

/// The live [BackupFilePicker] (E17 §9): the OS file picker, bytes read into
/// memory. Returns null if the user cancelled.
final class FilePickerBackup implements BackupFilePicker {
  /// Creates the file picker.
  const FilePickerBackup();

  @override
  Future<Uint8List?> pickBackupBytes() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return null;
    return result.files.first.bytes;
  }
}

/// The live [LocalStoreEraser] (E17 §9): close the store and delete the
/// `hifz.sqlite` + `-wal` + `-shm` siblings (a stale `-wal` can resurrect deleted
/// state) plus the secure-storage DB key. Right-to-be-forgotten by construction.
final class LocalStoreEraserImpl implements LocalStoreEraser {
  /// Creates the eraser over the open [handle] (closed before the files go).
  const LocalStoreEraserImpl(this._handle);

  final PersistenceHandle _handle;

  @override
  Future<void> eraseEverything() async {
    await _handle.close();
    final dir = await getApplicationDocumentsDirectory();
    for (final suffix in <String>['', '-wal', '-shm']) {
      final file = File('${dir.path}/hifz.sqlite$suffix');
      if (file.existsSync()) await file.delete();
    }
    // Idempotent — a no-op when at-rest encryption was never turned on.
    await FlutterSecureKeyStore().deleteDbKey();
  }
}
