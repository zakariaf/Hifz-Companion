---
name: domain-calendars-and-hifzdate
description: Govern every date, day-count, due-date, and calendar surface in the Hifz Companion app so scheduling days never drift across a timezone or DST transition and the calendar stays display-only. Use whenever adding or changing date math, day counts, due-date computation, "elapsed days", date serialization, the `CalendarDate` value type, the injected "today", calendar display (Hijri Umm al-Qurā / Solar-Hijri Jalālī / Gregorian), locale numerals on dates, or scheduled local notifications.
---

# Hifz calendars & CalendarDate correctness

Dates are the single most error-prone surface in a scheduling app whose whole promise is "every memorized page is re-recited at least once per chosen cycle, no matter what." A `due_at` that slips by a day because the clock sprang forward is not a cosmetic glitch — it is a silent breach of the cycle ceiling, the one invariant the product exists to keep. This skill enforces the boundary that prevents it: scheduling reasons in `CalendarDate` (an integer serial-day value type with no clock, no zone, no calendar object); all interval/cycle/ceiling math is integer day arithmetic; instants and civil days are stored as different kinds; the three calendars are rendered display-only behind one presenter; and "today" is injected so the engine is deterministic. The governing spec is `docs/engineering/07-dates-calendars-and-correctness.md`.

> The engine doc (`docs/engineering/06-scheduling-engine.md`) calls this value type `SerialDay`; doc 07 names the same type `CalendarDate` and owns it. They are one type — this skill is the one the engine refers to as **eng-datemath-and-serialday**.

## When to use

Use this skill when you:

- add or change any date math, day count, or "elapsed days" computation — anything that adds/subtracts days, computes a due date, or measures distance between two days;
- touch the `CalendarDate` value type, its `addDays` / `daysUntil` / `compareTo`, or its `epochDay` serialization to/from a SQLite `INTEGER`;
- compute or store a `due_at`, a cycle ceiling, or convert a review's instant into the civil day the engine measures from;
- render a date for the user — Hijri (Umm al-Qurā), Solar-Hijri/Jalālī, or Gregorian — or map its digits to the locale numeral set;
- wire the injected "today" provider, or schedule a local notification that keys off the local civil day;
- add or edit a date/calendar correctness test vector (DST, timezone, round-trip, numeral, reference-pair).

Do **NOT** use this skill for — use the sibling instead:

- the SR curve, interval inversion, S/D update, tracks, or the trust clamp *math* that consumes these dates → use **domain-scheduling-engine-rules**;
- how a `CalendarDate.epochDay` is physically written/read in one Drift transaction, or the `review_log` schema → use **eng-persistence-single-write-path**;
- the full bidi isolation, ARB strings, RTL widget mirroring, and the in-Settings calendar picker *UI* → use **ui-rtl-localization**;
- registering a user-facing factual claim (e.g. the Hijri honesty note) on the science screen → use **domain-claims-register-and-science-screen**;
- rendering the immutable muṣḥaf glyphs themselves → use **domain-mushaf-text-integrity**.

This skill owns the **date type the engine reasons in** and the **calendar rendering the engine never touches** — nothing else. If your change opens a database, mirrors a widget, or computes a stability value, it belongs to a sibling.

## The canonical pattern

The full spec is `docs/engineering/07-dates-calendars-and-correctness.md`. Reference each rule by its doc section — never re-derive an epoch, a range, or a conversion here.

### The value type and its math (`07-dates-calendars-and-correctness.md` §1–§2)

1. **Scheduling reasons in `CalendarDate`, never a `DateTime`.** `CalendarDate` is an immutable, dependency-free value type in the `engine/` package holding one integer — `epochDay`, days since `1970-01-01` on the proleptic-Gregorian calendar — with `(year, month, day)` derived on demand. It is the **only** date type the pure engine imports, constructs, or returns; a `DateTime` never enters the engine and a `CalendarDate` is never silently widened into an instant inside scheduling code. This is the Dart fix for the missing `LocalDate`. `docs/engineering/07-dates-calendars-and-correctness.md` §1 (the `CalendarDate` value type).
2. **Construct via the pure `(y,m,d) ↔ epochDay` calculator — never a clock read.** `CalendarDate.ymd(y,m,d)` uses `DateTime.utc(y,m,d)` (and `fromMillisecondsSinceEpoch(..., isUtc: true)` for the inverse) **only at construction**, as a deterministic proleptic-Gregorian calculator with no zone. This is the *one* permitted `DateTime` use in the type; it reads no clock. `docs/engineering/07-dates-calendars-and-correctness.md` §1 (Specification + Pitfalls — local-midnight as a stand-in is refused).
3. **All interval / cycle / ceiling math is integer day arithmetic.** `elapsed_days`, `interval(S,R)`, the cycle ceiling, catch-up re-spread, peak-smoothing nudges — every time-dimensioned quantity is `addDays` / `daysUntil` on `CalendarDate`. No `Duration`, no `DateTime.add`, no `DateTime.difference(...).inDays`, and no month/leap-year logic ever runs in a scheduling path. Day-distance is calendar-invariant, which is exactly why the calendar can be display-only. `docs/engineering/07-dates-calendars-and-correctness.md` §2 (integer day arithmetic; the engine-quantity table).

