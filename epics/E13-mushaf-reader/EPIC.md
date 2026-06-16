# E13 — Muṣḥaf Reader

The in-app muṣḥaf reader, assembled on top of E05's immutable rendering primitive: a book-like reader that draws each page glyph-only (the OS shaper never lays out Quran text), pages right-to-left between the 604 pages, and jumps to any juz / ḥizb / sūrah / page. It toggles weak-line and mutashābihāt overlays as coordinate rectangles over the glyph layer, applies sepia / dark / zoom by transforming the rendered layer (never the text), and always names the riwāyah on screen. It owns the reader *feature* — the tab, the navigator, the jump-to surface, the reader controls — and re-shapes, re-typesets, and re-derives nothing: every glyph, every line break, every overlay rectangle, and every checksum belongs to E05, and this epic only consumes them.

## Why this epic exists

The product is a retention engine for the muṣḥaf, and the reader is the surface a ḥāfiẓ opens to *look at the page* — to settle a doubt, to read along a manzil rotation, to mark a memorized range, to see where a weak line or a mutashābihāt sibling sits on the printed page they have read for years (PRD §12.3; CLAIMS C-031, the page is the unit because recall is a chunked, forward-cued, whole-page production). That familiarity is itself a memory cue: huffaz have read the exact Madani QPC page for years, so the page must appear *exactly* as they remember it (design-system 04 §1, "you read best what you read most"). This is why the reader cannot be allowed to relax E05's existential rule even slightly — a reader that line-breaks at runtime, font-swaps for dark mode, re-typesets a highlighted phrase, or hands a missing glyph to a fallback font would re-introduce the OS shaper that has shipped misplaced-diacritic and shattered-ligature bugs in Flutter (engineering 08 §2; `flutter#16886`, `#143975`, `#119805`), and a single altered diacritic ends the project (PRD R1). The reader's job is therefore *restraint*: it adds navigation, jump-to, overlay toggles, and zoom/theme **around** the immutable page without ever touching it.

It also exists to keep adab intact on the most sacred surface in the app. The reader is where sect-neutrality and reverence are most visible and most fragile: the page is never presented as "the Quran" in the absolute — the swappable edition's riwāyah ("Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf") is always named (PRD R2; engineering 08 §1), zero tafsīr/translation/commentary is ever drawn beside it, the muṣḥaf is identical across fa/ckb/ar with only the chrome localized, and no badge, counter, confetti, glow, ornamental border, page-flip fanfare, or wuḍūʾ/piety gate decorates or guards the page (PRD R3; design-system 13 §2–§4). The reader is "no dashboard": the words dominate and the chrome recedes to the edges. Building this as its own epic — separate from E05's primitive and E12's recite/grade flow — lets the reader feature be assembled correctly once, with the page renderer it consumes already proven byte-exact and offline, so the only new risk surface is the navigation and control chrome, not the sacred path.

## Scope

### In scope

