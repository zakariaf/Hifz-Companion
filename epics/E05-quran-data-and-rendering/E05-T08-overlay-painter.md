# E05-T08 — MushafOverlayPainter: coordinate-only markers over the glyph layer from the same bundled geometry

| | |
|---|---|
| **Epic** | [E05 — Quran Data & Immutable Rendering](EPIC.md) |
| **Size** | S (≈0.5-1 day) |
| **Depends on** | E05-T07 (the immutable `MushafPageView` glyph layer + the data-driven `assemblePage`, and the `PageGeometry`/`ImmutableGlyphPage` types this painter resolves against) |
| **Skills** | ui-mushaf-page-view, domain-mushaf-text-integrity |

## Goal

`MushafOverlayPainter` exists in `packages/quran` as the sibling `CustomPainter` that draws every marker — `weakLine`, `mutashabihAnchor`, `errorPosition`, `currentAyah` — as a calm rounded `Rect` resolved from each `OverlayMarker`'s `(lineNumber, position)` word-refs against the **same** `PageGeometry` the glyph layer (E05-T07) uses. It is stacked over the immutable glyph layer in `MushafPageView`, addressed by identical geometry, and draws **only** geometric primitives: it carries no text, measures no shaped Arabic, re-typesets nothing, and persists nothing but `(page, line, position)` refs. Marker colours/radii are resolved from design-system token *names* (calm, diagnostic — never decorative or congratulatory); this task only paints a marker it is handed. The *which-words* decision (the confusables dataset, the confusion log, the anchor-hint content) belongs to **E14** — this painter is a dumb consumer of an already-decided `List<OverlayMarker>`.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §4 | The verbatim contract: the glyph page renders into one layer; the overlay painter renders into a **sibling** layer addressed by the **same** bundled geometry. `class OverlayMarker { OverlayKind kind; int pageNumber; List<WordRef> words; }` (kinds: `weakLine | mutashabihAnchor | errorPosition | currentAyah`); `class MushafOverlayPainter extends CustomPainter` with `final List<OverlayMarker> markers; final PageGeometry geometry;`. The `paint` loop: for each marker, `final paint = _paintFor(m.kind)`; for each `WordRef w` in `m.words`, `final Rect box = geometry.wordRect(w.lineNumber, w.position); canvas.drawRRect(RRect.fromRectXY(box, 3, 3), paint);` — "a box, never glyphs". `shouldRepaint(old) => old.markers != markers \|\| old.geometry != geometry`. The three refusals: **refuse to store reconstructed text** (markers persist only `(page, line, position)` refs), **refuse to re-typeset a highlighted phrase** (the anchor highlights in place, never re-renders in another font/widget), **refuse overlays that depend on shaped text metrics** (rectangles come from the bundled word geometry — there is no shaped Arabic on this path to measure) |
| `docs/PRD.md` §11.2 (rendering rules, enforce R1) | "Highlights/overlays (weak line, mutashābihāt anchor, current ayah) are drawn as **rectangles/coordinates over the glyph layer**, computed from the bundled line/word geometry — never by editing text." The painter exists to make this rule structural |
| `docs/PRD.md` §4 R1 (text fidelity, existential) | "Any markers (weak-spot highlight, error position) are drawn as an **overlay of coordinates on the immutable glyph page** — never by re-typesetting or storing reconstructed text." This is the single rule the whole task implements; a marker that carries or rebuilds verse text is an R1 violation |
| Skill **ui-mushaf-page-view** (+ `template.dart`) | Canonical step 4 ("Overlays are rectangles over the glyph layer, never re-typeset text") — the sibling `CustomPainter` resolving each `OverlayMarker`'s `(line, position)` refs to device `Rect`s from the same `PageGeometry`, drawing only primitives, carrying no text, measuring no shaped Arabic, marker colours/radii from design-system tokens (not chosen here). The `template.dart` `MushafOverlayPainter` body (the `paint` loop, `_paintFor(kind)` switch mapping each `OverlayKind` to a token-backed `Paint`, and `shouldRepaint`) is the copy-paste shape; the `// TODO: map each OverlayKind to a design-system color token` markers are this task's work. The Do/Don't row "Draw overlays as `Rect`s in a sibling `CustomPainter` from the same geometry" / "Re-typeset a highlighted phrase, or persist reconstructed verse text for a marker", and the checklist line "Overlays are a sibling `CustomPainter` drawing `Rect`s resolved from the same `PageGeometry`; the painter holds no text and measures no shaped Arabic; marker colours/radii come from design-system tokens" |
| Skill **domain-mushaf-text-integrity** | Canonical step 6 ("Draw every marker as a coordinate overlay on the immutable glyph layer — never re-typeset"): markers are `OverlayMarker`s carrying only `(pageNumber, [WordRef])` — no text; a `CustomPainter` resolves each `WordRef` to a `Rect` from the **same** bundled geometry and draws a calm rounded box; **markers are diagnostic, never decorative or congratulatory**; persist only `(page, line, position)` refs, never reconstructed text. The Do/Don't row "Draw markers as `OverlayMarker` → `Rect` boxes via `CustomPainter`, colors from `color.semantic.*` tokens" / "Re-typeset, reconstruct, or store any verse to draw a highlight" |
| `docs/design-system/13-islamic-identity-and-adab.md` §1, §3 | Markers are diagnostic, never ornament on the words; the reader is "no dashboard" — no badge/counter/confetti/glow/ornamental border over an āyah; chrome (and overlays) defer to the words. This task references token *names* and the diagnostic-not-celebratory rule; the calm colour/radius **token values** are owned by the design-system / component-library (E10), not chosen here (EPIC out-of-scope) |
| `docs/science/CLAIMS.md` | **No CLAIMS id cited** — this task renders no on-screen number, no methodology copy, and no user-facing string; it paints geometric primitives whose colours come from design-system tokens. (The *which-words* / weak-line / mutashābihāt content that some markers later carry traces to its own claims under E14; this painter is content-agnostic) |
| Siblings: E05-T07, E05-T09, E14 | **T07** owns `MushafPageView`, `assemblePage`, the glyph layer, and the `PageGeometry`/`ImmutableGlyphPage`/`GlyphLine` types — this painter is stacked as the sibling layer in T07's `Stack(children: [_GlyphLayer, CustomPaint(painter: MushafOverlayPainter(...))])` and resolves against T07's `PageGeometry`. **T09** wraps the glyph+overlay `Stack` in the zoom (`Transform.scale`, RTL `topRight`) / theme (`ColorFiltered`) frame — overlays scale and recolour *with* the layer because they sit inside that wrapped `Stack`; this task must not apply its own transform. **E14** decides *which* words each marker covers (confusables dataset, confusion log, anchor hints) and hands this painter a finished `List<OverlayMarker>`; this task paints whatever it is handed and never reaches into that decision |

