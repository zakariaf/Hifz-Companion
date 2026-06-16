# E04-T08 — buildToday: tradition-shaped day, SR ordering, mutashābihāt sibling massing

| | |
|---|---|
| **Epic** | [E04 — Scheduling Engine](EPIC.md) |
| **Size** | L (≈2-3 days) |
| **Depends on** | E04-T07 |
| **Skills** | domain-scheduling-engine-rules, eng-write-engine-golden-vector |

## Goal

`buildToday(List<Card> cards, SerialDay today)` exists in the pure-Dart `engine/` package exactly as engineering 06 §7 specifies: **tradition shapes the day and SR only orders it and pulls weak pages forward.** It assembles the three recitation bands — FAR (manzil), NEAR (sabqi), NEW (sabaq) — in recitation order **manzil → near → new** (old before new), then hands the flat day list to `loadBalance` (E04-T09). The FAR band is `farCycleSliceForToday(...)` (the chosen cycle *guarantees* full coverage) plus `pullFwd` (Far pages whose recomputed `R < retentionFloor(card)` that are **not already in the slice**), sorted weakest-`R`-first, then passed through `expandMutashabihat` which masses each due page's confusable sibling(s) into the **same** session back-to-back — the one place the engine *adds* a not-yet-due card (additive contrast, never spaced apart). NEAR is the recent-juz window, weakest-first; NEW is the active memorizer's sabaq lines. `R` is recomputed per card with the injected `today` — no clock anywhere. After this task the day is built deterministically and `phaseOf`-banded; `loadBalance` (catch-up, deferral, peak-smoothing) is E04-T09. Sibling massing is correctness-critical and is built behind INV-2 test-first.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/06-scheduling-engine.md` §7 (building the day) | The verbatim `DayPlan buildToday(List<Card> cards, SerialDay today)`: the `rOf(c)` closure (`c.lastReview == null ? 1.0 : retrievability(today.value - c.lastReview!.value, c.s)` — `R` recomputed per card, `today` injected, no clock); the FAR assembly `expandMutashabihat(sortByWeakestR([...cycleSlice, ...pullFwd], rOf))` where `cycleSlice = farCycleSliceForToday(far, today, config)` and `pullFwd = far.where((c) => rOf(c) < retentionFloor(c) && !cycleSlice.contains(c))`; NEAR `sortByWeakestR(… phaseOf(c) == Track.near && inRecentWindow(c, config) …)`; NEW `sabaqLines(config.newLinesPerDay)`; the day `[...farToday, ...nearToday, ...newToday]`; the `return loadBalance(day, config.dailyBudgetMinutes, today, rOf)` hand-off; and the four refusals (never drop manzil, never dump a backlog, never space siblings apart, never a guilt surface) |
| `docs/engineering/06-scheduling-engine.md` §7 (`expandMutashabihat`, massing rule) | Interference is cured by **massing, not spacing**: when a page in a mutashābihāt group is due, pull its sibling(s) into the *same* session back-to-back so the brain practices discrimination; this is the one place the engine *adds* a not-yet-due card and it is additive contrast, **never** a dropped review and **never** spaced apart |
| `docs/engineering/06-scheduling-engine.md` §6 / §7.11 wiring | `config.pureCycleMode` turns SR *ordering and pull-forward* OFF (fixed-rotation only): in pure-cycle mode `farToday` is the bare `cycleSlice` (no `pullFwd`, no weakest-`R` reordering) — the app degrades to a faithful traditional tracker; the ceiling itself is E04-T07's concern, the ordering toggle is this task's |
| `docs/PRD.md` §7.8 (building the day — visible = tradition, ordering = SR) | The canonical pseudocode this task implements: FAR `cycleSlice + pullFwd` (R < floor, not already in slice) → `expandMutashabihat(sortByWeakestR(...))`; NEAR recent-juz window weakest-first; NEW today's + yesterday's sabaq lines; `day = farToday + nearToday + newToday` "recited OLD before NEW (manzil → near → new)"; `return loadBalance(day, cfg.daily_budget)` |
| `docs/PRD.md` §7.9 (load balancing & graceful catch-up) | The hand-off contract only: `buildToday` returns the *flat banded day list* to `loadBalance`, which makes FAR/manzil mandatory, orders NEAR by urgency, fits NEW to budget, and re-spreads after a gap — **E04-T09 owns that body**; this task must produce a day whose `phaseOf` bands `loadBalance` can read |
| `docs/PRD.md` §7.12 (engine invariants) | "FAR/manzil due items are never silently dropped" → INV-2 (every due Far page appears in the built plan); "The engine never displays or implies 'this page is safe to stop revising'" → no band, sort, or massing step ever removes a memorized card; "identical inputs → identical schedule" → `buildToday` is pure (INV-4) |
| `docs/science/03-spaced-repetition-algorithms.md` §8 (the `(11−D)` interference channel) | Why confusable pages are *harder* and surface together: interference rides difficulty, and discrimination practice is the cure — the science behind massing the siblings rather than scheduling them independently |
| `docs/science/06-overlearning-and-lifelong-retention.md` §6, §8 | §6: the permastore plateau still slopes — no Far page is ever "safe to drop," so the FAR slice + pull-forward keeps every page in rotation; §8: spacing over massing in *quota* decisions, with the one deliberate exception that interference is cured by massing siblings (this task's `expandMutashabihat`) |
| Skill `domain-scheduling-engine-rules` (+ `template.dart`) | Rule 19 (tradition shapes the day; SR only orders + pulls forward; recitation order manzil → near → new; manzil un-skippable) and Rule 20 (`expandMutashabihat` masses confusable siblings into one session — the one place the engine *adds* a not-yet-due card; **never** space siblings apart). The Do/Don't rows "Pull mutashābihāt siblings into the same session (massed contrast)" / "Space confusable siblings apart" and "Tradition shapes the day; SR only orders…" — and Rule 2 (no clock: `rOf` recomputes `R` from the injected `today` by integer subtraction) |
| Skill `eng-write-engine-golden-vector` (+ `template.dart`) | INV-2 as a `glados` property over generated `(Card set, today)` cases: every due FAR/manzil page appears in `buildToday(...)`'s plan (manzil never dropped); INV-4 determinism (two `buildToday` runs are fingerprint-equal, fuzz OFF); the band-ordering and sibling-massing golden cases asserted with integer/structural equality (the day is an ordered list of opaque page ids, not floats — `closeTo` does not apply here); constants referenced by name (`retentionFloor`, `kHardFloorR`, `inRecentWindow`); rely on shrinking, no fixed lucky seed |
| `docs/science/CLAIMS.md` C-034 | The user-facing methodology this banding *is*: hifz revision is traditionally organized in three tracks — new (sabaq), recent (sabqi), far (manzil/dhor) — rendered here as the FAR → NEAR → NEW recitation order of one card's three phases. `[TRAD]` — methodology, **no fiqh ruling**, madhhab/sect-neutral; the science-screen row and the swappable track-label strings are E19/the UI layer, not this task — invent no new citation |
| Siblings: E04-T02, E04-T05, E04-T07, E04-T09, E04-T11, E14 | T02 supplies `Card` (page id 1..604, `track`, `lastReview`, `s`) and the `Track` enum; T05 supplies `phaseOf(card)` (the band each page falls in) and `targetR`/`retentionFloor`; **T07 (this task's dependency)** supplies `EngineConfig` (`pureCycleMode`, `farCycleDays`, `newLinesPerDay`, `dailyBudgetMinutes`) and `retrievability`; **T09** owns `loadBalance` — this task only produces the flat banded day and calls it; T11 owns the broader §7.12 property suite — this task lands INV-2 (manzil never dropped) and the massing/ordering goldens as its test-first core; the scholar-reviewed mutashābihāt confusables dataset that the `confusionSiblings(card)` lookup reads is seeded by **E05/E14** — this task consumes an injected sibling lookup, it does not build the dataset |

## Implementation notes

TEST-FIRST: the sibling-massing rule and the manzil-never-dropped guarantee are correctness-critical covenants. Write the INV-2 property and the `expandMutashabihat` massing golden case **below** *before* `buildToday`/`expandMutashabihat` exist; a stub that spaces siblings apart, or that drops a due Far page when the slice is empty, must fail before the real assembly is written.

1. **Files** (in the package scaffolded by E04-T01): `packages/engine/lib/src/build_today.dart` for `buildToday`, `expandMutashabihat`, and the private helpers (`sortByWeakestR`, `farCycleSliceFortoday`, `inRecentWindow`, `sabaqLines`); the `DayPlan` result value type in `packages/engine/lib/src/day_plan.dart` (an immutable `final` value type carrying `final List<Card> items;` and the `budgetOverflow` flag `loadBalance` sets — E04-T09 fills the flag, this task constructs the band-ordered `items`). Re-export both from the `packages/engine/lib/engine.dart` barrel. Every file carries the REUSE SPDX header (`GPL-3.0-or-later`).

2. **`buildToday`** (engineering 06 §7, verbatim shape) — pure function of `cards` + injected `today` + the engine's `config`:
   ```dart
   /// Build today's revision day: tradition shapes it, SR only orders + pulls forward.
   /// Recitation order is manzil → near → new (old before new). PRD §7.8.
   DayPlan buildToday(List<Card> cards, SerialDay today) {
     final memorized = cards.where((c) => c.track != Track.unmemorized).toList();
     // R is recomputed per card; no clock, `today` is injected. PRD §7.8.
     double rOf(Card c) => c.lastReview == null
         ? 1.0
         : retrievability(today.value - c.lastReview!.value, c.s);

     // FAR (manzil): the cycle GUARANTEES coverage; SR only orders + pulls forward.
     final far = memorized.where((c) => phaseOf(c) == Track.far).toList();
     final cycleSlice = farCycleSliceForToday(far, today, config); // tradition: e.g. 1 juz
     final pullFwd = config.pureCycleMode
         ? const <Card>[]                                          // §7.11: pull-forward OFF
         : far.where((c) => rOf(c) < retentionFloor(c) && !cycleSlice.contains(c)).toList();
     final farOrdered = config.pureCycleMode
         ? cycleSlice                                              // §7.11: SR ordering OFF
         : sortByWeakestR([...cycleSlice, ...pullFwd], rOf);
     final farToday = expandMutashabihat(farOrdered);             // mass confusable siblings

     // NEAR: recent-juz window, weakest-first.
     final nearToday = sortByWeakestR(
         memorized.where((c) => phaseOf(c) == Track.near && inRecentWindow(c, config)).toList(),
         rOf);

     // NEW: today's + yesterday's sabaq lines (active memorizers only).
     final newToday = sabaqLines(config.newLinesPerDay);

     // Recited OLD before NEW: manzil → near → new.
     final day = [...farToday, ...nearToday, ...newToday];
     return loadBalance(day, config.dailyBudgetMinutes, today, rOf); // E04-T09
   }
   ```
   `retrievability`, `phaseOf`, `retentionFloor`, and `EngineConfig` are E04-T03/T05/T07 — **call** them, never re-derive a constant. `loadBalance` is E04-T09; until it lands, return `DayPlan(items: orderForRecitation(day), budgetOverflow: false)` directly so this task is testable on its own, and convert to the `loadBalance` call when T09 merges. The `rOf` closure is the single place `R` is recomputed; nothing reads a clock.

3. **`expandMutashabihat`** — the one place the engine *adds* a not-yet-due card. For each page in the ordered FAR list, look up its scholar-reviewed confusable sibling(s) via the injected `confusionSiblings(card)` lookup (the dataset is E05/E14; the engine consumes the lookup, does not own it) and splice each missing sibling **immediately after** its due page so the group recites back-to-back:
   ```dart
   /// Mass confusable siblings back-to-back in the SAME session (additive contrast).
   /// PRD §9.2 — interference is cured by massing, NEVER by spacing siblings apart.
   List<Card> expandMutashabihat(List<Card> ordered) {
     final result = <Card>[];
     final seen = <int>{};                       // page ids already placed
     for (final card in ordered) {
       if (seen.add(card.pageId)) result.add(card);
       for (final sib in confusionSiblings(card)) {
         if (seen.add(sib.pageId)) result.add(sib); // adjacent → same session
       }
     }
     return result;
   }
   ```
   A sibling pulled in this way is **additive** — it is never removed from, deferred past, or spaced apart from its group; if a sibling is itself independently due it is deduplicated (placed once, in group order) by the `seen` set. An empty sibling lookup yields the input list unchanged.

4. **`pureCycleMode` is the SR-ordering toggle here** (engineering 06 §7.11). When `config.pureCycleMode` is `true`, FAR is the bare `farCycleSliceForToday(...)` rotation: **no** `pullFwd`, **no** weakest-`R` reordering — a faithful traditional tracker. (`expandMutashabihat` still masses siblings — massed discrimination is methodology the tradition shares, not SR reordering, and it never spaces anything apart.) The ceiling that makes pure-cycle a one-flag change is E04-T07; this task honors the flag in *day assembly*. Do not add any clock or pull-forward path that ignores the flag.

5. **Recitation order is structural, never sorted away.** The three bands are concatenated `[...farToday, ...nearToday, ...newToday]` so manzil precedes near precedes new; `sortByWeakestR` orders **within** a band only and must be a stable sort keyed on `rOf` ascending (weakest first) so equal-`R` pages keep a deterministic order (sort the page id as the tiebreak — never leave order undefined, it would break INV-4 determinism). `orderForRecitation` (if used before T09 lands) preserves the band concatenation.

6. **`farCycleSliceForToday` / `inRecentWindow` / `sabaqLines` are pure helpers** — each a function of the cards + `today` + `config` only. `farCycleSliceForToday` returns the Far pages the chosen named cycle assigns to *this* day (e.g. one juz of a 30-day rotation), computed by integer day arithmetic on `today.value` and `config.farCycleDays`; `inRecentWindow` is the recent-juz NEAR membership test against `config`; `sabaqLines` returns the active memorizer's new lines (empty for a finished ḥāfiẓ with no active sabaq). None reads a clock, opens a DB, or consumes randomness.

7. **Pitfalls to avoid**: spacing mutashābihāt siblings apart — they MUST be adjacent in the same session (rule 20; INV would catch a non-adjacent sibling); dropping a due Far page when `cycleSlice` is empty or the budget is tight (manzil is mandatory — that guarantee is `loadBalance`'s in T09, but `buildToday` must *emit* every due Far page so it can be made mandatory; INV-2 catches a dropped Far page here); reordering across bands (new before old) — the concatenation order is the recitation order and is never globally sorted; an unstable or tiebreak-less `sortByWeakestR` (non-determinism breaks INV-4 — tiebreak on page id); honoring `pullFwd`/weakest-`R` reordering in `pureCycleMode` (the flag turns SR ordering off — rule, §7.11); reading `phaseOf` such that a page lands in two bands (a page is in exactly one band per `phaseOf`); calling `retrievability` with `DateTime`-derived elapsed instead of `today.value − card.lastReview.value` integer subtraction (rule 2 — no clock); building the mutashābihāt dataset inside `engine/` (it is injected from E05/E14 — the engine consumes a `confusionSiblings` lookup only); inlining a juz size, a window length, or `7`/`30` as a literal (those are `config.*`); a guilt/shame framing leaking into a doc comment ("overdue", "behind") — the day is calm and finite (R3).

## Acceptance criteria

- [ ] `build_today.dart` exists under `packages/engine/lib/src/` with `buildToday(List<Card>, SerialDay) → DayPlan` and `expandMutashabihat(List<Card>) → List<Card>`, plus pure helpers `sortByWeakestR`, `farCycleSliceForToday`, `inRecentWindow`, `sabaqLines`; `DayPlan` is an immutable value type in `day_plan.dart`; both re-exported from the `engine.dart` barrel; each carries the REUSE SPDX header.
- [ ] `buildToday` assembles the day in recitation order **manzil → near → new** (`[...farToday, ...nearToday, ...newToday]`) — old before new — and the band order is a structural concatenation, never a global sort.
- [ ] FAR = `farCycleSliceForToday(...)` (cycle coverage) + `pullFwd` (`rOf(c) < retentionFloor(c) && !cycleSlice.contains(c)`), sorted weakest-`R`-first by a **stable** `sortByWeakestR` (tiebreak on page id), then passed through `expandMutashabihat`.
- [ ] `expandMutashabihat` splices each due page's confusable sibling(s) **immediately after** it (same session, back-to-back), is additive (never removes/defers/spaces a sibling), deduplicates by page id, and returns the input unchanged when the sibling lookup is empty.
- [ ] `R` is recomputed per card via the local `rOf` closure from the **injected** `today` (`today.value − card.lastReview.value`, integer subtraction; `1.0` when `lastReview == null`) — no `DateTime.now()`, no clock anywhere reachable from `buildToday`.
- [ ] In `config.pureCycleMode`, FAR is the bare `cycleSlice` with **no** `pullFwd` and **no** weakest-`R` reordering (SR ordering/pull-forward OFF); `expandMutashabihat` still masses siblings; the rest of the day is the unreordered traditional rotation.
- [ ] Every **due FAR/manzil page** that `phaseOf` bands as Far appears in the built `DayPlan.items` — no band, sort, or massing step removes a memorized card (the guarantee `loadBalance` then makes mandatory).
- [ ] The engine consumes an **injected** `confusionSiblings` lookup; no mutashābihāt dataset, glyph, or layout is built inside `engine/`; the `engine/` dependency line stays `meta` (+ `models`) — no `drift`, `flutter`, `dart:io`, `DateTime`, or runtime `fsrs` — verifiable by grep and the E04-T01 purity gate.
- [ ] Every public declaration has a `///` doc; `dart format` and `dart analyze --fatal-infos` are clean; no `print`/`debugPrint`; no `!`/`late`/`dynamic` used to dodge the non-null `dueAt`/page-id honesty.

