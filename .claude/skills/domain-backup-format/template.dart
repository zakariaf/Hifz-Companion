// template.dart — copy-paste scaffold for the local, offline `.hifzbackup` format.
//
// Skill: domain-backup-format
// Governing docs:
//   docs/engineering/10-backup-format.md            §§1–10
//   docs/engineering/05-persistence-and-encryption.md §§1–5 (store boundary, review_log append-only, transactions, opt-in cipher)
//   docs/PRD.md §16 (backup & portability), §17 (privacy), §10.2/§10.3 (truth vs derived), R1/R2
//
// THE backup/ PACKAGE IS PURE DART OVER VALUE TYPES + BYTES. It imports NO drift,
// NO sqlite3, and NO networking package (CI banned-import gate, §1). It does file
// *bytes*, not file *system* and not database: serialization, integrity, optional
// crypto, structural validation, and the merge algorithm over value types live
// here; reading/writing the live store and moving the file live in the shell.
//
// Run all crypto OFF the UI isolate (Argon2id at 64 MiB is deliberately slow, §6).

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto; // Dart team — SHA-256 (§5). The
// ONLY hashing dep; the same one that pins the Quran asset packs.
import 'package:cryptography/cryptography.dart'; // pure-Dart Argon2id + ChaCha20-
// Poly1305 (§6). Imported only on the encrypted path.
// NOTE: NO `package:drift`, NO `package:sqlite3`, NO `dio`/`http`/`dart:io` socket
// here — see §1. dart:io is the SHELL's job (file move + share sheet, §9).

// ── Container constants — the §3 binary header. Never re-derive these offsets ──
const List<int> _kMagic = [0x48, 0x49, 0x46, 0x5A, 0x42, 0x4B]; // "HIFZBK"
const int _kSeparator = 0x1F; // US — makes the magic non-text-pasteable
const int _kFormatVersion = 0x01; // container/envelope GRAMMAR version
const int _kHeaderLen = 16; // magic(7)+fmt(1)+mode(1)+len(4)+reserved(2)... see below
const int _kDigestLen = 32; // SHA-256
const int _kMinFileLen = 16 + 32 + 1; // header + hash + ≥1 body byte = 49 (§3)

// Mode byte (§2/§3): plaintext is the DEFAULT — encryption is opt-in.
enum BackupMode { plaintextJson, encryptedJson } // 0x01, 0x02

int _modeByte(BackupMode m) => m == BackupMode.plaintextJson ? 0x01 : 0x02;

// Distinct, user-mappable failure reasons (§1). NEVER a generic catch-all; each
// maps to a calm, localized message in the UI (see ui-backup-and-restore).
enum BackupError {
  notAHifzBackup, // magic/format mismatch, or truncated
  newerFormat, // format byte OR schemaVersion > this app understands
  unknownMode, // mode byte not recognized
  integrityFailed, // body SHA-256 mismatch (plaintext corruption / truncation)
  wrongPasswordOrDamaged, // AEAD open failed — wrong key vs corruption indistinguishable (§6)
  malformedPayload, // JSON decode / schema validation failed
}

class BackupException implements Exception {
  const BackupException(this.error);
  final BackupError error;
  @override
  String toString() => 'BackupException(${error.name})';
}

// ── The portable value object (§1/§4) — TRUTH only, never derived state ───────
// The shell maps /data DAO rows into this; the package never queries the DB.
class BackupSnapshot {
  const BackupSnapshot({
    required this.schemaVersion, // == Drift schemaVersion at export (§3 step 8 gate)
    required this.appVersion, // informational only; NEVER used for logic
    required this.exportedAt, // floating "YYYY-MM-DD" of export
    required this.mushaf, // {id, riwayah, name, checksumSha256} — NO glyphs/text (§4, R1/R2)
    required this.profiles,
  });
  final int schemaVersion;
  final String appVersion;
  final String exportedAt;
  final MushafRef mushaf;
  final List<ProfileExport> profiles;

  // TODO: toJson MUST emit ONLY truth — cards (D/S/dueAt/flags), lineBlocks, the
  //       append-only reviewLog, confusionEdges, profile, cycleConfig. NO juz/ḥizb
  //       health %, NO Today list, NO forecast, NO notification cache (§4; PRD §10.3).
  //       Scheduling days → floating "YYYY-MM-DD"; true instants → UTC ISO-8601.
  Map<String, dynamic> toJson() => throw UnimplementedError('TODO §4');
  static BackupSnapshot fromJson(Map<String, dynamic> j) =>
      throw UnimplementedError('TODO §4 — migrate older schemaVersion forward');
}

