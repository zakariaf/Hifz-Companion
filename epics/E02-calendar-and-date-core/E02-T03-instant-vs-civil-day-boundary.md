# E02-T03 — Instant-vs-civil-day boundary: civilDayOf with single .toLocal() conversion

| | |
|---|---|
| **Epic** | [E02 — Calendar & Date Core](EPIC.md) |
| **Size** | S (≈half a day) |
| **Depends on** | E02-T01 |
| **Skills** | domain-calendars-and-hifzdate, eng-write-dart-test |

## Goal

`civilDayOf(instant)` exists as a pure, dependency-free app-edge helper that converts a review's UTC `DateTime` instant into the engine's civil `CalendarDate` **exactly once**, via `.toLocal()`, so "I revised this tonight" means tonight's *local* date and never tomorrow's UTC date. It is the single boundary where a real event moment becomes the civil day the engine measures from; after it, the engine sees only `CalendarDate`s. The function is total (never throws), reads no clock of its own (it converts a passed-in instant), and is pinned by a `package:test` unit suite whose load-bearing vector is a 23:00-local review in a positive-UTC-offset zone landing on the local date — T10 of the §7 matrix. This task adds the conversion helper and its tests only; it does not persist the instant, does not inject "today", and does not render anything.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/07-dates-calendars-and-correctness.md` §3 (instant vs civil day) | The authority: event **instants** (`review_log.reviewed_at`, `card.last_review_at`) are UTC `DateTime`, append-only, **never recomputed or normalized**; **scheduling days** (`due_at`, ceiling, `last_review_day`, "today") are the `CalendarDate` `epochDay` integer. The `civilDayOf` conversion happens **once** at the boundary where a completed review is handed to the engine, using the user's *local* civil day; after it the engine sees only `CalendarDate`s, while the instant stays UTC in `review_log` for the audit trail. The refusal: never store a scheduling day as a local-midnight `DateTime`; never derive the civil day from a UTC `(y,m,d)` |
| `docs/engineering/07-dates-calendars-and-correctness.md` §5 (Pitfalls) | The single-clock-read rule this helper participates in: `.toLocal()` is read once at the edge; the engine never reads a clock. `civilDayOf` converts an instant it is *given* (it is not the clock read itself — that is `todayFor`, E02-T04); both use `.toLocal()` exactly once |
| `docs/engineering/07-dates-calendars-and-correctness.md` §7, T10 | The one vector this task pins test-first: a **23:00-local review in a positive-UTC-offset zone** has civil day = the *local* date, not UTC's already-rolled-over next date. The independent-oracle / never-green-only-under-`TZ=UTC` discipline applies |
| Skill `domain-calendars-and-hifzdate` rules 4–5 (+ `template.dart` LAYER 2) | Rule 4: an instant and a civil day are different facts, stored differently. Rule 5: convert instant → civil day **once**, at the app edge, in local time, via `.toLocal()`; the verbatim `civilDayOf(DateTime instant)` scaffold (`instant.toLocal()` → `CalendarDate.ymd(local.year, local.month, local.day)`); `review_log` instants are never recomputed. The Checklist rows on §3 are the acceptance bar |
| Skill `eng-write-dart-test` §2, §3, §8, §11 | Engine-side tests use `package:test` (never `flutter_test`), need no widget binding, and construct every `DateTime`/`CalendarDate` as a literal — no wall clock; the shared throwing-`HttpOverrides` offline guard (E01-T06) stays installed; full-word/unit-bearing names, typed `catch`, the REUSE SPDX header on the test file. T10 is asserted by construction with explicit UTC instants, not by reading the host clock |
| `docs/PRD.md` §10.3, §19.3 | "All timestamps stored UTC; displayed in the locale's calendar/numerals" governs the *instant*; "today is injected", "no wall-clock in the engine" govern the *day*. This boundary is exactly where the two kinds meet without conflating them |
| CLAIMS ids | **None.** This task renders no user-facing number, date, or copy — it converts an instant to an internal integer day. The claim-bearing surfaces (locale numerals, calendar labels, the Hijri honesty note) are E02-T05/T06/T07, registered via `domain-claims-register-and-science-screen` there |
| Siblings: E02-T01, E02-T04, E02-T08 | **T01** ships `CalendarDate` + `CalendarDate.ymd` that this helper calls (hard dependency). **T04** adds `todayFor`/`todayProvider` — the *other* `.toLocal()` edge read (for "today"); this task supplies the *review-instant* half and T04 the *today* half, so T04 depends on this. **T08** runs the full T1–T5 DST/timezone matrix; T10's local-day boundary vector lands at **E02-T10**, which consumes this helper. This task ships only `civilDayOf` and its T10 unit pin — not persistence (E03), not the injected today (T04), not the presenter (T05) |

## Implementation notes

TEST-FIRST: this is correctness-critical edge arithmetic (the "revised tonight → tomorrow's UTC date" off-by-one). Write the `civil_day_of_test.dart` suite below — at minimum the T10 23:00-local pin and the UTC-vs-local divergence case — **before** the `civilDayOf` body, and watch them fail (red) before implementing.

1. **File**: `packages/engine/lib/src/dates/civil_day_of.dart`, alongside `calendar_date.dart` (E02-T01) in the engine's private `lib/src/dates/` subtree (per 02 §3.2 / E01-T03). A pure top-level function, not a class. Re-export from the engine barrel: `export 'src/dates/civil_day_of.dart' show civilDayOf;` in `packages/engine/lib/engine.dart`.
2. **Imports**: none beyond the sibling `calendar_date.dart`. **No** `package:flutter`, **no** `dart:io`/`dart:ui`, **no** `hijri`/`shamsi_date`/`intl`, **no** `package:flutter_riverpod`, **no** `DateTime.now()`. The CI banned-import / no-network grep gate (E01) enforces engine purity; this helper is pure-Dart and offline by construction. (`civilDayOf` is the *conversion*, not the clock read — it takes the instant as an argument, so it stays clock-free; the actual `DateTime.now()` read lives at the Riverpod composition root in E02-T04 / the app shell.)
3. **Signature & body** — verbatim from the skill `template.dart` LAYER 2 and 07 §3:
   ```dart
   /// Turn a real event INSTANT into the civil day the engine measures from.
   /// `.toLocal()` exactly once, so "I revised this tonight" means tonight's
   /// LOCAL date, not tomorrow's UTC date. The instant itself is still persisted
   /// UTC in review_log; the civil day is what drives scheduling.   (07 §3)
   CalendarDate civilDayOf(DateTime instant) {
     final local = instant.toLocal();
     return CalendarDate.ymd(local.year, local.month, local.day);
   }
   ```
   `.toLocal()` is called **exactly once**; the result's `(year, month, day)` feed `CalendarDate.ymd` (the pure proleptic-Gregorian calculator from E02-T01). No `Duration`, no `DateTime.add`, no `DateTime.difference`, no second `.toLocal()`.
4. **Totality**: the function never throws for any representable `DateTime` — `.toLocal()` and `CalendarDate.ymd` are both total. No range guard, no null path, no error type (the engine is total; the Hijri range-guard is a *display* concern at E02-T07, not here).
5. **The instant is never recomputed (document this)**: the `///` doc and an in-body why-comment state that the passed `DateTime` is a UTC instant from the append-only `review_log` audit trail and that this conversion is read-only — `civilDayOf` derives a day, it does not mutate, normalize, or re-store the instant. Persisting `review_log.reviewed_at` as UTC is E03's job; this task only consumes the instant to derive the civil day.
6. **Doc the doc**: the `///` comment also states the boundary rule in plain words — instants stay UTC, the civil day drives scheduling — so the next reader does not "helpfully" round-trip a stored day through a local-midnight `DateTime`.
7. **Pitfalls to avoid**: deriving the civil day from `instant.toUtc()` / the instant's UTC `(y,m,d)` (the exact bug — a 23:00 Tehran review would land on tomorrow); calling `.toLocal()` twice or once per field; using `DateTime(y,m,d)` (local midnight) instead of `CalendarDate.ymd`; adding a `localNow`/clock parameter and reading it (the clock read is `todayFor`, E02-T04 — not this function); importing Riverpod/Flutter here (it is pure engine-edge Dart); range-guarding or throwing (the engine is total); reusing this for "today" (use `todayFor`).

