# references — ui-mushaf-page-view

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §2 (Why glyph fonts, not the OS shaper) — **The existential rendering rule.** Draw each line by applying the page's dedicated `fontFamily` (`qpcFontFamily(pageNumber)`) to the opaque glyph-code string with `TextDirection.rtl` and `fontFamilyFallback: const []`; the OS shaper is never asked to lay out Quran text; a fallback re-shapes the sacred path the moment a glyph is missing, so missing glyphs surface as visible tofu instead. Glyph codes are addresses into a glyph table — never normalized, split, searched, or logged as text.

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §3 (Layout is data, never runtime line-breaking) — **`assemblePage`.** Group words strictly by `page-{p}-line-{l}`, never by verse; no `softWrap`, no width-driven wrapping, no `TextPainter` line computation on Quran text. Every line/page break is a row in the bundled QUL dataset, consumed verbatim.

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §4 (Overlays: coordinates over the glyph layer) — **`OverlayMarker` + `MushafOverlayPainter`.** Every marker (weak-line, current-ayah, mutashābihāt-anchor, error-position) is a sibling `CustomPainter` layer that resolves `(lineNumber, position)` word-refs to device `Rect`s from the same `PageGeometry` and draws only primitives — no text, no measuring of shaped Arabic, no re-typesetting, no persisted reconstructed verse.

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §5 (Themes, zoom, night/sepia — transform the layer) — **`mushafPageView`.** Zoom is a uniform `Transform.scale` (origin `Alignment.topRight` for RTL); sepia/dark is one `ColorFiltered` over the glyph+overlay `Stack`. One font per page — dark mode is a colour filter, not a "dark font"; zoom never reflows printed line breaks.

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §1 (Three reference layers; the muṣḥaf triple) — **`MushafEdition`.** The muṣḥaf is a swappable triple `{text, layout, fonts}` selected by `mushaf_id`, carrying `riwayah`/`displayName`; the reader names the reading and never calls the page "the Quran" absolutely (R2). The View consumes `ImmutableGlyphPage`/`GlyphLine`; it does not re-derive the triple.

- `docs/engineering/08-quran-data-and-immutable-rendering.md` §6 (Integrity pipeline) — **Refuse-to-render + real-font goldens.** The View renders only verified assets; an unverified pack means refuse to render Quran text, not show an unverified page. Muṣḥaf goldens load the **real KFGQPC fonts** via `FontLoader` (never Ahem, which draws squares) and run within a tight pixel tolerance.

- `docs/PRD.md` §11.2 (Rendering rules — enforce R1) — The four binding rules in one place: select the page's dedicated glyph font (the font *is* the page); overlays are rectangles/coordinates over the glyph layer; line/page breaks come only from bundled layout; zoom + night/sepia transform the rendered layer, not the text.

## Supporting

- `docs/design-system/04-typography.md` §1 (Two pipelines, one rule) — **The muṣḥaf is never a `type.*` token.** `type.family.ui`/`type.family.uiFallback` apply only to widgets drawing localized strings; they are never passed to the muṣḥaf reader or any overlay painter. The two faces are kept aesthetically distinct as an adab requirement; the page is never re-typeset/restyled for a visual goal.

- `docs/design-system/04-typography.md` §7 (Dynamic text) — **The reader's zoom is independent of OS chrome text-scale.** UI chrome respects the system `TextScaler`; the Quran reader has its own independent zoom (PRD §11.2, §12.3) which is *not* a `type.*` concern — so the page view must not inherit the chrome text-scale.

- `docs/design-system/04-typography.md` §5 (Numerals follow the resolved locale) — The riwāyah label, page numbers, and juz numbers in the reader chrome render their digits via `intl` `NumberFormat`/`DateFormat` per locale (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) — never ASCII concatenation. This binds the chrome *around* the page, not the glyph layer.

- `docs/PRD.md` §11.1.1 (Integrity, amended 2026-06-18) — The app refuses to render Quran text from any unverified asset; the page view's "refuse to render" path defers to this runtime guard. The View never fetches at runtime — fonts/geometry come from the **bundled**, build-verified core (re-verified at first load).

- `docs/PRD.md` §18 (Accessibility) / §12.3 (the reader) — Low-vision reciters get a larger muṣḥaf via uniform layer zoom that keeps every printed line break exactly as printed; the reader is its own screen with its own zoom and theme controls.

## Sibling skills

- **domain-mushaf-text-integrity** — owns the data, font registration (`FontLoader`), checksums, glyph-string ↔ font pairing, layout-from-data, and overlay-coordinate rules; this skill is the View that consumes them.
- **domain-mutashabihat-system** — decides *which* words a mutashābihāt-anchor / confusion marker covers; this skill only paints the `OverlayMarker` it is handed.
- **domain-asset-pack-integrity** — the bundled core's build-time SHA-256 manifest + runtime re-verify (and the optional-pack download/verifier) that delivers and verifies the per-page fonts and layout.
- **eng-add-feature-module** — scaffolds the muṣḥaf reader screen, its route, and its dumb-View/ViewModel split.
- **eng-create-riverpod-store** — the provider/notifier holding reader state (current page, zoom, theme) the View reads.
- **eng-rtl-and-bidi-layout** — RTL paging direction and the bidi-safe chrome (riwāyah label, page numbers) around the page.
- **eng-write-dart-test** — the real-font muṣḥaf golden harness (light/sepia/dark/zoom, RTL `Directionality`).
- **domain-adab-and-religious-integrity** — the reverent treatment of the page and how the riwāyah is worded; no gamification drawn over the muṣḥaf.
