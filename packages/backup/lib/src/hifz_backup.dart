// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'snapshot.dart';

/// The pure public façade (domain-backup-format §1) — CPU + crypto only, NO I/O.
///
/// The shell reads rows through `/data`, maps them to a [BackupSnapshot], and
/// hands it to [export]; on [import] the shell writes the validated snapshot back
/// through `/data` in one transaction. The package is store-blind and opens no
/// socket — `dart:io` and the OS share sheet are the shell's job (§1, §9).
abstract final class HifzBackup {
  /// Serialize → canonical sorted-key JSON (§4) → SHA-256 body (§5) → optional
  /// Argon2id→ChaCha20-Poly1305 envelope (§6) → §3 container bytes.
  ///
  /// A null [passphrase] writes mode `0x01` (plaintext versioned JSON — the
  /// default); a non-null one writes mode `0x02` (the encrypted envelope). Run
  /// OFF the UI isolate: Argon2id at 64 MiB is deliberately slow (§6).
  ///
  /// Implemented across E17-T02 (container) · T03 (payload) · T04 (integrity) ·
  /// T05 (envelope). The default plaintext path needs no `cryptography` dep.
  static Future<Uint8List> export(
    BackupSnapshot snapshot, {
    String? passphrase,
  }) async {
    throw UnimplementedError('HifzBackup.export — implemented in E17-T02..T05');
  }

  /// Parse → (optional) decrypt → verify integrity → decode + migrate, in the §3
  /// NORMATIVE parse order, throwing a typed `BackupException` at each stage —
  /// never a generic catch-all (§1, §3).
  ///
  /// Implemented across E17-T02..T05.
  static Future<BackupSnapshot> import(
    Uint8List fileBytes, {
    String? passphrase,
  }) async {
    throw UnimplementedError('HifzBackup.import — implemented in E17-T02..T05');
  }
}