- The `/features/mushaf` reader feature: the **Muṣḥaf** bottom-nav tab (rightmost-but-one in the RTL nav), its `go_router` route + typed deep-link params (jump to a page/juz/ḥizb/sūrah), the dumb `ConsumerWidget` `MushafReaderScreen` View, and its 1:1 `MushafReaderViewModel`.
- The **reader-state** scoped Riverpod store: current `pageNumber`, `zoom` level, reader `theme` (light/sepia/dark), and the weak-line / mutashābihāt **overlay-visibility** toggles — display-only state that mutates no engine state and persists no review.
- The **RTL paged navigator** over E05's `MushafPageView`: an RTL-aware `PageView`/`PageController` (`reverse` per direction so page 1→2 advances right-to-left) that rebuilds each page with a new `pageNumber`/geometry only — the immutable page is re-selected, never re-rendered or re-flowed, and the glyph content is never mirrored or reordered.
- The **jump-to navigator**: a calm picker to jump to any juz (1–30), ḥizb (1–60), sūrah (1–114), or page (1–604) using the fixed bundled Quran structure (read, never recomputed), with locale numerals; selecting a target seeks the `PageController` to the resolved page.
- The **overlay toggles**: wiring E05's coordinate-only `MushafOverlayPainter` for the weak-line and mutashābihāt-anchor markers, toggleable from the reader chrome, where this epic *paints the markers it is handed* — the weak-line refs come from the active profile's card/line-block state, the mutashābihāt refs from the confusables dataset — and never decides which words to mark.
- The **reader controls**: the zoom control (uniform `Transform.scale`, RTL `topRight` origin, independent of OS chrome text-scale) and the light/sepia/dark theme toggle (`ColorFiltered`), both as **layer transforms** — exactly one font per page, dark mode is a colour filter, zoom never reflows printed line breaks.
- The **riwāyah/edition chrome**: the always-shown `displayName`/`riwayah` label around the page (shaped `type.*` UI text with locale numerals), and the entry to the About/Credits attribution (Tanzil/QUL/KFGQPC + the byte-for-byte checksum guarantee) — the page is never called "the Quran" absolutely.
- The **reader-chrome "no-dashboard" treatment**: controls recede to the edges, the words dominate, and the chrome auto-hides/returns calmly; no gamification, ornament, page-flip sound/haptic fanfare, or piety gate on the sacred surface.
- fa/ckb/ar localization and RTL correctness for every reader-chrome string (riwāyah label, jump-to labels, control labels, `Semantics` labels), via `gen_l10n`, with locale numerals and FSI/PDI isolation.
- Reader-feature tests: the jump-to resolution/seek units, the overlay-toggle and reader-state ViewModel units, and the real-font muṣḥaf goldens (light/sepia/dark + a zoom step + overlays on/off) under an RTL `Directionality`.

### Out of scope

- The **immutable page renderer itself** — `MushafPageView`, the glyph-only `GlyphLine` builder, `assemblePage`, the `MushafOverlayPainter`, the zoom/`ColorFilter` transform frame, font registration, and the verified reference-data load → **E05 quran-data-and-rendering**; this epic *consumes* those primitives and re-derives none of them.
- The **one-time core-pack download / SHA-256 fail-closed verifier / refuse-unverified gate** → **E05 quran-data-and-rendering** (the reader only renders what `appReady` has verified) and the wire half in the asset-pack docs; this epic opens no socket.
- The **recite-from-memory reveal/grade flow** drawn over the page (reveal-on-tap, stumble-line tapping, the four-level grade band, in-flow teacher sign-off) → **E12 today-and-recite-grade**; the reader's "start revision here" entry hands off to that flow.
- *Which* words a mutashābihāt marker covers — the **confusables dataset, confusion log, discrimination drills, anchor-hint content** → **E14 mutashabihat-trainer**; this epic only paints the marker refs it is handed and exposes the toggle.
- The **weak-line/line-block math** that decides a page's weak lines (the `onReview` error-overlay, line-block splitting, `weak_flag`) → **E04 scheduling-engine** / **E03 models-and-persistence**; the reader reads the resulting refs, never computes them.
- The **"mark my memorized range" coverage tool** that writes coverage → owned by **E11 onboarding-and-cold-start** (cold-start coverage capture); the reader may surface an entry point but does not own the coverage write path.
- The shared **page card / track chip / decay indicator / jump-picker control / numerals-calendar primitive** leaf widgets → **E10 mihrab-component-library**; this epic assembles them and references token *names* only.
- The **bottom-nav shell, the `ProviderScope` composition root, the redirect guard, and the injected clock/DB boundaries** → **E07 app-shell-walking-skeleton**; this epic replaces the inert Muṣḥaf placeholder tab with the real reader inside the proven shell.
- The **muṣḥaf/riwāyah picker** that swaps the `MushafEdition` triple → **E16 settings-profiles-teacher**; the reader displays whichever edition is active.
- The CI **no-network / banned-import / checksum / 604-page visual-diff** gates → authored in **E01 repo-scaffold-and-ci** and **E05**; this epic must simply give them nothing to catch.

