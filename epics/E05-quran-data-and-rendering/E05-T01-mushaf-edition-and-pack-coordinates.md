# E05-T01 — MushafEdition triple model + PackCoordinates pinned tag + the core-pack manifest schema

| | |
|---|---|
| **Epic** | [E05 — Quran Data & Immutable Rendering](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E01 (the `models` + `assets` package stubs and the no-network / banned-import gates), E03 (the read-only `mushaf` reference table + `app_meta` row this triple is loaded into downstream) |
| **Skills** | domain-mushaf-text-integrity, domain-asset-pack-integrity, eng-add-persisted-model |

## Goal

The Quran-data spine's compile-time facts exist as three immutable artifacts: (1) `MushafEdition`, the co-versioned triple `{mushafId, riwayah, displayName, pageCount, lineCount, textSha256, layoutSha256, fontSha256[1..604]}` as a pure value type in `models`, defaulting to KFGQPC Madani 15-line Ḥafṣ ʿan ʿĀṣim QPC V2 with `pageCount`/`lineCount` as parameters (never hardcoded `604`/`15`); (2) `PackCoordinates`, the compile-time constants in `assets` carrying the **exact pinned tag** (never `latest`) and the GitHub immutable-Release asset base URL; and (3) the pinned **core-pack manifest schema** — one `{name, sha256, bytes, source, license}` entry per file, covering the Tanzil text, QUL layout, the mutashābihāt dataset, and all 604 QPC fonts — baked into the binary as the independent trust channel. No downloader, no verifier, no rendering: this task lays the data definitions every sibling task consumes, and gives the no-network gates nothing to catch.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §1 | The `MushafEdition` triple verbatim shape (`mushafId`/`riwayah`/`displayName`/`pageCount`/`lineCount`/`textSha256`/`layoutSha256`/`fontSha256[1..604]`); three separately-licensed co-versioned layers; default edition = KFGQPC Madani 15-line, Ḥafṣ ʿan ʿĀṣim, QPC V2; "we refuse to mix layers across editions" (one `mushafId` binds one `{text, layout, fonts}`); text is the audit source, never a render input |
| `docs/engineering/09-asset-packs-and-offline-integrity.md` §1 | `PackCoordinates` (`repo`, exact `pinnedTag`, `assetUrl(fileName)` → `github.com/<repo>/releases/download/<tag>/<file>`); the `core.manifest.json` schema (per file: `name`, `sha256`, `bytes`, `source`, `license`); the pack taxonomy (core / reciter-audio / alt-muṣḥaf — only core modelled here); "we refuse `latest` or any moving release pointer"; the manifest's `source + license` exist for the R2 attribution surface |
| `docs/PRD.md` §11.1, §11.1.1 | The asset-pack table (core = Tanzil text + QUL layout + KFGQPC QPC fonts + mutashābihāt dataset); pinned SHA-256 checksums + pinned release version ship in the binary; the request carries only a public asset URL |
| `docs/PRD.md` R1, R2 | R1 — text fidelity is existential (the SHA-256 fields exist to make a wrong byte unrepresentable); R2 — the muṣḥaf is a swappable asset and the riwāyah is named, which is *why* the model is a triple keyed by `mushafId` and carries `riwayah`/`displayName` |
| Skill **domain-mushaf-text-integrity** (+ `template.dart`) | Canonical pattern step 1 (model the muṣḥaf as the immutable co-versioned triple, never a blob; `pageCount`/`lineCount` are parameters); the Do/Don't row "Store the muṣḥaf as one blob, or hardcode 604/15"; the checklist line "edition is a `MushafEdition` triple keyed by `mushafId`; `riwayah`/`displayName` set; `pageCount`/`lineCount` are parameters" |
| Skill **domain-asset-pack-integrity** (+ `template.dart`) | Canonical pattern step 1 (pin pack identity at compile time, never resolve `latest`) and step 2 (three packs, one taxonomy; the manifest records `sha256` **and** `source + license` per file); the checklist lines "Pack coordinates are compile-time constants … exact `pinnedTag` (never `latest`)" and "the pinned SHA-256 manifest … records `sha256` + `source` + `license` per file" |
| Skill **eng-add-persisted-model** | The value type lives in the pure `models` package, immutable (`final` fields, `const` constructor, `copyWith`), `dart:core`/`package:meta` only — no `package:drift`, no `package:flutter`; full-word identifiers carrying units; closed sets are enums; user-facing strings (`displayName`, `riwayah` glosses) belong to `l10n`, not hardcoded into a record — but the riwāyah *identifier* itself is data, not localized copy |
| `docs/science/CLAIMS.md` C-031, C-048 | C-031 — "604 pages, one card per page": the `pageCount` default of 604 is the count this claim rests on (and is parameterised, not asserted as a universal truth). C-048 — "one-time, checksum-verified public asset download": the manifest's per-file `sha256` is the data behind that promise. No on-screen number is *rendered* by this task; both ids are cited because the constants this task defines back those claims |
| Siblings: E05-T02, E05-T03, E05-T04, E05-T05, E05-T10 | T02's `PackDownloader` calls `PackCoordinates.assetUrl(...)`; T03's verifier compares a file's hash against this manifest's `sha256`; T04's `installCorePack` iterates `manifest.files` and stamps `text_checksum_verified_at` (E03's `app_meta`); T05 loads the verified triple into E03's read-only `mushaf` reference table; T10's CI checksum gate asserts every manifest entry matches the release + the authoritative Tanzil hash. This task ships **only** the definitions those tasks consume |

