---
name: ui-reminder-row
description: Build or modify the Hifz Companion daily-reminder row — the opt-in, off-by-default local-notification config control that schedules one calm, neutral daily reminder ("Your revision for today is ready") at a user-chosen time, device-local only, with no guilt, fear, loss, or streak framing and no escalation. Use whenever building a reminder/notification toggle row, a "remind me daily" setting, a reminder-time picker, the optional catch-up note toggle, or any opt-in local-notification configuration in Settings or onboarding.
---

# ui-reminder-row

The Settings/onboarding row that lets a ḥāfiẓ opt into **one** calm daily reminder: a single switch (off by default), a reminder-time picker shown only once enabled, and one honest sentence. When on, it schedules exactly one device-local notification per day — "Your revision for today is ready" — fired for *today's local civil day*, with no server, no push, no escalation, and no celebratory or coercive content.

This control is the app's most dangerous surface for *adab*: the notification layer is where well-meaning apps slide into guilt and engagement-farming. Hifz Companion takes only the attention the task needs, makes opting in an explicit tap, and keeps the protective default (off / silent) the easy one.

## When to use

Use when building or placing:
- a daily-reminder toggle row or "remind me to revise" switch (Settings or onboarding)
- the reminder-time picker that appears once the reminder is enabled
- the optional, framed-as-help "catch-up ready" note toggle
- any opt-in local-notification configuration row built on `flutter_local_notifications`

Do NOT use this skill for → use the named sibling instead:
- a generic single-choice preference picker (language, calendar, numerals, theme, muṣḥaf) → use **ui-settings-picker**
- the on-screen catch-up *banner* shown on Today after a gap (not the notification) → use **ui-catch-up-banner**
- wiring the notification scheduler as an injectable side-effect boundary with a deterministic fake → use **eng-define-service-boundary**
- the long-lived Riverpod notifier/persistence behind the toggle → use **eng-create-riverpod-store**
- authoring/transcreating the reminder copy strings into fa/ckb/ar ARB → use **eng-add-localized-string**
- the conscience-check on the copy itself (no guilt/fear/loss, no "safe to drop") → use **domain-adab-and-religious-integrity**
- the local-civil-day / fire-time / calendar-numeral correctness of the scheduled time → use **domain-calendars-and-hifzdate**

This row *configures* a reminder; it does not render the muṣḥaf, mutate engine state, or compute a schedule. A reminder row that nags, escalates, or frames forgetting as loss is the wrong component.

## The canonical pattern

1. **Off by default; opt-in is one explicit tap.** The reminder is a genuine choice whose protective default is **off / easily silenced**, never pre-ticked. The toggle is the visually primary control; turning it on is a single deliberate tap, and a single tap silences it again. `docs/design-system/10-privacy-and-trust-ux.md` §9 (the few real choices: protective default, reversible, one plain sentence; "no pre-ticked boxes; opt-in is an explicit tap") and §9 table (Daily reminder: "off-by-default until the user opts in / easily silenced"). No status-quo bias keeps the user opted into anything they did not choose (§9 anti-patterns).

2. **Exactly one calm daily line — neutral, never guilt/fear/loss.** When on, schedule one local notification: "Your revision for today is ready." Supportive and neutral; never "You'll lose your hifz," never a countdown, never an exclamation mark. `docs/design-system/10-privacy-and-trust-ux.md` §10 (reminder layer stays calm and peripheral: one neutral, optional daily reminder; no guilt, no fear, no streak pressure, no escalation) and `docs/design-system/11-voice-and-tone.md` §3 tone matrix row "Daily session ready" → "Your revision for today is ready." (never urgency/exclamation). The copy passes the §9 banned-phrase voice gate before it ships.

