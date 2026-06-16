---
name: domain-backup-format
description: Build or change the Hifz app's local, offline `.hifzbackup` file — the versioned, integrity-checked, no-cloud/no-account export the user saves anywhere, and its replace-vs-merge restore semantics. Use whenever you touch the backup file layout, the magic/format/`schemaVersion` header, the SHA-256 integrity check, the optional Argon2id→ChaCha20-Poly1305 encryption envelope, the export/erase flow, or the teacher↔student merge (set-union over the append-only `review_log`).
---

# Hifz backup & restore format

The `.hifzbackup` file is the product's "never trapped" promise in bytes: a documented, versioned, self-describing, integrity-checked artifact that makes a ḥāfiẓ's years of review history portable and recoverable — with **no cloud, no account, no server** ([PRD §16](../../../docs/PRD.md)). The app never transmits it; the OS share sheet moves it. This skill is the checklist that keeps the file auditable, the restore all-or-nothing, the merge a deduplicating set-union that honors the append-only *sanad* trail, and the "lose phone + file = data gone" tradeoff stated honestly rather than hidden.

The full spec is `docs/engineering/10-backup-format.md`. Reference each rule by its doc section — never re-derive a header offset, a cipher choice, or a merge rule here.

## When to use

Use this skill when you:

- change the `.hifzbackup` container layout — the magic `HIFZBK\x1F`, the format-version byte, the mode byte, the body length, or the body SHA-256 (`docs/engineering/10-backup-format.md` §3);
- touch the versioned JSON payload schema, add a field, or bump the payload `schemaVersion` / write a forward-migration for it (§4);
- change the integrity mechanism, the optional encryption envelope (Argon2id KDF params, ChaCha20-Poly1305, salt/nonce), or the restore-side parameter clamp (§5, §6);
- edit the **replace** (full restore) or **merge** (teacher ↔ student transfer) import semantics, or the per-entity merge resolution rules (§7);
- touch the `VACUUM INTO` SQLite-dump variant, the export-to-share-sheet flow, or the one-tap **erase** (§8, §9);
- add or change a golden file, a round-trip property test, an integrity-rejection, or a timezone-invariance test for the `backup/` package (§10);
- review a PR that touches anything in the pure-Dart `backup/` package or the shell code that drives export/import.

Do **NOT** use this skill for:
- the live Drift/SQLite store, WAL crash-safety, the one-transaction write, or the *opt-in DB* `sqlite3mc` encryption / `flutter_secure_storage` key → use **eng-persistence-and-drift** (the `backup/` package imports value types only — never Drift, never `sqlite3`);
- what a stored `dueAt` / `lastReviewAt` *means*, the `CalendarDate`/`SerialDay` serial-day type, or Hijri/Jalālī/Gregorian conversion → use **eng-datemath-and-serialday** (this file only *encodes* dates as floating `"YYYY-MM-DD"` strings);
- the engine recompute that rebuilds D/S/`dueAt` from the merged `review_log` and re-applies the trust clamp after import → use **domain-scheduling-engine-rules**;
- the read-only Quran reference tables, fonts, layout, and their checksum governance — those are **never** in a backup → use **domain-mushaf-text-integrity** and **domain-asset-pack-integrity**;
- how the export / import / erase screens *look* (the calm copy, the "this file is readable by anyone" honesty line, RTL) → use **ui-backup-and-restore** / **ux-privacy-trust-surface**;
- registering a user-facing number on the science screen → use **domain-claims-register-and-science-screen**.

The `backup/` package owns *file bytes* — serialization, integrity, optional crypto, structural validation, and the merge algorithm over value types. If your change reads the database, opens a socket, or renders a widget, it does not belong in `backup/`.

## The canonical pattern

### Shape and boundary