## Acceptance criteria

- [ ] `packages/engine/lib/src/dates/civil_day_of.dart` exists and is re-exported from the engine barrel; the `engine` package still builds with deps `meta` + `models` only; a grep over the file shows no `DateTime.now()`, no `Duration`, no `.toUtc()`, no second `.toLocal()`, and no `flutter`/`dart:io`/`dart:ui`/`hijri`/`shamsi_date`/`intl`/`flutter_riverpod` import.
- [ ] `civilDayOf(DateTime instant)` calls `.toLocal()` **exactly once** and returns `CalendarDate.ymd(local.year, local.month, local.day)` — a `CalendarDate`, never a `DateTime`.
- [ ] **T10**: a 23:00-local review in a positive-UTC-offset zone yields the civil day equal to the *local* date (not UTC's already-incremented next date), asserted with explicit UTC instants so the result is host-zone-independent.
- [ ] A UTC instant whose local `(y,m,d)` differs from its UTC `(y,m,d)` (either direction across midnight) converts to the **local** day, not the UTC day.
- [ ] The function is total: it returns a valid `CalendarDate` for any representable `DateTime` and never throws — no range guard, no null, no error type.
- [ ] The `///` doc and an in-body why-comment cite 07 §3, state that `.toLocal()` is the single boundary conversion, and document that `review_log` instants stay UTC and are never recomputed — the civil day is what drives scheduling.
- [ ] The file passes `dart format --output=none --set-exit-if-changed` and `dart analyze --fatal-infos` clean and carries the REUSE SPDX header (`GPL-3.0-or-later`).
- [ ] The T10 + UTC-vs-local-divergence pins were committed and red **before** the `civilDayOf` body (test-first, visible in PR history or a noted local run).

## Tests

`packages/engine/test/dates/civil_day_of_test.dart` (mirrors the source name under the engine `test/` tree, per 11 §2 / E01-T03), `package:test` only (`test()`/`expect()`/`group()`) — **no** `flutter_test`, **no** widget binding, no wall-clock read; every instant is a constructed `DateTime.utc(...)` literal and every expectation a `CalendarDate.ymd(...)` literal. The shared throwing-`HttpOverrides` offline bootstrap (E01-T06) stays installed; this suite touches no network by construction. REUSE SPDX header on the file. Required cases, written **first**:

- **T10 — 23:00-local lands on the local day**: construct the UTC instant that corresponds to 23:00 local time in a positive-UTC-offset zone (e.g. Tehran, +03:30 — `DateTime.utc(2026, 6, 16, 19, 30)` is 2026-06-16 23:00 local). With the host's local zone set to that offset (via the runner's `TZ`, mirroring T4/T5 discipline), assert `civilDayOf(instant) == CalendarDate.ymd(2026, 6, 16)` — the *local* date — and explicitly **not** `CalendarDate.ymd(2026, 6, 17)` (UTC's already-rolled-over date). Never green only under `TZ=UTC`.
- **UTC-vs-local divergence (both directions)**: an instant just before local midnight whose UTC `(y,m,d)` is the *next* day → civil day is the local (earlier) day; an instant just after local midnight in a negative-offset zone whose UTC `(y,m,d)` is the *previous* day → civil day is the local (later) day. In both, the civil day follows local, not UTC.
- **No divergence (UTC zone control)**: under `TZ=UTC`, `civilDayOf(DateTime.utc(2026, 6, 16, 23, 0)) == CalendarDate.ymd(2026, 6, 16)` — the local and UTC days coincide, the control that proves the local-vs-UTC cases above isolate the boundary, not noise.
- **Single `.toLocal()` / idempotence of the day**: `civilDayOf(instant)` equals `civilDayOf(instant.toLocal())` and `civilDayOf(instant.toUtc())` for the same physical moment — the conversion depends only on the instant's *moment* and the device's local zone, never on the instant's stored `isUtc` flag.
- **Totality**: `civilDayOf` returns a `CalendarDate` and throws for no input across a sweep of instants (epoch, far past, far future, leap-day, year boundary).
- **Instant is untouched**: the passed `DateTime` is value-equal before and after the call (the helper reads it, never mutates or re-stores it) — the read-only `review_log` invariant asserted at the unit boundary.

T4/T5 schedule zone-independence and the broader DST matrix belong to **E02-T08**; this task pins only the T10 local-day boundary that `civilDayOf` owns, and E02-T10 wires T10 into the date-gate CI lane.

## Definition of Done

- [ ] All acceptance criteria met; the T10 + divergence + control + idempotence + totality + untouched-instant suite is green under `dart test packages/engine` and in CI's fast `dart test` lane, run under a positive-UTC-offset `TZ` (never green only under `TZ=UTC`).
- [ ] **Test-first honoured**: the T10 23:00-local pin and the UTC-vs-local divergence case existed and failed before the `civilDayOf` body — the "revised tonight → tomorrow's UTC date" off-by-one is pinned, not patched.
- [ ] **Offline / no-network**: the helper opens no socket; the shared throwing-`HttpOverrides` bootstrap is installed in the test and the no-network CI gate stays green ([PRD C1, §19.3](../../docs/PRD.md)).
- [ ] **No-AI / no-microphone**: pure `DateTime`→`CalendarDate` conversion — no ML, no recognition, no audio, no microphone anywhere in this task ([PRD C2](../../docs/PRD.md)).
- [ ] **Quran text fidelity untouched**: this task renders no glyph and imports no muṣḥaf asset; it converts an instant to an integer day far below the text layer ([PRD R1](../../docs/PRD.md)).
- [ ] **Engine purity**: `civilDayOf` is dependency-free in `engine/` (calls only `CalendarDate`); the CI banned-import grep proves `DateTime.now()`/`Duration`/`hijri`/`shamsi_date`/`intl`/`flutter`/`flutter_riverpod`/`dart:io` are unimportable here; the only `DateTime` use is the passed-in instant's `.toLocal()` and `CalendarDate.ymd` ([07 §1, §3](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- [ ] **Determinism**: the helper reads no clock of its own (it converts a *given* instant); with the local zone fixed by `TZ`, identical instants yield identical civil days on every runner — the property the injected-today design protects ([PRD §7.12, §19.3](../../docs/PRD.md)).
- [ ] **Instant integrity**: `review_log` instants stay UTC and are never recomputed or normalized; `civilDayOf` is a read-only derivation, documented as such ([07 §3](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- [ ] **RTL + fa/ckb/ar strings**: N/A by construction — this task introduces no user-facing string; it emits a `CalendarDate`, not a label. Locale numerals and calendar labels are E02-T05/T06.
- [ ] **Accessibility**: N/A — no rendered surface; the helper emits no label a screen reader consumes (the presenter at E02-T05 owns the screen-reader-safe localized output).
- [ ] **Sect-neutral adab**: no calendar, observance, or sighting claim is made here — the civil day is calendar-agnostic proleptic-Gregorian arithmetic; the Hijri Umm al-Qurā honesty note lives at E02-T07.
- [ ] **No gamification**: no streak, score, or "behind"/"overdue" framing is introduced — this is an internal edge conversion.
- [ ] **Deterministic tests**: every case constructs instants as `DateTime.utc(...)` literals and expectations as `CalendarDate.ymd(...)` literals, reads no wall clock, asserts exact integer-day equality (no float, no `closeTo`), and is reproducible on any host under the declared `TZ`; coding standards hold (REUSE header, full-word names, `dart format`/`dart analyze` clean, `///` on the public helper).

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
