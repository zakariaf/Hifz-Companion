# E03 — Models & Persistence

Build the persisted spine of Hifz Companion: the immutable value models in the pure `models` package and the Drift/SQLite store in `data` that holds them — `profile`, `card`, the append-only `review_log`, `confusion_edge`, `cycle_config`, `line_block`, `app_meta`, plus the read-only checksum-governed Quran reference tables. It ships the crash-safe write floor (WAL + `synchronous=FULL`), the one-`db.transaction`-per-review persist-before-republish single write path, guided `stepByStep` migrations with a release-blocking `integrity_check` fixture test, and the opt-in (off-by-default) at-rest encryption toggle — so that "nothing decays silently" is a property the storage layer holds, not a promise.

## Why this epic exists

The whole product exists to stop a ḥāfiẓ from *silently* losing the Quran ([PRD §2](../../docs/PRD.md)); the store is where that covenant becomes physical. A teacher sign-off is a *sanad* act and the `review_log` is its trustworthy audit trail, so a lost write, a half-applied review, or a silently mutated log row is not a bug — it is a breach of the app's central promise ([engineering 05 §intro](../../docs/engineering/05-persistence-and-encryption.md); [PRD §7.12, §10.3](../../docs/PRD.md)). That is why crash-safety and transactional integrity are the *mandatory floor* here and not a later hardening pass: every review writes several rows at once (`onReview` appends the audit row, updates the `card`'s D/S/`due_at`/flags, may create `line_block`s, may bump `confusion_edge` weights — [PRD §7.7](../../docs/PRD.md)), and only WAL + `synchronous=FULL` + one transaction makes that all-or-nothing across power loss ([engineering 05 §3](../../docs/engineering/05-persistence-and-encryption.md); [SQLite WAL](https://sqlite.org/wal.html)). This epic also sets the boundary that keeps the rest of the system honest: Drift and `package:sqlite3` are confined to `data`, so the pure-Dart engine stays deterministic and golden-testable without a database ([engineering 01 §2–§3](../../docs/engineering/01-architecture-overview.md)), the `review_log` is append-only by the *absence* of any `UPDATE`/`DELETE` DAO method ([PRD §10.3](../../docs/PRD.md)), and scheduling days are stored as `CalendarDate` serial-day integers — never `DateTime` instants — foreclosing the DST off-by-one that produces a wrong "next due." It also makes text-fidelity structural at the storage layer: the Quran reference tables (`page`, `line`, `ayah`, `surah`, `mushaf`, `mutashabih_*`) are read-only by construction, governed by the asset checksum, and never written at runtime ([PRD R1, §11.3](../../docs/PRD.md)). Every feature epic (E11–E19) then mutates state through a single write path already known to be crash-safe, instead of discovering data-loss bugs during release hardening.

## Scope

### In scope

- The immutable value types in the pure `models` package — `Profile`, `Card`, `ReviewLog`, `ConfusionEdge`, `CycleConfig`, `LineBlock`, plus the reference DTOs (`Page`, `Line`, `Ayah`, `Surah`, `Mushaf`, `MutashabihGroup`, `MutashabihMember`) — `final`/`const`/`copyWith`, `dart:core`/`package:meta` only, no Drift or Flutter import; closed sets (`track`, `grade`, `source`, `role`, `locale`, `revelation`) as enums; scheduling days typed `CalendarDate`, true instants typed `DateTime`.
- The Drift `HifzDatabase` in `data`: the v1 schema as `STRICT` table classes with `CHECK` (enum + range), foreign keys (`ON DELETE CASCADE` for per-profile children), indices (`card_due`, `review_log_by_card`, …), and the load-bearing invariant `CHECK (track = 'UNMEMORIZED' OR due_at IS NOT NULL)`, split into read-only reference tables and read-write user tables ([PRD §10](../../docs/PRD.md)).
- The connection `setup`/`beforeOpen` pragmas — `journal_mode=WAL`, `synchronous=FULL`, `foreign_keys=ON`, `busy_timeout` — re-asserted on every open, with a startup assertion that foreign keys are on.
- DAOs that map rows to plain `models` value types with no Drift symbol crossing the `data` boundary; the `review_log` DAO exposes **no** `UPDATE`/`DELETE` method.
- The single write path: a repository `commitReview(...)` that opens exactly one `db.transaction`, `await`s every query, appends the audit row, upserts the `card`, conditionally writes `line_block`/`confusion_edge`, and resolves only after the durable commit (persist-before-republish); plus the cold-start `seedColdStart(...)` outer transaction ([PRD §7.10](../../docs/PRD.md)).
- The persistence service boundary: the Drift handle behind a Dart interface declared as a Riverpod `Provider`, wired once at the composition root, with an in-memory (`NativeDatabase.memory()`) deterministic fake for tests, and a `FixedClock` so stored `CalendarDate`s never drift with the host.
- Guided migration infrastructure: integer `schemaVersion`, committed `drift_schemas/` JSON snapshot, `stepByStep` `onUpgrade`, the workflow + the rule that a shipped migration is never edited, and `eraseDatabaseOnSchemaChange` gated DEBUG-only.
- The opt-in / off-by-default at-rest encryption toggle (`source: sqlite3mc`, ChaCha20-Poly1305), the raw 32-byte key in `flutter_secure_storage` (`first_unlock_this_device`, non-syncing), the `PRAGMA cipher;` liveness guard that refuses a silently-plaintext store, and the wrong-key-≠-corruption error mapping.
- Tests: value→row→value round-trip units, the `commitReview` transaction unit (a thrown step republishes nothing / commits nothing), the append-only `review_log` enforcement check, and the release-blocking migration fixture test (`v(n−1)` populated → migrate → content survives + `PRAGMA integrity_check == ok`).

### Out of scope

- The pure scheduling arithmetic that produces the `Card` state the store persists — `onReview`, the trust clamp, tracks, the FSRS curve → **E04 scheduling-engine** (this epic persists the engine's output, never recomputes it).
- What a stored `due_at`/`last_review_at` serial-day integer *means* — the `CalendarDate` value type, the injected "today" clock semantics, Hijri/Jalālī/Gregorian display → **E02 calendar-and-date-core** (consumed here as a typed dependency).
- The read-only reference data's *content* and checksum governance — the byte-exact Tanzil text, KFGQPC fonts, QUL layout, the asset-pack download + SHA-256 verifier that fills these tables → **E05 quran-data-and-rendering**.
- The Riverpod `Notifier`/`AsyncNotifier`/`StreamProvider` controllers and the composition-root shell wiring that *call* `commitReview` → **E07 app-shell-walking-skeleton** (this epic defines the repository method and the persistence `Provider`; the shell consumes them).
- The `.hifzbackup` export/import file, the WAL-checkpointed snapshot, the set-union merge over `review_log`, one-tap erase — the only sanctioned bulk touch of `review_log` → **E17 backup-and-restore**.
- Normalizing a recitation verdict into the `(grade, error_lines, source)` signal before it becomes a `review_log` row → **E12 today-and-recite-grade** (with the grading-pipeline rules).
- The `pubspec.yaml`, `resolution: workspace` members, and the banned-import lints that contain `data` and keep `engine` pure → **E01 repo-scaffold-and-ci**.

## Dependencies

### Depends on

- **E01 repo-scaffold-and-ci** — the `models` and `data` packages, the `resolution: workspace` wiring, the engine-purity / no-network / Drift-quarantine banned-import lints, and the REUSE/SPDX headers this code lives under.
- **E02 calendar-and-date-core** — the `CalendarDate` serial-day value type that every scheduling-day column stores and the injected `Clock`/"today" the write path and tests read instead of `DateTime.now()`.

### Enables

E04 (persists the engine's `Card`/track outputs and reads `card` rows back), E05 (fills the read-only reference tables it owns the content for), E07 (the walking-skeleton shell wires the persistence `Provider` and drives the single write path), E11 (cold-start seeding writes 600+ cards through `seedColdStart`), E12 (the recite/grade flow commits a review), E14 (`confusion_edge` bookkeeping), E15 (per-juz health computed on read from `card`), E16 (multi-profile rows), and E17 (export/import and erase ride this schema).

## Foundation inputs

| Input | Where (doc/skill) | What this epic takes from it |
|---|---|---|
| The store decision & connection setup | docs/engineering/05-persistence-and-encryption.md §1 | Drift 2.34 on `NativeDatabase` FFI confined to `data`; the fixed `setup`/`beforeOpen` pragmas; FK pragma is per-connection, re-asserted on every open |
| The v1 schema | docs/engineering/05-persistence-and-encryption.md §2 | `STRICT` tables, `CHECK` enum/range, foreign keys, indices, the `CHECK (track='UNMEMORIZED' OR due_at IS NOT NULL)` invariant; reference vs. user split; instants UTC, scheduling days `CalendarDate` serial integers; `review_log` append-only; no persisted derived health |
| Crash safety | docs/engineering/05-persistence-and-encryption.md §3 | WAL + `synchronous=FULL`; one `db.transaction` per review; the canonical `commitReview` body; the `await` footgun; persist-before-republish; `seedColdStart` outer transaction |
| Migrations | docs/engineering/05-persistence-and-encryption.md §4 | `stepByStep`, committed JSON snapshots, the CI-gate table, "a shipped migration is never edited", the `integrity_check` fixture test, `eraseDatabaseOnSchemaChange` DEBUG-only, restore-maps-forward |
| At-rest encryption | docs/engineering/05-persistence-and-encryption.md §5 | The opt-in/off-by-default `sqlite3mc` toggle, the raw-key `flutter_secure_storage` lifecycle, the `PRAGMA cipher;` liveness guard, no decoy/duress, wrong-key-≠-corruption |
| Architecture & layers | docs/engineering/01-architecture-overview.md §2, §3 | Layer 0 `models` (pure value types) / Layer 2 `data` (Drift); the allowed-import matrix; Drift never crosses into `engine`/`features`/`quran` |
| The single write path | docs/engineering/01-architecture-overview.md §4 | The unidirectional lifecycle of one review: engine computes → repository persists in one WAL transaction *before* republish; one `due_at` sink |
| The offline guarantee | docs/engineering/01-architecture-overview.md §6 | Every `data` repository imports no networking package — the structural reason "no per-user data leaves the device" is grep-provable |
| PRD data model | docs/PRD.md §10 | The exact column set for `profile`/`card`/`review_log`/`confusion_edge`/`cycle_config`/`line_block`/`app_meta` and the reference tables; §10.3 append-only + computed-not-stored health |
| Skill: persisted model | eng-add-persisted-model | The value-type → Drift table → DAO → repository-transaction chain; enum closed-sets; `CalendarDate` days; append-only `review_log`; one transaction per write |
| Skill: Drift table/migration | eng-add-drift-table-or-migration | `STRICT`/`CHECK`/FK schema authoring; the `stepByStep` migration + committed snapshot + `integrity_check` fixture; the encryption toggle + `PRAGMA cipher` guard |
| Skill: service boundary | eng-define-service-boundary | The persistence handle as an injected `Provider` over a Dart interface, wired once at the composition root, with an in-memory fake and a fixed clock |
| Skill: tests | eng-write-dart-test | The value→row→value round-trip and DAO units, the transaction unit, and the release-blocking migration fixture test asserting `PRAGMA integrity_check`; the throwing `HttpOverrides` offline guard |

## Deliverables

- [ ] Immutable value types in `models`: `Profile`, `Card`, `ReviewLog`, `ConfusionEdge`, `CycleConfig`, `LineBlock` + reference DTOs — `final`/`const`/`copyWith`, enums for closed sets, `CalendarDate` for scheduling days, `DateTime` only for instants, no Drift/Flutter import.
- [ ] The Drift `HifzDatabase` v1 schema in `data`: `STRICT` table classes with `CHECK`/FK/index invariants and the memorized-card `CHECK`, read-only reference tables + read-write user tables, the `setup`/`beforeOpen` pragmas (WAL, `synchronous=FULL`, `foreign_keys=ON`, `busy_timeout`).
- [ ] DAOs mapping rows to `models` value types, no Drift symbol crossing `data`; the `review_log` DAO with **no** `UPDATE`/`DELETE` method.
- [ ] The single-write-path repository: `commitReview(...)` (one `db.transaction`, every query `await`-ed, persist-before-republish) and the `seedColdStart(...)` outer transaction; a sealed persistence error type, typed `catch`, no swallowed write error.
- [ ] The persistence service boundary: the Drift handle behind a Dart interface as a Riverpod `Provider` wired once at the composition root, throwing placeholder when un-overridden, plus the in-memory fake and `FixedClock` doubles.
- [ ] Migration infrastructure: `schemaVersion = 1`, committed `drift_schemas/` snapshot, `stepByStep` `onUpgrade` skeleton, `eraseDatabaseOnSchemaChange` gated DEBUG-only.
- [ ] The opt-in/off-by-default at-rest encryption path: the `sqlite3mc` build-hook flavor, the raw-key `flutter_secure_storage` lifecycle, the `PRAGMA cipher;` liveness guard, the wrong-key-vs-corruption error mapping.
- [ ] Tests: value→row→value round-trips, the `commitReview` transaction unit (throw ⇒ no commit, no republish), the append-only `review_log` enforcement check, and the release-blocking migration fixture test (`integrity_check == ok`), all offline by construction.

## Definition of Done

- [ ] Every review persists in exactly one `db.transaction` that commits *before* any state republishes; a unit test proves a thrown step rolls back fully and publishes nothing — no code path leaves memory newer than disk; a teacher sign-off is never acknowledged before its durable commit.
- [ ] The store runs WAL + `synchronous=FULL` + `foreign_keys=ON`, re-asserted on every open; no `synchronous=NORMAL` on the write path; every query inside a `transaction(() async` block is `await`-ed (reviewed).
- [ ] No `package:drift` / `package:sqlite3` symbol crosses the `data` boundary; `models` and `engine` import neither (banned-import gate green); DAOs hand the rest of the app only `models` value types.
- [ ] `review_log` is append-only — its DAO exposes no `UPDATE`/`DELETE` method (enforced by absence, reviewed); the only sanctioned bulk touch is export / one-tap erase, owned by E17.
- [ ] Scheduling-day columns (`due_at`, `last_review_at`) store `CalendarDate` serial integers, never `DateTime` instants; true event times (`reviewed_at`, `created_at`, `last_confused_at`) store UTC; a `DateTime` named like a scheduling day is rejected in review.
- [ ] Reference tables (`page`/`line`/`ayah`/`surah`/`mushaf`/`mutashabih_*`) are read-only by construction — no write DAO exists; text fidelity is not put at risk by any runtime write (R1). `mushaf` carries its riwāyah and `checksum_sha256`; the schema is sect-/madhhab-neutral and encodes no tafsīr/translation.
- [ ] No derived health is persisted: per-juz/per-page/per-ḥizb health and `R` are computed on read from `card` (min-leaning); `*_json` columns hold only small, decode-validated, non-Quran/non-health data.
- [ ] Migrations are guided `stepByStep` with a committed JSON snapshot per version and are append-only (a shipped migration is never edited); a release-blocking fixture test migrates a populated `v(n−1)` DB and asserts content survived **and** `PRAGMA integrity_check == ok`; `eraseDatabaseOnSchemaChange` is DEBUG-only.
- [ ] At-rest encryption is opt-in/off by default with zero cost when off; the `PRAGMA cipher;` liveness guard refuses a silently-plaintext store; the raw 32-byte key lives in `flutter_secure_storage` (`first_unlock_this_device`, non-syncing); rotation is export-to-freshly-keyed, never in-place WAL re-key; no decoy/duress isolation; a wrong key surfaces a key-recovery path, never a "your data is corrupted" message.
- [ ] Offline by construction: no `data` repository imports any networking package; tests install a throwing `HttpOverrides` so a stray call fails loudly; no telemetry, no account, no PII off-device.
- [ ] The persistence boundary is an injectable `Provider` over a Dart interface (no global singleton, no `get_it`), with an in-memory fake and a fixed clock; the engine takes no injection and reads no clock.
- [ ] No record encodes a streak/badge/score/confetti or any Quran/factual claim; any user-facing string a stored field maps to lives in `l10n` (`ar` template, `fa`/`ckb`), RTL, locale numerals — never hard-coded in a record, DAO, or repository.
- [ ] All tests are pure `dart test` (`models`/`data` round-trips, transaction, migration fixture) with full-word/unit-bearing names, typed `catch`, no `print`/`!`/`late` on persistence values, REUSE SPDX header; they assert behaviour, not lines; CI green.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E03-T01 | [Immutable value models in the pure `models` package (Card, ReviewLog, Profile, ConfusionEdge, CycleConfig, LineBlock) with enums and CalendarDate days](E03-T01-models-value-types.md) | M | E01, E02 |
| E03-T02 | [Reference DTOs and the read-only reference table classes (page/line/ayah/surah/mushaf/mutashabih_*) — no write DAO](E03-T02-reference-tables-readonly.md) | M | E03-T01 |
| E03-T03 | [User Drift table classes (profile, card, line_block, review_log, confusion_edge, cycle_config, app_meta) with STRICT/CHECK/FK/index invariants](E03-T03-user-drift-tables.md) | L | E03-T01, E03-T02 |
| E03-T04 | [Connection setup: WAL + synchronous=FULL + foreign_keys=ON pragmas, busy_timeout, and the FK-on startup assertion](E03-T04-connection-pragmas-crash-safety.md) | S | E03-T03 |
| E03-T05 | [Persistence service boundary: the Drift handle behind a Dart interface as a Riverpod Provider wired at the composition root, with in-memory fake + FixedClock doubles](E03-T05-persistence-service-boundary.md) | M | E03-T03, E02 |
| E03-T06 | [DAOs mapping rows to value types; the append-only review_log DAO (no UPDATE/DELETE) and value→row→value round-trip tests](E03-T06-daos-and-roundtrip-tests.md) | M | E03-T03, E03-T05 |
| E03-T07 | [The single write path: commitReview one-transaction persist-before-republish + a thrown-step rollback unit test (test-first)](E03-T07-single-write-path-commit-review.md) | L | E03-T04, E03-T06 |
| E03-T08 | [Cold-start seedColdStart outer transaction (600+ cards, profile, cycle_config) all-or-nothing](E03-T08-cold-start-seed-transaction.md) | M | E03-T07 |
| E03-T09 | [Migration infrastructure: schemaVersion, committed JSON snapshot, stepByStep onUpgrade, and the release-blocking v(n−1) integrity_check fixture test (test-first)](E03-T09-migration-stepwise-and-fixture-test.md) | L | E03-T03 |
| E03-T10 | [Opt-in at-rest encryption: sqlite3mc toggle, flutter_secure_storage raw key, PRAGMA cipher liveness guard, wrong-key-vs-corruption mapping](E03-T10-optin-at-rest-encryption.md) | M | E03-T04 |

## Risks

- **A missing `await` inside `transaction(() async`** lets a query run after the transaction closes → silent data loss on the *sanad* audit trail. *Mitigation:* the `await` footgun is a release-blocking review-checklist item ([engineering 05 §3](../../docs/engineering/05-persistence-and-encryption.md)); the transaction unit (E03-T07) asserts all-or-nothing; un-awaited queries in transaction blocks are grep-audited.
- **A `DateTime` instant leaks into a scheduling-day column**, reintroducing the DST off-by-one that produces a wrong "next due." *Mitigation:* `due_at`/`last_review_at` are typed `CalendarDate` in `models` and `INTEGER` serial days in the schema; a `DateTime` named like a day is rejected; the round-trip test (E03-T06) asserts serial-day identity through E02's value type.
- **A future `UPDATE`/`DELETE` reaches `review_log`**, breaching append-only. *Mitigation:* the property is enforced by the *absence* of those DAO methods, reviewed in CI; the only bulk touch is export/erase (E17); a test asserts the DAO surface has no mutation path.
- **A botched migration on `review_log` is irreversible hifz-history loss.** *Mitigation:* guided `stepByStep` only; a shipped migration is never edited; every migration ships with the `integrity_check` fixture test before merge (E03-T09); `eraseDatabaseOnSchemaChange` is DEBUG-only and gated.
- **A silently-plaintext store that only *looks* encrypted** if `source: sqlite3mc` is not in effect. *Mitigation:* the `PRAGMA cipher;` liveness guard is promoted from debug example to a real release guard that refuses to open (E03-T10); a wrong key surfaces key-recovery, never "corrupted."
- **A Drift symbol escapes `data`** and re-couples the engine to a database, breaking determinism. *Mitigation:* DAOs return `models` value types only; the banned-import gate (E01) fails the build on any `package:drift`/`package:sqlite3` import outside `data`; round-trip tests run under plain `dart test` with no widget binding.

## References

- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/engineering/05-persistence-and-encryption.md — §1 (store & connection setup), §2 (schema), §3 (crash safety / single write path), §4 (migrations), §5 (opt-in at-rest encryption)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/engineering/01-architecture-overview.md — §1 (hard rules → structural mechanisms), §2 (layer model), §3 (module map), §4 (the single review write path), §6 (offline guarantee)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/PRD.md — C1, C2, C5, C6, R1, R2, R3; §7.7, §7.10, §7.12 (engine outputs persisted), §10 (data model / SQLite schema), §10.3 (append-only / computed-not-stored health), §11.3 (reference integrity), §17 (privacy)
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-add-persisted-model/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-add-drift-table-or-migration/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-define-service-boundary/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-write-dart-test/SKILL.md

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