## Implementation notes

This task defines data, not behaviour; there is no I/O, no clock, no network, and no rendering. Keep the three artifacts in their correct packages so the layering and no-network gates stay green by construction.

1. **`MushafEdition` value type** → `packages/models/lib/src/quran/mushaf_edition.dart` (barrel-exported from `lib/models.dart`). An immutable value type: `final` fields, a `const` constructor, and a `copyWith` (per eng-add-persisted-model). Imports `dart:core`/`package:meta` only — **no** `package:drift`, **no** `package:flutter`, no networking. Fields exactly per engineering 08 §1:
   - `final String mushafId;` — e.g. `'kfgqpc_hafs_madani_v2'`; the single key that binds the triple (one `mushafId` ⇒ one `{text, layout, fonts}`).
   - `final String riwayah;` — `'Ḥafṣ ʿan ʿĀṣim'` (the transliterated domain identifier, data not localized chrome).
   - `final String displayName;` — `'Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf'`; shown around the page, never "the Quran" absolutely (R2). It is a default seed value here; the *localized* presentation of edition chrome is E05-T09 / `l10n`, not this record.
   - `final int pageCount;` — **a parameter** (604 for Madani 15-line), never a hardcoded literal in render/layout code.
   - `final int lineCount;` — **a parameter** (15), never hardcoded.
   - `final String textSha256;` `final String layoutSha256;` — the Tanzil text and QUL layout asset digests.
   - `final Map<int, String> fontSha256;` — page `1..pageCount` → that page's font-file digest; expose it as `Map<int, String>` (or an `UnmodifiableMapView`) so it cannot be mutated after construction.
2. **The default edition as a `const`/factory** → a named constructor or top-level `const kKfgqpcHafsMadaniV2Edition`-style seed in the same library that sets `mushafId`/`riwayah`/`displayName`/`pageCount: 604`/`lineCount: 15`. The actual hash *values* are filled by E05-T10's pipeline against the published release; this task may seed them from the pinned manifest constants below (single source of truth) or leave a typed `// TODO(E05-T10): pin from release` for the digest literals — but the *shape* and the parameterised counts are complete here.
3. **`PackCoordinates`** → `packages/assets/lib/src/pack_coordinates.dart`. Compile-time constants only, per engineering 09 §1:
   ```dart
   class PackCoordinates {
     static const repo = 'hifz-companion/quran-assets';
     static const pinnedTag = 'core-v1.0.0';   // EXACT tag — never 'latest'
     static Uri assetUrl(String fileName) => Uri.parse(
           'https://github.com/$repo/releases/download/$pinnedTag/$fileName',
         );
   }
   ```
   No code path resolves "newest". `assetUrl` is a pure function of the pinned tag. This file declares **no** networking import — it only builds a `Uri` string; `dio`/`http`/`HttpClient` belong to E05-T02's downloader, not here.
