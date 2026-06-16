# E02-T02 — Integer day-math primitives: elapsedDays, nextDue, ceiling-add, catch-up window

| | |
|---|---|
| **Epic** | [E02 — Calendar & Date Core](EPIC.md) |
| **Size** | S (≈0.5-1 day) |
| **Depends on** | E02-T01 |
| **Skills** | domain-calendars-and-hifzdate, eng-write-dart-test |

## Goal

The four time-dimensioned scheduling primitives every later engine quantity is built from exist as free functions in the pure-Dart `engine/` package, each expressed purely as `CalendarDate.addDays` / `daysUntil` integer math: `elapsedDays(lastReviewDay, today) = lastReviewDay.daysUntil(today)`, `nextDue(today, intervalDays) = today.addDays(intervalDays)`, a ceiling-add `dueWithCeiling(today, idealDays, ceilingDays) = min` over `epochDay`, and `catchUpWindow(today, spanDays) = [today.addDays(0), … today.addDays(spanDays-1)]`. The engineering/07 §2 engine-quantity table is encoded as a test suite that asserts, row by row, that each quantity equals its integer primitive **and** is byte-identical across a real spring-forward week — proving by construction that no `Duration`, no `DateTime.add`, no `DateTime.difference(...).inDays`, and no month/leap logic sits on any scheduling path.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/07-dates-calendars-and-correctness.md` §2 | The decision that **every** time-dimensioned scheduler quantity (`elapsed_days`, `interval(S,R)`→due, cycle ceiling, `due_at`, catch-up window, peak-smoothing nudges) is integer day arithmetic via `addDays`/`daysUntil`; the engine-quantity table (Engine quantity \| Computed as \| Never) that this task encodes as tests; the `elapsedDays`/`nextDue` reference listings; the refusals — no `Duration(days:n)`, no `DateTime.difference(...).inDays`, no month/leap branch in any scheduling path |
| `docs/engineering/07-dates-calendars-and-correctness.md` §1 | The `CalendarDate` API these primitives stand on (`epochDay`, `addDays`, `daysUntil`, `compareTo`, `isBefore`/`isAfter`) — supplied by E02-T01; this task adds no new method to the value type, only free functions over it |
| `docs/engineering/07-dates-calendars-and-correctness.md` §7 (T1, T2) | The DST-immunity vectors these primitives must satisfy: `CalendarDate.ymd(2026,3,7).addDays(1) == 2026-03-08` (exactly +1 epochDay across the US spring-forward week); `daysUntil` is an exact integer day count across a spring-forward **and** a fall-back boundary, never a 23h/25h artifact |
| `docs/PRD.md` §7.3, §7.6, §7.9 | The quantities being made integer-typed: `elapsed_days` and `interval(S,R)` (§7.3), the cycle ceiling / trust clamp `due = min(SR-ideal, cycle ceiling)` (§7.6), the catch-up re-spread (§7.9) — this task owns only the **day-math shape** of these; the SR/clamp/re-spread *values* are E04 |
| `docs/PRD.md` §7.12, §19.3 | "Identical inputs → identical schedule"; no wall-clock in the engine — the determinism these integer primitives exist to protect |
| Skill `domain-calendars-and-hifzdate` (+ `template.dart` LAYER 1) | Rule 3 (all interval/cycle/ceiling math is integer day arithmetic) and Rules 1–2 (reason in `CalendarDate`, never a `DateTime`); the `elapsedDays`/`nextDue` scaffold in `template.dart`; the Do/Don't row "Add/measure days with `addDays`/`daysUntil` — never `Duration`/`DateTime.add`/`inDays`"; the Checklist line "no `Duration`, `DateTime.add`, `DateTime.difference(...).inDays`, or month/leap logic in any scheduling path" |
| Skill `eng-write-dart-test` (+ `template.dart` engine-unit + property scaffolds) | §2 — test `engine` with `package:test` only (never `flutter_test`, no widget binding); §3 — `today` is a literal `CalendarDate`, no `DateTime.now()` reachable; §8 — the throwing `HttpOverrides` offline guard; §11 — REUSE SPDX header, full-word/unit-bearing names, `dart format` clean; the `glados` property scaffold for the calendar-invariance property |
| `docs/science/CLAIMS.md` | Nothing cited — these are internal arithmetic primitives with no on-screen number, copy, or claim; no CLAIMS id is involved |
| Siblings: E02-T01, E02-T03, E02-T08 | **T01** supplies the `CalendarDate` value type and its `addDays`/`daysUntil` (a hard dependency — this task adds no value-type method). **T03** owns the instant→civil-day edge (`civilDayOf`); the `lastReviewDay` these primitives consume is produced there, not here. **T08** consumes these primitives as the subject of the T1–T5 DST/timezone matrix; this task ships the focused T1/T2 vectors for its four functions, T08 wires the full zone sweep. **E04** consumes all four primitives as the basis of `interval`/clamp/catch-up math |

## Implementation notes

TEST-FIRST (correctness-critical): this is the integer-day spine the whole scheduler stands on; a single `Duration` leak here reintroduces the DST off-by-one the epic exists to remove. Write the engine-quantity-table suite and the T1/T2 vectors below **before** the function bodies — the spring-forward and fall-back vectors must exist and fail before the primitives are implemented.

1. **File**: `engine/lib/src/day_math.dart` (pure Dart, in the `engine/` package boundary from E01). No `import 'package:flutter/...'`, no `import 'dart:io'`, no `hijri`/`shamsi_date`/`intl`, no `DateTime.now()` — the E01 banned-import grep gate enforces this over the whole package. The only `DateTime` anywhere reachable is E02-T01's pure `CalendarDate.ymd` calculator, which these functions call only transitively through `CalendarDate`.
2. **`elapsedDays`** — `int elapsedDays(CalendarDate lastReviewDay, CalendarDate today) => lastReviewDay.daysUntil(today);`. Returns a signed integer day-distance (negative if `today` precedes the last review — the caller, E04, decides clamping; this primitive does not lie about the count). Matches the §2 listing exactly; the table's **Never** column is `DateTime.difference(...).inDays`.
3. **`nextDue`** — `CalendarDate nextDue(CalendarDate today, int intervalDays) => today.addDays(intervalDays);`. The FSRS curve in E04 produces `intervalDays` as an integer; this primitive only turns it into a due **date** by integer addition. The table's **Never** column is `lastReview.add(Duration(days: n))`.
4. **Ceiling-add** — `CalendarDate dueWithCeiling(CalendarDate today, int idealDays, int ceilingDays)` returns `min` over `epochDay` of `today.addDays(idealDays)` and `today.addDays(ceilingDays)` (use `isBefore`/`compareTo`, not a clock comparison). This is the day-math *shape* of the §7.6 trust clamp `due = min(SR-ideal, cycle ceiling)` — **not** the clamp itself: it takes two pre-computed day counts and never computes `S`, `R`, `targetR`, or the cycle ceiling (those are E04 / `domain-scheduling-engine-rules`). Keep it a thin `min`-over-`epochDay` helper so the property "result ≤ ceiling, always" is true by construction here, and the §7.12 INV-1 property over real engine state lives in E04.
5. **Catch-up window** — `List<CalendarDate> catchUpWindow(CalendarDate today, int spanDays)` returns `[for (var i = 0; i < spanDays; i++) today.addDays(i)]` — a sequence of `today.addDays(i)`, exactly the §2 table's "Catch-up window … a sequence of `today.addDays(i)`", **Never** "iterating wall-clock days". `spanDays == 0` yields the empty list; reject a negative `spanDays` with an `assert` / `RangeError` (an impossible scheduling input, not a runtime error path — keep it total for valid inputs). This task ships only the *enumeration* of the window's days; how the backlog is re-spread across them (most-decayed / prayer-critical first) is E04 §7.9 and the catch-up banner is a later UI epic.
6. **Totality & naming**: every function is total for valid inputs (no throw on any in-range value), pure (no I/O, no clock), and named with full-word, unit-bearing identifiers (`intervalDays`, `ceilingDays`, `spanDays` — never `n`/`i` in the public signature). Each carries a `///` doc comment that names the §2 rule and the **Never** form it replaces (intent, not narration). File carries the REUSE `GPL-3.0-or-later` SPDX header.
7. **Pitfalls to avoid**: introducing a `Duration` or `DateTime.add` "just for the offset" (the exact inversion the suite must catch); using `DateTime.difference(...).inDays` for `elapsedDays` (truncates to 0 across a 23h DST midnight pair); a month/leap branch sneaking in for a "monthly" cycle (cycles are day counts — 7/15/30/60 — chosen at the display layer, never a calendar-month computation here); widening a `CalendarDate` back into a local-midnight `DateTime`; reading `DateTime.now()` for `today` instead of taking it as a parameter; comparing due dates by constructing instants instead of `epochDay`.