1. **`backup/` is a pure-Dart package over value types and bytes — never Drift, `sqlite3`, or networking.** Its public API is `HifzBackup.export(BackupSnapshot, {passphrase})` → `Uint8List` and `HifzBackup.import(Uint8List, {passphrase})` → `BackupSnapshot`. The shell reads rows through `/data` DAOs, maps them to a `BackupSnapshot`, and hands it in; on import the shell writes the validated snapshot back through `/data` in one transaction. The package is store-blind, so a per-profile export structurally cannot leak another profile's rows. `docs/engineering/10-backup-format.md` §1; the same CI banned-import gate that walls Drift into `/data` walls it out of `backup/` (`docs/engineering/05-persistence-and-encryption.md` §1).

2. **Export/import perform ZERO network I/O.** The OS share sheet moves the file; the app transmits nothing. `dart:io` is confined to the shell's file-move step; the package opens no socket. `docs/engineering/10-backup-format.md` §1, §9; this inherits *Decision log: No networking beyond asset download* and is proven by the dependency allow-list + banned-import lint (**eng-offline-ci-gates**).

### Default form & honesty

3. **Default is plaintext, human-readable, versioned UTF-8 JSON; encryption is opt-in — a deliberate divergence from the CycleVault exemplar.** The PRD makes *portability*, not secrecy, the goal of the file ("documented, versioned … so data is never trapped," **encrypted-optional**); the data is religious-practice telemetry, not PII/medical history, and the headline transfer-to-a-teacher use *wants* readability. `docs/engineering/10-backup-format.md` §2; `docs/PRD.md` §16, §17. **We refuse to imply a plaintext backup is private** — the export screen states plainly, in the user's locale, that an unencrypted backup is readable by anyone who opens it, and offers the one-tap encryption toggle (§2).

### Container, integrity, versioning

4. **One self-describing, self-validating binary header; two version axes checked separately.** Big-endian: magic `HIFZBK` (`48 49 46 5A 42 4B`) + `0x1F` separator + 1-byte **format version** (`0x01`) + 1-byte **mode** (`0x01` plaintext JSON · `0x02` encrypted envelope) + UInt32 body length + 2 reserved zero bytes + 32-byte body SHA-256 + body. Minimum valid file is 49 bytes. The **`schemaVersion`** is *not* in the cleartext header — it is the first key of the JSON payload, so an encrypted file's header leaks nothing about contents. `docs/engineering/10-backup-format.md` §3.

5. **Follow the normative restore-side parse order, with a distinct typed `BackupError` at each stage.** length ≥ 49 → magic → format version (`> 0x01` ⇒ `newerFormat`) → mode ∈ {`0x01`,`0x02`} → body length matches file → **verify body SHA-256** (`integrityFailed`) → (mode `0x02`) decrypt (`wrongPasswordOrDamaged`) → JSON decode + read `schemaVersion` (`> current` ⇒ `newerFormat`; else migrate forward; decode/validation failure ⇒ `malformedPayload`). Cheap structural checks reject hostile/wrong input *before* any heavy hashing or decryption. `docs/engineering/10-backup-format.md` §3; never a generic catch-all error (§1, `BackupError` enum).

6. **Integrity is a SHA-256 of the body, present in BOTH modes, fail-closed before any write.** SHA-256 is the same NIST-standard primitive (FIPS 180-4) the Quran asset packs are pinned with, so the project carries one hashing dependency (Dart-team `crypto`). It is needed *most* in plaintext mode: without it a truncated transfer (a half-finished AirDrop, a clipped cloud sync) would import as silently-partial history — exactly the "silent loss" the product exists to prevent. **State plainly that the hash is corruption detection, not tamper resistance** — confidentiality/authenticity come only from turning on encryption (whose AEAD tag *is* authenticated). `docs/engineering/10-backup-format.md` §5; **we refuse MD5/SHA-1.**

### Payload — truth only, never derived state, never the Quran

7. **The JSON is a complete value-typed export of the per-profile user model and NOTHING else.** It carries `profile`, `cycleConfig`, `cards` (D/S/`dueAt`/flags), `lineBlocks`, the append-only `reviewLog`, and `confusionEdges` — keyed by stable UUIDs (`profileId`, `logId`) assigned at row creation and carried verbatim. **No derived state** is exported — no juz/ḥizb health %, no Today list, no forecast, no notification cache; the engine recomputes them on first build. `docs/engineering/10-backup-format.md` §4; `docs/PRD.md` §10.2, §10.3. **We refuse to export derived state as if it were truth** — only D/S/`dueAt` and the log are authoritative.