4. **The manifest schema** → `packages/assets/lib/src/core_pack_manifest.dart`. An immutable `ManifestEntry` value type `{String name, String sha256, int bytes, String source, String license}` (`const` constructor, `final` fields) and a `CorePackManifest` `{String pack, String tag, String mushafId, List<ManifestEntry> files}`. The embedded constant `EmbeddedManifest.core` (or `kCorePackManifest`) is the pinned manifest **baked into the binary** — the independent trust channel; it is a Dart constant, never read from a sidecar `SHA256SUMS` file at runtime. It must enumerate one entry per file: `quran-uthmani.db` (`source: 'tanzil.net'`, `license: 'verbatim+attribution'`), `layout-qul.json` (`source: 'qul.tarteel.ai'`, `license: 'QUL'`), `mutashabihat.json` (`source: 'repo'`, `license: 'CC-BY (scholar-reviewed)'`), and `QCF_P001.ttf … QCF_P604.ttf` (each `source: 'kfgqpc'`, `license: 'KFGQPC'`). Generate the 604 font entries with a documented build helper (a `tool/` script that emits the constant list) rather than 604 hand-written lines — keep the *list* a constant, the *generator* auditable. The `bytes` and `sha256` literals are pinned by E05-T10's pipeline; seed placeholders with a typed TODO if the release is not yet cut.
5. **Keep `mushafId` consistent across all three.** `MushafEdition.mushafId`, `CorePackManifest.mushafId`, and the `pinnedTag`'s edition all refer to the same physical muṣḥaf. A `const` assert / unit test ties them together so a future edition swap cannot silently pair a `core-v1.0.0` tag with a `v2` layout.
6. **Pitfalls to avoid:** hardcoding `604`/`15` anywhere the model can be read instead (the parameterisation is the whole point of swappability — R2); importing `package:drift`/`package:flutter`/any networking package into `models` (a compile-time layering break — engine/quran/features see only the value type); resolving `latest` or adding a "newer pack" pointer (forecloses the no-second-trust covenant); putting the manifest in a sidecar file the app parses at runtime (it must be a binary constant — the trust channel); widening `ManifestEntry` toward parsing attestation/Sigstore data (CI/audit only, never in-app); spelling the font asset names as anything but the published `QCF_P###.ttf` form; and treating `fontSha256` as a growable map (it must be unmodifiable post-construction).

## Acceptance criteria

- [ ] `MushafEdition` exists in `packages/models/lib/src/quran/mushaf_edition.dart`, is immutable (`final` fields, `const` constructor, `copyWith`), and is barrel-exported; the `models` package imports `dart:core`/`package:meta` only — no `package:drift`, no `package:flutter`, no networking import (verifiable by grep over the file and by the E01 manifest audit).
- [ ] `MushafEdition` carries exactly `{mushafId, riwayah, displayName, pageCount, lineCount, textSha256, layoutSha256, fontSha256}` with `fontSha256: Map<int, String>` keyed `1..pageCount`; `pageCount` and `lineCount` are constructor parameters, and no `604`/`15` literal appears in any render/layout/model code path (only as default-seed argument values).
- [ ] A default-edition seed (`const`/factory) sets `mushafId: 'kfgqpc_hafs_madani_v2'`, `riwayah: 'Ḥafṣ ʿan ʿĀṣim'`, `displayName: 'Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf'`, `pageCount: 604`, `lineCount: 15`.
- [ ] `PackCoordinates` exists in `packages/assets/lib/src/pack_coordinates.dart` with `repo`, an **exact** `pinnedTag` (string literal, never `'latest'`, no moving-pointer resolution), and a pure `assetUrl(fileName)` producing `https://github.com/<repo>/releases/download/<tag>/<file>`; the file declares no networking import.
- [ ] `ManifestEntry` `{name, sha256, bytes, source, license}` and `CorePackManifest` `{pack, tag, mushafId, files}` exist in `packages/assets/lib/src/core_pack_manifest.dart` as immutable value types; the embedded `EmbeddedManifest.core` constant is baked into the binary (a Dart constant, not read from a runtime file).
- [ ] `EmbeddedManifest.core.files` enumerates one entry per core file: the Tanzil text, the QUL layout, the mutashābihāt dataset, and all 604 `QCF_P###.ttf` fonts; every entry records a non-empty `source` and `license` (the R2 attribution surface); `files.length == 1 + 1 + 1 + pageCount` for the default edition.
- [ ] `MushafEdition.mushafId`, `CorePackManifest.mushafId`, and the manifest `tag` are mutually consistent for the default edition (asserted by a unit test).
- [ ] Every `public` declaration carries a `///` doc comment; `dart format` + analyzer/lint clean; the REUSE license header is present.

## Tests

