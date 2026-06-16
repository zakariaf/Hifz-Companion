# E03-T09 — Migration infrastructure: schemaVersion, committed JSON snapshot, stepByStep onUpgrade, and the release-blocking v(n−1) integrity_check fixture test (test-first)

| | |
|---|---|
| **Epic** | [E03 — Models & Persistence](EPIC.md) |
| **Size** | L (≈2-4 days) |
| **Depends on** | E03-T03 |
| **Skills** | eng-add-drift-table-or-migration, eng-write-dart-test |

## Goal

The guided-migration infrastructure stands up on the `HifzDatabase` in `packages/data`: `schemaVersion = 1`, the committed `drift_schemas/` JSON snapshot (a `drift_dev schema dump` of v1), a `stepByStep` `onUpgrade` skeleton wired into `MigrationStrategy` (the documented append-only path with the never-edit-a-shipped-migration rule), and `eraseDatabaseOnSchemaChange` gated DEBUG-only so it can never reach a release artifact. Test-first: a release-blocking, parameterized migration fixture harness exists under `packages/data/test/migration/` that — for every version step `n−1 → n` — builds a **populated** `v(n−1)` database (a profile, cards, and at least one `review_log` row), migrates it through the real `stepByStep` strategy, validates the resulting schema against the committed snapshot, asserts every seeded row **survived**, and asserts `PRAGMA integrity_check == ok`. At v1 the harness is exercised against the `startAt(1)` baseline (schema-validation + integrity + content round-trip) so the very first real migration in a later epic plugs into a harness already proven; the `app_meta.schema_version` singleton is written by `onCreate` and the harness is the gate every future bump must pass. Restore does **not** replay these SQL migrations — the `.hifzbackup` import maps any supported payload version forward onto the current schema (E17), which this task documents but does not implement.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/05-persistence-and-encryption.md` §4 (Migrations) | The authoritative contract: all schema evolution is Drift's guided `stepByStep` with an integer `schemaVersion`, a committed per-version JSON schema snapshot, generated `.steps.dart` + test scaffolds, kept green in CI; **migrations are append-only — a shipped migration is never edited** (a fix is a new higher version that corrects forward); a botched migration on `review_log` is irreversible hifz-history loss; the migration runs inside a transaction so a failed upgrade rolls back; the workflow/CI-gate table (`schema dump` → `drift_schemas/`, `make-migrations` → `.steps.dart` + test scaffold, the fixture test that builds a populated `v(n−1)` DB / migrates / asserts content **and** `PRAGMA integrity_check`, `eraseDatabaseOnSchemaChange` DEBUG-only, "backup restore does not replay SQL migrations"); the pitfalls — refuse `eraseDatabaseOnSchemaChange` in any shipping build, refuse to `select`/`update` a not-yet-added column inside an older step, refuse to ship a migration without a passing `integrity_check` fixture test |
| `docs/engineering/05-persistence-and-encryption.md` §1 (the store) + §2 (schema) | The `@DriftDatabase` class `HifzDatabase` and its `MigrationStrategy` this task edits: `onCreate: (m) async => m.createAll()`, `beforeOpen` re-asserts `PRAGMA foreign_keys = ON;` (pragmas are per-connection, not persisted), and the v1 table set the snapshot freezes — the read-only reference tables (`page`/`line`/`ayah`/`surah`/`mushaf`/`mutashabih_*`) and the read-write user tables (`profile`/`card`/`line_block`/`review_log`/`confusion_edge`/`cycle_config`/`app_meta`); the `app_meta` `'schema_version'` singleton key |
| `docs/engineering/05-persistence-and-encryption.md` §3 (crash safety) | Why migration discipline is existential here: `review_log` is the append-only *sanad* audit trail; the migration is the **one** code path that touches every user's entire hifz history, so it carries the strongest test discipline — the fixture must prove a populated `review_log` survives byte-intact, not merely that the schema diff applied |
| `docs/engineering/01-architecture-overview.md` §2, §3 (layers / module map) | `package:drift`/`package:sqlite3` stay confined to `data`; the migration strategy, the snapshot tooling, and the fixture test all live in `data` — no Drift symbol crosses into `engine`/`features`/`quran`; the migration fixture is exercised at the unit tier, never a device journey |
| Skill `eng-add-drift-table-or-migration` (canonical pattern 8, 9, 10; `template.dart` block 2 + block 5) | Pattern 8 — "schema evolution is guided `stepByStep`, append-only, with a committed snapshot per version": bump `schemaVersion`, `drift_dev schema dump` → committed `drift_schemas/`, `drift_dev make-migrations` → `.steps.dart` + test scaffold, one typed `fromNToM` callback; a shipped migration is never edited; never `select`/`update` a not-yet-added column in an older step. Pattern 9 — "every migration ships with a release-blocking fixture test": populated `v(n−1)` → migrate → content survived **and** `PRAGMA integrity_check == ok`; `eraseDatabaseOnSchemaChange` DEBUG-only and gated. Pattern 10 — restore does not replay SQL migrations; backups map forward; the `app_meta.schema_version` singleton. `template.dart` block 2 is the `@DriftDatabase` `schemaVersion`/`stepByStep` skeleton + the `(a)–(d)` workflow comment to copy; block 5 is the `SchemaVerifier(GeneratedHelper())` / `startAt(n−1)` / `migrateAndValidate(db, n)` / `PRAGMA integrity_check == 'ok'` fixture-test scaffold to fill |
| Skill `eng-write-dart-test` (canonical pattern 1, 8, 9, 10, 11; `template.dart` migration-fixture scaffold) | Pattern 1 — the migration/DAO test lives at the cheapest tier (unit), not a widget pump or a device journey. Pattern 8 — the throwing-`HttpOverrides` offline guard is installed via the shared bootstrap so a stray network call fails loudly. Pattern 9 — the migration fixture runs the **real** Drift/SQLite stack at the unit tier (it needs `flutter_test` for `drift_dev/api/migrations.dart`'s `SchemaVerifier`, not `package:test`); no `pumpAndSettle`. Pattern 10 — coverage published, never a gate; assert behaviour (rows survived, `integrity_check == ok`), not lines. Pattern 11 — REUSE SPDX `GPL-3.0-or-later` header, full-word/unit-bearing names, typed `catch`, `dart format` clean. The `template.dart` migration-fixture scaffold is the file to instantiate |
| `docs/engineering/11-testing-strategy.md` §1 (test pyramid), §8 (CI jobs) | The migration fixture test is a **unit-tier** test that runs in CI job **(1)** the `fast` job (`analyze` + engine unit + property + widget + coverage) on every push — it is release-blocking but is **not** a golden (no `@Tags(['golden'])`, no pinned-OS golden job) and **not** one of the four `integration_test` journeys; it is deterministic and headless |
| `docs/PRD.md` §10.3 (append-only / computed-not-stored), §16 (one-tap erase), §17 (privacy) | §10.3 — `review_log` append-only and health computed-not-stored: the fixture preserves the audit trail and never resurrects a derived health column across a migration; §16 — one-tap erase / export are the only sanctioned bulk touch, owned by E17, not this migration path; §17 — the fixture logs no user data and reaches no network |
| CLAIMS ids | **None.** Migration infrastructure renders no on-screen number, date, or copy — it evolves the schema and proves the audit trail survives. No user-facing string, scheduling number, or methodology claim originates here; nothing ships to the science screen from this task |
| Siblings: E03-T03, E03-T04, E03-T07, E03-T08, E17 | **E03-T03** owns the v1 `STRICT`/`CHECK`/FK/index user table classes (and E03-T02 the reference tables) whose definitions the committed v1 snapshot freezes and whose constraints `PRAGMA integrity_check` and the schema-validation step verify survive a migration — this is the hard dependency. E03-T04 owns the WAL/`synchronous=FULL`/`foreign_keys=ON` pragmas re-asserted in `beforeOpen` (the migration runs under them). E03-T07 (`commitReview`) and E03-T08 (`seedColdStart`) are the write paths whose rows the fixture seeds into the `v(n−1)` DB to prove they survive an upgrade. **E17** owns the `.hifzbackup` import that maps forward and never replays these SQL migrations — referenced here, implemented there |

## Implementation notes

**TEST-FIRST (correctness-critical).** Author the migration fixture harness in `packages/data/test/migration/` **before** declaring the infrastructure complete: the harness — `startAt(n−1)` → seed a profile + cards + a `review_log` row → `migrateAndValidate(db, n)` → assert content survived → assert `PRAGMA integrity_check == 'ok'` — must compile and run green against the v1 baseline (`startAt(1)`, schema-validation + integrity + content round-trip) as the committed gate. This is the one code path that touches every user's whole hifz history; the gate that proves it exists and passes before any real `fromNToM` step is written is the entire point. A later epic adding a column writes its `from1To2` step **only** after this harness, extended to that step, is red then green.

1. **Files (all in `data` — the only package importing `drift`/`sqlite3`):**
   - `packages/data/lib/src/database/hifz_database.dart` (or wherever E03-T03 placed the `@DriftDatabase` class) — extend its `MigrationStrategy` with `onUpgrade: stepByStep(...)` and the `(a)–(d)` workflow doc-comment; `schemaVersion => 1`.
   - `packages/data/drift_schemas/drift_schema_v1.json` — the committed snapshot, produced by `dart run drift_dev schema dump`, never hand-edited.
   - `packages/data/test/migration/schema/` — the generated `drift_dev make-migrations` output (`schema.dart` + per-version `SchemaVersion` fixtures), committed.
   - `packages/data/test/migration/migration_test.dart` — the parameterized fixture test.

2. **`schemaVersion` and the `stepByStep` skeleton.** In the `@DriftDatabase` class set `int get schemaVersion => 1;` and wire the strategy exactly as engineering 05 §4 / §1:
   ```dart
   // packages/data — the only package that imports drift.
   @override
   int get schemaVersion => 1;

   @override
   MigrationStrategy get migration => MigrationStrategy(
         onCreate: (m) async {
           await m.createAll();
           // The schema_version singleton is written at create-time so a future
           // forward-mapping restore (E17) can read what shape this store holds.
           await into(appMeta).insert(
             AppMetaCompanion.insert(key: 'schema_version', value: '1'),
           );
         },
         // No version bumps yet: stepByStep dispatches future from(n)To(n+1) callbacks.
         // A SHIPPED migration is NEVER edited — a fix is a NEW higher schemaVersion
         // that corrects forward (§4). Never select/update a not-yet-added column in
         // an older step. Append the typed callback here on the next bump:
         //   onUpgrade: stepByStep(
         //     from1To2: (m, schema) async { await m.createTable(schema.<new>); },
         //   ),
         onUpgrade: stepByStep(),
         beforeOpen: (details) async {
           // Pragmas are per-connection, not persisted — re-assert on every open (§1).
           await customStatement('PRAGMA foreign_keys = ON;');
         },
       );
   ```
   Keep `onUpgrade: stepByStep()` as the empty-but-wired skeleton (the type is `OnUpgrade`); the first real callback is a later epic's job. Do **not** invent a `from1To2` here — there is no v2 to migrate to, and a step against a not-yet-existing snapshot would be dead, untestable code.

3. **The committed v1 snapshot is the diff oracle.** Run `dart run drift_dev schema dump packages/data/drift_schemas/` (or the project's wrapper) to write `drift_schema_v1.json`, then `dart run drift_dev make-migrations` to generate the test schema fixtures under `test/migration/schema/`. Commit both. The snapshot freezes the exact v1 DDL E03-T02/E03-T03 authored — every `STRICT`, every `CHECK`, every FK, every index, the `CHECK (track='UNMEMORIZED' OR due_at IS NOT NULL)` invariant, the `confusion_edge` `ayah_a < ayah_b` ordering. A future schema change that forgets to dump a new snapshot is caught because `migrateAndValidate` validates the post-migration schema against the committed snapshot for the target version. Regenerating the snapshot is an explicit, reviewed step in the PR diff — never auto-blessed in CI.

4. **`eraseDatabaseOnSchemaChange` is DEBUG-only, gated.** It is a dev convenience that, shipped, would wipe real hifz history. Gate it so it can never reach a release build — e.g.:
   ```dart
   @override
   bool get eraseDatabaseOnSchemaChange => kDebugMode; // foundation.kDebugMode
   ```
   (or an equivalent assert-gated flag). It must be `false` in any release/profile artifact; a grep/review confirms it is never set unconditionally `true` and never appears without the debug gate.

5. **The fixture harness — parameterized over every step, run at v1 today (TEST-FIRST).** Instantiate the `eng-add-drift-table-or-migration` / `eng-write-dart-test` migration-fixture scaffold. It uses `drift_dev/api/migrations.dart`'s `SchemaVerifier(GeneratedHelper())`, `verifier.startAt(n−1)` to obtain a populated old-version connection, `verifier.migrateAndValidate(db, n)` to migrate **and** validate the resulting schema against the committed snapshot, then content-survival assertions and `PRAGMA integrity_check`:
   ```dart
   // packages/data/test/migration/migration_test.dart
   void main() {
     late SchemaVerifier verifier;
     setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

     test('v1 baseline: populated store validates, content survives, integrity_check ok',
         () async {
       final connection = await verifier.startAt(1);
       final db = HifzDatabase(connection);
       // Seed representative rows — a profile, cards, and at least one review_log row
       // (the append-only sanad audit trail is the highest-stakes content to preserve).
       // ... insert profile, cards, a review_log row, a cycle_config ...

       await verifier.migrateAndValidate(db, 1); // self-identity baseline today

       // CONTENT survived: query the seeded review_log/card rows back, intact.
       // ... expect(reviewLogRowBack, equals(seededRow)); ...

       final integrity = await db.customSelect('PRAGMA integrity_check;').get();
       expect(integrity.single.data.values.first, 'ok');

       await db.close();
     });
     // Next epic that bumps to v2 adds 'v1 -> v2 preserves content and integrity_check is ok'
     // here — startAt(1), seed, migrateAndValidate(db, 2), assert survival + integrity.
   }
   ```
   The seeded `review_log` row is the load-bearing assertion: prove the *sanad* audit trail survives byte-intact across the migration, not merely that the schema applied. Each future version step adds one `test(...)` of identical shape; the harness shape never changes.

6. **Restore does not replay these migrations — document, don't implement.** A doc-comment at the `MigrationStrategy` and in the test header records that the `.hifzbackup` import (E17) is version-stamped and maps any supported payload forward onto the **current** schema — it never runs a SQL upgrade on the failure-intolerant import flow, and an older backup must always still restore. This task ships the live-DB migration path only; the backup-format forward mapping is E17 / `domain-backup-format`.

7. **No reference-table write, no derived health, no second source of truth.** The migration path writes no reference (`page`/`line`/`ayah`/`surah`/`mushaf`/`mutashabih_*`) table — those are read-only by construction and re-supplied by the checksum-governed asset pack (E05), never carried in a SQL migration. A future migration never adds a stored derived-health/`R` column (computed-on-read, §2 pattern 12) and never widens a `*_json` column into Quran text or a health fact. The fixture seeds and re-reads only user-table rows.

8. **Pitfalls to avoid:** editing a shipped migration step (rewrites history for existing installs — irreversible user-data loss; a fix is always a new higher `schemaVersion`); skipping the committed snapshot on a bump (the verifier has no old schema to diff against); `select`/`update`ing a not-yet-added column inside an older step; shipping a migration with no passing `integrity_check` fixture (an untested migration on `review_log` is an unacceptable risk to the *sanad* trail); leaving `eraseDatabaseOnSchemaChange` ungated or `true` in a release build (wipes real hifz history); inventing a phantom `from1To2` against a non-existent v2 snapshot (dead, untestable code); reaching for a raw `customStatement` table rebuild instead of the guided `stepByStep` helpers; importing `drift`/`sqlite3` or the `drift_dev` migration API outside `data`/its tests; asserting on lines instead of behaviour (rows-survived + `integrity_check == ok`).

## Acceptance criteria

- [ ] `HifzDatabase` declares `schemaVersion => 1` and a `MigrationStrategy` with `onCreate: m.createAll()` (plus the `app_meta` `'schema_version'='1'` singleton insert), `onUpgrade: stepByStep()` wired as the empty-but-typed skeleton, and `beforeOpen` re-asserting `PRAGMA foreign_keys = ON;` — all in `packages/data`, no Drift symbol crossing the `data` boundary.
- [ ] The `(a)–(d)` append-only migration workflow (`schema dump` → committed `drift_schemas/` snapshot → `make-migrations` → one typed `fromNToM` callback) is documented at the `MigrationStrategy` as a doc-comment, including "a shipped migration is never edited — a fix is a new higher version that corrects forward."
- [ ] `packages/data/drift_schemas/drift_schema_v1.json` is committed (a real `drift_dev schema dump` of the E03-T02/E03-T03 v1 schema), and the `drift_dev make-migrations` schema fixtures are committed under `packages/data/test/migration/schema/`; neither is hand-edited.
- [ ] `eraseDatabaseOnSchemaChange` is gated DEBUG-only (`kDebugMode`/assert-gated) and is `false` in any release/profile artifact — never unconditionally `true`, never present without the debug gate (verifiable by reading the override + a grep).
- [ ] The fixture harness `packages/data/test/migration/migration_test.dart` exists, uses `SchemaVerifier(GeneratedHelper())` / `startAt(n−1)` / `migrateAndValidate(db, n)`, seeds a populated store (a profile, cards, **and** at least one `review_log` row + a `cycle_config`), asserts each seeded row survived, and asserts `PRAGMA integrity_check` returns `'ok'`.
- [ ] At v1 the harness runs green against the `startAt(1)` baseline (schema-validation + content round-trip + integrity), committed; the file documents that each future version bump adds one identically-shaped `test(...)` (`startAt(n−1)` → seed → `migrateAndValidate(db, n)` → survival + integrity) — the harness shape never changes.
- [ ] The migration path writes no reference table and adds no derived-health/`R` column; a doc-comment records that restore (E17) maps forward and does not replay these SQL migrations.
- [ ] The fixture test is unit-tier in CI job (1) the `fast` job — not a golden (`@Tags(['golden'])` absent), not an `integration_test` journey; it installs the throwing-`HttpOverrides` offline guard; `dart analyze --fatal-infos` and `dart format --set-exit-if-changed` clean; CI green.

## Tests

The migration fixture is the deliverable's centre and is authored **first** (red against the not-yet-wired strategy, then green once `schemaVersion`/`stepByStep`/snapshot are in place). It lives in `packages/data/test/migration/` and runs under `flutter test` (it needs the `drift_dev/api/migrations.dart` `SchemaVerifier`, so it is `flutter_test`, not `package:test`) against the **real** Drift/SQLite stack at the unit tier — no widget binding pump, no `pumpAndSettle`, no device. Each file carries the REUSE SPDX `GPL-3.0-or-later` header, full-word/unit-bearing names, typed `catch`, and asserts behaviour (rows survived, schema validated, `integrity_check == ok`) not lines. The shared throwing-`HttpOverrides` offline bootstrap is installed so any stray network call fails loudly.

- `packages/data/test/migration/migration_test.dart`
  - **v1 baseline — populated store migrates, content survives, integrity_check ok (written first):** `startAt(1)` → seed a `profile`, a handful of `card` rows (one per `track`, including the memorized-card `due_at`-non-null invariant and an `UNMEMORIZED` card), **at least one `review_log` row** (the *sanad* audit trail), a `cycle_config`, and a `confusion_edge` (`ayah_a < ayah_b`) → `migrateAndValidate(db, 1)` (self-identity validation against the committed v1 snapshot) → read every seeded row back and `expect` it byte-equal → `expect(PRAGMA integrity_check == 'ok')`. This is the gate that proves the harness works before any real step exists.
  - **`review_log` survives intact:** after migration, the seeded `review_log` row's `grade`/`source`/`reviewed_at`/`elapsed_days`/`error_lines_json` are unchanged and no row was dropped or mutated — the append-only audit trail is preserved across the migration path.
  - **Schema validation catches a missing snapshot/diff:** `migrateAndValidate` validates the post-migration schema against the committed snapshot; a deliberately stale/absent snapshot fails the verifier (asserted via the harness's own failure mode in review, documented so a future bump that forgets `schema dump` is caught).
  - **Forward-extension template (documented, not yet executed):** the file documents and stubs the shape a v2 case will take — `startAt(1)` → seed → `migrateAndValidate(db, 2)` → assert the seeded rows survived the `from1To2` step **and** `PRAGMA integrity_check == 'ok'` — so the next epic adds a step against a proven harness.
- **`app_meta.schema_version` singleton:** a small unit asserts a freshly `createAll`-ed store carries `schema_version = '1'` in `app_meta` (the forward-mapping anchor restore reads).
- **`eraseDatabaseOnSchemaChange` gating:** asserted by review + grep that the override is `kDebugMode`/assert-gated and never unconditionally `true` (a release build must never erase on schema change).

No golden, widget, or `integration_test` is in scope — this is a `data`-tier migration/DAO unit. Goldens and the four device journeys belong to the feature epics; the cold-start seeding and `commitReview` write paths whose rows this fixture seeds are E03-T08 / E03-T07.

## Definition of Done

- [ ] All acceptance criteria met; `flutter test packages/data/test/migration/` green; the v1-baseline fixture was committed red (against the not-yet-wired `MigrationStrategy`) before the infrastructure, per test-first; `dart analyze --fatal-infos` and `dart format --set-exit-if-changed` clean; CI green in the `fast` job.
- [ ] **Migration discipline (non-negotiable)**: migrations are guided `stepByStep` with a committed JSON snapshot per version and are append-only (a shipped migration is never edited — a fix is a new higher version); the release-blocking fixture migrates a populated `v(n−1)` DB and asserts content survived **and** `PRAGMA integrity_check == ok`; `eraseDatabaseOnSchemaChange` is DEBUG-only and gated (engineering 05 §4).
- [ ] **Offline / no-network**: the migration code and fixture import no networking package and no `dart:io HttpClient`; the test installs the throwing `HttpOverrides`; no telemetry, no account, no per-user data leaves the device; the fixture logs no user data (§17).
- [ ] **No-AI / no-microphone**: the migration path references no audio, microphone, recognizer, or ML/AI artifact — it evolves a schema and preserves an append-only audit trail of `(grade, error_lines, source)` rows.
- [ ] **Quran text fidelity**: the migration writes no reference (`page`/`line`/`ayah`/`surah`/`mushaf`/`mutashabih_*`) table — those are read-only by construction and re-supplied by the checksum-governed asset pack (E05); no migration step re-typesets or alters the sacred text, and the fixture never reconstructs Quran text from a `*_json` column (R1).
- [ ] **RTL + fa/ckb/ar strings**: no user-facing string is authored in the migration infrastructure — it carries only schema/value data; any restore/migration-failure copy a feature later shows lives in `l10n` (`ar` template, `fa`/`ckb`), RTL via `Directionality`, owned by the feature/backup epics.
- [ ] **Accessibility**: N/A by construction (no widget, no rendered surface) — there is no migration UI in this task; any user-visible recovery state is the owning feature's responsibility.
- [ ] **Sect-neutral adab**: the schema and migration encode no streak/badge/score, no "safe to drop" flag, no fiqh ruling, no tafsīr/translation, no sect/madhhab marker; the `review_log` the fixture preserves is a *sanad* audit trail, never a gamified tally; no migration ever silently drops a hifz-history row.
- [ ] **Deterministic tests**: every test is reproducible across machines and timezones — days are literal `CalendarDate` serial integers and instants explicit UTC `DateTime`s (no `DateTime.now()`, no wall clock), assertions are behaviour (rows-survived + schema-validated + `integrity_check == ok`) with full-word names and typed `catch`, and each test file carries the REUSE SPDX `GPL-3.0-or-later` header.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