8. **The Quran is NEVER in the file.** A backup records the `mushaf` `{id, riwayah, name, checksumSha256}` for import-time compatibility (R2) but never embeds glyphs, text, fonts, layout, or the mutashābihāt dataset — those are the verified, checksum-governed asset pack, re-derivable on any device. Embedding them would balloon the file *and* risk shipping an unverified copy of the sacred text through a side channel — a direct R1 hazard. `docs/engineering/10-backup-format.md` §4; `docs/PRD.md` R1, R2; **domain-mushaf-text-integrity**.

9. **Scheduling days are floating `"YYYY-MM-DD"` strings; true event instants are UTC ISO-8601; JSON is canonical (sorted keys).** `dueAt`/`lastReviewAt` are floating dates so a cross-timezone restore is byte-identical (a `DateTime` instant would shift a day across a DST/timezone boundary — the off-by-one **eng-datemath-and-serialday** forecloses); `reviewedAt`/`createdAt`/`lastConfusedAt` are UTC instants. Sorted-key encoding makes the body bytes — and thus the integrity hash and the golden tests — deterministic. `docs/engineering/10-backup-format.md` §4. **We refuse `DateTime`-instant date fields and non-deterministic JSON.**

10. **Forward-compatibility mirrors the DB migration discipline.** A reader accepts `schemaVersion ≤ current` and migrates older payloads forward through explicit, test-covered, per-version functions on the decoded value types (the same `schemaVersion` integer Drift stamps); `schemaVersion > current` ⇒ `newerFormat` *before any DB write*; unknown keys are ignored on decode (additive-optional, noted in the public changelog); any change to an existing field's meaning requires a `schemaVersion` bump; missing required fields ⇒ `malformedPayload`. `docs/engineering/10-backup-format.md` §3, §4; `docs/engineering/05-persistence-and-encryption.md` §4.

### Optional encryption (mode `0x02`)

11. **Encryption is an Argon2id → ChaCha20-Poly1305 envelope — the same AEAD family as the opt-in DB cipher.** A passphrase is Unicode-NFC-normalized then UTF-8, stretched with Argon2id (RFC 9106, memory-hard) to a 32-byte key, which seals the canonical JSON with ChaCha20-Poly1305 (RFC 8439), AAD = the file's 16-byte binary header. The KDF id + params (memory/iterations/parallelism), salt, and nonce are stored in the envelope for forward agility. **Clamp Argon2 params to the documented ranges BEFORE any derivation**, so a hostile header cannot demand minutes of pre-auth work. Run the crypto **off the UI isolate** — Argon2id at 64 MiB is deliberately slow. `docs/engineering/10-backup-format.md` §6.

12. **The backup passphrase is independent of the device DB key, and there is no recovery.** A portable file must open on a *different* device, which the device-bound `flutter_secure_storage` key is not — so we **refuse to derive the file key from the DB key**. The passphrase is never stored, never in secure storage, never logged; the export screen states honestly that a forgotten passphrase means the file is unrecoverable. AEAD failure is **indistinguishable** — a wrong passphrase and a corrupted ciphertext both surface the single `wrongPasswordOrDamaged`; the reader never claims to know which. `docs/engineering/10-backup-format.md` §6; `docs/engineering/05-persistence-and-encryption.md` §5.

### Import — replace vs merge

13. **Replace and merge are two explicit, separately-confirmed modes, each in ONE Drift transaction.** **Replace** validates the file entirely in memory first (a wrong passphrase / corrupt file loses nothing), then in one transaction wipes the in-scope user rows and inserts the snapshot verbatim (UUIDs preserved), then recomputes every imported card's `dueAt` via the engine trust clamp so a restore under a *different* cycle re-clamps to that device's ceiling. **Merge** unions the file's profiles into the live store by stable id. A failure rolls back to the exact pre-import state. `docs/engineering/10-backup-format.md` §7; `docs/engineering/05-persistence-and-encryption.md` §3 (Drift transactions); `docs/scheduling-engine.md` trust clamp via **domain-scheduling-engine-rules**.

