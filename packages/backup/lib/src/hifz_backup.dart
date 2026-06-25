// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'backup_error.dart';
import 'container.dart';
import 'envelope.dart';
import 'integrity.dart';
import 'payload.dart';
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
  static Future<Uint8List> export(
    BackupSnapshot snapshot, {
    String? passphrase,
  }) async {
    final json = encodeCanonicalJson(snapshotToJson(snapshot)); // §4
    if (passphrase == null) {
      final prefix = writeHeaderPrefix(BackupMode.plaintextJson, json.length);
      return _assemble(prefix, json);
    }
    // The AAD is the 16-byte header, whose length field is the envelope length:
    // the 38-byte envelope header + the ciphertext (== json) + the 16-byte tag.
    final envelopeLength = kEnvelopeHeaderLen + json.length + kTagLen;
    final prefix = writeHeaderPrefix(BackupMode.encryptedJson, envelopeLength);
    final body = await sealEnvelope(json, passphrase, prefix); // §6, AAD = prefix
    return _assemble(prefix, body);
  }

  /// Parse → verify integrity → (optional) decrypt → decode + migrate, in the §3
  /// NORMATIVE parse order, throwing a typed [BackupException] at each stage —
  /// never a generic catch-all (§1, §3).
  static Future<BackupSnapshot> import(
    Uint8List fileBytes, {
    String? passphrase,
  }) async {
    // Steps 1–5 — structural header parse (length, magic, format, mode, length).
    final header = readContainerHeader(fileBytes);
    final body = containerBody(fileBytes);
    // Step 6 — verify the body SHA-256 in BOTH modes, before any decode/decrypt.
    if (!verifyBody(body, header.storedDigest)) {
      throw const BackupException(BackupError.integrityFailed);
    }
    // Step 7 — decrypt the envelope if mode 0x02 (§6).
    final Uint8List jsonBytes;
    if (header.mode == BackupMode.encryptedJson) {
      if (passphrase == null) {
        // Encrypted file, no passphrase — surfaced like any open failure (§6).
        throw const BackupException(BackupError.wrongPasswordOrDamaged);
      }
      jsonBytes = await openEnvelope(body, passphrase, header.headerBytes);
    } else {
      jsonBytes = body;
    }
    // Step 8 — decode + read schemaVersion (> current ⇒ newerFormat, else migrate).
    return snapshotFromJson(decodeJsonObject(jsonBytes));
  }

  static Uint8List _assemble(Uint8List prefix, Uint8List body) => (BytesBuilder()
        ..add(prefix) // §3 bytes 0..15
        ..add(bodyDigest(body)) // §5 bytes 16..47
        ..add(body)) // bytes 48..
      .toBytes();
}
