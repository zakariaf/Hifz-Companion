# E05-T05 — Load verified bytes into E03's read-only Drift mushaf/page/line/ayah + layout reference tables, checksum-governed

| | |
|---|---|
| **Epic** | [E05 — Quran Data & Immutable Rendering](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E05-T04, E03 |
| **Skills** | domain-mushaf-text-integrity, eng-add-drift-table-or-migration, eng-add-persisted-model |

## Goal

A `ReferenceDbBuilder` in the `/data` package takes the already-verified core-pack files (Tanzil text + QUL page/line/word geometry + the `mushaf` descriptor) and loads them, in **one** `db.transaction`, into E03's **read-only** `mushaf`/`surah`/`page`/`line`/`ayah` reference tables — the `_buildReferenceDb(verifiedFiles)` seam that E05-T04's `installCorePack` calls after promote-to-documents and before stamping `text_checksum_verified_at`. The verified Tanzil bytes are stored byte-for-byte as the **audit source** (structure/search/audit only — never drawn, never a layout input); the 30 juz → 60 ḥizb → 240 rubʿ → 604 pages → 15 lines → 6,236 ayah hierarchy is **read from the QUL dataset, never recomputed**. The build refuses to run unless every input file's SHA-256 already matched the pinned manifest (checksum-governed), and refuses to write a row that violates a schema `CHECK`/FK. The reference-table DDL, the `schemaVersion`, and the migration stay owned by **E03**; this task only loads verified bytes through the single write path.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §1 | The three co-versioned layers; **the Tanzil text is the audit source of truth, never a render or layout input**; the `mushaf` row binds the `{text, layout, fonts}` triple and pins every checksum; refuse to derive layout from text, refuse to mix layers across editions |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §3 | Layout is data: page/line/word geometry comes **only** from the QUL dataset, grouped by `page-{p}-line-{l}` (never by verse); juz/ḥizb/rubʿ/page/line/ayah counts are **read, never recomputed**; `LineType` ∈ {ayah, surahName/surah_header, basmala}; glyph refs stay opaque |
| `docs/engineering/05-persistence-and-encryption.md` §2 | The exact v1 reference-table DDL this load targets (`mushaf`/`surah`/`page`/`line`/`ayah`, `STRICT`, the `CHECK`/FK/index invariants, `checksum_sha256` on `mushaf`, `qpc_font_name` on `page`); reference data is read-only **because the Quran is immutable** — no DAO exposes a mutation; this task adds a **one-shot build path**, not a runtime write DAO |
| `docs/engineering/05-persistence-and-encryption.md` §3 | The single write path: one `db.transaction`, **every query inside `await`-ed**, WAL + `synchronous=FULL`, persist-before-publish; the build commits atomically or rolls back |
| `docs/engineering/09-asset-packs-and-offline-integrity.md` §2 | `installCorePack` calls `_buildReferenceDb(verifiedFiles)` **only after** every file is hash-verified and promoted to app-documents, then stamps `text_checksum_verified_at`; this task implements that build step, owned at the seam by E05-T04 |
| `docs/PRD.md` §6.1 | The fixed structure: 30 juz → 60 ḥizb → 240 rubʿ al-ḥizb → 604 pages (Ḥafṣ / Madani 15-line) → 15 lines/page → 6,236 ayah → words; "the app never recomputes it" — load these counts from data |
| `docs/PRD.md` §11.1 / §11.1.1 | Core pack = Tanzil text (CC BY 3.0) + QUL layout + KFGQPC fonts + mutashābihāt; **text is never used for layout**; a pack is trusted only after exact SHA-256 match; the app refuses to render Quran text from any unverified asset |
| Skill `domain-mushaf-text-integrity` (+ `template.dart`, `references.md`) | Store text byte-for-byte, SHA-256-pinned, audit-only; never a layout input; the `MushafEdition` triple / `mushaf` descriptor; layout from QUL grouped by page-line; refuse to mix layers; the riwāyah is named |
| Skill `eng-add-drift-table-or-migration` (+ `template.dart`) | Reference tables are **read-only by construction**; constraints live in the schema (`STRICT`/`CHECK`/FK); one `db.transaction`, `await` every query, persist-before-publish; **the DDL/migration mechanics stay in E03** — this task loads bytes, does not author or bump the schema |
| Skill `eng-add-persisted-model` (+ `template.dart`) | Drift confined to `/data`, no Drift symbol crosses the boundary; the build maps parsed file rows → Drift companions inside `/data`; reference tables have **no runtime write DAO**; the load is reached through one repository transaction; throwing confined to the `/data` boundary, typed, never swallowed |
| `docs/science/CLAIMS.md` C-031 | "604 pages, one card per page" — the page count loaded here is the spine of the 604-card model; do **not** hardcode 604/15, read `page_count`/`line_count` from the `mushaf`/QUL data |
| Siblings: E05-T01, E05-T03, E05-T04, E05-T06, E05-T07 | T01 supplies the `MushafEdition` triple + the pinned manifest the verified files came from; T03 is the chunked SHA-256 verifier that already passed before this build runs; **T04 sequences `installCorePack` and calls `_buildReferenceDb` — the seam this task fills**; T06 registers the 604 fonts (consumes `page.qpc_font_name` this load writes); T07's `assemblePage` reads the `line`/`page` geometry this load writes |

## Implementation notes

TEST-FIRST for the correctness-critical parsing/structure invariants: write the golden-vector and counts/rollback cases below before `ReferenceDbBuilder.build` — the "604 pages / 6,236 ayah / 15 lines" assertions and the "one bad row rolls back the whole load" assertion must exist and fail first.

1. **File & package**: `packages/data/lib/src/reference/reference_db_builder.dart`. The builder lives in `/data` (the only package importing `package:drift`/`package:sqlite3`); it imports E03's generated reference tables and maps parsed file rows to Drift companions there. No Drift symbol escapes `/data`; callers (E05-T04's `installCorePack`) see only `Future<void> build(...)` over plain value types. **Do not** author, alter, or `schemaVersion`-bump the DDL — `mushaf`/`surah`/`page`/`line`/`ayah` and their `STRICT`/`CHECK`/FK/index are E03's; this task only inserts verified rows into them.

