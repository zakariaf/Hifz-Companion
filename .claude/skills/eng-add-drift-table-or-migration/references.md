# references — eng-add-drift-table-or-migration

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/engineering/05-persistence-and-encryption.md` §1 (The store: Drift over SQLite) — **Drift lives only in `/data`, behind DAOs that hand the rest of the app plain value types; the `NativeDatabase` FFI backend, not `sqflite`.** The CI `import_rules`/DCM banned-import gate forbids `package:drift`/`package:sqlite3` anywhere but `/data` — the boundary is what keeps the engine pure and golden-testable. The fixed `setup`/`beforeOpen` pragmas (WAL, `synchronous=FULL`, `foreign_keys=ON`, `busy_timeout`) are per-connection and re-asserted on every open.

- `docs/engineering/05-persistence-and-encryption.md` §2 (Schema) — **The v1 DDL and its rules:** read-only checksum-governed reference tables vs. read-write user tables; constraints in the schema not Dart (`STRICT`, `CHECK (... IN (...))`, ranges, foreign keys); `review_log` append-only (no `UPDATE`/`DELETE` DAO); scheduling days are `CalendarDate` serial integers and true instants are UTC; no derived health roll-up or `R` stored as a second source of truth; `*_json` columns carry small decode-validated data, never Quran text or health facts. The `CHECK (track = 'UNMEMORIZED' OR due_at IS NOT NULL)` memorized-card invariant defended at the storage layer.

- `docs/engineering/05-persistence-and-encryption.md` §3 (Crash safety) — **One `db.transaction` per review, committed atomically or rolled back on throw; persist-before-publish.** A review is several writes (append `review_log`, update `card`, maybe `line_block`/`confusion_edge`) that must be all-or-nothing; `commitReview` is the canonical body and the cold-start seed is one outer transaction with batched inserts. The **await footgun**: every query inside `transaction(() async` is `await`-ed or queries run after the transaction closes → data loss. Refuses `synchronous=NORMAL` on the write path, persist-after-publish, and a raw file-copy of the live WAL store.

- `docs/engineering/05-persistence-and-encryption.md` §4 (Migrations) — **Guided `stepByStep`: bump `schemaVersion`, commit a per-version JSON snapshot, generate the step file + test scaffold, add one typed `fromNToM` callback; a shipped migration is never edited (a fix is a new higher version forward).** Every migration ships with a fixture test that builds a populated `v(n−1)` DB, migrates, and asserts content **and** `PRAGMA integrity_check`. `eraseDatabaseOnSchemaChange` is DEBUG-only; never `select`/`update` a not-yet-added column in an old step; backup restore does **not** replay SQL migrations (the import maps any supported version onto the current schema).

- `docs/engineering/05-persistence-and-encryption.md` §5 (At-rest encryption — optional, opt-in) — **Off by default; one declarative build-hook toggle (`source: sqlite3mc`, ChaCha20-Poly1305) + `PRAGMA key` in `setup`; the mandatory floor is WAL + transactions, encryption is defense-in-depth for device theft.** The hard `PRAGMA cipher;` liveness guard refuses a silently-plaintext store; the raw 32-byte key is in `flutter_secure_storage` (`first_unlock_this_device`, non-syncing); rotation is export-to-freshly-keyed, never in-place WAL re-key. Refuses the deprecated SQLCipher packages and CycleVault-style decoy/duress isolation (the threat model is honestly narrower than a medical app's).

## Supporting

- `docs/engineering/11-testing-strategy.md` §1 (The test pyramid) — **DAO query logic and migration fixtures live in the broad pure-Dart/unit base, not a device journey;** the table maps each tier to its runner (`flutter test` for `/data`). A schema/DAO test is the cheapest tier — keep it there.

- `docs/engineering/11-testing-strategy.md` §8 (CI shape) — **The migration fixture + DAO tests run in the `fast` job; the PRD-gate→job mapping makes the release contract auditable.** A red gate (including a failing migration `integrity_check`) blocks the release, full stop.

## Sibling skills

- **eng-create-riverpod-store** — the `Notifier`/`AsyncNotifier`, composition-root `ProviderScope` overrides, and `StreamProvider` read model that *call* the single-write-path repository method this skill defines (persist-then-republish); here for the schema/transaction body, there for the shell wiring.
- **eng-create-package** — the `pubspec.yaml` / `resolution: workspace` member and the banned-import lints that keep `package:drift`/`package:sqlite3` quarantined inside `/data`.
- **eng-write-dart-test** — the migration fixture test (populated `v(n−1)` → migrate → `PRAGMA integrity_check == ok`), the DAO unit tests, and the offline guard this skill *requires* but does not author.
- **eng-define-service-boundary** — wiring the live `HifzDatabase` handle as an injectable `Provider` override at the composition root with a deterministic in-memory fake double, instead of a global singleton.
- **domain-scheduling-engine-rules** — the pure `onReview` / trust-clamp / track arithmetic whose `due_at`/`d`/`s`/track outputs this layer persists and never recomputes; `due_at = min(SR-ideal, cycle ceiling)` is the engine's job, the `CHECK` is the storage guard.
- **domain-grading-pipeline** — the normalized `(grade, error_lines, source)` `ReviewInput`/`ReviewOutcome` the `db.transaction` writes into `review_log` and `card`.
- **domain-calendars-and-hifzdate** — the `CalendarDate` serial-day value type a `due_at`/`last_review_at` column stores (Hijri / Jalālī / Gregorian correctness; never a `DateTime` instant as a scheduling day).
- **domain-backup-format** — the versioned `.hifzbackup` export/import that turns this store into a portable file; restore maps a version-stamped payload forward onto the current schema and never replays SQL migrations.
- **domain-asset-pack-integrity** — the SHA-256 checksum governance of the read-only reference tables (the muṣḥaf structure + mutashābihāt dataset) this schema must never let a runtime write touch.
- **domain-mushaf-text-integrity** — the immutability of the Quran glyph/text/layout reference data; the read-only reference tables exist precisely so the sacred text is unmodifiable at runtime.
- **domain-adab-and-religious-integrity** — the append-only-*sanad*, no-gamification, no "safe to drop", and privacy non-negotiables the schema must structurally uphold (no streak/score column, no Quran/health fact in a column).
