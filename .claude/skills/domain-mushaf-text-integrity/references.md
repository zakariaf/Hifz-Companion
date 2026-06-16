# references — domain-mushaf-text-integrity

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it. Every rule in `SKILL.md` traces to one of these.

## Primary

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §1 (the three reference layers) — The muṣḥaf is an immutable, co-versioned **triple** `{Tanzil text, QUL layout, KFGQPC fonts}`, each separately licensed and checksummed, modelled as `MushafEdition` and selected by `mushafId`. The text is the **audit source of truth** (the only human-readable, byte-comparable representation), **never** a rendering or layout input. Refuses to derive layout from text or mix layers across editions.

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §2 (glyph fonts, not the OS shaper) — **The existential decision.** Each page is drawn by selecting its dedicated KFGQPC `QPC_P###` font and painting opaque glyph codes; the OS shaper (HarfBuzz/Skia/Impeller) is never asked to lay out Quran text. `buildGlyphLine` uses `TextDirection.rtl` and `fontFamilyFallback: const []` — a missing glyph must surface as tofu, never re-shape. Fonts load at runtime via `registerVerifiedPageFonts` → `FontLoader`, only after `vault.readVerified` passes the per-page hash. Glyph codes are opaque addresses, never parsed as text.

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §3 (layout is data, never runtime line-breaking) — `assemblePage` groups words strictly by `page-{p}-line-{l}` from the QUL `MushafPage`/`MushafWord` dataset, **never** by verse (one line mixes multiple ayāt). No `softWrap`, no width-wrapping, no `TextPainter` line computation on Quran text; juz/page/line/ayah counts are read, never recomputed.

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §4 (overlays: coordinates over the glyph layer) — Every marker (weak-line, mutashābihāt anchor, current-ayah, error-position) is an `OverlayMarker` carrying only `(pageNumber, [WordRef])` — **no text** — resolved to `Rect`s by `MushafOverlayPainter` from the **same** bundled geometry the glyphs use. Persist only `(page, line, position)` refs; never re-typeset or store reconstructed verse text. The painter draws only geometric primitives; colors are design-system tokens.

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §5 (themes/zoom transform the layer, not the text) — `mushafPageView` wraps the immutable glyph page + overlays in a uniform `Transform.scale` (RTL `Alignment.topRight` origin) and a `ColorFiltered` theme filter. Zoom never reflows; sepia/dark is a color filter, never a per-theme font swap; OS text-scale never reflows the muṣḥaf.

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §6 (integrity pipeline) — Three fail-closed gates: CI checksum (`verifyAssetIntegrity`: pinned text/layout/604-font SHA-256 match the release and the authoritative Tanzil hash), runtime re-verify-before-first-use (refuse unverified Quran assets), and the visual-diff golden harness that renders all 604 pages with the **real KFGQPC fonts** (`FontLoader`, never Ahem) on min-OS iOS/Android within a tight tolerance. The test-vector table (text hash, font manifest, page count, sajda marks, ayah numbering, basmala, tolerance) and the scholar's on-device proof are release-blocking.

- `docs/PRD.md` R1 (Text fidelity is existential) — Store Uthmani text byte-for-byte (Tanzil, CC BY 3.0, attributed); SHA-256 verified in CI, any byte change fails the build; render **only** through KFGQPC per-page glyph fonts, never the OS shaper; layout from the fixed QUL dataset, never runtime line breaks; markers as a coordinate overlay on the immutable glyph page, never re-typeset/stored; CI visual-diff on min-OS iOS+Android.

- `docs/PRD.md` R2 (state the riwāyah; stay neutral) — Show the muṣḥaf as "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf," never "the Quran" absolutely; the scheduler is text-agnostic and the muṣḥaf is a **swappable asset** (data model supports alternative layouts/riwāyāt with no engine rewrite); zero bundled tafsīr/translation/commentary.