## Implementation notes

TEST-FIRST (correctness-critical): the reason this task exists is R1 — a marker must be coordinates, never text. Write the "the painter holds no text / carries no glyph string" structural cases and the "each `WordRef` resolves to `geometry.wordRect(line, position)` and is drawn as an `RRect`" geometry case **before** the painter body; they must exist and fail before `MushafOverlayPainter.paint` is implemented.

1. **File** → `packages/quran/lib/src/render/mushaf_overlay_painter.dart` (barrel-exported from `lib/quran.dart`, alongside T07's `MushafPageView`). Overlay painting over the glyph layer is muṣḥaf-rendering and is therefore allowed **only** in `packages/quran` (enforced by `tool/check_quran_isolation.sh`, engineering 02 §). It imports no networking symbol and touches no clock — it is a pure `CustomPainter`.

2. **Types** → reuse, do not re-declare. `OverlayMarker`, `OverlayKind`, `WordRef`, and `PageGeometry` come from where E05-T07 / the §4 spec placed them (`OverlayMarker`/`OverlayKind`/`WordRef` are the value shapes; `PageGeometry` is T07's data-derived line/word box source). If T07 has not yet landed `OverlayMarker`/`OverlayKind`/`WordRef`, this task introduces them as immutable value types in `models` (no Flutter import) — but `PageGeometry` and `wordRect(lineNumber, position)` stay with the renderer. Keep exactly one definition of each; do not fork a painter-local copy.

3. **The painter**, exactly per engineering 08 §4 and the skill `template.dart`:
   ```dart
   class MushafOverlayPainter extends CustomPainter {
     MushafOverlayPainter({required this.markers, required this.geometry});

     final List<OverlayMarker> markers;
     final PageGeometry geometry; // line/word boxes from data — NEVER measured from shaped text

     @override
     void paint(Canvas canvas, Size size) {
       for (final OverlayMarker m in markers) {
         final Paint paint = _paintFor(m.kind); // calm, diagnostic; tokens own the colour
         for (final WordRef w in m.words) {
           final Rect box = geometry.wordRect(w.lineNumber, w.position);
           canvas.drawRRect(RRect.fromRectXY(box, _radius, _radius), paint); // a box, never glyphs
         }
       }
     }

     @override
     bool shouldRepaint(MushafOverlayPainter old) =>
         old.markers != markers || old.geometry != geometry;
   }
   ```
   - `paint` draws **only** `drawRRect` (and at most a stroke for an outline kind) — no `TextPainter`, no `canvas.drawParagraph`, no glyph string, no `String` field anywhere on the class. The painter has no text to draw and no shaped Arabic to measure.
   - Each `WordRef`'s rectangle comes **only** from `geometry.wordRect(w.lineNumber, w.position)` — the same bundled QUL geometry the glyph layer uses. The painter never measures the glyph `Text`, never reads font metrics, never computes a box itself.
   - A whole-line marker (e.g. a `weakLine` covering a full muṣḥaf line) is still expressed as its constituent `WordRef`s (or a line-level box the geometry exposes); the painter does not special-case "the whole line" by measuring text.

4. **`_paintFor(OverlayKind kind)` — token-backed, diagnostic, calm.** Map each kind to a `Paint` whose colour and radius come from **design-system token names**, not literals:
   - `weakLine` → the calm "decaying / needs attention" token (the skill names `color.semantic.warning` for a decaying line); a low-alpha fill, never an alarming saturated red block.
   - `currentAyah` → the calm neutral focus token; a quiet wash, not a highlight that competes with the glyphs.
   - `mutashabihAnchor` → the calm anchor/attention token (the distinguishing-word highlight for the E14 micro-drill).
   - `errorPosition` → the diagnostic error token; muted and informative, never punitive/red-alert, never a "wrong!" celebration-inverse.
   - All four are **diagnostic, never decorative or congratulatory**: no glow, gradient, confetti, badge, gold, or ornament; corner radius is a small calm token (the §4 spec uses `3,3`). The painter takes the resolved colours/radii as inputs (passed in, or read from an injected token set) so the *values* stay owned by the design-system/component-library (E10) — this task wires the **names**, not the hex.

5. **No transform here.** Zoom (`Transform.scale`, RTL `topRight`) and sepia/dark (`ColorFiltered`) are applied by E05-T09 to the wrapped glyph+overlay `Stack` — the overlay scales and recolours *with* the glyph layer for free because it sits inside that wrapper. This painter must **not** apply its own `Transform`, its own `ColorFilter`, or any per-theme branch; it paints in the layer's coordinate space and lets the frame transform the whole thing uniformly. (Theme-awareness of a *token value* is fine — a sepia-mode warning token — but the recolour transform is T09's, not this painter's.)

6. **Empty / absent markers render nothing.** `markers: const <OverlayMarker>[]` is the common case (a plain reading page with no overlay) — `paint` is a no-op loop and draws nothing over the glyphs. The painter is always constructed (so the sibling layer exists), but an empty list must leave the page pixel-identical to the bare glyph layer (verified by a golden).

7. **`shouldRepaint` is value-based.** Repaint only when `markers` or `geometry` actually change; the page does not repaint the overlay on every frame. Treat `OverlayMarker`/`WordRef`/`PageGeometry` as value-equal (`==`/`hashCode`) so list identity changes from a new `MushafPageView` build do not force needless repaints, and a genuine marker change does. (If the value types come from `models` with proper equality, `old.markers != markers` is correct; do not fall back to `identical`.)

8. **Pitfalls to avoid:** adding **any** `String`/glyph/`TextPainter`/`drawParagraph` to the painter (it carries no text — that is the whole point); measuring the glyph `Text`/font metrics to derive a box instead of reading `geometry.wordRect` (overlays must not depend on shaped-text metrics — there is no shaped Arabic to measure); persisting or reconstructing verse text to back a marker (markers persist only `(page, line, position)` refs — R1); applying a `Transform`/`ColorFilter`/per-theme recolour inside the painter (that is T09's frame; the overlay would double-transform); hardcoding marker hex/radius literals instead of design-system token names (the calm/diagnostic palette is owned by E10); deciding *which* words to mark (E14 hands a finished `List<OverlayMarker>`); a celebratory/decorative treatment — glow, gradient, gold, badge, confetti — over an āyah (adab §3, no gamification of the muṣḥaf); importing `dio`/`http`/`HttpClient` (this file touches no network); placing the painter outside `packages/quran` (it would fail `check_quran_isolation.sh`).

## Acceptance criteria

- [ ] `MushafOverlayPainter extends CustomPainter` exists in `packages/quran/lib/src/render/mushaf_overlay_painter.dart`, is barrel-exported, lives only in `packages/quran`, imports no networking symbol, and passes `tool/check_quran_isolation.sh`.
- [ ] The painter has fields `List<OverlayMarker> markers` and `PageGeometry geometry` and **no** `String`/text/glyph/`TextPainter` field; `paint` draws only `drawRRect` (a box) per word-ref — never glyphs, never a `Paragraph`, never measured shaped Arabic.
- [ ] For each `OverlayMarker`, for each `WordRef w`, the box is `geometry.wordRect(w.lineNumber, w.position)` from the **same** bundled geometry the glyph layer uses; the painter never derives a box by measuring the glyph `Text` or font metrics.
- [ ] All four `OverlayKind`s (`weakLine`, `mutashabihAnchor`, `errorPosition`, `currentAyah`) map via `_paintFor` to a `Paint` whose colour and corner radius come from **design-system token names** (calm, diagnostic) — no hex/radius literals, no glow/gradient/gold/badge, no celebratory or decorative treatment.
- [ ] The painter applies **no** `Transform`, `ColorFilter`, per-theme recolour, or zoom of its own (those are E05-T09's frame, applied to the wrapped glyph+overlay `Stack`); it paints in the glyph layer's coordinate space.
- [ ] `markers: const <OverlayMarker>[]` is a valid no-op (draws nothing; page pixel-identical to the bare glyph layer); `shouldRepaint` is value-based (`old.markers != markers || old.geometry != geometry`) and does not repaint every frame.
- [ ] No marker carries or persists reconstructed verse text; the only state behind a marker is `(page, line, position)` refs (`OverlayMarker.pageNumber` + `WordRef.lineNumber`/`position`).
- [ ] `OverlayMarker`/`OverlayKind`/`WordRef`/`PageGeometry` are referenced from their single owning location (T07 / `models`), not re-declared painter-locally; every `public` declaration carries a `///` doc comment; `dart format` + analyzer/lint clean; the REUSE license header is present.

## Tests

`packages/quran/test/render/mushaf_overlay_painter_test.dart` (mirrors the source path), `flutter_test` (the test bootstrap installs E01's throwing `HttpOverrides`; this suite must never trip it — painting is offline). Drive the painter with a **synthetic `PageGeometry` fake** that returns known `Rect`s for a small set of `(lineNumber, position)` pairs (e.g. `wordRect(1, 0) → Rect.fromLTWH(10, 20, 30, 18)`), and synthetic `OverlayMarker`s, so geometry resolution is exact and assertable. Use a **recording `Canvas`** (a `Canvas` over a recording `PictureRecorder`, or a test double capturing `drawRRect` calls) to assert what was drawn. Required cases, the first two written FIRST:

- **No text on the painter (the central R1 structural case)**: by construction/reflection over the class, the painter exposes no `String`/text/glyph/`TextPainter` field and its `paint` issues **no** `drawParagraph`/text draw — only `drawRRect`. A recording canvas asserts zero text operations for any marker set, proving a marker is coordinates, never text.
- **Word-ref → exact rectangle**: a marker with `WordRef(line: 1, position: 0)` over the synthetic geometry causes exactly one `drawRRect` whose `Rect` equals `geometry.wordRect(1, 0)` and whose corner radius is the calm token radius; the box comes from the geometry, never from measuring text.
- **All four kinds map to distinct calm token paints**: one marker of each `OverlayKind` resolves through `_paintFor` to the expected token-backed colour (asserted by token name → resolved colour, not a raw hex), and none is a saturated alarm-red block, a glow, a gradient, or a gold/celebratory fill (diagnostic-only).
- **Multi-word and whole-line markers**: a marker spanning three `WordRef`s draws exactly three boxes (one per ref) at the three geometry rectangles; a whole-line `weakLine` covers its constituent word boxes — never one measured "line of text" box.
- **Empty markers are a no-op**: `markers: const []` issues **zero** draw calls; a widget golden (the bare glyph layer vs glyph layer + empty-overlay painter) is pixel-identical.
- **`shouldRepaint` value semantics**: same `markers`+`geometry` ⇒ `shouldRepaint == false`; a changed marker list or changed geometry ⇒ `true`; a new `MushafPageView` build with value-equal markers does not force a repaint.
- **Integration with the glyph layer (widget/golden)**: render `MushafPageView` (T07) with a small synthetic `ImmutableGlyphPage` + a `currentAyah` and a `weakLine` marker, under an RTL `Directionality`, with the **real KFGQPC font** loaded via `FontLoader` (never Ahem) — assert the overlay boxes land over the correct glyph word boxes via `matchesGoldenFile`, and that the glyph layer underneath is byte-identical to the no-marker render (overlays sit beside the glyphs, never recompose them). (The exhaustive 604-page real-font visual-diff is E05-T11; here one or two pages prove alignment.)
- **Offline guard**: the suite runs with the throwing `HttpOverrides` installed and never trips it; no network, no `rootBundle` text load, no clock.

## Definition of Done

- [ ] All acceptance criteria met; the unit + widget/golden suites green under `flutter test` locally and in CI; the no-text and word-ref→rectangle cases were written test-first.
- [ ] **Offline / no-network:** the file imports no networking symbol and lives in `packages/quran` (outside the networking-allowed `packages/assets`); the painter fetches nothing, reads no clock; tests run under the throwing `HttpOverrides` and never trip it; E01's banned-import + dependency-allow-list gates stay green.
- [ ] **No AI / no microphone:** nothing here touches AI, ASR, or audio; it paints geometric rectangles only.
- [ ] **Quran text fidelity (existential):** the painter carries no text and measures no shaped Arabic; every box comes from `geometry.wordRect(line, position)` over the **same** bundled geometry the glyph layer uses; no marker re-typesets, reconstructs, or persists verse text — markers persist only `(page, line, position)` refs (R1); the glyph layer beneath is never recomposed (asserted by the byte-identical-glyph-layer golden).
- [ ] **Immutable rendering:** overlays are coordinate rectangles in a sibling `CustomPainter`, holding no text; the painter applies no transform/recolour of its own (zoom/theme are E05-T09's frame over the wrapped `Stack`); an empty marker list leaves the page pixel-identical to the bare glyph layer.
- [ ] **Sect-neutral adab:** markers are **diagnostic, never decorative or congratulatory** — no badge/counter/confetti/glow/gradient/gold/ornament over an āyah; calm low-alpha token fills only; the painter gates nothing behind piety/wuḍūʾ and renders no riwāyah copy (that chrome is E05-T09); the muṣḥaf surface stays "no dashboard" (design-system §13.3).
- [ ] **RTL + fa/ckb/ar:** N/A user-facing string by construction — the painter ships no copy; the overlays are identical across all three locales (the muṣḥaf and its geometry are locale-independent; only chrome localizes), and the integration golden runs under an RTL `Directionality`.
- [ ] **Accessibility:** N/A `Semantics` on the painter itself (it is the visual overlay layer); the reader's accessible chrome and any toggle for overlays is E05-T09 / the reader feature; overlay colours are calm, low-contrast diagnostic washes that do not rely on colour alone for meaning where a marker conveys state (the kind/placement carries it).
- [ ] **Nothing safe to drop:** the painter is correctness-critical and never degrades — it draws every marker it is handed at its exact geometry; no marker is silently skipped, no page is marked optional/droppable, and a marker is never "approximated" by measuring text.
- [ ] **Deterministic tests:** the suite is fast and deterministic over synthetic `PageGeometry`/`OverlayMarker` fixtures and a recording canvas — no network, no real font I/O outside the one real-font alignment golden, no clock, no randomness; every `public` member has a `///` doc comment and the file carries its REUSE header; `dart format` + analyzer/lint clean.
