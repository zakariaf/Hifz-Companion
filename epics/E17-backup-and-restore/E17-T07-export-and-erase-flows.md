# E17-T07 — Shell export & erase: snapshot → off-UI serialize/encrypt → atomic temp → OS share; erase deletes the WAL family + key

| | |
|---|---|
| **Epic** | [E17 — Backup & Restore](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E17-T05, E17-T06, E07 |
| **Skills** | eng-define-service-boundary, eng-create-riverpod-store, domain-backup-format, eng-write-dart-test |

## Goal

The shell-side orchestration that turns the pure `backup/` package into a working export and a real erase — plumbing only, no widgets. **Export**: read a consistent `BackupSnapshot` through the `/data` DAOs, call `HifzBackup.export(snapshot, passphrase:)` **off the UI isolate**, write the bytes to a **fresh, flushed temp file** in the app container (e.g. `Hifz-2026-06-16.hifzbackup`, date from the injected clock), hand it to the **OS share sheet** — the app performs **no** network transfer; for an encrypted export **no plaintext ever touches disk** (serialize-then-seal in memory, only ciphertext is written); temp files are swept on completion and on next launch. **Erase**: one confirmed, irreversible action that closes the DB and deletes the `.sqlite` + `-wal` + `-shm` sibling family plus the `flutter_secure_storage` DB key if opt-in encryption was on — right-to-be-forgotten by construction, no soft-delete, no hidden flag. Both flows route through one controller whose methods persist/commit **before** republishing the card's status; the status date comes from the injected `CalendarDate` clock, never `DateTime.now()`. The card UI is E17-T08; the erase confirmation gate UI is E17-T09 — this task exposes the controller methods they call.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §16 | The verbatim contract: export (all profiles, cards, logs, configs) to local storage / share-sheet — the user chooses where — and "the app itself performs **no** network transfer"; erase is "one action wipes all local data (right-to-be-forgotten by construction)" |
| `docs/PRD.md` §17 | "All data stays on-device; backups are user-initiated local files" — the structural reason this path opens no socket; no account, no telemetry, no PII |
| `docs/engineering/10-backup-format.md` §9 | The normative `exportBackup({passphrase, scope})` and `eraseAllLocalData()` shapes: `/data` reads the snapshot → `backup/` serializes off-UI → fresh temp file, flushed → `Share.shareXFiles` (`share_plus`-class plugin, per the tech-decision log); temp swept on completion + next launch; erase closes the DB then deletes all three WAL-family files + the key; the three refusals (no in-app transfer, no plaintext left for encrypted, never delete only the main `.sqlite`) |
| `docs/engineering/10-backup-format.md` §8 | Only if the SQLite-dump fast-path is surfaced: it is generated with `VACUUM INTO` to a fresh non-existing path — **never** a copy of the live `.sqlite`/`-wal`/`-shm` family — wrapped in the same container; documented JSON stays primary |
| `docs/engineering/05-persistence-and-encryption.md` §3 | Persist-before-publish and "we never file-copy the live store" (WAL = a three-file family; copying the main file loses uncheckpointed commits) — the rules the snapshot read and the erase both honor |
| `docs/engineering/05-persistence-and-encryption.md` §5 | The `flutter_secure_storage` DB key the erase destroys when the encryption flavor is on; key destruction = cryptographic unrecoverability, the honest guarantee (never a "physical secure-erase of flash" claim) |
| Skill `domain-backup-format` (+ `template.dart`) | Canonical-pattern items 15–16: atomic temp + serialize-then-seal in memory, temp sweep, erase deletes `.sqlite` + `-wal` + `-shm` (+ key), `VACUUM INTO` fresh-path-only, refuse any in-app transfer; item 2 (`dart:io` confined to the shell's file-move step) |
| Skill `eng-define-service-boundary` (+ `template.dart`) | The boundary shape this task's file/share/key IO takes: framework-free interface + live impl + Riverpod `Provider` + throwing un-overridden placeholder, wired once in the E07 composition root; a hand-written deterministic fake per boundary; mutating boundaries consumed through the single write path; `today` only via the injected `Clock` |
| Skill `eng-create-riverpod-store` | The controller rules: `AsyncNotifier` over one immutable status value; every mutation persists transactionally before any republish; no `DateTime.now()` in shell logic; stores never navigate (the post-erase redirect is the router guard's); no hardcoded user-facing string in the store |
| Skill `eng-write-dart-test` | The throwing `HttpOverrides` offline guard in the test bootstrap, the injected fixed clock, and placing these as shell unit tests over fakes — never `pumpWidget` for controller logic |
| Sibling **E17-T01 / E17-T05** | Supply the `HifzBackup.export` façade, `BackupSnapshot`, and the mode-`0x02` encryption envelope this task *calls*; the off-UI-isolate requirement for Argon2id originates there — this task builds **no** format bytes and touches **no** crypto internals |
| Sibling **E17-T06** | The restore counterpart: shares the `/data` conventions and supplies `HifzBackup.import` for this task's export→import round-trip test; restore transactions/merge live there, not here |
| Sibling **E17-T08** | The Settings backup card that calls `exportBackup` / watches the status this controller republishes; **all** user-facing copy (status line, honesty copy, encryption toggle) is T08's |
| Sibling **E17-T09** | The erase confirmation gate that calls `eraseAllLocalData()` after its two-step confirm; this task exposes the method and performs the IO — it renders no dialog and owns no consequence copy |
| `docs/science/CLAIMS.md` | **None cited** — this task ships no user-facing factual claim; the status date is a display-only localized render (T08), not a graded claim |

## Implementation notes

This task is plumbing behind injected boundaries: no widget, no user-facing string, no new Drift schema (E03 owns schema; this task adds only read/orchestration methods). Everything side-effectful is an injected Riverpod boundary with a deterministic fake (E07 composition root) — never a global singleton, never raw `dart:io` in a controller.

1. **Files**:
   - `data/lib/src/backup/backup_snapshot_reader.dart` — `readSnapshot(BackupScope scope) → BackupSnapshot`: one read transaction over the existing DAOs (profile, cycleConfig, cards, lineBlocks, the append-only reviewLog, confusionEdges → T01 value types) so the snapshot is a consistent view; never a file copy of the live store (05 §3).
   - `app/lib/src/backup/backup_file_store.dart` — `BackupFileStore` boundary: `writeTempExport(fileName, bytes)` (fresh never-pre-existing path in the app container, flushed write), `sweepExports()`, `deleteDatabaseFamily()`; live `dart:io` impl + in-memory fake.
   - `app/lib/src/backup/share_service.dart` — `ShareService.shareFile(path)` boundary wrapping the platform share sheet (10 §9); recording fake.
   - `app/lib/src/backup/secure_key_store.dart` — thin boundary over the secure-storage key delete (05 §5); live only in the encryption flavor, no-op fake elsewhere.
   - `app/lib/src/backup/backup_controller.dart` — one `AsyncNotifier` exposing `exportBackup({String? passphrase, BackupScope scope})` and `eraseAllLocalData()`, publishing an immutable `BackupStatus` (idle / exporting / exported(date) / erased / failure).
2. **Export pipeline, in order** (10 §9): `readSnapshot(scope)` → `HifzBackup.export(snapshot, passphrase:)` **off the UI isolate** (`Isolate.run`/`compute` — Argon2id is deliberately slow, T05) → `writeTempExport` → `shareFile` → sweep. The controller awaits each stage; the in-progress state reflects only real CPU/crypto work — no fake "syncing…" theater.
3. **Atomic temp, no plaintext**: the temp path never pre-exists and the write is flushed, so the share sheet can never observe a half-written file; for `passphrase != null` the plaintext JSON exists only in memory inside `backup/` — only ciphertext bytes reach `writeTempExport`. `sweepExports()` runs after the share completes **and** at next launch (E07 startup hook) as the backstop.
4. **File name from the injected clock**: `Hifz-<yyyy-MM-dd>.hifzbackup` built from `clock.today()` (`CalendarDate` ISO text form) — ASCII, locale-independent (no locale leaks into the artifact); no `DateTime.now()` anywhere in this task's files.
5. **Status persists before it republishes**: on successful share, write the last-backup marker through the existing `/data` `app_meta` write path in one transaction (no new schema), and only then republish `BackupStatus.exported(date)` for the T08 card. A failure at any stage propagates as a typed failure state (calm retry is T08's rendering) — never a swallowed error, never an optimistic status.
6. **Erase, in order** (10 §9): close the DB handle (release the WAL family) → `deleteDatabaseFamily()` deletes `.sqlite`, `-wal`, **and** `-shm` (no stale sibling can resurrect deleted state) → delete the secure-storage DB key if the encryption flavor is on → sweep any leftover export temp files → republish the erased/uninitialized state. No soft-delete, no hidden "deleted" flag, no surviving `review_log` row. The controller does **not** navigate — the `go_router` redirect guard sees the uninitialized state and routes to onboarding.
7. **The share sheet moves the file — the app never does.** No networking import appears anywhere in this task's files; `dart:io` is confined to the live boundary impls. The CI banned-import/no-network gate (E01) covers `app/lib/src/backup/` exactly as it covers `backup/`.
8. **Boundaries per eng-define-service-boundary**: each interface is framework-free and lives with the value types it moves; each live impl is constructed **only** in `main`'s `ProviderScope` overrides (E07); each un-overridden placeholder throws; each fake is a plain hand-written class — no mock framework.
9. **`VACUUM INTO` variant (only if surfaced)**: an optional whole-store dump is produced by `VACUUM INTO` onto a fresh non-existing path and wrapped in the same container (10 §8) — never `cp hifz.sqlite`, never onto an existing path, never the primary format. Do not build UI for it here.
10. **Pitfalls to avoid:** running `HifzBackup.export` on the UI isolate; writing plaintext then encrypting the file in place; reusing/pre-creating the temp path; deleting only the main `.sqlite` on erase; deleting the files before the DB handle is closed; leaving the DB key after an encrypted-flavor erase; republishing status before the `app_meta` commit; `DateTime.now()` for the file name or status date; navigating from the controller; any user-facing string in this task (copy belongs to T08/T09); claiming physical secure-erase (key destruction is the honest guarantee, 05 §5).

## Acceptance criteria

- [ ] `data/.../backup_snapshot_reader.dart`, `app/.../backup_file_store.dart`, `share_service.dart`, `secure_key_store.dart`, and `backup_controller.dart` exist as specified; no widget, no user-facing string, no new Drift schema, no `DateTime.now()`, no networking import in any of them (verifiable by grep).
- [ ] `exportBackup` runs the full pipeline — consistent snapshot read → off-UI `HifzBackup.export` → fresh flushed temp file named `Hifz-<yyyy-MM-dd>.hifzbackup` from the injected clock → share-sheet boundary — and sweeps temp files on completion and on next launch.
- [ ] An encrypted export writes **only ciphertext** to disk: no plaintext JSON bytes ever reach the file store, proven against the in-memory fake.
- [ ] The exported bytes are a valid container: `HifzBackup.import` (T06's side) round-trips them back to an equal `BackupSnapshot`.
- [ ] The last-backup marker commits through the `/data` `app_meta` write path **before** the controller republishes `exported(date)`; failures surface as a typed failure state, never a swallowed error or optimistic status.
- [ ] `eraseAllLocalData()` closes the DB, deletes `.sqlite` + `-wal` + `-shm`, deletes the secure-storage DB key when the encryption flavor is on, and republishes an uninitialized state — with no soft-delete flag and no navigation from the controller.
- [ ] Every side effect (file IO, share sheet, key store, clock, DB handle) is an injected Riverpod boundary with a throwing un-overridden placeholder, wired once in the E07 composition root, each with a hand-written deterministic fake.
- [ ] The app performs no network transfer anywhere in these flows; the CI banned-import/no-network gate over `app/lib/src/backup/` and `backup/` stays green.

## Tests

All deterministic shell unit tests over the fakes with the injected fixed `CalendarDate` clock (never a wall clock) and the throwing `HttpOverrides` offline guard installed via the shared bootstrap (eng-write-dart-test).

- `app/test/backup/export_flow_test.dart` — pins the pipeline: `exportBackup` reads the seeded snapshot, produces bytes that `HifzBackup.import` round-trips to an equal `BackupSnapshot`; the temp path is fresh and the write flushed; the file name is `Hifz-2026-06-16.hifzbackup` under `FixedClock(2026-06-16)`; the recording `ShareService` fake receives exactly that path; the temp file is swept after share and by the launch-time sweep.
- `app/test/backup/export_no_plaintext_test.dart` — with a passphrase, asserts no plaintext marker (the canonical JSON's `schemaVersion` key / any payload substring) appears in **any** bytes ever handed to the `BackupFileStore` fake — only the sealed container is written; also asserts `HifzBackup.export` was invoked off the UI isolate (the isolate-runner boundary's fake records the hand-off).
- `app/test/backup/erase_completeness_test.dart` — the engineering 10 §10 "Erase completeness" case: after `eraseAllLocalData()` no `.sqlite`/`-wal`/`-shm` survives in the fake store, the DB key is gone from the `SecureKeyStore` fake, the DB handle was closed **before** any delete (call-order recorded), and the republished state is uninitialized with no navigation performed by the controller.
- `app/test/backup/backup_controller_test.dart` — persist-before-republish: the `exported(date)` status becomes observable only **after** the `app_meta` commit (a recording repository asserts the order); a failure injected at each stage (read / serialize / write / share) surfaces the typed failure state and leaves no stale temp file and no status write.
- Offline guard — the whole suite runs under the throwing `HttpOverrides`: any socket open from the export/erase path is a loud named failure, proving the share sheet (not the app) moves the file.
- CI — the existing banned-import/no-network gate (E01) covers these paths; this task adds no exemption.

## Definition of Done

- [ ] All acceptance criteria met; the export/erase tests are green and run in CI under the offline guard.
- [ ] **Offline / no-network (C1, PRD §17)**: no networking import in any file this task adds; the OS share sheet moves the file, the app transmits nothing; the throwing-`HttpOverrides` suite and the CI banned-import/no-network gate both pass.
- [ ] **No AI / no audio / no microphone (C2, R5)**: the export is a deterministic serialization of stored truth and the erase is file IO — nothing records, infers, or scores.
- [ ] **Quran text fidelity (R1)**: no Quran text, glyphs, fonts, or layout is read, written, or deleted-then-resurrected by these flows; the backup carries only the muṣḥaf reference (T03), and the erase touches the user store family, never the checksum-governed Quran reference assets (E05).
- [ ] **Never "safe to drop" (decay axiom)**: this task ships no copy and no engine call; nothing here labels, drops, or reschedules a page — status states are plumbing values, and the consequence/honesty copy is owned by T08/T09 under their adab gates.
- [ ] **No gamification / no shame (R3, C6)**: the controller's states carry no streak/score/celebration semantics; export progress reflects only real work (no fake sync theater); erase completion is a plain state change with no flourish.
- [ ] **Erase actually erases (PRD §16)**: `.sqlite` + `-wal` + `-shm` + the DB key are gone; no soft-delete or hidden flag; after erase nothing about the user persists on-device — cryptographic unrecoverability via key destruction is the stated guarantee, never "physical secure-erase".
- [ ] **Single write path / dumb View**: export/erase route through one controller; the status marker commits through `/data` before any republish; no widget mutates state; no `DateTime.now()` — the file-name and status dates come from the injected `CalendarDate` clock; the controller never navigates.
- [ ] **RTL + fa/ckb/ar**: no user-facing string is introduced here (T08/T09 own all copy through the ARB pipeline); the `.hifzbackup` file name is ASCII and locale-independent, so the format leaks no locale — its bidi-isolated on-screen rendering is T08's.
- [ ] **Accessibility**: no UI surface ships in this task; the controller exposes distinct, immutable states so the T08 card and T09 gate can announce export/erase progress and outcome per their own WCAG gates.
- [ ] **Deterministic tests**: every test uses fakes + the fixed injected clock, no wall clock, no real network, no mock framework; call-order and no-plaintext assertions are byte-level over the fakes; all gates stay green.