class MushafRef {
  const MushafRef(this.id, this.riwayah, this.name, this.checksumSha256);
  final String id, riwayah, name, checksumSha256; // identity only — NEVER bytes
}

class ProfileExport {
  // TODO: profile, cycleConfig, cards, lineBlocks, reviewLog, confusionEdges.
  //       reviewLog rows + the profile carry STABLE UUIDs (logId/profileId) assigned
  //       at row creation, carried verbatim — they are the content-address keys that
  //       make merge a deduplicating set union (§4/§7).
  const ProfileExport();
}

// ── Canonical JSON (§4) — sorted keys → deterministic bytes → reproducible hash ──
Uint8List _canonicalJsonBytes(Map<String, dynamic> payload) =>
    Uint8List.fromList(utf8.encode(jsonEncode(_sortKeysDeep(payload))));

Object? _sortKeysDeep(Object? v) {
  if (v is Map) {
    final sorted = <String, Object?>{};
    for (final k in v.keys.map((k) => k.toString()).toList()..sort()) {
      sorted[k] = _sortKeysDeep(v[k]);
    }
    return sorted;
  }
  if (v is List) return v.map(_sortKeysDeep).toList();
  return v;
}

// ── §5 integrity — SHA-256 of the body, in BOTH modes. Corruption detection,
//    NOT tamper resistance. SHA-256 only; never MD5/SHA-1. ──────────────────────
List<int> _bodyDigest(Uint8List body) => crypto.sha256.convert(body).bytes; // 32 B

bool _verifyBody(Uint8List body, List<int> stored) {
  final actual = crypto.sha256.convert(body).bytes;
  if (actual.length != stored.length) return false;
  var ok = true;
  for (var i = 0; i < actual.length; i++) {
    ok = ok && actual[i] == stored[i];
  }
  return ok; // constant-time unnecessary (no secret), but length+content required
}

// ── §6 encryption envelope (mode 0x02) — Argon2id → ChaCha20-Poly1305 ──────────
// Same AEAD FAMILY as the opt-in DB cipher (one crypto mental model). The file
// key is INDEPENDENT of the device DB key (a portable file must open elsewhere).
class _EnvelopeParams {
  // v1 export defaults; restore CLAMPS to these ranges BEFORE any derivation (§6)
  static const memoryKiBExport = 65536; // 64 MiB
  static const memoryKiBMin = 19456, memoryKiBMax = 1048576;
  static const iterationsExport = 3;
  static const iterationsMin = 1, iterationsMax = 16;
  static const parallelism = 1;
}

Future<Uint8List> _seal(Uint8List jsonBytes, String passphrase, Uint8List header) async {
  // TODO §6:
  //  1. Generate a FRESH 16-byte salt + 12-byte nonce from a CSPRNG.
  //  2. NFC-normalize then UTF-8 the passphrase before derivation.
  //  3. Derive a 32-byte key with Argon2id (memory/iterations/parallelism above).
  //  4. ChaCha20-Poly1305 encrypt jsonBytes with AAD = `header` (the 16-byte §3 header).
  //  5. Lay out the envelope: [kdfId 0x01][mem u32][iters u32][p 1][salt 16][nonce 12]
  //     [ciphertext][tag 16] — this whole envelope is the "body" the §5 hash covers.
  throw UnimplementedError('TODO §6 — run OFF the UI isolate');
}

Future<Uint8List> _open(Uint8List envelope, String passphrase, Uint8List header) async {
  // TODO §6:
  //  - Parse kdfId + params; CLAMP mem/iters to [min..max] BEFORE deriving, so a
  //    hostile header cannot demand minutes of pre-auth work.
  //  - Re-derive the key; ChaCha20-Poly1305 decrypt with AAD = `header`.
  //  - ANY AEAD failure → throw BackupException(wrongPasswordOrDamaged). The reader
  //    NEVER claims to know whether it was a wrong passphrase or corruption.
  throw UnimplementedError('TODO §6');
}

