# E02 — Calendar & Date Core

Build the `CalendarDate` value type — an immutable integer serial-day on the proleptic-Gregorian calendar, never a `DateTime` instant — and the single display boundary that turn timezone/DST scheduling drift into something impossible by construction. This epic owns the date type the engine reasons in (pure integer `addDays`/`daysUntil`), the injected "today", and the display-only `CalendarPresenter` that renders Hijri (Umm al-Qurā) / Solar-Hijri Jalālī / Gregorian with locale numerals — all pinned by the multi-decade round-trip sweep and the hostile-timezone/DST test matrix that make date correctness a release gate.

## Why this epic exists

The whole product is one promise: *every memorized page is re-recited at least once per chosen cycle, no matter what* ([PRD §7.6](../../docs/PRD.md)). That promise is a **date** computation. A `due_at` that slips by a day because the device clock sprang forward is not a cosmetic glitch — it is a silent breach of the cycle ceiling, the single invariant the app exists to keep ([PRD §7.12](../../docs/PRD.md), [engineering/07 §intro](../../docs/engineering/07-dates-calendars-and-correctness.md)). Dates are also the most error-prone surface in any scheduler, and Dart hands us a loaded gun: its `DateTime` is "an instant in time," has no civil `LocalDate`, and its own docs warn that "the difference between two midnights in local time may be less than 24 hours… if there is a daylight saving change in between" ([engineering/07 §1–§2](../../docs/engineering/07-dates-calendars-and-correctness.md)). `add(Duration(days: 1))` on a local instant adds 24 physical hours, which across a spring-forward lands on the wrong calendar day — a latent off-by-one-day generator pointed straight at the cycle ceiling.

So this epic draws the line Dart did not. A **scheduling day is a fact the user asserted, not a moment on a clock**: "due in 7 days" is seven calendar days, identical in Gregorian, Jalālī, and Hijri, immune to any zone or DST transition. We get there with three boundaries — (1) the engine reasons only in `CalendarDate` integer serial-days, so all interval/cycle/ceiling math is total, exact integer arithmetic with no `Duration`, no leap logic, no zone; (2) "today" is **injected** at the app edge, read from the device's local civil day exactly once, so the engine reads no clock and goldens are reproducible on any runner in any zone ([PRD §19.3](../../docs/PRD.md)); (3) the three calendars are **display-only**, produced by one `CalendarPresenter` that the engine never touches, so day-distance stays calendar-invariant and the calendar can change only the *label*. Because Hijri is genuinely several disagreeing calendars (±1–2 days vs sighting), the Umm al-Qurā rendering is honest by construction: labelled as a civil approximation, range-guarded with a Gregorian fallback, never asserting a sighting ruling — sect-neutral per R2 ([engineering/07 §6](../../docs/engineering/07-dates-calendars-and-correctness.md), [PRD R2](../../docs/PRD.md)). Everything here is pure Dart, fully offline (both calendar packages bundle no network), with no AI, no audio, no clock in the engine. E03 (persistence) maps `epochDay` to an `INTEGER` column, E04 (engine) consumes this type as its only date, and every dated UI surface in E11–E19 renders through this one presenter; a wrong boundary here corrupts all of them.

## Scope

### In scope

