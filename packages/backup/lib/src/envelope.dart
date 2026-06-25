// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'backup_error.dart';

// The §6 optional encryption envelope (mode 0x02): an Argon2id → ChaCha20-Poly1305
// sealing of the canonical JSON. The file key is passphrase-derived and
// INDEPENDENT of the device DB key (a portable file must open on another device).
// Run OFF the UI isolate (Argon2id at 64 MiB is deliberately slow). The envelope
// body (the bytes the §5 SHA-256 covers, for mode 0x02):
//
//    0   1  KDF id            0x01 = Argon2id (RFC 9106)
//    1   4  Argon2 memory KiB UInt32 BE; v1 = 65536; restore-clamped [19456..1048576]
//    5   4  Argon2 iterations UInt32 BE; v1 = 3; restore-clamped [1..16]
//    9   1  Argon2 parallelism v1 = 1
//   10  16  salt              CSPRNG, fresh per export
//   26  12  nonce             CSPRNG, fresh per export (96-bit ChaCha20 nonce)
//   38   m  ciphertext        ChaCha20-Poly1305 over the JSON, AAD = the 16-byte §3 header
//  38+m 16  Poly1305 tag      authentication tag

const int kKdfArgon2id = 0x01;
const int kArgon2MemoryExport = 65536; // 64 MiB
const int kArgon2MemoryMin = 19456;
const int kArgon2MemoryMax = 1048576;
const int kArgon2IterationsExport = 3;
const int kArgon2IterationsMin = 1;
const int kArgon2IterationsMax = 16;
const int kArgon2Parallelism = 1;
const int kSaltLen = 16;
const int kNonceLen = 12;
const int kTagLen = 16;
const int kKeyLen = 32;

/// The fixed envelope header length (kdfId + params + salt + nonce), before the
/// ciphertext and the 16-byte tag.
const int kEnvelopeHeaderLen = 1 + 4 + 4 + 1 + kSaltLen + kNonceLen; // 38

/// Clamps a hostile/foreign Argon2 memory parameter to the documented range
/// *before* derivation (§6), so a hostile header cannot demand minutes/hours of
/// memory-hard work pre-authentication. The KDF therefore only ever sees an
/// in-range value.
int clampArgon2Memory(int kiB) => kiB < kArgon2MemoryMin
    ? kArgon2MemoryMin
    : (kiB > kArgon2MemoryMax ? kArgon2MemoryMax : kiB);

/// Clamps a hostile/foreign Argon2 iteration count to the documented range (§6).
int clampArgon2Iterations(int t) => t < kArgon2IterationsMin
    ? kArgon2IterationsMin
    : (t > kArgon2IterationsMax ? kArgon2IterationsMax : t);

// TODO(E17): Unicode-NFC-normalize the passphrase before derivation (§6) so a
// passphrase typed with different composition on another device derives the same
// key. Dart has no built-in normalization; this needs `unorm_dart` (a second
// runtime dependency → a Decision-log amendment). Until ratified this is the
// identity, so a passphrase must be entered with identical composition across
// devices; the in-process round-trip is unaffected.
String _normalizePassphrase(String passphrase) => passphrase;

Future<List<int>> _deriveKey(
  String passphrase,
  List<int> salt, {
  required int memory,
  required int iterations,
  required int parallelism,
}) async {
  final argon2 = Argon2id(
    memory: memory,
    iterations: iterations,
    parallelism: parallelism < 1 ? 1 : parallelism,
    hashLength: kKeyLen,
  );
  final key = await argon2.deriveKeyFromPassword(
    password: _normalizePassphrase(passphrase),
    nonce: salt, // Argon2's "nonce" is the password salt
  );
  return key.extractBytes();
}

/// Seals [jsonBytes] into the §6 envelope under [passphrase], with AAD = the
/// 16-byte §3 header [aad]. A fresh CSPRNG salt + nonce are generated per call;
/// v1 export params (64 MiB / 3 / 1) are stored in the envelope header.
Future<Uint8List> sealEnvelope(
  Uint8List jsonBytes,
  String passphrase,
  Uint8List aad,
) async {
  final rng = Random.secure();
  final salt =
      Uint8List.fromList(List<int>.generate(kSaltLen, (_) => rng.nextInt(256)));
  final key = await _deriveKey(
    passphrase,
    salt,
    memory: kArgon2MemoryExport,
    iterations: kArgon2IterationsExport,
    parallelism: kArgon2Parallelism,
  );
  final box = await Chacha20.poly1305Aead()
      .encrypt(jsonBytes, secretKey: SecretKey(key), aad: aad);

  final params = ByteData(8)
    ..setUint32(0, kArgon2MemoryExport)
    ..setUint32(4, kArgon2IterationsExport); // big-endian default
  return (BytesBuilder()
        ..addByte(kKdfArgon2id)
        ..add(params.buffer.asUint8List())
        ..addByte(kArgon2Parallelism)
        ..add(salt)
        ..add(box.nonce) // 12-byte CSPRNG nonce from the cipher
        ..add(box.cipherText)
        ..add(box.mac.bytes))
      .toBytes();
}

/// Opens a §6 envelope under [passphrase], with AAD = the 16-byte §3 header
/// [aad]. Argon2 params are clamped to range *before* derivation. Any failure —
/// a wrong passphrase, a corrupted ciphertext, or a structurally bad envelope —
/// surfaces the single, indistinguishable [BackupError.wrongPasswordOrDamaged]
/// (§6); the reader never claims to know which.
Future<Uint8List> openEnvelope(
  Uint8List envelope,
  String passphrase,
  Uint8List aad,
) async {
  if (envelope.length < kEnvelopeHeaderLen + kTagLen ||
      envelope[0] != kKdfArgon2id) {
    throw const BackupException(BackupError.wrongPasswordOrDamaged);
  }
  final header = ByteData.sublistView(envelope);
  final memory = clampArgon2Memory(header.getUint32(1));
  final iterations = clampArgon2Iterations(header.getUint32(5));
  final parallelism = envelope[9];
  final salt = Uint8List.sublistView(envelope, 10, 10 + kSaltLen);
  final nonce =
      Uint8List.sublistView(envelope, 26, 26 + kNonceLen);
  final cipherText =
      Uint8List.sublistView(envelope, kEnvelopeHeaderLen, envelope.length - kTagLen);
  final mac = Uint8List.sublistView(envelope, envelope.length - kTagLen);

  final key = await _deriveKey(
    passphrase,
    salt,
    memory: memory,
    iterations: iterations,
    parallelism: parallelism,
  );
  try {
    final clear = await Chacha20.poly1305Aead().decrypt(
      SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
      secretKey: SecretKey(key),
      aad: aad,
    );
    return Uint8List.fromList(clear);
  } on SecretBoxAuthenticationError {
    throw const BackupException(BackupError.wrongPasswordOrDamaged);
  }
}