// ── §1 public façade — pure CPU + crypto, NO I/O ──────────────────────────────
abstract final class HifzBackup {
  /// Serialize → canonical JSON → integrity hash → (optional) encrypt → bytes.
  static Future<Uint8List> export(
    BackupSnapshot snapshot, {
    String? passphrase,
  }) async {
    final json = _canonicalJsonBytes(snapshot.toJson()); // sorted keys (§4)
    final mode =
        passphrase == null ? BackupMode.plaintextJson : BackupMode.encryptedJson;

    final header = _writeHeaderPrefix(mode); // first 16 bytes, hash filled below
    final body = mode == BackupMode.plaintextJson
        ? json
        : await _seal(json, passphrase!, header); // AAD = header (§6)

    final out = BytesBuilder()
      ..add(_finalizeHeader(header, body.length, _bodyDigest(body))) // §3
      ..add(body);
    return out.toBytes();
  }

  /// Parse → (optional) decrypt → verify integrity → decode → validate + migrate.
  /// Follows the §3 NORMATIVE parse order; throws a typed BackupException.
  static Future<BackupSnapshot> import(
    Uint8List fileBytes, {
    String? passphrase,
  }) async {
    if (fileBytes.length < _kMinFileLen) {
      throw const BackupException(BackupError.notAHifzBackup); // §3 step 1
    }
    final header = _readHeader(fileBytes); // steps 2–5: magic, format, mode, length
    final body = Uint8List.sublistView(fileBytes, _kHeaderLen + _kDigestLen);

    // Step 6 — verify body SHA-256 (BOTH modes) BEFORE any decrypt/decode.
    if (!_verifyBody(body, header.digest)) {
      throw const BackupException(BackupError.integrityFailed);
    }

    // Step 7 — decrypt if mode 0x02 (AEAD failure → wrongPasswordOrDamaged).
    final jsonBytes = header.mode == BackupMode.plaintextJson
        ? body
        : await _open(body, _requirePass(passphrase),
            Uint8List.sublistView(fileBytes, 0, _kHeaderLen));

    // Step 8 — decode + read schemaVersion; > current ⇒ newerFormat, else migrate.
    final Map<String, dynamic> map;
    try {
      map = jsonDecode(utf8.decode(jsonBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw const BackupException(BackupError.malformedPayload);
    }
    // TODO: if (map['schemaVersion'] as int) > kCurrentSchemaVersion → newerFormat.
    return BackupSnapshot.fromJson(map); // migrates older versions forward (§4)
  }
}

String _requirePass(String? p) =>
    p ?? (throw const BackupException(BackupError.wrongPasswordOrDamaged));

// ── §3 header read/write helpers — every offset traces to the doc table ───────
class _Header {
  const _Header(this.mode, this.bodyLen, this.digest);
  final BackupMode mode;
  final int bodyLen;
  final List<int> digest;
}

_Header _readHeader(Uint8List f) {
  // TODO §3 step 2: magic == _kMagic && f[6] == _kSeparator, else notAHifzBackup.
  // TODO §3 step 3: f[7] (format) > _kFormatVersion ⇒ newerFormat; other ≠ 0x01 ⇒ notAHifzBackup.
  // TODO §3 step 4: f[8] (mode) ∈ {0x01,0x02}, else unknownMode.
  // TODO §3 step 5: read UInt32 BE body length at offset 9 (and the 2 reserved zero
  //                 bytes); assert (headerLen + digestLen + bodyLen) == f.length,
  //                 else notAHifzBackup. Digest is the 32 bytes after the prefix.
  throw UnimplementedError('TODO §3 — see the offset table in the doc');
}

Uint8List _writeHeaderPrefix(BackupMode mode) {
  // TODO §3: magic(7) + separator(1) + formatVersion(1) + modeByte(1) + zeros for
  //          (len u32 + reserved u16) to be filled by _finalizeHeader. Big-endian.
  final b = Uint8List(_kHeaderLen);
  b.setRange(0, 6, _kMagic);
  b[6] = _kSeparator;
  b[7] = _kFormatVersion;
  b[8] = _modeByte(mode);
  return b; // bytes 9..15 (len + reserved) filled in _finalizeHeader
}

Uint8List _finalizeHeader(Uint8List prefix, int bodyLen, List<int> digest) {
  // TODO §3: write bodyLen as UInt32 BE at offset 9; keep offsets 14–15 = 00 00;
  //          then append the 32-byte body digest. Result is the full 48-byte header.
  throw UnimplementedError('TODO §3');
}

// ══════════════════════════════════════════════════════════════════════════════
// SHELL SIDE (NOT in backup/): /data read → backup/ serialize → OS share, and the
// import transaction. Lives where drift + dart:io are allowed. Shown for context.
// ══════════════════════════════════════════════════════════════════════════════

enum BackupScope { all, profile } // export one profile or all (§1 store-blind)
enum ImportMode { replace, merge } // §7 — two EXPLICIT, separately-confirmed modes

abstract interface class ShellDataLayer {
  Future<BackupSnapshot> readSnapshot(BackupScope scope); // DAOs → value types
  Future<void> runInTransaction(Future<void> Function() body); // Drift txn (§3 persistence doc)
}

// §7 — the merge: a content-addressed SET UNION over the append-only review_log,
// in ONE transaction. NEVER overwrite/delete a review_log row; NEVER duplicate a
// teacher sign-off; rebuild each touched card from the MERGED log; refuse a
// cross-muṣḥaf import. A failure rolls back to the exact pre-import state.
Future<void> mergeImport(ShellDataLayer data, BackupSnapshot incoming) {
  return data.runInTransaction(() async {
    // TODO §7 — _assertSameMushaf(incoming): same mushaf id + checksumSha256, else
    //           refuse (R2 — cards index a layout-specific page geometry).
    for (final _ in incoming.profiles) {
      // TODO _upsertProfileMetadata(p)        — by profileId; conflicts SURFACED, not auto-resolved
      // TODO _unionReviewLog(p.reviewLog)      — insert rows whose logId is ABSENT; skip present (idempotent)
      // TODO _unionLineBlocks(p.lineBlocks)    — errorCount = max
      // TODO _unionConfusionEdges(p.edges)     — weight summed-then-capped, lastConfusedAt = max
      // TODO _recomputeCardsFromLog(profileId) — domain-scheduling-engine-rules: rebuild D/S and
      //      RE-APPLY THE TRUST CLAMP under THIS device's cycle, so an imported dueAt can never
      //      exceed the local cycle ceiling (§7.6 invariant survives transfer).
    }
    // Notifications are re-scheduled from cycle_config AFTER commit (rebuildable cache).
  });
}

// §7 replace (full restore): validate in memory first (a wrong passphrase / corrupt
// file loses nothing), then in ONE transaction wipe in-scope rows + insert verbatim
// (UUIDs preserved), then re-clamp every imported card's dueAt via the engine.
Future<void> replaceImport(ShellDataLayer data, BackupSnapshot incoming) {
  return data.runInTransaction(() async {
    // TODO §7: delete in-scope user rows; insert snapshot rows verbatim; reference
    //          (Quran) tables are NEVER touched; recompute dueAt via the trust clamp.
    throw UnimplementedError('TODO §7');
  });
}

// §9 export & erase. The OS share sheet moves the file — the app sends NOTHING.
// No plaintext is left on disk for an encrypted export. Erase deletes the .sqlite
// AND its -wal/-shm siblings (+ the secure-storage key if encryption was on).
//
// TODO §9 (shell, dart:io allowed here ONLY):
//   final snapshot = await data.readSnapshot(scope);
//   final bytes    = await HifzBackup.export(snapshot, passphrase: passphrase); // off UI isolate
//   write bytes atomically to a temp file (e.g. Hifz-2026-06-16.hifzbackup, flushed);
//   await Share.shareXFiles([XFile(path)]);   // OS share sheet — NO app-owned transport
//   sweep the temp file after share + on next launch.
//   ERASE: db.close(); delete hifz.sqlite + -wal + -shm; secureStorage.delete('db_key').
//   Both export-as-SQLite-dump (§8: VACUUM INTO a FRESH path, never cp the live DB)
//   and erase are shown in 10-backup-format.md §8/§9.

// ── UI note (build the screens in the backup feature, not here) ───────────────
// Wrap export/import/erase in Directionality(TextDirection.rtl) for fa/ckb/ar;
// render all copy via AppLocalizations (gen_l10n), Material 3 calm styling, no
// exclamation marks, localized numerals. Replace shows "This will replace all
// data currently in Hifz Companion"; merge shows "This will add the imported
// reviews to your existing history" — DISTINCT, separately confirmed (§7). The
// plaintext-export screen states plainly that an unencrypted file is readable by
// anyone who opens it, with the one-tap encryption toggle (§2). Erase confirms it
// is irreversible and that any existing backup file is then the only remaining
// copy (§9). See ui-backup-and-restore / ux-privacy-trust-surface for exact copy.
