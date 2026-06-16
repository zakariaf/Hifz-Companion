---
name: domain-scheduling-engine-rules
description: Govern any change to the Hifz Companion DSR scheduling engine so revision stays pure, deterministic, and never tells a ḥāfiẓ a page is "safe to drop." Use whenever adding, changing, or reviewing the page card, FSRS Difficulty/Stability/Retrievability math, the sabaq/sabqi/manzil tracks, phase graduation, stakes-tiered retention, cold start, the load balancer, the TRUST CLAMP (`due = min(SR-ideal, cycle ceiling)`), or any engine golden test vector.
---

# Hifz scheduling-engine rules

The `engine/` package is the heart of the product and its one covenant in code: *nothing the user has memorized ever decays silently.* It dresses an FSRS-style DSR scheduler in the traditional sabaq / sabqi / manzil workflow, schedules one card per muṣḥaf page, and — above every line of math — clamps each page's next-due date to the user's chosen cycle ceiling so the algorithm may only ever pull a page **forward**, never let it drift past the cycle, and never marks a memorized page "done." This skill is the checklist that keeps it pure, deterministic, sect-neutral, and honest.

## When to use

Use this skill when you:

- add or change any logic inside the pure-Dart `engine/` package — `onReview(...)`, `coldStartCard(...)`, `buildToday(...)`, the curve/interval, the S/D update branches, phase/graduation, the load balancer, or the trust clamp;
- touch the FSRS curve constants (`kDecay`, `kFactor`), the weight vector, a retention target, a track threshold (`kNearMinS`, `kFarMinS`), or a cold-start seed;
- change the `Card` value type or any field the schedule depends on (`d`, `s`, `track`, `dueAt`, `weakFlag`, `prayerCritical`, `manualLock`, `signoffs`);
- add or edit a golden test vector or a `glados` property test for any §7.12 invariant;
- review a PR that touches scheduling math, track/phase transitions, or any engine output.

Do **NOT** use this skill for:
- how a stored "due date" *means* a calendar day, serial-day arithmetic, or Hijri/Jalālī/Gregorian conversion → use **eng-datemath-and-serialday**;
- persisting cards / the `review_log` / one-transaction writes → use **eng-persistence-and-drift**;
- the immutable muṣḥaf glyph rendering and the mutashābihāt dataset that seeds interference links → use **eng-quran-data-and-immutable-rendering**;
- how the day plan, retention heat-map, or catch-up banner is *displayed* → use **ui-today-revision-list**, **ui-retention-heatmap**, **ui-catchup-banner**;
- the reveal-on-tap recite flow that normalizes `(grade, errorLines, source)` before it reaches the engine → use **ui-recite-and-grade-flow**;
- registering a user-facing number on the science screen → use **domain-claims-register-and-science-screen**.

The engine owns the arithmetic and the policy on top of it, nothing else. If your change reads a clock, opens a database, or renders a widget, it does not belong in `engine/`.

## The canonical pattern

The full spec is `docs/engineering/06-scheduling-engine.md`. Reference each rule by its doc section — never re-derive a constant or invent a number here.

### Shape and purity

1. **One stateless façade, pure functions only.** `SchedulingEngine(config)` exposes `onReview`, `coldStartCard`, `buildToday` — each a pure function of its arguments and the injected `today`. `docs/engineering/06-scheduling-engine.md` §1 (vendored FSRS arithmetic, one stateless façade).
2. **`engine/` is pure Dart, zero I/O.** No `import 'package:flutter'`, no `DateTime.now()`, no `Random`, no database, no network. `today` is always injected as a `SerialDay`; "elapsed days" is plain integer subtraction (`today.value − card.lastReview.value`), immune to the DST `+1 day ≠ +24h` bug. `docs/engineering/06-scheduling-engine.md` §1 and §8 (determinism; CI banned-import grep gate).
3. **Vendor the arithmetic, never depend on `fsrs`/dart-fsrs at runtime.** We reimplement the ~30 lines of FSRS-4.5 math in `engine/` and read dart-fsrs only as a cross-check oracle in tests. `docs/engineering/06-scheduling-engine.md` §1 (Pitfalls — we refuse a runtime dependency); `docs/science/03-spaced-repetition-algorithms.md` §5 (FSRS chosen because it is the only model that is both two-component *and* open, local, auditable).

