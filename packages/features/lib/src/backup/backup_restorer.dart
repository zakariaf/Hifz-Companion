// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:backup/backup.dart';
import 'package:data/data.dart' show RestoreRepository;
import 'package:models/models.dart';

/// How an import combines with the existing store (domain-backup-format §7) — the
/// two explicit, separately-confirmed modes.
enum RestoreMode { replace, merge }

/// Thrown when an import's muṣḥaf does not match this device's edition (§7, R2).
/// Cards index a layout-specific muṣḥaf, so a cross-edition import is refused with
/// a clear message — never silently coerced.
class CrossMushafRefused implements Exception {
  /// Records the incoming vs the local muṣḥaf id for the refusal message.
  const CrossMushafRefused(this.incomingMushafId, this.localMushafId);

  /// The muṣḥaf id the backup was recorded against.
  final String incomingMushafId;

  /// This device's muṣḥaf id.
  final String localMushafId;

  @override
  String toString() =>
      'CrossMushafRefused(incoming: $incomingMushafId, local: $localMushafId)';
}

/// The shell-side restore orchestration (E17-T06): decode a `.hifzbackup` into a
/// [BackupSnapshot], refuse a cross-muṣḥaf import, then apply each profile through
/// the data restore write path. Each profile is one all-or-nothing Drift
/// transaction in the data layer; the reactive card/log streams republish the UI
/// after the durable commit (persist-before-republish).
///
/// Run OFF the UI isolate — decode + (for an encrypted file) Argon2id are slow.
class BackupRestorer {
  /// Creates the restorer over the data restore path and the injected clock.
  BackupRestorer({
    required RestoreRepository restore,
    required CalendarDate Function() today,
  })  : _restore = restore,
        _today = today;

  final RestoreRepository _restore;
  final CalendarDate Function() _today;

  /// Decodes [bytes] (a bad/locked/corrupt file throws a typed [BackupException]),
  /// refuses a cross-muṣḥaf import ([CrossMushafRefused]), then applies every
  /// profile in [mode]. [passphrase] is required for an encrypted file.
  Future<void> restore(
    Uint8List bytes, {
    required RestoreMode mode,
    String? passphrase,
  }) async {
    final snapshot = await HifzBackup.import(bytes, passphrase: passphrase);

    // R2 — a backup made against another muṣḥaf indexes a different page geometry;
    // refuse rather than coerce cards onto the wrong layout.
    final localId = kKfgqpcHafsMadaniV2Edition.mushafId;
    if (snapshot.mushaf.id != localId) {
      throw CrossMushafRefused(snapshot.mushaf.id, localId);
    }

    final today = _today();
    final apply = mode == RestoreMode.replace
        ? _restore.replaceProfile
        : _restore.mergeProfile;
    for (final p in snapshot.profiles) {
      await apply(
        profile: p.profile,
        cycleConfig: p.cycleConfig,
        cards: p.cards,
        lineBlocks: p.lineBlocks,
        reviewLog: p.reviewLog,
        confusionEdges: p.confusionEdges,
        today: today,
      );
    }
  }
}
