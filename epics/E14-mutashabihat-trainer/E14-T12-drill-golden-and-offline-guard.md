# E14-T12 — Drill muṣḥaf golden (whole-group, reveal→anchor, RTL × fa/ckb/ar) + offline guard

| | |
|---|---|
| **Epic** | [E14 — Mutashābihāt Trainer](EPIC.md) |
| **Size** | M |
| **Depends on** | E14-T08, E14-T09, E14-T11 |
| **Skills** | eng-write-dart-test, domain-mushaf-text-integrity |

## Goal

The release-blocking visual proof for the discrimination drill exists as a tagged, pinned-runner golden suite plus a throwing-`HttpOverrides` offline guard. Real bundled **KFGQPC per-page glyph fonts** (never Ahem) render the `DiscriminationDrillView` (E14-T08) for a whole confusable group, golden-captured at each choreography state — **sibling hidden → revealed → anchor highlight** (E14-T09) — under `Directionality.rtl` for **fa, ckb, ar** on the real UI fonts, so a dropped/shifted diacritic, a reflowed line, a re-typeset āyah, a moved anchor `Rect`, or a broken RTL layout moves pixels and fails the build. A separate offline guard pumps the drill and the hotspots surface with a `HttpOverrides` that throws on any socket and proves the trainer path opens none. This task writes only **tests and golden masters** — no production widget code; it freezes the pixels the E14-T08/T09/T11 surfaces already produce.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §9.2 (behaviours), §9.3 (standalone trainer) | The drill contract this golden freezes: whole-group siblings back-to-back, reveal-on-tap retrieval, the anchor on the distinguishing word — the visual states the golden must capture, no more |
| `docs/PRD.md` §11.2 (rendering rules, enforce R1), §11.3 (the integrity gate this golden is part of) | The anchor and every marker are **coordinate overlays on the immutable glyph layer**, never re-typeset; the muṣḥaf golden is the build invariant that proves the rendered page (and the anchor `Rect` over it) is byte/pixel-faithful — a wrong diacritic must fail the build |
| `docs/science/05-interference-and-mutashabihat.md` §6 (anchor on the distinguishing word as overlay) | What the anchor frame asserts: the distinguishing word is a **highlight rectangle over the KFGQPC glyph layer** from `distinguishing_word_index_json` + bundled word geometry — "the Quran is rendered, never re-typeset"; the golden is the regression catch for any reshape/reconstruct |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §6 (integrity pipeline: checksum gates + visual-diff) | The golden harness shape this task mirrors at the drill scale: `setUpAll(loadRealKfgqpcFontsForGoldens)` via `FontLoader` (never Ahem, which draws squares), pinned DPR/size/theme, tight tolerance, min-OS pinned runner, `matchesGoldenFile`; the gate verifies, never blesses |
| `docs/engineering/11-testing-strategy.md` §5 (real-font muṣḥaf goldens), §6 (widget/RTL/journey tiers), §7 (throwing `HttpOverrides`), §8 (golden CI job + `@Tags(['golden'])`) | The tier placement (widget+golden, **not** a journey — no fifth `integration_test`), the per-locale RTL golden loop, the `@Tags(['golden'])` → Linux-only pinned job, and the offline-guard bootstrap that throws on any connection attempt |
| `docs/engineering/03-coding-standards.md` §4 (REUSE SPDX header), §7.2 (banned networking imports), §8.1 (sacred-text checklist) | Every test file carries the `GPL-3.0-or-later` SPDX header; no `package:http`/`dio`/`dart:io HttpClient` in the trainer path; the dropped/shifted-diacritic golden *is* the §8.1 sacred-text guard at the drill surface |
| Skill **eng-write-dart-test** (+ `template.dart` Block D fidelity golden, Block E RTL/locale golden, Block H throwing-`HttpOverrides` bootstrap) | The fidelity-golden scaffold (real `FontLoader`, pinned DPR/size, `@Tags(['golden'])`), the per-`Locale` RTL golden loop for `ar`/`fa`/`ckb`, in-memory Riverpod fakes for the read models (no real DB/assets in a widget test), and `useOfflineTestPolicy()` from the shared bootstrap |
| Skill **domain-mushaf-text-integrity** (+ its golden checklist) | What a *correct* pixel is: glyph codes drawn in the page's `QPC_P###` font with `fontFamilyFallback: const []`, layout from the QUL dataset (never width-wrapped), the anchor as an `OverlayMarker` `Rect` over the same geometry; the golden loads **real** KFGQPC fonts at tight tolerance and spot-checks the anchor box sits on the distinguishing word, not re-typeset text |
| CLAIMS — **none newly registered** | T12 surfaces **no** on-screen number or methodology claim; it *proves* the already-graded behaviour rows render faithfully (C-026 interference-not-decay, C-027 objective wording, **C-028** back-to-back contrast, **C-029** whole-group/no-isolated-sibling, C-030, C-045 no-gamification). **Invent no CLAIMS id**; assert no new numeral |
| Siblings **E14-T08, E14-T09, E14-T11** | T12 freezes what they produce: T08 supplies the `DiscriminationDrillView` (whole-group A→B→…, hidden → reveal-on-tap → anchor, composing E05/E13's `MushafPageView`) and the `/mutashabihat/drill/:groupId` route; T09 supplies the anchor `Rect` overlay via `MushafOverlayPainter` from `distinguishing_word_index_json`; T11 supplies the transcreated fa/ckb/ar strings the chrome renders. T12 authors **no** production widget — it captures their output |
| Siblings **E14-T10, E14-T01/T02/T06** | T12 may pump the `ConfusionHotspotsView` (E14-T10) under the offline guard (proving the whole trainer path is offline) and consumes the E14-T01 dataset + E14-T06 read-model providers as **in-memory fakes** seeded with a fixed confusable group; it re-runs none of T01's dataset-integrity, T02/T03's write-path, or T04/T05's engine-wiring suites |

## Implementation notes

This task **is the test** — there is no production Dart to write beyond a minimal golden harness widget if E14-T08 did not already expose a pumpable entry. The bar is: the golden fails loudly on any text-fidelity, anchor-placement, or RTL-layout regression, and the offline guard fails loudly on any socket. Place the work at the **widget+golden tier** (testing-strategy §1, §6) — the drill is a screen, not one of the four `integration_test` journeys; do **not** add a fifth journey.

1. **Files** (testing-strategy §5, §6; eng-write-dart-test Blocks D/E/H):
   - `packages/features/test/mutashabihat/golden/discrimination_drill_golden_test.dart` — the fidelity + RTL goldens (`@Tags(['golden'])`).
   - `packages/features/test/mutashabihat/mutashabihat_offline_guard_test.dart` — the throwing-`HttpOverrides` guard over the drill + hotspots path (untagged; runs in the fast job).
   - reuse the shared `packages/features/test/test_setup.dart` `useOfflineTestPolicy()` (Block H) — do **not** define a second `HttpOverrides`.
   - golden masters under `packages/features/test/mutashabihat/golden/goldens/drill/` (one PNG per state × locale).

2. **Load the real fonts, never Ahem** (testing-strategy §5; eng-08 §6; domain-mushaf-text-integrity): in `setUpAll`, `FontLoader`-load the **real bundled KFGQPC page font(s)** for the test group's page(s) **and** the fa/ckb/ar UI fonts (Vazirmatn/the Sorani+Arabic UI set) over `rootBundle`. Ahem renders every glyph as a solid square and would make a re-typeset āyah pass — it is forbidden on the muṣḥaf surface. Drawing must use `fontFamilyFallback: const []` (inherited from E05's `MushafPageView`); a missing glyph must surface as visible tofu, never re-shape.