## Dependencies

### Depends on

- **E05 quran-data-and-rendering** — the immutable `MushafPageView` glyph renderer, `assemblePage`, the coordinate-only `MushafOverlayPainter`, the zoom/`ColorFilter` transform frame, the RTL-aware paging primitive, the verified per-page fonts + reference data, the `MushafEdition` triple (`riwayah`/`displayName`), and the `appReady`/refuse-unverified gate the reader renders behind.
- **E07 app-shell-walking-skeleton** — the `ProviderScope` composition root, the `go_router` RTL `ShellRoute` bottom nav whose inert Muṣḥaf placeholder this epic replaces, the redirect guard (no Quran screen renders before the core pack is verified and a profile exists), the injected `CalendarDate` clock and Drift handle, and the `activeProfileProvider` the weak-line refs key on.
- **E10 mihrab-component-library** — the reusable leaf widgets the reader chrome assembles (the jump-to single-choice picker pattern, the numerals/calendar/text rendering primitive, the calm control chrome), token-only and RTL-native; the reader references them and the `color.*`/`type.*`/`space.*`/`touch.min` token names, never raw values.

### Enables

- **E12 today-and-recite-grade** — the recite flow can route a "start revision here" hand-off from the reader into the reveal/grade surface, and reuses the reader's page-navigation chrome.
- **E14 mutashabihat-trainer** — the discrimination drill opens sibling pages back-to-back in this reader and drives the mutashābihāt-anchor overlay toggle the reader exposes.
- **E15 progress-and-heatmap** — a heat-map page-detail "open in reader" action deep-links into this reader at the tapped page.
- **E16 settings-profiles-teacher** — the muṣḥaf/riwāyah swap re-binds the `MushafEdition` the reader names and renders; the reader's theme/zoom defaults read Settings.

## Foundation inputs

