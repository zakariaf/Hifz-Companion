# 10 — Backup & Restore File Format (`.hifzbackup`)

This document specifies Hifz Companion's local backup file — the documented, versioned, self-describing artifact that makes a ḥāfiẓ's review history portable, recoverable, and never trapped ([PRD §16](../PRD.md)) — precisely enough that a third party could reimplement export and import from this page alone. It covers the module boundary, the file layout and its versioning, the integrity mechanism, the versioned JSON payload schema, the WAL-aware snapshot rule, the **optional** at-rest-style encryption envelope, and — the feature CycleVault's backup never needed — the **merge** semantics that let a teacher and a student exchange progress without any server.

This doc owns the *portable file*. The live database it serializes — Drift over SQLite, WAL crash-safety, the append-only `review_log`, the optional `sqlite3mc` cipher, and the `flutter_secure_storage` key — is owned by [05-persistence-and-encryption.md](05-persistence-and-encryption.md); what a stored "due date" *means* and the `CalendarDate` serial-day type are owned by [07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md); the read-only Quran reference tables and their checksum governance are owned by [08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md) and [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md) — those tables are **never** put in a backup (§4). The scheduling state this file carries is interpreted only by the pure engine ([06-scheduling-engine.md](06-scheduling-engine.md)).

There is no `Decision log` entry named "backup format" in the [README tech-decision log](README.md#tech-decision-log) — backup is the downstream consumer of three decisions and re-states none of them: it inherits *Persistence & at-rest encryption* (decision 3) for the WAL-snapshot rule, the `schemaVersion` stamp, and the cipher; *Dates, calendars & correctness* (decision 7) for the floating-date encoding that makes a cross-timezone restore byte-identical; and *No networking beyond asset download* (decision 8) for the rule that **export and import perform zero network I/O** — the OS share sheet moves the file, the app never transmits it.

Two framing rules from the README's [outranking rules](README.md#rules-that-outrank-everything) and [PRD §10.3, §16, §17](../PRD.md) govern everything below:

1. **The `review_log` is an append-only *sanad* audit trail.** Backup/restore is the *only* sanctioned bulk path that touches it ([05-persistence-and-encryption.md](05-persistence-and-encryption.md) §2). A merge that silently dropped, reordered, or duplicated a teacher sign-off would be a breach of trust, not a bug — so merge is defined as a content-addressed *set union* over immutable log rows (§7), never an overwrite.
2. **The Quran is never in the file.** A backup carries only the user's own review state; it never carries Quran bytes, fonts, layout, or the mutashābihāt dataset — those are the verified, checksum-governed asset pack ([09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)), re-derivable on any device and orders of magnitude larger. A backup references the muṣḥaf by id and checksum; it does not embed it (§4).

## At a glance

| Concern | Decision |
|---|---|
| Module | Pure-Dart `backup/` package — imports value types only; **never** Drift, `sqlite3`, or `dart:io` networking ([Flutter: packages](https://docs.flutter.dev/packages-and-plugins/developing-packages)) |
| Default form | **Plaintext, human-readable, versioned UTF-8 JSON** — data portability is the goal ([PRD §16](../PRD.md)); encryption is opt-in (*Decision log: Persistence & at-rest encryption*) |
| Container | Magic `HIFZBK\x1F` + 1-byte format version + 1-byte mode + JSON or encrypted envelope; self-describing and self-validating |
| Versioning | A `schemaVersion` int stamped from the Drift `schemaVersion` ([Drift: Migrations](https://drift.simonbinder.eu/Migrations/)); newer-than-app ⇒ refuse, older ⇒ migrate forward |
| Integrity | SHA-256 of the canonical payload, stored in the container — catches corruption even for *plaintext* backups ([NIST FIPS 180-4](https://csrc.nist.gov/pubs/fips/180-4/upd1/final); Dart-team [`crypto`](https://pub.dev/packages/crypto)) |
| Dates | Floating `"YYYY-MM-DD"` strings + UTC instants for true events — a cross-timezone restore is byte-identical (*Decision log: Dates, calendars & correctness*) |
| Optional encryption | Argon2id (RFC 9106) → ChaCha20-Poly1305 (RFC 8439) envelope; same cipher family as the opt-in DB encryption ([cryptography pub.dev](https://pub.dev/packages/cryptography)) |
| SQLite-dump variant | A consistent single-file snapshot via `VACUUM INTO` — never a copy of the live `-wal`/`-shm` family ([SQLite: VACUUM](https://sqlite.org/lang_vacuum.html); [SQLite: WAL](https://sqlite.org/wal.html)) |
| Import semantics | **Replace** (full restore) **or merge** (teacher ↔ student transfer, PRD §16) — both explicit, confirmed, transactional |
| Network | **None.** The OS share sheet moves the file; the app transmits nothing (*Decision log: No networking beyond asset download*) |
| Erase | One action wipes all local data — right-to-be-forgotten by construction ([PRD §16, §17](../PRD.md)) |

---

## 1. Module boundary

### Decision

Backup is a **pure-Dart `backup/` package** that imports the shared value-type models only — never Drift, never `package:sqlite3`, never any networking import. Its public API is functions over value types: the app shell reads rows from `/data` through DAOs, maps them to a `BackupSnapshot` value object, and hands it in; on import the package returns a validated `BackupSnapshot` the shell writes back through `/data` in one transaction. The package does file *bytes*, not file *system* and not database: serialization, integrity, optional crypto, and structural validation live here; reading/writing the live store lives in `/data` ([05-persistence-and-encryption.md](05-persistence-and-encryption.md)).

### Rationale

- **A pure package is the most auditable and testable layer.** Flutter's guidance is that a Dart package "contains pure business logic with no Flutter or framework dependencies, making it the easiest layer to test" and runs under `dart test` with no widget binding ([Flutter: Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)). For an open-source *ṣadaqah* project the community will read, a format/crypto module whose entire dependency graph is the Dart-team [`crypto`](https://pub.dev/packages/crypto) package (SHA-256) plus, only when encryption is enabled, [`cryptography`](https://pub.dev/packages/cryptography) (Argon2id, ChaCha20-Poly1305) is the strongest answer to a supply-chain audit — both are first-party / widely-vetted, pure-Dart-capable, and carry no analytics.
- **The boundary preserves the no-networking invariant structurally.** Because the package imports no networking and `dart:io` use is confined to the shell's file-move step, the CI banned-import gate (*Decision log: No networking beyond asset download*) proves "export/import sends nothing" by construction — the package literally cannot phone home ([PRD §16, §19.3](../PRD.md)).
- **Store-blind by construction.** The package receives a `BackupSnapshot` and never queries the database, so it cannot accidentally include data the shell did not select — e.g. a per-profile export structurally cannot contain another profile's rows, because the shell only ever maps the chosen profile's rows into the snapshot.

### Specification

```dart
// package:hifz_backup — imports value types + crypto only; no drift, no sqlite3, no networking.

/// Top-level value object: the entire portable state of one or all profiles.
/// Reference (Quran) tables are NEVER part of this — see §4.
class BackupSnapshot {
  final int schemaVersion;        // stamped from the Drift schemaVersion (§3)
  final String appVersion;        // informational only; never used for logic
  final String exportedAt;        // floating "YYYY-MM-DD" of export (§4)
  final List<ProfileExport> profiles;
}

enum BackupMode { plaintextJson, encryptedJson }

abstract final class HifzBackup {
  /// Serialize → canonical JSON → integrity hash → (optional) encrypt → container bytes.
  /// Pure CPU + crypto; no I/O. Run off the UI isolate for the encrypted path.
  static Uint8List export(BackupSnapshot snapshot, {String? passphrase});

  /// Parse container → (optional) decrypt → verify integrity → JSON decode →
  /// validate + migrate forward → BackupSnapshot. Throws a typed BackupError.
  static BackupSnapshot import(Uint8List fileBytes, {String? passphrase});
}

/// Distinct, user-mappable failure reasons (copy in §8). Never a generic catch-all.
enum BackupError {
  notAHifzBackup,        // magic mismatch
  newerFormat,           // format/schema version > this app understands
  unknownMode,           // mode byte not recognized
  integrityFailed,       // payload SHA-256 mismatch (plaintext corruption)
  wrongPasswordOrDamaged,// AEAD open failed (encrypted path) — indistinguishable, by design
  malformedPayload,      // JSON decode / schema validation failed
}
```

### Pitfalls / what we refuse

- **We refuse a `drift`/`sqlite3` import in `backup/`.** The same CI banned-import gate that walls Drift into `/data` ([05-persistence-and-encryption.md](05-persistence-and-encryption.md) §1) walls it out of `backup/`. The package speaks value types and bytes, nothing else.
- **We refuse any network call in the export/import path.** Moving the file is the OS share sheet's job, in the shell; the package never opens a socket. This is asserted by the dependency allow-list and import-rules gate (*Decision log: No networking beyond asset download*).
- **We refuse to let the package read the database.** It validates only what the shell handed it, so a scoping mistake cannot leak another profile's data into a file.

---

## 2. Default form: plaintext, versioned JSON — and why *not* mandatory encryption

### Decision

The default backup is **plaintext, human-readable, versioned UTF-8 JSON** inside a thin self-describing container. Encryption is an **opt-in** envelope the user must turn on with a passphrase (§6). This is a deliberate, honest divergence from a medical-data app like the CycleVault exemplar (whose backup is mandatorily encrypted): Hifz Companion's threat model and its primary use justify plaintext-by-default.

### Rationale

- **The PRD makes portability, not secrecy, the goal of the file.** §16 requires "a **documented, versioned** JSON (or SQLite dump) so data is never trapped," exported to the user's own storage / share-sheet, with "**encrypted-optional**" called out explicitly ([PRD §16](../PRD.md)). The point of the file is that a ḥāfiẓ's years of review history can be read, recovered, migrated, and inspected — a plaintext, documented JSON is the strongest possible "never trapped" guarantee, exactly the precedent the public `age` format set by being a published spec third parties can build on.
- **The data is religious-practice telemetry, not PII or medical history.** A profile is a typed display name; the payload is which muṣḥaf pages a profile reviewed and how fluently ([PRD §17](../PRD.md)). The research dossier scopes encryption here as honest defense-in-depth for *device theft / shared-device curiosity*, not network exfiltration — "WAL crash-safety and transactional integrity are mandatory; at-rest encryption is an opt-in setting" ([research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §10). The backup file mirrors that posture: integrity is mandatory, confidentiality is the user's choice.
- **The headline transfer use *wants* readability.** A teacher receiving a student's export, or a parent moving a child's profile, benefits from a file that is auditable and tool-readable; a teacher who wants privacy on a shared device turns encryption on. The default serves the common case; the option serves the sensitive one.

### Specification

The mode is one byte in the container header (§3), so a single artifact format covers both: `0x01` plaintext JSON, `0x02` encrypted-JSON envelope. Integrity (SHA-256, §5) is present in **both** modes — a plaintext backup must still detect a truncated or corrupted file, which encryption-by-AEAD would otherwise be the only thing catching.

### Pitfalls / what we refuse

- **We refuse to imply a plaintext backup is private.** The export screen states plainly, in the user's locale, that an unencrypted backup is readable by anyone who opens the file, and offers the one-tap encryption toggle. Honesty about what the file is *is* the trust feature ([PRD §17](../PRD.md)).
- **We refuse to copy CycleVault's mandatory-encryption design unexamined.** Different data, different threat model, different primary use — the blueprint forbids importing the exemplar's domain decisions ([_DOC-SET-BLUEPRINT.md](../_DOC-SET-BLUEPRINT.md) §0). We match its *rigor*, not its medical-grade default.

---

## 3. Container layout & versioning

### Decision

A `.hifzbackup` file is a short, fixed, big-endian binary header followed by a length-prefixed body. The header is self-describing (magic, format version, mode) and self-validating (a SHA-256 of the body, §5). Two version axes are carried and checked separately: the **format version** (the container/envelope grammar) and the **`schemaVersion`** (the payload's data shape, inside the JSON), the latter stamped directly from the Drift `schemaVersion` so the file and the database speak one version language.

### Rationale

- **An explicit, length-and-version-prefixed header lets the reader reject hostile or wrong input cheaply and with distinct errors before any heavy work** — the same staged-parse discipline the SRI/`age` lineage and the CycleVault exemplar use. A magic check rejects "not our file"; a version check rejects "newer than this app"; only then does the reader spend CPU on hashing or decryption.
- **Stamping `schemaVersion` from Drift ties the file's forward-compatibility to the database's.** Drift's migration system is driven by an integer `schemaVersion` with guided, per-version, transactional migrations and committed schema snapshots ([Drift: Migrations](https://drift.simonbinder.eu/Migrations/)); the research note flags that the backup "must carry a schema/app version stamp (consistent with Drift's `schemaVersion`) so an older app refuses or migrates a newer file deterministically" ([research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §8). Using the same integer means an import path can reuse the same per-version forward-migration functions the DB uses.

### Specification

All multi-byte integers are **big-endian**. Minimum valid file size is 16 bytes (header) + 32 (hash) + 1 (body) = **49 bytes**; shorter files are rejected before any parsing.

| Offset | Size | Field | Value |
|---|---|---|---|
| 0 | 7 | Magic | ASCII `HIFZBK` = `48 49 46 5A 42 4B` |
| 7 | 1 | Separator | `0x1F` (US — unit separator; makes the magic non-text-pasteable) |
| 8 | 1 | Format version | `0x01` |
| 9 | 1 | Mode | `0x01` = plaintext JSON · `0x02` = encrypted-JSON envelope |
| 10 | 4 | Body length `n` | UInt32 big-endian; rejected if `10 + 32 + n` ≠ file length |
| 14 | 2 | Reserved | `00 00` (must be zero in v1; non-zero ⇒ reject) |
| 16 | 32 | Body SHA-256 | digest over bytes `[48 …]` (the body) — §5 |
| 48 | n | Body | mode `0x01`: canonical UTF-8 JSON (§4) · mode `0x02`: encryption envelope (§6) |

The `schemaVersion` is **not** in this binary header — it lives as the first key of the JSON payload (§4), because in the encrypted mode the binary header is plaintext and must leak nothing about contents beyond "this is a Hifz backup." The reader checks the binary **format version** first; the **`schemaVersion`** is checked only after the body is decrypted (if needed) and decoded.

Restore-side parse order (normative):

1. Length ≥ 49, else `notAHifzBackup`.
2. Magic `HIFZBK` + `0x1F`, else `notAHifzBackup`.
3. Format version: `> 0x01` ⇒ `newerFormat` ("created by a newer version of the app — please update"); other non-`0x01` ⇒ `notAHifzBackup`.
4. Mode ∈ {`0x01`, `0x02`}, else `unknownMode`.
5. Body length field matches file size, else `notAHifzBackup`.
6. **Verify body SHA-256** (§5). Mismatch ⇒ `integrityFailed` for plaintext; for encrypted mode the hash is over the ciphertext envelope, so a mismatch here is also `integrityFailed` (pre-decryption corruption).
7. Mode `0x02`: decrypt the envelope (§6); AEAD failure ⇒ `wrongPasswordOrDamaged`.
8. JSON decode; read `schemaVersion`. `> currentSchemaVersion` ⇒ `newerFormat`; otherwise migrate forward (§4). Decode/validation failure ⇒ `malformedPayload`.

Steps 1–6 are cheap structural/integrity checks with distinct errors; only step 7 (encrypted) is a single indistinguishable crypto failure.

### Pitfalls / what we refuse

- **We refuse to put `schemaVersion` in the cleartext header of an encrypted file.** It would leak a fingerprint of which app build produced the file. The version that gates *data* compatibility lives inside the protected payload; only the *container* grammar version is cleartext.
- **We refuse to trust the body-length field without cross-checking the actual file length.** A mismatch is a malformed/truncated file and is rejected at step 5, before hashing.
- **We refuse to skip integrity on plaintext backups.** Without the SHA-256, a half-copied plaintext JSON would import as silently-partial data — exactly the "silent loss" the product exists to prevent ([PRD §7.12](../PRD.md)).

---

## 4. Payload schema (versioned JSON)

### Decision

The body (or, when encrypted, the plaintext inside the envelope) is **UTF-8 JSON** that is a complete, value-typed export of the per-profile user data model ([PRD §10.2](../PRD.md)) and **nothing else** — no reference/Quran tables, no derived state, no live notification cache. Dates follow the floating-date contract of *Decision log: Dates, calendars & correctness*. The JSON is produced canonically (sorted keys) so golden-file tests are byte-stable and the integrity hash is reproducible.

### Rationale

- **Export only what is *truth*, never what is *derived*.** The PRD stores strength roll-ups (juz/ḥizb health) as *computed from `card` retrievability*, "not stored as a separate authority" ([PRD §10.3](../PRD.md)); the engine recomputes them. So the backup carries `card` D/S/`due_at` and the `review_log`, and the receiving device recomputes heat-map, forecasts, and the trust-clamped `due_at` on first build ([06-scheduling-engine.md](06-scheduling-engine.md)). This keeps one source of truth and means a backup made under one cycle config can be re-clamped correctly under another.
- **Reference tables are excluded because they are the asset pack, not user data.** `page`, `line`, `ayah`, `surah`, `mushaf`, and the mutashābihāt dataset are read-only, bundled, and checksum-governed ([PRD §6.1, §11.3](../PRD.md)); they are identical on every device that downloaded the same verified pack ([09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)). The backup records the `mushaf_id` and the pack's checksum so import can *verify the target device has the same muṣḥaf*, but it never embeds those bytes.
- **Floating dates make a cross-device restore byte-identical.** `DateTime` is a proleptic-Gregorian instant that "does not provide internationalization" and warns that adding a Duration is not adding calendar days across DST ([Dart: DateTime](https://api.dart.dev/dart-core/DateTime-class.html)); encoding scheduling days as floating `"YYYY-MM-DD"` strings (the `CalendarDate` serial-day's text form) and true event instants as UTC ISO-8601 means importing in another timezone yields the same records ([07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md)).
- **Canonical (sorted-key) JSON is for testability, not security.** Dart's `dart:convert` `jsonEncode`/`utf8` (and `JsonUtf8Encoder` for direct UTF-8 bytes) produce the JSON; a key-sorting pass over the maps before encoding makes the output deterministic so the §8 round-trip and golden tests are byte-exact and the body SHA-256 is reproducible ([Dart: dart:convert](https://api.dart.dev/dart-core/dart-convert/)).

### Specification

Top-level object:

| Key | Type | Notes |
|---|---|---|
| `schemaVersion` | int | Equals the Drift `schemaVersion` at export. Gates compatibility (§3, step 8). |
| `appVersion` | string | Informational only; never used for logic. |
| `exportedAt` | string | Floating `"YYYY-MM-DD"` of export. Informational. |
| `mushaf` | object | `{ "id", "riwayah", "name", "checksumSha256" }` — identifies the muṣḥaf the cards index, for import-time compatibility (R2). No glyphs/text. |
| `profiles` | array | One `ProfileExport` per exported profile (one, or all — §5/§7). |

Each `ProfileExport`:

| Key | Type | Source table | Notes |
|---|---|---|---|
| `profileId` | string (UUID) | `profile` | Stable identity across devices — see merge (§7). |
| `profile` | object | `profile` | `displayName`, `role`, `locale`, `mushafId`, `createdAt` (UTC), `settingsJson`. |
| `cycleConfig` | object | `cycle_config` | `cycleType`, `newLinesPerDay`, `nearWindowJuz`, `farTargetPerDay`, `farCycleDays`, `dailyBudgetMinutes`, `pureCycleMode`, `termLabelSet`, `regionPreset`. |
| `cards` | array | `card` | Per page: `pageId`, `track`, `d`, `s`, `lastReviewAt` (floating date), `dueAt` (floating date), `reps`, `lapses`, `weakFlag`, `signoffs`, `manualLock`, `prayerCritical`, `enabled`. |
| `lineBlocks` | array | `line_block` | Lazily-created weak-spot blocks: `blockId`, `pageId`, `lineStart`, `lineEnd`, `errorCount`. |
| `reviewLog` | array | `review_log` | **Append-only.** Each row: `logId` (UUID), `pageId`, `reviewedAt` (UTC instant), `trackAtReview`, `grade`, `errorLinesJson`, `elapsedDays`, `rPredicted`, `sBefore`, `sAfter`, `dBefore`, `dAfter`, `source`, `teacherLabel?`. |
| `confusionEdges` | array | `confusion_edge` | `ayahA`, `ayahB`, `weight`, `lastConfusedAt` (UTC). |

Encoding rules:

- **Scheduling days** (`dueAt`, `lastReviewAt`) are floating `"YYYY-MM-DD"`; **true event instants** (`reviewedAt`, `createdAt`, `lastConfusedAt`) are UTC ISO-8601. Restore in a different timezone is tested for record-identity (§8).
- **`logId` and `profileId` are stable UUIDs**, assigned at row creation, carried verbatim. They are the content-address keys that make merge a deduplicating set union (§7) — without device-stable ids, merging two exports would duplicate sign-offs.
- **No derived field is exported** — no juz/ḥizb health %, no Today list, no forecast; the engine recomputes them ([PRD §10.3](../PRD.md)).
- **Notifications are not exported** — they are a rebuildable local cache, re-scheduled from `cycle_config` after import ([14 — Notifications, PRD §14](../PRD.md)).

Forward-compatibility:

- A reader accepts `schemaVersion ≤ current` and migrates older payloads forward through explicit, test-covered, per-version functions on the decoded value types — mirroring the DB migration discipline ([05-persistence-and-encryption.md](05-persistence-and-encryption.md); [Drift: Migrations](https://drift.simonbinder.eu/Migrations/)).
- `schemaVersion > current` ⇒ `newerFormat`, before any database write.
- Within a known `schemaVersion`, unknown keys are ignored on decode (additive-optional fields may ship without a bump but must be noted in the public format changelog); any change to the meaning of an existing field requires a `schemaVersion` bump.
- Missing required fields or invalid enum values ⇒ `malformedPayload`.

### Pitfalls / what we refuse

- **We refuse to embed Quran reference data in the file.** It would balloon the backup, duplicate the checksum-governed asset pack, and risk shipping an *unverified* copy of the sacred text through a side channel — a direct R1 hazard ([PRD R1](../PRD.md)). The backup names the muṣḥaf and its checksum; the device must already hold that verified pack.
- **We refuse to export derived state as if it were truth.** Re-importing a stored heat-map would let stale numbers override the engine's recomputation; only D/S/`due_at` and the log are authoritative.
- **We refuse `DateTime`-instant date fields.** A `dueAt` stored as an instant would shift by a day across a timezone/DST boundary on import — the exact off-by-one *Decision log: Dates, calendars & correctness* forecloses. Scheduling dates are floating strings.
- **We refuse non-deterministic JSON.** Without sorted keys the body bytes — and thus the integrity hash and the golden tests — would vary run to run.

---

## 5. Integrity

### Decision

The container stores a **SHA-256 of the body** (the JSON in plaintext mode, or the whole encryption envelope in encrypted mode). On import the reader recomputes it and refuses the file on any mismatch — fail-closed, before the payload is decoded or applied.

### Rationale

- **SHA-256 is the right integrity primitive and is the one we already pin assets with.** It is NIST-standard (FIPS 180-4), explicitly intended "to detect whether messages have been changed since the digests were generated," with ~128-bit collision resistance and the avalanche property that any single changed byte yields a totally different digest ([NIST FIPS 180-4](https://csrc.nist.gov/pubs/fips/180-4/upd1/final); [research/asset-integrity-and-distribution.md](research/asset-integrity-and-distribution.md) §4). The same algorithm and the same Dart-team [`crypto`](https://pub.dev/packages/crypto) package gate the Quran asset packs ([09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)), so the project carries one hashing dependency, audited once.
- **Integrity is needed *most* in the plaintext mode.** An encrypted backup gets tamper/corruption detection for free from the AEAD tag (§6); a plaintext backup has no such tag, so without an explicit hash a truncated transfer (a half-finished AirDrop, a clipped cloud-drive sync) would import as silently-partial review history. Catching that is non-negotiable for an app whose covenant is "nothing decays silently."

### Specification

```dart
import 'package:crypto/crypto.dart'; // Dart team
import 'dart:convert';

Uint8List _canonicalJsonBytes(Map<String, dynamic> payload) =>
    utf8.encode(jsonEncode(_sortKeysDeep(payload))); // sorted keys → deterministic

List<int> _bodyDigest(Uint8List body) => sha256.convert(body).bytes; // 32 bytes

bool _verifyBody(Uint8List body, List<int> storedDigest) {
  final actual = sha256.convert(body).bytes;
  // constant-time compare is unnecessary (no secret), but a length+content check is required.
  return actual.length == storedDigest.length &&
      List.generate(actual.length, (i) => actual[i] == storedDigest[i])
          .every((ok) => ok);
}
```

The digest covers the body only (bytes `[48 …]`); the header is fixed-format and validated structurally, so a flipped header byte is caught by the magic/version/length checks rather than the hash.

### Pitfalls / what we refuse

- **We refuse to treat the integrity hash as a security control.** A plaintext backup's hash sits inside the same file and an attacker who rewrites the body can rewrite the hash — it is *corruption detection*, not tamper resistance. Confidentiality/authenticity, when wanted, come from turning on encryption (§6), whose AEAD tag *is* authenticated. We state this distinction plainly rather than overselling the checksum.
- **We refuse MD5/SHA-1.** Both are broken for integrity; the SRI lineage accepts only SHA-256/384/512 ([research/asset-integrity-and-distribution.md](research/asset-integrity-and-distribution.md) §4).

---

## 6. Optional encryption envelope (mode `0x02`)

### Decision

When the user enables encryption, the body is an **Argon2id → ChaCha20-Poly1305** envelope: a passphrase is stretched with Argon2id (RFC 9106) to a 32-byte key, which seals the canonical JSON with ChaCha20-Poly1305 (RFC 8439). This is the **same cipher family** as the opt-in database encryption (`sqlite3mc` default ChaCha20-Poly1305 — *Decision log: Persistence & at-rest encryption*), so the project reasons about one AEAD. The KDF id and parameters are stored in the envelope header for forward agility.

### Rationale

- **Argon2id is the modern, memory-hard password KDF — the right choice for an offline file where passphrase strength dominates.** It is standardized in RFC 9106 ("Argon2 Memory-Hard Function for Password Hashing"), and memory-hardness "increases the cost of large-scale password guessing by limiting the degree to which attackers can exploit specialized hardware" ([RFC 9106](https://www.rfc-editor.org/info/rfc9106/)). Unlike the CycleVault exemplar — pinned to CommonCrypto's PBKDF2 because CryptoKit ships no password KDF — Dart's pure-`cryptography` package implements Argon2id cross-platform ([cryptography pub.dev](https://pub.dev/packages/cryptography)), so we take the memory-hard option directly and avoid PBKDF2's GPU weakness.
- **ChaCha20-Poly1305 is a standardized AEAD that authenticates as it encrypts**, fast in software without hardware acceleration ([RFC 8439](https://www.rfc-editor.org/rfc/rfc8439); [ChaCha20-Poly1305 overview](https://en.wikipedia.org/wiki/ChaCha20-Poly1305)). Matching the DB cipher keeps one crypto mental model and one audited library.
- **Storing the KDF id + parameters makes a future upgrade a header change, not a format break** — the same forward-agility lesson the `age` format and the asset-pinning note teach ([research/asset-integrity-and-distribution.md](research/asset-integrity-and-distribution.md) §5).

### Specification

Envelope body (the bytes the §5 SHA-256 covers, for mode `0x02`):

| Offset | Size | Field | Value |
|---|---|---|---|
| 0 | 1 | KDF id | `0x01` = Argon2id (RFC 9106) |
| 1 | 4 | Argon2 memory KiB | UInt32 BE; v1 export = `65536` (64 MiB); restore-clamped to `[19456 … 1048576]` *before* derivation |
| 5 | 4 | Argon2 iterations (t) | UInt32 BE; v1 export = `3`; restore-clamped to `[1 … 16]` |
| 9 | 1 | Argon2 parallelism (p) | v1 export = `1` |
| 10 | 16 | Salt | CSPRNG, fresh per export |
| 26 | 12 | Nonce | CSPRNG, fresh per export (ChaCha20-Poly1305 96-bit nonce) |
| 38 | m | Ciphertext | ChaCha20-Poly1305 over the canonical JSON, AAD = the file's 16-byte binary header (§3) |
| 38+m | 16 | Poly1305 tag | authentication tag |

```dart
import 'package:cryptography/cryptography.dart';

Future<List<int>> _deriveKey(String passphrase, List<int> salt,
    {required int memoryKiB, required int iterations, required int parallelism}) async {
  final argon2 = Argon2id(
    memory: memoryKiB, iterations: iterations, parallelism: parallelism, hashLength: 32);
  final sk = await argon2.deriveKeyFromPassword(
    password: passphrase, nonce: salt); // 'nonce' is Argon2's salt
  return sk.extractBytes();
}

Future<SecretBox> _seal(List<int> jsonBytes, List<int> key, List<int> nonce, List<int> aad) {
  final algo = Chacha20.poly1305Aead();
  return algo.encrypt(jsonBytes,
      secretKey: SecretKey(key), nonce: nonce, aad: aad);
}
```

Restore-side rules:

- **Clamp Argon2 parameters to the documented ranges *before* any derivation**, so a hostile header cannot demand minutes/hours of memory-hard work pre-authentication (the same pre-auth-cost defense the CycleVault exemplar applies to its PBKDF2 iteration count).
- **Passphrase is Unicode-NFC-normalized then UTF-8** before derivation, so a passphrase typed with different composition on the new device still derives the same key.
- **AEAD failure is indistinguishable** — a wrong passphrase and a corrupted ciphertext both surface the single error `wrongPasswordOrDamaged` (§8). The reader never claims to know which.
- **No recovery.** The passphrase is never stored, never in `flutter_secure_storage`, never logged; the export screen states honestly that a forgotten passphrase means the file is unrecoverable.

### Pitfalls / what we refuse

- **We refuse to derive the file key from the device DB key.** The backup passphrase is independent of the `flutter_secure_storage` DB key ([05-persistence-and-encryption.md](05-persistence-and-encryption.md) §5); a portable file must be openable on a *different* device, which the device-bound keystore key is not.
- **We refuse PBKDF2-by-default.** Where the platform offers Argon2id (it does, in pure Dart), the memory-hard KDF is the honest choice for an offline file; we do not inherit the exemplar's PBKDF2 constraint, which existed only because CryptoKit lacked a password KDF.
- **We refuse to run encryption on the UI isolate.** Argon2id at 64 MiB is deliberately slow; export/import crypto runs off the UI isolate so the app never janks ([Flutter: packages](https://docs.flutter.dev/packages-and-plugins/developing-packages)).

---

## 7. Import: replace vs merge

### Decision

Import offers two explicit, separately-confirmed modes. **Replace** is full restore: the chosen scope (all profiles, or one) is wiped and rebuilt from the file. **Merge** is the teacher ↔ student / multi-device path ([PRD §16](../PRD.md)): the file's profiles are unioned into the live store by stable id, with the append-only `review_log` deduplicated as a content-addressed **set union** — never an overwrite, never a duplicate. Both run inside one Drift transaction; a failure rolls back to the exact pre-import state.

### Rationale

- **Merge is a real PRD requirement CycleVault never had.** "Transfer between devices / to a teacher: export → user moves the file by any means → import. This is how 'teacher sees student data' works without a backend" ([PRD §16](../PRD.md)). A teacher who signs off a student on the teacher's device, then sends the export back, must have those sign-offs *added* to the student's history — not replace it, and not duplicate the sign-offs already there.
- **A set union over immutable, UUID-keyed log rows is the only merge that honors the append-only *sanad* trail.** Because `review_log` rows carry a device-stable `logId` and are never mutated ([05-persistence-and-encryption.md](05-persistence-and-encryption.md) §2), "the same review" is exactly "the same `logId`," so union-by-`logId` is idempotent: importing the same file twice changes nothing, and importing a teacher's superset adds only the new sign-offs. This is the §0 framing rule made concrete.
- **One transaction makes import all-or-nothing.** Drift's `db.transaction(() async {…})` is atomic and "rolls back automatically when it throws," with every query `await`-ed inside it ([Drift: Transactions](https://drift.simonbinder.eu/dart_api/transactions/)); a power loss mid-import leaves the live store byte-identical to before.

### Specification

Merge resolution, per entity:

| Entity | Key | Rule |
|---|---|---|
| `profile` | `profileId` (UUID) | New id ⇒ insert. Existing id ⇒ keep local mutable fields unless the import is newer by `createdAt`+settings; never silently rename. Conflicts surfaced to the user, not auto-resolved. |
| `review_log` | `logId` (UUID) | **Set union.** Insert rows whose `logId` is absent; rows already present are skipped (idempotent). Existing rows are **never** updated or deleted. |
| `card` | `(profileId, pageId)` | Last-review-wins by the **maximum `reviewedAt` across the unioned `review_log`**, then the engine recomputes D/S/`dueAt` from the merged log — the card row is a cache of the log, so it is rebuilt, not blindly copied. |
| `line_block` | `(profileId, pageId, lineStart, lineEnd)` | Union; `errorCount` taken as the max (weak-spot evidence only accumulates). |
| `confusion_edge` | `(profileId, ayahA, ayahB)` | Union; `weight` summed-then-capped, `lastConfusedAt` = max. |
| `cycle_config` | `profileId` | Local config wins on merge (the device owner's chosen cycle); replace overwrites it. |

Merge algorithm (shell, over the value-typed snapshot, in one transaction):

```dart
Future<void> mergeImport(BackupSnapshot incoming) =>
  db.transaction(() async {
    // Compatibility gate: same muṣḥaf id + checksum, else refuse (cards index that layout).
    await _assertSameMushaf(incoming.profiles);          // R2 — never mix riwāyāt silently

    for (final p in incoming.profiles) {
      await _upsertProfileMetadata(p);                   // by profileId; conflicts surfaced
      await _unionReviewLog(p.profileId, p.reviewLog);   // dedup by logId — set union
      await _unionLineBlocks(p.profileId, p.lineBlocks);
      await _unionConfusionEdges(p.profileId, p.confusionEdges);
      // Rebuild each touched card from the MERGED log (the log is the truth) …
      await _recomputeCardsFromLog(p.profileId);         // engine; trust-clamp re-applied
    }
    // … then notifications are re-scheduled from cycle_config (shell, post-commit).
  });
```

Replace flow (full restore):

1. Validate the file entirely in memory (§3 parse order) — the live store is untouched through this step. A wrong passphrase, corrupt file, or crash here loses nothing.
2. In one transaction, delete the in-scope user rows and insert the snapshot's rows verbatim (UUIDs preserved). Reference tables are never touched.
3. Recompute `dueAt` for every imported card via the engine's trust clamp — so a restore under a *different* cycle config re-clamps to that device's ceiling ([06-scheduling-engine.md](06-scheduling-engine.md) §7.6), never importing a stale `dueAt` that exceeds the new cycle.
4. Re-schedule notifications from `cycle_config` ([PRD §14](../PRD.md)).

The UI requires explicit, distinct confirmation for each: replace shows "This will replace all data currently in Hifz Companion"; merge shows "This will add the imported reviews to your existing history."

### Pitfalls / what we refuse

- **We refuse to overwrite or delete a `review_log` row on merge.** The trail is append-only and a sign-off is a *sanad* act; merge only ever *adds* rows whose `logId` is new ([PRD §10.3, §16](../PRD.md)).
- **We refuse to copy a card's `dueAt` blindly across cycle configs.** The card is a cache of the log; after merge or restore the engine rebuilds D/S and re-applies the trust clamp under the *receiving* device's cycle, so an imported page can never end up due later than the local cycle ceiling — the §7.6 invariant holds across device transfer ([PRD §7.12](../PRD.md)).
- **We refuse to merge across muṣḥaf editions silently.** Cards index a specific layout (page ids are layout-specific, R2); importing cards built against a different `mushaf_id`/checksum is refused with a clear message, never coerced.
- **We refuse a partial import.** It is one transaction; on any error the live store is byte-identical to before ([Drift: Transactions](https://drift.simonbinder.eu/dart_api/transactions/)).

---

## 8. The SQLite-dump variant & the WAL trap

### Decision

The PRD allows the backup to be "documented, versioned JSON **(or SQLite dump)**" ([PRD §16](../PRD.md)). When a raw SQLite snapshot is produced (for power users, or as a fast whole-store path), it is generated with **`VACUUM INTO`** to a fresh single file — **never** by copying the live `.sqlite`/`-wal`/`-shm` family. The documented, portable, mergeable format above remains the *primary* one; the SQLite dump is a convenience that carries the same `schemaVersion` and is wrapped in the same container.

### Rationale

- **Copying the live database file mid-session loses uncheckpointed commits.** WAL means the live store is a *family* of files — the main file plus `-wal` and `-shm` — and the main file is untouched until checkpoint, so copying only it drops the most recent reviews ([SQLite: WAL](https://sqlite.org/wal.html); [research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §8). Handing the user a half-written WAL set is exactly the silent-loss failure the product forbids.
- **`VACUUM INTO` produces a transactionally consistent single-file snapshot.** SQLite's own docs state: "The VACUUM INTO command is transactional in the sense that the generated output database is a consistent snapshot of the original database" ([SQLite: VACUUM](https://sqlite.org/lang_vacuum.html)). It folds the WAL state into one defragmented file with no siblings, safe to run while the app holds the database open — the correct way to capture "everything, including the latest commit."

### Specification

```dart
// /data — runs on the open connection; produces ONE consistent file, no -wal/-shm siblings.
Future<File> exportSqliteSnapshot(String destPath) async {
  // destPath must NOT pre-exist — VACUUM INTO fails if the target file exists.
  await db.customStatement("VACUUM INTO '$destPath';");
  return File(destPath);
}
```

The resulting file is then wrapped in the §3 container (mode `0x01` body = the snapshot bytes for the dump sub-format, or §6 envelope if encrypted), so a SQLite-dump backup is integrity-hashed and version-stamped identically to a JSON backup. Import of a dump validates the embedded `schemaVersion` via Drift's migration path before opening it as the live store.

### Pitfalls / what we refuse

- **We refuse `cp hifz.sqlite backup.sqlite`** (or any file-copy of the live DB). It drops uncheckpointed WAL commits and can hand the user a corrupt or stale store ([SQLite: WAL](https://sqlite.org/wal.html)).
- **We refuse `VACUUM INTO` onto an existing path.** The command fails if the destination exists; the exporter writes to a fresh temp path, then moves it.
- **We refuse to make the opaque dump the *primary* format.** A raw SQLite file is not the "never trapped," human-readable, *mergeable* artifact the PRD's transfer-to-a-teacher use needs; the documented JSON is primary, the dump is an optional fast-path ([PRD §16](../PRD.md)).

---

## 9. Export & erase flows

### Decision

Export builds the snapshot in `/data`, serializes/encrypts it in `backup/`, writes it atomically to a temp file in the app container, and hands it to the **OS share sheet** — the app performs no network transfer. **Erase** is one action that wipes all local user data; with WAL-family cleanup so no stale sibling can resurrect deleted state.

### Rationale

- **The OS share sheet, not the app, moves the file** ([PRD §16, §17](../PRD.md)). The user chooses local file, their own cloud drive, AirDrop, a messaging app — and the app's network surface stays empty, which the CI no-networking gate proves (*Decision log: No networking beyond asset download*). `share_plus`/`file_picker`-class plugins invoke the platform share sheet and file pickers without any app-owned transport.
- **Atomic write means the file is never observed half-written**, and no plaintext is left behind: encrypted exports never write plaintext to disk, and temp files are swept on completion and on next launch as a backstop.
- **Erase is right-to-be-forgotten by construction** ([PRD §16, §17](../PRD.md)). Because there is no account and nothing left the device, deleting the local store and its WAL siblings (and, if encryption was on, the `flutter_secure_storage` key) is a complete, verifiable erasure.

### Specification

```dart
// Shell — orchestrates /data (read) → backup/ (serialize) → OS share. No networking.
Future<void> exportBackup({String? passphrase, BackupScope scope = BackupScope.all}) async {
  final snapshot = await dataLayer.readSnapshot(scope);          // /data, DAOs → value types
  final bytes = HifzBackup.export(snapshot, passphrase: passphrase); // backup/, off-UI isolate
  final dir = await getTemporaryDirectory();
  final file = File(p.join(dir.path, _defaultName()))            // e.g. Hifz-2026-06-16.hifzbackup
    ..writeAsBytesSync(bytes, flush: true);                      // atomic-ish; flushed
  await Share.shareXFiles([XFile(file.path)]);                   // OS share sheet — app sends nothing
  // temp file swept after share completes; export dir swept on next launch.
}
```

Erase:

```dart
Future<void> eraseAllLocalData() async {
  await db.close();                          // release the WAL family
  for (final f in ['hifz.sqlite', 'hifz.sqlite-wal', 'hifz.sqlite-shm']) {
    final file = File(p.join(docsDir, f));
    if (file.existsSync()) file.deleteSync(); // delete siblings too — no resurrection
  }
  await secureStorage.delete(key: 'db_key'); // if opt-in encryption was on (§6, doc 05)
}
```

The erase UI requires explicit confirmation and states plainly that it is irreversible and that any existing backup file is the only remaining copy.

### Pitfalls / what we refuse

- **We refuse any in-app network transfer of the backup.** Sharing is the OS's job; the app never uploads ([PRD §16, §17](../PRD.md)).
- **We refuse to leave plaintext on disk for an encrypted export.** Serialization-then-seal happens in memory; only ciphertext is written.
- **We refuse to delete only the main `.sqlite` on erase.** The `-wal`/`-shm` siblings are deleted too, so no uncheckpointed state survives a "wipe" ([SQLite: WAL](https://sqlite.org/wal.html)).

---

## 10. Test plan

All `backup/` tests are pure-Dart `package:test`, simulator-free, run under at least two `TZ` values in CI ([11-testing-strategy.md](11-testing-strategy.md)); the package carries a high line-coverage gate. Property tests use a seeded generator (seed logged on failure).

| Test | Kind | Asserts |
|---|---|---|
| Round-trip identity | Property | `import(export(s)) == s` for arbitrary histories (multi-profile, teacher sign-offs, line blocks, confusion edges) |
| Encrypted round-trip | Property | `import(export(s, p), p) == s` for passphrases with emoji, CJK, combining marks, spaces |
| Golden files | Fixture | Committed v1 plaintext + encrypted files decode to byte-exact known snapshots; header offsets asserted against §3 |
| Integrity rejection | Property | One flipped byte anywhere in the body ⇒ `integrityFailed` (plaintext) |
| Truncation | Negative | Every truncation boundary (header-internal, mid-body, tag-trimmed) ⇒ rejected with the right error |
| Wrong passphrase | Negative | Encrypted file, wrong passphrase ⇒ `wrongPasswordOrDamaged`, distinct from structural errors |
| Argon2 param clamp | Negative | memory/iterations out of range ⇒ rejected; a KDF spy asserts **zero** derivation calls |
| Newer format / schema | Negative | format byte `0x02` ⇒ `newerFormat`; valid crypto, `schemaVersion: current+1` ⇒ `newerFormat`, **DB untouched** |
| Timezone-shift invariance | Property | Export under one `TZ`, import under another ⇒ identical records (floating `"YYYY-MM-DD"`) |
| Merge idempotence | Property | `merge(merge(empty, f), f) == merge(empty, f)` — re-importing the same file changes nothing (union by `logId`) |
| Merge superset | Unit | Student log ∪ teacher's superset = teacher's superset; no duplicated sign-offs; no log row deleted/mutated |
| Trust-clamp after import | Unit | Imported cards' `dueAt` ≤ the **receiving** device's cycle ceiling after recompute (§7.6 invariant survives transfer) |
| Cross-muṣḥaf refusal | Negative | Importing cards built against a different `mushaf_id`/checksum ⇒ refused, not coerced |
| `VACUUM INTO` snapshot | Unit | Snapshot is a single file with no `-wal`/`-shm` siblings and contains the latest uncheckpointed commit |
| Schema migration | Unit | Each historical `schemaVersion` fixture migrates forward to current with expected records |
| Crash mid-import | Unit | Simulated failure inside the import transaction leaves the live store byte-identical (Drift auto-rollback) |
| Erase completeness | Unit | After erase, no `.sqlite`/`-wal`/`-shm` survives and the DB key is gone |

---

## References

- Hifz Companion. *Documentation blueprint (authoring contract).* [_DOC-SET-BLUEPRINT.md](../_DOC-SET-BLUEPRINT.md)
- Hifz Companion. *Product Requirements Document* (§10 data model, §14 notifications, §16 backup & portability, §17 privacy, §7.6/§7.12 trust clamp & invariants, R1/R2). [PRD.md](../PRD.md)
- Hifz Companion engineering. *README & tech-decision log* (decisions 3, 7, 8). [README.md](README.md)
- Hifz Companion engineering. *Persistence & Encryption* (Drift schema, WAL, transactions, `schemaVersion`, opt-in `sqlite3mc`, key storage). [05-persistence-and-encryption.md](05-persistence-and-encryption.md)
- Hifz Companion engineering. *Scheduling Engine* (trust clamp, recompute from log). [06-scheduling-engine.md](06-scheduling-engine.md)
- Hifz Companion engineering. *Dates, Calendars & Correctness* (`CalendarDate`, floating-date encoding). [07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md)
- Hifz Companion engineering. *Asset Packs & Offline Integrity* (SHA-256 pinning, muṣḥaf checksum). [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)
- Hifz Companion engineering research. *Local Persistence in Flutter with Drift over SQLite* (§8 WAL-aware backup, §10 encryption optional). [research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md)
- Hifz Companion engineering research. *Asset Integrity & Distribution* (§4 SHA-256, §5 version pinning). [research/asset-integrity-and-distribution.md](research/asset-integrity-and-distribution.md)
- SQLite. *VACUUM* ("the generated output database is a consistent snapshot of the original database"). https://sqlite.org/lang_vacuum.html
- SQLite. *Write-Ahead Logging* (`-wal`/`-shm` family; main file untouched until checkpoint; copy-the-file backup hazard). https://sqlite.org/wal.html
- Simon Binder. *Drift — Migrations* (integer `schemaVersion`; guided, per-version, transactional migrations; schema snapshots). https://drift.simonbinder.eu/Migrations/
- Simon Binder. *Drift — Transactions* (atomic, automatic rollback on throw, every query must be awaited). https://drift.simonbinder.eu/dart_api/transactions/
- Dart team. *DateTime class — dart:core* (instant, not date; no internationalization; DST/Duration warning). https://api.dart.dev/dart-core/DateTime-class.html
- Dart team. *dart:convert library* (`jsonEncode`, `utf8`, `JsonUtf8Encoder`). https://api.dart.dev/dart-core/dart-convert/
- Dart team. *crypto* (SHA-256; the project's single hashing dependency). https://pub.dev/packages/crypto
- dint.dev (verified publisher). *cryptography* (pure-Dart Argon2id and ChaCha20-Poly1305-AEAD; cross-platform). https://pub.dev/packages/cryptography
- National Institute of Standards and Technology. *FIPS 180-4: Secure Hash Standard* (SHA-256; detect message changes; avalanche). https://csrc.nist.gov/pubs/fips/180-4/upd1/final
- Biryukov, A., Dinu, D., Khovratovich, D., Josefsson, S. *RFC 9106: Argon2 Memory-Hard Function for Password Hashing and Proof-of-Work Applications.* https://www.rfc-editor.org/info/rfc9106/
- Nir, Y., Langley, A. *RFC 8439: ChaCha20 and Poly1305 for IETF Protocols.* https://www.rfc-editor.org/rfc/rfc8439
- Wikipedia. *ChaCha20-Poly1305* (AEAD; faster than AES-GCM without hardware acceleration). https://en.wikipedia.org/wiki/ChaCha20-Poly1305
- Flutter (Google). *Developing packages & plugins* (pure Dart package = easiest layer to test). https://docs.flutter.dev/packages-and-plugins/developing-packages

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
