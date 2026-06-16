# E03-T04 — Connection setup: WAL + synchronous=FULL + foreign_keys=ON pragmas, busy_timeout, and the FK-on startup assertion

| | |
|---|---|
| **Epic** | [E03 — Models & Persistence](EPIC.md) |
| **Size** | S (≈0.5–1 day) |
| **Depends on** | E03-T03 |
| **Skills** | eng-add-drift-table-or-migration, eng-write-dart-test |

## Goal

`HifzDatabase` in `packages/data/lib/src/db/database.dart` opens through a `LazyDatabase` over `NativeDatabase.createInBackground`, and every open — first launch, relaunch, in-memory test — applies the fixed connection configuration: `PRAGMA journal_mode = WAL`, `PRAGMA synchronous = FULL`, `PRAGMA foreign_keys = ON`, `PRAGMA busy_timeout = 5000` in the `setup` callback, **re-asserted** in `beforeOpen` (pragmas are per-connection and not persisted in the file), with a startup `assert` that foreign keys are actually on. This is the crash-safe write floor: a teacher sign-off survives power loss because the write connection syncs the WAL on every commit (`synchronous=FULL`, never `NORMAL`), and the §2 foreign keys enforce because the per-connection FK pragma is turned on on every open. A test proves, against a fresh `NativeDatabase.memory()` open, that WAL is the active journal mode and an FK violation is rejected.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/05-persistence-and-encryption.md` §1 (Specification) | The verbatim `_openConnection()` shape: `LazyDatabase(() async { … NativeDatabase.createInBackground(file, setup: (raw) { … }) })`; the four `setup` pragmas in order (`journal_mode=WAL`, `synchronous=FULL`, `foreign_keys=ON`, `busy_timeout=5000`); the `MigrationStrategy.beforeOpen` that re-issues `PRAGMA foreign_keys = ON` and `assert(await _foreignKeysAreOn())` — "PRAGMA foreign_keys is per-connection and **not** persisted … re-issued on every open" |
| `docs/engineering/05-persistence-and-encryption.md` §1 (Pitfalls) | "We do not forget that pragmas are per-connection" — `foreign_keys`, `synchronous`, and the cipher key are set in `setup`/`beforeOpen` on every open; a value set once and assumed persistent is a silent correctness hole. The Drift-import-only-in-`/data` boundary (banned-import gate) the open path lives behind |
| `docs/engineering/05-persistence-and-encryption.md` §3 (Decision, Rationale) | The crash-safe floor: WAL + `synchronous=FULL` on the write connection; **why `FULL`, not `NORMAL`** — `NORMAL` "transactions are no longer durable and might rollback following a power failure," unacceptable for a *sanad* record we must not lose; readers don't block the writer (the heat-map/Today reads while a review commits) |
| `docs/engineering/05-persistence-and-encryption.md` §5 (Specification) | The encryption-flavor `setup` re-applies the SAME WAL/`synchronous`/`foreign_keys` pragmas after `PRAGMA key` — this task ships the non-encrypted floor; do not duplicate the encryption-only `PRAGMA key`/`PRAGMA cipher` guard here (that is E03-T10), but author `setup` so T10 inserts its key step ahead of these pragmas without restructuring |
| `docs/engineering/01-architecture-overview.md` §1 (hard-rules table), §4 (single write path) | "Crash-safe persist on every review … one SQLite WAL transaction before state republishes" is one of the structural mechanisms; this task lays the WAL/`FULL` floor the §4 `commitReview` (E03-T07) stands on; one `db.transaction` per review is T07, not here |
| Skill `eng-add-drift-table-or-migration` (canonical pattern 6, 7; Do/Don't; checklist) | Pattern 7 verbatim: "WAL + `synchronous=FULL` + `foreign_keys=ON`, re-asserted on every open … pragmas are per-connection, not persisted." Do: "Re-assert WAL + `synchronous=FULL` + `foreign_keys=ON` (+ `busy_timeout`) in `setup`/`beforeOpen` on every open." Don't: "Assume a pragma persists in the file, or use `synchronous=NORMAL` on the write path." Pattern 6's await footgun belongs to the transaction body (T07), not this open path |
| Skill `eng-write-dart-test` (canonical pattern 2, 8; checklist) | The pragma-liveness check is a pure `dart test` (`package:test`) DAO/connection unit on `data` over `NativeDatabase.memory()` — no `flutter_test`, no widget binding; install the throwing `HttpOverrides` offline guard in the `data` test bootstrap; assert behaviour (journal mode is WAL, FK violation throws), full-word names, REUSE SPDX header |
| CLAIMS register | None — this task wires connection pragmas and an FK assertion; it renders no user-facing number, copy, scheduling rule, or methodology claim, so no CLAIMS id is implemented here |
| Siblings: E03-T03, E03-T05, E03-T07, E03-T10 | T03 (depends-on) authored the user Drift tables whose `ON DELETE CASCADE` / `REFERENCES` foreign keys these pragmas make enforce; T05 wraps the `HifzDatabase` handle behind the injected persistence `Provider` and supplies the `NativeDatabase.memory()` fake doubles this task's test reuses; T07's `commitReview` one-transaction write path stands on this WAL+`FULL` floor; T10 inserts the opt-in `PRAGMA key` + `PRAGMA cipher;` liveness guard into the SAME `setup` callback this task defines |

## Implementation notes

This is a small, correctness-critical wiring task — the pragmas ARE the crash-safe floor. It is not test-first in the FSRS-arithmetic sense, but the WAL-active / FK-enforced property is correctness-critical and is proven by the connection test below; author that test alongside the open path.

1. **The open path** — in `packages/data/lib/src/db/database.dart` (or a sibling `connection.dart` in the same `db/` folder, imported by `database.dart`), author the `LazyDatabase _openConnection()` exactly as §1 specifies. Resolve the file with `getApplicationDocumentsDirectory()` + `p.join(dir.path, 'hifz.sqlite')`, then return `NativeDatabase.createInBackground(file, setup: (raw) { … })`. Keep this the **only** place that opens the live store; the in-memory fake for tests is `NativeDatabase.memory()` (T05). Drift / `package:sqlite3` symbols never leave `data` (banned-import gate from E01).

2. **The four `setup` pragmas, in order** — inside `setup: (raw) { … }`, execute on the raw `sqlite3` handle, in this exact order:
   ```dart
   raw.execute('PRAGMA journal_mode = WAL;');   // crash-safe append-only journal — §3
   raw.execute('PRAGMA synchronous = FULL;');   // durable across power loss — §3
   raw.execute('PRAGMA foreign_keys = ON;');    // SQLite leaves FKs OFF by default
   raw.execute('PRAGMA busy_timeout = 5000;');  // wait, don't throw, on brief lock contention
   ```
   `setup` runs on the raw handle **before** Drift touches the DB. Leave a clearly-marked insertion point at the top of `setup` (a comment such as `// (encryption key — PRAGMA key — is set here when the opt-in cipher build is active — §5/E03-T10)`) so T10 can prepend `PRAGMA key`/`PRAGMA cipher;` without restructuring this callback. Do **not** add the encryption guard now.

