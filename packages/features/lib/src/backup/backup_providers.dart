// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart'
    show persistenceProvider, restoreRepositoryProvider, todayProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backup_exporter.dart';
import 'backup_restorer.dart';

/// The shell-side [BackupRestorer] over the data restore path + the injected
/// "today" clock — the Settings backup card drives import through it (E16/E17).
final backupRestorerProvider = Provider<BackupRestorer>(
  (ref) => BackupRestorer(
    restore: ref.watch(restoreRepositoryProvider),
    today: () => ref.read(todayProvider),
  ),
);

/// The shell-side [BackupExporter] over the persistence facade + the injected
/// clock — the backup card drives export through it, then hands the bytes to the
/// OS share sheet (E17-T07).
final backupExporterProvider = Provider<BackupExporter>((ref) {
  final persistence = ref.watch(persistenceProvider);
  return BackupExporter(
    profiles: persistence.profiles,
    backupRead: persistence.backupRead,
    today: () => ref.read(todayProvider),
  );
});
