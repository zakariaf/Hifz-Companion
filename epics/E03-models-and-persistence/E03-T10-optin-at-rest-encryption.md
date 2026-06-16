# E03-T10 — Opt-in at-rest encryption: sqlite3mc toggle, flutter_secure_storage raw key, PRAGMA cipher liveness guard, wrong-key-vs-corruption mapping

| | |
|---|---|
| **Epic** | [E03 — Models & Persistence](EPIC.md) |
| **Size** | M (≈1–2 days) |
| **Depends on** | E03-T04 |
| **Skills** | eng-add-drift-table-or-migration, eng-define-service-boundary, eng-write-dart-test |

## Goal

The store gains an **opt-in, off-by-default** at-rest encryption path that ships with **zero cost when off**: the encryption build flavor sets `hooks: user_defines: sqlite3: source: sqlite3mc` (SQLite3MultipleCiphers, ChaCha20-Poly1305 default), a random 32-byte raw key is generated once and stored in `flutter_secure_storage` (`first_unlock_this_device`, non-syncing), and the connection `setup` callback from E03-T04 feeds `PRAGMA key` ahead of the WAL/`synchronous`/`foreign_keys` pragmas. A **hard `PRAGMA cipher;` liveness guard** refuses to open a store that only *looks* encrypted (the toggle silently fell back to stock SQLite), and a `SQLITE_NOTADB` at open is mapped to a **key-recovery flow, never a "your data is corrupted" message**. Rotation is **export-to-freshly-keyed** (never an in-place WAL re-key); there is **no decoy/duress isolation**. When the flavor is off, none of this code is on the open path and the store opens exactly as in E03-T04.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/05-persistence-and-encryption.md` §5 (Decision) | At-rest encryption is **optional/opt-in, off by default**, one declarative build-hook toggle (`hooks: user_defines: sqlite3: source: sqlite3mc`, ChaCha20-Poly1305) plus a `PRAGMA key` in `setup`; the mandatory floor stays WAL + transactions (§3); **no** deprecated `sqlcipher_flutter_libs`/`sqlite3_flutter_libs`; **no** CycleVault-style decoy/duress isolation |
| `docs/engineering/05-persistence-and-encryption.md` §5 (Rationale) | The honestly-narrower threat model — religious-practice telemetry, no PII/account, nothing leaves the device; realistic threat is device theft / shared-device curiosity (a teacher/halaqa device holding several students' progress, PRD §15.3), not network exfiltration; the 2026 build-hook model replaces the EOL SQLCipher packages; ChaCha20-Poly1305 is the right greenfield default; a **raw 32-byte key beats a passphrase** (full-entropy keystore material, skips PBKDF2, no per-open key-derivation delay) |
| `docs/engineering/05-persistence-and-encryption.md` §5 (Specification) | The verbatim shapes: the `pubspec.yaml` `hooks` block (encryption flavor only); `_dbKeyHex()` — read-or-generate-once 32 random bytes → hex, `FlutterSecureStorage(IOSOptions(accessibility: first_unlock_this_device), AndroidOptions(encryptedSharedPreferences: true))`; the `setup` callback that runs `PRAGMA key = "x'$keyHex'";` then the **hard guard** `if (raw.select('PRAGMA cipher;').isEmpty) throw StateError(...)` **before** the WAL/`synchronous`/`foreign_keys` pragmas; the two-row open-failure table (`PRAGMA cipher;` empty ⇒ refuse, build defect; `SQLITE_NOTADB` ⇒ wrong/missing key ⇒ key-recovery, never "corrupted"); **key rotation never in place on WAL** — export to a freshly-keyed DB via the checkpointed snapshot pipeline, never `PRAGMA rekey` |
| `docs/engineering/05-persistence-and-encryption.md` §5 (Pitfalls) | Refuse a silently-plaintext build (the `PRAGMA cipher;` guard is promoted from Drift's debug example to a release guard); refuse the deprecated SQLCipher packages (silent dual-link conflict); refuse in-place WAL re-keying; refuse to misreport a wrong key as corruption; refuse decoy/duress isolation; refuse to *claim* physical secure-erase — destroying the key is the honest cryptographic-unrecoverability guarantee; **pin** the bundled SQLite + sqlite3mc versions |
| `docs/engineering/05-persistence-and-encryption.md` §1 (Specification / Pitfalls) | The `setup: (raw) { … }` callback E03-T04 authored already carries the marked insertion point for `PRAGMA key`; the `_openConnection()` / `NativeDatabase.createInBackground` open path lives only in `data` (banned-import gate); pragmas (incl. the cipher key) are **per-connection** and re-issued on every open |
| `docs/engineering/01-architecture-overview.md` §6 (offline guarantee) | The store imports no networking package; encryption adds no socket and no off-device path — the DB key never leaves the device; the encrypted backup file + its own independent passphrase (E17) is the only off-device path |
| Skill `eng-add-drift-table-or-migration` (canonical pattern 11; Do/Don't; checklist) | Pattern 11 verbatim: encryption is optional/opt-in/off-by-default and **never silently plaintext** — the build-hook toggle + `PRAGMA key` in `setup`, the **hard `PRAGMA cipher;` liveness guard** (empty ⇒ refuse), the 32-byte raw key in `flutter_secure_storage` (`first_unlock_this_device`, non-syncing), rotation never in place on WAL. Do: "Keep encryption opt-in with the `PRAGMA cipher;` liveness guard." Don't: "Ship a silently-plaintext store, re-key in place on WAL, or build decoy/duress isolation" |
| Skill `eng-define-service-boundary` (canonical pattern 1, 5, 8; checklist) | The key store is a side-effect boundary: a framework-free Dart interface (`SecretKeyStore`) with a live `flutter_secure_storage` impl in `data`, exposed as a Riverpod `Provider`, wired once at the composition root, with a deterministic **in-memory fake** installed via `overrideWith` so the open path is testable without a real keychain; throwing IO surfaces as a calm retry, the wrong-key user copy authored at the feature/`l10n` layer, never inside the boundary |
| Skill `eng-write-dart-test` (canonical pattern 2, 8, 11; checklist) | The cipher-liveness and error-mapping checks are pure `dart test` (`package:test`) units on `data` over an in-memory key-store fake; assert behaviour (a plaintext store under the encryption flavor is refused; a `SQLITE_NOTADB` open maps to the key-recovery error type, never a corruption type; the key is generated once then stable); install the throwing `HttpOverrides` offline guard; full-word names, typed `catch`, REUSE SPDX header |
| CLAIMS register | None — this task wires a build toggle, a key lifecycle, a liveness guard, and an error mapping; it renders **no** user-facing number, scheduling rule, or methodology claim. The one user-facing surface it *implies* — the key-recovery message and the encryption-toggle / no-physical-erase tradeoff copy — is authored and CLAIMS/adab-reviewed at the Settings/backup feature layer (E16/E17), localized in `l10n`, never hard-coded here |
| Siblings: E03-T04 (depends-on), E03-T05, E03-T09, E17 | T04 authored the `setup`/`beforeOpen` open path with the marked insertion point this task fills with `PRAGMA key`/`PRAGMA cipher;` — author so the existing WAL/`synchronous`/`foreign_keys` order is preserved *after* the key+guard; T05's persistence `Provider` + `NativeDatabase.memory()` doubles are the override seam the key-store fake plugs into; T09's `stepByStep` migrations run *inside* the keyed connection (a key set once at open covers migrations too); **rotation and the encrypted-backup off-device path are E17's checkpointed export pipeline** — this task only points rotation at it, it does not build it |

## Implementation notes

This is correctness-critical, security-adjacent wiring — a silently-plaintext store that *looks* encrypted is the failure this task exists to make impossible. It is not test-first in the FSRS-arithmetic sense, but the **cipher-live / wrong-key-≠-corruption** properties are correctness-critical and must be proven by the units below; author those tests alongside the code.

1. **The build toggle (encryption flavor only).** Add the `hooks` block to the workspace-root `pubspec.yaml` *of the encryption-enabled build flavor only* — when the flavor is off, the block is absent and stock SQLite is bundled with zero cost:
   ```yaml
   hooks:
     user_defines:
       sqlite3:
         source: sqlite3mc   # bundles SQLite3MultipleCiphers instead of stock SQLite
   ```
   Pin the bundled SQLite + sqlite3mc versions (the bundled SQLite is part of the durability surface). Do **not** add `sqlcipher_flutter_libs` or `sqlite3_flutter_libs` (EOL; linking two native SQLite sources reintroduces the silent dual-link conflict).

2. **The key-store boundary** — `packages/data/lib/src/encryption/secret_key_store.dart`. Define a framework-free interface `abstract interface class SecretKeyStore { Future<String> readOrCreateDbKeyHex(); Future<void> deleteDbKey(); }` and a live impl `FlutterSecureKeyStore` that wraps `const FlutterSecureStorage(iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device), aOptions: AndroidOptions(encryptedSharedPreferences: true))`. `readOrCreateDbKeyHex()` reads `hifz_db_key`; if `null`, generates 32 bytes from a cryptographically secure source (`Random.secure()`), hex-encodes (`toRadixString(16).padLeft(2, '0')`), writes it once, and returns it — exactly the §5 `_dbKeyHex()` shape. Expose a Riverpod `Provider<SecretKeyStore>` with a throwing placeholder; wire the live impl only in `main`'s `ProviderScope(overrides:)` (composition root, T05's seam). `flutter_secure_storage` is platform IO confined to `data`; it imports no networking package.

3. **`PRAGMA key` + the hard liveness guard in `setup`** — fill the marked insertion point E03-T04 left at the **top** of the `setup: (raw) { … }` callback (key+guard run *before* the WAL/`synchronous`/`foreign_keys` pragmas, since they must run on the keyed handle):
   ```dart
   // setup runs on the raw sqlite3 handle BEFORE drift touches the DB.
   setup: (raw) {
     if (keyHex != null) {                       // encryption flavor active
       raw.execute("PRAGMA key = \"x'$keyHex'\";");   // raw-key BLOB literal: skips PBKDF2
       // HARD GUARD: refuse a plaintext store that only *looks* encrypted.
       if (raw.select('PRAGMA cipher;').isEmpty) {
         throw const EncryptionNotLiveException();  // build defect — never write plaintext
       }
     }
     raw.execute('PRAGMA journal_mode = WAL;');   // E03-T04 floor, unchanged below the key
     raw.execute('PRAGMA synchronous = FULL;');
     raw.execute('PRAGMA foreign_keys = ON;');
     raw.execute('PRAGMA busy_timeout = 5000;');
   }
   ```
   The `keyHex` is resolved from `SecretKeyStore.readOrCreateDbKeyHex()` *before* `NativeDatabase.createInBackground` is constructed and threaded into `setup` (key derivation/cipher setup is paid once at open, never per write). When the flavor is **off**, `keyHex` is `null` and the entire key+guard block is skipped — the open path is byte-identical to E03-T04.

4. **The cipher-liveness guard is a real release guard, not a debug example.** `EncryptionNotLiveException` is a sealed/typed persistence error (alongside the §3 write-path error type from T07). `PRAGMA cipher;` returning empty means `source: sqlite3mc` is not actually in effect (the toggle fell back to stock SQLite and `PRAGMA key` was a no-op) — this is a build defect that must fail **loudly at open**, never degrade to writing a plaintext DB that looks encrypted. Do not gate this guard behind `kDebugMode`.

5. **Wrong-key-≠-corruption error mapping.** Wrap the first real access at open and classify the failure (model on the §5 table; do not invent classes the doc doesn't name):
   | Symptom at open | Meaning | Mapped error / response |
   |---|---|---|
   | `PRAGMA cipher;` returns empty (encryption flavor) | Cipher not live — misconfigured build | `EncryptionNotLiveException` — refuse to open, fail loudly (never write plaintext) |
   | First access throws `SQLITE_NOTADB` ("file is encrypted or is not a database") | Wrong / missing key — **not** corruption | `WrongDatabaseKeyException` — surface a **key-recovery** flow at the feature layer, **never** a "your data is corrupted" message |
   Detect `SQLITE_NOTADB` via the `SqliteException.extendedResultCode`/result-code surfaced by `package:sqlite3` (typed `catch`, never a string-match on the message). The data layer returns the typed error; the *copy* a ḥāfiẓ reads is authored in `l10n` (`ar` template, `fa`/`ckb`, RTL) at the Settings/backup feature layer — calm, no guilt, never "corrupted."

6. **Rotation is export-to-freshly-keyed — this task only points at it.** Do **not** implement `PRAGMA rekey` or any in-place re-key: SQLite3MultipleCiphers requires the DB not be in WAL mode for a key change, and in-place WAL re-keying has caused corruption. Rotation goes through E17's checkpointed-snapshot export into a freshly-keyed database; document at the rotation call site that it routes to E17 and add **no** in-place re-key path here.

7. **No decoy/duress isolation; honest erase.** Build no decoy session, duress key, or hidden-volume isolation (that is a CycleVault reproductive-health feature answering a coercion threat that does not apply here). One-tap erase (E17/PRD §16) deletes the store and, when encryption is on, `deleteDbKey()` destroys the key — rendering the data cryptographically unrecoverable, which is the honest guarantee. **Never** claim physical secure-erase of flash blocks in any copy.

8. **Pitfalls to avoid:**
   - **A silently-plaintext build.** If `source: sqlite3mc` is not in effect, `PRAGMA key` is a no-op and a plaintext DB ships that *looks* encrypted — the `PRAGMA cipher;` guard must refuse to open. Do not soften it to a log line.
   - **Reporting a wrong key as corruption.** `SQLITE_NOTADB` is wrong/missing key, not corruption; a "data corrupted" message needlessly frightens a user whose data is intact. Map to `WrongDatabaseKeyException` → key-recovery.
   - **In-place WAL re-keying** (`PRAGMA rekey` on the live WAL store) — refused; rotation is export-to-freshly-keyed (E17).
   - **Deprecated SQLCipher packages** (`sqlcipher_flutter_libs` 0.7.0+eol, `sqlite3_flutter_libs` no-op) — refused; the single-source build-hook model is the only path.
   - **Key in syncing / cloud-backed storage** — `first_unlock_this_device` + non-syncing keeps the key off cloud backups and other devices; do not relax the accessibility class.
   - **Cost when off.** No encryption symbol, no `PRAGMA key`, no guard runs in the non-encryption flavor; the `keyHex == null` short-circuit is the only branch the default build sees.
   - **Decoy/duress isolation or a physical-erase claim** — both refused (§5 Pitfalls).
   - **A networking import** sneaking into the key store or open path — `flutter_secure_storage` and `package:sqlite3` are local; no `package:http`/`HttpClient` belongs in `data`.

## Acceptance criteria

- [ ] The encryption-flavor `pubspec.yaml` carries `hooks: user_defines: sqlite3: source: sqlite3mc` with pinned SQLite + sqlite3mc versions; no `sqlcipher_flutter_libs`/`sqlite3_flutter_libs` is added; the non-encryption flavor has no `hooks` block and bundles stock SQLite (zero cost when off).
- [ ] `packages/data/lib/src/encryption/secret_key_store.dart` defines the `SecretKeyStore` interface (framework-free) and a `FlutterSecureKeyStore` live impl using `FlutterSecureStorage` with `first_unlock_this_device` + `encryptedSharedPreferences: true`; `readOrCreateDbKeyHex()` reads-or-generates **once** 32 secure-random bytes as hex; it is exposed as a Riverpod `Provider` with a throwing placeholder, wired live only at the composition root.
- [ ] The E03-T04 `setup` callback's marked insertion point is filled so that, **when a key is present**, `PRAGMA key = "x'…'"` runs, then the hard guard `if (raw.select('PRAGMA cipher;').isEmpty) throw EncryptionNotLiveException()` runs, **before** the unchanged WAL/`synchronous=FULL`/`foreign_keys=ON`/`busy_timeout` pragmas; when the key is `null` the whole block is skipped and the open path is byte-identical to E03-T04.
- [ ] The `PRAGMA cipher;` liveness guard is a real release guard (not `kDebugMode`-gated) and surfaces as the typed `EncryptionNotLiveException` — a store that only looks encrypted is refused, never opened plaintext.
- [ ] A `SQLITE_NOTADB` at open is classified via the typed `package:sqlite3` result code (never a message string-match) and mapped to `WrongDatabaseKeyException` → a key-recovery path; **no** code path emits a "data corrupted" message for a wrong/missing key.
- [ ] No in-place WAL re-key exists (`PRAGMA rekey` appears nowhere); the rotation call site documents that it routes to E17's export-to-freshly-keyed pipeline; no decoy/duress isolation and no physical-secure-erase claim exist.
- [ ] One-tap erase, when encryption is on, calls `deleteDbKey()` so the data is cryptographically unrecoverable; the key never reaches syncing storage or leaves the device.
- [ ] Every changed file carries the REUSE SPDX header; `dart run drift_dev` generates with no errors; `dart format`/analyzer clean; Drift/`sqlite3`/`flutter_secure_storage` symbols stay inside `data` (banned-import gate green).

## Tests

All pure `dart test` in `packages/data/test/` — `package:test`, `NativeDatabase.memory()` (or a temp-file `NativeDatabase` where the cipher must be observable on disk), no `flutter_test`, no widget binding; the key store is the **in-memory fake** injected via the T05 override seam (no real keychain); offline by construction (no networking import in `data`; the throwing `HttpOverrides` is installed in the shared `data` test bootstrap, and no test here opts out).

- `packages/data/test/encryption/secret_key_store_test.dart`:
  - **Key generated once, then stable** — first `readOrCreateDbKeyHex()` on an empty fake store returns a 64-hex-char (32-byte) value and persists it; a second call returns the **same** value (generate-once, not regenerate-per-open).
  - **`deleteDbKey()` clears it** — after delete, a subsequent `readOrCreateDbKeyHex()` mints a *new* key (the erase-renders-unrecoverable path).
- `packages/data/test/encryption/cipher_liveness_guard_test.dart`:
  - **Plaintext-under-encryption-flavor is refused** — drive the `setup` path with a non-null `keyHex` against a handle whose `PRAGMA cipher;` is empty (the stock-SQLite stand-in); assert it throws `EncryptionNotLiveException`, and that **no** plaintext store is left open. This is the load-bearing guard: it proves a silently-plaintext build cannot ship.
  - **Cipher-live path opens** — with `PRAGMA cipher;` reporting a live cipher, the guard passes and the WAL/`synchronous`/`foreign_keys` floor (E03-T04) is still asserted on the keyed connection.
  - **Off-flavor short-circuit** — with `keyHex == null`, the key+guard block does not run and the connection opens exactly as the E03-T04 floor (no `PRAGMA key`, no `PRAGMA cipher;` call) — proves zero cost when off.
- `packages/data/test/encryption/wrong_key_mapping_test.dart`:
  - **`SQLITE_NOTADB` ⇒ `WrongDatabaseKeyException`, never corruption** — open a keyed store with the *wrong* key (or a stock DB with a key set), trigger the first access, and assert the thrown error is the typed `WrongDatabaseKeyException` carrying a key-recovery intent — **never** any corruption-typed error and never a "corrupted" string. Detection is by the `package:sqlite3` extended result code, asserted via typed `catch`.
- The throwing `HttpOverrides` offline guard is installed via the shared `data` test bootstrap; no test reaches a socket.

CI: these run in the `fast` unit job (`docs/engineering/11-testing-strategy.md` §8). No golden, no RTL, no `integration_test` — this task touches no UI and no muṣḥaf rendering; the key-recovery/encryption-toggle copy and its RTL/locale goldens belong to the owning Settings/backup feature (E16/E17).

## Definition of Done

- [ ] All acceptance criteria met; the three `data/test/encryption/*` suites green locally and in CI's `fast` job.
- [ ] **At-rest encryption (epic DoD, non-negotiable)**: it is opt-in/off-by-default with **zero cost when off**; the `PRAGMA cipher;` liveness guard refuses a silently-plaintext store; the raw 32-byte key lives in `flutter_secure_storage` (`first_unlock_this_device`, non-syncing); rotation is export-to-freshly-keyed, never in-place WAL re-key; **no** decoy/duress isolation; a wrong key surfaces a key-recovery path, **never** a "your data is corrupted" message.
- [ ] **Crash-safe floor preserved (epic DoD)**: the key+guard run *before* the WAL/`synchronous=FULL`/`foreign_keys=ON` pragmas E03-T04 set, on the keyed connection; encryption changes nothing about the crash-safe floor or the single write path (E03-T07); a teacher sign-off committed on the keyed connection survives power loss exactly as on the plaintext floor.
- [ ] **Offline / no-network (C1)**: encryption adds no socket — `flutter_secure_storage` and `package:sqlite3` are local IO; the DB key never leaves the device; the only off-device path remains E17's independently-passphrased encrypted backup; the `data` tests install a throwing `HttpOverrides`; no telemetry, no account, nothing leaves the device.
- [ ] **No AI / no microphone**: nothing here touches audio, a microphone, or any model/inference — this is key lifecycle, a cipher pragma, and an error mapping.
- [ ] **Quran text fidelity (R1)**: untouched and unthreatened — the read-only reference tables (E03-T02) gain no write path; encryption protects the at-rest bytes and creates no runtime mutation of the muṣḥaf; `mushaf.checksum_sha256` governance is unaffected.
- [ ] **Layer boundary**: no `package:drift`/`package:sqlite3`/`flutter_secure_storage` symbol crosses into `models`/`engine`/`features`/`quran`; the toggle, key store, guard, and error mapping live only in `data` (banned-import gate green); the key store is an injected `Provider` over an interface, with an in-memory fake — no global singleton, no `get_it`.
- [ ] **RTL + fa/ckb/ar / accessibility**: N/A by construction in this layer — this task emits typed errors, not strings; the key-recovery message and the encryption-toggle / no-physical-erase tradeoff copy are authored in `l10n` (`ar` template, `fa`/`ckb`), RTL, calm and non-shaming, at the Settings/backup feature layer (E16/E17), never hard-coded here.
- [ ] **Sect-neutral adab / no gamification**: no streak/badge/score/health column or value; no Quran/factual claim; no guilt/fear/loss copy implied; the encryption guarantee is stated honestly (key destruction ⇒ cryptographic unrecoverability), never an over-claimed physical-erase promise; sect-/madhhab-neutral.
- [ ] **Deterministic tests**: all pure `dart test`, full-word/unit-bearing names, typed `catch` (the `SQLITE_NOTADB` detection is a typed result-code match, never a string-match), no `print`/`!`/`late` on persistence values, REUSE SPDX header on every changed/new file; the tests assert behaviour (a plaintext store under the flavor is refused; a wrong key maps to key-recovery not corruption; the key is generated once then stable; off-flavor short-circuits), not line counts.
