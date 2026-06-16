# E04-T09 — The budget-aware load balancer and graceful missed-day catch-up

| | |
|---|---|
| **Epic** | [E04 — Scheduling Engine](EPIC.md) |
| **Size** | L (≈3-4 days) |
| **Depends on** | E04-T08 |
| **Skills** | domain-scheduling-engine-rules, eng-write-engine-golden-vector |

## Goal

`loadBalance(day, budgetMinutes, today, rOf)` exists in the pure-Dart `engine/` package exactly as engineering 06 §7 specifies, and `buildToday` (E04-T08) returns `loadBalance(...)` as its last step so every day plan is budget-fitted before it leaves the engine. The balancer fits the assembled `manzil → near → new` day into the user's time budget by four ordered rules: (1) FAR/manzil due items are **scheduled unconditionally** — even when they overflow the budget, which surfaces as a calm honest `budgetOverflow` flag on the returned `DayPlan`, never a drop; (2) NEAR is taken by urgency (`targetR − R`, descending), deferring a low-urgency page within its ceiling **only while its predicted R stays above `kHardFloorR` (0.85)** — a page crossing the floor is promoted to mandatory and can no longer slip; (3) NEW is taken only if budget remains *and* yesterday's sabaq is consolidated; (4) bounded `±1–2 day` peak-smoothing nudges above-floor pages within their ceiling to flatten spikes — the deterministic replacement for FSRS interval fuzz, never RNG. A separate pure `catchUp(backlog, gapDays, today, rOf)` re-spreads a missed-day backlog over N days, lowest-R and prayer-critical first — re-spread, never a red shame-pile. The whole thing is pure and deterministic, and it is built behind INV-2 (manzil never dropped) and INV-4 (determinism, fuzz OFF), which are written test-first.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/06-scheduling-engine.md` §7 (building the day) | The verbatim `DayPlan loadBalance(List<Card> day, int budgetMin, SerialDay today, double Function(Card) rOf)` body: step 1 schedules every `phaseOf(c) == Track.far` item and decrements `budget`, then `final overflow = budget < 0`; step 2 sorts Near by `(targetR(b) − rOf(b)).compareTo(targetR(a) − rOf(a))` (urgency descending) and, per page, schedules if it fits, *safe-slips within the ceiling* if `rOf(c) > kHardFloorR`, else promotes-and-schedules; step 3 NEW only if budget remains and yesterday's sabaq is consolidated; step 4 peak-smoothing; returns `DayPlan(items: orderForRecitation(scheduled), budgetOverflow: overflow)`. Plus `const double kHardFloorR = 0.85;` and the four refusals: never drop a manzil item, never dump a backlog, never space mutashābihāt siblings apart, never a guilt/shame surface |
| `docs/engineering/06-scheduling-engine.md` §7 (missed-day catch-up) | "After a gap the balancer re-spreads over N days, lowest-R and prayer-critical first — re-spread, never shame"; the honest overflow banner text the flag drives ("your scope needs ~X min/day; you've set Y" — raise budget / lengthen cycle / pause new sabaq); peak-smoothing is the **deterministic** replacement for interval fuzz (§3), bounded `±1–2 days` within the ceiling, never hidden RNG |
| `docs/engineering/06-scheduling-engine.md` §8 (determinism) | The plan must be a pure function of `(cards, today, config)` — no clock, no `Random`, no I/O; two `buildToday`/`loadBalance` runs over identical inputs are fingerprint-equal (INV-4). Peak-smoothing and catch-up re-spread are deterministic functions of `rOf`/`prayerCritical`/`today`, never RNG; `kHardFloorR` is the named §8 constant, never a `0.85` literal |
| `docs/PRD.md` §7.9 (load balancing & graceful catch-up) | The four-rule `loadBalance` pseudocode this task implements 1:1 — manzil MANDATORY (schedule even on overflow → gentle warning), NEAR by urgency with the *single-day* slip allowed only above the floor, NEW gated on consolidated sabaq, `±1–2 day` peak-smoothing; and the headline catch-up rule: "after a gap the engine does **not** dump a red overdue pile … re-flows the backlog over several days, most-decayed and prayer-critical first … *'You missed 3 days — here is a 5-day catch-up plan that still completes your cycle.'* Re-spread, never shame" |
| `docs/PRD.md` §7.12 (engine invariants) | The two invariants this task makes structurally true: FAR/manzil due items always appear in the built plan (never dropped to fit a budget), and the engine never displays or implies "this page is safe to stop revising" — overflow is honest signal, not a silent cut |
| `docs/science/06-overlearning-and-lifelong-retention.md` §8 (spacing over massing in catch-up) | "When the engine must choose between stacking a page's re-recitations close together or spreading them across days, it spreads them" — peak-smoothing nudges above-floor pages `±1–2 days` within their ceiling to flatten spikes *rather than massing*; the catch-up re-spread is the long-horizon spacing form (Bahrick 1993, **[EXP]**). Anti-pattern this task must never do: resolve a heavy day by massing repetitions when they could be spaced within the ceiling |
| Skill `domain-scheduling-engine-rules` (+ `template.dart`) | Rule 19 (tradition shapes the day; SR only orders + pulls forward; **manzil is un-skippable** — defer Near and reduce New, never drop dhor) · rule 21 (**missed-day catch-up re-spreads, never dumps a pile or shames** — re-flow over N days, lowest-R and prayer-critical first; overflow is a calm honest banner, never a red overdue pile/streak punishment/silent drop; prefer spacing over massing in every quota decision) · rule 5 (interval fuzzing is OFF — declumping is the bounded `loadBalance` peak-smoothing, never hidden RNG). The Do/Don't rows "Schedule manzil mandatory; surface overflow as a calm banner" / "Drop a manzil due item to fit the budget; dump a red overdue pile" and "Seed conservative … converge" — and the cover note: the FSRS curve is a *prior*, the ceiling is the *promise* |
| Skill `eng-write-engine-golden-vector` (+ `template.dart`) | INV-2 as a `glados` property over generated `(Card-set, today)` histories: every due FAR/manzil page appears in `loadBalance`'s output even when the budget is tiny (the budget can only set `budgetOverflow`, never remove a Far item); INV-4 determinism (two runs fingerprint-equal, fuzz OFF); constants by name (`kHardFloorR`, `targetR`, `cycleCeilingDays`); shrinking relied on, no fixed lucky seed. Peak-smoothing rows asserted with integer day counts (`==`), never `closeTo` |
| `docs/science/CLAIMS.md` C-042 | The user-facing copy this balancer's catch-up drives: "Missing one day doesn't undo your progress" → "catch-up re-spreads the backlog calmly, never a red shame-pile" (**[OBS]**, Lally et al. 2010). This task implements the *engine* behind C-042 (the re-spread + the overflow flag); the catch-up **banner** itself and its rendered copy are E12/`ui-catch-up-banner` and the registered row is E19 — invent no new citation, render no number here |
| Siblings: E04-T02, E04-T05, E04-T07, E04-T08, E04-T11, E04-T14 (mutashabihat, downstream) | T02 supplies `Card`, `Track`, `prayerCritical`, `lastReview`, `Card.copyWith`, and the `DayPlan` value type (extend it here with `budgetOverflow`); **T05** supplies `phaseOf(card)` and `targetR(card)` the urgency sort and floor-promotion read; **T07** supplies `cycleCeilingDays(card, config)` that bounds the peak-smoothing/slip — a slip or smooth must never push a page past its ceiling; **T08 (this task's dependency)** assembles the ordered `manzil → near → new` `day` list (with mutashābihāt already massed) and calls `loadBalance(...)` as its final line — this task owns only the budget fit and catch-up, not assembly or sibling-massing; T11 owns the broader §7.12 property suite — this task lands INV-2 and INV-4 plus the balancer/catch-up vectors as its test-first core |

## Implementation notes

TEST-FIRST: dropping a manzil item or dumping a backlog is the exact covenant breach the product exists to prevent, so it is correctness-critical. Write the **INV-2** property (every due FAR page survives `loadBalance` at *any* budget, including 0) and the **catch-up re-spread** cases below **before** the balancer exists, and watch a naive "schedule until budget runs out, then stop" stub fail INV-2 (it would drop the last Far items). Then write the real four-rule body. Determinism (INV-4) is written test-first too — a stub that shuffled with `Random` must fail it.

1. **Files** (in the package scaffolded by E04-T01): `packages/engine/lib/src/load_balance.dart` for `loadBalance` + `catchUp` + the `estMinutes`/`orderForRecitation` helpers, re-exported from the `packages/engine/lib/engine.dart` barrel. `DayPlan` gains a `final bool budgetOverflow;` field — extend the existing `DayPlan` type from E04-T08 (`packages/engine/lib/src/day_plan.dart`) rather than declaring a second one. `buildToday`'s final line (E04-T08, `packages/engine/lib/src/build_today.dart`) is the call site `return loadBalance(day, config.dailyBudgetMinutes, today, rOf);` — if T08 already returns the assembled list unbalanced, this task wires that last line. Every file carries the REUSE SPDX header (`GPL-3.0-or-later`).

2. **`EngineConfig` field** (extend the type from E04-T07): add `final int dailyBudgetMinutes;` — the user's chosen daily time budget (set by E16/`ui-cycle-preset-picker`). It is a plain integer minute count, `///`-documented; not a retention dial, not a clock. The balancer reads it via `buildToday`; `loadBalance` itself takes the budget as a parameter so it stays a pure function of its arguments.