| Input | Where (doc/skill) | What this epic takes from it |
|---|---|---|
| Immutable page rendering rules | docs/PRD.md §11.2 | Glyph-font-only render, line/page breaks from bundled layout, markers as coordinate overlays, zoom/sepia/dark by transforming the rendered layer, RTL paging |
| Reader screen behaviors | docs/PRD.md §12.3 | Swipe pages (RTL), jump to juz/ḥizb/sūrah/page, weak-line + mutashābihāt anchors as toggleable overlays, "start revision here" entry |
| Fixed Quran structure | docs/PRD.md §6.1 | 30 juz → 60 ḥizb → 240 rubʿ → 604 pages → 15 lines hierarchy, read from data (never recomputed) to resolve jump-to targets |
| Glyph fonts not the OS shaper | docs/engineering/08-quran-data-and-immutable-rendering.md §2 | `qpcFontFamily(page)`, empty `fontFamilyFallback`, fail-loud-on-missing-glyph — the reader draws what E05 registered, re-shapes nothing |
| Layout is data, never runtime line-breaking | docs/engineering/08-quran-data-and-immutable-rendering.md §3 | `assemblePage` grouped by `page-{p}-line-{l}`; no `softWrap`/`TextPainter`/width-wrap on Quran text in the navigator |
| Overlays as coordinates | docs/engineering/08-quran-data-and-immutable-rendering.md §4 | `OverlayMarker`/`MushafOverlayPainter` `(page,line,position)` refs the reader toggles; never re-typeset or stored reconstructed text |
| Themes / zoom transform the layer | docs/engineering/08-quran-data-and-immutable-rendering.md §5 | `mushafPageView` uniform `Transform.scale` (RTL topRight) + `ColorFiltered`; no per-theme font swap, no muṣḥaf reflow, zoom independent of OS text-scale |
| Three reference layers / swappable edition | docs/engineering/08-quran-data-and-immutable-rendering.md §1 | `MushafEdition.riwayah`/`displayName` the reader names; the swappable triple selected by `mushaf_id` (R2) |
| Two pipelines, one rule | docs/design-system/04-typography.md §1 | The muṣḥaf is its own pipeline — no `type.*` token, no shared `TextStyle`, no OS text-scale on the page; the reader's zoom is independent of chrome text-scale |
| Reader-chrome typography | docs/design-system/04-typography.md §4–§8 | `type.*` ramp + 16 sp floor for the riwāyah/jump-to/control labels, locale numerals, FSI/PDI for mixed runs — shaped chrome around (never on) the page |
| Skill: muṣḥaf page view | .claude/skills/ui-mushaf-page-view | The dumb RTL page-view widget, the overlay painter wiring, the zoom/theme transform frame, RTL `PageView` paging, the riwāyah chrome, the real-font golden |
| Skill: muṣḥaf text integrity | .claude/skills/domain-mushaf-text-integrity | The existential render rules the reader must not relax (glyph-only, data layout, coordinate overlays, riwāyah named, no gamification/piety gate, fail-closed) |
| Skill: adab & religious integrity | .claude/skills/domain-adab-and-religious-integrity | Riwāyah wording, "never the Quran absolutely", zero tafsīr, no gamification/ornament/piety gate on the sacred surface, sect-neutrality |
| Skill: feature module | .claude/skills/eng-add-feature-module | The `features/lib/src/mushaf/` folder anatomy (dumb View + 1:1 ViewModel + `widgets/` + scoped providers), the `ShellRoute` RTL nav entry, the downward-only dependency set |
| Skill: Riverpod store | .claude/skills/eng-create-riverpod-store | The reader-state notifier (current page, zoom, theme, overlay toggles) — autoDispose, immutable UI state, no `DateTime.now()`, no mutation of engine state |
| Skill: RTL & bidi layout | .claude/skills/eng-rtl-and-bidi-layout | RTL paging direction, logical start/end insets, FSI/PDI isolation, locale numerals for the page/juz indices in the chrome |
| Skill: localized string | .claude/skills/eng-add-localized-string | The reader-chrome ARB keys (riwāyah label, jump-to, controls, `Semantics`) for fa/ckb/ar with locale numerals |
| Skill: Dart test | .claude/skills/eng-write-dart-test | The jump-to/ViewModel units and the real-font (`FontLoader`, never Ahem) RTL muṣḥaf golden harness across themes/zoom/overlays |
| CLAIMS behind on-screen content | docs/science/CLAIMS.md C-031, C-048 | "one card = one muṣḥaf page, 604" framing (C-031); "fully offline, never records voice, one-time checksum-verified download" (C-048) — the reader's offline/no-mic covenant |

## Deliverables

- [ ] The `/features/mushaf` feature module: the Muṣḥaf tab + `go_router` route (typed page/juz/ḥizb/sūrah deep-link params), the dumb `MushafReaderScreen` View, and the 1:1 `MushafReaderViewModel`, wired into the E07 RTL `ShellRoute` in place of the inert placeholder.
- [ ] The scoped reader-state Riverpod store (current `pageNumber`, `zoom`, reader `theme`, weak-line + mutashābihāt overlay toggles) — autoDispose, immutable UI state, mutates no engine state and writes no review.
- [ ] The RTL paged navigator over E05's `MushafPageView`: an RTL-aware `PageView`/`PageController` rebuilding each page with a new `pageNumber`/geometry only, glyph content never mirrored or reordered.
- [ ] The jump-to navigator (juz 1–30 / ḥizb 1–60 / sūrah 1–114 / page 1–604) resolving targets from the fixed bundled structure with locale numerals, seeking the controller to the resolved page.
- [ ] The overlay toggles wiring E05's `MushafOverlayPainter` for weak-line refs (from the active profile's card/line-block state) and mutashābihāt-anchor refs (from the confusables dataset), togglable from reader chrome; the reader paints only refs it is handed.
- [ ] The reader controls: the zoom control (uniform scale, independent of OS chrome text-scale) and the light/sepia/dark theme toggle (`ColorFilter`), both as layer transforms with no per-theme font swap and no reflow.
- [ ] The always-shown riwāyah/edition chrome label (shaped `type.*`, locale numerals) and the entry to About/Credits attribution (Tanzil/QUL/KFGQPC + byte-for-byte checksum guarantee); the page is never called "the Quran" absolutely.
- [ ] The "no-dashboard" reader-chrome treatment: edge-receding, auto-hiding controls; no gamification/ornament/page-flip fanfare/piety gate on the page.
- [ ] fa/ckb/ar `gen_l10n` strings + `Semantics` labels for every reader-chrome surface, with locale numerals and FSI/PDI isolation; the muṣḥaf itself identical across all three locales.
- [ ] Test suites: the jump-to resolution/seek units, the overlay-toggle/reader-state ViewModel units, and the real-font RTL muṣḥaf goldens across light/sepia/dark + a zoom step + overlays on/off.