## Tests

`packages/engine/test/build_today_test.dart` (unit + band-ordering & massing golden cases) and the INV-2 property in `packages/engine/test/vectors/invariants_test.dart` (shared with E04-T11), `package:test` + `package:glados` — pure Dart, **no** `flutter_test`, no widget binding, no fonts, no network. `today` is a constructed `SerialDay` literal (`day(130)`); elapsed and day counts are integer arithmetic; no `DateTime`, no clock. The day is an ordered list of opaque page ids, so cases assert with structural/integer equality (`equals(...)`, `==`), **not** `closeTo` (the float `1e-6` tolerance applies to the curve rows in E04-T03, which this task only *calls*). Written FIRST where they pin a covenant:

- **INV-2 — manzil never dropped (the covenant, test-first)**: a `glados` property over generated `(List<Card>, SerialDay today)` cases asserting that **every** card the post-build `phaseOf` bands as a due Far/manzil page appears in `buildToday(cards, today).items`. The covenant is named in a comment (`// PRD §7.12: FAR/manzil due items are never silently dropped`); no fixed lucky seed; rely on shrinking. A stub that drops a Far page when `cycleSlice` is empty must fail this before the real assembly is written.
- **Sibling massing (test-first, with a fake `confusionSiblings`)**: given a Far page `P` due and a fake lookup mapping `P → {Q}` (a not-yet-due sibling), `expandMutashabihat([P]) == [P, Q]` — `Q` is **adjacent** to `P` (back-to-back), is *added* though not independently due, and is never separated by another page; a three-way group `P → {Q, R}` produces `[P, Q, R]` contiguous; a sibling that is itself independently due is deduplicated (placed once, in group order). A stub that appends siblings at the end of the day (spaced apart) must fail.
- **Recitation order (manzil → near → new)**: a card set with at least one Far, one Near, and one New page produces `items` whose first run is all Far, then all Near, then all New — band order is structural; reversing the input does not change the band order.
- **Weakest-`R`-first within a band, stable**: two Far pages with different `S`/`lastReview` order weakest-`R` first; two with equal `rOf` order by page id (deterministic tiebreak) — running `buildToday` twice yields an identical list (feeds INV-4).
- **Pull-forward**: a Far page **not** in today's `cycleSlice` whose `rOf < retentionFloor` is pulled into FAR; one whose `rOf ≥ retentionFloor` and not in the slice is **not** pulled; a page already in the slice is never duplicated by pull-forward.
- **Pure-cycle mode**: with `pureCycleMode: true`, FAR is exactly `farCycleSliceForToday(...)` (no extra `pullFwd` page, no weakest-`R` reorder) while a non-pure config over the same cards *does* pull forward and reorder — proving the flag toggles SR ordering only; siblings are still massed in both modes.
- **No clock / determinism (feeds INV-4)**: two `buildToday(cards, today)` calls with identical inputs return fingerprint-equal `items`; constructing `today` as a different `SerialDay` literal shifts `rOf` deterministically; grep-level check that `build_today.dart` references no `DateTime`/`Random`.
- **Empty / finished-ḥāfiẓ edges**: an all-Far card set with no active sabaq yields `newToday` empty and a FAR-only day; an empty card set yields an empty `DayPlan`; an empty `confusionSiblings` lookup yields the FAR list unchanged.
- **Purity / offline guard** (complements the E04-T01 banned-import grep gate): `build_today.dart`/`day_plan.dart` import no `dart:io`/`flutter`/`drift` and reference no `DateTime`/`Random`; `buildToday` is deterministic and airplane-mode-safe by construction (an `HttpOverrides`-style no-network assertion is unnecessary — the package links no socket — but the offline guard is the import grep).