### The curve and the interval (`06-scheduling-engine.md` §3)

4. **The curve constants live in exactly one place, and `kFactor` is computed from `kDecay`.** `kDecay = -0.5`; `kFactor = pow(0.9, 1/kDecay) - 1` (= 19/81), defined so `R(S,S) = 0.9`. `0.2346` never appears as a literal — that is what makes the FSRS-6 upgrade a one-line `kDecay = -w[20]` change. `docs/engineering/06-scheduling-engine.md` §3 / §8; `docs/science/03-spaced-repetition-algorithms.md` §5.
5. **The interval is the closed-form inverse, never fuzzed.** `interval(s, targetR) = (s/kFactor)·(targetR^(1/kDecay) − 1)`, clamped `[1, kMaxInterval]`. `I(S, 0.9) = S` exactly. Interval fuzzing is **OFF** — random fuzz breaks the §7.12 "identical inputs → identical schedule" invariant; any declumping happens in our own bounded `loadBalance` peak-smoothing, never via hidden RNG. `docs/engineering/06-scheduling-engine.md` §3 (Pitfalls — we refuse interval fuzzing).

### The review update (`06-scheduling-engine.md` §4)

6. **One deterministic update path with a sacred-text guard.** `onReview` runs the FSRS difficulty + stability update, then in order: the sacred-text guard, source-confidence scaling, the lapse/success split, the weak-line difficulty channel, and the trust clamp. `docs/engineering/06-scheduling-engine.md` §4; `docs/PRD.md` §7.7.
7. **A missed or altered sacred word is NEVER "Good".** If `rv.missedOrAlteredWord`, cap the grade at `Grade.hard` before any math. This is non-negotiable R1 in code. `docs/engineering/06-scheduling-engine.md` §4; `docs/PRD.md` §7.7, §8.3.
8. **A lapse demotes; it never grows stability.** `postLapseStability` is clamped `≤ S`; a forgotten page never earns a longer interval than it had. `docs/engineering/06-scheduling-engine.md` §4; `docs/science/03-spaced-repetition-algorithms.md` §4 (a lapse genuinely sets S back and naturally demotes the phase).
9. **Self-rating is noisy, so it moves state less.** `Source.self_` scales the *applied stability gain* by `kSelfConfidence` (≈ 0.5); `Source.teacher` is 1.0 — the *sanad*-respecting ground truth that always supersedes the math. Self-rating alone cannot reach the top prayer-critical retention tier. `docs/engineering/06-scheduling-engine.md` §4; `docs/PRD.md` §8.1, §8.2.
10. **Interference rides the `(11−D)` factor, never a parallel scheduler.** A mutashābihāt-confused or chronically-weak page bumps `D`; the FSRS stability equation turns higher `D` into a shorter interval automatically. `errorLines` and confusion-edge updates apply at *full strength regardless of source*; only the magnitude of the S move is confidence-scaled. `docs/engineering/06-scheduling-engine.md` §4; `docs/science/03-spaced-repetition-algorithms.md` §8.

### Tracks, graduation, retention, cold start (`06-scheduling-engine.md` §5)