2. **Input contract**: `Future<void> build({required VerifiedCorePack pack, required AppDatabase db})`. `VerifiedCorePack` (from E05-T04) carries the promoted, hash-verified files keyed by manifest name (`text`, `layout`, `mushaf_descriptor`, …) plus the `MushafEdition` triple (E05-T01) whose `textSha256`/`layoutSha256` already matched the pinned manifest. The builder **re-asserts the precondition** that the pack is verified (`pack.isVerified == true` / the triple's checksums are non-empty) and throws `ReferenceLoadError.unverifiedInput` otherwise — fail-closed, never load unverified bytes.

3. **Parse, never compute**: read `page_number`, `line_number`, `position`, `line_type`, and the opaque glyph ref straight from the QUL layout file; read juz/ḥizb/rubʿ/surah/ayah membership from the dataset. Group words by `page-{p}-line-{l}` exactly as `assemblePage` will (08 §3) — **never** by verse boundary. Do not derive a page/line break, an ayah-to-page mapping, or a count from the text; every structural fact is a dataset row. The Tanzil text is read only to (a) store byte-for-byte as the audit blob and (b) drive any text-keyed `ayah` row content — it is **never** parsed to decide layout.

4. **Store the text byte-for-byte**: the verified Tanzil Uthmani bytes are persisted verbatim (no normalization, no NFC/NFD, no re-encoding, no trimming) as the audit source; its SHA-256 (already pinned in the `MushafEdition` triple and on the `mushaf.checksum_sha256` row) is the only governance. The glyph refs on `line.text_glyph_ref` stay opaque — never parsed as Arabic, never logged "as the verse".

5. **One transaction, persist-before-publish**: wrap the whole load in `await db.transaction(() async { ... })` (05 §3) — `mushaf` + `surah`(114) + `page`(604) + `line`(~9,060) + `ayah`(6,236) inserted all-or-nothing. **`await` every `into(...).insert(...)`/`batch`**; use a `batch` for the bulk line/ayah inserts but still inside the single transaction. A `CHECK`/FK violation (e.g. a `page_id` outside 1..604, a `line_no` outside 1..15, a dangling `surah` FK) throws and rolls the entire load back — no half-built reference DB is ever observable. The build's `Future` resolves only after the durable commit; T04 stamps `text_checksum_verified_at` *after* that.

6. **Stamp is T04's, the build is idempotent-by-guard**: this builder does **not** stamp `app_meta`/`text_checksum_verified_at` (E05-T04 owns the stamp after the build returns). Guard against a double build: if the reference tables are already populated for this `mushaf_id`, the build is a no-op or a clean replace inside the same transaction — never a partial overwrite. Reference tables remain read-only **at runtime**: this one-shot build path is the only writer, exposed to the install sequence, not to any feature.

7. **Errors**: one sealed `ReferenceLoadError` in `/data` (`unverifiedInput`, `malformedLayout(detail)`, `structuralMismatch(expected, actual)`, `constraintViolation(table, detail)`); typed `on … catch`, never `catch (_)`. No `print`/`debugPrint` of file contents or glyph refs. The pure engine never sees this type — it is a `/data` boundary error surfaced to the install controller.

8. **Pitfalls to avoid**: recomputing the hierarchy instead of reading it (08 §3 / PRD §6.1 — even when 604/15/6,236 look derivable); hardcoding `604`/`15`/`6236` as literals in the load instead of reading `page_count`/`line_count` from the `mushaf`/QUL data and asserting them in tests; normalizing or re-encoding the Tanzil text before storing; deriving any `page`/`line` row from the text; splitting the load across multiple transactions (a crash mid-build must leave the DB empty, not half-loaded); dropping an `await` inside the transaction (the await footgun, 05 §3); exposing a runtime write DAO on a reference table; touching E03's DDL or `schemaVersion`; loading before the pack is verified.

## Acceptance criteria

- [ ] `ReferenceDbBuilder.build({required VerifiedCorePack pack, required AppDatabase db})` exists in `packages/data/lib/src/reference/`; it imports Drift only from within `/data`, exposes no Drift symbol to callers, and adds **no** runtime write DAO to any reference table (verifiable by grep + the banned-import gate).
- [ ] The build refuses an unverified input: a `VerifiedCorePack` whose checksums are absent/unverified throws `ReferenceLoadError.unverifiedInput` and writes **nothing** (fail-closed, checksum-governed).
- [ ] After a successful build over the golden core-pack fixture, the reference tables hold exactly the read structure: `mushaf`=1 row (`page_count`=604, `line_count`=15, `riwayah`/`name`/`checksum_sha256` set), `surah`=114, `page`=604, `ayah`=6,236, and `line` counts match the QUL dataset — **all read from data, none recomputed**.
- [ ] The Tanzil text is stored byte-for-byte (the stored audit blob's SHA-256 equals the pinned `textSha256`); the text is never parsed to produce a `page`/`line` row, and `line.text_glyph_ref` is stored opaque.
- [ ] The entire load is one `db.transaction`; a single `CHECK`/FK violation (injected: `page_id`=605, `line_no`=16, dangling `surah` FK) throws and leaves all five reference tables **empty** (atomic rollback) — no partially-built reference DB is observable.
- [ ] The builder does not stamp `text_checksum_verified_at` and does not touch E03's DDL or `schemaVersion` (the seam: T04 stamps after `build` returns; E03 owns the schema).
- [ ] A re-run of `build` for the same `mushaf_id` does not duplicate rows or leave the DB inconsistent (idempotent guard inside the transaction).
- [ ] Every `public` declaration carries a `///` doc comment; errors are the sealed `ReferenceLoadError`, typed `on … catch`, never swallowed; no `print` of file/glyph content.

## Tests

`packages/data/test/reference/reference_db_builder_test.dart` (mirrors the source name), plain `dart test`/`drift` over an in-memory `NativeDatabase.memory()` (no Flutter, no IO beyond the bundled fixture), with an `HttpOverrides` that throws installed in `setUpAll` so the load is provably offline. Fixtures are a small, committed, **already-verified** golden core-pack slice plus the full-structure golden where counts are asserted. Required cases, the structural ones written FIRST:

- **Structure golden (TEST-FIRST)**: build over the golden pack → `mushaf`/`surah`/`page`/`ayah` counts equal 1 / 114 / 604 / 6,236 and `line` count equals the dataset's; `page_count`/`line_count` come from data (assert the loaded value, not a literal); a spot-check that page→juz→ḥizb→rubʿ membership matches the dataset for a few known pages (e.g. juz 30 starts at the documented page).
- **Byte-for-byte text (TEST-FIRST)**: the stored Tanzil audit blob's SHA-256 equals the fixture's pinned `textSha256`; mutating one byte of the input fixture changes the stored hash (proves verbatim storage, no normalization).
- **Atomic rollback (TEST-FIRST)**: a fixture with one out-of-range row (`page_id`=605 / `line_no`=16 / dangling `surah` FK) → `build` throws `ReferenceLoadError.constraintViolation` and all five reference tables are empty afterwards.
- **Fail-closed on unverified input**: an unverified `VerifiedCorePack` (checksums cleared) → `build` throws `ReferenceLoadError.unverifiedInput`, tables empty.
- **No layout from text**: a fixture whose text and layout disagree on a verse's page is loaded faithfully to the **layout** (the page/line rows follow QUL, not the text) — proves text is never a layout input.
- **Single-transaction / await**: a mid-load injected failure (DB throws on the Nth insert) leaves the DB empty (rollback), proving one transaction and that every query is awaited.
- **Idempotent re-run**: building twice for the same `mushaf_id` yields the same row counts, no duplicates.
- **Read-only at runtime**: a compile/grep assertion that no public DAO method mutates `mushaf`/`surah`/`page`/`line`/`ayah` outside this build path.

The migration **fixture test** (`integrity_check` over a populated `v(n−1)` DB) belongs to E03's schema task, not here; this task's load runs on top of E03's `schemaVersion=1` schema and asserts only data correctness.

## Definition of Done

- [ ] All acceptance criteria met; the suite is green locally and in the `fast` CI job; the load runs entirely offline (`HttpOverrides` throws) and over an in-memory DB.
- [ ] **Offline / no-network (non-negotiable)**: the builder opens no socket and imports nothing networking; it consumes only already-verified, promoted local files; after the build the muṣḥaf renders with the radio off.
- [ ] **No AI / no microphone**: the load is pure parse-and-insert — no AI, ASR, audio, or inference anywhere in the path.
- [ ] **Text fidelity (existential)**: the Tanzil text is stored byte-for-byte and used only for structure/audit — never drawn, never a layout input; layout/line/page rows come only from the QUL dataset, grouped by page-line, never recomputed; an unverified or checksum-mismatched input is refused (fail-closed); a constraint violation rolls the whole load back.
- [ ] **Read-only reference tables (E03 boundary respected)**: no runtime write DAO is added; the DDL, `schemaVersion`, and migration stay E03's; this task only loads verified bytes through one `db.transaction` and does not stamp `text_checksum_verified_at` (T04 does, after the build commits).
- [ ] **RTL + fa/ckb/ar localization**: N/A by construction — the builder loads reference rows and surfaces no user-facing string; the `riwayah`/`displayName` shown to the user is chrome owned by sibling tasks, the muṣḥaf data is identical across all three locales.
- [ ] **Accessibility**: N/A by construction — no UI in this task.
- [ ] **Sect-neutral adab**: the loaded `mushaf` row names the riwāyah (Ḥafṣ ʿan ʿĀṣim — Madani 15-line); zero tafsīr/translation/commentary is loaded; the data is the verbatim text + neutral structure only, no fiqh ruling encoded.
- [ ] **Nothing safe to drop**: the load is correctness-critical and never degrades — it either builds the complete, verified reference DB or fails closed; no page/ayah is ever marked optional or droppable.
- [ ] **Deterministic tests**: the structure-golden, byte-for-byte, atomic-rollback, fail-closed, and no-layout-from-text cases run in CI on every PR; counts assert loaded-from-data values, not literals; no clock, no network, no Ahem.
