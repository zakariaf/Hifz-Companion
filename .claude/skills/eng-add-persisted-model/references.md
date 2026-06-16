# references — eng-add-persisted-model

The precise governing doc sections for adding a persisted record type and its DAO/repository surface in the Hifz Companion app. Each is a repo-relative path with the section and the one thing to take from it. Primary docs first, then supporting, then sibling skills.

## Primary — Persistence & encryption (the schema, the transaction, the migration)

- `docs/engineering/05-persistence-and-encryption.md` §2 (Schema) — the value type is a Drift table class with invariants in the schema: `STRICT` tables, `CHECK (... IN (...))` on enumerable columns (`track`, `grade`, `source`, `role`, `revelation`), range `CHECK`s (`d BETWEEN 1 AND 10`, `s >= 0`), `REFERENCES`/`ON DELETE CASCADE` foreign keys, query indices (`card_due ON card(profile_id, track, due_at)`), and the load-bearing `CHECK (track='UNMEMORIZED' OR due_at IS NOT NULL)`. Scheduling days are `CalendarDate` serial **integers** (`due_at`, `last_review_at`), event times are UTC; `review_log` is append-only; derived health is never stored; reference tables are read-only; `*_json` columns hold small decode-validated data only, never Quran/health facts.
- `docs/engineering/05-persistence-and-encryption.md` §3 (Crash safety) — read/write is one `db.transaction` per mutation, all-or-nothing with auto-rollback on throw; WAL + `synchronous = FULL` on the write connection; the canonical `commitReview` body (append `review_log`, upsert `card`, lazily insert `line_block`, bump `confusion_edge`); the **`await` footgun** ("All queries inside the transaction must be `await`-ed" — a missing `await` is release-blocking); persist-before-publish, never the reverse; the `seedColdStart` outer transaction for the 600+-card cold start.
- `docs/engineering/05-persistence-and-encryption.md` §1 (The store: Drift over SQLite) — the `@DriftDatabase` table list and the `data`-only connection setup; `PRAGMA foreign_keys = ON` re-asserted per connection (it is not persisted in the file); **"We refuse a Drift import outside `/data`"** — the `import_rules`/DCM banned-import gate keeps `package:drift`/`package:sqlite3` confined to one package, the same mechanism that bans networking imports.
- `docs/engineering/05-persistence-and-encryption.md` §4 (Migrations) — a new record/field is paired with a guided `stepByStep` migration: a `schemaVersion` bump, a committed `drift_schemas/` JSON snapshot (`drift_dev schema dump`), generated `.steps.dart` (`drift_dev make-migrations`), and a fixture test that migrates a populated v(n−1) DB and asserts content **and** `PRAGMA integrity_check`. A shipped migration is never edited; `eraseDatabaseOnSchemaChange` is DEBUG-only; backup restore does not replay SQL migrations.

## Primary — Coding standards (naming, units, immutability, errors)

- `docs/engineering/03-coding-standards.md` §1.1 (project-specific naming) — full dictionary words, no abbreviations (`stabilityDays` not `s`); units live in the name (`cycleCeilingDays`, `dailyBudgetMinutes`, `targetRetention`); `CalendarDate` (floating day: `dueAt`, `lastReviewedDay`) vs `DateTime` (instant: `reviewedAtInstant`, `reminderFireInstant`) marked by name **and** type — a `DateTime` named like a day is a review-blocking defect; sacred-domain transliteration one spelling per term (`mushaf`, `juz`, `hizb`, `surah`, `ayah`, `manzil`, `mutashabihat`, `riwayah`); booleans read as assertions (`isWeak`, `hasTeacherSignoff`); user-facing strings owned by the ARB files, never hardcoded.
- `docs/engineering/03-coding-standards.md` §5 (immutability, error handling, logging) — domain values are immutable (`final`, `const`, `copyWith`; closed sets as enums so invalid states are unrepresentable); **the engine is total — it never throws**; throwing is confined to I/O boundaries (`data` is one), each defining one sealed error type surfaced to the feature layer; no swallowed errors on write paths, typed `catch` (`on … catch`, never bare `catch (_)`); a sign-off acknowledged only after durable commit; no `print`/`debugPrint`/logging of user data; no `!`/`late` shortcut on persistence values.
- `docs/engineering/03-coding-standards.md` §6 (library privacy & the `engine/` purity rule) — `data` imports Drift/SQLite but no networking; the engine imports no Drift/Flutter/`dart:io`; default-private surface, `export` only the intended façade; the package graph is the audit artifact.
- `docs/engineering/03-coding-standards.md` §7.2 (path-scoped import bans) — the architecture gates (`avoid-banned-imports`) that keep Drift in `data` and networking in the one downloader module are correctness gates, never suppressible with `// ignore:`.