11. **Three tracks are three phases of ONE card, derived from `S` — not three algorithms.** `phaseOf(card)`: `S < kNearMinS` → New, `< kFarMinS` → Near, else Far; `manualLock` (teacher pin) wins over the math. One card, one update path, one source of truth. `docs/engineering/06-scheduling-engine.md` §5; `docs/PRD.md` §7.4.
12. **Graduation is predictable and sign-off gated, never a hidden jump.** New → Near needs *N* sign-offs; Near → Far needs crossing `kFarMinS` *and* leaving the recent-juz window; a lapse shrinks `S` and naturally demotes. A teacher can anticipate every transition. `docs/engineering/06-scheduling-engine.md` §5; `docs/PRD.md` §7.4.
13. **Retention is stakes-tiered, never a global 0.99.** New 0.90 → Near 0.94 → Far 0.95 ordinary, **0.97+ for prayer-critical / weak / previously-lapsed** pages. A global 0.99 is ~11× the 0.90 workload across 604 pages — infeasible; near-100% comes from the §6 clamp, not the probability target. `docs/engineering/06-scheduling-engine.md` §5; `docs/science/06-overlearning-and-lifelong-retention.md` §7.
14. **Graduate on fluency (Easy), not bare correctness.** `Easy` is the automaticity signal that warrants a longer interval; a correct-but-effortful `Hard` is *not yet automatic* and must not lengthen the interval or promote the page. `docs/science/06-overlearning-and-lifelong-retention.md` §4; `docs/PRD.md` §6.3, §7.4.
15. **Cold start seeds conservative, under-estimated priors — no calibration grind.** Solid → (D 3, S 60) / Shaky → (D 5, S 14) / Rusty → (D 7, S 4); optional stale-time decay ages `S` from a known memorization date; every held page is `dueAt = today` so the first weeks review each once. Priors deliberately under-estimate so the first recitation can only surprise upward, and successive relearning dominates the seed within ~2–3 weeks. `docs/engineering/06-scheduling-engine.md` §5; `docs/science/06-overlearning-and-lifelong-retention.md` §3; `docs/PRD.md` §7.10.

### The trust clamp — the whole engine in one rule (`06-scheduling-engine.md` §6)

16. **`due_at = min(ideal_due, ceiling_due)` — the earlier date, always.** `trustClamp` takes the SR-ideal interval and clamps it to `cycleCeilingDays(card, config)`. The algorithm's only freedom is to pull a page **forward**. This is the README's second outranking rule, the most-tested line in the engine. `docs/engineering/06-scheduling-engine.md` §6; `docs/PRD.md` §7.6.
17. **`cycleCeilingDays` is a pure function of card + config — and pure-cycle mode is a one-flag change.** No clock, no profile lookup, no I/O. `config.pureCycleMode` runs fixed rotation only (SR ordering off, zero pull-forward) so the app degrades gracefully to a faithful traditional tracker for ulama who distrust reordering. `docs/engineering/06-scheduling-engine.md` §6; `docs/PRD.md` §7.11; `docs/science/03-spaced-repetition-algorithms.md` §7.
18. **Never `max` where `min` belongs; never exempt a page from the ceiling; never "safe to drop."** A memorized page (`track != unmemorized`) without a non-null `dueAt ≤ ceiling` is unrepresentable — asserted at construction. No code path lengthens a ceiling to infinity, retires a page, or surfaces such a suggestion. `docs/engineering/06-scheduling-engine.md` §6; `docs/PRD.md` §7.12; `docs/science/06-overlearning-and-lifelong-retention.md` §6 (the permastore plateau still slopes — keep a non-null due date forever).

### Building the day (`06-scheduling-engine.md` §7)

19. **Tradition shapes the day; SR only orders and pulls forward; manzil is un-skippable.** Recitation order is manzil → near → new (old before new). FAR/manzil due items are MANDATORY — the balancer may defer Near and reduce New, but never drops dhor. `docs/engineering/06-scheduling-engine.md` §7; `docs/PRD.md` §7.8, §7.9.
20. **Interference is cured by massing, not spacing.** `expandMutashabihat` pulls confusable siblings into the *same* session back-to-back — the one place the engine *adds* a not-yet-due card; it is additive contrast, never a dropped review. Never space siblings apart. `docs/engineering/06-scheduling-engine.md` §7; `docs/PRD.md` §9.2.
21. **Missed-day catch-up re-spreads; it never dumps a pile or shames.** After a gap, re-flow the backlog over N days, lowest-R and prayer-critical first; an overflow is a calm honest banner ("your scope needs ~X min/day; you've set Y"), never a red overdue pile, streak punishment, or silent drop. Prefer spacing over massing in every quota decision. `docs/engineering/06-scheduling-engine.md` §7; `docs/science/06-overlearning-and-lifelong-retention.md` §8; `docs/PRD.md` §7.9, §12.2.

### Determinism, weights, golden vectors (`06-scheduling-engine.md` §8)

