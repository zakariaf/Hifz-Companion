// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'backup_error.dart';

// The §3 container — the self-describing binary header that wraps every
// `.hifzbackup` body. All multi-byte integers are big-endian. The layout is
// forced by the unambiguous facts in docs/engineering/10-backup-format.md §3:
// the magic is `HIFZBK` (6 bytes), the header is 16 bytes, the body SHA-256 sits
// at offset 16, the body at offset 48, and the minimum file is 49 bytes:
//
//    0   6  magic "HIFZBK"    48 49 46 5A 42 4B
//    6   1  separator         0x1F  (US — makes the magic non-text-pasteable)
//    7   1  format version    0x01  (the container grammar version)
//    8   1  mode              0x01 plaintext JSON · 0x02 encrypted envelope
//    9   4  body length n     UInt32 big-endian
//   13   3  reserved          00 00 00  (must be zero in v1; non-zero ⇒ reject)
//   16  32  body SHA-256      digest over bytes [48 …]  (verified in §5 / T04)
//   48   n  body              canonical JSON (§4) · encryption envelope (§6)
//
// The first 16 bytes are the encryption AAD (§6). `schemaVersion` is NOT in this
// cleartext header — it is the first key of the JSON payload, so an encrypted
// file's header leaks nothing about contents beyond "this is a Hifz backup".

/// The ASCII magic `HIFZBK` (6 bytes) that opens every container.
const List<int> kMagic = <int>[0x48, 0x49, 0x46, 0x5A, 0x42, 0x4B];

/// The unit-separator byte after the magic.
const int kSeparator = 0x1F;

/// The container grammar version this app writes and accepts.
const int kFormatVersion = 0x01;

/// The fixed 16-byte cleartext header length (also the §6 encryption AAD length).
const int kHeaderLen = 16;

/// The SHA-256 body digest length (§5).
const int kDigestLen = 32;

/// The minimum valid file: header + digest + at least one body byte (§3).
const int kMinFileLen = kHeaderLen + kDigestLen + 1; // 49

const int _oFormat = 7;
const int _oMode = 8;
const int _oBodyLen = 9; // UInt32 big-endian, bytes 9..12
const int _oReserved = 13; // bytes 13..15
const int _oBody = kHeaderLen + kDigestLen; // 48

int _modeByte(BackupMode m) => m == BackupMode.plaintextJson ? 0x01 : 0x02;

/// The parsed §3 header (steps 1–5): the [mode], the declared [bodyLength], the
/// 32-byte [storedDigest] (verified in §5), and the 16-byte [headerBytes] view
/// (the §6 encryption AAD).
class ContainerHeader {
  /// Wraps a successfully parsed header.
  const ContainerHeader({
    required this.mode,
    required this.bodyLength,
    required this.storedDigest,
    required this.headerBytes,
  });

  /// Plaintext (`0x01`) or encrypted (`0x02`).
  final BackupMode mode;

  /// The declared body length, already cross-checked against the file size.
  final int bodyLength;

  /// The 32-byte body SHA-256 stored in the header (verified by the caller, §5).
  final Uint8List storedDigest;

  /// The 16-byte cleartext header — the AAD an encrypted body is sealed under (§6).
  final Uint8List headerBytes;
}

/// Writes the 16-byte §3 header prefix (magic … reserved) for [mode] over a
/// [bodyLength]-byte body. This prefix is the §6 encryption AAD; the caller
/// splices the 32-byte body digest (§5) and the body after it.
Uint8List writeHeaderPrefix(BackupMode mode, int bodyLength) {
  final h = Uint8List(kHeaderLen); // zero-filled ⇒ reserved bytes already 0
  h.setRange(0, kMagic.length, kMagic);
  h[kMagic.length] = kSeparator; // offset 6
  h[_oFormat] = kFormatVersion;
  h[_oMode] = _modeByte(mode);
  ByteData.sublistView(h).setUint32(_oBodyLen, bodyLength); // big-endian default
  return h;
}

/// Parses the §3 header in the normative restore-side order (steps 1–5),
/// throwing a typed [BackupException] at the FIRST failing stage. It does not
/// verify the digest (§5 / T04) or decode the body — it returns the structural
/// header so the caller can run integrity → decrypt → decode (steps 6–8).
ContainerHeader readContainerHeader(Uint8List file) {
  // Step 1 — minimum length (the cheapest reject, before any field read).
  if (file.length < kMinFileLen) {
    throw const BackupException(BackupError.notAHifzBackup);
  }
  // Step 2 — magic + separator.
  for (var i = 0; i < kMagic.length; i++) {
    if (file[i] != kMagic[i]) {
      throw const BackupException(BackupError.notAHifzBackup);
    }
  }
  if (file[kMagic.length] != kSeparator) {
    throw const BackupException(BackupError.notAHifzBackup);
  }
  // Step 3 — format version: newer ⇒ "please update"; any other non-0x01 ⇒ not ours.
  final format = file[_oFormat];
  if (format > kFormatVersion) {
    throw const BackupException(BackupError.newerFormat);
  }
  if (format != kFormatVersion) {
    throw const BackupException(BackupError.notAHifzBackup);
  }
  // Step 4 — mode.
  final mode = switch (file[_oMode]) {
    0x01 => BackupMode.plaintextJson,
    0x02 => BackupMode.encryptedJson,
    _ => throw const BackupException(BackupError.unknownMode),
  };
  // Step 5 — reserved bytes zero, and the declared body length matches the file.
  if (file[_oReserved] != 0 ||
      file[_oReserved + 1] != 0 ||
      file[_oReserved + 2] != 0) {
    throw const BackupException(BackupError.notAHifzBackup);
  }
  final bodyLength = ByteData.sublistView(file).getUint32(_oBodyLen); // big-endian
  if (kHeaderLen + kDigestLen + bodyLength != file.length) {
    throw const BackupException(BackupError.notAHifzBackup);
  }
  return ContainerHeader(
    mode: mode,
    bodyLength: bodyLength,
    storedDigest: Uint8List.sublistView(file, kHeaderLen, _oBody),
    headerBytes: Uint8List.sublistView(file, 0, kHeaderLen),
  );
}

/// The body bytes (offset 48 onward). Call only after [readContainerHeader]
/// has validated the structure.
Uint8List containerBody(Uint8List file) => Uint8List.sublistView(file, _oBody);
