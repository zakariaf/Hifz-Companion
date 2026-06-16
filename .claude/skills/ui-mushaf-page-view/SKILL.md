---
name: ui-mushaf-page-view
description: Build the Hifz app's immutable muṣḥaf page renderer — select the page's dedicated KFGQPC glyph font and draw its pre-shaped glyph codes (never the OS shaper), draw every marker as a coordinate rectangle over the glyph layer, apply zoom/sepia/dark by transforming the rendered layer (never the text), and always name the riwāyah. Use whenever building the muṣḥaf reader, a page view, page navigation, the zoom/theme controls, or any widget that puts Quran text on a page.
---

# ui-mushaf-page-view

The widget layer that draws one muṣḥaf page faithfully: it picks that page's **dedicated per-page QPC glyph font**, paints the pre-shaped glyph codes with `Directionality.rtl`, stacks a coordinate-only overlay painter on top, and wraps the whole thing in a uniform scale + colour-filter transform for zoom and sepia/dark. The font *is* the typeset page; the OS shaper is never asked to lay out Quran text. This is the **presentation** half of the sacred path — the data, checksums, font registration, and layer separation rules belong to **domain-mushaf-text-integrity**; this skill is how a Flutter `View` consumes them without ever re-shaping, reflowing, or re-typesetting the page.

One rule outranks every visual goal here: **the sacred text is never put at risk for any feature, performance win, or convenience** (`docs/PRD.md` R1; `docs/engineering/08-quran-data-and-immutable-rendering.md` framing rule). Zoom, theme, and overlays transform or sit *beside* the glyph layer — they never touch it.

## When to use

Use when building or placing:
- the muṣḥaf reader screen or a single muṣḥaf **page view** widget
- page navigation (swipe/jump between the 604 pages) over the immutable page
- the reader's **zoom** control and **light/sepia/dark** theme toggle
- a coordinate overlay layer (weak-line, current-ayah, mutashābihāt-anchor, error-position highlight) drawn over the page
- the riwāyah label / muṣḥaf-edition chrome shown around the page

Do NOT use this skill for:
- the **data, font registration, checksums, glyph-string ↔ font pairing, layout-from-data** rules → use **domain-mushaf-text-integrity** (this skill *consumes* its `ImmutableGlyphPage` / `GlyphLine` / `OverlayMarker` types; it does not re-derive them)
- the **confusables dataset, confusion log, discrimination drills, anchor-hint content** that *decide which* words to mark → use **domain-mutashabihat-system** (this skill only *paints* the marker it is handed)
- the **one-time core-pack download / SHA-256 verifier** that delivers the fonts → use **domain-asset-pack-integrity**
- the **bottom-nav tab, route, and ViewModel scaffold** the reader lives in → use **eng-add-feature-module**
- the **Riverpod provider/notifier** holding reader state (current page, zoom, theme) → use **eng-create-riverpod-store**
- the **UI chrome** type/numerals/bidi *around* the page (riwāyah label text, page-number formatting) → use **eng-rtl-and-bidi-layout** and the `type.*` tokens in `docs/design-system/04-typography.md`
- any **adab / copy / framing** judgement (how the riwāyah is worded, what overlays are allowed to look like) → use **domain-adab-and-religious-integrity**

The View here is a *dumb* renderer: it draws glyphs it did not shape and rectangles it did not choose. A page view that line-breaks, re-typesets, font-swaps per theme, or shapes Arabic is the wrong component.

## The canonical pattern

1. **Draw glyphs, never shape them.** Render each line by applying the page's dedicated `fontFamily` (`qpcFontFamily(pageNumber)`) to its opaque glyph-code string with `TextDirection.rtl` and an **empty `fontFamilyFallback`** — a fallback would hand the sacred string back to the OS shaper the moment a glyph is missing. Set the family, draw the string, and do nothing else to it (no normalize, no `String` munging, no splitting into spans). `docs/engineering/08-quran-data-and-immutable-rendering.md` §2 (glyph fonts not the OS shaper; `buildGlyphLine`, `fontFamilyFallback: const []`); `docs/PRD.md` §11.2 (the font *is* the typeset page); `docs/design-system/04-typography.md` §1 (two pipelines — the muṣḥaf is never a `type.*` token and never the UI shaper).