3. **`loadBalance`** (engineering 06 §7, verbatim shape — implement the four rules in order):
   ```dart
   /// Fit the assembled day into the budget: manzil mandatory, Near by urgency above the
   /// floor, New only on spare budget. PRD §7.9 — overflow is an honest signal, never a drop.
   DayPlan loadBalance(
       List<Card> day, int budgetMin, SerialDay today, double Function(Card) rOf) {
     var budget = budgetMin;
     final scheduled = <Card>[];

     // 1. FAR/manzil due items are MANDATORY — scheduled even if they overflow. PRD §7.9
     for (final c in day.where((c) => phaseOf(c) == Track.far)) {
       scheduled.add(c);
       budget -= estMinutes(c);
     }
     final overflow = budget < 0; // surfaced as a calm banner, never a drop. PRD §7.9

     // 2. NEAR by urgency (targetR − R, descending); defer ONLY above the floor.
     final near = day.where((c) => phaseOf(c) == Track.near).toList()
       ..sort((a, b) =>
           (targetR(b) - rOf(b)).compareTo(targetR(a) - rOf(a)));
     for (final c in near) {
       if (estMinutes(c) <= budget) {
         scheduled.add(c);
         budget -= estMinutes(c);
       } else if (rOf(c) > kHardFloorR) {
         // safe slip: defer within the ceiling, ±1 day. PRD §7.9
       } else {
         scheduled.add(c); // crossed the floor → promote, cannot defer.
         budget -= estMinutes(c);
       }
     }

     // 3. NEW only if budget remains AND yesterday's sabaq is consolidated.
     // 4. Peak smoothing: nudge above-floor pages ±1–2 days within their ceiling.
     return DayPlan(
         items: orderForRecitation(scheduled), budgetOverflow: overflow);
   }
   ```
   `phaseOf`/`targetR` are E04-T05; `kHardFloorR` is the E04-T10/§8 named constant. The covenant comments live at the overflow flag and the promote branch. The Far loop has **no budget guard** — that is the point; the budget can only set `overflow`, never gate a Far item.