3. **Pin everything deterministic** (testing-strategy §5): fix `tester.view.devicePixelRatio`, `tester.view.physicalSize`, the theme, and disable animations; inject a **fixed `today`** (`CalendarDate`/`clockProvider` override) so no `DateTime.now()` is reachable; seed the read models from **in-memory fakes** (Riverpod `overrideWith`) holding one fixed confusable group (≥2 siblings) with known `distinguishing_word_index_json` — never the real Drift store or live assets in a widget test (testing-strategy §6). The fuzz/`Random` seam stays OFF; two runs must be pixel-identical.

4. **Capture the whole-group reveal→anchor states** (PRD §9.2; science 05 §6; C-028, C-029): golden-capture, per locale, at least —
   - **`hidden`**: sibling A’s page presented with the branch concealed (reveal-on-tap retrieval surface), no anchor yet;
   - **`revealed`**: after the reveal tap (`await tester.pump(motionDurationShort)` — an explicit pump, never `pumpAndSettle` on an indefinite indicator), the immutable glyph page shown, still no anchor;
   - **`anchor`**: the anchor `Rect` highlight drawn over the distinguishing word on the immutable layer;
   - and the **next sibling** (B) presented back-to-back in the same view — proving no spacing/interstitial/unrelated page sits between siblings and no isolated-single-sibling terminal state exists (C-028, C-029). The anchor frame is the load-bearing fidelity check: it asserts the highlight sits on the diverging word over rendered glyphs, not over reconstructed text.

