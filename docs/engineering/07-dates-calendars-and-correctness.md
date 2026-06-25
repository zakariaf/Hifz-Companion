# 07 — Dates, Calendars & Correctness

This document specifies how Hifz Companion represents, computes with, and displays dates — the single most error-prone surface in a scheduling app whose entire promise is "a page is re-recited at least once per chosen cycle, no matter what" ([PRD §7.6](../PRD.md)). It defines the `CalendarDate` value type that fills the gap Dart's `DateTime` leaves; the rule that **all** interval, cycle, and ceiling math is integer day arithmetic; the strict separation between *event instants* (stored UTC) and *scheduling days* (stored as `CalendarDate`); the display-only boundary across which Hijri (Umm al-Qurā) / Solar-Hijri-Jalālī / Gregorian rendering happens; and the DST/timezone test matrix that pins it all down. It applies the *Decision log: Dates, calendars & correctness* entry (README decision 7) and is grounded in the evidence dossier [research/calendars-i18n-hijri-jalali.md](research/calendars-i18n-hijri-jalali.md).

The boundaries are deliberate. The pure scheduling math that *consumes* these dates — the curve, the interval, the trust clamp — lives in the engine and is owned by [06-scheduling-engine.md](06-scheduling-engine.md); this doc owns the **date type the engine reasons in** and the **calendar rendering the engine never touches**. How a date is physically stored in SQLite is owned by [05-persistence-and-encryption.md](05-persistence-and-encryption.md), which defers the *meaning* of a stored "due date" to here. The locale numeral mapping, bidi isolation, and the in-Settings calendar picker UI are owned by [12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md); this doc owns only the calendar *conversion* feeding them. The two date kinds — instant and civil day — are the spine of all four docs.

One framing rule governs everything below, from the README's outranking rules and [PRD §7.6, §7.12, §10.3](../PRD.md): **a scheduling day is a fact the user asserted, not a moment on a clock.** When a ḥāfiẓ revises a page "today" and the engine says it is "due in 7 days," that 7 is seven calendar days — identical in Gregorian, Jalālī, and Hijri — and must never be perturbed by a daylight-saving transition, a timezone, or a calendar's leap rule. A `due_at` that drifts by a day because the clock sprang forward is not a cosmetic glitch; it is a silent breach of the cycle ceiling, the one invariant the whole product exists to keep ([PRD §7.12](../PRD.md)).

## At a glance