2. **The muṣḥaf is its own pipeline — no `type.*` token, no `TextStyle` sharing.** The page never inherits a UI `TextStyle`, never participates in the app's `MediaQuery.textScalerOf` text-scale, and never resolves `type.family.ui`/`type.family.uiFallback`. The reader has its **own independent zoom** (step 5), which is *not* a `type.*` concern. `docs/design-system/04-typography.md` §1 (UI font never touches the Quran; muṣḥaf reader gets no `type.*` token) and §7 (the Quran reader's zoom is independent of OS chrome text-scale); `docs/PRD.md` §11.2, §12.3.

3. **Line breaks and page breaks come only from the bundled layout data.** Assemble the page from the QUL geometry handed in (group strictly by `page-{p}-line-{l}`, never by verse); **never** call `softWrap`, width-driven wrapping, or `TextPainter` line computation on Quran text. Every break is a dataset row. `docs/engineering/08-quran-data-and-immutable-rendering.md` §3 (layout is data, never runtime line-breaking; `assemblePage`); `docs/PRD.md` §11.2 (line/page breaks come only from bundled layout).

4. **Overlays are rectangles over the glyph layer, never re-typeset text.** Stack a sibling `CustomPainter` layer (`MushafOverlayPainter`) that resolves each `OverlayMarker`'s `(line, position)` word-refs to device `Rect`s from the **same** bundled `PageGeometry` and draws only geometric primitives — weak-line, current-ayah, mutashābihāt-anchor, error-position. The painter carries **no text** and never measures shaped Arabic. Marker colours/radii are design-system tokens (calm, non-gamified), not chosen here. `docs/engineering/08-quran-data-and-immutable-rendering.md` §4 (overlays as coordinates over the glyph layer; `OverlayMarker`, `MushafOverlayPainter`); `docs/PRD.md` §11.2, R1 (markers drawn as coordinate overlays, never by editing/storing reconstructed text).

5. **Zoom and theme transform the rendered layer, not the text.** Apply zoom as a **uniform `Transform.scale`** (origin `Alignment.topRight` for RTL) and sepia/dark as a single `ColorFiltered` over the glyph+overlay `Stack`. There is exactly **one font per page** — dark mode is a colour filter, not a "dark font," and zoom never reflows printed line breaks. `docs/engineering/08-quran-data-and-immutable-rendering.md` §5 (themes/zoom transform the layer, not the text; `mushafPageView`); `docs/PRD.md` §11.2, §18 (zoom + night/sepia by transforming the rendered layer).

6. **Page navigation moves the immutable page, never re-renders its text.** Swipe/jump rebuilds with a new `pageNumber` (a new `fontFamily` + new geometry), each page still drawn glyph-only. Use a `PageView`/`PageController` whose `reverse` honours RTL so page 1→2 advances right-to-left; never reorder or mirror the glyph content itself. `docs/PRD.md` §11.2 (each page selects its dedicated font); `docs/design-system/04-typography.md` §1 (never reflow/restyle a page for any visual goal); RTL paging direction per **eng-rtl-and-bidi-layout**.

7. **Name the riwāyah; never call the page "the Quran" absolutely.** The reader chrome shows the muṣḥaf edition's `displayName`/`riwayah` (e.g. *Ḥafṣ ʿan ʿĀṣim*) so the user always knows which reading is on screen, because the muṣḥaf is a swappable triple selected by `mushaf_id`. That label is **UI chrome**: it is ordinary shaped text set in `type.*` tokens with locale numerals, not part of the sacred path. `docs/engineering/08-quran-data-and-immutable-rendering.md` §1 (`MushafEdition.riwayah`/`displayName`, never "the Quran" absolutely; swappable triple, R2); `docs/PRD.md` §11.2; adab framing in **domain-adab-and-religious-integrity**.

8. **Fail loudly, never substitute quietly.** If a glyph is missing it must surface as visible tofu (caught by the visual-diff gate), not be papered over by a fallback font; if an asset is unverified the reader must **refuse to render Quran text** rather than show an unverified page. The View renders only what the integrity layer has verified. `docs/engineering/08-quran-data-and-immutable-rendering.md` §2 (no fallback on the sacred path; fail loudly) and §6 (refuse to render unverified Quran assets); `docs/PRD.md` §11.1.1, §11.3.

## Do / Don't