## Acceptance criteria

- [ ] `engine/lib/src/day_math.dart` exists in the pure-Dart `engine/` package; the package's banned-import grep gate stays green (no Flutter, no `dart:io`, no `hijri`/`shamsi_date`/`intl`, no `DateTime.now()` reachable).
- [ ] `elapsedDays(lastReviewDay, today)` returns `lastReviewDay.daysUntil(today)` — a signed integer — and contains no `DateTime.difference`/`.inDays`.
- [ ] `nextDue(today, intervalDays)` returns `today.addDays(intervalDays)` and contains no `Duration`/`DateTime.add`.
- [ ] `dueWithCeiling(today, idealDays, ceilingDays)` returns the earlier of `today.addDays(idealDays)` and `today.addDays(ceilingDays)` by `epochDay`, and its result is `≤` the ceiling day for every input (true by construction).
- [ ] `catchUpWindow(today, spanDays)` returns exactly `[today, today.addDays(1), … today.addDays(spanDays-1)]`; `spanDays == 0` → empty list; negative `spanDays` is rejected by `assert`/`RangeError`, never silently producing a wrong window.
- [ ] No function reads a clock, opens I/O, or imports a calendar package; `today` and `lastReviewDay` are always parameters.
- [ ] Every public function carries a `///` doc comment naming its §2 rule and the `Never` form it replaces; names are full-word and unit-bearing; the file passes `dart format` and the analyzer with the REUSE SPDX header present.
- [ ] A grep over `engine/lib/src/day_math.dart` finds zero of: `Duration(`, `.add(Duration`, `.difference(`, `.inDays`, `DateTime.now`, `.month ==`/leap branching on a scheduling path.