5. **RTL × fa/ckb/ar by construction** (testing-strategy §6, §7; eng-rtl-and-bidi-layout): loop `for (final locale in const [Locale('ar'), Locale('fa'), Locale('ckb')])`, pump under `Directionality(textDirection: TextDirection.rtl)` with the locale’s numerals (`-u-nu-arabext` for fa/ckb, `-u-nu-arab` for ar) and the E14-T11 transcreated strings; capture per state per locale (`goldens/drill/<state>_<locale>.png`). The **muṣḥaf glyph layer is identical across all three locales** (only chrome localizes — domain-mushaf-text-integrity); the per-locale goldens prove the *chrome* mirrors and the page does not. The chrome (title, reveal control, sibling label) uses the **real UI fonts** so the Sorani extra letters / Persian-digit path is exercised — the font-independent (Ahem/coloured-block) strategy is **forbidden** on this surface because the page is a fidelity golden.

6. **Tag for the pinned golden job** (testing-strategy §8; eng-08 §6): `@Tags(['golden']) library;` so the suite runs only in the Linux-only, pinned-OS golden CI job at tight tolerance; goldens are OS/font/Flutter-version-sensitive. Masters are regenerated with `--update-goldens` **locally** and reviewed in the diff — **CI never blesses**, only verifies.

7. **Offline guard** (testing-strategy §7; EPIC DoD): in `mutashabihat_offline_guard_test.dart`, install the shared throwing `HttpOverrides` (`useOfflineTestPolicy()`), pump the `DiscriminationDrillView` (drive a full reveal→anchor→next-sibling cycle) and the `ConfusionHotspotsView` with in-memory fakes, and assert the run completes with **zero** connection attempts — any socket throws a loud, named `StateError`. The trainer reads only the bundled dataset + the local `confusion_edge` graph; it must open no socket. This is a fast-job widget test, not a golden.

8. **Pitfalls** (testing-strategy §5–§7; domain-mushaf-text-integrity): rendering the golden with Ahem (defeats the diacritic check); a loose pixel tolerance ("close enough" is not a standard the sacred text gets); `pumpAndSettle()` on the reveal motion (pump an explicit `motion.duration.short`); a real Drift store / live asset load in a widget test (use fakes; the real stack is `integration_test` only); leaving fuzz/`Random` ON (non-deterministic pixels); a single-locale capture, or assuming LTR; importing `package:http`/`dio`/`HttpClient` into the trainer path; auto-blessing goldens/vectors in CI; capturing an isolated single-sibling terminal state (violates C-029); asserting any streak/score/badge/confetti widget *exists* (none may); inventing a CLAIMS id or a new on-screen numeral; a missing REUSE SPDX header.

