// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart'
    show restoreRepositoryProvider, todayProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backup_restorer.dart';

/// The shell-side [BackupRestorer] over the data restore path + the injected
/// "today" clock — the Settings backup card drives import through it (E16/E17).
final backupRestorerProvider = Provider<BackupRestorer>(
  (ref) => BackupRestorer(
    restore: ref.watch(restoreRepositoryProvider),
    today: () => ref.read(todayProvider),
  ),
);
