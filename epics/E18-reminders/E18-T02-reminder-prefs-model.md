# E18-T02 — Reminder preferences persisted model + DAO through the single write path

| | |
|---|---|
| **Epic** | [E18 — Reminders](EPIC.md) |
| **Size** | S (≈0.5–1 day) |
| **Depends on** | — |
| **Skills** | eng-add-persisted-model, eng-add-drift-table-or-migration, eng-create-riverpod-store |

## Goal

Add the one persisted record this epic owns — the reminder preferences — as the epic's single source of truth: an immutable `ReminderPreferences` value type in `models` (`isEnabled: bool`, the chosen reminder time-of-day as **integer minutes since local midnight**, `isCatchUpNoteEnabled: bool`), a `STRICT` Drift table + DAO confined to `data`, and a repository read/upsert surface that commits through exactly one `db.transaction` (WAL + `synchronous=FULL`, persist-before-republish). Both switches default **off** in the schema itself, so the protective default (design-system 10 §9) is structural, not a UI courtesy. The reminder time is a **civil time-of-day fact, never a `DateTime` instant** — this task stores integers only, computes no fire moment, reads no clock, and touches no OS. The prefs row is mutable config (upsert is correct); it is explicitly **not** the append-only `review_log` and this task adds nothing to it. The controller that calls this repository is E18-T03; the scheduler boundary is E18-T01.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §14 | The complete fact set the reminder layer is allowed to persist: one calm daily reminder at a user-set time, an optional catch-up note, fully optional/easily silenced — i.e. exactly three fields (enabled, time-of-day, catch-up-note-enabled) and **nothing more**: no streak, no last-fired timestamp, no escalation counter |
| `docs/PRD.md` §10.2, §10.3 | The user-table family this record joins: `cycle_config` is the per-profile config-singleton analog (PK = `profile_id` FK, `ON DELETE CASCADE`); `review_log` is append-only and untouched here; derived state is never stored as a second authority |
| `docs/PRD.md` §15.3, §17 | Profiles are device-local (self/students/child) and E16 exposes the reminder row per profile → the prefs row is keyed by `profile_id`; nothing here creates a network, account, or telemetry surface |
| `docs/engineering/05-persistence-and-encryption.md` §2 | Invariants live in the schema, not in Dart: `STRICT` table, `CHECK` on booleans (`IN (0,1)`) and the minutes range, foreign key to `profile`; config columns carry no health/Quran facts |
| `docs/engineering/05-persistence-and-encryption.md` §3 | Crash safety: exactly one `db.transaction` per write, every query inside `await`-ed, WAL + `synchronous=FULL`, the write `Future` resolves only after the durable commit — no debounce, no "save later" |
| `docs/engineering/05-persistence-and-encryption.md` §4 | Migration mechanics: bump `schemaVersion`, commit the `drift_schemas/` JSON snapshot, one generated `stepByStep` callback, the release-blocking fixture test with `PRAGMA integrity_check`; a shipped migration is never edited |
| `docs/engineering/07-dates-calendars-and-correctness.md` §1, §2 | All day/time quantities in scheduling paths are integer arithmetic on plain integers — no `Duration`, no `DateTime.add`; the same discipline makes the stored time-of-day a zone-free integer |
| `docs/engineering/07-dates-calendars-and-correctness.md` §3 | The instant-vs-civil split this task must honor: a `DateTime` named or used like a civil quantity is the DST off-by-one class; the reminder time is a civil fact → integer fields, never an instant, never local-midnight-encoded |
| Skill `eng-add-persisted-model` (+ `template.dart`) | The whole three-layer chain: immutable value type in `models` (`dart:core`/`package:meta` only), Drift table/DAO confined to `data` (no Drift symbol crosses the boundary), names carry units, one `db.transaction` per write, derived state never stored, typed sealed boundary errors, `///` docs |
| Skill `eng-add-drift-table-or-migration` (+ `template.dart`) | The schema/migration half: `STRICT` + `CHECK` + FK in the table class, pragmas re-asserted per connection, the versioned `stepByStep` migration, the populated-v(n−1) fixture test asserting content **and** `integrity_check == ok` |
| Skill `eng-create-riverpod-store` | What this task does **not** own — the `Notifier`/controller and composition-root wiring (E18-T03); taken here only as the contract the repository method must make honorable: persist transactionally **before** any republish becomes observable |
| `docs/engineering/04-flutter-and-state-patterns.md` §4 | The single-write-path property this repository method joins: every mutation is a named repository method whose commit lands **before** any in-memory/stream state becomes observable; the committed Drift watch stream — never a second cache — republishes the UI |
| `docs/design-system/10-privacy-and-trust-ux.md` §9 | The protective default is opinionated, never coercive: off-by-default is encoded as schema `DEFAULT 0`, and an absent row reads as "off" — no pre-ticked box can exist by construction |
| `docs/design-system/10-privacy-and-trust-ux.md` §10 | The reminder layer stays calm and peripheral — which at the storage layer means schema minimalism: nothing exists in this table that could power a cadence escalation, a streak, or a re-engagement heuristic |
| CLAUDE.md engineering non-negotiable #10 | Persist-on-every-change through the single write path: transactional commit **before** republishing; the `review_log` append-only rule is stated so this mutable prefs row is understood as *distinct from it*, not an exception to it |
| Sibling **E18-T01** | Owns the `NotificationScheduler` OS boundary — this task never imports or calls it; nothing here schedules |
| Sibling **E18-T03** | Owns the `ReminderController` that calls this repository, persists-before-republishing, then schedules; this task supplies only the storage surface T03 calls |
| Sibling **E18-T04** / **E18-T05** | T04 owns the time-of-day → fire-moment computation; T05 treats the OS schedule as a rebuildable derived cache — which is exactly why this prefs row is the *only* thing persisted (the schedule itself is never stored) |
| Sibling **E18-T06** | Renders the switch/picker whose committed values land here (via T03); the off-by-default the row shows and the schema `DEFAULT 0` are the same single truth — the widget never invents its own default |
| Sibling **E18-T09** | Consumes `isCatchUpNoteEnabled` for the notification catch-up note; this task stores the flag, authors no note copy |
| `docs/science/CLAIMS.md` | **No CLAIMS id is cited**: this task adds no user-facing string, number, or methodology claim — it is a storage surface only; copy lives in E18-T10 |