### Two kinds of date, stored differently (`07-dates-calendars-and-correctness.md` §3)

4. **An instant and a civil day are different facts.** Store **event instants** — `review_log.reviewed_at`, `card.last_review_at` — as **UTC `DateTime`** (the exact moment of a *sanad* act, append-only, never recomputed). Store **scheduling days** — `due_at`, the cycle ceiling, the injected "today", `card.last_review_day` — as the **`CalendarDate` serial-day integer**. A scheduling day is never round-tripped through a local-midnight `DateTime`. `docs/engineering/07-dates-calendars-and-correctness.md` §3 (instant vs civil day; the field-kind table).
5. **Convert instant → civil day once, at the app edge, in local time.** `civilDayOf(instant)` uses `.toLocal()` exactly once so "I revised this tonight" means tonight's *local* date, not tomorrow's UTC date. After this single boundary conversion the engine sees only `CalendarDate`s; the instant is still persisted UTC in `review_log` for the audit trail. `docs/engineering/07-dates-calendars-and-correctness.md` §3 (Specification — `civilDayOf`; Pitfalls — never derive "today" from a UTC `(y,m,d)`).

### Calendars are display-only (`07-dates-calendars-and-correctness.md` §4, §6)

6. **One `CalendarPresenter` is the only place a `CalendarDate` becomes localized text.** It maps `(CalendarDate, CalendarSystem, Locale)` → a localized string using pure-Dart, BSD-licensed, offline packages: `shamsi_date` (Jalālī, default for `fa`), `hijri` (Umm al-Qurā), and `intl`'s `DateFormat` for Gregorian. Views never construct a `Jalali`/`HijriCalendar`; the engine never sees one. `docs/engineering/07-dates-calendars-and-correctness.md` §4 (one presentation helper); `docs/PRD.md` §13.3 (the three supported calendars).
7. **Calendar choice is an explicit Settings value, never inferred from locale.** `CalendarSystem.{jalali, hijriUmmAlQura, gregorian}` is a user picker — defaulted (Jalālī for `fa`) but never silently switched off `Locale.current`; Hijri and Gregorian are offered to every locale. `docs/engineering/07-dates-calendars-and-correctness.md` §4 (Pitfalls — we refuse to infer the calendar from locale); `docs/PRD.md` §13.3.
8. **Numerals are remapped downstream of the calendar conversion.** Convert the date first, then pass the numeric fields through the locale digit map — `fa`/`ckb` → Extended Arabic-Indic (۰۱۲۳۴۵۶۷۸۹), `ar` → Arabic-Indic (٠١٢٣٤٥٦٧٨٩) via `intl` `NumberFormat`. Never concatenate raw ASCII digits into a localized string; the month *name* and era come from the calendar package's localized tables, not `intl`'s Gregorian-only `DateFormat`. `docs/engineering/07-dates-calendars-and-correctness.md` §4 (numerals remapped downstream); `docs/PRD.md` §13.3.
9. **Hijri is a labelled civil approximation, never a religious authority.** Render Hijri as **Umm al-Qurā**, labelled as such, with a standing one-line honesty note that an observance's start may differ by a day by sighting; never key a deadline, reminder, or guarantee to a Hijri date being exact; range-guard conversions and fall back to a Gregorian label rather than throw; stay madhhab/sect-neutral and issue no sighting ruling. `docs/engineering/07-dates-calendars-and-correctness.md` §6 (Hijri honesty); `docs/PRD.md` §13.3, R2.

### "Today" is injected; one zone (`07-dates-calendars-and-correctness.md` §5)

