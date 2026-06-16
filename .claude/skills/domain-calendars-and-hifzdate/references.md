# references — domain-calendars-and-hifzdate

The precise governing sections. Reference these by number in code review and commit messages; never re-derive an epoch, a supported range, or a conversion here.

## Primary spec

`docs/engineering/07-dates-calendars-and-correctness.md`

- **§1 The `CalendarDate` value type** — an immutable, dependency-free value type in `engine/` holding one integer `epochDay` (days since `1970-01-01`, proleptic-Gregorian), `(y,m,d)` derived on demand; the *only* date the engine imports/constructs/returns; the Dart fix for the missing `LocalDate`. The one permitted `DateTime` use is the pure `CalendarDate.ymd` `(y,m,d) ↔ epochDay` calculator (`DateTime.utc` / `fromMillisecondsSinceEpoch(isUtc: true)`), which reads no clock. Take: the value type, its `addDays`/`daysUntil`/`compareTo`, and the refusal of a `DateTime` (or a local-midnight stand-in) inside the engine.
- **§2 All interval, cycle, and ceiling math is integer day arithmetic** — `elapsed_days`, `interval(S,R)`→due, the cycle ceiling, catch-up, peak-smoothing are `addDays`/`daysUntil` integers; day-distance is calendar-invariant, which is *why* the calendar can be display-only. The engine-quantity table maps each quantity to its integer primitive and the `DateTime`/`Duration` form it must never use. Take: the no-`Duration`, no-`difference(...).inDays`, no-month/leap rule and the primitive for each quantity.
- **§3 Two date kinds, stored differently: instant vs civil day** — event instants (`reviewed_at`, `last_review_at`) are UTC `DateTime` (exact *sanad* moment, append-only); scheduling days (`due_at`, ceiling, `last_review_day`, "today") are the `CalendarDate` `epochDay` integer; the field-kind table is the authority. `civilDayOf(instant)` converts once at the edge with `.toLocal()` so "tonight" is tonight's local date. Take: which field is which kind, the single boundary conversion, and the refusal to store a day as a local-midnight `DateTime`.
- **§4 Hijri / Jalālī / Gregorian are display-only, behind one presentation helper** — `CalendarPresenter(system, locale)` is the single place a `CalendarDate` becomes text, using pure-Dart offline packages `shamsi_date` (Jalālī) and `hijri` (Umm al-Qurā) plus `intl` for Gregorian; `CalendarSystem` is an explicit Settings value (Jalālī default for `fa`), never inferred from locale; numerals are remapped *downstream* of conversion (month name/era come from the calendar package, not `intl`'s Gregorian-only `DateFormat`); Hijri conversions are range-guarded with a Gregorian fallback. Take: the one-presenter boundary, the explicit-calendar rule, and the downstream-numeral rule.
- **§5 "Today" is injected; the device's local zone is the only zone we read** — `todayFor(now)` reads the clock once at the edge via `.toLocal()`; a single `todayProvider` threads the `CalendarDate` through the session; the engine receives `ref.read(todayProvider)`, never `DateTime.now()`; tests inject a fixed date. No `timezone`/IANA dependency (nothing syncs, no cross-zone conversion); the local reminder keys off the local civil day; a midnight rollover never re-shuffles an open session. Take: the injected-today wiring, the single-zone rule, and the dependency we deliberately refuse.
- **§6 Hijri honesty: a civil approximation, never a religious authority** — Hijri is shown as **Umm al-Qurā**, labelled, with a standing one-line note that an observance's start may differ by a day by sighting; no deadline/reminder/guarantee keys off a Hijri date being exact; out-of-range conversion falls back to Gregorian; any per-region `adjustments` offset is a user/community act, never an app default; madhhab/sect-neutral, no fiqh ruling. Take: the label-and-caveat rule, the no-observance-promise rule, and the neutral framing.
- **§7 The correctness test matrix (release gate)** — T1/T2 DST-immune `addDays`/`daysUntil`; T3 clamp ≤ ceiling (`glados`); T4/T5 schedule byte-identical across `TZ=Asia/Tehran`/`Pacific/Kiritimati`/`UTC` and across a DST-change date; T6/T7 Jalālī + in-range Hijri identity round-trips with graceful Gregorian fallback; T8 per-locale numerals (no ASCII); T9 a documented Umm al-Qurā reference pair; T10 a 23:00-local review lands on the local day. Vectors come from an independent published source, never the library asserting against itself; never green only under `TZ=UTC`. Take: the ten properties to pin and the independent-oracle rule.

## PRD anchors

- `docs/PRD.md` **§13.3 Numerals & calendars** — the three supported calendars (Hijri Umm al-Qurā, Solar-Hijri/Jalālī default for `fa` and offered for Kurdish, Gregorian), user-selectable; "next due / last reviewed" render in the chosen calendar and numerals; locale digit sets (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) via `intl` `NumberFormat`; never concatenate raw ASCII digits; week start follows locale. Take: the calendar list, the numeral mapping, and the no-ASCII-digits rule — never invent a numeral set.
- `docs/PRD.md` **§7.6, §7.12** — the cycle ceiling and the "identical inputs → identical schedule" invariant the date layer must not perturb; a `due_at` that drifts by a day across DST is a silent ceiling breach. Take: why date correctness is load-bearing, not cosmetic.
- `docs/PRD.md` **§10.3** — all timestamps stored UTC, displayed in the locale's calendar/numerals; the split this skill implements as two columns of two kinds. Take: the storage-UTC / display-local mandate.
- `docs/PRD.md` **§20 gate 5** — date/calendar/RTL correctness is a release gate; a failing round-trip or non-deterministic schedule blocks the release exactly as a missing ARB key does. Take: that a red date vector ships nothing.
- `docs/PRD.md` **R2** — sect/madhhab-neutrality; the app surfaces a calendar tool, never a sighting ruling. Take: the framing constraint on every Hijri surface.

## Sibling spec it borders

- `docs/engineering/06-scheduling-engine.md` **§1, §8** — the engine consumes this type as `SerialDay` and requires it pure (no clock, no I/O); "elapsed days" is integer subtraction immune to the DST `+1 day ≠ +24h` bug; determinism depends on the injected `today`. Take: that `SerialDay` and `CalendarDate` are one type, and what the engine demands of it.

## CLAIMS this skill surfaces

`docs/science/CLAIMS.md` — the Hijri honesty note ("a civil Umm al-Qurā approximation; an observance's start may differ by a day by sighting") is a user-facing factual claim and must be a graded row here before it ships. Do not invent an id or a citation; register first via **domain-claims-register-and-science-screen**.

## Sibling skills

- **domain-scheduling-engine-rules** — the SR curve, interval, S/D update, tracks, and the trust clamp that consume `CalendarDate` and the injected `today` (the engine calls this type `SerialDay`).
- **eng-persistence-single-write-path** — the one-transaction Drift/SQLite write that persists `due_at` as `epochDay` `INTEGER` and the append-only UTC `review_log`.
- **ui-rtl-localization** — full bidi isolation (FSI/PDI), ARB strings, RTL widget mirroring, and the in-Settings calendar picker that selects `CalendarSystem`.
- **domain-claims-register-and-science-screen** — register the Hijri honesty note (and any other user-facing date claim) before it ships.
- **domain-mushaf-text-integrity** — the immutable muṣḥaf glyph rendering this skill never touches.
- **eng-write-dart-test** — the `package:test` golden-vector + `glados` property-test harness for the §7 matrix.
- **eng-offline-ci-gates** — the banned-import grep gate keeping `DateTime.now()`, the `timezone`/IANA package, and the calendar packages out of `engine/`.