- The `CalendarDate` value type in the pure-Dart `engine/` package: immutable, dependency-free, one integer `epochDay` (days since `1970-01-01`, proleptic-Gregorian), `(year, month, day)` derived on demand, `addDays` / `daysUntil` / `compareTo` / `==` / `toString` (ISO-8601 `full-date`), built via the pure `CalendarDate.ymd(y,m,d)` `(y,m,d) ↔ epochDay` calculator — the *one* permitted `DateTime` use, reading no clock ([07 §1](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- The integer day-arithmetic primitives every scheduling quantity uses (`elapsed_days`, interval→due date, cycle ceiling, catch-up window, peak-smoothing offsets) — `addDays`/`daysUntil` only; no `Duration`, no `DateTime.add`, no `DateTime.difference(...).inDays`, no month/leap logic ([07 §2](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- The instant-vs-civil-day boundary helper `civilDayOf(instant)` that converts a review's UTC instant to the engine's civil day **once**, at the app edge, via `.toLocal()` (so "I revised this tonight" is tonight's local date) ([07 §3](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- The injected "today": `todayFor(now)` reading the device's local civil day once at the edge, and the `todayProvider` that threads the resulting `CalendarDate` through the session; the engine receives `ref.read(todayProvider)`, never `DateTime.now()` ([07 §5](../../docs/engineering/07-dates-calendars-and-correctness.md), [PRD §19.3](../../docs/PRD.md)).
- The display-only `CalendarPresenter(system, locale)` — the single place a `CalendarDate` becomes localized text — converting via pure-Dart, offline, BSD-licensed packages: `shamsi_date` (Jalālī, default for `fa`), `hijri` (Umm al-Qurā), `intl`'s `DateFormat` for Gregorian; with month name/era from the calendar package and the numeral remap applied **downstream** of conversion ([07 §4](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- The `CalendarSystem` enum (`jalali`, `hijriUmmAlQura`, `gregorian`) as the conversion contract an explicit Settings value selects (defaulted Jalālī for `fa`, never inferred from locale) ([07 §4](../../docs/engineering/07-dates-calendars-and-correctness.md), [PRD §13.3](../../docs/PRD.md)).
- Locale-numeral rendering on dates: remap digits downstream of conversion to Extended Arabic-Indic (`fa`/`ckb`) and Arabic-Indic (`ar`) via `intl` `NumberFormat`; never let a calendar package's Latin digits reach the UI ([07 §4](../../docs/engineering/07-dates-calendars-and-correctness.md), [PRD §13.3](../../docs/PRD.md)).
- Hijri honesty: render Hijri as **Umm al-Qurā**, range-guarded with a graceful Gregorian fallback (never an exception), with the standing one-line civil-approximation note and no observance/deadline keyed off a Hijri date being exact ([07 §6](../../docs/engineering/07-dates-calendars-and-correctness.md), [PRD R2](../../docs/PRD.md)).
- The full date-correctness test matrix as a release-gate suite: T1–T10 (DST-immune `addDays`/`daysUntil`; clamp ≤ ceiling under `glados`; schedule byte-identical across `TZ=Asia/Tehran`/`Pacific/Kiritimati`/`UTC` and across a DST-change date; multi-decade Jalālī and in-range Hijri identity round-trip sweeps with Gregorian fallback; per-locale numerals with no ASCII; a documented Umm al-Qurā reference pair; a 23:00-local review landing on the local day) ([07 §7](../../docs/engineering/07-dates-calendars-and-correctness.md), [PRD §20 gate 5](../../docs/PRD.md)).

### Out of scope

- The SR curve, interval inversion, S/D update, tracks, the trust clamp *math*, and the engine golden vectors that *consume* `CalendarDate` and the injected `today` → **E04 scheduling-engine** (the engine calls this type `SerialDay`; same type).
- How `epochDay` is physically written/read in one Drift transaction, the `review_log` UTC-instant column, and the at-rest schema → **E03 models-and-persistence**.
- The full bidi isolation (FSI/PDI), the ARB string pipeline, RTL widget mirroring, and the in-Settings calendar/numeral/term-set *picker UI* → **E09 localization-rtl-foundation** and the Settings surface in **E16 settings-profiles-teacher** (this epic exposes the `CalendarSystem` contract they select; it builds no picker).
- The numeral/calendar Mihrab display *components* (page-card date chips, the `numberFormatFor(locale)` widget path) → **E10 mihrab-component-library**.
- Scheduling and firing the local daily reminder that keys off the local civil day → **E18 reminders** (this epic owns only the civil-day the reminder keys off).
- Registering the Hijri honesty note as a graded CLAIMS row and rendering it on the science screen → **E19 science-screen-and-claims** (this epic ships the caveat copy slot; the claim is graded there).

## Dependencies

### Depends on

- **E01 repo-scaffold-and-ci** — the pub workspace, the pure-Dart `engine/` package boundary, the banned-import / no-network CI grep gates (so `DateTime.now()`, `timezone`/IANA, and calendar packages are provably kept out of `engine/`), and the `dart test` / `flutter test` runners and golden-CI job this epic's matrix plugs into.

### Enables

- **E03 models-and-persistence** — maps `CalendarDate.epochDay` to the `INTEGER` `due_at`/`last_review_day` columns and stores `review_log` instants UTC.
- **E04 scheduling-engine** — consumes `CalendarDate` as its only date type (`SerialDay`) and the injected `today`; the trust-clamp and interval math is built on this epic's integer primitives.
- **E07 app-shell-walking-skeleton** — wires the `todayProvider` at the composition root and the `civilDayOf` edge conversion when a review is handed to the engine.
- **E09 localization-rtl-foundation, E10 mihrab-component-library** — render dates through `CalendarPresenter`; numerals bind to the active locale.
- **E16 settings-profiles-teacher** — the calendar/numeral pickers select the `CalendarSystem` contract this epic defines.
- **E18 reminders** — the local reminder keys off this epic's local civil day.
- **E19 science-screen-and-claims** — grades and surfaces the Hijri honesty note this epic emits.

## Foundation inputs

| Input | Where (doc/skill) | What this epic takes |
|---|---|---|
| Value type & integer math | docs/engineering/07-dates-calendars-and-correctness.md §1–§2 | The `CalendarDate` shape (`epochDay`, `(y,m,d)` derived, `addDays`/`daysUntil`), the pure `ymd` calculator as the one permitted `DateTime` use, and the no-`Duration`/no-`difference(...).inDays`/no-leap rule for every scheduling quantity |
| Instant vs civil day | docs/engineering/07-dates-calendars-and-correctness.md §3 | Which fields are instants (UTC `DateTime`) vs civil days (`epochDay`), and the single `.toLocal()` boundary conversion `civilDayOf` |
| Injected "today" | docs/engineering/07-dates-calendars-and-correctness.md §5; docs/PRD.md §19.3 | `todayFor(now)` + `todayProvider`, the read-the-clock-once-at-the-edge rule, the single-zone (no `timezone`/IANA) decision, the no-mid-session-rollover rule |
| Display-only calendars | docs/engineering/07-dates-calendars-and-correctness.md §4; docs/PRD.md §13.3 | The one-`CalendarPresenter` boundary, the `CalendarSystem` enum, `shamsi_date`/`hijri`/`intl` package roles, the explicit-calendar (never inferred) rule, the downstream-numeral remap |
| Hijri honesty | docs/engineering/07-dates-calendars-and-correctness.md §6; docs/PRD.md R2 | The Umm al-Qurā label + standing civil-approximation note, the range-guard Gregorian fallback, the no-observance-promise and sect-neutral framing |
| Correctness gate | docs/engineering/07-dates-calendars-and-correctness.md §7; docs/PRD.md §20 gate 5 | The ten properties (T1–T10), the run-under-DST-zones requirement, the independent-published-oracle rule for reference pairs |
| Calendars skill | .claude/skills/domain-calendars-and-hifzdate/SKILL.md | The 12 canonical rules + the Do/Don't and Checklist that gate every date change; the `template.dart` scaffold and `references.md` section map |
| RTL & numerals on dates | .claude/skills/eng-rtl-and-bidi-layout/SKILL.md | The locale-numeral digit-block rules and the rendering (not converting) of a converted date in chrome — the display half this epic feeds |
| Test harness | .claude/skills/eng-write-dart-test/SKILL.md | `package:test` for the pure engine (no `flutter_test`), frozen golden-vector rows to `closeTo(_, 1e-6)`, `glados` properties, the throwing-`HttpOverrides` offline guard, the pinned-OS golden CI tagging |
| Determinism mandate | docs/PRD.md §7.12, §19.3 | "Identical inputs → identical schedule"; no wall-clock inside the engine — the property the injected-`today` design exists to protect |

## Deliverables

- [ ] `CalendarDate` value type in `engine/`: immutable, dependency-free, `epochDay` int, `ymd` factory, `addDays`/`daysUntil`/`isBefore`/`isAfter`/`compareTo`/`==`/`hashCode`/`toString`, with `///` API docs and unit coverage.
- [ ] The integer day-math primitives (`elapsedDays`, `nextDue`, ceiling-add, catch-up window enumeration) expressed as `addDays`/`daysUntil` only, with the engine-quantity table encoded as tests.
- [ ] `civilDayOf(instant)` app-edge helper converting a UTC instant to a civil `CalendarDate` once via `.toLocal()`.
- [ ] `todayFor(now)` edge function and the `todayProvider`, with a test-overridable fixed-date double.
- [ ] `CalendarSystem` enum and `CalendarPresenter(system, locale)` — the single `CalendarDate`→localized-text boundary — wired to `shamsi_date`, `hijri`, and `intl`.
- [ ] The downstream locale-numeral remap (Extended Arabic-Indic for `fa`/`ckb`, Arabic-Indic for `ar`) applied after conversion, with no ASCII digits reaching a rendered date.
- [ ] Hijri Umm al-Qurā rendering with the range-guard Gregorian fallback and the standing civil-approximation caveat slot.
- [ ] The date-correctness test suite T1–T10 (DST/timezone, multi-decade Jalālī + in-range Hijri round-trip sweeps, numerals, reference pair, local-day boundary) running in CI as a release gate.
- [ ] The pinned `shamsi_date` / `hijri` / `intl` dependencies declared at the display layer only — provably absent from `engine/` (CI banned-import gate green); the throwing-`HttpOverrides` offline guard asserts no date path touches the network.

## Definition of Done

- [ ] **Offline / no-network:** both calendar packages are bundled pure Dart; a throwing `HttpOverrides` in the test bootstrap proves no date or calendar path opens a socket; the no-network CI gate stays green ([PRD C1, §19.3](../../docs/PRD.md)).
- [ ] **No-AI / no-audio:** nothing in this epic uses ML, recognition, or a microphone — it is pure arithmetic and table conversion ([PRD C2](../../docs/PRD.md)).
- [ ] **Text fidelity untouched:** this epic renders no Quran glyphs and imports no muṣḥaf asset; date rendering stops at the chrome boundary and never reaches the immutable glyph layer ([PRD R1](../../docs/PRD.md)).
- [ ] **Engine purity:** `CalendarDate` and the integer math are dependency-free in `engine/`; the CI banned-import grep proves `hijri`/`shamsi_date`/`intl`/`timezone`/`DateTime.now()` are unimportable there; the only `DateTime` use in `CalendarDate` is the pure `ymd` calculator ([07 §1](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- [ ] **Determinism:** the engine reads no clock — "today" is injected via `todayProvider`; the schedule is byte-identical across `TZ=Asia/Tehran`/`Pacific/Kiritimati`/`UTC` and across a DST-change date, asserted by T4/T5 ([PRD §7.12, §19.3](../../docs/PRD.md), [07 §7](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- [ ] **RTL + fa/ckb/ar localization:** dates render through `CalendarPresenter` with per-locale numerals — Extended Arabic-Indic for `fa`/`ckb`, Arabic-Indic for `ar` — and no ASCII digits leak; the calendar is an explicit `CalendarSystem` value (Jalālī default for `fa`), never inferred from locale; T8 is green ([PRD §13.3](../../docs/PRD.md), [07 §4](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- [ ] **Accessibility:** the presenter emits screen-reader-safe localized strings (digits and calendar match the visible label; no raw ASCII to be misread); the numeral/date output is the same string a `Semantics` label consumes downstream ([PRD §18](../../docs/PRD.md)).
- [ ] **Sect-neutral adab:** Hijri is labelled **Umm al-Qurā** with the standing one-line civil-approximation caveat; no deadline, reminder, or guarantee keys off a Hijri date being exact; no fiqh ruling, no sighting claim, no single-region offset baked in as default ([PRD R2](../../docs/PRD.md), [07 §6](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- [ ] **No gamification:** no streak, score, or "behind"/"overdue" date framing is introduced anywhere in this epic ([PRD R3, C6](../../docs/PRD.md)).
- [ ] **Tests:** the full T1–T10 matrix is green, run under DST zones (never green only under `TZ=UTC`); reference pairs come from an independently published Umm al-Qurā / Jalālī conversion, never the library asserting against itself; a red date vector blocks release ([07 §7](../../docs/engineering/07-dates-calendars-and-correctness.md), [PRD §20 gate 5](../../docs/PRD.md)).

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E02-T01 | [CalendarDate value type in engine/ with DST-immune addDays/daysUntil (test-first)](E02-T01-calendardate-value-type.md) | M | E01 |
| E02-T02 | [Integer day-math primitives: elapsedDays, nextDue, ceiling-add, catch-up window](E02-T02-integer-day-math-primitives.md) | S | E02-T01 |
| E02-T03 | [Instant-vs-civil-day boundary: civilDayOf with single .toLocal() conversion](E02-T03-instant-vs-civil-day-boundary.md) | S | E02-T01 |
| E02-T04 | [Injected "today": todayFor edge function + todayProvider with fixed-date override](E02-T04-injected-today-provider.md) | S | E02-T01, E02-T03 |
| E02-T05 | [CalendarSystem enum + CalendarPresenter Gregorian/Jalālī/Hijri conversion boundary](E02-T05-calendar-presenter-conversion.md) | M | E02-T01 |
| E02-T06 | [Downstream locale-numeral remap on dates (Extended/Arabic-Indic, no ASCII)](E02-T06-locale-numeral-remap.md) | S | E02-T05 |
| E02-T07 | [Hijri Umm al-Qurā honesty: range-guard Gregorian fallback + civil-approximation caveat](E02-T07-hijri-honesty-fallback.md) | M | E02-T05 |
| E02-T08 | [DST/timezone correctness matrix T1–T5: addDays/daysUntil + schedule zone-independence](E02-T08-dst-timezone-matrix.md) | M | E02-T02, E02-T04 |
| E02-T09 | [Multi-decade round-trip sweep T6/T7 + reference-pair T9 (independent oracle)](E02-T09-roundtrip-sweep-reference.md) | M | E02-T05, E02-T07 |
| E02-T10 | [Numeral + local-day boundary vectors T8/T10 and the date-gate CI wiring](E02-T10-numeral-local-day-gate.md) | S | E02-T06, E02-T08 |

## Risks

- **A `DateTime` or a `Duration` sneaks into a scheduling path.** A single `lastReview.add(Duration(days: n))` reintroduces the DST off-by-one the whole epic exists to remove. *Mitigation:* `CalendarDate`'s only `DateTime` use is the pure `ymd` calculator; the CI banned-import grep keeps `DateTime.now()`/`timezone`/calendar packages out of `engine/` (E01 gate); T1/T2 assert `addDays`/`daysUntil` are exactly ±epochDay across a real spring-forward week.
- **A green suite under `TZ=UTC` proves nothing.** The bug class is invisible in a no-DST zone and fails silently on a Tehran phone. *Mitigation:* T4/T5 run under `TZ=Asia/Tehran`/`Pacific/Kiritimati`/`UTC` and across a DST-change date explicitly; the gate is never considered green from a UTC-only run ([07 §7](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- **A calendar package's Latin digits leak to the UI.** The conversion libraries emit ASCII digits; concatenating them into an RTL string is a localization defect. *Mitigation:* numerals are remapped strictly downstream of conversion; T8 formats a known date in `fa`/`ckb`/`ar` and asserts the correct digit block with zero ASCII digits.
- **The Hijri table goes out of range and throws on a screen.** Umm al-Qurā data is tabulated, not open-ended. *Mitigation:* every conversion is range-guarded and falls back to a Gregorian label rather than throwing; T7 asserts identity in range and graceful fallback out of range; a date label never crashes a screen ([07 §6](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- **A reference vector is self-asserting.** A library checked against its own output proves only internal consistency. *Mitigation:* T9 takes its Gregorian↔Hijri (and Jalālī) reference pairs from an independently published conversion, with the sighting caveat carried in copy.
- **The calendar is silently inferred from locale.** A Persian speaker may want Hijri; an Arabic speaker may want Gregorian. *Mitigation:* `CalendarSystem` is an explicit value (defaulted, never switched off `Locale.current`); the presenter takes the system as a parameter, and a test asserts each locale can render each calendar.
- **A long session flips days mid-recitation.** A midnight rollover could re-shuffle an open Today screen under the user's fingers. *Mitigation:* "today" is captured once at session start via `todayProvider`; the next session recomputes it; no scheduling path reads the clock again ([07 §5](../../docs/engineering/07-dates-calendars-and-correctness.md)).

## References

- docs/PRD.md — §7.6 (cycle ceiling / trust clamp), §7.12 (engine invariants — identical inputs → identical schedule), §10.3 (timestamps stored UTC, displayed in locale calendar/numerals), §13.3 (numerals & calendars), §14 (local reminder keys off the local day), §19.3 (determinism & offline guarantees), §20 gate 5 (localization/calendar correctness gate), R1 (text fidelity), R2 (riwāyah/sect-neutrality), R3 & C6 (no gamification), C1 (offline), C2 (no AI/audio), C4 (fa/ckb/ar RTL)
- docs/engineering/07-dates-calendars-and-correctness.md — §1 (the `CalendarDate` value type), §2 (integer day arithmetic), §3 (instant vs civil day), §4 (display-only calendars behind one presenter), §5 (injected "today"; single zone), §6 (Hijri honesty), §7 (the correctness test matrix — release gate)
- .claude/skills/domain-calendars-and-hifzdate/SKILL.md — the 12 canonical rules, Do/Don't table, Checklist, `template.dart`, `references.md`
- .claude/skills/eng-rtl-and-bidi-layout/SKILL.md — locale-numeral digit blocks; rendering a converted date in RTL chrome
- .claude/skills/eng-write-dart-test/SKILL.md — `package:test` for the pure engine, frozen golden vectors, `glados` properties, the throwing-`HttpOverrides` offline guard, pinned-OS golden CI tagging

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