3. **`beforeOpen` re-asserts FK + the startup assertion** — in `HifzDatabase`'s `MigrationStrategy`, keep `onCreate: (m) async => m.createAll()` and add `beforeOpen: (details) async { await customStatement('PRAGMA foreign_keys = ON;'); assert(await _foreignKeysAreOn()); }`. `beforeOpen` runs through Drift's API (so use `customStatement`, not the raw handle). `_foreignKeysAreOn()` is a private async helper that runs `PRAGMA foreign_keys;` via `customSelect` and returns whether the single result row's value is `1`. The `assert` is debug-fail-fast: if a future refactor drops the FK pragma, debug builds trip immediately rather than silently allowing orphan rows. (T03's foreign keys are load-bearing referential guarantees — `card`/`review_log`/`line_block`/`confusion_edge`/`cycle_config` all `REFERENCES profile(profile_id) ON DELETE CASCADE` — so this assertion guards the whole user-table graph.)

4. **`synchronous = FULL`, never `NORMAL`** — the value is the floor, not a tunable. Do not add a "perf mode" that downgrades to `NORMAL` on the write connection; §3 is explicit that `NORMAL` drops per-commit `fsync` and makes a committed teacher sign-off rollback-able after power loss. The write volume is a handful of rows per review, so `FULL` is free in practice. No code path, build flavor, or test helper sets `synchronous=NORMAL` on the live write connection.