## Primary — Architecture (the boundary, the single write path)

- `docs/engineering/01-architecture-overview.md` §2 (Layer model) — Layer 0 `models` = immutable value types importing `dart:core`/`package:meta` only (bottom of the graph); Layer 2 `data` = Drift schema, DAOs, repositories, the single write path; the boundary that matters most runs between Layer 1 (pure engine) and Layer 2 (the Flutter/Drift shell).
- `docs/engineering/01-architecture-overview.md` §3.1 (Packages and allowed imports) — `models`: Foundation-equivalent only; `engine`: `models` only, no Drift, no I/O; `data`: `package:drift`/`dart:async`, no networking; `features`: may import `data` repositories, never a DAO's Drift types. The manifest is the audit evidence.
- `docs/engineering/01-architecture-overview.md` §4 (Unidirectional data flow) — the lifecycle of one review: engine computes the new immutable `Card` (today injected), the repository commits in **one WAL transaction (append `ReviewLog`, upsert `Card`) BEFORE republishing**; "We refuse 'republish then persist'"; "We refuse a second `due_at` computation anywhere" (one sink, one truth); immutability is the golden-test precondition.

## Supporting

- `docs/engineering/05-persistence-and-encryption.md` "At a glance" table — the one-line decisions: Drift 2.34.x on `NativeDatabase`, WAL + `synchronous=FULL`, one `db.transaction` per review, `PRAGMA foreign_keys = ON` in `beforeOpen`, guided `stepByStep` migrations, reference tables read-only and checksum-governed.
- `docs/engineering/03-coding-standards.md` §8.1 (PR checklist) — the Persistence & privacy block: every mutation flows through the single write path and persists transactionally before state republishes; no bare `catch`/swallowed write errors/`!`/`late` on persistence values; no `print`/logging of user data.

## Sibling skills

- **eng-create-riverpod-store** — the `Notifier`/`StreamProvider`/composition-root controller and the persist-then-republish command that *calls* the repository method this skill defines.
- **eng-create-package** — the `pubspec.yaml`/`resolution: workspace` member and the engine-purity / no-network / quran-isolation banned-import lints that contain the `data` package.
- **eng-define-service-boundary** — wiring the Drift DB handle and the injected `CalendarDate` clock as a `Provider` override at the composition root (not a global singleton or a `DateTime.now()` call).
- **domain-scheduling-engine-rules** — the pure `onReview`/trust-clamp arithmetic that produces the `Card` state this DAO persists; the engine that must stay Drift-free and total.
- **domain-grading-pipeline** — the `(grade, errorLines, source)` signal (sacred-text guard, source-confidence) that becomes a `review_log` row.
- **domain-calendars-and-hifzdate** — the `CalendarDate` serial-day semantics that the stored `due_at`/`last_review_at` integers carry; the injected "today".
- **domain-backup-format** — the `.hifzbackup` export/import and the only sanctioned bulk touch of the append-only `review_log` (set-union merge, one-tap erase).
- **domain-mushaf-text-integrity** / **domain-mutashabihat-system** — the read-only reference tables (`page`/`line`/`ayah`/`surah`/`mushaf`/`mutashabih_*`) this schema references but never writes.
- **eng-write-dart-test** — the value→row→value round-trip test under plain `dart test` and the migration-ladder fixture test with `PRAGMA integrity_check`.
- **eng-write-to-coding-standards** — the Effective Dart naming/units/immutability/sealed-error conventions on each declaration.
- **domain-adab-and-religious-integrity** — the no-gamification / servant-to-teacher / privacy / sect-neutrality non-negotiables this layer must never violate.
