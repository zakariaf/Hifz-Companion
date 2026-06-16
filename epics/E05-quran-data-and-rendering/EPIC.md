# E05 — Quran Data & Immutable Rendering

The offline Quran-data spine: the one-time asset-pack downloader (GitHub immutable Releases, exact-tag pinned, per-file SHA-256 fail-closed), the verified reference-data load (Tanzil text + QUL page/line/word geometry into the read-only Drift reference tables), and the immutable rendering primitive — select the page's dedicated KFGQPC glyph font and *draw* it (the OS shaper never lays out Quran text), markers as coordinate overlays on the glyph layer, zoom/theme as layer transforms. Ships with the explicit riwāyah, the runtime "refuse unverified assets" gate, and the CI text/font checksum + 604-page visual-diff that make "one wrong diacritic ends the project" a build invariant rather than a hope.

## Why this epic exists

The whole product is a retention engine for the muṣḥaf, and PRD R1 makes one thing existential before any feature: a single altered or misplaced diacritic ends the project (PRD §4 R1; engineering 08 framing rule). Every later epic that puts Quran text on screen — the reader (E13), the recite/grade flow (E12), the mutashābihāt drills (E14), the heat-map's page detail (E15) — draws on the rendering primitive and the verified data this epic establishes; if that primitive is wrong, or if a tampered byte can reach the screen, the trust that makes this app *ṣadaqah jāriyah* collapses (engineering 08 §2, the existential decision). The category's documented failure mode is precisely the seam this epic owns: Flutter's Arabic shaping is font-, platform-, and backend-dependent and has shipped misplaced-diacritic and shattered-ligature bugs (`flutter#16886`, `#143975`, `#119805`; engineering 08 §2), so the only safe answer is to *refuse to shape the muṣḥaf at all* — draw pre-shaped per-page glyph codes in their dedicated KFGQPC font and let a missing glyph fail loudly as visible tofu rather than re-shape silently. The second existential seam is the network: the app's privacy covenant (no microphone, no telemetry, airplane-mode forever — CLAIMS C-048, PRD R5/C1) depends on the asset download being the *single* moment trust is extended to the network, fail-closed and quarantined, after which the verified local muṣḥaf is the root of trust for the life of the install (engineering 09 framing rules). This epic builds both seams while the surface is still small — the downloader, the verifier, the reference-data load, and one immutable page renderer with its CI gates — so that every feature epic extends a spine already proven byte-exact and offline, instead of discovering a fidelity or privacy break during release hardening.

## Scope

### In scope

- The `MushafEdition` immutable triple model `{textSha256, layoutSha256, fontSha256[1..604]}` keyed by `mushafId`, carrying `riwayah`/`displayName`, with `pageCount`/`lineCount` as parameters (default: KFGQPC Madani 15-line, Ḥafṣ ʿan ʿĀṣim, QPC V2).
- The `/assets` pack downloader: the single whitelisted networking module — `dio` HTTPS GET to a compile-time **exact pinned tag** on a GitHub immutable Release, no auth/cookies/identifiers/custom User-Agent, `CancelToken` + timeouts, download-to-temp `.part`.
- The pinned core-pack **manifest** baked into the binary (per file: `sha256` + `source` + `license`) covering Uthmani text, QUL layout, the mutashābihāt dataset, and all 604 QPC fonts.
- The chunked SHA-256 verifier and its total fail-closed state machine: match → promote; mismatch → delete + re-fetch **once**; still mismatch → refuse to render Quran text; missing/truncated → mismatch.
- The sequenced `installCorePack` (download → verify → promote to app-documents → build reference DB → stamp `text_checksum_verified_at`), with no partially-trusted state ever observable.
- Building the verified bytes into the **read-only** Drift reference tables (`mushaf`/`page`/`line`/`ayah` and the layout geometry) consumed downstream, with checksum-governed load.
- Registering the 604 per-page KFGQPC fonts at runtime via `FontLoader` **only** after each passes `vault.readVerified(expectedSha256:)`.
- The immutable page renderer: glyph-only `GlyphLine` drawing (`fontFamily: qpcFontFamily(page)`, `fontFamilyFallback: const []`, `TextDirection.rtl`), data-driven page assembly grouped by `page-{p}-line-{l}` (never by verse, no `softWrap`/`TextPainter` line-breaking).
- The `MushafOverlayPainter`: markers as `(page, line, position)` coordinate rectangles over the glyph layer, holding no text and measuring no shaped Arabic.
- Zoom (uniform `Transform.scale`, RTL `topRight` origin) and sepia/dark (`ColorFiltered`) as layer transforms; RTL-aware `PageView` navigation rebuilding with a new `pageNumber`/geometry only.
- The riwāyah/edition chrome label (shaped `type.*` UI text, locale numerals) shown around the page; the byte-for-byte/attribution guarantee text for About/Credits.
- CI gates: text/layout/604-font SHA-256 match the release and the authoritative Tanzil hash; the 604-page visual-diff with **real KFGQPC fonts** (never Ahem) on min-OS iOS+Android within a tight tolerance; sajda/ayah-numbering/basmala spot-checks; the runtime "refuse unverified" guard.