## Acceptance criteria

- [ ] `discrimination_drill_golden_test.dart` exists, is `@Tags(['golden'])`, loads the **real** KFGQPC page font(s) + fa/ckb/ar UI fonts via `FontLoader` in `setUpAll` (never Ahem), and pins `devicePixelRatio`/`physicalSize`/theme with animations disabled.
- [ ] For one fixed confusable group (≥2 siblings, known `distinguishing_word_index_json`), the suite golden-captures the **hidden**, **revealed**, **anchor**, and **next-sibling (back-to-back)** states — proving whole-group juxtaposition with no spacing/interstitial and no isolated-single-sibling terminal state.
- [ ] Each state is captured under `Directionality.rtl` for **ar, fa, ckb** with the locale’s numerals and the E14-T11 transcreated strings; masters live under `goldens/drill/<state>_<locale>.png`.
- [ ] The anchor golden asserts the highlight `Rect` sits over the distinguishing word on the **immutable glyph layer** (rendered KFGQPC glyphs), not over re-typeset/reconstructed text; a moved/reshaped anchor or a reflowed line moves pixels and fails.
- [ ] A dropped/shifted diacritic, a re-typeset āyah, or a width-wrapped line in the drill page changes pixels and fails the golden (the §8.1 sacred-text guard at the drill surface).
- [ ] `mutashabihat_offline_guard_test.dart` installs the shared throwing `HttpOverrides` and proves a full reveal→anchor→next-sibling drill cycle **and** the hotspots surface complete with zero connection attempts; a stray socket throws a named failure.
- [ ] Both suites are deterministic (in-memory faked read models, injected fixed `today`/`clockProvider`, fuzz/`Random` OFF, pinned golden runner); two runs are pixel-identical; no `DateTime.now()` is reachable.
- [ ] No production widget logic is added (no new drill/anchor/string behaviour — those are E14-T08/T09/T11); only tests, a minimal pumpable harness if needed, and golden masters.
- [ ] No `package:http`/`dio`/`dart:io HttpClient` import appears in the trainer path or these tests; the banned-import / no-network gate has nothing to catch; every test file carries the `GPL-3.0-or-later` REUSE SPDX header and passes the analyzer/lint config and `dart format`.

## Tests

`packages/features/test/mutashabihat/` — `flutter_test`; goldens run in the **pinned Linux golden CI job** (`@Tags(['golden'])`, testing-strategy §8), the offline guard in the **fast job**. The shared `test_setup.dart` installs the throwing `HttpOverrides`; read models are in-memory Riverpod fakes; `today` is a fixed `CalendarDate`. The dataset-integrity (E14-T01), write-path (E14-T03), and engine-wiring (E14-T04/T05) suites are **not** duplicated here.

- `discrimination_drill_golden_test.dart` (golden, `@Tags(['golden'])`):
  - **fidelity — real fonts**: `setUpAll` loads the real KFGQPC page font(s) + UI fonts via `FontLoader`; the drill page renders glyph codes with `fontFamilyFallback: const []`; `matchesGoldenFile('goldens/drill/hidden_<locale>.png')` … per state.
  - **reveal→anchor sequence**: pump `hidden` → tap reveal → `pump(motion.duration.short)` → capture `revealed` → trigger anchor → capture `anchor`; assert each master per locale. Explicit pumps only, never `pumpAndSettle` on the reveal.
  - **whole-group, back-to-back**: advance to sibling B in the same view; capture `next_sibling_<locale>.png`; assert no interstitial/spacing page renders between A and B and no single-sibling terminal screen is reachable (C-028, C-029).
  - **anchor-on-glyph-layer**: assert (by golden + a `find`-based `Rect` check against the `MushafOverlayPainter` geometry) the anchor box maps to the `distinguishing_word_index_json` word over rendered glyphs, not reconstructed text (PRD R1; science 05 §6).
  - **RTL × fa/ckb/ar**: the `for (locale in [ar, fa, ckb])` loop pumps under `Directionality.rtl` with per-locale numerals; the muṣḥaf glyph layer is byte-identical across locales while the chrome mirrors; goldens captured per locale.
  - **fidelity-failure proof**: a deliberate diacritic-shift / re-typeset fixture (in a `// dart format off`-free helper) is shown to fail the golden — documenting that the gate is live (kept as a commented or skipped negative-control note, not a green test).