## Definition of Done

- [ ] **Offline / no-network:** the reader opens no socket and fetches nothing at runtime; it renders only fonts/geometry E05 delivered in the verified core pack; E01's banned-import + no-network gates stay green; an `HttpOverrides`-that-throws guard proves the radio stays off while paging/jumping (CLAIMS C-048).
- [ ] **No AI / no microphone:** nothing in the reader, its navigation, or its overlay/control path uses AI, ASR, or audio; the reader couples to no microphone and no audio-recognition.
- [ ] **Text fidelity (existential):** the reader re-shapes, re-typesets, re-flows, and re-derives nothing — every page draws glyph-only via E05 with `fontFamilyFallback: const []`; line/page breaks come only from the bundled layout (no `softWrap`/`TextPainter`/width-wrap, never grouped by verse); overlays are coordinate rectangles holding no text; zoom is a uniform scale and sepia/dark a `ColorFilter` with no per-theme font swap and no reflow; a missing glyph surfaces as visible tofu; the reader refuses to render any unverified Quran asset.
- [ ] **Sect-neutral adab:** the riwāyah is always named (`displayName` "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"); the page is never called "the Quran" absolutely; zero tafsīr/translation/commentary is drawn beside it; Tanzil/QUL/KFGQPC attribution + the checksum guarantee are reachable from the reader; no badge/counter/confetti/glow/ornament over an āyah, no page-flip fanfare, and no wuḍūʾ/piety gate to open the muṣḥaf.
- [ ] **RTL + fa/ckb/ar localization:** the muṣḥaf is identical across all three locales (only chrome localizes); the navigator and jump-to advance right-to-left in fa/ckb/ar; every reader-chrome string ships via `gen_l10n` for fa/ckb/ar with `type.*` tokens, locale numerals (`intl`), and FSI/PDI isolation; the page/juz/ḥizb/sūrah indices render in the locale numeral set.
- [ ] **Accessibility:** the reader's zoom is independent of OS chrome text-scale (the muṣḥaf never reflows); every interactive control (page-jump, zoom, theme, overlay toggles, About entry) carries a localized `Semantics` label, meets the 48dp/contrast floors, and respects RTL focus order; the muṣḥaf golden runs under an RTL `Directionality`.
- [ ] **Nothing safe to drop:** the reader never marks a page droppable, optional, or "done", surfaces no raw D/S/R or percentage, and adds no scoreboard/streak over the page; it is a calm reference surface, not a status display.
- [ ] **Single write path / no engine mutation:** reader state (page, zoom, theme, toggles) is display-only and mutates no card, writes no `review_log`, and re-derives no `due_at`; any hand-off that *does* write (start-revision, mark-range) routes through the owning epic's single write path, never the reader.
- [ ] **Tests:** the jump-to/ViewModel units and the real-font (`FontLoader`, never Ahem) RTL muṣḥaf goldens across light/sepia/dark + a zoom step + overlays on/off run in CI on every PR; the reader inherits E05's 604-page visual-diff coverage and adds none of its own re-rendered references.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E13-T01 | [Mushaf reader feature module: tab + go_router route (page/juz/ḥizb/sūrah deep-link params) + dumb View + 1:1 ViewModel](E13-T01-reader-feature-module.md) | M | E05, E07, E10 |
| E13-T02 | [Reader-state Riverpod store: current page, zoom, theme, overlay toggles — display-only, no engine mutation](E13-T02-reader-state-store.md) | S | E13-T01 |
| E13-T03 | [RTL paged navigator over E05's MushafPageView: RTL-aware PageView rebuilding page/geometry only, glyph content never mirrored](E13-T03-rtl-paged-navigator.md) | M | E13-T01, E13-T02 |
| E13-T04 | [Jump-to navigator: resolve juz/ḥizb/sūrah/page targets from the fixed bundled structure with locale numerals, seek the controller](E13-T04-jump-to-navigator.md) | M | E13-T03 |
| E13-T05 | [Weak-line + mutashābihāt overlay toggles: wire E05's MushafOverlayPainter to profile weak-line refs and confusables refs](E13-T05-overlay-toggles.md) | M | E13-T03 |
| E13-T06 | [Reader controls: zoom (uniform scale, independent of OS text-scale) + light/sepia/dark theme toggle (ColorFilter) as layer transforms](E13-T06-zoom-theme-controls.md) | M | E13-T02, E13-T03 |
| E13-T07 | [Always-shown riwāyah/edition chrome label + About/Credits attribution entry (never "the Quran" absolutely)](E13-T07-riwayah-chrome-and-attribution.md) | S | E13-T01 |
| E13-T08 | [No-dashboard reader chrome: edge-receding auto-hiding controls, no gamification/ornament/piety gate on the page](E13-T08-no-dashboard-chrome.md) | S | E13-T03, E13-T06, E13-T07 |
| E13-T09 | [fa/ckb/ar reader-chrome localization + Semantics labels + locale numerals + FSI/PDI isolation](E13-T09-localization-rtl-chrome.md) | M | E13-T04, E13-T05, E13-T06, E13-T07 |
| E13-T10 | [Reader tests: jump-to/ViewModel units + real-font RTL muṣḥaf goldens (light/sepia/dark + zoom + overlays on/off)](E13-T10-reader-tests-and-goldens.md) | M | E13-T04, E13-T05, E13-T06, E13-T08 |

## Risks

- **A reader convenience relaxes the sacred render path.** A "fit to width" toggle, a per-theme "dark font", a runtime re-wrap, or a fallback font added "to avoid tofu" would each re-introduce the OS shaper E05 exists to bypass — the exact corruption that ends the project. *Mitigation:* the reader is a *dumb consumer* of E05's `MushafPageView`; it never sets `softWrap`, never adds a `fontFamilyFallback`, never swaps fonts per theme; zoom/theme stay uniform layer transforms; a missing glyph must surface as visible tofu and is caught by E05's 604-page visual-diff gate; the no-relaxation rules are checklist items and code-review rejects.
- **The page gets dressed as a dashboard.** Page-flip sounds, a "pages read today" counter, a glow on the current ayah, or an ornamental border creep onto the most sacred surface. *Mitigation:* the reader is "no dashboard" by spec (design-system 13 §3) — chrome recedes to the edges, overlays are diagnostic-only coordinate boxes from E05, and no streak/badge/celebration/fanfare is permitted over the page; the adab skill gates the chrome.
- **The muṣḥaf is presented as "the Quran" absolutely.** Dropping the riwāyah label, or letting a translation/tafsīr surface beside the page, breaks sect-neutrality. *Mitigation:* the `displayName`/`riwayah` is *always* on screen (T07), zero tafsīr/translation ships, and the attribution/checksum guarantee is reachable from the reader; the page is identical across fa/ckb/ar with only the chrome localized.
- **The navigator mirrors or reorders glyph content under RTL.** Forcing RTL onto the page itself (rather than the paging direction) could flip or reorder the immutable glyphs. *Mitigation:* RTL applies to the *paging direction* (`PageView.reverse`) and the chrome layout only; the glyph content is re-selected per `pageNumber` and never mirrored or reordered; the goldens assert fa/ckb/ar all advance right-to-left with identical page pixels.
- **The reader reaches into engine or write state.** A "start revision here" or "mark range" affordance writes a review or coverage directly from the reader, bypassing the single write path. *Mitigation:* reader state is display-only; any write hands off to the owning epic (E12 recite/grade, E11 coverage) through its single write path — the reader mutates no card, appends no `review_log`, and re-derives no `due_at`.
- **Overlay refs drift from E05's coordinate contract.** Computing overlay rectangles from shaped text metrics, or persisting reconstructed verse text for a highlight, would break the coordinate-only contract. *Mitigation:* overlays are `(page, line, position)` refs resolved from the *same* bundled geometry the glyphs use, painted by E05's `MushafOverlayPainter`; the reader supplies refs (weak-line, mutashābihāt) and paints no text and measures no shaped Arabic.
- **Jump-to recomputes the Quran hierarchy.** Deriving which page a juz/ḥizb/sūrah starts on by calculation rather than from the fixed dataset risks an off-by-one on a sacred boundary. *Mitigation:* every jump-to target resolves through the read-only bundled `page`/`surah` structure (PRD §6.1) — counts and boundaries are read, never computed — and the resolution units pin the boundary pages.

## References

- docs/PRD.md — §11.2 (rendering rules: glyph-font only, layout from data, coordinate overlays, zoom/sepia/dark by transforming the layer, RTL paging), §12.3 (Muṣḥaf reader: RTL swipe, jump to juz/ḥizb/sūrah/page, toggleable weak-line + mutashābihāt overlays, "start revision here"), §6.1 (fixed Quran structure), §4 R1/R2/R3/R5, §18 (zoom/contrast/themes), §13 (RTL + fa/ckb/ar + numerals), §17/§19.3 (offline + no-mic covenant)
- docs/engineering/08-quran-data-and-immutable-rendering.md — §1 (three reference layers / swappable edition / riwāyah named), §2 (glyph fonts not the OS shaper / empty fallback / fail loud), §3 (layout is data, never runtime line-breaking), §4 (coordinate overlays, never re-typeset), §5 (themes/zoom transform the layer), §6 (integrity pipeline the reader renders behind)
- docs/design-system/04-typography.md — §1 (two pipelines: the muṣḥaf is never a `type.*` token and never the OS shaper; reader zoom independent of OS text-scale), §4 (size ramp + 16 sp floor for chrome), §5 (locale numerals), §6 (line-height/letter-spacing), §7 (dynamic text), §8 (bidi isolation for mixed runs)
- docs/science/CLAIMS.md — C-031 (one card = one muṣḥaf page, 604, whole-page review), C-048 (fully offline, no microphone, one-time checksum-verified download, then airplane-mode forever)
- .claude/skills/ui-mushaf-page-view/SKILL.md — the dumb RTL page-view widget, overlay painter wiring, zoom/theme transform frame, RTL `PageView` paging, the riwāyah chrome, the real-font golden
- .claude/skills/domain-mushaf-text-integrity/SKILL.md — the existential render rules the reader must not relax (glyph-only, data layout, coordinate overlays, riwāyah named, no gamification/piety gate, fail-closed)
- .claude/skills/domain-adab-and-religious-integrity/SKILL.md — riwāyah wording, never-"the-Quran"-absolutely, zero tafsīr, no gamification/ornament/piety gate on the sacred surface, sect-neutrality
- .claude/skills/eng-add-feature-module/SKILL.md, eng-create-riverpod-store/SKILL.md, eng-rtl-and-bidi-layout/SKILL.md, eng-add-localized-string/SKILL.md, eng-write-dart-test/SKILL.md — the module/store/RTL/localization/test scaffolds the tasks follow
