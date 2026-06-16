# E13-T05 — Weak-line + mutashābihāt overlay toggles: wire E05's MushafOverlayPainter to profile weak-line refs and confusables refs

| | |
|---|---|
| **Epic** | [E13 — Muṣḥaf Reader](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E13-T03 |
| **Skills** | ui-mushaf-page-view, domain-mushaf-text-integrity, domain-mutashabihat-system |

## Goal

The reader can toggle two diagnostic overlays — **weak-line** markers and **mutashābihāt-anchor** markers — on or off from the reader chrome, each drawn by E05's coordinate-only `MushafOverlayPainter` over the immutable glyph layer. For the page on screen the View assembles a `List<OverlayMarker>` of `(pageNumber, [WordRef])` refs: weak-line refs come from the active profile's `line_block`/`weak_flag` state (read through E03's repository), mutashābihāt-anchor refs come from the read-only confusables dataset (`mutashabih_member.distinguishing_word_index_json`). The reader **paints only the refs it is handed** — it holds no verse text, measures no shaped Arabic, computes no geometry, and decides for *neither* overlay which words are weak or confusable. Both toggles are display-only reader state (E13-T02); flipping them mutates no card, writes no `review_log`, and re-derives no `due_at`.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §11.2 (R1) | Overlays are "rectangles/coordinates over the glyph layer, computed from the bundled line/word geometry — never by editing text"; the marker set is weak-line, mutashābihāt anchor, current ayah. The reader supplies refs, never reconstructs text. |
| `docs/PRD.md` §12.3 | "Weak lines and mutashābihāt anchors shown as overlays (**toggleable**)" — this task owns exactly those two toggles on the reader surface. |
| `docs/PRD.md` §10.1 (`line_block`, `card.weak_flag`, `mutashabih_member`) | Weak-line refs derive from `line_block(profile_id, page_id, line_start, line_end, error_count)` + `card.weak_flag` (per-profile, lazily created for repeatedly-lapsing pages); mutashābihāt refs derive from `mutashabih_member.distinguishing_word_index_json`. The reader **reads** these rows; it never writes or computes them. |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §4 | The exact contract this task wires: `OverlayMarker { OverlayKind kind; int pageNumber; List<WordRef> words }` where `WordRef` is `(lineNumber, position)`; `MushafOverlayPainter` resolves each `WordRef` to a `Rect` from the **same** bundled `PageGeometry` the glyphs use and draws only primitives. "We refuse to store reconstructed text… refuse overlays that depend on shaped text metrics." Use `OverlayKind.weakLine` and `OverlayKind.mutashabihAnchor`. |
| `docs/design-system/04-typography.md` §4–§8 | The two toggle controls' labels are shaped `type.*` UI chrome (16 sp floor, FSI/PDI isolation, locale numerals if a count ever appears) — the overlays are *not* `type.*` and never touch the page pipeline (§1). |
| Skill `ui-mushaf-page-view` (+ `template.dart`) | The dumb-renderer rule: the View "draws rectangles it did not choose"; overlays are a sibling `CustomPainter` over the same `PageGeometry`, carry no text, measure no shaped Arabic, and use design-system token colours/radii (not chosen here). The reader paints the marker it is handed and "only paints the marker it is handed" for mutashābihāt. |
| Skill `domain-mushaf-text-integrity` (+ `template.dart`) | The existential rule the toggles must not relax: markers are `(page, line, position)` refs only; nothing re-typesets, reconstructs, or persists verse text; markers are **diagnostic, never decorative or congratulatory**; no glow/badge/ornament on the words. Weak-line colour is a calm `color.semantic.*` token, not a red shame mark. |
| Skill `domain-mutashabihat-system` | This epic is the *consumer*, not the owner: it draws the anchor "as a highlight rectangle over the KFGQPC glyph layer computed from `distinguishing_word_index_json` and the bundled word geometry"; it **does not** decide which words are confusable, run drills, or log swaps (that is E14). Anchor hinting framed calmly, never gamified. |
| CLAIMS | None new. No user-facing number or copy is introduced by the toggle *mechanism*; the two toggle labels are localized strings owned/translated in E13-T09. The offline/no-mic covenant (C-048) is inherited, not asserted here. |
| Siblings: E13-T01, E13-T02, E13-T03, E13-T09, E13-T10 | T01 supplies the `MushafReaderViewModel` this task extends with an `overlays(pageNumber)` read model; T02 owns the `weakLineVisible`/`mutashabihVisible` toggle bits in the reader-state store (this task *reads and flips* them, does not define the store); T03 supplies the per-page `MushafPageView`/`PageGeometry` the painter sits over; T09 transcreates the two toggle labels + `Semantics` for fa/ckb/ar; T10 owns the overlays-on/off golden rows. |

## Implementation notes

TEST-FIRST (correctness-critical): the ref-assembly mapping below is sacred-text-adjacent — a wrong `WordRef` highlights the wrong word on the muṣḥaf. Write the `overlayMarkers(...)` unit suite (boundary `line_block`, multi-block page, empty page, mutashābihāt span) and assert it emits exactly the expected `(kind, lineNumber, position)` refs **before** wiring the painter into the View.

1. **Read model — `features/lib/src/mushaf/mushaf_reader_view_model.dart`** (extend the E13-T01 ViewModel; do not add a new screen file). Add a pure builder `List<OverlayMarker> overlayMarkers({required int pageNumber, required ReaderOverlayState toggles, required ProfileWeakLines weakLines, required PageConfusables confusables})` that returns:
   - nothing for an overlay whose toggle is off (`toggles.weakLineVisible == false` ⇒ no `weakLine` markers; likewise `mutashabihVisible`);
   - one `OverlayMarker(kind: OverlayKind.weakLine, pageNumber: pageNumber, words: [...])` per weak `line_block` on this page, each `line_start..line_end` expanded to the `WordRef`s of those whole lines (a weak *line*, so every word in the line range);
   - one `OverlayMarker(kind: OverlayKind.mutashabihAnchor, pageNumber: pageNumber, words: [...])` per confusable member on this page, its `words` exactly the `WordRef`s named by `distinguishing_word_index_json` (the distinguishing word(s) only, not the whole āyah).
   The builder is **total and side-effect-free** — no `DateTime.now()`, no DB call, no `Random`; it is handed already-loaded value objects and returns refs. It must reference the E05 `OverlayMarker`/`WordRef`/`OverlayKind` types verbatim (no parallel local copy).

2. **Reader-state read — `features/lib/src/mushaf/mushaf_providers.dart`.** The two toggle bits (`weakLineVisible`, `mutashabihVisible`) live in the E13-T02 `ReaderStateNotifier`; this task only *reads* them via `ref.watch(readerStateProvider.select((s) => s.overlays))` and exposes two callbacks on the ViewModel (`toggleWeakLine()`, `toggleMutashabih()`) that delegate to the E13-T02 notifier's existing setters — **add no new mutation path** and no engine write.

3. **Weak-line refs — repository read, not engine call.** Add a `family` `autoDispose` provider keyed by `(profileId, pageNumber)` that reads the active profile's weak lines for this page from E03's read surface: the `line_block` rows for `(activeProfileId, page_id)` plus the `card.weak_flag` for that page. Project them into a small immutable `ProfileWeakLines` value type carrying only `List<({int lineStart, int lineEnd})>` (no card, no D/S/R, no `due_at`). The reader **never** calls the scheduling engine and never recomputes `weak_flag` or `error_count` — those are E04/E03's outputs (R1: "the app never calculates them"). Key on `activeProfileProvider` (E07) so the weak-line overlay re-reads when the profile switches.

4. **Mutashābihāt refs — read-only dataset.** Add a `family` `autoDispose` provider keyed by `pageNumber` that reads the bundled, checksummed `mutashabih_member` rows whose ayāt fall on this page and projects each to a `PageConfusables` entry of `{List<WordRef> anchorWords}` parsed from `distinguishing_word_index_json` against the bundled page/word geometry. This dataset is read-only reference data (E03 reference tables); the reader runs **no** confusables inference, no graph walk, no `confusion_edge` read — it surfaces the static reviewed prior only.

5. **Geometry resolution stays in E05.** The ViewModel produces `(lineNumber, position)` refs; it never resolves a `Rect`. The E13-T03 `MushafPageView` passes its already-built `PageGeometry` (page + font + current zoom scale) and the assembled `markers` into E05's `MushafOverlayPainter`; the painter does the `geometry.wordRect(...)` resolution. The reader measures no shaped Arabic and computes no box — if a ref is needed for a missing word the painter (E05) is the failure point, not this task.

6. **Wire the toggles into the chrome (View only).** In `MushafReaderScreen` (dumb `ConsumerWidget`), add two calm controls to the existing reader chrome (E13-T08 owns the auto-hide/edge-recede treatment; this task only places the two toggles) — each a token-styled `type.*` label + state, calling `viewModel.toggleWeakLine()` / `viewModel.toggleMutashabih()`. Default both **off** (a clean page first; diagnostics are opt-in, never forced on the sacred surface). No badge, no count bubble, no celebration on toggle.

7. **Colours/radii are tokens, chosen by E05/design-system, not here.** Pass nothing but `OverlayMarker`s; the weak-line paint is a calm `color.semantic.*` warning token and the anchor a calm highlight token, both owned by the painter's `_paintFor(kind)` (E05). Do not introduce a red "you failed here" colour, a glow, or an animated pulse.

8. **Pitfalls to avoid:**
   - Emitting a marker whose `words` were measured from *shaped* text or computed by `TextPainter` — overlays come only from the bundled geometry (08 §4 "refuse overlays that depend on shaped text metrics").
   - Persisting or reconstructing any verse text to draw a highlight (08 §4 "refuse to store reconstructed text").
   - Highlighting the **whole āyah** for mutashābihāt instead of just the `distinguishing_word_index_json` word(s) (it is *anchor* hinting, localized to where continuations diverge).
   - Highlighting a single **word** for a weak line instead of the whole `line_start..line_end` line range (weak-*line*, not weak-word).
   - Calling the scheduling engine or recomputing `weak_flag`/`error_count` in the reader, or reading `confusion_edge` (E14's, not this task's).
   - Letting a toggle write any persisted state, mutate a card, or re-derive `due_at`.
   - Forcing an overlay default-on, or dressing the weak-line marker as a shame/red mark or the anchor as an ornament.

## Acceptance criteria

- [ ] `overlayMarkers({pageNumber, toggles, weakLines, confusables})` exists on `MushafReaderViewModel`, is total and side-effect-free (no clock, no DB, no `Random`), and returns E05's `OverlayMarker`/`WordRef`/`OverlayKind` types verbatim (no local copy) — verifiable by grep + the unit suite.
- [ ] With `weakLineVisible: false` it emits **zero** `weakLine` markers; with `mutashabihVisible: false` it emits **zero** `mutashabihAnchor` markers; both off ⇒ empty list.
- [ ] A weak `line_block` `(line_start, line_end)` expands to the `WordRef`s of **every word in those whole lines**; a multi-block page yields one `weakLine` marker per block; a page with no weak block yields none.
- [ ] A mutashābihāt member yields one `mutashabihAnchor` marker whose `words` are **exactly** the refs from `distinguishing_word_index_json` (the distinguishing word(s) only) — never the whole āyah, never reconstructed text.
- [ ] Toggling either overlay flips only the E13-T02 reader-state bit (via the existing notifier setter); no `card`, no `review_log`, no `due_at`, no engine call is touched (verifiable by a no-write assertion in the unit suite and a grep showing no repository write/engine import on the toggle path).
- [ ] Weak-line refs come from the active profile's `line_block`/`weak_flag` read surface and re-read on profile switch (keyed on `activeProfileProvider`); mutashābihāt refs come from the read-only checksummed dataset — the reader recomputes neither and reads no `confusion_edge`.
- [ ] Both overlays default **off**; the two toggle controls carry `type.*`-styled labels and (in E13-T09) localized `Semantics`; no badge/count/glow/celebration appears on toggle.
- [ ] `MushafOverlayPainter` is given only `markers` + E05's `PageGeometry`; the reader resolves no `Rect`, measures no shaped Arabic, and reconstructs no text.

## Tests

`features/test/mushaf/mushaf_overlay_markers_test.dart` (`flutter_test`, mirrors the source; deterministic — explicit fixture geometry, fixture `line_block`/confusables value objects, no clock, no DB), written FIRST. Required cases:

- **Toggle gating**: `weakLineVisible:false` ⇒ no `weakLine` markers; `mutashabihVisible:false` ⇒ no `mutashabihAnchor` markers; both off ⇒ `[]`; both on ⇒ both kinds present.
- **Weak-line expansion**: a single `line_block(line_start:3, line_end:4)` ⇒ one `OverlayMarker(kind: weakLine)` whose `words` are every `WordRef` on lines 3 and 4 of the fixture geometry; a two-block page ⇒ two `weakLine` markers; boundary blocks (first line, last line of the page) resolve correctly; a page with no block ⇒ no `weakLine` marker.
- **Mutashābihāt anchor**: a member with `distinguishing_word_index_json` naming positions (line 2, pos 5) and (line 2, pos 6) ⇒ one `mutashabihAnchor` marker whose `words` are exactly those two `WordRef`s — and **not** the rest of the āyah; two members on one page ⇒ two anchor markers.
- **No-write / no-engine proof**: a fake repository + fake engine recorder asserts `toggleWeakLine()`/`toggleMutashabih()` call neither a repository write nor any engine method; only the E13-T02 toggle setter fires.
- **No reconstructed text**: assert every emitted `OverlayMarker.words` is `(lineNumber, position)` refs and that no marker carries or exposes a verse string (the `OverlayMarker` type has no text field — a regression guard if E05's type ever changes).

`features/test/mushaf/mushaf_overlay_widget_test.dart` (widget): pumps `MushafReaderScreen` under `Directionality.rtl` with a fixture page; flips each toggle and asserts the `MushafOverlayPainter` receives the expected marker count for each on/off combination; asserts both default **off** on first build.

Golden coverage (overlays on vs off, across light/sepia/dark + a zoom step, real KFGQPC fonts via `FontLoader`, RTL `Directionality`) is authored in **E13-T10** and consumes this task's `overlayMarkers(...)` output — not duplicated here.

Offline guard: the widget test installs an `HttpOverrides`-that-throws; flipping either overlay opens no socket (the refs come from already-loaded reference data, the geometry from E05).

CI gates (E01/E05) stay green: no `softWrap`/`TextPainter` on Quran text introduced, no banned import, no reconstructed-text persistence, no network.

## Definition of Done

- [ ] All acceptance criteria met; both unit and widget suites green locally and in CI on every PR.
- [ ] **Offline / no-network:** flipping either overlay opens no socket and fetches nothing; refs come from already-loaded reference data and E05 geometry; the `HttpOverrides`-throws guard passes (CLAIMS C-048 inherited).
- [ ] **No AI / no microphone:** the overlay path uses no AI, ASR, inference, or audio; mutashābihāt refs are the static reviewed dataset, not a model output; nothing couples to a microphone.
- [ ] **Text fidelity (existential):** overlays are `(page, line, position)` coordinate refs only, painted by E05's `MushafOverlayPainter` over the unmodified glyph layer; nothing is re-typeset, reconstructed, or persisted as verse text; no marker depends on shaped-text metrics; the glyph layer is byte-identical with overlays on or off.
- [ ] **Sect-neutral adab:** markers are **diagnostic, never decorative or congratulatory** — no glow/badge/confetti/ornament on the words, no red shame mark for a weak line; the anchor highlights only the objective distinguishing word(s), issues no gloss of *why* verses differ, and adds no tafsīr/interpretation.
- [ ] **RTL + fa/ckb/ar strings:** the two toggle controls carry `type.*`-styled labels routed through `gen_l10n` for fa/ckb/ar (transcreation + `Semantics` in E13-T09), with FSI/PDI isolation; the overlay rectangles themselves are locale-independent (the muṣḥaf is identical across all three locales).
- [ ] **Accessibility:** each toggle is a ≥48dp control with a localized `Semantics` label and announces its on/off state; overlay colours meet the contrast floor and do not rely on colour alone (a weak line is also positioned/shaped distinctly), under RTL focus order.
- [ ] **Nothing safe to drop:** an absent weak-line marker never implies a page is "safe", "done", or droppable; the overlays surface no D/S/R, percentage, score, or streak — they are calm reference rectangles, not a status display.
- [ ] **Single write path / no engine mutation:** the toggles and ref reads mutate no card, append no `review_log`, re-derive no `due_at`, and call no scheduling engine; weak-line/`weak_flag`/`error_count` and the confusables set are read-only inputs owned by E04/E03/E14.
- [ ] **Deterministic tests:** `overlayMarkers(...)` is pure (no clock/DB/RNG); fixtures are explicit; the marker output is asserted exactly; the real-font golden rows live in E13-T10.