22. **Weights are data with a length assert; defaults documented as flashcard averages.** `assert(weights.length == kFsrsWeightCount)` at construction (19 for FSRS-4.5/5, 21 for FSRS-6); a 19-vs-21 mismatch must fail loudly, not silently mis-schedule. The shipped vector is a flashcard population average, never a hifz-fitted set, and we never ship the optimizer (no telemetry, nothing to train on). `docs/engineering/06-scheduling-engine.md` §8; `docs/science/03-spaced-repetition-algorithms.md` §5, §6.
23. **Pin every change with anchor golden vectors + `glados` invariants, from an independent oracle.** Anchor vectors come from the FSRS definition (curve/interval identities) and dart-fsrs run with `enableFuzzing: false` — never from the engine under test, so a fixture cannot agree with a bug. `docs/engineering/06-scheduling-engine.md` §8; harness via **eng-write-dart-test**.

## Do / Don't

| Do | Don't |
|---|---|
| Inject `today` as a `SerialDay`; compute elapsed by integer subtraction | `DateTime.now()`, `Random`, any clock or RNG in `engine/` |
| Keep `kDecay`/`kFactor` in one place; compute `kFactor` from `kDecay` | Inline `0.2346` / `19/81` as a literal, or fuzz the interval |
| Cap grade at `Hard` when `missedOrAlteredWord` (sacred-text guard, R1) | Let a dropped/altered word produce a Good/Easy outcome |
| Clamp `postLapseStability ≤ s`; scale self-rating gain by `kSelfConfidence` | Grow S on a lapse; let self-rating alone reach the top retention tier |
| Bump `D` for weak/confusable pages and let `(11−D)` shorten the interval | Build a parallel mutashābihāt or sabaq/sabqi/manzil scheduler |
| Derive phase from `S`; gate graduation on sign-offs + window (predictable) | Hide a graduation jump; run three separate track algorithms |
| Tier retention by stakes (0.90→0.97+); reserve high R for mature pages | Chase a global 0.99; expose any "retention %" slider |
| Graduate on `Easy`/fluency; treat `Hard` as not-yet-automatic | Lengthen an interval on a correct-but-effortful recitation |
| `due_at = min(ideal_due, ceiling_due)` — the earlier date, always | `max(...)`; exempt any page from its ceiling; mark a page "safe to drop" |
| Keep `dueAt` non-null for every memorized card (assert at construction) | Allow a nullable/infinite `dueAt` on a `track != unmemorized` card |
| Schedule manzil mandatory; surface overflow as a calm banner | Drop a manzil due item to fit the budget; dump a red overdue pile |
| Pull mutashābihāt siblings into the same session (massed contrast) | Space confusable siblings apart |
| Seed conservative under-estimated cold-start priors; converge on real grades | Build a calibration grind; over-estimate priors and skip a lost page |
| Assert `weights.length == kFsrsWeightCount`; pin vectors from dart-fsrs | Inline the weight vector; generate fixtures from the engine under test |

## Checklist

Before a scheduling-engine change is done:

- [ ] `engine/` still imports no Flutter, opens no DB, and contains no `DateTime.now()` / `Random` — `today` is injected as a `SerialDay`, elapsed-days is integer subtraction (§1, §8; banned-import grep gate via **eng-add-ci-check**).
- [ ] `onReview`, `coldStartCard`, `buildToday` remain pure functions: identical inputs → byte-identical output (§8; the `onReview is pure` `glados` property still holds).
- [ ] `kDecay`/`kFactor` live in one place, `kFactor` is computed from `kDecay`, and `0.2346`/`19/81` appears as no literal anywhere (§3, §8).
- [ ] The interval is the closed-form inverse, clamped `[1, kMaxInterval]`, with **no** fuzzing; any declumping is bounded `loadBalance` peak-smoothing (§3, §7).
- [ ] The sacred-text guard caps the grade at `Hard` whenever `missedOrAlteredWord` — verified by the `dropped word is never Good` property (§4, R1; `docs/PRD.md` §7.7).
- [ ] `postLapseStability` is clamped `≤ s` (the `Again shrinks S` property holds); self-rating gain is scaled by `kSelfConfidence` and cannot alone reach the prayer-critical tier (§4; `docs/PRD.md` §8.1).
- [ ] Phase is derived from `S` (`kNearMinS`/`kFarMinS`), `manualLock` wins, graduation is sign-off + window gated and predictable (§5; `docs/PRD.md` §7.4).
- [ ] Retention is stakes-tiered via `targetR(card)` (0.90 / 0.94 / 0.95 / 0.97+), never a global 0.99, never a user-facing slider (§5; `docs/science/06-overlearning-and-lifelong-retention.md` §7).
- [ ] Graduation is gated on fluency (`Easy`), not bare correctness (§5; `docs/science/06-overlearning-and-lifelong-retention.md` §4).
- [ ] Cold-start seeds are the conservative `_coldStartSeed` table, every held page `dueAt = today`, priors under-estimate strength (§5; `docs/PRD.md` §7.10).
- [ ] `trustClamp` returns the **earlier** of `idealDue`/`ceilingDue`; `cycleCeilingDays` is pure; `pureCycleMode` is a one-flag fixed rotation (§6; `docs/PRD.md` §7.6, §7.11) — verified by the `due_at never exceeds the cycle ceiling` property.
- [ ] No memorized card has a null/infinite `dueAt`; no code path retires a page or implies "safe to drop"; the heat-map keeps the slow slope visible (§6; `docs/PRD.md` §7.12; `docs/science/06-overlearning-and-lifelong-retention.md` §6).
- [ ] `buildToday` orders manzil → near → new; FAR/manzil due items always appear (the `FAR due items always appear in the plan` property holds); overflow is a calm banner, never a drop (§7; `docs/PRD.md` §7.9).
- [ ] `expandMutashabihat` masses confusable siblings into one session; siblings are never spaced apart (§7; `docs/PRD.md` §9.2).
- [ ] `assert(weights.length == kFsrsWeightCount)` is present; the shipped weights are commented as flashcard-average priors, not hifz-fitted (§8).
- [ ] Anchor golden vectors + `glados` invariants are added/updated from the FSRS definition and dart-fsrs (`enableFuzzing: false`), never from the engine under test (§8; harness via **eng-write-dart-test**).
- [ ] No user-facing number the change introduces is unsourced — it is already a graded row in `docs/science/CLAIMS.md`; if not, stop and use **domain-claims-register-and-science-screen** (never invent a citation or CLAIMS id).
- [ ] RTL/i18n unaffected: the engine emits opaque page ids and day counts only — no locale, numeral, or calendar logic leaks into `engine/` (those belong to **eng-datemath-and-serialday** and the fa/ckb/ar UI layer).
- [ ] Adab/neutrality preserved: no streak, score, badge, or shame surface is introduced; nothing implies a madhhab/sect ruling; the change works fully offline with no network call.

The trust clamp is the covenant: the FSRS curve is a *prior*, the cycle ceiling is the *promise*. If a change makes the math the guarantee instead of the clamp, it is wrong no matter how accurate the math is.

## Files

- `template.dart` — copy-paste scaffold for a typical engine edit: a pure `onReview`/`trustClamp` change, a cold-start seed, and the golden-vector + `glados` invariant test, with `// TODO` markers and every constant referenced by name.
- `references.md` — the exact governing doc sections, each with the one thing to take from it, and the sibling skills.

Related skills: **eng-datemath-and-serialday** (the `SerialDay` value type and day arithmetic the engine consumes), **eng-persistence-and-drift** (the one-transaction write that persists the engine's output), **eng-quran-data-and-immutable-rendering** (the 604-page corpus + the mutashābihāt dataset), **domain-claims-register-and-science-screen** (register any user-facing number before the engine emits it), **ui-recite-and-grade-flow** (normalizes `(grade, errorLines, source)` before the engine), **ui-today-revision-list** / **ui-retention-heatmap** / **ui-catchup-banner** (the surfaces that render the day plan), **eng-write-dart-test** (the golden-vector + property-test harness), **eng-add-ci-check** (the banned-import grep gate).
