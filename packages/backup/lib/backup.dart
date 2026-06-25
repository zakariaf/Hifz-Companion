// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The Hifz Companion `.hifzbackup` format — a pure-Dart, offline, versioned,
/// integrity-checked serializer of a ḥāfiẓ's review history over value types and
/// bytes only (never Drift, sqlite3, or networking; domain-backup-format §1).
///
/// Public API: [HifzBackup.export] / [HifzBackup.import] over a [BackupSnapshot]
/// the shell assembles from `/data` and writes back in one transaction. The
/// container codec, JSON payload, integrity check, and encryption envelope land
/// across E17-T02..T05; this is the value-model + façade scaffold (E17-T01).
library;

export 'src/backup_error.dart';
export 'src/hifz_backup.dart';
export 'src/snapshot.dart';