4. **`kHardFloorR`** — a Near page may slip a day only while its predicted R stays *above* this floor; a page crossing it is promoted to mandatory. Reference it by name (`kHardFloorR`, defined `= 0.85` in the E04-T10 constants file, engineering 06 §8); never inline `0.85`. The comparison is strictly `>` (a page exactly at the floor is promoted, the conservative direction).

5. **NEW gating (rule 3)** — take NEW lines only if `budget > 0` *and* `yesterday's sabaq is consolidated`. "Consolidated" is read from the card/profile signal E04-T05 graduation exposes (e.g. yesterday's sabaq reached its sign-off threshold), passed in as part of the assembled `day` or a small predicate — do **not** read a clock or a DB here. If sabaq is not yet consolidated, NEW is held back (not dropped from existence — it returns tomorrow); this is reduce-New, never drop-manzil. Keep this a pure function of the inputs.

6. **Peak-smoothing (rule 4)** — bounded, deterministic declumping, the explicit replacement for FSRS interval fuzz (rule 5; engineering 06 §3, §7): for an above-floor page (`rOf(c) > kHardFloorR`) sitting on a spike day, nudge its `dueAt` by `±1–2 days` **within `cycleCeilingDays(c, config)`** to flatten the load curve. The nudge is a pure function of the card and `today` (e.g. a deterministic spread by page id / current load), **never** `Random` — INV-4 catches any RNG. A smoothed page can never cross its ceiling (clamp the nudge to `≤ cycleCeilingDays`), and a below-floor or Far page is never smoothed away from today. Prefer spacing over massing (science 06 §8): smoothing spreads, it must never *mass* a page's repetitions into one sitting.

7. **`catchUp`** — the missed-day re-spread, a separate pure function (engineering 06 §7; PRD §7.9; rule 21):
   ```dart
   /// Re-spread a missed-day backlog over N days, most-decayed and prayer-critical first.
   /// PRD §7.9 — re-spread, never a red overdue pile; never shame.
   List<DayPlan> catchUp(
       List<Card> backlog, int spreadDays, SerialDay today, double Function(Card) rOf) { ... }
   ```
   Sort the backlog by *urgency first* — lowest predicted R, with `prayerCritical` pages ahead of equal-R non-critical pages (a stable tie-break, deterministic) — then re-flow across `spreadDays` budget-respecting plans so the cycle still completes. It returns plans, not a single dumped list; the count of days and the per-day budget come from the caller (`spreadDays` chosen so each day fits the budget, e.g. ceil(backlogMinutes / dailyBudget)). It emits **no** "overdue"/"behind"/red state and **no** number itself — the rendered "you missed 3 days, here is a 5-day plan" copy and its numerals are E12/`ui-catch-up-banner` (the engine returns the plans and the day counts as opaque integers). Spacing over massing (science 06 §8): spread the backlog across days rather than cram it into one heavy session.

8. **`DayPlan.budgetOverflow`** is the *only* overflow surface — a boolean signal, not a thrown error, not a dropped page, not a sort to the bottom. When `true`, the day still contains every mandatory manzil item; the UI (E12) reads the flag to show the calm honest banner ("your scope needs ~X min/day; you've set Y" — raise budget / lengthen cycle / pause new sabaq). The engine sets the flag and stops; it computes no banner string and no `X`/`Y` number (those are E12 + registered under C-042 in E19). Keep `DayPlan` immutable with a `const` constructor and value equality (so INV-4 can assert two plans `==`).

9. **Pitfalls to avoid**: a budget guard on the Far loop (would drop a manzil item to "fit" — the exact rule-19 breach INV-2 catches); using `max`/last-resort truncation that silently cuts the tail of the scheduled list; deferring a Near page that is *at or below* the floor (the comparison is strictly `rOf(c) > kHardFloorR`; at the floor → promote); a peak-smoothing or slip nudge that pushes a page *past* `cycleCeilingDays` (clamp it — a slip never breaks the ceiling, T07's covenant); `Random`/`shuffle()`/`DateTime.now()` anywhere in smoothing or catch-up (rule 5; INV-4 fails loudly); massing a page's repetitions into one sitting to clear a heavy day (science 06 §8 anti-pattern — spread within the ceiling); returning a single dumped backlog list or any "overdue"/red/streak-reset state from `catchUp` (rule 21 — re-spread, never shame); the engine computing the banner string or the `X min/day` number (it sets a boolean; copy + numerals are the fa/ckb/ar UI under C-042); inlining `0.85`/`1`/`2` as literals (use `kHardFloorR` and named smoothing bounds); spelling drift on a sacred term in a doc comment (`muṣḥaf`, `juz`, `manzil`, `sabaq`, `mutashābihāt` — one fixed transliteration); reading `phaseOf` inconsistently with T05 (call it, never re-derive the track from `S` here).

## Acceptance criteria

- [ ] `load_balance.dart` exists under `packages/engine/lib/src/` with `loadBalance(List<Card>, int, SerialDay, double Function(Card)) → DayPlan` and `catchUp(List<Card>, int, SerialDay, double Function(Card)) → List<DayPlan>`, re-exported from the `engine.dart` barrel; each carries the REUSE SPDX header.
- [ ] **FAR/manzil is mandatory**: the Far loop has no budget guard — every `phaseOf(c) == Track.far` item in `day` is in the returned `DayPlan.items` for *any* budget, including `0` and negative; an overflowing manzil sets `budgetOverflow == true` and drops nothing.
- [ ] **NEAR by urgency above the floor**: Near is sorted by `targetR − R` descending; a Near page that does not fit is deferred **only when `rOf(c) > kHardFloorR`**; a page with `rOf(c) ≤ kHardFloorR` is promoted-and-scheduled even over budget; `kHardFloorR` is referenced by name, never inlined as `0.85`.
- [ ] **NEW gated**: NEW items are taken only when budget remains *and* yesterday's sabaq is consolidated; otherwise New is held (returns next day), never manzil/Near is cut to make room for New.
- [ ] **Peak-smoothing is bounded and deterministic**: above-floor pages are nudged `±1–2 days` *within* `cycleCeilingDays(c, config)` (never past the ceiling), as a pure function of the card and `today` — no `Random`, no `shuffle`, no clock; a below-floor or Far page is not smoothed away from today.
- [ ] **`budgetOverflow`** is a boolean on the immutable `DayPlan` (value equality, `const` constructor); it is the only overflow surface; the engine computes no banner string and no `X`/`Y` minute number.
- [ ] **`catchUp` re-spreads, never dumps**: returns `List<DayPlan>` over `spreadDays`, sorted lowest-R and `prayerCritical`-first (deterministic, stable tie-break), each plan budget-respecting and still completing the cycle; it emits no "overdue"/red/streak state and no number.
- [ ] The `engine/` dependency line stays `meta` (+ `models`) — no `drift`, `flutter`, `dart:io`, `DateTime`, `Random`, or runtime `fsrs` — verifiable by grep and the E04-T01 purity gate; every public declaration has a `///` doc; `dart format` and `dart analyze --fatal-infos` are clean.

## Tests

`packages/engine/test/load_balance_test.dart` (balancer + catch-up unit + peak-smoothing vectors) and the INV-2/INV-4 properties in `packages/engine/test/vectors/invariants_test.dart` (shared with E04-T11), `package:test` + `package:glados` — pure Dart, no `flutter_test`, no widget binding, no fonts, no network. `today` is a constructed `SerialDay` literal (`day(130)`); `rOf` is a deterministic test stub (or the real `retrievability`); day counts are integer arithmetic; no `DateTime`, no clock. Written FIRST where they pin the covenant:

- **INV-2 — manzil never dropped (the covenant, test-first)**: a `glados` property over generated `(Card-set, today)` histories asserting every due FAR/manzil page appears in `loadBalance(day, budget, today, rOf).items` for **every** generated budget, including `0` and negative. The covenant is named in a comment (`// PRD §7.9/§7.12: manzil is un-skippable; overflow is signal, never a drop`); no fixed lucky seed; rely on shrinking. A "stop scheduling when budget runs out" stub must fail this before the real body is written.
- **INV-4 — determinism, fuzz OFF (test-first)**: a `glados` property asserting two `loadBalance` (and two `catchUp`) runs over identical inputs are value-equal — peak-smoothing and catch-up re-spread are deterministic. A stub that `shuffle`d or smoothed with `Random` must fail this before the deterministic body is written.
- **Overflow sets the flag, drops nothing**: a day whose mandatory manzil alone exceeds the budget returns `budgetOverflow == true` *and* every Far item present; a day that fits returns `budgetOverflow == false`. Two explicit cases with hand-sized `estMinutes`.
- **Near urgency ordering**: with two Near pages, the lower-R (higher `targetR − R`) page is scheduled first; given a budget that fits only one, the more-urgent page is the one taken.
- **Floor promotion vs safe slip**: a Near page that does not fit but has `rOf > kHardFloorR` is deferred (absent from today's items); an identical page with `rOf ≤ kHardFloorR` is promoted-and-scheduled even over budget. The boundary case `rOf == kHardFloorR` is promoted (strict `>`).
- **NEW gating**: with spare budget but yesterday's sabaq *not* consolidated, no NEW item is scheduled; with spare budget and sabaq consolidated, NEW is taken; in neither case is a manzil/Near item cut for New.
- **Peak-smoothing bounded by the ceiling**: an above-floor page on a spike day is nudged `±1–2 days` and its smoothed `dueAt − today ≤ cycleCeilingDays(c, config)` always (asserted with `==`/`<=` on integer day counts); a below-floor page is not smoothed away from today; running twice yields the identical nudge (no RNG).
- **Catch-up re-spread**: a backlog of N pages over a gap returns `spreadDays` plans, each within budget; ordering is lowest-R then `prayerCritical`-first (a prayer-critical page at equal R precedes a non-critical one); the union of all plans' items equals the backlog (nothing dropped, nothing dumped into one day); no plan carries an "overdue"/red flag and `catchUp` emits no number.
- **Spacing over massing**: a backlog that *could* be massed into one heavy day is instead spread across days within the ceiling (no single returned plan exceeds the budget when a re-spread is possible) — science 06 §8 anti-pattern guarded.
- **Purity / offline guard** (complements the E04-T01 banned-import grep gate): `load_balance.dart` imports no `dart:io`/`flutter`/`drift` and references no `DateTime`/`Random`/`shuffle` — `loadBalance`/`catchUp` are deterministic and airplane-mode-safe by construction.

(No widget/integration test — `engine/` renders nothing; the catch-up *banner* and the budget-feedback copy are E12/`ui-catch-up-banner`. Day counts and budgets are integers, so they assert with `==`/`<=`, not `closeTo`; the float `closeTo(_, 1e-6)` tolerance applies only to the `rOf`/curve rows owned by E04-T03, which this task calls.)

## Definition of Done

- [ ] All acceptance criteria met; both suites green under `dart test` in the `engine/` package locally and in CI (PRD §20 gates 3 and 4); the test-first INV-2 property existed and failed against a "stop at budget" stub, and INV-4 against a `Random`/`shuffle` stub, before the real body was written.
- [ ] **Manzil un-skippable (non-negotiable)**: FAR/manzil due items always appear in `loadBalance`'s output; overflow surfaces as the calm `budgetOverflow` signal, never a drop, never a red shame-pile; `catchUp` re-spreads the backlog (lowest-R + prayer-critical first), never dumps a pile or emits an "overdue"/streak-reset state; INV-2 holds (PRD §7.9, §7.12; engineering 06 §7; CLAIMS C-042; domain-scheduling-engine-rules rules 19, 21).
- [ ] **No "safe to drop"**: no code path removes, retires, or de-prioritizes a memorized page to fit a budget; the budget can only set a boolean flag and defer an *above-floor* Near page within its ceiling — never past it, never below the floor (PRD §7.12; T07's clamp covenant).
- [ ] **Offline / no-network**: `load_balance.dart` opens no socket and links no http/analytics SDK; the `engine/` dependency line stays `meta` (+ `models`) — verifiable by grep (PRD C1; engineering 06 §1).
- [ ] **No AI / no audio / no microphone**: the balancer consumes only the assembled `day`, the budget, injected `today`, `rOf`, and `EngineConfig` constants — no model, optimizer, ASR, or audio anywhere; the FSRS weights are *used*, never *fitted* (PRD C2, R5; engineering 06 §8).
- [ ] **Determinism**: `loadBalance`/`catchUp`/peak-smoothing are pure — no `DateTime.now()`, no `Random`, no `shuffle`, no I/O; `today` is a `SerialDay` and all day math is integer arithmetic; identical inputs → byte-identical `DayPlan` (INV-4 holds; the `onReview is pure` sibling property is unaffected) (PRD §7.12; engineering 06 §1, §7, §8).
- [ ] **Quran text fidelity**: N/A by construction — this task orders and budgets page *ids*, never touches muṣḥaf glyphs or layout and cannot reflow or re-typeset sacred text; mutashābihāt sibling-massing is E04-T08's, not changed here. The boundary is stated, not assumed (PRD R1).
- [ ] **RTL + fa/ckb/ar localization**: N/A by construction — `loadBalance`/`catchUp` emit an opaque `DayPlan`/`List<DayPlan>` of page ids, a boolean flag, and integer day counts, and no user-facing string; the catch-up banner copy, the budget-feedback line, and all numerals live in the fa/ckb/ar UI (E12/`ui-catch-up-banner`/`ui-numerals-calendar-text`); no locale, numeral, or calendar logic leaks into `engine/`.
- [ ] **Accessibility**: N/A by construction — `engine/` renders no widget; a11y lives wherever the day plan and catch-up banner are displayed (E12/E15).
- [ ] **Sect-neutral adab**: no streak/score/badge/shame surface, no red overdue pile, no "you're behind" framing; a missed gap is met with a calm re-spread plan, an over-budget scope with an honest "raise budget / lengthen cycle / pause new sabaq" signal — help, never blame; nothing implies a madhhab/sect ruling (PRD R3, C6, §12.2; CLAIMS C-042, C-043).
- [ ] **No unsourced number**: this task renders no number; the catch-up + overflow behaviour traces to already-graded CLAIMS C-042 ("missing one day doesn't undo your progress", [OBS]), and the rendered copy/numerals are registered and shown by E19/E12 — no citation or CLAIMS id is invented (domain-claims-register-and-science-screen).
- [ ] Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`); `///` docs on every public API; the covenant is restated as a why-comment at the overflow flag, the promote branch, and the catch-up sort; `dart format` and `dart analyze --fatal-infos` clean; no `print`/`debugPrint`; no `!`/`late`/`dynamic` used to dodge the non-null `dueAt`/`DayPlan` honesty (eng-write-to-coding-standards §4, §5, §7).