3. **No streaks, no escalation, no re-engagement.** One reminder per day at a fixed user-chosen time. Never escalate cadence to re-engage a lapsed user, never build a streak to punish a break, never advertise or upsell. `docs/design-system/10-privacy-and-trust-ux.md` §10 anti-patterns (no streak the user is punished for breaking; no escalating frequency; no using notifications to pull the user back for engagement's sake) and `docs/design-system/11-voice-and-tone.md` §7 (no manufactured urgency, no streak-pressure).

4. **Schedule for the local civil day; never a UTC or Hijri instant.** The reminder keys off the device's **local civil day** ("today" for the user), not a UTC date and not a Hijri date being exact. Read the clock once, at the app edge, via the injected boundary — never `DateTime.now()` in shell logic. `docs/engineering/07-dates-calendars-and-correctness.md` §5 ("Today" is injected; the local notification keys off the same local civil day; `flutter_local_notifications` schedules in local time at the app edge; the engine is uninvolved) and §6 (the daily reminder keys off the local civil day, not a Hijri date being exact).

5. **Render the chosen reminder time in the user's calendar + locale numerals.** The time-picker value and any displayed time render through the one presentation boundary in the user's chosen calendar (Jalālī / Umm al-Qurā Hijri / Gregorian) and locale numeral set — Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar — via `intl` `NumberFormat`, never raw ASCII concatenated into a string. `docs/engineering/07-dates-calendars-and-correctness.md` §4 (one `CalendarPresenter`; numerals remapped downstream of conversion) and `docs/design-system/10-privacy-and-trust-ux.md` §10 ("the reminder time renders in the user's calendar and numerals").

6. **Persist the choice through the single write path, then schedule as a side effect.** The toggle and time write through a Riverpod notifier that **persists transactionally before** republishing in-memory state; the actual OS scheduling (`NotificationScheduler.scheduleDaily` / `cancelAll`) is an injected side-effect boundary called after the write commits, never a view reaching the OS directly. `docs/design-system/10-privacy-and-trust-ux.md` §9 (each toggle's state announced per locale; reversible) — reuse **eng-create-riverpod-store** (persist-before-republish) and **eng-define-service-boundary** (the `NotificationScheduler` interface + deterministic fake).

7. **State the one honest sentence; this is also a privacy fact.** Under the row, one plain transcreated line: a neutral reminder at a time you choose, silence it anytime — local-only, nothing sent. `docs/design-system/10-privacy-and-trust-ux.md` §9 table (the honest one-line: "A neutral reminder at a time you choose. Silence it anytime.") and §6 (every network action is explained in context — a reminder makes none; it is `flutter_local_notifications`, no push, no server, §10). No "we care about your privacy" rhetoric (§3); state the checkable fact.

8. **RTL-correct, accessible, bidi-safe.** Lay the row out with `EdgeInsetsDirectional` (logical start/end), give the switch a `Semantics` label + on/off value announced per locale, isolate any mixed Latin/numeric run (the time) in FSI/PDI, and meet the 48×48dp touch minimum with the primary control in the bottom thumb band. `docs/design-system/10-privacy-and-trust-ux.md` §9 ("each toggle's state is announced to screen readers per locale") — reuse **eng-rtl-and-bidi-layout** (`EdgeInsetsDirectional`, FSI/PDI, locale numerals).

9. **Audit the row against the five dark-pattern strategies.** No nagging (one optional reminder, no re-engagement loop), no obstruction (silencing is one tap), no sneaking (no pre-checked option; the local-only fact is stated), no interface interference (the protective off/silent path is never buried), no forced action (the reminder gates nothing). `docs/design-system/10-privacy-and-trust-ux.md` §11 (the five strategies are a release-gate checklist; any instance is a logged defect) and §9 (the protective path is always the easy path).

## Do / Don't

| Do | Don't |
|---|---|
| Ship the toggle **off by default**; opt-in is one explicit tap | Pre-tick the reminder or default it on / to an aggressive cadence |
| Use the one neutral line "Your revision for today is ready" | Use guilt/fear/loss copy ("You'll lose your hifz," "Don't miss today!"), exclamation marks, or a countdown |
| Schedule exactly one reminder/day at the user's chosen time | Escalate cadence, add a streak, or re-notify to re-engage a lapsed user |
| Key the fire time off the device's **local civil day** via the injected clock edge | Call `DateTime.now()` in the row/controller, or key off a UTC or Hijri instant |
| Render the time in the user's calendar + locale numerals via the presenter (`intl` `NumberFormat`) | Concatenate raw ASCII digits, or show the time only in Gregorian |
| Persist via the notifier (persist-before-republish), then call the injected `NotificationScheduler` | Schedule from the view, or republish state before the write commits |
| State the honest one-liner: neutral reminder, silence anytime, local-only | Use "we care about your privacy" rhetoric or imply it phones home |
| `EdgeInsetsDirectional`, `Semantics` on/off value per locale, FSI/PDI on the time, 48×48dp | Hard-code left/right padding, leave the switch unlabeled, or shrink the hit area |
| Frame the optional catch-up note as help, fully silenceable | Frame missed days as blame, "N days lost," or a red overdue pile |

## Checklist

Before this control is done:

- [ ] The reminder toggle is **off by default**; opt-in is an explicit tap; no pre-ticked box; one tap silences it again (`docs/design-system/10-privacy-and-trust-ux.md` §9).
- [ ] When on, exactly **one** local notification/day fires: "Your revision for today is ready." — neutral, no exclamation, no guilt/fear/loss, no countdown (§10; `11-voice-and-tone.md` §3 matrix).
- [ ] No streak, no escalating cadence, no re-engagement of a lapsed user, no upsell (`10-privacy-and-trust-ux.md` §10 anti-patterns; `11-voice-and-tone.md` §7).
- [ ] The fire time keys off the device's **local civil day** via the injected clock edge; **no `DateTime.now()`** in the row, controller, or any shell logic (`07-dates-calendars-and-correctness.md` §5/§6).
- [ ] The chosen/displayed time renders in the user's calendar + locale numerals (Extended Arabic-Indic fa/ckb, Arabic-Indic ar) through `intl` `NumberFormat` — never raw ASCII (`07-dates-calendars-and-correctness.md` §4).
- [ ] Toggle/time persist through the notifier (persist-before-republish); OS scheduling runs **after** the write via the injected `NotificationScheduler` (`scheduleDaily`/`cancelAll`), never from a view (reuse **eng-create-riverpod-store**, **eng-define-service-boundary**).
- [ ] One honest, transcreated sentence under the row: a neutral reminder at a time you choose, silence anytime, local-only — no privacy rhetoric (`10-privacy-and-trust-ux.md` §9/§3).
- [ ] `EdgeInsetsDirectional` layout; `Semantics` label + on/off value announced per locale; mixed time run isolated FSI/PDI; primary control ≥48×48dp in the thumb band (reuse **eng-rtl-and-bidi-layout**).
- [ ] fa/ckb/ar copy is transcreated (not literally translated) and passes the banned-phrase voice gate and scholarly/native review before ship (`11-voice-and-tone.md` §8/§9).
- [ ] Local-only / no-AI / offline: `flutter_local_notifications`, no push, no server, no network call; the reminder is a config choice, computes nothing, and works in airplane mode (`10-privacy-and-trust-ux.md` §10).
- [ ] The row passes the five dark-pattern audit: no nagging / obstruction / sneaking / interface-interference / forced action (`10-privacy-and-trust-ux.md` §11).

This row only configures a calm, optional reminder; it surfaces no methodology claim and issues no ruling. If the copy ever changes, it must re-pass the **domain-adab-and-religious-integrity** conscience-check and the `11-voice-and-tone.md` §9 banned-phrase gate in all three locales — a single wrong sentence here is a documented breach of *adab*, not a style slip.

## Files

- `template.dart` — copy-paste scaffold: the domain-blind `ReminderRow` widget (switch + conditional time picker + honest one-liner), the feature-layer `ReminderController` that persists through the single write path and calls the injected `NotificationScheduler`, and a widget-test stub. Fill the `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **ui-settings-picker** (the grouped Settings surface this row sits in), **ui-catch-up-banner** (the on-screen return-after-gap surface the catch-up note mirrors), **eng-define-service-boundary** (the `NotificationScheduler` interface + fake), **eng-create-riverpod-store** (the persist-before-republish notifier), **eng-add-localized-string** (the fa/ckb/ar reminder copy), **eng-rtl-and-bidi-layout** (directional insets, FSI/PDI, locale numerals), **domain-calendars-and-hifzdate** (local-civil-day fire time, calendar/numeral rendering), **domain-adab-and-religious-integrity** (the conscience-check on every reminder string).