`packages/models/test/quran/mushaf_edition_test.dart` and `packages/assets/test/core_pack_manifest_test.dart` (mirror the source paths), plain `dart test` (pure, offline by construction — no `HttpOverrides` needed because no file touches the network; the test bootstrap still installs the throwing `HttpOverrides` from E01 and these tests must not trip it). Required cases:

- **Triple shape & immutability**: a `MushafEdition` round-trips its fields; `copyWith` produces an independent value; `fontSha256` cannot be mutated through the exposed map (mutation throws / is a compile error); two equal editions compare equal (if `==`/`hashCode` are defined).
- **Parameterised counts**: constructing an edition with `pageCount: 548, lineCount: 16` is accepted and read back unchanged — proving `604`/`15` are not baked in (the swappability contract, R2).
- **Default edition seed**: the default value has `mushafId == 'kfgqpc_hafs_madani_v2'`, `riwayah == 'Ḥafṣ ʿan ʿĀṣim'`, `displayName == 'Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf'`, `pageCount == 604`, `lineCount == 15`, and `fontSha256` is keyed exactly `1..604`.
- **`PackCoordinates` pinning**: `pinnedTag` is a non-empty literal and is **not** `'latest'`; `assetUrl('QCF_P001.ttf')` equals `https://github.com/hifz-companion/quran-assets/releases/download/core-v1.0.0/QCF_P001.ttf`; `assetUrl` is pure (same input → same `Uri`).
- **Manifest coverage**: `EmbeddedManifest.core.files` contains the text, layout, and mutashābihāt entries plus exactly 604 `QCF_P###.ttf` entries with no gaps or duplicates (`P001`…`P604`); `files.length == 607`.
- **Manifest attribution invariant**: every `ManifestEntry` has non-empty `source` and `license`; the Tanzil entry's `source` is `'tanzil.net'`, the QUL entry's is `'qul.tarteel.ai'`, the font entries' `source` is `'kfgqpc'` (the lawful-redistribution / R2 surface).
- **Cross-artifact consistency**: `MushafEdition` default `mushafId` == `CorePackManifest.mushafId` == the edition implied by `PackCoordinates.pinnedTag`.

No golden, widget, or integration test in this task — there is nothing rendered, persisted, or fetched. Verifier behaviour (single-byte-flip / truncation rejection) is E05-T03; the CI checksum gate against the real release is E05-T10.

## Definition of Done

- [ ] All acceptance criteria met; both unit suites green under `dart test` locally and in CI.
- [ ] **Offline / no-network:** no file in this task imports `dio`/`http`/`dart:io HttpClient`/any networking symbol; `PackCoordinates` only builds a `Uri` string and resolves no `latest` pointer; the E01 banned-import + dependency-allow-list gates stay green; the throwing `HttpOverrides` is never tripped by these tests.
- [ ] **No AI / no microphone:** nothing here touches AI, ASR, or audio; the reciter-audio and alt-muṣḥaf packs are *not modelled* in this task (core only), so no inert-audio surface is introduced.
- [ ] **Quran text fidelity (existential):** the model holds only SHA-256 *digests* and counts — no Quran text, no glyph codes, no layout bytes; the digest fields exist precisely so a wrong byte is unrepresentable downstream (R1); the manifest is the binary-baked independent trust channel, never a runtime sidecar.
- [ ] **Swappability / sect-neutral adab:** the muṣḥaf is a triple keyed by `mushafId`; `riwayah` and `displayName` are set; `pageCount`/`lineCount` are parameters; `displayName` names the riwāyah and is never "the Quran" absolutely; the model encodes no tafsīr/translation and no madhhab assumption; per-file `source`/`license` carry the Tanzil/QUL/KFGQPC attribution downstream surfaces (R2).
- [ ] **RTL + fa/ckb/ar:** N/A by construction — this task defines value types and constants, not user-facing strings; `riwayah`/`displayName` defaults are domain data (the *localized* edition chrome and its FSI/PDI-isolated, locale-numeral presentation land in E05-T09 via `l10n`), and no string is hardcoded into a render path here.
- [ ] **Accessibility:** N/A — no widget, no `Semantics`; the accessible edition label is rendered by E05-T09.
- [ ] **Nothing safe to drop:** the model marks no page optional, droppable, or "done"; `pageCount`/`fontSha256` cover the whole muṣḥaf with no per-page omission.
- [ ] **Deterministic tests:** suites are pure `dart test`, no clock, no network, no randomness; every `public` member has a `///` doc comment and the file carries its REUSE header; `dart format` + analyzer/lint clean.