| Do | Don't |
|---|---|
| Apply `qpcFontFamily(pageNumber)` to the opaque glyph string with `TextDirection.rtl` and draw it as-is | Normalize, split into `TextSpan`s, search, or log the glyph codes as "the verse" |
| Set `fontFamilyFallback: const []` on every muṣḥaf line | Add any fallback font to the sacred path (it re-shapes the moment a glyph is missing) |
| Take page geometry from the bundled QUL dataset; group by `page-line` | Use `softWrap` / width wrapping / `TextPainter` line-breaking, or group by verse |
| Keep the muṣḥaf in its own pipeline with no `type.*` token and no shared `TextStyle` | Style the page with `type.family.ui` or scale it via OS chrome `textScaler` |
| Draw overlays as `Rect`s in a sibling `CustomPainter` from the same geometry | Re-typeset a highlighted phrase, or persist reconstructed verse text for a marker |
| Zoom = uniform `Transform.scale`; sepia/dark = one `ColorFiltered` | Swap fonts per theme, or reflow line breaks when zooming |
| Page with an RTL-aware `PageView` (`reverse` per direction) | Mirror or reorder the glyph content itself |
| Show the edition `riwayah`/`displayName` as `type.*` UI chrome, with locale numerals | Label the page "the Quran" absolutely, or omit which reading is shown |
| Surface a missing glyph as visible tofu; refuse to render unverified assets | Quietly substitute a font, or render a page whose SHA-256 did not verify |

## Checklist

Before this page view is done:

- [ ] Each line draws the page's `qpcFontFamily(pageNumber)` over its opaque glyph string with `TextDirection.rtl`; **no** normalization/splitting/logging of glyph codes.
- [ ] `fontFamilyFallback: const []` on every muṣḥaf line — nothing can hand the sacred string to the OS shaper.
- [ ] No `type.*` token, no UI `TextStyle`, and no `MediaQuery.textScalerOf` touches the page; the reader's zoom is independent of OS chrome text-scale.
- [ ] Page assembled from the injected QUL geometry, grouped by `page-line` (never by verse); **no** `softWrap`/width-wrap/`TextPainter` line-breaking on Quran text.
- [ ] Overlays are a sibling `CustomPainter` drawing `Rect`s resolved from the same `PageGeometry`; the painter holds no text and measures no shaped Arabic; marker colours/radii come from design-system tokens.
- [ ] Zoom is a uniform `Transform.scale` (origin `Alignment.topRight`); sepia/dark is one `ColorFiltered`; **no** per-theme font swap and **no** reflow on zoom.
- [ ] Page navigation rebuilds with a new `pageNumber`/geometry only, with RTL-correct paging direction (verify fa/ckb/ar advance right-to-left); glyph content is never mirrored or reordered.
- [ ] The riwāyah/edition name is shown as shaped UI chrome (`type.*`, locale numerals via `intl`); the page is never called "the Quran" absolutely (sect-neutral, swappable muṣḥaf).
- [ ] Missing glyphs surface as visible tofu; the View refuses to render any unverified Quran asset (defers to the integrity layer's verified types).
- [ ] Fully offline: the page view fetches nothing at runtime; fonts/geometry arrive from the verified core pack only.
- [ ] No AI, no microphone, no audio-recognition coupling in the reader; no streaks/badges/celebration drawn over the page (no gamification of the muṣḥaf).
- [ ] Muṣḥaf golden test present: render the page with the **real KFGQPC fonts** (via `FontLoader`, never Ahem) under light + sepia + dark + a zoom step, in an RTL `Directionality`, against `matchesGoldenFile`.

This widget *renders* the muṣḥaf; it never decides the text, the layout, or which words to mark. If a page view ever needs to reflow, re-typeset, font-swap per theme, or shape Arabic to hit a visual goal, the goal is wrong — the sacred text does not bend for it (`docs/PRD.md` R1).

## Files

- `template.dart` — copy-paste scaffold: an RTL `MushafPageView` consuming `ImmutableGlyphPage` + overlay markers, a glyph-only line builder with empty fallback, a `MushafOverlayPainter` drawing coordinate `Rect`s, the zoom/`ColorFilter` transform wrapper, an RTL-aware `PageView`, the riwāyah chrome label, and a real-font golden test stub. Fill the `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-mushaf-text-integrity** (the data/font/checksum/overlay-coordinate rules this View consumes), **domain-mutashabihat-system** (decides *which* words a marker covers), **domain-asset-pack-integrity** (delivers and verifies the per-page fonts), **eng-add-feature-module** (the reader screen/route/ViewModel the page view lives in), **eng-create-riverpod-store** (reader state: current page, zoom, theme), **eng-rtl-and-bidi-layout** (RTL paging direction and the chrome around the page), **eng-write-dart-test** (the real-font muṣḥaf golden harness), **domain-adab-and-religious-integrity** (riwāyah wording and reverent treatment of the page).
