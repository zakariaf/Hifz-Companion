# E02-T01 — CalendarDate value type in engine/ with DST-immune addDays/daysUntil (test-first)

| | |
|---|---|
| **Epic** | [E02 — Calendar & Date Core](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E01 |
| **Skills** | domain-calendars-and-hifzdate, eng-write-dart-test, eng-write-to-coding-standards |

## Goal

`CalendarDate` exists in `packages/engine/lib/src/dates/calendar_date.dart` as an immutable, dependency-free value type holding **one** `int epochDay` (days since `1970-01-01` on the proleptic-Gregorian calendar), with `(year, month, day)` derived on demand. It is constructed only through `CalendarDate.ymd(year, month, day)` — a pure `(y,m,d) ↔ epochDay` calculator that uses `DateTime.utc` / `DateTime.fromMillisecondsSinceEpoch(isUtc: true)` as arithmetic and **reads no clock** — and exposes `addDays` / `daysUntil` / `isBefore` / `isAfter` / `compareTo` / `==` / `hashCode` / `toString` (ISO-8601 full-date). `addDays`/`daysUntil` are exact integer epoch-day math, immune to any timezone or DST transition by construction. A `package:test` unit suite, **written first**, pins `addDays`/`daysUntil` as exact ±epochDay across a real US spring-forward week before the type is implemented. This is the single date type the pure engine reasons in; no `DateTime` field and no local-midnight stand-in is permitted.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/07-dates-calendars-and-correctness.md` §1 (the `CalendarDate` value type) | The exact shape: one `int epochDay` (days since `1970-01-01`, proleptic-Gregorian), `(y,m,d)` derived on demand, the verbatim `CalendarDate.ymd` calculator (`DateTime.utc` forward, `fromMillisecondsSinceEpoch(..., isUtc: true)` inverse) as the **one** permitted `DateTime` use that reads no clock; the refusal of a `DateTime` field and of local-midnight as a stand-in for a day |
| `docs/engineering/07-dates-calendars-and-correctness.md` §2 (integer day arithmetic) | `addDays`/`daysUntil` are pure integer epoch-day add/subtract — **never** `Duration(days:n)`, `DateTime.add`, or `DateTime.difference(...).inDays`; day-distance is calendar-invariant, which is why the calendar can be display-only; `elapsedDays`/`nextDue` consume this type but their scheduling math is **E04**, not this task |
| `docs/engineering/07-dates-calendars-and-correctness.md` §7, T1–T2 | The two DST-immunity vectors this task pins test-first: T1 `CalendarDate.ymd(2026,3,7).addDays(1) == CalendarDate.ymd(2026,3,8)` (exactly +1 epochDay across the US spring-forward week); T2 `daysUntil` is an exact integer day-count across a spring-forward **and** a fall-back boundary (never a 23h/25h artifact) |
| Skill `domain-calendars-and-hifzdate` (+ `template.dart` LAYER 1) | Rules 1–3: reason in `CalendarDate` never a `DateTime`; build via the pure `ymd` calculator never a clock read; all interval math is `addDays`/`daysUntil` integer arithmetic. The LAYER 1 scaffold is the body to author; the Checklist's first two rows are the acceptance bar. (Doc 06 calls this same type `SerialDay`; it is one type, owned here.) |
| Skill `eng-write-dart-test` §2, §3, §8, §11 | Engine tests use `package:test` (never `flutter_test`), need no widget binding, construct dates as literals with no wall clock; the throwing-`HttpOverrides` offline guard from the shared bootstrap (E01-T06); full-word names, typed `catch`, REUSE SPDX header on the test file |
| Skill `eng-write-to-coding-standards` §1–§6 | Effective Dart casing (`CalendarDate`, `epochDay`, `addDays`); the unit lives in the name (`epochDay`, not `day`); `@immutable`, `final` fields, `const` constructor; the engine is **total** — every method returns a value, never throws; `///` on every public member; in-body comments say *why* (cite §1/§2 at the `ymd` calculator and at `addDays`) |
| `docs/PRD.md` §7.12, §19.3 | The determinism mandate this type protects: identical inputs → identical schedule; no wall-clock in the engine — the property `epochDay` integer math makes true by construction |
| CLAIMS ids | **None.** This task renders no user-facing number, date, or copy — it is the internal integer value type. Locale numerals, calendar labels, and the Hijri honesty note (the only claim-bearing surfaces) are **E02-T05/T06/T07**, registered via `domain-claims-register-and-science-screen` there |
| Siblings: E02-T02, E02-T03, E02-T04, E02-T08 | T02 builds `elapsedDays`/`nextDue`/ceiling-add/catch-up on **this** type's `addDays`/`daysUntil`; T03 adds the `civilDayOf` app-edge instant→civil-day boundary that calls `CalendarDate.ymd`; T04 injects `todayFor`/`todayProvider` returning this type; T08 runs the full T1–T5 DST/timezone matrix over this type. This task ships only the value type and its T1/T2 unit pins — not the day-math primitives, the edge conversions, or the presenter |

## Implementation notes

TEST-FIRST: this is correctness-critical date arithmetic (the off-by-one-day class the whole epic exists to remove). Write the `calendar_date_test.dart` suite below — the T1 `addDays` pin and the T2 `daysUntil` pin across a real spring-forward/fall-back week — **before** the `CalendarDate` body, and watch them fail (red) before implementing.

1. **File**: `packages/engine/lib/src/dates/calendar_date.dart`, one primary type per file (`calendar_date.dart` → `CalendarDate`). The `dates/` subfolder under the engine's private `lib/src/` tree (per 02 §3.2 / E01-T03); no `utils/`/`helpers/`/`core/` junk-drawer folder. Re-export from the barrel `packages/engine/lib/engine.dart` as `export 'src/dates/calendar_date.dart' show CalendarDate;`.
2. **Imports**: `package:meta/meta.dart` only (for `@immutable`), already an `engine` dependency (E01-T03). **No** `package:flutter`, **no** `dart:io`, **no** `dart:ui`, **no** `hijri`/`shamsi_date`/`intl`, **no** `DateTime.now()`. The CI banned-import / no-network grep gate (E01) enforces this; the `engine` manifest is the purity audit.
3. **State**: `final int epochDay;` — the single field, days since `1970-01-01`, negative for earlier dates; this integer **is** the stored representation (E03 maps it to a SQLite `INTEGER` with bit-for-bit fidelity). `(year, month, day)` are derived getters, never stored fields. `@immutable`, private `const CalendarDate._(this.epochDay)`.
4. **Construction**: the **only** public constructor is `factory CalendarDate.ymd(int year, int month, int day)` — verbatim from 07 §1: `DateTime.utc(year, month, day).millisecondsSinceEpoch ~/ _msPerDay`. This is the one permitted `DateTime` use in the engine: a pure proleptic-Gregorian calculator reading no clock, no zone. The inverse getters use `DateTime.fromMillisecondsSinceEpoch(epochDay * _msPerDay, isUtc: true)`. `static const int _msPerDay = 86400000;` named, not magic.
5. **Day math**: `CalendarDate addDays(int days) => CalendarDate._(epochDay + days);` and `int daysUntil(CalendarDate other) => other.epochDay - epochDay;` — pure integer arithmetic, total (never throws), DST-immune by construction. A why-comment cites §2 and names the refusal: never `Duration(days:n)`, never `DateTime.add`, never `DateTime.difference(...).inDays`.
6. **Comparison & value semantics**: `isBefore`/`isAfter` over `epochDay`; `implements Comparable<CalendarDate>` with `compareTo`; `operator ==` and `hashCode` over `epochDay` only; `toString()` is the ISO-8601 `full-date` (`YYYY-MM-DD`, zero-padded) for logs/backup — explicitly **not** a localized label (that is the `CalendarPresenter`, E02-T05).
7. **Docs**: `///` on every public member — the class, `epochDay`, `ymd`, `addDays`, `daysUntil`, `isBefore`, `isAfter`, `compareTo`, `toString`. The class doc states "a civil calendar day on the proleptic-Gregorian calendar; NOT an instant — no time, no zone, no DST surface." `ymd` and `addDays` carry the §1/§2 why-comments.
8. **Pitfalls to avoid**: a `DateTime` field anywhere in the type (the exact refusal of §1); `DateTime(y,m,d)` local-midnight instead of `DateTime.utc` (bakes in the device zone); `addDays` via `Duration`/`DateTime.add`; `daysUntil` via `DateTime.difference(...).inDays` (truncates to 23h/25h across DST — the bug this task pins against); a public unnamed constructor that lets a raw `epochDay` or a `DateTime` in; making any method throw (the engine is total); a localized `toString`; hardcoding `86400000` as a magic literal.

## Acceptance criteria

- [ ] `packages/engine/lib/src/dates/calendar_date.dart` exists; the `engine` package builds with deps `meta` + `models` only (E01-T03); a grep over the file shows no `DateTime.now()`, no `Duration`, no `flutter`/`dart:io`/`dart:ui`/`hijri`/`shamsi_date`/`intl` import; the only `DateTime` references are inside `ymd` and the `(y,m,d)` getters.
- [ ] `CalendarDate` is `@immutable` with a single `final int epochDay`, a private `const` constructor, and `(year, month, day)` exposed as derived getters — no stored `DateTime` field, no public mutable state.
- [ ] `CalendarDate.ymd(y,m,d)` is the only public constructor; it round-trips: `CalendarDate.ymd(d.year, d.month, d.day) == d` for every date exercised.
- [ ] `addDays(n)` shifts `epochDay` by exactly `n` (`ymd(2026,3,7).addDays(1) == ymd(2026,3,8)` across the US spring-forward week — T1); `daysUntil(other)` returns the exact signed integer day-count across a spring-forward **and** a fall-back boundary, with zero 23h/25h artifacts (T2).
- [ ] `isBefore`/`isAfter`/`compareTo`/`==`/`hashCode` are consistent with `epochDay` ordering and equality; `toString()` is the zero-padded ISO-8601 `full-date` (`YYYY-MM-DD`), never a localized string.
- [ ] Every public declaration carries a `///` doc; `ymd` and `addDays` carry why-comments citing 07 §1 / §2; the file passes `dart format --output=none --set-exit-if-changed` and `dart analyze --fatal-infos` clean and carries the REUSE SPDX header (`GPL-3.0-or-later`).
- [ ] The T1/T2 unit suite was committed and red **before** the `CalendarDate` body (test-first, visible in the PR history or a noted local run).

## Tests

`packages/engine/test/dates/calendar_date_test.dart` (mirrors the source name under the engine `test/` tree, per 11 §2 / E01-T03), `package:test` only (`test()`/`expect()`/`group()`) — **no** `flutter_test`, **no** widget binding, no wall clock read; every date is a constructed `CalendarDate.ymd(...)` literal. The shared throwing-`HttpOverrides` offline bootstrap (E01-T06) stays installed; this suite touches no network by construction. REUSE SPDX header on the file. Required cases, written **first**:

- **T1 — `addDays` is DST-immune (spring-forward week)**: `expect(CalendarDate.ymd(2026, 3, 7).addDays(1), CalendarDate.ymd(2026, 3, 8))`; assert `epochDay` advanced by exactly 1 across the US spring-forward transition (2026-03-08). A control date in a no-transition week behaves identically.
- **T2 — `daysUntil` is exact across DST**: pick two dates straddling a spring-forward boundary and two straddling a fall-back boundary; assert `daysUntil` is the exact signed calendar-day count (e.g. 7 across a 7-day span containing a transition), never `6`/`8` and never an `inDays` 23h/25h artifact; assert `a.daysUntil(b) == -b.daysUntil(a)` (antisymmetry).
- **`ymd` ↔ `epochDay` round-trip**: for a sweep of dates (a multi-year span including leap-day `2024-02-29` and year boundaries), `CalendarDate.ymd(d.year, d.month, d.day) == d` and `d.epochDay` matches the expected serial integer; the epoch anchor `CalendarDate.ymd(1970, 1, 1).epochDay == 0`.
- **`addDays`/`daysUntil` inverse law**: `today.addDays(n).daysUntil(today) == -n` and `today.daysUntil(today.addDays(n)) == n` for a range of positive and negative `n`, including across month/year/leap boundaries.
- **Ordering & value semantics**: `isBefore`/`isAfter`/`compareTo` agree with `epochDay` ordering; `==`/`hashCode` are equal iff `epochDay` is equal (two `ymd` calls for the same day are equal and hash-equal).
- **`toString` is ISO-8601 full-date**: `CalendarDate.ymd(2026, 6, 16).toString() == '2026-06-16'`; single-digit month/day are zero-padded; the output contains only ASCII digits and hyphens (no localization here).

Optionally a `glados` property may pin "`ymd → epochDay → ymd` is identity" over generated `(y,m,d)` triples; the DST-zone matrix (T3–T5, schedule zone-independence under `TZ=Asia/Tehran`/`Pacific/Kiritimati`/`UTC`) belongs to **E02-T08** and consumes this type — it is not this task.

## Definition of Done

- [ ] All acceptance criteria met; the T1/T2 + round-trip + inverse + ordering + `toString` suite is green under `dart test packages/engine` and in CI's fast `dart test` lane.
- [ ] **Test-first honoured**: the DST `addDays`/`daysUntil` pins existed and failed before the `CalendarDate` body — the off-by-one-day class is pinned, not patched.
- [ ] **Offline / no-network**: the type opens no socket; the shared throwing-`HttpOverrides` bootstrap is installed in the test and the no-network CI gate stays green ([PRD C1, §19.3](../../docs/PRD.md)).
- [ ] **No-AI / no-microphone**: pure integer arithmetic — no ML, no recognition, no audio, no microphone anywhere in this task ([PRD C2](../../docs/PRD.md)).
- [ ] **Quran text fidelity untouched**: this task renders no glyph and imports no muṣḥaf asset; it is an integer value type far below the text layer ([PRD R1](../../docs/PRD.md)).
- [ ] **Engine purity**: `CalendarDate` is dependency-free in `engine/` (`meta` only); the CI banned-import grep proves `DateTime.now()`/`Duration`/`hijri`/`shamsi_date`/`intl`/`flutter`/`dart:io` are unimportable here; the only `DateTime` use is the pure `ymd` `(y,m,d)` calculator ([07 §1](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- [ ] **Determinism**: the type reads no clock; `addDays`/`daysUntil` are total integer functions that yield identical results on every runner in every zone — the property that lets the engine goldens reproduce ([PRD §7.12, §19.3](../../docs/PRD.md)).
- [ ] **RTL + fa/ckb/ar strings**: N/A by construction — this task introduces no user-facing string; `toString` is a non-localized ISO-8601 machine form (logs/backup). Locale numerals and calendar labels are E02-T05/T06.
- [ ] **Accessibility**: N/A — no rendered surface; the type emits no label a screen reader consumes (the presenter at E02-T05 owns the screen-reader-safe localized output).
- [ ] **Sect-neutral adab**: no calendar, observance, or sighting claim is made here — `CalendarDate` is calendar-agnostic proleptic-Gregorian arithmetic; the Hijri Umm al-Qurā honesty note lives at E02-T07.
- [ ] **No gamification**: no streak, score, or "behind"/"overdue" framing is introduced — this is an internal value type.
- [ ] **Deterministic tests**: every case constructs dates as literals, reads no wall clock, asserts exact integer equality (no float, no `closeTo` needed), and is reproducible on any host/zone; coding standards hold (REUSE header, full-word names, `dart format`/`dart analyze` clean, `///` on public members).

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
