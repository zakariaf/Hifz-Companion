# E14-T01 — Load the bundled scholar-reviewed mutashābihāt dataset into the read-only reference tables, checksum-governed — test-first

| | |
|---|---|
| **Epic** | [E14 — Mutashābihāt Trainer](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E05, E03 |
| **Skills** | domain-mutashabihat-system, domain-mushaf-text-integrity, eng-write-dart-test |

## Goal

The scholar-reviewed mutashābihāt confusables dataset — shipped as a file in the checksum-pinned core asset pack, scoped to **objective wording only** (`identical | near_identical | structural`) — is parsed and inserted into E03's **read-only** `mutashabih_group` / `mutashabih_member` reference tables during the same `_buildReferenceDb` step that already populates `page`/`line`/`ayah`/`surah`/`mushaf`, and only **after** the file has passed its SHA-256 verification against the manifest baked into the signed binary (fail-closed). The load runs once at onboarding, never at runtime thereafter; no DAO exposes a write to either table; every `mutashabih_member.ayah_id` resolves to a real `ayah` row and every `distinguishing_word_index_json` is a valid in-range index list, or the build refuses the dataset. Authored test-first: the integrity/conformance suite — checksum-gated load, the type-enum guard that rejects a thematic/non-conforming row, the foreign-key/word-index validity check, and "no runtime write surface exists" — all exist and **fail** before the loader is written.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §9.1 | The dataset is a **bundled, scholar-reviewed** set of well-documented near-identical / identical passage groups, **objective wording only (R4)**; each group links the ayāt and the distinguishing word(s)/phrase — this task loads exactly that, nothing thematic or interpretive |
| `docs/PRD.md` §10.1 | The committed reference DDL: `mutashabih_group(group_id PK, type /* identical\|near_identical\|structural */, note_key)` and `mutashabih_member(group_id FK, ayah_id FK, distinguishing_word_index_json)`; reference tables are **read-only (shipped bundled, checksummed), never written at runtime** |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` (framing rule; §1 reference layers) | The text-fidelity covenant this task must not break: the dataset carries only ayah refs and word **indices** — never reconstructed verse text, never tafsīr/translation; `distinguishing_word_index_json` is an index into the bundled word geometry the glyph layer already uses (the overlay is E14-T09; this task only stores valid indices) |
| `docs/engineering/05-persistence-and-encryption.md` §2 (Rationale; the `mutashabih_*` DDL block) | Reference data is **read-only because the Quran is immutable** — forbidden-to-write by construction (no DAO exposes a mutation); the `STRICT` tables, the `type IN ('identical','near_identical','structural')` `CHECK`, the `mutashabih_member` PK `(group_id, ayah_id)` and the `ayah_id`/`group_id` foreign keys are the storage-layer backstop this loader must satisfy |
| `docs/engineering/09-asset-packs-and-offline-integrity.md` §2 (`installCorePack`, `_buildReferenceDb`), §3 (fail-closed SHA-256) | The load rides the **existing** onboarding sequence download → verify → build-DB: the dataset file is one `manifest.files` entry verified by `sha256OfFile` against the binary-baked manifest **before** `_buildReferenceDb` runs; no partially-trusted state is observable; a mismatch is fail-closed (`integrityFailure`), never log-and-continue, and the expected digest comes only from the binary, never a sidecar |
| `docs/science/05-interference-and-mutashabihat.md` §3 | Why objective-wording-only: interference is predictable from **objective** wording overlap (the high-similarity end of the McGeoch & McDonald gradient); the schema's `identical\|near_identical\|structural` typing exists so the trainer weights closest pairs as highest-risk — **never** ship thematic/meaning-based groupings |
| `docs/science/05-interference-and-mutashabihat.md` §7 | The dataset is a **reviewed static prior**, not inferred at runtime (no AI/inference, PRD C2); `mutashabih_group`/`mutashabih_member` ship **read-only and checksummed**; the data is open and community-auditable; until named scholarly sign-off, copy stays an aid (sign-off is E20, not this task) |
| Skill `domain-mutashabihat-system` (+ `template.dart`) | Rule 2 — the dataset is **objective wording only**, ships read-only + checksummed, scoped to `identical\|near_identical\|structural`, **zero** bundled tafsīr/translation; the group set is a static reviewed prior, never inferred; confusion is a property of the **group/pair**; Rule 9 — fully offline (bundled once), deterministic |
| Skill `domain-mushaf-text-integrity` (+ `template.dart`) | The reference data stays the immutable, checksum-governed audit source: this task stores ayah `id`s and word **index** lists, never reconstructed/normalized Quran text or glyph codes; refuse to register/build from an unverified asset; `distinguishing_word_index_json` is a coordinate-into-geometry handle, not text |
| Skill `eng-write-dart-test` (+ `template.dart`) | Test-first; DAO/loader unit tests on an in-memory `NativeDatabase.memory()` executor; `package:test` (the loader is `data`-layer, not a widget); assert behaviour with a meaningful `expect`; the throwing-`HttpOverrides` offline guard stays installed; typed `catch`; REUSE SPDX header; the reference-build path is exercised with a small fixture, not the full 300+-group production file |
| CLAIMS | **C-026** (interference, not time, drives forgetting — a confusion edge is a property of the *pair*), **C-027** (the dataset is **objective near-identical/identical wording only**, scholar-reviewed; the *raison d'être* of this load's scope). Both surface on the science/Mutashābihāt screens (E19); this task ships **no** user-facing number or string of its own and **invents no new CLAIMS id** |
| Siblings: E14-T02, E14-T06, E14-T08/T09, E01 | T02 owns the **user** `confusion_edge` value type + table/DAO — a *different*, read-write graph; this task touches only the read-only `mutashabih_*` reference tables. T06 reads these rows into the group read model + providers. T08/T09 consume `distinguishing_word_index_json` to draw the anchor overlay — this task only **validates and stores** the indices, it renders nothing. E01 owns the CI dataset-checksum/no-network gate scripts; this task supplies the integrity test they run |

## Implementation notes

**TEST-FIRST:** write the integrity/conformance suite in `## Tests` below before the loader body. The checksum-gated-load case, the type-enum guard (reject a non-conforming/thematic row), the FK + word-index validity case, and the "no runtime write surface exists" case must exist and **fail** before `loadMutashabihatInto(...)` is written.

1. **Drift table classes (in `data`), read-only by construction.** If E03/E05 have not already declared them, add the two `STRICT` reference tables as Drift classes in the `data` package (e.g. `packages/data/lib/src/tables/mutashabih_tables.dart`) matching the §10.1 / persistence §2 DDL exactly: `MutashabihGroups` (`groupId TEXT PK`, `type TEXT` with `CHECK (type IN ('identical','near_identical','structural'))`, `noteKey TEXT NULL`) and `MutashabihMembers` (`groupId TEXT REFERENCES mutashabih_group`, `ayahId TEXT REFERENCES ayah`, `distinguishingWordIndexJson TEXT NULL`, PK `(groupId, ayahId)`). Expose a **read-only DAO** — query methods only (`groupsOfAyah`, `membersOfGroup`, `allGroups`); **no** `insert`/`update`/`delete` method is part of the public DAO surface, mirroring the other reference tables. The one-time population is done by the build-DB loader (below), not a public write API.

2. **The loader rides the existing `_buildReferenceDb` step, not a new network/IO path.** Add the mutashābihāt population to the reference-DB build that onboarding already calls **after every core file is hash-verified** (asset doc §2: `await _buildReferenceDb(verifiedFiles)`). Signature shape, in `data`:
   ```dart
   /// Parses the verified mutashābihāt dataset file and populates the read-only
   /// reference tables. Called ONLY from the post-verification _buildReferenceDb
   /// step; never a runtime write path. Throws [MutashabihatDatasetException] on
   /// any non-conforming row so the build fails closed rather than ship a bad prior.
   Future<void> loadMutashabihatInto(
     ReferenceDb db, {
     required File verifiedDatasetFile,
   });
   ```
   This task does **not** open a socket, does **not** re-implement SHA-256 verification, and does **not** call the downloader — the file handed in is the one already verified by `sha256OfFile` against the binary-baked manifest (asset doc §3). The dataset filename is a compile-time `manifest.files` entry (a pinned coordinate), not resolved at runtime.

3. **Parse, then validate every row before any insert (fail-closed).** Read the verified file (a bundled JSON/CSV asset — match whatever the asset-pack format E05/E09 already use for reference data) and validate **before** writing a single row, inside one `db.transaction` so a rejected dataset leaves the tables empty rather than half-populated:
   - **Type guard:** every `group.type` is one of `identical | near_identical | structural`; any other value (including a thematic/meaning label) → `MutashabihatDatasetException`. The `CHECK` is the storage backstop; reject in Dart too so the failure names the offending group.
   - **Foreign-key validity:** every `member.ayahId` resolves to an existing `ayah` row (already loaded in this same build) and every `groupId` is declared; a dangling ref → exception (the `REFERENCES ayah(ayah_id)` FK is the backstop, but `PRAGMA foreign_keys = ON` and an explicit check give a named error).
   - **Word-index validity:** each `distinguishing_word_index_json` parses to a list of non-negative integers within the member ayah's word count (from the bundled geometry); it is **a list of indices into existing word geometry, never text** — reject an out-of-range or non-integer index. (The overlay that *draws* from these indices is E14-T09; this task only guarantees they are storable and in-range.)
   - **Group shape:** a group has ≥ 2 members (a confusion is a property of a *pair/group*, never a lone node); reject a singleton group.
4. **Objective wording only — no tafsīr/translation field is even parsed.** `note_key` is a **localizable resource key** (resolved later by `l10n`), not prose, and certainly not a gloss explaining *why* two verses differ; the loader stores the key verbatim and never an interpretive string. There is no column for, and the parser ignores/rejects, any bundled translation or commentary — that would encode a school of thought (PRD R2/R4; science 05 §3, §6). The loader stores ayah `id`s + word indices + a type + a note key, and nothing that reconstructs the sacred text.
5. **Idempotent, one-time population — never a runtime re-write.** The load happens exactly once, in `_buildReferenceDb`, on a freshly created reference DB; it is not re-run on app launch and there is no "refresh dataset" runtime path (a new dataset ships as a new pinned pack + a reference-DB rebuild, governed by the manifest, not an in-app mutation). Do **not** add a DAO `INSERT` reachable from a widget/controller/engine — the read-only invariant is the first outranking rule (persistence §2; `eng-add-drift-table-or-migration` Rule 3).
6. **Determinism + offline.** No `DateTime.now()`, no `Random`, no network anywhere in the loader; the dataset is bundled once and read offline forever. Parsing is order-stable so two builds of the same file produce byte-identical tables (helps the integrity test and any future content checksum).
7. **`MutashabihatDatasetException` is a sealed/`data`-local error type**, not a bare `throw 'string'`; it names the offending `groupId`/`ayahId` and the failed rule so a bad dataset fails the build with an actionable message (and so the CI dataset gate, E01, can assert on it). It never leaks Quran text or glyph codes into the message.
8. **Pitfalls to avoid:**
   - **Writing the reference tables at runtime** (a stray public `insert` DAO, or running the loader on every launch) — the exact read-only break; population is one-time inside `_buildReferenceDb` only.
   - **Loading before verification** — the file must already have passed `sha256OfFile` vs the binary-baked manifest; never parse a `.part`/temp/unverified file (asset doc §2/§3).
   - **Half-populating on a bad row** — validate-all-then-write inside one transaction; reject the whole dataset on any non-conforming row rather than ship a partial prior.
   - **Storing reconstructed verse text or a tafsīr gloss** — store `ayah_id` refs + word **indices** + a `note_key` only; the parser has no text/translation field.
   - **Accepting a thematic `type`** — the enum is closed to `identical|near_identical|structural`; a meaning-based label is rejected in Dart and by the `CHECK`.
   - **An out-of-range or non-integer word index** silently stored — validate against the ayah's word count; an index the overlay can't resolve must fail the build here, not at render time.
   - **A singleton group** — a group with one member is a non-confusion; reject it (group-not-node).
   - **Importing `drift` outside `data`** — the tables/DAO/loader stay in `data`; no Drift symbol crosses into `models`/`engine`/`features`.

## Acceptance criteria

- [ ] `mutashabih_group` and `mutashabih_member` are `STRICT` Drift tables in `data` matching the §10.1 / persistence §2 DDL (the `type` `CHECK`, the `(group_id, ayah_id)` PK, the `ayah_id`/`group_id` foreign keys); their DAO exposes **query methods only** — no public `insert`/`update`/`delete` exists (verifiable by grep over the DAO).
- [ ] `loadMutashabihatInto(...)` is invoked **only** from the post-verification `_buildReferenceDb` build step, parses the **already-SHA-256-verified** dataset file, and opens no socket and re-implements no hashing (verifiable by grep — no networking/`crypto` import in the loader).
- [ ] Every loaded `group.type` is one of `identical | near_identical | structural`; a non-conforming/thematic type fails the build with a named `MutashabihatDatasetException`, and the tables are left empty (no half-write).
- [ ] Every `member.ayah_id` resolves to an existing `ayah` row and every `group_id` is declared; a dangling reference fails the build with a named error.
- [ ] Every `distinguishing_word_index_json` parses to a list of non-negative integers in range for the member ayah's word count; an out-of-range/non-integer index fails the build (the indices are storable handles for the E14-T09 overlay, never text).
- [ ] A group with fewer than two members is rejected (confusion is a property of the pair/group, not a lone node).
- [ ] The load stores **no** reconstructed verse text, glyph codes, tafsīr, or translation — only ayah `id`s, word indices, a `type`, and a `note_key` resource key; the parser has no text/translation field.
- [ ] The population is one-time and idempotent inside `_buildReferenceDb`; no runtime re-write path exists; the loader contains no `DateTime.now()`/`Random` and no network.
- [ ] Every public declaration carries a `///` doc comment; the file carries the REUSE SPDX header and passes `dart format`/analyzer; `MutashabihatDatasetException` is a typed `data`-local error, not a bare string throw.

## Tests

`packages/data/test/reference/mutashabihat_loader_test.dart` (mirrors the source name), `package:test` + `drift`'s in-memory `NativeDatabase.memory()` reference DB seeded with a tiny fixture set of `surah`/`ayah` rows (so foreign keys resolve), the dataset supplied as a **small in-test fixture file** (a handful of groups, not the full production dataset), `PRAGMA foreign_keys = ON`. The shared throwing-`HttpOverrides` offline bootstrap stays installed (this path opens no socket). Required cases, written **FIRST**:

- **Happy-path load:** a conforming fixture (≥ 2 groups, each ≥ 2 members, valid types, valid word indices over the seeded ayāt) populates exactly the expected `mutashabih_group`/`mutashabih_member` rows; the DAO's `membersOfGroup`/`groupsOfAyah` return them; row counts match the fixture exactly.
- **Type-enum guard (reject thematic/non-conforming):** a fixture with a group whose `type` is anything outside `identical|near_identical|structural` (e.g. a `thematic` label) throws `MutashabihatDatasetException` naming the group, and leaves **both** tables empty (validate-all-then-write — no half-populated state).
- **Foreign-key validity:** a member whose `ayah_id` is not in the seeded `ayah` set, and a member whose `group_id` is undeclared, each fail the build with a named error and no rows are committed.
- **Word-index validity:** a `distinguishing_word_index_json` with a negative, non-integer, or out-of-range index (beyond the member ayah's word count) fails the build; a valid index list loads and round-trips byte-equal.
- **Singleton-group rejection:** a group with one member is rejected (group-not-node / confusion-is-a-pair).
- **No tafsīr/text stored:** assert the stored member rows contain only `ayah_id` + index-list + (group) `type`/`note_key`; the loader exposes/stores no reconstructed-verse-text or translation column (a fixture carrying an extra translation field is ignored/rejected, never persisted).
- **Read-only invariant:** there is no public DAO method that writes `mutashabih_group`/`mutashabih_member` at runtime (compile-time/grep assertion in the test file's doc + an `expect` that the DAO surface is query-only); a second build over a populated DB is the only sanctioned re-population path.
- **Determinism:** loading the same fixture twice produces byte-identical table contents (order-stable parse); no `DateTime.now()`/`Random` is reachable from the loader.

A reference-DB build fixture (alongside the E03/E05 `_buildReferenceDb` test) asserts that the mutashābihāt load runs **after** the `ayah` rows exist and that `PRAGMA integrity_check` returns `ok` over the populated reference DB. All cases run under `dart test` in CI on every PR; the offline guard fails the build on any network attempt; the CI dataset-checksum gate (E01) consumes this loader's integrity behaviour.

## Definition of Done

- [ ] All acceptance criteria met; the test-first integrity/conformance suite is green locally and in CI on every PR.
- [ ] **Offline / no-network:** the dataset is bundled once (one pinned `manifest.files` entry) and loaded offline; the loader opens no socket, imports no networking/`crypto` symbol, and the throwing-`HttpOverrides` guard plus E01's banned-import/no-network gates stay green.
- [ ] **No AI / no microphone / no inference:** the group set is the **bundled scholar-reviewed static dataset** loaded verbatim; nothing infers "similar verses", trains on data, or captures audio at any point in the load (PRD C2, R5; science 05 §3, §7).
- [ ] **Quran text fidelity (existential):** the load stores ayah `id`s + word **indices** + `type` + `note_key` only — never reconstructed/normalized verse text or glyph codes; reference tables stay **read-only, checksum-governed**; the file is parsed only **after** its SHA-256 matches the binary-baked manifest (fail-closed); a non-conforming dataset fails the build rather than ship a bad prior (PRD R1, §11.1.1; doc 08 framing rule; doc 09 §3).
- [ ] **Objective wording only, zero tafsīr:** the dataset is scoped to `identical | near_identical | structural` and rejects any thematic/interpretive type; **no** tafsīr or translation is parsed or stored, and `note_key` is a localizable resource key, never a gloss (PRD R2, R4; science 05 §3; CLAIMS C-027).
- [ ] **Group-not-node / nothing safe to drop:** a confusion is a property of the group/pair — singleton groups are rejected; this task adds no "cured"/"resolved"/"safe to drop" flag, no scoreboard, and no gamified affordance (the calm trainer/hotspots reading these rows are E14-T07/T08/T10).
- [ ] **Deterministic:** no `DateTime.now()`/`Random` in the loader; identical input file → byte-identical tables; the load is one-time and idempotent inside `_buildReferenceDb`.
- [ ] **RTL + fa/ckb/ar strings / accessibility:** N/A by construction at the load layer — the loader holds reference value types and renders no user-facing string; `note_key` is resolved to a transcreated, sect-neutral, calm fa/ckb/ar string by `l10n` at the feature layer (E14-T11), never hard-coded here.
- [ ] **No unsourced number:** the task surfaces no user-facing number or claim; the dataset's scope is the already-graded CLAIMS rows C-026/C-027 (rendered on the science screen in E19), and **no** CLAIMS id is invented.
- [ ] Every Dart file carries the REUSE SPDX header and `///` docs on public APIs; typed `catch`, no `print`/`!`/`late` on persistence values; the DAO surface is query-only; passes the analyzer/lint config and `dart format`.