## Implementation notes

This task is storage-only: no widget, no OS call, no copy, no clock. It is correctness-critical → the write-path suite and the migration fixture are **written first** (test-first per CLAUDE.md #15).

1. **The value type** lives in the pure `models` package: `ReminderPreferences` — immutable (`final` fields, `const` constructor, `copyWith`), importing `dart:core`/`package:meta` only. Fields per the coding-standards naming rules (full words, units in the name, booleans as assertions): `isEnabled`, `reminderMinutesSinceMidnight` (int, 0–1439 — one integer field chosen over an hour+minute pair so the range invariant is a single `CHECK`), `isCatchUpNoteEnabled`. A `static const defaults` carries both switches off and a neutral default time; `///` docs state that the minutes field is a **civil time-of-day, not an instant**, and that converting it to a fire moment is E18-T04's job.
2. **The Drift table** lives in `data` only: `reminder_preferences`, `STRICT`, per-profile singleton mirroring `cycle_config` — `profile_id TEXT PRIMARY KEY REFERENCES profile(profile_id) ON DELETE CASCADE`; `enabled INTEGER NOT NULL DEFAULT 0 CHECK (enabled IN (0,1))`; `reminder_minutes_since_midnight INTEGER NOT NULL CHECK (reminder_minutes_since_midnight BETWEEN 0 AND 1439)`; `catch_up_note_enabled INTEGER NOT NULL DEFAULT 0 CHECK (catch_up_note_enabled IN (0,1))`. No `DateTime`/instant column exists in this table; no `last_fired_at`, no streak/count column of any kind.
3. **The DAO** maps rows to the `models` value type and back; no Drift `Companion`/`TableInfo`/row class appears in any public signature. Reads: a point read plus a Drift-stream watch (`watchReminderPreferences(profileId)`) so T03's read model re-emits from the committed row — one source of truth, no second cache. An **absent row reads as `ReminderPreferences.defaults`** (off/off); no row is written until the user's first explicit change.
4. **The repository write** is one method, `saveReminderPreferences(profileId, prefs)`, that opens exactly **one** `db.transaction`, `await`s every query inside it, upserts the single row (insert-or-replace on the `profile_id` PK), and resolves only after the durable commit — WAL + `synchronous=FULL` already asserted in the connection `setup`/`beforeOpen`. Upsert/update is correct here because this is mutable config, **not** `review_log`; this task adds no `review_log` method of any kind. Failures surface through the `data` package's sealed error type (`on … catch`, never swallowed).
5. **The migration**: bump `schemaVersion` n → n+1, `drift_dev schema dump` → commit the JSON snapshot, `drift_dev make-migrations` → one typed `stepByStep` `fromNToN+1` callback creating the table. Append-only: no shipped step is edited; `eraseDatabaseOnSchemaChange` stays DEBUG-only. If the prefs should survive `.hifzbackup` export/restore, that is an **additive** payload change routed through `domain-backup-format` (older backups must still restore; restore never replays SQL migrations) — flag it there, do not widen this task.
6. **Pitfalls to avoid:** storing the time as a `DateTime`/local-midnight instant or an epoch value (the DST off-by-one class, eng-07 §3); calling `DateTime.now()` anywhere (nothing here needs a clock); computing or caching a fire moment (T04/T05 own that; the OS schedule is a derived cache and is never persisted); letting a Drift symbol leak into `models`/`engine`/`features`; republishing or emitting before the commit resolves; a default-on switch or a pre-seeded enabled row; adding a "helpful" extra column (last-fired, snooze count, streak) that PRD §14 does not name.

## Acceptance criteria

- [ ] `ReminderPreferences` exists in the `models` package: immutable, `const`-constructible, `copyWith`, imports `dart:core`/`package:meta` only (no Drift, no Flutter); fields are `isEnabled`, `reminderMinutesSinceMidnight`, `isCatchUpNoteEnabled` with `///` docs naming the civil-time-of-day semantics; `defaults` has both switches off.
- [ ] The `reminder_preferences` Drift table lives in `data` only: `STRICT`, PK `profile_id` FK → `profile` with `ON DELETE CASCADE`, `DEFAULT 0` + `CHECK (… IN (0,1))` on both booleans, `CHECK (… BETWEEN 0 AND 1439)` on the minutes column; the table contains **no** `DateTime`/instant column and **no** derived/telemetry column.
- [ ] No Drift/`sqlite3` symbol crosses the `data` boundary: the DAO and repository expose only `models` value types; the banned-import gate stays green.
- [ ] The repository exposes a point read, a watch stream, and `saveReminderPreferences` — the write opens exactly one `db.transaction`, `await`s every inner query, upserts the single per-profile row, and its `Future` resolves only after the durable commit (WAL + `synchronous=FULL`); an absent row reads as the off-by-default value without writing.
- [ ] `review_log` is untouched: this task adds no method, column, or write against it; the prefs upsert is documented as mutable config distinct from the append-only audit trail (CLAUDE.md #10).
- [ ] The migration ships complete: `schemaVersion` bumped, `drift_schemas/` snapshot committed, one `stepByStep` callback added, no shipped step edited, `eraseDatabaseOnSchemaChange` DEBUG-only.
- [ ] No `DateTime.now()`, no `timezone`/`flutter_local_notifications` import, no fire-time computation, no user-facing string, and no CLAIMS-bearing content anywhere in this task's files (verifiable by grep).
- [ ] Every public API added carries `///` docs; naming follows the coding standards (full words, units in the name, booleans as assertions).

## Tests

All deterministic, offline by construction, in the pure **unit tier** of the test pyramid (`flutter test` in the `data` package; no widget binding, no clock, no network — testing-strategy §1). The write-path and migration suites are **written first**; they run in the CI `fast` job, the boundary/banned-import assertions in the `restraint` job (testing-strategy §8).

- `data/test/reminder_preferences_repository_test.dart` (unit) — **written first**:
  - round-trip identity: upsert a `ReminderPreferences` → read it back equal, including the minutes integer unchanged (no unit or zone transform);
  - **persist-before-republish ordering**: a recording observer on the watch stream asserts no emission is observable before the write's `Future` resolves, and the post-commit emission carries the committed value;
  - upsert twice for one profile → exactly one row (idempotent replace, never a duplicate);
  - absent row → `defaults` (both switches off) and **no row is written** by the read;
  - a constraint violation (minutes = 1440; a boolean = 2) is rejected by the schema `CHECK` and surfaces as the typed sealed `data` error — never swallowed;
  - deleting the profile cascades the prefs row (`ON DELETE CASCADE`).
- `data/test/migrations/reminder_preferences_migration_test.dart` (fixture, release-blocking) — builds a **populated v(n−1)** database (profiles, cards, review_log rows), runs the `stepByStep` migration, asserts all prior content survived, the new table exists with its `DEFAULT 0`/`CHECK` constraints live, **and** `PRAGMA integrity_check` returns `ok` (eng-add-drift-table-or-migration Pattern 9; authored per eng-write-dart-test).
- `data/test/reminder_preferences_boundary_test.dart` (boundary) — asserts no Drift/`sqlite3` type appears in the repository's public API surface or in the `models` package (the same banned-import mechanism that quarantines networking); pins that `models`' `ReminderPreferences` file imports `dart:core`/`package:meta` only.
- Grep guards (CI): no `DateTime` in the `reminder_preferences` table/model fields; no `DateTime.now()` in any file this task adds; no `UPDATE`/`DELETE` method added to the `review_log` DAO.

## Definition of Done

- [ ] All acceptance criteria met; the write-path suite and migration fixture were written first and are green locally and in the CI `fast` job (testing-strategy §1/§8).
- [ ] **Offline / no-network**: this task opens no socket and adds no network-capable import; the no-networking/banned-import gates stay green (PRD §17, C1).
- [ ] **No AI / no microphone**: nothing here records, transcribes, or infers; three integers/booleans of user-chosen config are the entire surface (R5).
- [ ] **Quran text fidelity (R1)**: no Quran text, glyph, or reference table is read, written, or referenced; the muṣḥaf integrity surface is untouched (N/A by construction, asserted).
- [ ] **Never "safe to drop" / nothing decays silently**: no scheduling state, health value, or engine fact is stored or altered; the prefs row cannot express a "skip/drop" of any page — it holds only the reminder's own on/off/time facts.
- [ ] **No gamification / no shame (R3, C6)**: the schema structurally forbids the failure mode — no streak, count, last-fired, or escalation column exists; both switches are `DEFAULT 0` (off), per design-system 10 §9.
- [ ] **Date-correctness**: the reminder time persists as an integer civil time-of-day (0–1439); no `DateTime` instant, no zone, no `DateTime.now()`, no fire-moment computation (eng-07 §1–§3); T04 alone converts it at the app edge.
- [ ] **Single write path (CLAUDE.md #10)**: the upsert commits in one `db.transaction` (WAL + `synchronous=FULL`) before any state is observable; `review_log` remains append-only and untouched; the migration is versioned, snapshotted, and fixture-tested with `PRAGMA integrity_check`.
- [ ] **RTL + fa/ckb/ar & accessibility**: N/A by construction — this task ships zero user-facing strings or widgets (asserted by grep); all reminder copy and rendering land in E18-T06/T07/T10.
- [ ] **Deterministic tests**: every suite runs with no clock, no network, no randomness; the boundary and grep guards are wired into CI; all existing gates stay green.