10. **The engine never reads a clock — "today" is an injected `CalendarDate`.** `todayFor(now)` reads the clock **once**, at the app edge, via `.toLocal()`, and a single `todayProvider` threads the resulting `CalendarDate` through the session; the engine call sites receive `ref.read(todayProvider)`, never `DateTime.now()`. Tests override the provider with a fixed date. `docs/engineering/07-dates-calendars-and-correctness.md` §5 (Specification — `todayFor` + `todayProvider`); `docs/engineering/06-scheduling-engine.md` §8 (identical inputs ⇒ identical schedule).
11. **The device's own local zone is the only zone we read; no `timezone`/IANA dependency.** Nothing syncs between devices and we never convert into another region's zone, so the full tz database is dead weight; the local daily reminder (`flutter_local_notifications`) keys off the same local civil day, not a UTC or Hijri date. A midnight rollover never re-shuffles an open session — "today" is captured at session start. `docs/engineering/07-dates-calendars-and-correctness.md` §5 (Pitfalls — we refuse the `timezone`/IANA dependency and the mid-session rollover).

### Correctness is a release gate (`07-dates-calendars-and-correctness.md` §7)

12. **Pin every date change with the DST/timezone/round-trip/numeral matrix.** `addDays`/`daysUntil` DST-immune (T1/T2); trust clamp ≤ ceiling under `glados` (T3); schedule byte-identical across `TZ=Asia/Tehran`/`Pacific/Kiritimati`/`UTC` and across a DST-change date (T4/T5); Jalālī and in-range Hijri round-trips are identity with a graceful Gregorian fallback out of range (T6/T7); numerals map per locale with no ASCII digits (T8); a documented Umm al-Qurā reference pair matches (T9); a 23:00-local review lands on the local day (T10). Reference vectors come from an independently published conversion, never the library asserting against itself. `docs/engineering/07-dates-calendars-and-correctness.md` §7 (the correctness test matrix — release gate); `docs/PRD.md` §20 gate 5.

## Do / Don't

| Do | Don't |
|---|---|
| Reason over `CalendarDate` (`epochDay` integer); keep it pure, dependency-free, in `engine/` | Let a `DateTime` enter the engine, or widen a `CalendarDate` into an instant in scheduling code |
| Build dates with `CalendarDate.ymd` (pure `(y,m,d)` calculator via `DateTime.utc`) | Use `DateTime(y,m,d)` (local midnight) to mean "that day" — it bakes in the device zone |
| Add/measure days with `addDays` / `daysUntil` (integer) | `Duration(days: n)`, `DateTime.add`, or `DateTime.difference(...).inDays` (DST off-by-one) |
| Store instants (`reviewed_at`) as UTC `DateTime`; store days (`due_at`) as `epochDay` `INTEGER` | Store a scheduling day as a local-midnight `DateTime`, or one column doing double duty |
| Convert instant→civil day once at the edge with `.toLocal()` | Derive "today" from a UTC `(y,m,d)`, or recompute/normalize a stored `review_log` instant |
| Render dates only through `CalendarPresenter`; calendar from an explicit Settings value | Construct a `Jalali`/`HijriCalendar` in a view, or infer the calendar from `Locale.current` |
| Remap numerals downstream of conversion (`intl` `NumberFormat` per locale) | Concatenate raw ASCII digits into a localized string, or let a package's Latin digits reach the UI |
| Label Hijri as Umm al-Qurā with the standing honesty note; range-guard with Gregorian fallback | Present a Hijri date as the authoritative date of Ramaḍān/ʿĪd, or bake in one region's sighting offset |
| Inject "today" via `todayProvider`; read the clock once at the edge via `.toLocal()` | `DateTime.now()` in the engine or any scheduling path; the `timezone`/IANA dependency |
| Pin DST/timezone/round-trip/numeral vectors from an independently published source | Test dates only in a no-DST zone, or assert calendar output against a hand-typed string |

## Checklist

Before a date/calendar change is done:

- [ ] All scheduling day math is `CalendarDate` integer arithmetic (`addDays`/`daysUntil`); no `Duration`, `DateTime.add`, `DateTime.difference(...).inDays`, or month/leap logic in any scheduling path (§1, §2).
- [ ] `CalendarDate` stays pure and dependency-free in `engine/`; no `hijri`/`shamsi_date`/`intl`/`DateTime.now()` is importable from it; the only `DateTime` use is the `CalendarDate.ymd` `(y,m,d)` calculator (§1; banned-import grep gate via **eng-offline-ci-gates**).
- [ ] Instants (`reviewed_at`, `last_review_at`) are stored UTC `DateTime`; scheduling days (`due_at`, ceiling, `last_review_day`, "today") are stored as `epochDay` `INTEGER`; no scheduling day round-trips through a local-midnight `DateTime` (§3; persistence via **eng-persistence-single-write-path**).
- [ ] Instant→civil-day conversion happens once at the app edge via `.toLocal()` (`civilDayOf`); `review_log` instants are never recomputed (§3).
- [ ] Every `CalendarDate`→text path goes through `CalendarPresenter`; no view constructs a `Jalali`/`HijriCalendar`; the calendar is an explicit `CalendarSystem` Settings value (default Jalālī for `fa`), never inferred from locale (§4; UI picker via **ui-rtl-localization**).
- [ ] Numerals are remapped *after* conversion to the locale set — Extended Arabic-Indic for `fa`/`ckb`, Arabic-Indic for `ar` — with no ASCII digits in any localized date string (§4; `docs/PRD.md` §13.3).
- [ ] Hijri is labelled Umm al-Qurā with the standing honesty note; no deadline/reminder/guarantee keys off a Hijri date being exact; out-of-range conversion falls back to Gregorian (never throws); framing is madhhab/sect-neutral with no sighting ruling (§6; `docs/PRD.md` R2; register the honesty note via **domain-claims-register-and-science-screen**).
- [ ] "Today" is injected as a `CalendarDate` via `todayProvider`; the clock is read once at the edge via `.toLocal()`; no `DateTime.now()` in the engine or any scheduling path; tests override the provider with a fixed date (§5; §1 of `06-scheduling-engine.md`).
- [ ] No `timezone`/IANA dependency is added; the local notification keys off the local civil day; a midnight rollover does not re-shuffle an open session (§5).
- [ ] The correctness matrix is updated and green: T1/T2 (DST-immune `addDays`/`daysUntil`), T3 (clamp ≤ ceiling), T4/T5 (timezone- and DST-independent schedule), T6/T7 (Jalālī + in-range Hijri identity round-trips, Gregorian fallback out of range), T8 (per-locale numerals, no ASCII), T9 (published Umm al-Qurā reference pair), T10 (23:00-local lands on the local day) — vectors from an independent source, run under DST zones, never green only under `TZ=UTC` (§7; `docs/PRD.md` §20 gate 5; harness via **eng-write-dart-test**).
- [ ] RTL/i18n preserved: the engine still emits opaque day counts only; all locale/numeral/calendar logic lives at the display boundary, correct in fa/ckb/ar (§4).
- [ ] Offline & adab preserved: nothing about date rendering touches the network (both calendar packages are bundled pure Dart); no streak/score/shame surface is introduced; the Hijri caveat keeps the app honest and never asserts a sighting (§4, §6; `docs/PRD.md` R2).

A scheduling day is a fact the user asserted, not a moment on a clock. If a change makes a `due_at` depend on a zone, a DST transition, or a calendar's leap rule, it is wrong no matter how it renders — the schedule must be byte-identical in Gregorian, Jalālī, and Hijri, and the calendar may only change the *label*.

## Files

- `template.dart` — copy-paste scaffold for a typical date/calendar edit: the pure `CalendarDate` value type and its integer math, the app-edge `todayFor`/`civilDayOf` boundary and `todayProvider`, the `CalendarPresenter` with downstream numeral remap and the Hijri honesty fallback, and the DST/round-trip/numeral test matrix — with `// TODO` markers and every constant/rule referenced by name.
- `references.md` — the exact governing doc sections, each with the one thing to take from it, and the sibling skills.

Related skills: **domain-scheduling-engine-rules** (the SR math / trust clamp that consumes `CalendarDate` and the injected `today`; the engine calls this type `SerialDay`), **eng-persistence-single-write-path** (writes `epochDay` and the UTC `review_log` in one transaction), **ui-rtl-localization** (bidi isolation, ARB strings, the Settings calendar picker that selects `CalendarSystem`), **domain-claims-register-and-science-screen** (register the Hijri honesty note before it ships), **domain-mushaf-text-integrity** (the immutable glyph rendering this skill never touches), **eng-write-dart-test** (the golden-vector + `glados` matrix harness), **eng-offline-ci-gates** (the banned-import grep gate keeping `DateTime.now()`/`timezone`/calendar packages out of `engine/`).