## Tests

`engine/test/day_math_test.dart` (mirrors the source name), **`package:test` only** — no `flutter_test`, no widget binding (eng-write-dart-test §2). `today`/`lastReviewDay` are literal `CalendarDate.ymd(...)` values; nothing reads a wall clock (§3). The shared throwing-`HttpOverrides` bootstrap is installed so any stray socket is a loud named failure (§8). Runs under `dart test` in the fast CI job, and is re-run by E02-T08 under the `TZ=Asia/Tehran` / `Pacific/Kiritimati` / `UTC` pins. Required cases, written FIRST:

- **Engine-quantity-table coverage (one group per §2 row)** — for each row assert the quantity equals its integer primitive form: `elapsedDays(a, b) == b.epochDay - a.epochDay`; `nextDue(t, k).epochDay == t.epochDay + k`; `dueWithCeiling(t, ideal, ceil)` equals whichever of the two `addDays` results has the smaller `epochDay`; `catchUpWindow(t, n)` equals the explicit list `[t.addDays(0) … t.addDays(n-1)]`. Each group's name cites the row so a red test points at the exact table line.
- **T1 — `addDays` / `nextDue` DST-immune (spring-forward)**: `nextDue(CalendarDate.ymd(2026,3,7), 1) == CalendarDate.ymd(2026,3,8)` and is exactly +1 `epochDay` — proving the US spring-forward night did not eat or add a day.
- **T2 — `elapsedDays` / `daysUntil` exact across DST**: pick two dates straddling a spring-forward boundary and two straddling a fall-back boundary; assert `elapsedDays` returns the exact integer day count (never the 23h/25h `inDays` artifact). Include a same-day pair (`== 0`) and a reversed pair (negative).
- **Ceiling never exceeded**: across a fixed grid of `(idealDays, ceilingDays)` pairs including `ideal < ceil`, `ideal == ceil`, and `ideal > ceil`, assert `dueWithCeiling(t, ideal, ceil).epochDay <= t.addDays(ceil).epochDay` always — the local, by-construction half of §7.12 INV-1 (the property over real engine state is E04).
- **Catch-up window shape**: `catchUpWindow(t, 5)` has length 5, starts at `t`, ends at `t.addDays(4)`, is strictly increasing in `epochDay`, and has consecutive `daysUntil` of exactly 1; `catchUpWindow(t, 0)` is empty; a negative span throws.
- **`glados` calendar-invariance property** (eng-write-dart-test §5 shape): over generated `(CalendarDate, intervalDays)` pairs, `nextDue(t, k).daysUntil(t) == -k` and `elapsedDays(t, t.addDays(k)) == k` for all `k` — pinning that the primitives are exact integer inverses with no DST/zone surface, via shrinking.