(No widget/integration test — `engine/` renders nothing; how the day plan is *displayed* in RTL fa/ckb/ar is E12's `ui-daily-session-list` golden. The INV-4 determinism property and the broader §7.12 suite are E04-T11; this task lands INV-2 and the massing/ordering goldens.)

## Definition of Done

- [ ] All acceptance criteria met; both suites green under `dart test` in the `engine/` package locally and in CI (PRD §20 gates 3 and 4); the test-first INV-2 property and the sibling-massing golden existed and failed against a drop-Far / space-siblings stub before the real assembly was written.
- [ ] **Manzil un-skippable (non-negotiable)**: every due FAR/manzil page `buildToday` bands as Far appears in `DayPlan.items`; no band, sort, or massing step removes a memorized card; INV-2 (`FAR due items always appear in the plan`) holds (PRD §7.9, §7.12; domain-scheduling-engine-rules rule 19).
- [ ] **Mutashābihāt massing, never spacing (non-negotiable)**: `expandMutashabihat` places confusable siblings **adjacent** in the same session; no path spaces them apart or drops a sibling; the sibling pulled in is *additive* contrast (PRD §9.2; domain-scheduling-engine-rules rule 20).
- [ ] **Offline / no-network**: `build_today.dart`/`day_plan.dart` open no socket and link no http/analytics SDK; the `engine/` dependency line stays `meta` (+ `models`) — verifiable by grep (PRD C1; engineering 06 §1).
- [ ] **No AI / no audio / no microphone**: `buildToday` consumes only `Card`s + injected `today` + `EngineConfig` + an injected `confusionSiblings` lookup — no model, optimizer, ASR, or audio anywhere; nothing is *fitted* (PRD C2, R5; engineering 06 §8).
- [ ] **Determinism**: `buildToday`/`expandMutashabihat` and every helper are pure — no `DateTime.now()`, no `Random`, no I/O; `R` is recomputed from the injected `today` by integer subtraction; `sortByWeakestR` is stable with a page-id tiebreak; identical inputs → fingerprint-equal day (the `onReview is pure`/INV-4 determinism contract holds) (PRD §7.12; engineering 06 §1, §7).
- [ ] **Quran text fidelity**: N/A by construction — `buildToday` orders opaque page *ids*, never touches muṣḥaf glyphs, layout, or the mutashābihāt dataset's text, and cannot reflow or re-typeset sacred text; the confusables lookup is injected, not built here. The boundary is stated, not assumed (PRD R1).
- [ ] **RTL + fa/ckb/ar localization**: N/A by construction — `buildToday` emits an ordered list of opaque page ids and no user-facing string; no locale, numeral, or calendar logic leaks into `engine/`; the recitation-order *rendering* (RTL band headers, swappable sabaq/sabqi/manzil labels, locale numerals) lives in E12's `ui-daily-session-list`.
- [ ] **Accessibility**: N/A by construction — `engine/` renders no widget; a11y lives wherever the day plan is displayed (E12).
- [ ] **Sect-neutral adab**: no streak/score/badge/shame surface and no "overdue"/"behind" framing in code or comments; the three bands are a *named tradition* (sabaq/sabqi/manzil) a teacher recognizes, not a verdict the app issues; the day is calm and finite; pure-cycle mode honors ulama who distrust reordering — the engine never presents itself as superseding the teacher or the tradition (PRD R3, R6, §7.8, §7.11; CLAIMS C-034 — methodology, no fiqh ruling).
- [ ] **No unsourced number**: this task renders no number; the banding traces to the already-graded CLAIMS row C-034 (the sabaq/sabqi/manzil three-track tradition) and no citation or CLAIMS id is invented; track-label strings and the science-screen row are E19/the UI layer (domain-claims-register-and-science-screen).
- [ ] Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`); `///` docs on every public API; the massing covenant is restated as a why-comment at `expandMutashabihat`'s splice and the recitation-order intent at the band concatenation; `dart format` and `dart analyze --fatal-infos` clean; no `print`/`debugPrint`; no `!`/`late`/`dynamic` used to dodge non-null honesty (eng-write-to-coding-standards §4, §5, §7).
