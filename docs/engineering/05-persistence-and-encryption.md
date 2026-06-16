# 05 — Persistence & Encryption

This document specifies Hifz Companion's local store: the Drift-over-SQLite stack and why it was chosen; the concrete schema for the PRD's data model ([PRD §10](../PRD.md)); the crash-safety mechanics that make "persist on every grade" durable across power loss; the transactional write contract that keeps every review all-or-nothing; the guided, testable migration strategy; and the **optional, opt-in** at-rest encryption path that ships with zero cost when off. It applies the *Decision log: Persistence & at-rest encryption* entry (README decision 3) and is grounded in the evidence dossier [research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md).

The boundaries are deliberate. The pure scheduling math lives in the engine and never touches this layer ([06-scheduling-engine.md](06-scheduling-engine.md)); date and calendar semantics — what a stored "due date" *means* — are owned by [07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md); the Quran reference data, its checksum governance, and its read-only nature are owned by [08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md) and [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md); and the WAL-aware export/import format that turns this store into a portable file is owned by [10-backup-format.md](10-backup-format.md). This doc owns the live database only.

One framing rule governs everything below, from the README's outranking rules and [PRD §7.12, §10.3](../PRD.md): **the `review_log` is an append-only audit trail and a teacher sign-off is a *sanad* act.** A lost write, a half-applied review, or a silently mutated log entry is not a bug — it is a breach of the app's covenant that "nothing decays silently." Crash-safety and transactional integrity are therefore the *mandatory* floor; at-rest encryption is honest defense-in-depth, scoped to a real but narrower threat.

## At a glance