14. **Merge is a content-addressed SET UNION over the append-only `review_log` — never an overwrite, never a duplicate.** The `review_log` is an append-only *sanad* audit trail; "the same review" is exactly "the same `logId`," so union-by-`logId` is idempotent (re-importing the same file changes nothing; importing a teacher's superset adds only the new sign-offs). A `card` is a *cache of the log*, so after merge the engine rebuilds D/S/`dueAt` from the merged log and re-applies the trust clamp — never blindly copied. **We refuse to overwrite or delete a `review_log` row on merge**, and **we refuse to merge across muṣḥaf editions silently** (cards index a layout-specific `mushaf_id`/checksum, R2 — a cross-muṣḥaf import is refused with a clear message, never coerced). `docs/engineering/10-backup-format.md` §7; `docs/engineering/05-persistence-and-encryption.md` §2; `docs/PRD.md` §10.3, §16.

### SQLite-dump variant, export & erase

15. **A raw SQLite snapshot uses `VACUUM INTO` to a fresh file — never a copy of the live `-wal`/`-shm` family.** WAL means the live store is a *family* of files and the main file is untouched until checkpoint, so copying only it drops the latest reviews — the silent-loss failure the product forbids. `VACUUM INTO` folds the WAL state into one transactionally-consistent file. The documented JSON stays *primary* (it is the "never trapped," mergeable artifact); the dump is an optional fast-path, wrapped in the same §3 container, carrying the same `schemaVersion`. `docs/engineering/10-backup-format.md` §8; `docs/engineering/05-persistence-and-encryption.md` §3. **We refuse `cp hifz.sqlite …` and `VACUUM INTO` onto an existing path.**

16. **Export writes atomically to a temp file then hands it to the OS share sheet; erase is right-to-be-forgotten by construction.** No plaintext is left on disk for an encrypted export (serialize-then-seal in memory; temp files swept on completion and on next launch). Erase is one confirmed, irreversible action that closes the DB and deletes the `.sqlite` **and its `-wal`/`-shm` siblings** (and, if opt-in encryption was on, the secure-storage key) — no stale sibling can resurrect deleted state. The erase UI states plainly that any existing backup file is then the only remaining copy. `docs/engineering/10-backup-format.md` §9; `docs/PRD.md` §16, §17. **We refuse any in-app network transfer, and refuse to delete only the main `.sqlite` on erase.**

## Do / Don't

| Do | Don't |
|---|---|
| Keep `backup/` pure Dart over value types + bytes; export/import via `BackupSnapshot` | Import `drift`/`sqlite3`/any networking package in `backup/`, or let it read the DB |
| Move the file with the OS share sheet only | Open a socket or transmit the backup from inside the app |
| Default to plaintext versioned JSON; make encryption an opt-in toggle | Mandate encryption (CycleVault's medical-grade default) or imply plaintext is private |
| Stamp magic `HIFZBK\x1F` + format byte + mode byte + body length + body SHA-256 | Put `schemaVersion` in the cleartext header of an encrypted file |
| Parse in the normative order; emit a distinct typed `BackupError` per stage | Use a generic catch-all error, or hash/decrypt before the cheap structural checks pass |
| Verify the body SHA-256 in **both** modes, fail-closed before any write | Skip integrity on plaintext backups, or use MD5/SHA-1 |
| Export only truth: D/S/`dueAt`, the append-only log, configs — and recompute the rest | Export derived health %/forecasts/Today list, or re-import them as authority |
| Reference the muṣḥaf by `{id, checksumSha256}` only | Embed Quran glyphs/text/fonts/layout or the mutashābihāt dataset in the file |
| Encode scheduling days as floating `"YYYY-MM-DD"`, instants as UTC; sort keys | Store `dueAt` as a `DateTime` instant, or emit non-deterministic JSON |
| Argon2id (memory-hard) → ChaCha20-Poly1305; clamp params *before* derivation | Derive the file key from the device DB key, or claim a forgotten passphrase is recoverable |
| Surface AEAD failure as the single `wrongPasswordOrDamaged` | Claim to distinguish a wrong passphrase from corrupted ciphertext |
| Merge as set-union by `logId`; rebuild the card from the merged log | Overwrite/delete a `review_log` row on merge, or duplicate a teacher sign-off |
| Refuse a cross-`mushaf_id`/checksum merge with a clear message | Silently coerce cards built against a different muṣḥaf edition |
| Run replace/merge in one Drift transaction; re-clamp `dueAt` to this device's ceiling | Allow a partial import, or copy an imported `dueAt` past the local cycle ceiling |
| `VACUUM INTO` a fresh file for the dump variant; keep JSON primary | `cp` the live `.sqlite`, or make the opaque dump the primary format |
| Erase: delete `.sqlite` + `-wal` + `-shm` (+ key); confirm, state it's irreversible | Delete only the main `.sqlite`, or promise physical secure-erase of flash |

## Checklist

Before a backup-format change is done:

- [ ] `backup/` still imports no `drift`, no `sqlite3`, and no networking package; export/import flow through a `BackupSnapshot` value object and the package never queries the DB (§1; banned-import grep gate via **eng-offline-ci-gates**).
- [ ] The export/import path opens no socket; only the shell's share-sheet step touches `dart:io`/the file system (§1, §9).
- [ ] Default backup is plaintext versioned UTF-8 JSON; encryption is an opt-in toggle, and the export screen says plainly (in fa/ckb/ar) that an unencrypted file is readable by anyone (§2; `docs/PRD.md` §17).
- [ ] The container header is exactly magic `HIFZBK` + `0x1F` + format `0x01` + mode byte + UInt32 body length + 2 reserved zeros + 32-byte body SHA-256; min file 49 bytes; `schemaVersion` is in the JSON payload, never the cleartext header (§3).
- [ ] Restore parses in the normative order and returns the right distinct `BackupError` at each stage (`notAHifzBackup` / `newerFormat` / `unknownMode` / `integrityFailed` / `wrongPasswordOrDamaged` / `malformedPayload`) — no generic catch-all (§1, §3).
- [ ] Body SHA-256 is verified in **both** modes, fail-closed before any decode/write; no MD5/SHA-1; the UI distinguishes corruption from a wrong key (§5).
- [ ] The payload carries only truth — `profile`, `cycleConfig`, `cards`, `lineBlocks`, append-only `reviewLog`, `confusionEdges` keyed by stable UUIDs — and **no** derived state (no health %, forecast, Today list, or notification cache) (§4; `docs/PRD.md` §10.3).
- [ ] No Quran glyphs/text/fonts/layout or mutashābihāt data is in the file; only `mushaf {id, riwayah, name, checksumSha256}` is recorded (§4; `docs/PRD.md` R1, R2; **domain-mushaf-text-integrity**).
- [ ] Scheduling days are floating `"YYYY-MM-DD"`, true instants are UTC ISO-8601, JSON keys are sorted (deterministic body → stable hash + golden tests) — verified by the timezone-shift invariance property (§4; **eng-datemath-and-serialday**).
- [ ] Forward-compat: `schemaVersion ≤ current` migrates forward via per-version functions; `> current` ⇒ `newerFormat` before any DB write; unknown keys ignored; a field-meaning change bumps `schemaVersion` (§3, §4).
- [ ] Encryption (mode `0x02`) is Argon2id → ChaCha20-Poly1305 with NFC-normalized passphrase, fresh CSPRNG salt+nonce, AAD = the binary header, params clamped to range *before* derivation, run off the UI isolate (§6) — a KDF spy asserts **zero** derivation calls on an out-of-range header.
- [ ] The file key is independent of the device DB key; the passphrase is never stored/logged; AEAD failure surfaces only `wrongPasswordOrDamaged` (§6; `docs/engineering/05-persistence-and-encryption.md` §5).
- [ ] Replace and merge are separately confirmed, each in one Drift transaction; a mid-import failure leaves the live store byte-identical (Drift auto-rollback) — verified by the crash-mid-import test (§7).
- [ ] Merge is set-union by `logId` (idempotent; no row deleted/mutated; no sign-off duplicated); each touched card is rebuilt from the merged log; the merge-superset and merge-idempotence properties hold (§7; `docs/PRD.md` §10.3).
- [ ] A cross-`mushaf_id`/checksum import is refused with a clear message, never coerced (§7; `docs/PRD.md` R2).
- [ ] After restore/merge, every imported card's `dueAt ≤` the **receiving** device's cycle ceiling (engine recompute + trust clamp re-applied) — the §7.6 invariant survives transfer (§7; **domain-scheduling-engine-rules**).
- [ ] Any SQLite dump uses `VACUUM INTO` to a fresh path (no `-wal`/`-shm` siblings; includes the latest uncheckpointed commit); the documented JSON stays primary (§8).
- [ ] Export writes atomically to temp then shares via the OS sheet (no plaintext left for an encrypted export); erase deletes `.sqlite` + `-wal` + `-shm` (+ secure-storage key if encryption was on) and is confirmed + irreversible (§9; `docs/PRD.md` §16, §17).
- [ ] Tests added/updated: round-trip identity, encrypted round-trip (emoji/CJK/combining-mark passphrases), committed golden files with header-offset asserts, integrity-rejection (one flipped byte), truncation, wrong-passphrase, Argon2 param-clamp, newer-format/schema-untouched-DB, timezone invariance, merge idempotence + superset, trust-clamp-after-import, cross-muṣḥaf refusal — under at least two `TZ` values in CI (§10; harness via **eng-write-dart-test**).
- [ ] RTL/i18n: every export/import/erase string is fa/ckb/ar-localized, calm, no exclamation marks; numerals localized; the file format itself is locale-independent (no locale leaks into encoded dates/ids) (**ui-backup-and-restore** / **ux-privacy-trust-surface**).
- [ ] No-AI / offline / adab preserved: the whole flow works with the radio off; no streak/score/badge/shame surface; no number the change introduces is user-facing-and-unsourced (if it is, register it via **domain-claims-register-and-science-screen** — never invent a citation).

The covenant of this file is honesty: the backup is a *plain documented artifact the user controls*, not a cloud safety net. If a change makes the file feel like a managed backup the app guarantees, or hides the "lose phone + file = data gone" tradeoff, it is wrong no matter how convenient it is. Integrity is mandatory; confidentiality is the user's choice; transmission is never the app's.

## Files

- `template.dart` — copy-paste scaffold for the pure-Dart `backup/` package: `BackupSnapshot`/`BackupMode`/`BackupError` value types, the `HifzBackup.export`/`import` façade, the §3 container read/write, the §5 SHA-256 check, the §6 Argon2id→ChaCha20-Poly1305 envelope with restore-side param clamp, and the shell-side §7 merge transaction (set-union by `logId`) + export/erase, with `// TODO` markers and every header offset / cipher / rule referenced by name.
- `references.md` — the exact governing doc sections, each with the one thing to take from it, and the sibling skills.

Related skills: **eng-persistence-and-drift** (the live Drift store the snapshot is read from / written back to, the one-transaction write, the opt-in DB cipher + `flutter_secure_storage` key the backup passphrase is deliberately independent of), **domain-scheduling-engine-rules** (the engine recompute + trust clamp re-applied to every imported card), **eng-datemath-and-serialday** (the `SerialDay`/`CalendarDate` whose floating `"YYYY-MM-DD"` text form makes a cross-timezone restore byte-identical), **domain-mushaf-text-integrity** / **domain-asset-pack-integrity** (the checksum-governed Quran/asset pack the backup references but never embeds), **eng-offline-ci-gates** (the banned-import + no-network gates and the byte-flip/truncation golden tests), **eng-write-dart-test** (the round-trip + property-test harness), **ui-backup-and-restore** / **ux-privacy-trust-surface** (the calm RTL export/import/erase UI and the "readable by anyone" honesty line), **domain-claims-register-and-science-screen** (register any user-facing number before it ships).