| Concern | Decision |
|---|---|
| Scheduling unit | **`CalendarDate`** — an immutable proleptic-Gregorian serial-day value type; the *only* date the engine sees ([Dart: DateTime](https://api.dart.dev/dart-core/DateTime-class.html)) |
| Interval / cycle / ceiling math | **Integer day arithmetic only** — day-counts are calendar-invariant; no leap-year or month logic ever runs in the engine ([Wikipedia: ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)) |
| Event instants (`reviewed_at`, `last_review_at`) | **UTC `DateTime`** — physical time, stored canonical ([PRD §10.3](../PRD.md); [Baeldung: Instant vs LocalDateTime](https://www.baeldung.com/java-instant-vs-localdatetime)) |
| Scheduling days (`due_at`, ceiling, "today") | **`CalendarDate`** — civil day, never a local-midnight instant ([Dart: DateTime](https://api.dart.dev/dart-core/DateTime-class.html)) |
| "Today" | **Injected** at the app edge; computed once from the device's local civil day; the engine has no `DateTime.now()` ([PRD §19.3](../PRD.md)) |
| Hijri | **Umm al-Qurā** via pure-Dart `hijri` (BSD-2), display-only, with a standing honesty caveat ([pub.dev: hijri](https://pub.dev/packages/hijri)) |
| Jalālī | **Solar Hijri** via pure-Dart `shamsi_date` (BSD-3), display-only; default for `fa` ([pub.dev: shamsi_date](https://pub.dev/packages/shamsi_date)) |
| Calendar choice | **Explicit user setting** (Jalālī / Hijri / Gregorian), not silently inferred from locale ([PRD §13.3](../PRD.md)) |
| Numerals | Re-mapped **downstream** of calendar conversion to the locale digit set ([PRD §13.3](../PRD.md)) |
| `timezone` / IANA package | **Not in the engine or the `CalendarDate` core** — the device's own local zone names "today" and the engine never sees a zone; taken **only at the app-notification edge** (E18, decision 14) to hand `flutter_local_notifications`' `zonedSchedule` a DST-correct local `TZDateTime` for the §14 daily reminder ([pub.dev: timezone](https://pub.dev/packages/timezone)) |

---

## 1. The `CalendarDate` value type

### Decision

Scheduling reasons over a project-defined **`CalendarDate`** — an immutable value type holding a single integer: the count of days since a fixed proleptic-Gregorian epoch (`1970-01-01`, the Unix-epoch date), with `(year, month, day)` derived on demand. It is the **only** date type the pure engine ([06-scheduling-engine.md](06-scheduling-engine.md)) imports, constructs, or returns. A Dart `DateTime` never enters the engine, and a `CalendarDate` is never silently widened into a `DateTime` instant inside scheduling code (*Decision log: Dates, calendars & correctness*). This is the Dart fix for the missing `LocalDate`.

### Rationale

- **Dart has no date-only type.** A `DateTime` is "an instant in time, such as July 20, 1969, 8:18pm GMT," storing only `microsecondsSinceEpoch` plus an `isUtc` flag ([Dart: DateTime](https://api.dart.dev/dart-core/DateTime-class.html)). There is no civil-`LocalDate` analogue in `dart:core`. A bare calendar day like `2026-06-16` cannot be stored as a `DateTime` without *choosing a clock instant* for it — local midnight? UTC midnight? — and that choice is exactly where the off-by-one bugs live (§2). Languages that took date correctness seriously drew this boundary explicitly: JSR-310 and `kotlinx-datetime` keep "a clear boundary between the physical time of an instant and the local, time-zone-dependent civil time" and "intentionally avoid entities that mix both" ([kotlinx-datetime](https://github.com/Kotlin/kotlinx-datetime)). Dart did not put that line in its core type, so we draw it ourselves.
- **A serial-day integer makes day-distance trivial and exact.** ISO 8601's `full-date` (`YYYY-MM-DD`) is defined on the proleptic Gregorian calendar and carries no time, zone, or locale ([Wikipedia: ISO 8601](https://en.wikipedia.org/wiki/ISO_8601); [Wikipedia: Proleptic Gregorian calendar](https://en.wikipedia.org/wiki/Proleptic_Gregorian_calendar)). Representing the date as the integer count of days from a fixed epoch turns "days between" and "add N days" into plain integer subtraction and addition — no `Duration`, no clock, no DST surface (§2). The engine's `elapsed_days` and `interval(S, R)` ([PRD §7.3](../PRD.md)) are integers by construction.
- **It keeps the engine pure and its goldens reproducible.** Because `CalendarDate` carries no zone, no clock, and no calendar object, feeding the same injected "today" and the same card state yields the same schedule on every device in every timezone — the [PRD §7.12, §19.3](../PRD.md) "identical inputs → identical schedule" guarantee, testable on `dart test` with no widget binding ([06-scheduling-engine.md](06-scheduling-engine.md), [11-testing-strategy.md](11-testing-strategy.md)).

### Specification

`CalendarDate` is a small, dependency-free value type in the engine package. The serial-day arithmetic uses the standard reversible algorithm (no leap tables): `DateTime.utc(y, m, d)` for the forward map and `DateTime.fromMillisecondsSinceEpoch(..., isUtc: true)` for the inverse — both used **only at construction**, as a deterministic pure function of `(y, m, d)`, never as a clock read.

```dart
// /engine — zero I/O, no Flutter, no DateTime.now(), no calendar package.

/// A civil calendar day on the proleptic-Gregorian calendar.
/// Stored as the integer count of days since 1970-01-01 (the Unix-epoch date).
/// This is NOT an instant: it has no time, no zone, no DST surface.
@immutable
class CalendarDate implements Comparable<CalendarDate> {
  /// Days since 1970-01-01. Negative for earlier dates.
  final int epochDay;
  const CalendarDate._(this.epochDay);

  /// Build from a (year, month, day) triple. Uses DateTime.utc as a PURE
  /// proleptic-Gregorian calculator — no clock is read, no zone is involved.
  factory CalendarDate.ymd(int year, int month, int day) {
    final utcMidnight = DateTime.utc(year, month, day);
    return CalendarDate._(utcMidnight.millisecondsSinceEpoch ~/ _msPerDay);
  }

  static const int _msPerDay = 86400000; // 24 * 60 * 60 * 1000

  int get _utcMs => epochDay * _msPerDay;
  int get year  => _asUtc.year;
  int get month => _asUtc.month;
  int get day   => _asUtc.day;
  DateTime get _asUtc =>
      DateTime.fromMillisecondsSinceEpoch(_utcMs, isUtc: true);

  /// Add or subtract whole calendar days — pure integer math, DST-immune.
  CalendarDate addDays(int days) => CalendarDate._(epochDay + days);

  /// Calendar days from `this` to `other` (signed). Exact, no Duration.
  int daysUntil(CalendarDate other) => other.epochDay - this.epochDay;

  bool isBefore(CalendarDate o) => epochDay <  o.epochDay;
  bool isAfter (CalendarDate o) => epochDay >  o.epochDay;

  @override
  int compareTo(CalendarDate o) => epochDay.compareTo(o.epochDay);
  @override
  bool operator ==(Object o) => o is CalendarDate && o.epochDay == epochDay;
  @override
  int get hashCode => epochDay.hashCode;

  /// ISO 8601 full-date, for logs/backup — never localized here.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
```

The trust clamp and every other scheduling computation operate on this type and nothing else. The clamp from [PRD §7.6](../PRD.md) becomes pure integer min:

```dart
// /engine — every date here is a CalendarDate; all math is integer days.
CalendarDate trustClamp(Card card, CalendarDate today) {
  final idealDue   = today.addDays(intervalDays(card.s, targetR(card)));
  final ceilingDue = today.addDays(cycleCeilingDays(card, cycle));
  // SR may only make a page MORE frequent — never later than the ceiling.
  return idealDue.isBefore(ceilingDue) ? idealDue : ceilingDue;
}
```

The DAO layer maps `CalendarDate.epochDay` to a SQLite `INTEGER` column and back ([05-persistence-and-encryption.md](05-persistence-and-encryption.md)); the integer *is* the stored representation, so a `due_at` round-trips through the database with bit-for-bit fidelity and no parsing.

### Pitfalls / what we refuse

- **We refuse a `DateTime` inside the engine.** A CI banned-import/lint gate forbids `dart:core` `DateTime.now()` and any `DateTime` field in `/engine` scheduling types (the same mechanism that bans networking imports — *Decision log: No networking beyond asset download*). The only `DateTime` use permitted in `CalendarDate` is the pure `(y,m,d) ↔ epochDay` calculator above, which reads no clock.
- **We refuse local-midnight as a stand-in for a date.** Constructing `DateTime(y, m, d)` (local, not `.utc`) to mean "that day" reintroduces the zone the type exists to remove; `CalendarDate.ymd` uses `DateTime.utc` purely as arithmetic, and the engine never converts a `CalendarDate` back to a *local* instant.
- **We refuse to let a calendar object reach the engine.** No `hijri`, `shamsi_date`, or `intl` symbol is importable from `/engine`; calendars are a display concern (§4) and the engine is calendar-agnostic ([PRD §19.3](../PRD.md)).

---

## 2. All interval, cycle, and ceiling math is integer day arithmetic

### Decision

Every quantity the scheduler computes that has the dimension of *time* — `elapsed_days`, `interval(S, R)`, the cycle ceiling, the catch-up re-spread, peak-smoothing nudges ([PRD §7.3, §7.6, §7.9](../PRD.md)) — is computed as **integer days** via `CalendarDate.addDays` / `daysUntil`. No `Duration`, no `DateTime.add`, no `DateTime.difference`, and no calendar month/leap logic ever participates in a scheduling computation (*Decision log: Dates, calendars & correctness*).

### Rationale

- **`Duration` arithmetic on a local instant is unsafe across DST.** Dart's own documentation warns that the difference between two `DateTime`s "is just the number of [microseconds] between the two points in time… the difference between two midnights in local time may be less than 24 hours times the number of days between them, if there is a daylight saving change in between" ([Dart: DateTime](https://api.dart.dev/dart-core/DateTime-class.html)). `add(Duration(days: 1))` on a local `DateTime` adds exactly 24 hours of *physical* time — which, across a spring-forward transition, lands on the wrong calendar day. For an app whose contract is "due every N days," a `due_at` computed by `Duration`-adding to a local instant is a latent off-by-one-day generator ([PRD §7.6](../PRD.md)).
- **Day-distance is calendar-invariant — so the calendar can be display-only.** Jalālī and Hijri differ from Gregorian only in *how a day is labelled*, not in how far apart two days are. A "due in 7 days" interval is seven days whether the user reads it in Jalālī, Hijri, or Gregorian ([Wikipedia: Solar Hijri calendar](https://en.wikipedia.org/wiki/Solar_Hijri_calendar)). Keeping all interval math in proleptic-Gregorian serial integers is therefore not a simplification that loses fidelity — it is *the* correct model, and it lets the rendered calendar affect only the label (§4).
- **Integer math is total and exact.** There is no rounding, no zone, no ambiguous "fall-back" hour, and no representable invalid value. `today.addDays(7)` is one integer addition; the result is a valid `CalendarDate` for any input. This is the property that makes the §7 test matrix pass by construction rather than by luck.

### Specification

The engine's day-math primitives, all pure and all integer:

| Engine quantity | Computed as | Never |
|---|---|---|
| `elapsed_days` (since last review) | `card.lastReviewDay.daysUntil(today)` | `DateTime.difference(...).inDays` (truncates across DST) |
| `interval(S, R)` → next due | `today.addDays(intervalDays)` | `lastReview.add(Duration(days: n))` |
| Cycle ceiling | `today.addDays(cycleCeilingDays(...))` | a `DateTime` plus a `Duration` |
| `due_at` | `min(idealDue, ceilingDue)` over `epochDay` | a clock comparison |
| Catch-up window | a sequence of `today.addDays(i)` | iterating wall-clock days |

```dart
// /engine — elapsed days are integer day-distance, not a truncated Duration.
int elapsedDays(Card card, CalendarDate today) =>
    card.lastReviewDay.daysUntil(today); // exact, DST-immune

// interval() returns an integer number of days (from the FSRS curve);
// it is converted to a due DATE by integer addition only.
CalendarDate nextDue(Card card, CalendarDate today) =>
    today.addDays(intervalDays(card.s, targetR(card)));
```

Where the engine needs the count of *physical* days between two stored instants (it almost never does — `elapsed_days` is derived from scheduling days), the conversion from a UTC instant to a `CalendarDate` happens **once, at the app edge**, by reading the instant's UTC `(y, m, d)` — not by truncating a `Duration`.

### Pitfalls / what we refuse

- **We refuse `DateTime.difference(...).inDays`.** It returns whole 24-hour spans, so two local midnights 1 calendar day apart across a DST boundary differ by `inDays == 0` (23 h) or `inDays == 0` rounding artifacts — a classic, documented off-by-one ([Dart: DateTime](https://api.dart.dev/dart-core/DateTime-class.html)). Day-distance is `daysUntil`, full stop.
- **We refuse `Duration(days: n)` for calendar offsets.** A `Duration` is physical time; "n calendar days later" is `addDays(n)` on a `CalendarDate`. The two agree only when no DST transition intervenes — i.e. exactly until they silently disagree on a user's device.
- **We refuse month/leap-year logic in the engine.** Cycles are expressed in days (7, 15, 30, 60 — [PRD §15.1](../PRD.md)), never "1 month"; there is no month-length branch in any scheduling path. A "monthly" cycle, if ever offered, is a fixed day count chosen at the display layer, not a calendar-month computation in the engine.

---

## 3. Two date kinds, stored differently: instant vs civil day

### Decision

The two date-shaped quantities the app persists are different in kind and are stored differently, per [PRD §10.3](../PRD.md): **event instants** — the wall-clock moment a review actually happened (`review_log.reviewed_at`, `card.last_review_at` as an instant) — are stored as **UTC `DateTime`**; **scheduling days** — `due_at`, the cycle ceiling, and the injected "today" — are stored as the **`CalendarDate` serial-day integer**. A scheduling day is never round-tripped through a local `DateTime` instant (*Decision log: Dates, calendars & correctness*; storage mechanics in [05-persistence-and-encryption.md](05-persistence-and-encryption.md)).

### Rationale

- **Physical time and civil time are different facts and must not be conflated.** An `Instant` is "a single moment in time in the UTC time zone" — the canonical machine-facing form for storage — whereas the `Local`-prefixed types are "not tied to any time zone" and represent "a possible event that occurs regardless of time zone," i.e. a calendar fact ([Baeldung: Instant vs LocalDateTime](https://www.baeldung.com/java-instant-vs-localdatetime)). "When did this review occur" is physical; "which day is this page due" is civil. Storing the second as the first invites a zone or DST change to shift the day (§2).
- **The PRD already mandates the split.** "All timestamps stored UTC; displayed in the locale's calendar/numerals" ([PRD §10.3](../PRD.md)) governs *instants*; "today is injected" and the engine reasons in *integer day counts* ([PRD §7.3, §19.3](../PRD.md)) govern *days*. Honouring both means two columns of two kinds, not one column doing double duty.
- **The audit trail needs the precise moment; the schedule needs the day.** `review_log` is the append-only *sanad*-respecting record ([PRD §10.3](../PRD.md), [05-persistence-and-encryption.md](05-persistence-and-encryption.md)); a teacher sign-off's exact instant is genuine evidence and is kept UTC-precise. The scheduler, by contrast, only ever asks "is this page due on or before today's date," which is a day comparison.

### Specification

| Field | Kind | Stored as | Column type | Rationale |
|---|---|---|---|---|
| `review_log.reviewed_at` | instant | UTC `DateTime` | `INTEGER` (µs since epoch, UTC) | exact moment of a *sanad* act ([PRD §10.3](../PRD.md)) |
| `card.last_review_at` (instant view) | instant | UTC `DateTime` | `INTEGER` | when the last review physically happened |
| `card.last_review_day` (engine view) | civil day | `CalendarDate` | `INTEGER` (`epochDay`) | the day the engine measures `elapsed_days` from |
| `card.due_at` | civil day | `CalendarDate` | `INTEGER` (`epochDay`) | next-due **ceiling**; a date, never an instant ([PRD §7.2](../PRD.md)) |
| cycle ceiling (derived) | civil day | `CalendarDate` | not stored | computed each review |
| injected "today" | civil day | `CalendarDate` | not stored | derived once at the app edge (§5) |

The conversion from a review's UTC instant to the `CalendarDate` the engine measures against happens **once**, at the boundary where a completed review is handed to the engine, using the user's *local* civil day (so "I revised this tonight" means tonight's local date, not tomorrow's UTC date):

```dart
// app edge (NOT the engine): turn a real local moment into a civil day.
CalendarDate civilDayOf(DateTime instant, {required DateTime localNow}) {
  final local = instant.toLocal();
  return CalendarDate.ymd(local.year, local.month, local.day);
}
```

After this single boundary conversion, the engine sees only `CalendarDate`s. The instant is still persisted UTC in `review_log` for the audit trail; the civil day is what drives scheduling.

### Pitfalls / what we refuse

- **We refuse to store a scheduling day as a local-midnight `DateTime`.** `due_at = DateTime(2026, 6, 23)` (local) silently bakes in the device's current zone; restore the backup on a device in another zone, or cross a DST boundary, and the "same" due date is now a different instant — and, at the rendering boundary, possibly a different *day*. `due_at` is an `epochDay` integer; there is no zone to drift.
- **We refuse to derive the civil day from a UTC `(y,m,d)` for "today."** "Today" is the user's *local* civil day, not UTC's — a review at 23:00 local in Tehran is today, even though it is already tomorrow in UTC. The boundary uses `.toLocal()` exactly once (§5); the engine then sees a pure day.
- **We refuse to mutate or recompute `review_log` instants.** They are append-only physical evidence ([PRD §10.3](../PRD.md)); a stored instant is never "normalized" after the fact.

---

## 4. Hijri / Jalālī / Gregorian are display-only, behind one presentation helper

### Decision

The three calendars the app must render — **Hijri (Umm al-Qurā)**, **Solar-Hijri/Jalālī**, and **Gregorian** ([PRD §13.3](../PRD.md)) — are produced **only at the display boundary**, by one presentation helper that maps a `CalendarDate` (plus the user's chosen calendar and locale) to a localized string. Conversion uses pure-Dart, BSD-licensed, offline packages: **`hijri`** (Umm al-Qurā) and **`shamsi_date`** (Jalālī); Gregorian needs no package. Views never construct a calendar object themselves; the engine never sees one (*Decision log: Dates, calendars & correctness*).

### Rationale

- **Both libraries are pure Dart, permissive, and bundle offline — satisfying C1.** `shamsi_date` is "a pure dart package" (v1.1.1, BSD-3-Clause, Null-Safe), exposing `Jalali`, `Gregorian`, and a common `Date`, with `toDateTime`, `fromDateTime`, `julianDayNumber`, `copy`, a `formatter`, month-length getters, and comparison operators; its algorithm is "based on [the] popular JavaScript library jalaali-js," and its valid range — `Gregorian(560,3,20)` to `Gregorian(3798,12,31)` — is effectively unbounded for our use ([pub.dev: shamsi_date](https://pub.dev/packages/shamsi_date)). `hijri` (v3.0.1, BSD-2-Clause, pure Dart) converts Gregorian↔Hijri using **Umm al-Qurā**, with `HijriCalendar.now()`, `fromDate(DateTime)`, `hijriToGregorian`, `hYear/hMonth/hDay`, `toFormat`, and `lengthOfMonth` ([pub.dev: hijri](https://pub.dev/packages/hijri)). Neither touches the network.
- **`intl` localizes numerals and bidi but does not render non-Gregorian calendars.** `intl`'s `DateFormat` is Gregorian-only; month *names*, era, and day-of-week for a Hijri/Jalālī date come from the calendar package, while `intl`'s `NumberFormat` and `BidiFormatter` handle locale digits and direction ([pub.dev: intl](https://pub.dev/packages/intl); [12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md)). So the calendar package and `intl` each own a different half of the rendered string, and the helper composes them.
- **One helper keeps the boundary auditable.** Collapsing all three calendars behind a single `CalendarPresenter` means there is exactly one place where a `CalendarDate` becomes human text — the display analogue of the engine being the one place a schedule is computed. A view that wants to show a date asks the presenter; it cannot reach a raw `HijriCalendar` or `Jalali`.

### Specification

The presenter takes a `CalendarDate`, the user's `CalendarSystem` choice, and the active locale; it converts, formats month/era from the calendar package, then re-maps digits to the locale numeral set **downstream** (§ below). Calendar choice is an **explicit Settings value** ([PRD §13.3, §15.2](../PRD.md)), not silently inferred from `Locale.current`; the `fa` default is Jalālī, and Hijri/Gregorian are offered to every locale.

```dart
// /features or /l10n — the ONLY place a CalendarDate becomes localized text.
enum CalendarSystem { jalali, hijriUmmAlQura, gregorian }

class CalendarPresenter {
  final CalendarSystem system;
  final Locale locale;
  const CalendarPresenter(this.system, this.locale);

  /// CalendarDate -> localized, locale-numeralled date label.
  String format(CalendarDate d) {
    final g = DateTime.utc(d.year, d.month, d.day); // pure (y,m,d), not a clock
    final latin = switch (system) {
      CalendarSystem.gregorian      => _gregorianLabel(g, locale), // intl DateFormat
      CalendarSystem.jalali         => _jalaliLabel(g),            // shamsi_date
      CalendarSystem.hijriUmmAlQura => _hijriLabel(g, locale),     // hijri.fromDate(...)
    };
    return toLocaleNumerals(latin, locale);          // downstream numeral remap (§ below)
  }

  String _jalaliLabel(DateTime g) {
    final f = Jalali.fromDateTime(g).formatter;       // shamsi_date DateFormatter
    return '${f.d} ${f.mN} ${f.yyyy}';                // day monthName year (Latin digits)
  }
}
```

**Numerals are remapped downstream of the calendar.** The calendar packages tend to emit **Latin digits** in their formatter output, but `fa`/`ckb` must show Extended Arabic-Indic (۰۱۲۳۴۵۶۷۸۹) and `ar` must show Arabic-Indic (٠١٢٣٤٥٦٧٨٩), and the app must "never concatenate raw ASCII digits into localized strings" ([PRD §13.3](../PRD.md)). So the helper converts the date *first*, then passes the numeric fields through a locale digit map (`NumberFormat`/explicit numbering-system) — the numeral transform sits **after** the calendar conversion, never inside it. The month *name* and era come from the calendar package's localized tables (`intl`'s `DateFormat` cannot supply them for Hijri/Jalālī); only the Gregorian path uses `intl`'s `DateFormat` directly. Full numeral and bidi mechanics are owned by [12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md).

**Hijri conversions are range-guarded and fail safe.** The Umm al-Qurā data underpinning the Dart Hijri family is tabulated, not open-ended — the comparable `hijri_calendar` fork documents a "Supported Gregorian date range validation (**1937–2076**)" ([pub.dev: hijri_calendar](https://pub.dev/documentation/hijri_calendar/latest/)), and the rigorous `hijridate` implementation covers **1343–1500 AH (1 Aug 1924 – 16 Nov 2077 CE)** ([dralshehri: hijridate](https://github.com/dralshehri/hijridate)). Every real due-date falls comfortably inside this, but a conversion call outside range falls back to a Gregorian label rather than throwing (and logs nothing off-device).

### Pitfalls / what we refuse

- **We refuse to infer the calendar from the locale.** A Persian-speaking user may want Hijri; an Arabic-speaking user may want Gregorian. The calendar is an explicit picker ([PRD §13.3](../PRD.md)), defaulted (Jalālī for `fa`) but never silently switched off `Locale.current`.
- **We refuse to let a calendar package's Latin digits leak to the UI.** Conversion is always followed by the locale numeral remap; a date that reaches a widget with ASCII digits is a localization defect caught by the §7 round-trip test and the RTL/numeral golden gate ([PRD §20 gate 5](../PRD.md)).
- **We refuse a font-CDN or network calendar source.** Both packages are bundled pure Dart; nothing about date rendering touches the one permitted network event (the asset download — *Decision log: No networking beyond asset download*).

---

## 5. "Today" is injected; the device's local zone is the only zone we read

### Decision

The engine never reads a clock: "today" is a `CalendarDate` **injected** at the app edge ([PRD §7.12, §19.3](../PRD.md)). It is computed **once per session/day**, at the boundary, from the device's *local* civil day. The full `timezone`/IANA package is **not** a dependency of the engine or the `CalendarDate` core; the device's own local zone is sufficient to name the local day, and nothing in the scheduling path ever converts across arbitrary zones (*Decision log: Dates, calendars & correctness*). The one edge exception — handing the §14 daily-reminder scheduler a DST-correct local `TZDateTime` — is added in the app shell only (decision 14, §6).

### Rationale

- **Determinism requires an injected clock.** "No wall-clock inside; 'today' is injected" ([PRD §19.3](../PRD.md)) is what makes the goldens reproducible — a test passes a fixed `today` and asserts a fixed schedule, with no dependence on when or where the test runs ([11-testing-strategy.md](11-testing-strategy.md)). A `DateTime.now()` anywhere in scheduling would make the schedule a function of the test machine's clock.
- **The only place a real zone matters is naming the local day.** A user's "today," and the local daily-reminder fire time ([PRD §14](../PRD.md)), depend on which civil day it is *for them*. That is a thin app-edge concern, resolved by the device's own local zone — `DateTime.now().toLocal()` names the local day. Naming the civil *day* never needs the full IANA tz database — nothing syncs between devices ([PRD §17](../PRD.md)) and we never convert a date into another region's zone. Re-firing the reminder at a fixed local *time* across a DST transition is the one place the database earns its keep: `flutter_local_notifications`' `zonedSchedule` takes a `TZDateTime`, so E18 takes `timezone` + `flutter_timezone` **only in the app-shell scheduler** (decision 14, §6) — never in the engine or the `CalendarDate` core, whose offline footprint and zone-freedom are unchanged ([pub.dev: timezone](https://pub.dev/packages/timezone)).
- **One boundary conversion, never repeated.** Computing "today" once and threading the `CalendarDate` through the session means a long-running session does not flip days mid-flight in a surprising way, and a single, testable function owns the local→civil mapping.

### Specification

```dart
// app edge — the ONE place a clock is read for scheduling.
CalendarDate todayFor(DateTime now) {
  final local = now.toLocal();                 // device's own local zone
  return CalendarDate.ymd(local.year, local.month, local.day);
}

// Wiring: a single provider supplies `today`; tests override it with a fixed date.
final todayProvider = Provider<CalendarDate>((ref) => todayFor(DateTime.now()));
// engine call sites receive `ref.read(todayProvider)`, never DateTime.now().
```

The local notification ([PRD §14](../PRD.md)) keys off the same local civil day: "Your revision for today is ready" fires for *today's* local date, not a UTC date and not a Hijri date being exact (§6). `flutter_local_notifications` schedules in local time at the app edge; the engine is uninvolved.

### Pitfalls / what we refuse

- **We refuse `DateTime.now()` in the engine or any scheduling path.** It is the determinism break the injected-`today` design exists to prevent; a CI grep flags `DateTime.now()` outside the single `todayFor`/provider edge.
- **We refuse the `timezone`/IANA dependency anywhere it is dead weight.** Arbitrary-zone conversion has no place in an app that never syncs and never shows another region's local time, so the engine and the `CalendarDate` core stay zone-free. The one concrete edge requirement that did appear — firing the §14 daily reminder at a fixed *local* time, DST-correct, via `zonedSchedule` — is added **at the app-notification edge only** (decision 14), exactly as this rule provided; the engine still never sees a zone.
- **We refuse to let a midnight rollover silently re-shuffle an open session.** "Today" is captured at session start; the next session recomputes it. A page does not change due-state under the user's fingers because the clock ticked past midnight mid-recitation.

---

## 6. Hijri honesty: a civil approximation, never a religious authority

### Decision

Wherever a **Hijri** date is shown, it is the **Umm al-Qurā civil** date, labelled as such, accompanied by a standing one-line honesty note, and **never** presented as the authoritative date of a religious observance. The app surfaces a calendar; it does not issue a sighting ruling and stays madhhab/sect-neutral ([PRD R2, §13.3](../PRD.md)) (*Decision log: Dates, calendars & correctness*).

### Rationale

- **The Islamic calendars are genuinely several calendars, disagreeing by up to ~2 days.** Unicode/CLDR define multiple Islamic calendar *types*. The **tabular/arithmetic** calendars use a fixed 30-year cycle with, "in its most common form … 11 leap years," but "dates predicted by the tabular Islamic calendar can occur one or two days too early or too late" relative to observation ([Wikipedia: Tabular Islamic calendar](https://en.wikipedia.org/wiki/Tabular_Islamic_calendar)). **Umm al-Qurā** itself is the calendar "used by the government of Saudi Arabia for civil purposes," its months "determined at the Institute of Astronomical & Geophysical Research … from modern astronomical theories of the sun and the moon" at Mecca, not a religious sighting authority ([van Gent: Umm al-Qurā rules](https://webspace.science.uu.nl/~gent0113/islam/ummalqura_rules.htm)).
- **Even the chosen library says so.** The most rigorous Dart-side Umm al-Qurā implementation, `hijridate`, states the limitation outright: it is "not intended for religious purposes where lunar crescent sighting is preferred over astronomical calculations," and covers **1343–1500 AH (1 Aug 1924 – 16 Nov 2077 CE)** ([dralshehri: hijridate](https://github.com/dralshehri/hijridate)). For the three months that matter most — Ramaḍān, Shawwāl, Dhū al-Ḥijjah — Saudi Arabia's Crescent Sighting Committee confirms the start by sighting, which may differ from the civil date by a day in either direction ([prayertimesksa: Umm al-Qurā vs moon sighting](https://prayertimesksa.com/umm-al-qura-vs-moon-sighting/)).
- **This matches the app's "honest, never fake precision" stance.** The product refuses to imply false certainty anywhere ([PRD §2, R3](../PRD.md)); a Hijri date is approximate by construction, so the UI says so. The libraries even expose a manual per-region `adjustments` map (a `Map<int,int>` keyed by Julian Day Number, values −1/0/+1, "for regional moon sighting differences" and "aligning with local Islamic calendar authorities") for communities reconciling the civil table with a local decision ([pub.dev: hijri_calendar](https://pub.dev/documentation/hijri_calendar/latest/)) — but any such adjustment is a user/community act, never the app silently asserting a sighting.

### Specification

| Rule | Implementation |
|---|---|
| Label the variant | Hijri dates are shown as **Umm al-Qurā** (e.g. a short "(Umm al-Qurā)" qualifier or Settings label), never "the Hijri date" in the absolute |
| Standing honesty note | A localized one-liner near the Hijri picker: the Hijri date is a *civil approximation* and an observance's start may differ by a day by sighting |
| No observance promise | Nothing in the app keys a deadline, reminder, or guarantee to a Hijri date being exact; the daily reminder ([PRD §14](../PRD.md)) keys off the **local civil day**, not a Hijri date |
| Range-guard | Out-of-range Hijri conversion falls back to a Gregorian label (§4), never an exception or a wrong date |
| Neutral framing | No fiqh ruling, no sect-specific sighting claim; the app presents a calendar tool, the user/community owns the religious determination ([PRD R2](../PRD.md)) |

This is a scheduling/retention app: the Hijri date is a courtesy *label* on a `due_at`, not a religious deadline. Because every interval is computed in calendar-invariant integer days (§2), the schedule itself is unaffected by which calendar the user reads — the honesty note guards only the *display*, where the only risk is a user mistaking a civil approximation for an observance date.

### Pitfalls / what we refuse

- **We refuse to present a Hijri date as the authoritative date of Ramaḍān, ʿĪd, or any observance.** That is a sighting determination the app has no authority to make ([PRD R2](../PRD.md)); the civil date is labelled and caveated.
- **We refuse to bake a single region's sighting offset in as "the" Hijri date.** Variants disagree by up to ~2 days ([Wikipedia: Tabular Islamic calendar](https://en.wikipedia.org/wiki/Tabular_Islamic_calendar)); any `adjustments` offset is an explicit user/community choice, not a default the app asserts.
- **We refuse to let a Hijri rendering failure surface to the user as an error.** Out-of-range or library failure falls back to Gregorian silently and locally; a date label never crashes a screen.

---

## 7. The correctness test matrix (release gate)

### Decision

Date and calendar correctness is a **release gate** ([PRD §20 gate 5](../PRD.md)): a pinned suite proves the `CalendarDate` arithmetic is DST/zone-immune, that calendar round-trips are identity, that numerals map per locale, and that the engine produces an identical schedule regardless of the device's timezone or any DST transition (*Decision log: Dates, calendars & correctness*; test infrastructure in [11-testing-strategy.md](11-testing-strategy.md)).

### Rationale

- **The bug class is invisible without DST-spanning vectors.** A `due_at` that drifts by a day across a spring-forward transition passes every test run in a no-DST zone and fails silently on a user's device ([Dart: DateTime](https://api.dart.dev/dart-core/DateTime-class.html)). The only defense is test vectors that deliberately straddle real DST transitions and run under simulated zones.
- **Determinism is testable precisely because the engine is pure.** With "today" injected and `CalendarDate` carrying no zone, the same inputs must yield the same schedule on a Linux CI runner, a Tehran phone, and a no-DST phone — a property a golden test asserts directly ([PRD §7.12](../PRD.md)).

### Specification

The matrix below is the minimum pinned set; vectors are concrete so they are reproducible.

| # | Property under test | Vector / method | Expected |
|---|---|---|---|
| T1 | `addDays` is DST-immune | `CalendarDate.ymd(2026,3,7).addDays(1)` (US spring-forward week) | `2026-03-08`, exactly +1 epochDay |
| T2 | `daysUntil` is exact across DST | `daysUntil` between two dates spanning a spring-forward and a fall-back boundary | exact integer day count (never 23h/25h artifacts) |
| T3 | Trust clamp never exceeds ceiling | randomized `(S, R, cycle, today)` via `glados` | `due_at.epochDay ≤ ceiling.epochDay`, always ([PRD §7.6, §7.12](../PRD.md)) |
| T4 | Schedule is timezone-independent | run `buildToday` under simulated `TZ=Asia/Tehran`, `TZ=Pacific/Kiritimati`, `TZ=UTC` with identical injected `today` + state | byte-identical schedule in all zones |
| T5 | Schedule is DST-transition-independent | inject a `today` on the DST-change date in a DST zone | identical to the no-DST control |
| T6 | Jalālī round-trip is identity | `CalendarDate → Jalali → CalendarDate` over a date sweep | identity for every date in range |
| T7 | Hijri round-trip is identity (in range) | `CalendarDate → Hijri(UmmAlQura) → CalendarDate` over the supported AH range | identity in range; graceful Gregorian fallback out of range |
| T8 | Numerals map per locale | format a known date in `fa`/`ckb`/`ar` | Extended Arabic-Indic for `fa`/`ckb`, Arabic-Indic for `ar`; no ASCII digits ([PRD §13.3](../PRD.md)) |
| T9 | Known Umm al-Qurā reference | convert a documented Gregorian↔Hijri reference pair | matches the published Umm al-Qurā value, with the sighting caveat in copy (§6) |
| T10 | "Today" boundary uses local day | a 23:00-local review in a +UTC-offset zone | civil day = local date, not UTC's next date (§3, §5) |

```dart
// Illustrative: T4/T5 — the engine is zone- and DST-independent by construction.
// Run under different TZ env vars; the injected `today` is the SAME CalendarDate.
test('schedule is identical across timezones and DST', () {
  final today = CalendarDate.ymd(2026, 3, 8); // a US DST-change date
  final state = pinnedFixtureCards();
  final schedule = buildToday(state, today);
  expect(schedule, equals(goldenSchedule)); // same on every runner/zone
});
```

T4/T5 are run by setting the process `TZ` (or the host clock) across zones with and without DST, because the engine reads no clock — the test merely proves that nothing *else* in the date pipeline reintroduced a zone. T8's numeral expectations and the bidi-isolation goldens are shared with the localization gate ([12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md), [PRD §20 gate 5](../PRD.md)).

### Pitfalls / what we refuse

- **We refuse to test dates only in a no-DST zone.** A green suite under `TZ=UTC` proves nothing about a Tehran user crossing a transition; T4/T5 run under DST zones explicitly.
- **We refuse to assert calendar output against a hand-typed string.** Reference vectors (T9) come from a documented, independently published Umm al-Qurā / Jalālī conversion, not from the library asserting against itself.
- **We refuse to ship if any date vector is red.** Date correctness is part of [PRD §20 gate 5](../PRD.md); a failing round-trip or a non-deterministic schedule blocks the release exactly as a missing ARB key does.

---

## References

All URLs verified reachable on 2026-06-16.

- Dart team. *DateTime class — dart:core* (instant not date; `microsecondsSinceEpoch`; "does not provide internationalization, use the `intl` package"; DST warning that two local midnights may differ by less than 24 h × days; `add`/`difference` semantics). https://api.dart.dev/dart-core/DateTime-class.html
- `intl` package, pub.dev (`NumberFormat`, `DateFormat` Gregorian-only, `BidiFormatter`; locale numerals). https://pub.dev/packages/intl
- `shamsi_date` package, pub.dev (pure Dart, BSD-3-Clause, null-safe; `Jalali`/`Gregorian`/`Date`, `toDateTime`/`fromDateTime`, `julianDayNumber`, `formatter`; range `Gregorian(560,3,20)`–`Gregorian(3798,12,31)`; algorithm based on `jalaali-js`). https://pub.dev/packages/shamsi_date
- `hijri` package, pub.dev (pure Dart, BSD-2-Clause, v3.0.1; Umm al-Qurā conversion; `HijriCalendar.now()`, `fromDate`, `hijriToGregorian`, `hYear/hMonth/hDay`, `toFormat`, `lengthOfMonth`). https://pub.dev/packages/hijri
- `hijri_calendar` API docs, pub.dev ("Supported Gregorian date range validation (1937–2076)"; `adjustments` `Map<int,int>` keyed by Julian Day Number, values −1/0/+1, for regional moon-sighting / local-authority alignment). https://pub.dev/documentation/hijri_calendar/latest/
- `timezone` package, pub.dev (bundled IANA tz database; `TZDateTime`, `initializeTimeZones`, `getLocation`, `setLocalLocation` — taken only at the app-notification edge for the E18 reminder, decision 14; never in the engine). https://pub.dev/packages/timezone
- van Gent, R. H. (Utrecht). *The Umm al-Qura Calendar of Saudi Arabia — astronomical rules* ("used by the government of Saudi Arabia for civil purposes"; determined at the Institute of Astronomical & Geophysical Research from "modern astronomical theories of the sun and the moon"; geocentric-conjunction / moonset-after-sunset criteria at Mecca). https://webspace.science.uu.nl/~gent0113/islam/ummalqura_rules.htm
- Alshehri, M. *hijridate* (Umm al-Qurā ↔ Gregorian; range 1343–1500 AH / 1924–2077 CE; "not intended for religious purposes where lunar crescent sighting is preferred"). https://github.com/dralshehri/hijridate
- Wikipedia. *Tabular Islamic calendar* (30-year cycle, 11 leap years; "one or two days too early or too late" vs observation; civil/astronomical epochs one day apart). https://en.wikipedia.org/wiki/Tabular_Islamic_calendar
- Wikipedia. *Solar Hijri calendar* (official calendar of Iran; equinox-locked; month lengths; Nowruz; calendar-invariant day distance). https://en.wikipedia.org/wiki/Solar_Hijri_calendar
- Wikipedia. *ISO 8601* (`full-date` `YYYY-MM-DD`, proleptic-Gregorian basis, no zone/locale). https://en.wikipedia.org/wiki/ISO_8601
- Wikipedia. *Proleptic Gregorian calendar.* https://en.wikipedia.org/wiki/Proleptic_Gregorian_calendar
- Baeldung. *Difference Between Instant and LocalDateTime* (physical vs civil time; `Instant` for storage, `LocalDate` for calendar facts). https://www.baeldung.com/java-instant-vs-localdatetime
- JetBrains/Kotlin. *kotlinx-datetime* (explicit boundary between physical instant and local civil time; avoids mixed entities). https://github.com/Kotlin/kotlinx-datetime
- PrayerTimesKSA. *Umm al-Qura vs Moon Sighting* (civil table vs Crescent Sighting Committee; Ramaḍān/Shawwāl/Dhū al-Ḥijjah may differ ±1 day). https://prayertimesksa.com/umm-al-qura-vs-moon-sighting/
- Hifz Companion. *Documentation blueprint (authoring contract).* [_DOC-SET-BLUEPRINT.md](../_DOC-SET-BLUEPRINT.md)
- Hifz Companion. *Product Requirements Document.* [PRD.md](../PRD.md)
- Hifz Companion. *Calendars & i18n research dossier.* [research/calendars-i18n-hijri-jalali.md](research/calendars-i18n-hijri-jalali.md)

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