| Concern | Decision |
|---|---|
| Library | **Drift 2.34.x** (MIT) on `NativeDatabase` (FFI `package:sqlite3` v3), confined to `/data` ([Drift on pub.dev](https://pub.dev/packages/drift)) |
| Journal mode | **WAL**, `synchronous=FULL` on the write connection — durable across power loss ([SQLite: WAL](https://sqlite.org/wal.html)) |
| Write unit | **One `db.transaction` per review** — atomic, auto-rollback on throw ([Drift: Transactions](https://drift.simonbinder.eu/dart_api/transactions/)) |
| Foreign keys | `PRAGMA foreign_keys = ON` in `beforeOpen` (SQLite leaves them off by default) ([Drift: Migrations](https://drift.simonbinder.eu/Migrations/)) |
| Migrations | Guided `stepByStep` migrations; committed per-version JSON schema snapshots; generated migration tests green in CI ([Drift: Migrations](https://drift.simonbinder.eu/Migrations/)) |
| At-rest encryption | **Optional / opt-in** build-hook toggle (`hooks: user_defines: sqlite3: source: sqlite3mc`, ChaCha20-Poly1305); mandatory floor is WAL + transactions ([Drift: Encryption](https://drift.simonbinder.eu/platforms/encryption/)) |
| Key storage | Random 32-byte raw key in `flutter_secure_storage` (Keychain / Android KeyStore), `first_unlock_this_device`, non-syncing ([flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)) |
| Reference tables | Read-only, checksum-governed, never written at runtime ([PRD §11.3](../PRD.md)) |

---

## 1. The store: Drift over SQLite

### Decision

The local store is **Drift 2.34.x on `NativeDatabase`** (Drift's FFI backend over `package:sqlite3` v3), confined to the `/data` package and reachable only through DAOs that map rows to plain value types — no Drift symbol crosses into `/engine`, `/features`, or `/quran` (*Decision log: Persistence & at-rest encryption*; module boundaries in [02-project-structure.md](02-project-structure.md)). The pure-Dart engine package ([06-scheduling-engine.md](06-scheduling-engine.md)) never imports Drift; `/data` feeds it plain state and persists the result it returns.

### Rationale

- Drift is "a reactive library to store relational data in Dart and Flutter applications," MIT-licensed, built on SQLite, with compile-time-checked queries, generated DAOs, auto-updating result streams, transactions, and a first-class migration system ([Drift on pub.dev](https://pub.dev/packages/drift); [Drift docs](https://drift.simonbinder.eu/)). For a free, open-source *ṣadaqah* project an MIT dependency the community can audit, with no proprietary engine, matches the README's auditability value.
- **Compile-time query checking is correctness, not convenience.** The PRD schema ([§10](../PRD.md)) is large and relational; a mistyped column in a hand-rolled `sqflite` string query fails only at runtime, on a user's device, after a write has already gone wrong. Drift's code generator catches schema/query mismatches at build time ([Drift docs](https://drift.simonbinder.eu/)).
- **The `NativeDatabase` (FFI) backend, not the platform-channel `sqflite` backend.** Drift separates the database definition from the execution backend; `NativeDatabase` runs SQLite in-process over FFI, which gives the native concurrency model WAL depends on (readers and a writer proceeding concurrently — §3) and the single-source build-hook path to optional encryption (§5), instead of a second native database dependency. The research dossier rejects the `sqflite_sqlcipher`/`encrypted_drift` route for exactly this reason ([research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §9).
- **The boundary keeps determinism testable.** Because Drift lives only in `/data` and the engine is pure Dart with zero I/O, the FSRS-style math is golden- and property-tested without a database, preserving the [PRD §7.12](../PRD.md) "identical inputs → identical schedule" guarantee ([11-testing-strategy.md](11-testing-strategy.md)).

### Specification

The store opens with a single long-lived connection per process for the app's lifetime — SQLite key-derivation and cipher setup (if encryption is on) cost is paid once at open, never per write. The connection configuration, applied in Drift's `setup`/`beforeOpen` hooks, is fixed:

```dart
// /data — the only package that imports drift
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'hifz.sqlite'));

    return NativeDatabase.createInBackground(
      file,
      // setup runs on the raw sqlite3 handle BEFORE drift touches the DB.
      setup: (raw) {
        // (encryption key is set here when the opt-in cipher build is active — §5)
        raw.execute('PRAGMA journal_mode = WAL;');   // crash-safe append-only journal — §3
        raw.execute('PRAGMA synchronous = FULL;');   // durable across power loss — §3
        raw.execute('PRAGMA foreign_keys = ON;');    // SQLite leaves FKs OFF by default
        raw.execute('PRAGMA busy_timeout = 5000;');  // wait, don't throw, on brief lock contention
      },
    );
  });
}

@DriftDatabase(
  tables: [
    // user (read-write)
    Profiles, Cards, LineBlocks, ReviewLog, ConfusionEdges, CycleConfigs, AppMeta,
    // reference (read-only — §2)
    Pages, Lines, Ayat, Surahs, Mushafs, MutashabihGroups, MutashabihMembers,
  ],
)
class HifzDatabase extends _$HifzDatabase {
  HifzDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        // beforeOpen also re-asserts pragmas, since they are per-connection, not persisted.
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
          assert(await _foreignKeysAreOn());
        },
      );
}
```

`PRAGMA foreign_keys` is per-connection and **not** persisted in the database file; it must be re-issued on every open, and Drift's own migration docs flag that SQLite leaves FK enforcement off unless you turn it on ([Drift: Migrations](https://drift.simonbinder.eu/Migrations/)). The profile/page foreign keys in §2 are load-bearing referential guarantees, not decoration, so this pragma is asserted at startup.

### Pitfalls / what we refuse

- **We refuse a Drift import outside `/data`.** A CI `import_rules`/DCM banned-import gate forbids `package:drift` and `package:sqlite3` anywhere except `/data` (the same mechanism that bans networking imports — *Decision log: No networking beyond asset download*). A feature reaching for a raw query is a layering break that defeats the determinism boundary.
- **We refuse the `sqflite`/`sqflite_sqlcipher` backend.** It reintroduces a second native database dependency and the native-link coupling the `sqlite3` v3 build-hook model was created to retire ([research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §9).
- **We do not forget that pragmas are per-connection.** `foreign_keys`, `synchronous`, and the cipher key must be set in `setup`/`beforeOpen` on every open; a value set once and assumed persistent is a silent correctness hole.

---

## 2. Schema

### Decision

The schema is the PRD §10 data model, split into **read-only reference tables** (the fixed Quran structure and the scholar-reviewed mutashābihāt dataset, governed by checksums — never written at runtime) and **read-write user tables** (per-profile cards, the append-only review log, and configuration). The schema is authored as Drift table classes with explicit `CHECK` constraints, foreign keys, and indices encoded in the table definitions so the invariants are enforced by SQLite, not by application code.

### Rationale

- **Reference data is read-only because the Quran is immutable.** The 604-page structure, line geometry, ayah refs, surah metadata, and muṣḥaf descriptor come from the bundled, checksum-verified asset pack; the app "never recomputes" the hierarchy ([PRD §6.1, §11.3](../PRD.md)). Writing to these tables at runtime is forbidden by construction (no DAO exposes a write to them), upholding the README's first outranking rule.
- **`review_log` is append-only** ([PRD §10.3](../PRD.md)): it is the trustworthy audit trail and the *sanad*-respecting record of teacher sign-offs, "never updated or deleted by normal flows (export/erase only)." No DAO exposes an `UPDATE` or `DELETE` against it; the only sanctioned bulk touch is backup/restore ([10-backup-format.md](10-backup-format.md)).
- **Constraints live in the schema, not in Dart.** Enumerable columns (`track`, `grade`, `source`, `role`) are constrained with `CHECK (... IN (...))`; ranges (`d BETWEEN 1 AND 10`) are `CHECK`ed; referential integrity is enforced by foreign keys (turned on per §1). This makes a corrupt row unrepresentable at the storage layer rather than relying on every call site to validate. (CycleVault uses `STRICT` tables for the same reason; SQLite `STRICT` is available and is applied here where a column should never silently coerce.)
- **No derived state is stored as a second source of truth.** Per-juz / per-ḥizb health roll-ups are **computed from `card` retrievability**, not persisted ([PRD §10.3](../PRD.md)); the engine recomputes them, so there is one authority. This mirrors the PRD rule that strength roll-ups use a min-leaning aggregate and are never a stored authority.

### Specification

Timestamps that are true instants (a review's wall-clock moment) are stored **UTC** ([PRD §10.3](../PRD.md)); scheduling *days* (`due_at`, `last_review_at` as a scheduling unit) are stored as the `CalendarDate` serial-day integer owned by [07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md) — never as a `DateTime` instant, foreclosing the DST off-by-one class. The SQL below is the v1 schema (`schemaVersion = 1`), shown as DDL for auditability; the Drift table classes generate exactly this.

```sql
-- ============================================================
-- REFERENCE TABLES (read-only; bundled, checksum-governed — §11.3, R1)
-- Never written at runtime; no DAO exposes a mutation.
-- ============================================================
CREATE TABLE mushaf (
  mushaf_id     TEXT PRIMARY KEY,
  riwayah       TEXT NOT NULL,                 -- e.g. 'hafs_an_asim'
  name          TEXT NOT NULL,                 -- 'Madani 15-line'
  line_count    INTEGER NOT NULL,              -- 15
  page_count    INTEGER NOT NULL,              -- 604
  font_family   TEXT NOT NULL,
  checksum_sha256 TEXT NOT NULL                -- pinned; verified against the asset manifest (§09)
) STRICT;

CREATE TABLE surah (
  surah_id      INTEGER PRIMARY KEY CHECK (surah_id BETWEEN 1 AND 114),
  name_ar       TEXT NOT NULL,
  revelation    TEXT NOT NULL CHECK (revelation IN ('meccan','medinan')),
  ayah_count    INTEGER NOT NULL CHECK (ayah_count > 0),
  bismillah_pre INTEGER NOT NULL CHECK (bismillah_pre IN (0,1))
) STRICT;

CREATE TABLE page (
  page_id       INTEGER PRIMARY KEY CHECK (page_id BETWEEN 1 AND 604),
  juz           INTEGER NOT NULL CHECK (juz BETWEEN 1 AND 30),
  hizb          INTEGER NOT NULL CHECK (hizb BETWEEN 1 AND 60),
  rub           INTEGER NOT NULL CHECK (rub BETWEEN 1 AND 240),
  surah_start   INTEGER NOT NULL REFERENCES surah(surah_id),
  ayah_start    INTEGER NOT NULL,
  surah_end     INTEGER NOT NULL REFERENCES surah(surah_id),
  ayah_end      INTEGER NOT NULL,
  line_count    INTEGER NOT NULL,
  qpc_font_name TEXT NOT NULL                  -- this page's dedicated glyph font (§08)
) STRICT;

CREATE TABLE line (
  line_id       INTEGER PRIMARY KEY,
  page_id       INTEGER NOT NULL REFERENCES page(page_id),
  line_no       INTEGER NOT NULL CHECK (line_no BETWEEN 1 AND 15),
  line_type     TEXT NOT NULL CHECK (line_type IN ('ayah','surah_header','basmala')),
  ayah_refs_json TEXT NOT NULL,                -- which ayāt occupy this line
  text_glyph_ref TEXT NOT NULL                 -- glyph codes; never parsed as real Arabic text (§08)
) STRICT;
CREATE INDEX line_by_page ON line(page_id, line_no);

CREATE TABLE ayah (
  ayah_id       TEXT PRIMARY KEY,              -- 's:a', e.g. '2:255'
  surah         INTEGER NOT NULL REFERENCES surah(surah_id),
  ayah          INTEGER NOT NULL,
  page_id       INTEGER NOT NULL REFERENCES page(page_id),
  line_refs_json TEXT NOT NULL,
  sajda         INTEGER NOT NULL CHECK (sajda IN (0,1))
) STRICT;
CREATE INDEX ayah_by_page ON ayah(page_id);

-- Mutashābihāt: scholar-reviewed, objective wording only (R4)
CREATE TABLE mutashabih_group (
  group_id      TEXT PRIMARY KEY,
  type          TEXT NOT NULL CHECK (type IN ('identical','near_identical','structural')),
  note_key      TEXT                           -- localizable note resource key
) STRICT;

CREATE TABLE mutashabih_member (
  group_id      TEXT NOT NULL REFERENCES mutashabih_group(group_id),
  ayah_id       TEXT NOT NULL REFERENCES ayah(ayah_id),
  distinguishing_word_index_json TEXT,
  PRIMARY KEY (group_id, ayah_id)
) STRICT;

-- ============================================================
-- USER TABLES (read-write; per profile)
-- ============================================================
CREATE TABLE profile (
  profile_id    TEXT PRIMARY KEY,              -- UUID
  display_name  TEXT NOT NULL,                 -- the only "PII": a typed name (PRD §17)
  role          TEXT NOT NULL CHECK (role IN ('self','student','child')),
  locale        TEXT NOT NULL CHECK (locale IN ('ar','fa','ckb')),
  mushaf_id     TEXT NOT NULL REFERENCES mushaf(mushaf_id),
  created_at    TEXT NOT NULL,                 -- UTC ISO-8601 instant
  settings_json TEXT                           -- Codable-validated; never health/Quran facts
) STRICT;

CREATE TABLE card (
  profile_id      TEXT NOT NULL REFERENCES profile(profile_id) ON DELETE CASCADE,
  page_id         INTEGER NOT NULL REFERENCES page(page_id),
  track           TEXT NOT NULL CHECK (track IN ('NEW','NEAR','FAR','UNMEMORIZED')),
  d               REAL NOT NULL CHECK (d BETWEEN 1 AND 10),     -- difficulty
  s               REAL NOT NULL CHECK (s >= 0),                 -- stability (days)
  last_review_at  INTEGER,                                     -- CalendarDate serial day (NULL if never)
  due_at          INTEGER,                                     -- CalendarDate serial day; non-null once memorized
  reps            INTEGER NOT NULL DEFAULT 0 CHECK (reps >= 0),
  lapses          INTEGER NOT NULL DEFAULT 0 CHECK (lapses >= 0),
  weak_flag       INTEGER NOT NULL DEFAULT 0 CHECK (weak_flag IN (0,1)),
  signoffs        INTEGER NOT NULL DEFAULT 0 CHECK (signoffs >= 0),
  manual_lock     INTEGER NOT NULL DEFAULT 0 CHECK (manual_lock IN (0,1)),
  prayer_critical INTEGER NOT NULL DEFAULT 0 CHECK (prayer_critical IN (0,1)),
  enabled         INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0,1)),
  -- Engine invariant (PRD §7.12), defended at the storage layer:
  -- a memorized card's due_at never exceeds its cycle ceiling. The clamp is the
  -- engine's job; this CHECK guarantees no row can ever encode a non-memorized
  -- card with a due date or a negative stability.
  CHECK (track = 'UNMEMORIZED' OR due_at IS NOT NULL),
  PRIMARY KEY (profile_id, page_id)
) STRICT;
CREATE INDEX card_due ON card(profile_id, track, due_at);  -- buildToday() scans due FAR/NEAR cards

CREATE TABLE line_block (                       -- created LAZILY only for repeatedly-lapsing pages
  block_id     TEXT PRIMARY KEY,                -- UUID
  profile_id   TEXT NOT NULL REFERENCES profile(profile_id) ON DELETE CASCADE,
  page_id      INTEGER NOT NULL REFERENCES page(page_id),
  line_start   INTEGER NOT NULL CHECK (line_start BETWEEN 1 AND 15),
  line_end     INTEGER NOT NULL CHECK (line_end BETWEEN line_start AND 15),
  error_count  INTEGER NOT NULL DEFAULT 0 CHECK (error_count >= 0)
) STRICT;
CREATE INDEX line_block_by_card ON line_block(profile_id, page_id);

-- APPEND-ONLY audit trail (PRD §10.3): no DAO exposes UPDATE or DELETE.
CREATE TABLE review_log (
  log_id          TEXT PRIMARY KEY,            -- UUID
  profile_id      TEXT NOT NULL REFERENCES profile(profile_id) ON DELETE CASCADE,
  page_id         INTEGER NOT NULL REFERENCES page(page_id),
  reviewed_at     TEXT NOT NULL,               -- UTC instant (the event time)
  track_at_review TEXT NOT NULL CHECK (track_at_review IN ('NEW','NEAR','FAR','UNMEMORIZED')),
  grade           TEXT NOT NULL CHECK (grade IN ('again','hard','good','easy')),
  error_lines_json TEXT,                        -- stumble line indices — the highest-value signal
  elapsed_days    INTEGER NOT NULL,            -- CalendarDate-serial delta fed to the curve
  r_predicted     REAL,
  s_before        REAL, s_after REAL,
  d_before        REAL, d_after REAL,
  source          TEXT NOT NULL CHECK (source IN ('self','teacher')),
  teacher_label   TEXT                          -- optional; the local sanad audit hint
) STRICT;
CREATE INDEX review_log_by_card ON review_log(profile_id, page_id, reviewed_at);

CREATE TABLE confusion_edge (                   -- personal mutashābihāt confusion log (bookkeeping, not ML)
  profile_id      TEXT NOT NULL REFERENCES profile(profile_id) ON DELETE CASCADE,
  ayah_a          TEXT NOT NULL REFERENCES ayah(ayah_id),
  ayah_b          TEXT NOT NULL REFERENCES ayah(ayah_id),
  weight          REAL NOT NULL DEFAULT 0,
  last_confused_at TEXT,                         -- UTC instant
  PRIMARY KEY (profile_id, ayah_a, ayah_b),
  CHECK (ayah_a < ayah_b)                        -- canonical ordering: one edge per unordered pair
) STRICT;

CREATE TABLE cycle_config (
  profile_id          TEXT PRIMARY KEY REFERENCES profile(profile_id) ON DELETE CASCADE,
  cycle_type          TEXT NOT NULL,            -- '7_manzil' | '1_juz_day' | 'half_juz_day' | 'custom' ...
  new_lines_per_day   INTEGER NOT NULL DEFAULT 0 CHECK (new_lines_per_day >= 0),
  near_window_juz     INTEGER NOT NULL CHECK (near_window_juz >= 0),
  far_target_per_day  INTEGER NOT NULL CHECK (far_target_per_day >= 0),
  far_cycle_days      INTEGER NOT NULL CHECK (far_cycle_days > 0),   -- the cycle ceiling (PRD §7.6)
  daily_budget_minutes INTEGER NOT NULL CHECK (daily_budget_minutes > 0),
  pure_cycle_mode     INTEGER NOT NULL DEFAULT 0 CHECK (pure_cycle_mode IN (0,1)),
  term_label_set      TEXT NOT NULL,
  region_preset       TEXT
) STRICT;

-- App-level singletons (not per profile)
CREATE TABLE app_meta (
  key   TEXT PRIMARY KEY,                       -- 'schema_version', 'text_checksum_verified_at',
  value TEXT NOT NULL                           -- 'active_profile', 'encryption_enabled', ...
) STRICT;
```

### Pitfalls / what we refuse

- **We refuse any `UPDATE` or `DELETE` DAO method on `review_log`.** The append-only property is enforced by the *absence* of those methods on the generated DAO, reviewed in CI; the only bulk reads/writes are export and one-tap erase ([10-backup-format.md](10-backup-format.md), [PRD §16](../PRD.md)).
- **We refuse to store `DateTime` instants as scheduling days.** `due_at`/`last_review_at` are `CalendarDate` serial integers; an instant column here would reintroduce the DST off-by-one that produces a wrong "next due" ([07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md)).
- **We refuse to persist derived health roll-ups.** Per-juz/per-page health is recomputed from `card` state ([PRD §10.3](../PRD.md)); a stored copy is a second source of truth that drifts.
- **We refuse to widen the `*_json` columns into health or Quran facts.** `settings_json`, `error_lines_json`, `ayah_refs_json`, `distinguishing_word_index_json` carry small, schema-shaped, decode-validated data only; the Quran text itself is never reconstructed from or stored in these columns ([PRD R1, §11.2](../PRD.md)).

---

## 3. Crash safety

### Decision

The store runs in **WAL journal mode with `synchronous = FULL` on the write connection**, and **every review is exactly one `db.transaction`** — committed atomically or not at all, with automatic rollback on any error. There is no debounce, no deferred save, no in-memory dirty state: when a write method returns, the change is durably on disk. No teacher sign-off — a *sanad* act — is acknowledged in the UI before it is committed. This applies *Decision log: Persistence & at-rest encryption* and the README's fifth engineering value, "crash-safe local persistence."

### Rationale

- **WAL makes "persist on every grade" crash-safe.** Instead of a rollback journal, WAL appends changes to a separate `-wal` file and the main database file is untouched until checkpoint; commits are atomic, and the scheme is robust against crashes and power loss ([SQLite: WAL](https://sqlite.org/wal.html)). It also gives concurrency that matches our access pattern exactly: "WAL provides more concurrency as readers do not block writers and a writer does not block readers" ([SQLite: WAL](https://sqlite.org/wal.html)) — the grade/sign-off path writes while the reactive UI (heat-map, Today list) reads consistent snapshots.
- **`synchronous = FULL`, not `NORMAL`, on the write connection.** In WAL mode, `synchronous = NORMAL` omits the per-commit `fsync`; the SQLite docs are explicit about the cost: "the downside to this configuration is that transactions are no longer durable and might rollback following a power failure or hard reset" ([SQLite: WAL](https://sqlite.org/wal.html)). For a teacher sign-off we must not lose, the safe posture is `FULL`, which syncs the WAL on every commit ([SQLite: WAL](https://sqlite.org/wal.html)). The write volume is a handful of rows per review, so the extra `fsync` is free in practice.
- **One transaction per review, because a review is several writes.** `onReview` ([PRD §7.7](../PRD.md)) appends to `review_log`, updates the `card` row (D/S/`due_at`/flags), may create `line_block` rows, and may bump `confusion_edge` weights. These must be all-or-nothing — a half-applied review corrupts the audit trail. Drift's `db.transaction` runs them so that "none of their changes is visible to the main database until the transaction is finished," and the block reverts on a thrown exception ([Drift: Transactions](https://drift.simonbinder.eu/dart_api/transactions/)).

### Specification

Every mutation the features can trigger is one transaction. The review write is the canonical case:

```dart
// /data — the only code that sees drift; features call this and await it.
Future<void> commitReview(ReviewOutcome r) {
  return _db.transaction(() async {
    // 1. APPEND the immutable audit row (never updated/deleted)
    await _db.into(_db.reviewLog).insert(r.logRow);

    // 2. UPDATE the card's engine state (D, S, due_at, flags, reps/lapses)
    await (_db.update(_db.card)
          ..where((c) =>
              c.profileId.equals(r.profileId) & c.pageId.equals(r.pageId)))
        .write(r.cardUpdate);

    // 3. LAZILY create line-blocks for a repeatedly-lapsing page (if any)
    if (r.newLineBlocks.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.lineBlock, r.newLineBlocks));
    }

    // 4. BUMP mutashābihāt confusion edges (if a wrong-branch stumble occurred)
    for (final edge in r.confusionBumps) {
      await _db.into(_db.confusionEdge).insertOnConflictUpdate(edge);
    }
  });
  // When this Future completes, every row above is durably on disk (synchronous=FULL).
  // The ViewModel republishes state only AFTER this returns — persist-before-publish.
}
```

The cold-start seed ([PRD §7.10](../PRD.md)) — provisioning 600+ cards from the coverage capture — is one **outer** transaction with batched inserts, so a failure mid-seed leaves no partially-provisioned profile; nested transactions (savepoints, supported since Drift 2.0) are available if a sub-step needs its own boundary ([Drift: Transactions](https://drift.simonbinder.eu/dart_api/transactions/)):

```dart
Future<void> seedColdStart(Profile p, List<CardSeed> seeds) {
  return _db.transaction(() async {
    await _db.into(_db.profile).insert(p.row);
    await _db.batch((b) => b.insertAll(_db.card, seeds.map((s) => s.row).toList()));
    await _db.into(_db.cycleConfig).insert(p.cycleConfig.row);
  });
}
```

### Pitfalls / what we refuse

- **The await footgun.** Drift's transaction docs are blunt: "All queries inside the transaction must be `await`-ed," because "without `await`, some queries might be operating on the transaction after it has been closed! This can cause data loss or runtime crashes" ([Drift: Transactions](https://drift.simonbinder.eu/dart_api/transactions/)). **A missing `await` inside a transaction is a release-blocking review-checklist item** ([03-coding-standards.md](03-coding-standards.md)); the lint surface is grep-able (`transaction(() async` blocks are audited for un-awaited query calls).
- **We refuse `synchronous = NORMAL` on the write path.** The "may roll back after power failure" window is acceptable for disposable caches, not for a *sanad* record.
- **We refuse persist-after-publish.** The ViewModel publishes new state only after the write Future resolves; UI optimism that shows a sign-off before it is committed could acknowledge a review that a crash then loses.
- **We do not assume a rollback always succeeds.** If even the `ROLLBACK` fails, Drift surfaces both errors via `CouldNotRollBackException` ([Drift: CouldNotRollBackException](https://pub.dev/documentation/drift/latest/drift/CouldNotRollBackException-class.html)); the data layer logs it locally (never transmitted) and treats the store as needing recovery rather than swallowing it.
- **We never file-copy the live store.** WAL means a three-file family (`hifz.sqlite`, `-wal`, `-shm`); copying only the main file loses uncheckpointed commits ([SQLite: WAL](https://sqlite.org/wal.html)). Export goes through the checkpointed snapshot path in [10-backup-format.md](10-backup-format.md), never a raw file copy.

---

## 4. Migrations

### Decision

All schema evolution uses **Drift's guided, step-by-step migrations**: an integer `schemaVersion`, a committed JSON schema snapshot per version, generated `.steps.dart` migration files, and generated migration tests kept green in CI. Migrations are append-only — a shipped migration is never edited. Backup restore does **not** replay SQL migrations; the versioned backup payload is mapped to the current schema by the import pipeline ([10-backup-format.md](10-backup-format.md)).

### Rationale

- **A botched migration on `review_log` is irreversible hifz-history loss.** Drift's own docs warn that manual migrations are "error-prone and can lead to data loss" and steer to the guided path ([Drift: Migrations](https://drift.simonbinder.eu/Migrations/)). For an append-only audit trail that must survive years of app updates, the verify-every-path capability is the safeguard.
- **Migrations are run inside a transaction so a failed upgrade rolls back cleanly.** Drift's guided `stepByStep` migrations run the steps with foreign keys disabled and re-enabled afterward — its `from1To2`-style callbacks execute the version diff, and the recommended pattern wraps the migration logic transactionally so a half-migrated database is never left behind ([Drift: Migrations](https://drift.simonbinder.eu/Migrations/); [Drift: Schema migration helpers](https://drift.simonbinder.eu/migrations/step_by_step/)). Combined with the WAL/transaction guarantees of §3, an interrupted upgrade does not corrupt the store.
- **Schema snapshots let the tooling validate a migration against the real old→new diff.** "Drift's code generator can only see the current state of your schema"; exporting older-version snapshots lets `drift_dev` verify an upgrade from *every* prior version, and generate test scaffolds ([Drift: Migrations](https://drift.simonbinder.eu/Migrations/)). This is the one code path that touches every user's entire history, so it is the one with the strongest test discipline.

### Specification

The migration strategy uses `stepByStep`, which dispatches incremental version bumps and re-applies the connection pragmas after migration:

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async => m.createAll(),
  onUpgrade: stepByStep(
    // from1To2: (m, schema) async {
    //   await m.addColumn(schema.card, schema.card.someNewColumn);
    // },
    // ... one typed callback per version bump; generated against committed snapshots
  ),
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON;');
  },
);
```

The workflow and its CI gates:

| Step | Command / rule | Why |
|---|---|---|
| Export a schema snapshot on every `schemaVersion` bump | `dart run drift_dev schema dump` → committed `drift_schemas/` JSON | Gives the tooling the old schema to diff against ([Drift: Migrations](https://drift.simonbinder.eu/Migrations/)) |
| Generate step files + test scaffold | `dart run drift_dev make-migrations` | Produces `.steps.dart` and the migration-test skeleton, the guided path the docs recommend ([Drift: Migrations](https://drift.simonbinder.eu/Migrations/)) |
| A shipped migration is **never edited** | Review rule | Editing rewrites history for existing installs — a botched migration is user data loss (CycleVault's same rule) |
| Every new migration ships with a fixture test | Build a populated v(n−1) DB, migrate, assert content **and** `PRAGMA integrity_check` | Migrations touch every user's entire history; the test is release-blocking ([11-testing-strategy.md](11-testing-strategy.md)) |
| `eraseDatabaseOnSchemaChange` is DEBUG-only | `#if`/assert-gated; never in a release build | A dev convenience that, shipped, would wipe real hifz history |
| Backup restore does not replay SQL migrations | The payload is schema-version-stamped; import maps any supported version to the current schema | Old backups restore into new app versions without running a SQL upgrade on the failure-intolerant import flow ([10-backup-format.md](10-backup-format.md)) |

### Pitfalls / what we refuse

- **We refuse `eraseDatabaseOnSchemaChange` in any shipping build.** It is a DEBUG-only convenience and is gated so it can never reach a release artifact.
- **We refuse to query a column before the migration that adds it has run.** Drift's docs flag this: write queries only against the *latest* schema, and never `select`/`update` a not-yet-added column inside an older migration step ([Drift: Migrations](https://drift.simonbinder.eu/Migrations/)).
- **We refuse to ship a migration without a passing fixture test that includes `PRAGMA integrity_check`.** An untested migration on `review_log` is an unacceptable risk to the audit trail.

---

## 5. At-rest encryption (optional, opt-in)

### Decision

At-rest encryption is an **optional, opt-in** feature, **off by default**, implemented as a single declarative build-hook toggle (`hooks: user_defines: sqlite3: source: sqlite3mc`) plus a `PRAGMA key` in the connection `setup`, using **SQLite3MultipleCiphers with its ChaCha20-Poly1305 default**. The mandatory floor is WAL crash-safety and transactional integrity (§3); encryption is honest defense-in-depth for a *narrower* threat. We do **not** use the deprecated `sqlcipher_flutter_libs`/`sqlite3_flutter_libs` packages, and we do **not** build CycleVault-style decoy/duress isolation. This applies *Decision log: Persistence & at-rest encryption*.

### Rationale

- **The threat model is honestly narrower than a medical app's.** Hifz Companion stores *religious-practice telemetry* — which muṣḥaf pages a profile reviewed and how fluently — with no PII (a profile is a typed display name), no account, and nothing ever leaving the device ([PRD §17](../PRD.md)). The realistic threat is **device theft or shared-device curiosity**, not network exfiltration or forensic extraction of medical history. Treating encryption as mandatory-and-headline (CycleVault's posture, justified there by reproductive-health data) would be dishonest gold-plating here; treating it as a clean opt-in matched to a real trigger — a teacher/halaqa device holding several students' progress ([PRD §15.3](../PRD.md)) — is the proportionate call. OS-level file protection (iOS Data Protection, Android FBE) already covers the locked device for free as defense-in-depth.
- **The 2026 encryption path is the build-hook model, not the old SQLCipher packages.** `package:sqlite3` v3 "relies on build hooks and code assets to load SQLite" and no longer needs `sqlite3_flutter_libs`; encryption is selected by pointing the hook at the SQLite3MultipleCiphers source ([sqlite3 hooks topic](https://pub.dev/documentation/sqlite3/latest/topics/hook-topic.html)). Drift's own docs confirm "that package is no longer necessary after upgrading to drift 2.32.0 and can be removed," and document the `PRAGMA key` setup and the `PRAGMA cipher` liveness check ([Drift: Encryption](https://drift.simonbinder.eu/platforms/encryption/)). The deprecated `sqlcipher_flutter_libs` is at `0.7.0+eol` ("no longer does anything"); depending on both it and `sqlite3_flutter_libs` historically caused stock SQLite to win the link and SQLCipher to be silently unavailable — the single-source build-hook model removes that ambiguity entirely ([research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §5).
- **ChaCha20-Poly1305 is the right default for a greenfield store.** SQLite3MultipleCiphers (MIT) supports several schemes; its recommended default is ChaCha20-Poly1305 HMAC, a modern AEAD, with no legacy file to read we have no reason to choose the SQLCipher-compat AES-256-CBC scheme ([research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §6).
- **A raw 32-byte key beats a passphrase here.** The key is full-entropy random material held in the OS keystore, not a typed human password, so supplying it as a raw key skips PBKDF2 and removes the per-open key-derivation delay.

### Specification

The toggle is one line in the workspace-root `pubspec.yaml` (only present in the encryption-enabled build flavor):

```yaml
# pubspec.yaml (encryption flavor only)
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc   # bundles SQLite3MultipleCiphers instead of stock SQLite
```

The key is generated once at first launch, stored raw in `flutter_secure_storage`, and fed in the `setup` callback **before** Drift touches the database — with a hard liveness assertion promoted from debug-only to a real release guard:

```dart
// Key lifecycle — flutter_secure_storage (Keychain / Android KeyStore)
const _storage = FlutterSecureStorage(
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

Future<String> _dbKeyHex() async {
  var hex = await _storage.read(key: 'hifz_db_key');
  if (hex == null) {
    final bytes = List<int>.generate(32, (_) => _secureRandom.nextInt(256));
    hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _storage.write(key: 'hifz_db_key', value: hex);   // first launch only
  }
  return hex;
}

NativeDatabase.createInBackground(
  file,
  setup: (raw) {
    // Raw-key BLOB-literal form: full-entropy key, skips PBKDF2.
    raw.execute("PRAGMA key = \"x'$keyHex'\";");
    // HARD GUARD: refuse to operate on a plaintext store that only *looks* encrypted.
    if (raw.select('PRAGMA cipher;').isEmpty) {
      throw StateError('Encryption build active but cipher is not live; refusing to open.');
    }
    raw.execute('PRAGMA journal_mode = WAL;');
    raw.execute('PRAGMA synchronous = FULL;');
    raw.execute('PRAGMA foreign_keys = ON;');
  },
);
```

`flutter_secure_storage` (BSD-3-Clause) uses the iOS/macOS Keychain and, on Android, AES-GCM via the platform KeyStore; the `first_unlock_this_device` accessibility class makes the key readable for background notification scheduling but keeps it from migrating to cloud backups or other devices ([flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)). The encrypted backup file plus its own independent passphrase ([10-backup-format.md](10-backup-format.md)) is therefore the *only* off-device path; the DB key never leaves the device.

Error handling at open distinguishes two failure classes:

| Symptom at open | Meaning | App response |
|---|---|---|
| `PRAGMA cipher;` returns empty (encryption build) | Cipher not live — misconfigured build | Refuse to open; this is a build defect, fail loudly (never write plaintext) |
| First access throws `SQLITE_NOTADB` ("file is encrypted or is not a database") | Wrong / missing key — not corruption | Surface a key-recovery flow, **never** a "your data is corrupted" message ([research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §7) |

**Key rotation never happens in place on a WAL database.** SQLite3MultipleCiphers requires the database not be in WAL mode for a key or page-size change ([SQLite3MultipleCiphers FAQ](https://utelle.github.io/SQLite3MultipleCiphers/docs/faq/faq_overview/)), and in-place WAL rekeying has caused corruption; to rotate the key, export to a freshly-keyed database via the checkpointed snapshot pipeline rather than `PRAGMA rekey` ([research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §7).

### Pitfalls / what we refuse

- **We refuse a silently-plaintext build.** If `source: sqlite3mc` is not actually in effect, `PRAGMA key` is a no-op against stock SQLite and a *plaintext* database ships that *looks* encrypted. The `PRAGMA cipher;` check is promoted from Drift's debug-only example to a real release guard that refuses to open ([Drift: Encryption](https://drift.simonbinder.eu/platforms/encryption/)).
- **We refuse the deprecated SQLCipher packages.** `sqlcipher_flutter_libs` (0.7.0+eol) and `sqlite3_flutter_libs` (no-op from 0.6.0) are EOL; linking two native SQLite sources reintroduces the silent dual-link conflict ([research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §5).
- **We refuse in-place WAL re-keying.** sqlite3mc disabled it after corruption reports; rotation goes through an export to a freshly-keyed database ([SQLite3MultipleCiphers FAQ](https://utelle.github.io/SQLite3MultipleCiphers/docs/faq/faq_overview/)).
- **We refuse to misreport a wrong key as corruption.** `SQLITE_NOTADB` on open means wrong/missing key; a "data corrupted" message would needlessly frighten a user whose data is intact ([research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §7).
- **We refuse to build decoy/duress isolation.** That is a reproductive-health-app feature (CycleVault) answering a coercion threat that does not apply to religious-practice telemetry; building it here would be unjustified complexity. We also refuse to *claim* physical secure-erase — one-tap erase ([PRD §16](../PRD.md)) deletes the store and, when encryption is on, destroying the key renders the data cryptographically unrecoverable, which is the honest guarantee; UI copy never promises physical erasure of flash blocks.
- **We pin the bundled SQLite + sqlite3mc versions.** The bundled SQLite is part of the durability surface; point releases that fix WAL/corruption issues are tracked and updated promptly ([research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md) §6).

---

## References

- Simon Binder. *drift — Reactive, typesafe persistence library for Dart & Flutter* (v2.34.0, MIT). pub.dev. https://pub.dev/packages/drift
- Simon Binder. *Welcome to Drift!* (project documentation home). https://drift.simonbinder.eu/
- Simon Binder. *Drift — Transactions* (atomicity; automatic rollback on throw; the `await` requirement and its data-loss consequence; nested transactions/savepoints since 2.0). https://drift.simonbinder.eu/dart_api/transactions/
- Simon Binder. *Drift — Migrations* (`schemaVersion`, `MigrationStrategy`, `make-migrations`, schema snapshot export/verification, manual migrations "error-prone and can lead to data loss", `PRAGMA foreign_keys` in `beforeOpen`). https://drift.simonbinder.eu/Migrations/
- Simon Binder. *Drift — Schema migration helpers* (`stepByStep`; running migration steps with foreign keys disabled and re-enabled afterward). https://drift.simonbinder.eu/migrations/step_by_step/
- Simon Binder. *Drift — Encryption* (sqlite3mc via build hooks; `PRAGMA key` in `setup`; `PRAGMA cipher` liveness check; `sqlcipher_flutter_libs` unnecessary after drift 2.32.0; `encrypted_drift`/`sqflite_sqlcipher` alternative). https://drift.simonbinder.eu/platforms/encryption/
- Simon Binder. *CouldNotRollBackException class* (drift Dart API). https://pub.dev/documentation/drift/latest/drift/CouldNotRollBackException-class.html
- Simon Binder. *sqlite3 — build hook options* (`hooks: user_defines: sqlite3: source: sqlite3mc`; v3 build-hooks model). https://pub.dev/documentation/sqlite3/latest/topics/hook-topic.html
- SQLite Consortium. *Write-Ahead Logging* (atomic commits, main file untouched until checkpoint, `-wal`/`-shm` files, readers don't block writers, `synchronous=NORMAL` durability trade-off, power-loss robustness). https://sqlite.org/wal.html
- Ulrich Telle. *SQLite3 Multiple Ciphers — Frequently Asked Questions* (a key or page-size change requires the database not be in WAL journal mode). https://utelle.github.io/SQLite3MultipleCiphers/docs/faq/faq_overview/
- Ulrich Telle. *SQLite3 Multiple Ciphers — Overview* (MIT; default ChaCha20-Poly1305 HMAC; supported cipher schemes). https://utelle.github.io/SQLite3MultipleCiphers/
- juliansteenbakker et al. *flutter_secure_storage* (v10.3.1, BSD-3-Clause; iOS/macOS Keychain; Android AES-GCM via KeyStore; `first_unlock_this_device` accessibility). https://pub.dev/packages/flutter_secure_storage
- Hifz Companion. *Engineering README & tech-decision log.* [README.md](README.md)
- Hifz Companion. *Product Requirements Document.* [PRD.md](../PRD.md)
- Hifz Companion. *Local persistence research note.* [research/drift-sqlite-persistence.md](research/drift-sqlite-persistence.md)

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
