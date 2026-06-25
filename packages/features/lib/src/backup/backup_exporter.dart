// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:backup/backup.dart';
import 'package:data/data.dart' show BackupReadRepository, ProfileRepository;
import 'package:models/models.dart';

/// The exporting app's version stamped into the backup — informational only,
/// never used for logic.
const String kBackupAppVersion = '0.1.0'; // TODO(E17): wire package_info.

/// Assembles a [BackupSnapshot] from every profile's rows through `/data` and
/// serializes it to `.hifzbackup` bytes (E17-T07; domain-backup-format §4/§9).
/// The shell hands the bytes to the OS share sheet — the package transmits
/// nothing. Only the truth-only rows are read; never derived state.
class BackupExporter {
  /// Creates the exporter over the profile + export read seams and the clock.
  BackupExporter({
    required ProfileRepository profiles,
    required BackupReadRepository backupRead,
    required CalendarDate Function() today,
  })  : _profiles = profiles,
        _backupRead = backupRead,
        _today = today;

  final ProfileRepository _profiles;
  final BackupReadRepository _backupRead;
  final CalendarDate Function() _today;

  /// Builds the snapshot (all device profiles) and exports it; a non-null
  /// [passphrase] writes the encrypted envelope. Returns the `.hifzbackup` bytes.
  Future<Uint8List> exportAll({String? passphrase}) async {
    final profiles = await _profiles.all();
    final exports = <ProfileExport>[];
    for (final profile in profiles) {
      final rows = await _backupRead.readProfileForExport(profile.profileId);
      if (rows == null) continue;
      exports.add(
        ProfileExport(
          profile: rows.profile,
          cycleConfig: rows.cycleConfig,
          cards: rows.cards,
          lineBlocks: rows.lineBlocks,
          reviewLog: rows.reviewLog,
          confusionEdges: rows.confusionEdges,
        ),
      );
    }

    final edition = kKfgqpcHafsMadaniV2Edition;
    final snapshot = BackupSnapshot(
      schemaVersion: kCurrentSchemaVersion,
      appVersion: kBackupAppVersion,
      exportedAt: _today().toString(), // floating "YYYY-MM-DD"
      mushaf: MushafRef(
        id: edition.mushafId,
        riwayah: edition.riwayah,
        name: edition.displayName,
        checksumSha256: edition.textSha256,
      ),
      profiles: exports,
    );

    // TODO(E17): run HifzBackup.export OFF the UI isolate via compute() — the
    // encrypted path's Argon2id (64 MiB) blocks; the plaintext default is fast.
    return HifzBackup.export(snapshot, passphrase: passphrase);
  }

  /// A locale-independent suggested file name for the share sheet.
  String suggestedFileName() => 'hifz-${_today()}.hifzbackup';
}