5. **`schemaVersion` and migrations stay minimal here** — `schemaVersion => 1` and `onCreate: createAll()` are this task's only migration surface; the `stepByStep onUpgrade`, committed JSON snapshot, and the release-blocking `integrity_check` fixture test are **E03-T09**, not this task. Do not author migration steps here; just leave the `beforeOpen` FK re-assertion in place (T09's `stepByStep` re-applies pragmas after a migration runs, building on this same `beforeOpen`).

6. **Pitfalls to avoid:**
   - **Assuming a pragma persists.** `journal_mode`'s WAL setting persists in the file, but `foreign_keys`, `synchronous`, and the (later) cipher key are **per-connection** and reset to defaults on every open — they must be in `setup`/`beforeOpen` every time, not set once during onboarding (§1 Pitfalls).
   - **`synchronous = NORMAL` anywhere on the write path** — a *sanad*-record-losing window; refuse it (§3, skill Don't).
   - **Setting FK on only in `setup` and not `beforeOpen`** (or vice-versa) — §1's spec sets it in **both**: `setup` covers the raw-handle open, `beforeOpen` covers Drift's own re-open and is where the startup `assert` lives. Keep both.
   - **Putting the transaction body / `commitReview` here** — the one-`db.transaction`-per-review write path and the await footgun are E03-T07; this task is the connection floor only.
   - **Adding the `PRAGMA key`/`PRAGMA cipher;` encryption guard here** — opt-in at-rest encryption is E03-T10; shipping it now would mean a decision with no toggle behind it.
   - **A `flutter_test` connection test** — the engine/data unit tier is pure `package:test` over `NativeDatabase.memory()`; a widget binding is slower, flakier, and unnecessary to read `PRAGMA journal_mode`.
   - **A network import sneaking into the open path** — `getApplicationDocumentsDirectory` (path_provider) is local IO, not a socket; no `package:http`/`HttpClient` belongs anywhere in `data`.

## Acceptance criteria

- [ ] `packages/data/lib/src/db/database.dart` (and/or `connection.dart`) defines `LazyDatabase _openConnection()` returning `NativeDatabase.createInBackground(file, setup: …)`, the file resolved under `getApplicationDocumentsDirectory()` as `hifz.sqlite`; it is the only live-store open path; Drift/`sqlite3` symbols stay inside `data` (banned-import gate green).
- [ ] The `setup` callback executes, in order, `PRAGMA journal_mode = WAL`, `PRAGMA synchronous = FULL`, `PRAGMA foreign_keys = ON`, `PRAGMA busy_timeout = 5000`, with a clearly-marked insertion point above them for E03-T10's `PRAGMA key`/`PRAGMA cipher;`.
- [ ] `HifzDatabase.migration` keeps `onCreate: createAll()` and adds `beforeOpen` that re-issues `PRAGMA foreign_keys = ON` via `customStatement` and `assert`s a private `_foreignKeysAreOn()` (which reads `PRAGMA foreign_keys;` and checks the value is `1`).
- [ ] No code path, build flavor, or helper sets `synchronous = NORMAL` on the live write connection — verifiable by grep over `data`.
- [ ] On a fresh open (live or `NativeDatabase.memory()`), `PRAGMA journal_mode` reports `wal` and a foreign-key violation against a T03 user table is rejected — proven by the connection test.
- [ ] `schemaVersion` stays `1` and no `stepByStep`/migration step is authored here (that is E03-T09); no encryption pragma is authored here (that is E03-T10).
- [ ] Every changed file carries the REUSE SPDX header; `dart run drift_dev` generates with no errors; `dart format`/analyzer clean.

## Tests

All pure `dart test` in `packages/data/test/` — `package:test`, `NativeDatabase.memory()`, no `flutter_test`, no widget binding; offline by construction (no networking import in `data`; a throwing `HttpOverrides` is installed in the `data` test bootstrap so a stray socket fails loudly). Note that `NativeDatabase.memory()` is single-connection in-memory SQLite, so the connection-level assertions below run against the same `setup`/`beforeOpen` path as the live open.

- `packages/data/test/db/connection_pragmas_test.dart`:
  - **WAL is active on a fresh open** — open an in-memory `HifzDatabase`, `customSelect('PRAGMA journal_mode;')`, assert the returned value is `wal` (case-insensitive). (For `:memory:`, assert the live-file path reports `wal`; if the in-memory backend coerces the journal mode, pin the assertion against a temp-file `NativeDatabase(File(...))` opened through the same `_openConnection` setup so WAL is observable.)
  - **`synchronous = FULL`** — `customSelect('PRAGMA synchronous;')` returns `2` (the SQLite code for `FULL`); assert it is `2`, never `1` (`NORMAL`).
  - **`busy_timeout = 5000`** — `customSelect('PRAGMA busy_timeout;')` returns `5000`.
  - **Foreign keys are enforced on a fresh open** — `customSelect('PRAGMA foreign_keys;')` returns `1`; and an `INSERT` into a child user table (e.g. a `card` row referencing a non-existent `profile_id`, or a `review_log` row with no parent `profile`) **throws** a SQLite FK-constraint error. This is the load-bearing case: it proves the per-connection FK pragma is on, not merely set.
  - **Re-open re-asserts the pragmas** — open, close, re-open the same backing store through `_openConnection`; assert FK is `1` and `synchronous` is `2` again on the second connection, proving they are re-applied per-connection (not relied upon to persist).
  - **`_foreignKeysAreOn()` returns true** after `beforeOpen` (exercise the path that backs the `assert`).
- The throwing `HttpOverrides` offline guard is installed via the shared `data` test bootstrap (no test here opts out).

CI: these run in the `fast` unit job (`docs/engineering/11-testing-strategy.md` §8). No golden, no RTL, no `integration_test` — this task touches no UI and no muṣḥaf rendering.

## Definition of Done

- [ ] All acceptance criteria met; `connection_pragmas_test.dart` green locally and in CI's `fast` job.
- [ ] **Crash-safe floor (epic DoD, non-negotiable)**: the store runs WAL + `synchronous=FULL` + `foreign_keys=ON`, re-asserted on every open; no `synchronous=NORMAL` on the write path; the FK-on startup `assert` is in `beforeOpen`. The WAL+`FULL` floor the §3 single write path (E03-T07) stands on is in place; a teacher sign-off committed on this connection survives power loss.
- [ ] **Offline / no-network (C1)**: the open path imports only local IO (`path_provider`, `dart:async`) — no `package:http`/`dart:io HttpClient`; the `data` connection tests install a throwing `HttpOverrides`; no telemetry, no account, nothing leaves the device.
- [ ] **No AI / no microphone**: nothing here touches audio, a microphone, or any model/inference — this is pure connection wiring.
- [ ] **Quran text fidelity (R1)**: untouched and unthreatened — the FK assertion guards the user-table graph; the read-only reference tables (E03-T02) gain no write path from this task; no runtime write to the muṣḥaf becomes possible.
- [ ] **Layer boundary**: no `package:drift`/`package:sqlite3` symbol crosses into `models`/`engine`/`features`/`quran`; the open path and pragmas live only in `data` (banned-import gate green).
- [ ] **RTL + fa/ckb/ar / accessibility**: N/A by construction — this task has no UI surface and no user-facing string; any error a wrong-key/recovery flow later surfaces is localized at the feature/`l10n` layer (E03-T10), never hard-coded here.
- [ ] **Sect-neutral adab / no gamification**: no streak/badge/score/health column or value; no Quran/factual claim; the schema and connection are sect-/madhhab-neutral and encode no tafsīr.
- [ ] **Deterministic tests**: all pure `dart test`, full-word/unit-bearing names, typed `catch`, no `print`/`!`/`late` on persistence values, REUSE SPDX header on every changed/new file; the tests assert behaviour (journal mode is WAL, FK violation throws, pragmas re-assert on re-open), not line counts.