### Out of scope

- Reciter-audio packs and future alt-muṣḥaf packs fetched on demand → deferred; the taxonomy is modelled here, but only the core pack is implemented in E05 (alt-muṣḥaf swap surfaces in **E16 settings/muṣḥaf picker**).
- The full muṣḥaf **reader feature** — bottom-nav tab, route, ViewModel, jump-to-juz/ḥizb/surah, "mark my memorized range", "start revision here" → **E13 muṣḥaf-reader** (consumes this epic's page renderer).
- The recite-from-memory reveal/grade flow drawn over the page → **E12 today-and-recite-grade**.
- *Which* words a mutashābihāt/weak-line marker covers (the confusables dataset, confusion log, anchor-hint content) → **E14 mutashabihat-trainer**; this epic only paints a marker it is handed.
- The onboarding *flow* sequencing around the download (welcome, coverage capture, per-juz confidence, cycle preset) → **E11 onboarding-and-cold-start**; this epic owns only the download/verify step it embeds.
- The read-only reference-table **DDL and migration mechanics** (the Drift schema for `mushaf`/`page`/`line`/`ayah`) → owned by **E03 models-and-persistence**; this epic *loads verified bytes into* those tables.
- The no-network CI gate, dependency allow-list, banned-import lint, and airplane-mode acceptance test → authored as gates in **E01 repo-scaffold-and-ci**; this epic must simply give them nothing to catch.
- Localized chrome strings beyond the download/riwāyah surfaces, and the calm color/motion tokens an overlay paints with → **E09 localization-rtl** / **E10 component-library** (this epic references token *names* only).

## Dependencies

### Depends on

- **E01 repo-scaffold-and-ci** — the package layout (`/engine`, `/data`, `/assets`, `/quran`), the banned-import / no-network / dependency-allow-list gates this epic's single quarantined socket must satisfy, and the CI golden/checksum job shapes the new gates plug into.
- **E03 models-and-persistence** — the read-only Drift reference-table schema (`mushaf`/`page`/`line`/`ayah` and layout geometry), the single-write-path transaction, and the `app_meta` row (`text_checksum_verified_at`) the verified load builds into and stamps.

### Enables

- **E11 onboarding-and-cold-start** — embeds the core-pack download/verify step inside the onboarding flow.
- **E12 today-and-recite-grade** — draws the reveal/grade surface over this epic's immutable page renderer.
- **E13 muṣḥaf-reader** — the reader feature consumes the page view, overlay painter, zoom/theme transform, and RTL paging.
- **E14 mutashabihat-trainer** — paints anchor/discrimination overlays via the coordinate `OverlayMarker` contract established here.
- **E15 progress-and-heatmap** — the page-detail sheet renders a page through this primitive.
- **E16 settings-profiles-teacher** — the muṣḥaf/riwāyah picker swaps the `MushafEdition` triple this epic made swappable.

## Foundation inputs

| Input | Where (doc/skill) | What this epic takes from it |
|---|---|---|
| Three reference layers (text / layout / fonts) | docs/engineering/08-quran-data-and-immutable-rendering.md §1 | The co-versioned `MushafEdition` triple, three separate licences + checksums, text-is-audit-source-never-render-input rule |
| Glyph-font rendering, not the OS shaper | docs/engineering/08-quran-data-and-immutable-rendering.md §2 | `GlyphLine`, `buildGlyphLine`, `qpcFontFamily`, empty `fontFamilyFallback`, `registerVerifiedPageFonts` via `FontLoader` |
| Layout is data, never runtime line-breaking | docs/engineering/08-quran-data-and-immutable-rendering.md §3 | `assemblePage` grouping by `page-{p}-line-{l}`, line types, no `softWrap`/`TextPainter` on Quran text |
| Overlays as coordinates | docs/engineering/08-quran-data-and-immutable-rendering.md §4 | `OverlayMarker`, `MushafOverlayPainter`, `(page,line,position)` refs, never re-typeset or stored reconstructed text |
| Themes / zoom transform the layer | docs/engineering/08-quran-data-and-immutable-rendering.md §5 | `mushafPageView` uniform `Transform.scale` (RTL topRight) + `ColorFiltered`; no per-theme font swap, no muṣḥaf reflow |
| Integrity pipeline (CI + runtime + visual-diff) | docs/engineering/08-quran-data-and-immutable-rendering.md §6; docs/PRD.md §11.3 | `verifyAssetIntegrity`, the real-font 604-page goldens, the test-vector table (sajda/ayah-numbering/basmala), refuse-unverified |
| Pack hosting + pinning | docs/engineering/09-asset-packs-and-offline-integrity.md §1; docs/PRD.md §11.1 | `PackCoordinates` exact pinned tag, immutable-Release asset URL, the manifest schema (`sha256`+`source`+`license`), pack taxonomy |
| One-time download | docs/engineering/09-asset-packs-and-offline-integrity.md §2; docs/PRD.md §11.1.1, §12.1 | The quarantined `PackDownloader` (`dio`, temp `.part`, no identifiers), sequenced `installCorePack`, calm offline/interrupted/ready states |
| Runtime SHA-256 fail-closed | docs/engineering/09-asset-packs-and-offline-integrity.md §3 | `sha256OfFile` (chunked), the total fail-closed state machine, the single-byte-flip / truncation golden rejections, the known SHA-256 anchors |
| TLS without cert pinning | docs/engineering/09-asset-packs-and-offline-integrity.md §5 | TLS 1.2+/1.3 via platform trust store, no cert/key pinning, no `badCertificateCallback => true` |
| Quran structure (fixed reference data) | docs/PRD.md §6.1 | 30 juz → 60 ḥizb → 240 rubʿ → 604 pages → 15 lines/page → 6,236 ayah hierarchy, read from data, never recomputed |
| Skill: asset-pack integrity | .claude/skills/domain-asset-pack-integrity | The download/verify canonical pattern, the fail-closed checklist, the socket-quarantine rule |
| Skill: muṣḥaf text integrity | .claude/skills/domain-mushaf-text-integrity | The `MushafEdition` triple, glyph-only rendering, data-driven layout, coordinate overlays, riwāyah naming, integrity gates |
| Skill: muṣḥaf page view | .claude/skills/ui-mushaf-page-view | The dumb RTL page-view widget, the overlay painter, the zoom/theme transform frame, the real-font golden |
| Skill: feature module / Riverpod store | .claude/skills/eng-add-feature-module, eng-create-riverpod-store | The `/quran` module placement, the reader-state provider shape (current page, zoom, theme) the renderer reads |
| Skill: service boundary | .claude/skills/eng-define-service-boundary | The injectable `AssetVault`/downloader boundary behind a Dart interface with a deterministic fake, so tests stay offline |
| Skill: tests / CI checks | .claude/skills/eng-write-dart-test, eng-add-ci-check | The real-font muṣḥaf golden harness, the `HttpOverrides`-that-throws offline guard, the checksum/visual-diff CI gate shape |
| Claims behind on-screen numbers | docs/science/CLAIMS.md C-031, C-048 | "604 pages, one card per page" framing (C-031); "fully offline, never records voice, one-time checksum-verified download" (C-048) |

## Deliverables

- [ ] `MushafEdition` value type in the models package: `{mushafId, riwayah, displayName, pageCount, lineCount, textSha256, layoutSha256, fontSha256[1..604]}`, default KFGQPC Madani 15-line Ḥafṣ ʿan ʿĀṣim QPC V2.
- [ ] `PackCoordinates` with the exact pinned tag + GitHub immutable-Release asset base URL as compile-time constants in `/assets`.
- [ ] The pinned core-pack manifest baked into the binary, each entry `{name, sha256, bytes, source, license}` for text, QUL layout, mutashābihāt, and all 604 fonts.
- [ ] The quarantined `PackDownloader` (`dio`, `CancelToken`, `connectTimeout`/`receiveTimeout`, temp `.part`, zero identifiers) behind an injectable boundary with a deterministic fake double.
- [ ] The chunked `sha256OfFile` verifier + the total fail-closed `verifyAndPromote` state machine.
- [ ] The sequenced `installCorePack` (download → verify → promote → build reference DB → stamp `text_checksum_verified_at`) and the calm `awaitingFirstDownload` / `downloadInterrupted` / `ready` onboarding states (fa/ckb/ar, RTL).
- [ ] The verified reference-data load into E03's read-only Drift `mushaf`/`page`/`line`/`ayah` + layout tables, checksum-governed.
- [ ] `registerVerifiedPageFonts` loading the 604 QPC fonts via `FontLoader` only after each passes its hash.
- [ ] The immutable `MushafPageView` (glyph-only `GlyphLine` builder, empty fallback, RTL), `assemblePage` grouped by page-line, and the `MushafOverlayPainter` (coordinate-only).
- [ ] The zoom/theme transform frame (uniform scale + `ColorFiltered`) and the RTL-aware `PageView` navigation.
- [ ] The riwāyah/edition chrome label (shaped, locale numerals) and the byte-for-byte attribution text for About/Credits.
- [ ] CI: the checksum gate (text/layout/604 fonts vs release + authoritative Tanzil hash), the 604-page real-font visual-diff on min-OS iOS+Android with sajda/ayah-numbering/basmala spot-checks, and the runtime refuse-unverified guard.
- [ ] Test suites: the fail-closed verifier (single-byte-flip + truncation rejected; known SHA-256 anchors), the page-assembly/overlay-geometry units, and the real-font muṣḥaf golden across light/sepia/dark + zoom in RTL.

## Definition of Done

- [ ] **Offline / no-network:** the only networking import in the whole app is the `/assets` downloader; E01's banned-import + dependency-allow-list gates stay green; tests install an `HttpOverrides` that throws; after the one verified core-pack download every Quran path renders with the radio off.
- [ ] **No AI / no microphone:** nothing in the download, verify, load, or render path uses AI, ASR, or audio; reciter packs (modelled, not implemented) are inert bytes fetched only on demand.
- [ ] **Text fidelity (existential):** Quran text is stored byte-for-byte (Tanzil Uthmani) and used only for structure/audit, never drawn and never a layout input; pages render glyph-only with `fontFamilyFallback: const []`; a single-byte-flipped and a truncated pack are golden-*rejected*; CI fails on any text/layout/font SHA-256 drift vs the release or the authoritative Tanzil hash.
- [ ] **Fail-closed verification:** the state machine is total (match → promote; mismatch → re-fetch once; still mismatch → refuse to render Quran text; missing/truncated → mismatch); no soft path, SHA-256 only, exactly one re-fetch; the app refuses to render any unverified Quran asset.
- [ ] **Immutable rendering:** the OS shaper is never asked to lay out Quran text; line/page breaks come only from the QUL dataset (grouped by page-line, never verse, no `softWrap`/`TextPainter`); markers are coordinate rectangles holding no text; zoom is a uniform scale and sepia/dark a `ColorFilter` — no per-theme font swap and no muṣḥaf reflow; missing glyphs surface as visible tofu.
- [ ] **Sect-neutral adab:** the riwāyah is named (`displayName` "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"); the page is never called "the Quran" absolutely; zero tafsīr/translation/commentary; Tanzil/QUL/KFGQPC attribution surfaces in About/Credits; no badge/counter/confetti/glow/ornament over an āyah, no wuḍūʾ/piety gate to open the page.
- [ ] **RTL + fa/ckb/ar localization:** the muṣḥaf is identical across all three locales (only chrome localizes); the download/riwāyah/attribution strings ship via `gen_l10n` for fa/ckb/ar with `type.*` tokens, locale numerals (`intl`), and FSI/PDI isolation; the page view and `PageView` advance right-to-left in all three.
- [ ] **Accessibility:** the reader's zoom is independent of OS chrome text-scale (the muṣḥaf never reflows); interactive chrome around the page (download retry, zoom/theme controls) carries `Semantics` labels and meets thumb-zone/contrast norms; the muṣḥaf golden runs under an RTL `Directionality`.
- [ ] **Nothing safe to drop:** nothing in this epic ever marks a page droppable, optional, or "done"; the renderer and the data load are correctness-critical and never degrade.
- [ ] **Tests:** the verifier suite (anchors + single-byte-flip + truncation rejections), the page-assembly/overlay-geometry units, and the real-font (`FontLoader`, never Ahem) muṣḥaf goldens across light/sepia/dark + a zoom step all run in CI on every PR; the 604-page visual-diff runs on min-OS iOS+Android within a tight tolerance.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E05-T01 | [MushafEdition triple model + PackCoordinates pinned tag + the core-pack manifest schema](E05-T01-mushaf-edition-and-pack-coordinates.md) | M | E01, E03 |
| E05-T02 | [Quarantined /assets PackDownloader behind an injectable boundary with a deterministic fake](E05-T02-pack-downloader-boundary.md) | M | E05-T01 |
| E05-T03 | [Chunked SHA-256 verifier + total fail-closed state machine (single-byte-flip + truncation golden-rejected) — test-first](E05-T03-sha256-failclosed-verifier.md) | M | E05-T01 |
| E05-T04 | [Sequenced installCorePack (download → verify → promote → build reference DB → stamp) with calm RTL onboarding states](E05-T04-install-core-pack-sequence.md) | M | E05-T02, E05-T03, E03 |
| E05-T05 | [Load verified bytes into E03's read-only Drift mushaf/page/line/ayah + layout reference tables, checksum-governed](E05-T05-reference-data-load.md) | M | E05-T04, E03 |
| E05-T06 | [registerVerifiedPageFonts: load the 604 QPC fonts via FontLoader only after each passes its hash](E05-T06-verified-font-registration.md) | S | E05-T03, E05-T05 |
| E05-T07 | [Immutable MushafPageView: glyph-only line builder (empty fallback, RTL) + data-driven assemblePage](E05-T07-immutable-page-view.md) | M | E05-T05, E05-T06 |
| E05-T08 | [MushafOverlayPainter: coordinate-only markers over the glyph layer from the same bundled geometry](E05-T08-overlay-painter.md) | S | E05-T07 |
| E05-T09 | [Zoom/theme transform frame + RTL-aware PageView navigation + riwāyah chrome label](E05-T09-zoom-theme-rtl-navigation.md) | M | E05-T07, E05-T08 |
| E05-T10 | [CI checksum gate: text/layout/604-font SHA-256 vs release + authoritative Tanzil hash — test-first](E05-T10-ci-checksum-gate.md) | M | E05-T01, E05-T03 |
| E05-T11 | [CI 604-page real-font visual-diff on min-OS iOS+Android, tight tolerance, sajda/ayah-numbering/basmala spot-checks](E05-T11-ci-visual-diff-goldens.md) | L | E05-T07, E05-T09 |

## Risks

- **A fallback font silently re-shapes the sacred path.** A single `fontFamilyFallback` entry hands the glyph string to the OS shaper the instant a glyph is missing — the exact corruption this epic exists to eliminate. *Mitigation:* `fontFamilyFallback: const []` on every muṣḥaf line is a checklist item and a code-review reject; a missing glyph is required to surface as visible tofu and is caught by the T11 visual-diff gate.
- **Goldens rendered with Ahem prove nothing.** A 604-page golden of squares passes while diacritics are misplaced. *Mitigation:* the muṣḥaf goldens load the **real KFGQPC fonts** via `FontLoader` (never Ahem), pinned to one runner per Decision 9, with a tight tolerance because the failure mode (a shifted mark) is small in pixels but catastrophic in meaning.
- **The automated gate gets mistaken for sufficiency.** CI guards against *regression*, not against an originally-wrong reference image. *Mitigation:* the qualified ḥāfiẓ/scholar on-device proof (PRD §20.8) stays a release-blocking gate handled at **E20 release-readiness**; T11 documents that the goldens are seeded from scholar-approved references, not auto-captured.
- **A second network client creeps in.** A "check for newer pack", crash reporter, or analytics SDK would void the no-telemetry covenant and F-Droid eligibility (CLAIMS C-048, PRD R5/C1). *Mitigation:* the socket is quarantined to `/assets` with exact-tag pinning (a 404 means "keep the verified local copy", never "fetch something else"); E01's banned-import + allow-list gates fail the build on any second client.
- **Mixing layers across editions corrupts the page.** A QPC V2 font paired with a different edition's layout silently breaks the typeset page. *Mitigation:* the triple is verified together (T03/T10); cross-edition mixing is refused by construction — one `mushafId` binds one `{text, layout, fonts}`.
- **Reference-data load straddles E03's boundary.** Building verified bytes into the read-only Drift tables risks duplicating schema/migration logic this epic does not own. *Mitigation:* the DDL/migration stays in E03; T05 only loads verified bytes through the single write path and stamps `text_checksum_verified_at`, with the hand-off explicitly scoped.
- **Hashing a hundreds-of-MB pack OOMs low-end Android.** *Mitigation:* verification is chunked via `crypto` `startChunkedConversion` (bounded memory), never `readAsBytes`; exactly one re-fetch on mismatch so a tampering edge never becomes an infinite-retry battery drain.

## References

- docs/PRD.md — §11 (Quran data & immutable rendering: §11.1 asset packs, §11.1.1 download integrity, §11.2 rendering rules, §11.3 integrity pipeline), §6.1 (fixed Quran structure), §4 R1/R2/R3/R5, §12.1 (onboarding download), §17/§19.3/§20 (offline + integrity gates), C1/C2
- docs/engineering/08-quran-data-and-immutable-rendering.md — §1 (three reference layers / triple), §2 (glyph fonts not the OS shaper), §3 (layout is data), §4 (coordinate overlays), §5 (themes/zoom transform), §6 (integrity pipeline + visual-diff)
- docs/engineering/09-asset-packs-and-offline-integrity.md — §1 (pinned exact tag / immutable Releases / manifest), §2 (one-time download / installCorePack / states), §3 (runtime SHA-256 fail-closed), §4 (reproducible builds — CI/audit only), §5 (TLS without cert pinning), §6 (offline-forever as a build invariant)
- docs/engineering/README.md — decision log #5 (Quran asset distribution & offline integrity), #6 (immutable muṣḥaf rendering), #8 (no networking beyond asset download), #9 (testing/CI: real-font goldens), #3 (read-only reference tables / single write path), #1 (Flutter/Impeller, shaper bypassed for the muṣḥaf)
- docs/science/CLAIMS.md — C-031 (one card = one muṣḥaf page, 604), C-048 (fully offline, no microphone, one-time checksum-verified download)
- .claude/skills/domain-asset-pack-integrity/SKILL.md — the download/verify canonical pattern and fail-closed checklist
- .claude/skills/domain-mushaf-text-integrity/SKILL.md — the triple, glyph-only rendering, data-driven layout, coordinate overlays, riwāyah naming, integrity gates
- .claude/skills/ui-mushaf-page-view/SKILL.md — the dumb RTL page-view widget, overlay painter, zoom/theme transform, real-font golden
- .claude/skills/eng-define-service-boundary/SKILL.md, eng-add-feature-module/SKILL.md, eng-create-riverpod-store/SKILL.md, eng-write-dart-test/SKILL.md, eng-add-ci-check/SKILL.md — the boundary/module/store/test/CI scaffolds the tasks follow
