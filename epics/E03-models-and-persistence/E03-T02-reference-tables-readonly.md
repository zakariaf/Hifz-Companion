# E03-T02 — Reference DTOs and the read-only reference table classes (page/line/ayah/surah/mushaf/mutashabih_*) — no write DAO

| | |
|---|---|
| **Epic** | [E03 — Models & Persistence](EPIC.md) |
| **Size** | M (≈1–2 days) |
| **Depends on** | E03-T01 |
| **Skills** | eng-add-drift-table-or-migration, eng-add-persisted-model, domain-mushaf-text-integrity |

## Goal

The seven Quran reference tables exist as `STRICT` Drift table classes in `packages/data/lib/src/db/tables/reference/` — `Pages`, `Lines`, `Ayat`, `Surahs`, `Mushafs`, `MutashabihGroups`, `MutashabihMembers` — every invariant encoded as a `CHECK`/foreign-key constraint (`surah_id BETWEEN 1 AND 114`, `page_id BETWEEN 1 AND 604`, `line_no BETWEEN 1 AND 15`, `revelation IN ('meccan','medinan')`, `line_type IN ('ayah','surah_header','basmala')`, `mutashabih_group.type IN ('identical','near_identical','structural')`), and their seven immutable reference DTOs (`Page`, `Line`, `Ayah`, `Surah`, `Mushaf`, `MutashabihGroup`, `MutashabihMember`) already live in `packages/models`. The tables are **read-only by construction** — no DAO that exposes an `INSERT`/`UPDATE`/`DELETE` against any of them is authored or generated, so a runtime write to the muṣḥaf is unrepresentable in the data layer (R1, §11.3). `mushaf` carries its `riwayah` and `checksum_sha256`; the content that fills these tables and the checksum governance over it belong to E05, not here. This task owns only the schema, the DTO mapping shape, and the absence of any write path.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/05-persistence-and-encryption.md` §2 (Schema) | The verbatim v1 DDL for `mushaf`/`surah`/`page`/`line`/`ayah`/`mutashabih_group`/`mutashabih_member`: every column, every `CHECK`, every foreign key, every index (`line_by_page`, `ayah_by_page`); `STRICT` on every table; reference-vs-user split; "Reference data is read-only because the Quran is immutable … no DAO exposes a write to them"; `*_json` columns hold small, decode-validated, non-Quran/non-health data only |
| `docs/engineering/05-persistence-and-encryption.md` §1 (Specification) | The `@DriftDatabase(tables: [...])` table list registering these seven reference tables alongside the user tables; the connection `setup`/`beforeOpen` pragmas are E03-T04's job, not this task's |
| `docs/engineering/01-architecture-overview.md` §2 (layer table), §3.1 (allowed-imports matrix) | Layer 0 `models` imports `dart:core`/`package:meta` only (the DTOs); Layer 2 `data` is the only package that imports `package:drift`/`package:sqlite3` (the table classes); no Drift symbol crosses into `engine`/`features`/`quran` |
| `docs/PRD.md` §10.1 (Reference, read-only, bundled), R1, §11.3 | The PRD column list these tables realize; reference tables are read-only (shipped as a bundled, checksummed DB / generated on first run from bundled assets); the integrity pipeline that fills + verifies them is E05's |
| `docs/PRD.md` R2, §11.2 | `mushaf.riwayah` is stated explicitly and the muṣḥaf is swappable; `line.text_glyph_ref` holds glyph codes that are **never parsed as real Arabic text** — the DTO carries them opaquely |
| Skill `eng-add-drift-table-or-migration` (canonical pattern 1–3, Do/Don't) | Drift lives only in `/data`; constraints in the schema (`STRICT`, `CHECK IN (...)`, range `CHECK`, FKs); **reference tables read-only by construction — no runtime write DAO** (pattern 3, the third outranking rule) |
| Skill `eng-add-persisted-model` (canonical pattern 1, 3, 8) | The immutable `models` value type (`final`, `const`, `copyWith`, `dart:core`/`package:meta` only); the Drift table class with invariants in the schema; "the read-only reference tables … come from the bundled, checksum-verified asset pack; no DAO exposes a write to them" |
| Skill `domain-mushaf-text-integrity` (canonical pattern 1, 2, 6; checklist) | Model the muṣḥaf as an immutable triple keyed by `mushaf_id` with `riwayah`/`displayName`; `pageCount`/`lineCount` are fields, not hardcodes; glyph codes (`text_glyph_ref`) stay **opaque** — never normalized, searched, or logged "as the verse"; markers persist only `(page, line, position)` refs, never reconstructed text |
| CLAIMS register | None — these tables hold value types and Quran structure; no user-facing number, copy, or methodology claim is rendered by this task, so no CLAIMS id is implemented here |
| Siblings: E03-T01, E03-T03, E03-T04, E03-T06 | T01 (depends-on) authors the **user** value models and the enum/`CalendarDate` conventions this task's reference DTOs reuse; T03 authors the **user** Drift tables (`profile`/`card`/… whose FKs point at `page`/`mushaf`/`ayah` defined here); T04 owns the connection pragmas + the FK-on startup assertion that make these FKs enforce; T06 authors the **read** DAOs/round-trip tests over both reference and user rows — this task deliberately ships **no** DAO |

## Implementation notes

This task is schema + value-type mapping; it is not test-first in the FSRS-arithmetic sense, but the read-only-by-construction property **is** correctness-critical and is proven by a test that the data layer exposes no write surface (see Tests) — write that test alongside the schema.

1. **Reference DTOs in `models`** — `packages/models/lib/src/reference/` (one file per type or a grouped `reference.dart`, matching the T01 layout): `Page`, `Line`, `Ayah`, `Surah`, `Mushaf`, `MutashabihGroup`, `MutashabihMember`. Each is an immutable value type — `final` fields, `const` constructor, `copyWith`, value equality (`package:meta` `@immutable`; `freezed` optional per T01's choice) — importing `dart:core`/`package:meta` only. **No `package:drift`, no `package:flutter`** (a compile error if present, enforced by the engine-purity / banned-import gate from E01). Export them from the `models` barrel.

2. **Field types and closed sets** — full-word names with semantics in the name (`pageNumber`, `juz`, `hizb`, `rub`, `lineNumber`, `ayahCount`, `pageCount`, `lineCount`). Closed sets are enums, not free strings: `Revelation { meccan, medinan }`, `LineType { ayah, surahHeader, basmala }`, `MutashabihType { identical, nearIdentical, structural }`. `Mushaf` carries `riwayah` (a `String` for now — the named riwāyah, e.g. `'hafs_an_asim'`), `name`, `fontFamily`, `checksumSha256`, and `pageCount`/`lineCount` as **fields, never hardcoded 604/15** (domain-mushaf-text-integrity pattern 1). `Line.textGlyphRef` is an **opaque** `String` of glyph codes — documented as never to be parsed, normalized, searched, or logged as Quran text. The `*_json` payloads (`ayahRefsJson`, `lineRefsJson`, `distinguishingWordIndexJson`) are carried as the raw `String` here; their decode-validation shape is the consumer's concern (E05/E14), and they hold only small structural refs — never reconstructed Quran text (R1).

3. **Reference table classes in `data`** — `packages/data/lib/src/db/tables/reference/` (one file per table, e.g. `mushafs.dart`, `surahs.dart`, `pages.dart`, `lines.dart`, `ayat.dart`, `mutashabih_groups.dart`, `mutashabih_members.dart`). Each is a Drift table class generating **exactly** the §2 DDL. Transcribe every constraint into the table definition — do not validate in Dart:
   - `Mushafs`: `mushafId` TEXT PK; `riwayah`, `name`, `fontFamily`, `checksumSha256` NOT NULL; `lineCount`, `pageCount` NOT NULL INTEGER. `STRICT`.
   - `Surahs`: `surahId` INTEGER PK with `CHECK (surah_id BETWEEN 1 AND 114)`; `nameAr` NOT NULL; `revelation TEXT NOT NULL CHECK (revelation IN ('meccan','medinan'))`; `ayahCount CHECK (ayah_count > 0)`; `bismillahPre CHECK (bismillah_pre IN (0,1))`. `STRICT`.
   - `Pages`: `pageId` INTEGER PK `CHECK (page_id BETWEEN 1 AND 604)`; `juz CHECK (BETWEEN 1 AND 30)`, `hizb CHECK (BETWEEN 1 AND 60)`, `rub CHECK (BETWEEN 1 AND 240)`; `surahStart`/`surahEnd` `REFERENCES surah(surah_id)`; `ayahStart`, `ayahEnd`, `lineCount`, `qpcFontName` NOT NULL. `STRICT`.
   - `Lines`: `lineId` INTEGER PK; `pageId REFERENCES page(page_id)`; `lineNo CHECK (line_no BETWEEN 1 AND 15)`; `lineType TEXT NOT NULL CHECK (line_type IN ('ayah','surah_header','basmala'))`; `ayahRefsJson`, `textGlyphRef` NOT NULL. `STRICT`. Index `line_by_page ON line(page_id, line_no)`.
   - `Ayat`: `ayahId` TEXT PK (`'s:a'`); `surah REFERENCES surah(surah_id)`; `ayah`; `pageId REFERENCES page(page_id)`; `lineRefsJson` NOT NULL; `sajda CHECK (sajda IN (0,1))`. `STRICT`. Index `ayah_by_page ON ayah(page_id)`.
   - `MutashabihGroups`: `groupId` TEXT PK; `type TEXT NOT NULL CHECK (type IN ('identical','near_identical','structural'))`; `noteKey` nullable. `STRICT`.
   - `MutashabihMembers`: `groupId REFERENCES mutashabih_group(group_id)`; `ayahId REFERENCES ayah(ayah_id)`; `distinguishingWordIndexJson` nullable; composite `PRIMARY KEY (group_id, ayah_id)`. `STRICT`.
   Use `@DataClassName(...)` / column overrides so generated names map to the snake_case DDL columns; verify against the §2 SQL that the generated schema is byte-identical to the documented DDL.

4. **Register, but do not write** — add these seven tables to the `@DriftDatabase(tables: [...])` list on `HifzDatabase` in `packages/data/lib/src/db/database.dart` (the read-only block in §1's specification), so `createAll()` materializes them and the user-table FKs in E03-T03 resolve. **Author no DAO over them.** No `daos/PageDao`, no `MushafDao`, nothing that exposes `into(...).insert`, `update(...)`, or `delete(...)` against a reference table. Reads (when E05/E14 need them) are added later as read-only DAO methods in E03-T06; this task's contract is the *absence* of any mutation path, the same enforced-by-absence rule the append-only `review_log` relies on.

5. **The read-only property is structural, not a comment** — the only thing that makes a runtime muṣḥaf write impossible is that no method exists to perform one. Do not add a "// read-only" comment and a public insert method "for tests/seeding"; the asset loader that fills these tables (E05) is the *only* writer and it lives behind the checksum verifier, not behind a general DAO. If a test needs reference rows, seed them through `HifzDatabase.createAll()` + a raw `customStatement`/`batch` confined to the test file, never through a shipped DAO method.

6. **Pitfalls to avoid:**
   - Hardcoding `604`/`15`/`114` anywhere except the `CHECK` ranges that intentionally pin the muṣḥaf's fixed structure — `Mushaf.pageCount`/`lineCount` stay fields so the muṣḥaf is swappable (R2, domain-mushaf-text-integrity).
   - Treating `text_glyph_ref` as text — never `.trim()`/`.split()`/`.toLowerCase()`/`.contains()` it, never log it; it is an opaque address into a glyph table (domain-mushaf-text-integrity pattern 3).
   - Letting a Drift `Companion`/`TableInfo`/row class escape `data` — the DTO mapping (T06) hands out only `models` value types; this task must not export a generated row type from the `data` barrel.
   - A non-`STRICT` table (silent `REAL`/`TEXT` coercion) or validating a range in Dart instead of a `CHECK`.
   - Adding a write DAO "to make seeding convenient", or putting an `INSERT` into the schema task — content + checksum governance is E05; this task is schema-only.
   - Encoding any tafsīr/translation/commentary column, or any sect/madhhab-specific field — the schema is sect-/madhhab-neutral and ships zero tafsīr (R2, domain-adab).
   - Storing a `DateTime` instant anywhere in these tables — reference data has no scheduling days and no event instants; the only date-ish field is `mushaf.checksum_sha256`'s governance, which is a hash, not a time.

## Acceptance criteria

- [ ] Seven reference DTOs exist in `packages/models/lib/src/reference/` — `Page`, `Line`, `Ayah`, `Surah`, `Mushaf`, `MutashabihGroup`, `MutashabihMember` — immutable (`final`, `const`, `copyWith`, value equality), importing `dart:core`/`package:meta` only; verifiable by grep that no `package:drift`/`package:flutter` import appears in `models`.
- [ ] Closed sets are enums (`Revelation`, `LineType`, `MutashabihType`); `Mushaf` carries `riwayah`, `name`, `fontFamily`, `checksumSha256`, and `pageCount`/`lineCount` as fields (not hardcoded); `Line.textGlyphRef` is documented opaque-glyph and is never string-processed.
- [ ] Seven `STRICT` Drift table classes exist in `packages/data/lib/src/db/tables/reference/`, registered in `@DriftDatabase(tables: [...])` on `HifzDatabase`; `dart run drift_dev` generates with no errors.
- [ ] Every `CHECK` and foreign key from `05-persistence-and-encryption.md` §2 is present in the table classes: `surah_id BETWEEN 1 AND 114`, `page_id BETWEEN 1 AND 604`, `line_no BETWEEN 1 AND 15`, `revelation IN ('meccan','medinan')`, `line_type IN ('ayah','surah_header','basmala')`, `type IN ('identical','near_identical','structural')`, `sajda`/`bismillah_pre IN (0,1)`, and the FKs `page→surah`, `line→page`, `ayah→surah/page`, `mutashabih_member→group/ayah`.
- [ ] The indices `line_by_page ON line(page_id, line_no)` and `ayah_by_page ON ayah(page_id)` are created.
- [ ] **No DAO, repository method, or any code path exposes `INSERT`/`UPDATE`/`DELETE` against any reference table** — verifiable by grep and by the read-only enforcement test; the only future reads are read-only DAO methods added in E03-T06.
- [ ] The generated v1 schema for these seven tables is byte-equivalent to the §2 DDL (column names, types, constraints) — confirmed against a committed schema dump.
- [ ] No reference table holds a tafsīr/translation/commentary column or any sect/madhhab-specific field; `*_json` columns are typed `TEXT` carrying only structural refs.

## Tests

All pure `dart test` in `packages/models/test/` and `packages/data/test/` — no widget binding, no Flutter SDK, offline by construction (no networking import in `models`/`data`; a throwing `HttpOverrides` is installed in any `data` test entrypoint so a stray socket fails loudly).

- `packages/models/test/reference/reference_dtos_test.dart` — `copyWith`/value-equality identity for each of the seven DTOs; enum coverage for `Revelation`/`LineType`/`MutashabihType` (every documented variant round-trips through its string form); `Mushaf.pageCount`/`lineCount` are settable fields (a 15-line and a hypothetical alt count both construct) proving the muṣḥaf is not hardcoded; a `Line` constructed with arbitrary `textGlyphRef` bytes preserves them verbatim (opaque-glyph: equality, not normalization).
- `packages/data/test/reference/reference_schema_test.dart` — open an in-memory `NativeDatabase.memory()` `HifzDatabase`, `createAll()`, and assert (a) all seven reference tables and both indices exist (`PRAGMA table_info` / `sqlite_master`); (b) each documented `CHECK` rejects an out-of-range insert via a raw `customStatement` (e.g. `surah_id = 0` and `= 115` both throw; `page_id = 605` throws; `line_no = 16` throws; `revelation = 'martian'` throws; `line_type = 'footnote'` throws; `type = 'thematic'` throws); (c) a foreign-key violation is rejected with `foreign_keys = ON` (an `ayah` referencing a missing `page_id` throws) — this doubles as the constraints-are-in-the-schema proof.
- `packages/data/test/reference/reference_read_only_test.dart` — the correctness-critical guard: assert that the `data` public surface (the `data.dart` barrel + repositories) exposes **no** write method against any reference table. Implement as (a) a source-grep/reflection check that no repository or DAO type declares an insert/update/delete over `Pages`/`Lines`/`Ayat`/`Surahs`/`Mushafs`/`MutashabihGroups`/`MutashabihMembers`, and (b) an assertion that no reference DAO class is exported from the barrel. The intent — "a runtime write to the muṣḥaf is unrepresentable" (R1) — is named in the test.

CI: these run in the `fast` unit job (`docs/engineering/11-testing-strategy.md`); the schema-equivalence check is gated against the committed `drift_schemas/` snapshot so a drift between the DDL and the table classes fails the build.

## Definition of Done

- [ ] All acceptance criteria met; the three test files green locally and in CI's `fast` job.
- [ ] **Quran text fidelity (non-negotiable, R1)**: reference tables are read-only by construction — no write DAO exists, proven by the read-only enforcement test; `line.text_glyph_ref` is opaque and never string-processed; no `*_json` column reconstructs Quran text; the content/checksum that fills these tables is E05's, untouched here.
- [ ] **Sect-/madhhab-neutral adab**: zero tafsīr/translation/commentary columns; no sect/madhhab-specific field; `mushaf.riwayah` names the reading explicitly and `mushaf.pageCount`/`lineCount` keep the muṣḥaf swappable (R2).
- [ ] **Offline / no-network (C1)**: `models` and `data` import no networking package; the `data` reference tests install a throwing `HttpOverrides`; no telemetry, no account, nothing leaves the device.
- [ ] **No AI / no microphone**: nothing in this task touches audio, a microphone, or any model/inference — these are pure structural tables and value types.
- [ ] **Layer boundary**: no `package:drift`/`package:sqlite3` symbol crosses into `models`/`engine`/`features`/`quran`; the table classes live only in `data`; the DTOs only in `models` (banned-import gate green).
- [ ] **RTL + fa/ckb/ar / accessibility**: N/A by construction — these tables and DTOs hold structural data and opaque glyph refs; any user-facing string a consumer derives (e.g. a surah name shown in chrome) is localized at the feature/`l10n` layer, never hardcoded in a record or DAO.
- [ ] **No gamification**: no streak/badge/score/health column; no derived health is persisted (computed on read from `card`, owned elsewhere).
- [ ] **Deterministic tests**: all pure `dart test`, full-word/unit-bearing names, typed `catch`, no `print`/`!`/`late` on persistence values, REUSE SPDX header on every new file; assert behaviour (constraints reject, DTOs round-trip, no write surface), not line counts.