No widget/golden/integration tests in this task (pure arithmetic, no UI, no DB). The offline guard is asserted by construction via the throwing `HttpOverrides`; nothing here touches the network.

## Definition of Done

- [ ] All acceptance criteria met; `engine/test/day_math_test.dart` green locally under `dart test` and in the fast CI job; the T1/T2 vectors are re-green under E02-T08's DST/timezone pins (never considered green from a `TZ=UTC`-only run).
- [ ] **Determinism (non-negotiable)**: no function reads `DateTime.now()` or any clock; `today`/`lastReviewDay` are injected parameters; identical inputs yield identical outputs on any runner in any zone ([PRD §7.12, §19.3](../../docs/PRD.md)).
- [ ] **Engine purity / integer-only math**: the file is pure Dart in `engine/`, free of `Duration`, `DateTime.add`, `DateTime.difference(...).inDays`, and any month/leap branch on a scheduling path; the only `DateTime` reachable is E02-T01's pure `ymd` calculator; the banned-import gate is green ([07 §2](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- [ ] **Offline / no-network**: the throwing `HttpOverrides` bootstrap proves no day-math path opens a socket; the no-network CI gate stays green ([PRD C1, §19.3](../../docs/PRD.md)).
- [ ] **No-AI / no-microphone**: this task is pure integer arithmetic — no ML, no recognition, no audio, no microphone anywhere ([PRD C2](../../docs/PRD.md)).
- [ ] **Quran text fidelity untouched**: renders no glyph, imports no muṣḥaf asset; nothing here reaches the immutable text layer ([PRD R1](../../docs/PRD.md)).
- [ ] **RTL + fa/ckb/ar strings**: N/A by construction — these primitives emit opaque integer day counts and `CalendarDate`s only; no user-facing string, numeral, or date label is produced here (locale/numeral rendering is E02-T05/T06) ([07 §4](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- [ ] **Accessibility**: N/A — no UI surface, no `Semantics` label introduced.
- [ ] **Sect-neutral adab / no gamification**: no streak, score, "behind"/"overdue" framing, and nothing that lets a page be computed as "safe to drop" is introduced; the ceiling-add only makes a page *more* frequent, never later than the ceiling ([PRD R3, C6](../../docs/PRD.md)).
- [ ] **Deterministic tests**: `package:test` only, no `flutter_test`/widget binding; literal `CalendarDate` fixtures, no wall clock; float-free integer assertions (exact `==` on `epochDay`/day counts is correct here, not `closeTo`); REUSE SPDX header, full-word unit-bearing names, `dart format` clean ([11-testing §2, §3](../../docs/engineering/07-dates-calendars-and-correctness.md)).

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
