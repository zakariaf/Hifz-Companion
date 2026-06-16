# E13-T10 — Reader tests: jump-to/ViewModel units + real-font RTL muṣḥaf goldens (light/sepia/dark + zoom + overlays on/off)

| | |
|---|---|
| **Epic** | [E13 — Muṣḥaf Reader](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E13-T04, E13-T05, E13-T06, E13-T08 |
| **Skills** | eng-write-dart-test, ui-mushaf-page-view, domain-mushaf-text-integrity |

## Goal

The reader's consolidated test suites exist and run on every PR: pure-Dart **jump-to resolution/seek units** with the sacred-boundary pages pinned as a frozen vector table; **overlay-toggle and reader-state ViewModel units** proving the chrome is display-only and the toggles gate markers correctly; and the **real-font muṣḥaf goldens** — loaded via `FontLoader`, never Ahem — that render the assembled reader page across `ReaderTheme.light`/`.sepia`/`.dark`, a single zoom step, and overlays on/off, all under an RTL `Directionality`. A throwing `HttpOverrides` guard installed via the shared bootstrap proves the radio stays off while paging and jumping. The reader **inherits** E05's 604-page visual-diff coverage and adds **no** re-rendered reference images of its own — its goldens fix only the *chrome assembly* (theme/zoom/overlay frame) over the page E05 already proves byte-exact.

## Context & references

| Reference | What to take from it |
|---|---|
| [E13 EPIC.md](EPIC.md) — Scope (reader-feature tests), Deliverables #9, Risks, DoD ("Tests") | This task's exact charter: the jump-to resolution/seek units, the overlay-toggle/reader-state ViewModel units, and the real-font RTL muṣḥaf goldens (light/sepia/dark + a zoom step + overlays on/off); the verbatim DoD sentence — goldens run in CI on every PR, the reader inherits E05's 604-page visual-diff and **adds none of its own re-rendered references** |
| `docs/PRD.md` §11.2 | The render invariants the goldens prove are *not relaxed* by the reader chrome: glyph-font-only, line/page breaks from bundled layout, markers as coordinate overlays, zoom = uniform scale + sepia/dark = `ColorFilter` over the rendered layer (never a per-theme font swap), RTL paging — a golden that moved a diacritic or reflowed a line under zoom/dark/overlay must fail the build |
| `docs/PRD.md` §12.3 | The reader behaviours under test: RTL swipe, jump to juz/ḥizb/sūrah/page, toggleable weak-line + mutashābihāt overlays — the unit + golden cases mirror these affordances |
| `docs/PRD.md` §6.1 | The fixed 30 juz → 60 ḥizb → 240 rubʿ → 604 pages hierarchy the jump-to vectors pin the **boundary pages** of, read from data and never recomputed |
| `docs/engineering/11-testing-strategy.md` §3 | Frozen golden-vector discipline: a committed `(input) → (output)` table asserted to tolerance, regenerated only by an explicit `--update-vectors` run a human reviews — CI only ever *verifies*; the jump-to boundary table is the executable form of "read, never recompute" |
| `docs/engineering/11-testing-strategy.md` §4 | `(card, grade, today) → card'` and any deterministic logic is a **unit/property test, never a `pumpWidget`**; jump-resolution and the overlay-marker builder are pure units, not widget pumps |
| `docs/engineering/11-testing-strategy.md` §5 | The muṣḥaf-fidelity golden recipe: load the **real bundled KFGQPC page fonts + UI fonts via `FontLoader`** in `setUpAll` (never Ahem, which draws solid squares and defeats the test), pin `devicePixelRatio`/`physicalSize`/theme, disable animations, `@Tags(['golden'])` → the pinned Linux-only golden job, `await expectLater(..., matchesGoldenFile(...))`; masters regenerated with `--update-goldens` **locally** and reviewed, never blessed in CI |
| `docs/engineering/11-testing-strategy.md` §6 | RTL goldens pump each key screen under `Directionality(textDirection: TextDirection.rtl)` for `ar`/`fa`/`ckb` with locale numerals/calendars; widget tests use **in-memory fakes** via Riverpod overrides (never a real DB/assets) and pump explicit durations (never `pumpAndSettle` on an indefinite indicator) |
| `docs/engineering/11-testing-strategy.md` §7 | Offline is a test invariant: every test keeps the binding's default block **and** installs a throwing `HttpOverrides` so a stray call is a loud, named failure; only the single asset-downloader test opts out — the reader suites never do |
| `docs/engineering/11-testing-strategy.md` §8 | CI shape: the fast job runs the units; the **pinned, Linux-only** golden job runs `--tags=golden`; masters stay stable only because the runner OS/Flutter version are pinned — the reader goldens land in that job, not the fast job |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §3 | "We refuse to recompute the hierarchy" — the jump-to vectors assert `page_id` read from the `page` reference table, never arithmetic like `(juz-1)*20+1`; an off-by-one on a sacred boundary is the bug the table catches |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §4 | The overlay contract the marker-builder unit asserts: `OverlayMarker { OverlayKind kind; int pageNumber; List<WordRef> words }`, `WordRef = (lineNumber, position)`, painter resolves to `Rect`s from the same geometry — markers carry **no text**; the unit guards that no reconstructed verse string is ever produced |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §5, §6 | Zoom/theme transform the layer (the golden's zoom step + theme rows prove no reflow / no font swap); the reader renders only verified assets — the goldens load the *real* verified fonts, the unit/widget tier uses in-memory fakes |
| `docs/design-system/04-typography.md` §1 | Two pipelines, one rule: the reader's zoom is the muṣḥaf's **own** uniform scale, independent of OS chrome text-scale — the golden zoom step is a reader-state `zoom`, set on the store, never `MediaQuery.textScaler` |
| Skill `eng-write-dart-test` (+ `template.dart` Blocks B, D, E, F, H) | The exact scaffolds: Block B (frozen vector table + `closeTo`-style assertion for the jump boundary set — here exact `int` page ids), Block D (real-`FontLoader` fidelity golden, pinned DPR/size/theme, `@Tags(['golden'])`), Block E (RTL/locale golden under `Directionality.rtl`), Block F (widget test with in-memory Riverpod fakes, explicit pumps), Block H (`useOfflineTestPolicy()` throwing-`HttpOverrides` bootstrap); REUSE SPDX header on every file, full-word/unit-bearing names |
| Skill `ui-mushaf-page-view` (+ `template.dart`) | What the goldens must prove holds under the chrome: `fontFamilyFallback: const []` on every line, no `softWrap`/`TextPainter` on Quran text, overlays as sibling `CustomPainter` `Rect`s, zoom = uniform `Transform.scale` (RTL `topRight`) + sepia/dark = one `ColorFiltered`, RTL paging, riwāyah named — the checklist's "muṣḥaf golden test present: real KFGQPC fonts via `FontLoader`, light + sepia + dark + a zoom step, RTL `Directionality`" is *this* task's deliverable |
| Skill `domain-mushaf-text-integrity` (+ `template.dart`) | The outranking covenant the goldens enforce: "a dropped or shifted diacritic must change pixels and fail the build"; goldens load **real** KFGQPC (never Ahem), tight tolerance, min-OS — and the reader's chrome goldens must not become a *second* 604-page reference set (that gate lives in E05); they fix only the assembly frame on a small fixed page set |
| `docs/science/CLAIMS.md` C-031 | "one card = one muṣḥaf page (604)" framing behind the page-as-unit navigation any "604 pages" copy under test traces to |
| `docs/science/CLAIMS.md` C-048 | "Works fully offline … never records voice … one-time checksum-verified download, then airplane-mode forever" — the covenant the throwing-`HttpOverrides` guard proves and the no-microphone/no-AI assertion the suites carry |
| Sibling E13-T04 | Ships its own resolver boundary-vectors + picker widget test; **this task folds the jump-to resolution/seek units into the consolidated reader suite** and reuses T04's `QuranStructureRepository.firstPageOf` / `JumpTarget` / the E13-T03 `PageController` page-index mapping — it does not re-author the resolver |
| Sibling E13-T05 | Owns `MushafReaderViewModel.overlayMarkers(...)`; T05 ships the marker-builder unit + a widget toggle test, and explicitly defers the **overlays-on/off golden rows to this task**, which consumes its `overlayMarkers(...)` output |
| Sibling E13-T06 | Owns the zoom (uniform scale) + light/sepia/dark (`ColorFiltered`) controls as layer transforms; this task's golden matrix exercises the `ReaderTheme` values and the zoom step those controls set on the E13-T02 store |
| Sibling E13-T02 | Owns the `MushafReaderState` value type + `mushafReaderStateProvider` (`autoDispose`) and ships its own notifier unit suite; this task's **reader-state ViewModel units** assert the ViewModel ↔ store binding (the View's reads of `pageNumber`/`zoom`/`theme`/overlay bits drive the render frame) without re-authoring the notifier's command tests |
| Sibling E13-T08 | Owns the no-dashboard chrome (edge-receding, auto-hiding controls, no gamification/ornament/piety gate); the golden rows assert the assembled page carries no streak/badge/confetti/glow/ornamental-border/piety-gate widget over the āyah |

## Implementation notes

**TEST-FIRST (correctness-critical):** the jump-to boundary table and the overlay-gating unit are sacred-correctness checks — a wrong juz/ḥizb/sūrah start page sends the reader to the wrong āyah, and a leaking toggle paints a marker on a page it does not belong to. Write the **frozen boundary-page vector table** and the **toggle-gating cases first**; they must exist and fail before the reader is wired through them. The goldens are written against a small **fixed fixture page set** (e.g. page 1 al-Fātiḥa, page 2 al-Baqarah opening, and one dense mid-muṣḥaf page) — not all 604 (that is E05's gate).

1. **File homes (all under the `features` package's `test/`, except the shared bootstrap):**
   - `packages/features/test/mushaf/jump_to_resolution_test.dart` — the consolidated jump-to resolution/seek units (`flutter_test` with an in-memory Drift fixture seeded from the bundled `page`/`surah` reference rows, or `package:test` if T04's resolver is pure over an eagerly-loaded snapshot).
   - `packages/features/test/mushaf/reader_view_model_test.dart` — the overlay-toggle + reader-state ViewModel units (`flutter_test` `ProviderContainer`, no widget pump for the pure read models).
   - `packages/features/test/mushaf/golden/reader_page_golden_test.dart` — the real-font RTL muṣḥaf goldens, `@Tags(['golden'])`.
   - `packages/features/test/test_setup.dart` (or reuse the repo-shared bootstrap) — `useOfflineTestPolicy()` installing the throwing `HttpOverrides`.
   Mirror source names; one REUSE SPDX header (`GPL-3.0-or-later`) per file; `dart format` clean; full-word/unit-bearing names.

2. **Jump-to resolution/seek units — boundary pages pinned (Block B shape).** Reuse E13-T04's `QuranStructureRepository.firstPageOf(JumpTarget)`. Author a committed frozen table `(JumpUnit, index) → expectedPageId`:
   - the **first page of every juz 1–30** and **every ḥizb 1–60** (these are the sacred boundaries that must be *read*, never `(juz-1)*20+1`-derived);
   - a representative sūrah spread — al-Fātiḥa→1, al-Baqarah→2, an-Nās, plus a few mid-muṣḥaf sūrahs (resolved to the page where that sūrah's **first āyah** falls, the rule T04 pins);
   - `page → page` identity at the endpoints (1 and 604).
   Assert exact `int` page ids (not `closeTo` — these are addresses, not floats). The table is regenerated only by an explicit `--update-vectors` run reviewed in the diff; CI never blesses. Add the **seek** case: choosing a target calls `controller.jumpToPage(pageIndexFor(expectedPageId))` over the E13-T03 RTL page-index mapping (page 1 → first slot), and the reader-state `pageNumber` updates only via the controller's `onPageChanged`, never written directly by the picker. Add the **range-guard** case: juz 0/31, ḥizb 0/61, sūrah 0/115, page 0/605 each yield the sealed error (or are unreachable), never a silent page-1 fallback.

3. **Reader-state + overlay-toggle ViewModel units.** Over a `ProviderContainer` with in-memory Riverpod overrides:
   - **Display-only proof** — flipping `zoom`/`theme`/the two overlay bits and seeking pages touches no `card`, appends no `review_log`, opens no `db.transaction`, calls no `package:engine` symbol, and reads no `DateTime.now()` (assert via spy repositories/fakes that record any write). This is the epic's single-write-path DoD held verbatim at the reader's ViewModel seam (the notifier's own command tests live in E13-T02; here we assert the **binding**).
   - **Overlay gating** (consuming E13-T05's `overlayMarkers(...)`) — `weakLineVisible:false` ⇒ zero `weakLine` markers; `mutashabihVisible:false` ⇒ zero `mutashabihAnchor` markers; both off ⇒ `[]`; both on ⇒ both kinds present; **both default off** on first build.
   - **No reconstructed text** — every emitted `OverlayMarker.words` is `(lineNumber, position)` refs only; assert no marker carries or exposes a verse string (a regression guard if E05's `OverlayMarker` type ever grew a text field).

4. **Real-font RTL muṣḥaf goldens (Block D + E shape) — the assembly frame, not a second 604-page set.** In `setUpAll`, load the **actual bundled KFGQPC per-page fonts + the fa/ckb/ar UI fonts via `FontLoader`** (never Ahem). Pin `tester.view.devicePixelRatio`, `tester.view.physicalSize`, and the theme; disable animations. Pump the assembled reader page (`MushafReaderScreen`/`MushafPager` over the fixture page) under `Directionality(textDirection: TextDirection.rtl)`. Capture the matrix over the **fixed fixture page set**:
   - `ReaderTheme.light`, `.sepia`, `.dark` (proves sepia/dark is a `ColorFilter`, not a per-theme font swap);
   - one **zoom step** at the reader's own `zoom` factor (proves uniform `Transform.scale`, RTL `topRight` origin, no reflow of printed line breaks, independent of OS text-scale);
   - **overlays off** and **overlays on** (weak-line + mutashābihāt anchor markers as coordinate `Rect`s over the *unchanged* glyph layer — the glyph pixels under the overlay must match the overlays-off master except where a box is drawn).
   Master file names are descriptive and stable (e.g. `goldens/mushaf/reader_p001_dark_zoom120_overlays_on.png`). `@Tags(['golden'])`; `await expectLater(finder, matchesGoldenFile(...))`. Keep the page set **small and fixed** — the all-604 visual-diff is E05's gate (PRD §20 gate 2); duplicating it here would create a second, drift-prone reference set the DoD forbids.

5. **Offline guard.** Install `useOfflineTestPolicy()` (the throwing `HttpOverrides` from Block H) via the shared bootstrap across all three reader suites; none of them opts out. Add an explicit assertion in the jump/seek unit that resolving a target and seeking the controller makes **no** network attempt (the throw would surface as a loud failure). This is the reader's half of the C-048 covenant: the radio stays off while paging and jumping.

6. **No-microphone / no-AI assertion.** A small structural assertion (or a documented absence) that the reader suites import no ASR/audio/AI symbol and the assembled `MushafReaderScreen` widget tree contains no audio/recorder/mic widget — the reader couples to no microphone and no audio-recognition (C-048; PRD §17/§19.3).

7. **Pitfalls to avoid:**
   - Asserting jump-to page ids with `closeTo`/float tolerance — they are exact `int` addresses; tolerance would hide an off-by-one on a sacred boundary.
   - Driving the resolver or the overlay-marker builder through `pumpWidget` instead of a pure unit (11 §4 — slower, flakier, hides which layer broke).
   - Loading **Ahem** (or any font-independent/colored-block strategy) in the muṣḥaf goldens — that strategy is allowed for *layout* goldens but **forbidden** for fidelity goldens; it draws every glyph as a square and would silently pass a corrupted page.
   - Re-rendering all 604 pages here, creating a second reference set that drifts from E05's gate (the DoD's "adds no re-rendered references" violation).
   - Running the goldens on an un-pinned/macOS CI runner (cross-OS golden drift is documented) — they must carry `@Tags(['golden'])` so they land only in the pinned Linux golden job.
   - Letting a golden's zoom come from `MediaQuery.textScaler` instead of the reader-state `zoom` (couples the sacred zoom to OS chrome text-scale — forbidden by type-04 §1).
   - Auto-blessing vectors or goldens in CI (the gate would assert nothing); `--update-vectors`/`--update-goldens` are local-and-reviewed only.
   - `pumpAndSettle()` on the auto-hiding chrome's animation (E13-T08) — pump explicit durations.
   - A widget test reaching a real Drift DB or real asset bytes (use in-memory Riverpod fakes); only the goldens load the real fonts, and they do so via `FontLoader`, not a live socket.

## Acceptance criteria

- [ ] The three reader test files exist under `packages/features/test/mushaf/` (resolution, ViewModel, golden) plus the shared offline bootstrap; each carries the REUSE SPDX header and is `dart format` clean.
- [ ] **Jump-to boundary table** pins the first page of every juz (1–30) and every ḥizb (1–60), a representative sūrah spread (al-Fātiḥa→1, al-Baqarah→2, an-Nās, mid-muṣḥaf), and the page-identity endpoints (1, 604), asserting **exact `int`** page ids read from the `page`/`surah` reference tables (no arithmetic derivation; regenerated only by a reviewed `--update-vectors` run).
- [ ] The **seek** case asserts a chosen target calls `controller.jumpToPage(...)` over the E13-T03 RTL page-index mapping and that reader-state `pageNumber` updates only via the controller's `onPageChanged`, never written directly.
- [ ] The **range-guard** case asserts every out-of-range index (juz 0/31, ḥizb 0/61, sūrah 0/115, page 0/605) yields the sealed error / is unreachable — never a silent page-1 fallback.
- [ ] The **display-only** ViewModel unit proves flipping zoom/theme/overlays and seeking pages mutates no `card`, appends no `review_log`, opens no transaction, calls no engine symbol, and reads no `DateTime.now()`.
- [ ] The **overlay-gating** unit (over E13-T05's `overlayMarkers(...)`) asserts each toggle independently gates its marker kind, both off ⇒ empty, both default off on first build, and no marker carries reconstructed verse text.
- [ ] The **real-font RTL muṣḥaf goldens** load the actual KFGQPC + UI fonts via `FontLoader` (never Ahem), pin DPR/size/theme, disable animations, pump under `Directionality.rtl`, are `@Tags(['golden'])`, and cover `light`/`sepia`/`dark` × overlays-on/off × one zoom step over a **small fixed fixture page set**.
- [ ] The goldens prove no relaxation: the glyph pixels are identical across themes (filter, not font swap), across the zoom step (uniform scale, no reflow), and with overlays on except where a coordinate box is drawn; the chrome shows the riwāyah and no gamification/ornament/piety-gate widget.
- [ ] The reader **adds no all-604 reference set** — the fidelity visual-diff over all pages remains E05's gate; this task fixes only the assembly frame on the fixture set.
- [ ] The throwing `HttpOverrides` is installed across all three suites; a jump/seek/page/toggle makes no network call.
- [ ] All suites run in CI on every PR — the units + ViewModel tests in the fast job, the goldens in the pinned Linux-only golden job (`--tags=golden`).

## Tests

This task *is* the test deliverable; the files below are its product.

**`packages/features/test/mushaf/jump_to_resolution_test.dart`** — `flutter_test` (in-memory Drift fixture seeded from the bundled reference rows) or `package:test` (pure snapshot resolver), REUSE SPDX header, throwing `HttpOverrides` via the shared bootstrap. Cases, written FIRST:
- **Frozen boundary-page vectors** — exact `(JumpUnit, index) → page_id` for every juz 1–30, every ḥizb 1–60, the sūrah spread, and endpoints (1, 604); reviewed `--update-vectors` only.
- **Seek** — target → `jumpToPage(pageIndexFor(page))` in RTL direction; `pageNumber` updates via `onPageChanged` only.
- **Range guard** — every out-of-range index → sealed error / unreachable; never page-1 fallback.
- **Read-only / offline** — the resolve+seek path issues no write, opens no transaction, and makes no network attempt.

**`packages/features/test/mushaf/reader_view_model_test.dart`** — `flutter_test` `ProviderContainer`, in-memory Riverpod overrides:
- **Display-only** — zoom/theme/overlay flips + page seeks touch no card/`review_log`/transaction/engine/`DateTime.now()` (spy fakes record any write).
- **Overlay gating** — each toggle gates its kind; both off ⇒ `[]`; both default off; markers carry no verse text.
- **State ↔ render-frame binding** — the View's `pageNumber`/`zoom`/`theme`/overlay reads feed the E05 render frame (`mushafPageView(pageNumber, theme, zoom)` + assembled `markers`) unchanged.

**`packages/features/test/mushaf/golden/reader_page_golden_test.dart`** — `flutter_test`, `@Tags(['golden'])`, real KFGQPC + UI fonts via `FontLoader` in `setUpAll`, pinned DPR/size/theme, animations off, under `Directionality.rtl`:
- The **matrix** over the fixed fixture page set: `ReaderTheme.{light,sepia,dark}` × `{overlays off, overlays on}` × `{base zoom, one zoom step}`, each `await expectLater(find.byType(MushafReaderScreen), matchesGoldenFile('goldens/mushaf/reader_...png'))`.
- Masters regenerated with `--update-goldens` **locally** and reviewed; CI never blesses.

**`packages/features/test/test_setup.dart`** — `useOfflineTestPolicy()` (throwing `HttpOverrides`, Block H), imported by all three suites; only the asset-downloader test (elsewhere) opts out.

**Offline/no-network guard:** the throwing `HttpOverrides` stays installed across every reader suite; any stray connection attempt is a loud, named failure (C-048).

## Definition of Done

- [ ] All acceptance criteria met; the three suites green locally and in CI — the units/ViewModel tests in the fast job, the goldens in the pinned, Linux-only golden job on every PR.
- [ ] **Offline / no-network (non-negotiable):** the throwing-`HttpOverrides` guard is installed across all reader suites and proves the radio stays off while paging, jumping, zooming, and toggling (CLAIMS C-048); no suite opts out; E01's no-network/banned-import gates stay green.
- [ ] **No AI / no microphone:** the suites import no ASR/audio/AI symbol, and the assembled reader widget tree under test contains no microphone/recorder/audio-recognition widget (C-048; PRD §17/§19.3).
- [ ] **Quran text fidelity (existential):** the goldens load the **real** KFGQPC fonts via `FontLoader` (never Ahem), prove the glyph layer is pixel-identical across light/sepia/dark (filter, not font swap), across the zoom step (uniform scale, no reflow), and with overlays on except where a coordinate box draws — a dropped/shifted diacritic or a reflowed line must move pixels and fail the build; the reader adds **no** re-rendered all-604 reference set (that visual-diff remains E05's gate).
- [ ] **RTL + fa/ckb/ar strings:** every golden pumps under `Directionality.rtl`; the chrome's localized labels/numerals/`Semantics` (E13-T09) render in the locale block; the muṣḥaf page pixels are identical across locales (only chrome localizes) — the goldens confirm the page is never mirrored or reordered.
- [ ] **Accessibility:** the goldens render under RTL `Directionality`; the units assert the muṣḥaf's `zoom` stays independent of OS chrome text-scale (no reflow); the interactive controls' localized `Semantics` labels (owned by T09/T06/T05/T08) are present in the assembled tree.
- [ ] **Sect-neutral adab:** the golden chrome shows the riwāyah `displayName` and is never labeled "the Quran" absolutely; no tafsīr/translation is drawn beside the page; the assembled tree carries no badge/counter/confetti/glow/ornamental border over an āyah, no page-flip fanfare, and no wuḍūʾ/piety gate (the no-dashboard treatment, E13-T08).
- [ ] **Nothing safe to drop / single write path:** the ViewModel units prove reader state is display-only — no page is marked droppable/optional/done, no raw D/S/R or percentage is surfaced, no scoreboard/streak is asserted present, and no card/`review_log`/`due_at` is written from the reader.
- [ ] **Deterministic tests:** the jump-to boundary vectors are frozen exact-`int` and human-reviewed (no auto-bless); the resolver and overlay-marker builder are pure units (not `pumpWidget`); the goldens are pinned (DPR/size/theme/OS/Flutter version) and tagged — all running in CI on every PR.