- `docs/PRD.md` §11 (Quran Data & Immutable Rendering) — §11.1/§11.1.1: assets are a versioned core pack downloaded once from an open-source repo, pinned SHA-256 + release, rejected and re-fetched on mismatch, render refused if unverified. §11.2: dedicated glyph font per page, overlays as rectangles, breaks from layout data only, zoom/themes transform the rendered layer. §11.3: the CI + runtime integrity pipeline.

- `docs/design-system/13-islamic-identity-and-adab.md` §1 (the muṣḥaf page is the unit of reverence) — Render page-faithful through per-page glyph fonts; the QPC fonts are **not design tokens** (referenced, never restyled/re-weighted/substituted); markers are coordinates over the immutable layer; page position is itself a retrieval cue, so reflow is forbidden as both adab and a retention failure.

## Supporting

- `docs/design-system/13-islamic-identity-and-adab.md` §3 (chrome defers to the words) — Nothing the app adds ever sits decoratively over the words of Allah; the reader is "no dashboard"; markers are strictly diagnostic (a calm `color.semantic.warning` for a decaying line), never congratulatory; no flip sound, no celebratory motion on Quran text.

- `docs/design-system/13-islamic-identity-and-adab.md` §5 (state the riwāyah, attribute, stay neutral) — Name the transmission in settings/onboarding/About; surface Tanzil/QUL/KFGQPC attribution and the checksum/byte-for-byte guarantee; ship zero tafsīr/translation; the muṣḥaf text is identical across fa/ckb/ar — never "translated" or restyled per locale.

- `docs/design-system/13-islamic-identity-and-adab.md` §2 (reverence is presentation, not device-gating) — Do not gate opening the muṣḥaf behind a wuḍūʾ prompt or piety pledge; any reverent framing (taʿawwudh/basmalah line) is optional and dismissible; the app surfaces methodology, issues no fiqh ruling.

- `docs/design-system/13-islamic-identity-and-adab.md` §4 (never gamify worship) — No XP/badges/streaks/confetti on āyāt or juz completion; the only feedback is honest competence feedback (the calm retention heat-map), never a points economy over the sacred.

- `docs/PRD.md` §6.1 (fixed hierarchy) — The 30 juz → 604 pages → 15 lines/page → ayah hierarchy is fixed glyph/layout data the app never recomputes; the card unit is a parameter, so non-15-line layouts can swap in.

- `docs/PRD.md` R3 (no gamification of the sacred) — No leaderboards/XP/badges/confetti; neutral calm notifications, never guilt/fear; progress is a calm retention heat-map, not a punitive streak.

## Sibling skills

- **domain-asset-pack-integrity** — owns the *wire half*: how the core pack is hosted on the open-source repo, downloaded once over HTTPS, and SHA-256-verified at runtime before this skill is allowed to render it. Shares the checksum manifest with this skill. (`docs/engineering/09-asset-packs-and-offline-integrity.md`; `docs/PRD.md` §11.1/§11.1.1.)
- **eng-reference-data-persistence** — owns the read-only Drift/SQLite DDL for the `mushaf`/`page`/`line`/`ayah` reference tables that hold the layout/text/edition rows this skill reads. (`docs/engineering/05-persistence-and-encryption.md`; `docs/PRD.md` §10.1.)
- **eng-scheduling-engine** — the pure-Dart, text-agnostic scheduler that decides which page is due; it never sees glyphs and is decoupled from the muṣḥaf by R2's swappability. (`docs/engineering/06-scheduling-engine.md`.)
- **ui-retention-heatmap** — the calm "keep your Quran green" progress surface and the `color.semantic.*` tokens an overlay paints a weak line with. (`docs/design-system/08-data-visualization.md`.)
- **ui-rtl-localization** — the shaped fa/ckb/ar UI chrome that *does* go through Flutter's shaper — deliberately the opposite path from the muṣḥaf, kept architecturally apart. (`docs/engineering/12-localization-rtl-accessibility-impl.md`; `docs/design-system/12-localization-and-rtl.md`.)
