// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

/// The container mode byte (domain-backup-format §2/§3): plaintext is the
/// DEFAULT — encryption is opt-in. [plaintextJson] writes `0x01`,
/// [encryptedJson] writes `0x02`.
enum BackupMode { plaintextJson, encryptedJson }

/// Distinct, user-mappable failure reasons (§1) — NEVER a generic catch-all.
/// Each maps to a calm, localized message in the UI (ui-backup-and-restore), and
/// is emitted in the §3 normative restore-side parse order so a hostile or wrong
/// file is rejected with the cheapest applicable check first.
enum BackupError {
  /// Magic/format-byte mismatch, a non-zero reserved byte, or a file shorter
  /// than the 49-byte minimum (§3 steps 1–3).
  notAHifzBackup,

  /// The cleartext format byte — or, post-decode, the payload `schemaVersion` —
  /// is newer than this app understands (§3, §4); refused before any DB write.
  newerFormat,

  /// The mode byte is neither `0x01` (plaintext) nor `0x02` (encrypted) (§3).
  unknownMode,

  /// The body SHA-256 does not match the header digest — corruption or a
  /// truncated transfer, fail-closed before any decode/write (§5).
  integrityFailed,

  /// AEAD open failed (mode `0x02`). A wrong passphrase and a corrupted
  /// ciphertext are deliberately indistinguishable — the reader never claims to
  /// know which (§6).
  wrongPasswordOrDamaged,

  /// JSON decode or schema validation failed (a missing required field, a wrong
  /// shape) after a verified, decrypted body (§4).
  malformedPayload,
}

/// The single typed exception the backup package throws; it carries exactly one
/// [BackupError]. The façade never throws a generic error (§1) — every failure
/// is one of these typed reasons.
@immutable
class BackupException implements Exception {
  /// Wraps a single typed [error].
  const BackupException(this.error);

  /// The typed reason this backup operation failed.
  final BackupError error;

  @override
  String toString() => 'BackupException(${error.name})';
}