- `mutashabihat_offline_guard_test.dart` (widget, fast job):
  - **drill opens no socket**: under `useOfflineTestPolicy()`, pump the drill, drive reveal→anchor→next-sibling; assert completion with no `HttpClient` creation (the throwing override is never hit).
  - **hotspots opens no socket**: pump `ConfusionHotspotsView` (E14-T10) with faked `confusion_edge` rows; assert the same.
  - **banned-import / no-network grep** stays green over the new files; no `DateTime.now()` is reachable.

(The drill **behaviour** tests — reveal-on-tap state machine, whole-group iteration order, no-isolated-sibling rule — are owned by E14-T08; the anchor `Rect` **computation** unit test by E14-T09; the ARB key-coverage + adab pass by E14-T11. T12 freezes the *pixels* and proves *offline*, it does not re-assert those behaviours.)

## Definition of Done

- [ ] All acceptance criteria met; the golden suite green in the pinned Linux golden CI job and the offline guard green in the fast job, on every PR.
- [ ] **Offline / no-network (non-negotiable):** the drill and hotspots path opens no socket; the throwing-`HttpOverrides` guard passes; E01's banned-import/no-network gates stay green over the new files; nothing in these tests or the trainer path imports `http`/`dio`/`HttpClient`.
- [ ] **No AI / no microphone / no inference:** the goldens render the bundled scholar-reviewed dataset group via in-memory fakes and the local `confusion_edge` graph only; no recording, speech-to-text, on-device model, or runtime "similar-verse" inference is pumped or reachable (PRD C2, R5; science 05 §7).
- [ ] **Quran text fidelity (existential):** the golden loads the **real** KFGQPC fonts (never Ahem) at tight tolerance; the anchor is captured as a coordinate `Rect` overlay over the immutable glyph layer; a dropped/shifted diacritic, a re-typeset/reshaped āyah, a width-wrapped/reflowed line, or a moved anchor box moves pixels and fails the build (PRD R1, §11.2, §11.3; eng-08 §6; science 05 §6).
- [ ] **Whole-group, juxtaposed, no isolated sibling:** the captured states show siblings back-to-back in one view with no spacing/interstitial between them and no single-sibling terminal screen; the golden proves the C-028/C-029 contract visually.
- [ ] **RTL + fa/ckb/ar strings:** every state is golden-captured under `Directionality.rtl` for ar/fa/ckb on the real UI fonts with per-locale numerals and the E14-T11 transcreated chrome; the muṣḥaf glyph layer is identical across locales while the chrome mirrors; the font-independent strategy is **not** used on this sacred surface.
- [ ] **Accessibility:** the goldens are captured with reveal using `motion.duration.short` and OS Reduce-Motion respected (no celebratory motion exists); the anchor highlight is not encoded by colour alone (shape/box, per E14-T09); the captured chrome carries its per-locale `Semantics` labels.
- [ ] **Sect-neutral adab / nothing safe to drop:** the captured surfaces contain no points/badges/streaks/confetti and no "cured"/"resolved"/"safe to drop"/"safe to stop drilling" copy; a test assertion confirms no such widget/string is present; copy stays an aid to revision and a servant to the teacher.
- [ ] **No unsourced number / deterministic tests:** T12 surfaces no on-screen number or new methodology claim and invents no CLAIMS id (it proves C-026…C-030/C-045 render faithfully); the suites are deterministic (faked read models, injected fixed `today`, fuzz/`Random` OFF, pinned runner, real fonts) — two runs are pixel-identical; CI verifies goldens, never blesses. Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`) and `///` docs on any public API and passes `dart format` and the analyzer/lint config.
