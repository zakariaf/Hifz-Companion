# references — ui-reminder-row

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/design-system/10-privacy-and-trust-ux.md` §10 (The reminder layer stays calm and peripheral) — **The core rule.** One local notification (`flutter_local_notifications`, no push, no server): "Your revision for today is ready." Neutral, supportive, never "You'll lose your hifz." Fully optional, trivially silenced, no escalating cadence. The reminder time renders in the user's calendar and numerals; no celebratory motion or sound beyond the OS default. The optional "catch-up ready" note is framed as help, never blame. Take: the reminder is one calm, optional, non-escalating, non-coercive line.

- `docs/design-system/10-privacy-and-trust-ux.md` §9 (For the few real choices, default to the safe path) — The reminder is one of only three genuine choices. The §9 table fixes it: **safe default = one calm reminder, off-by-default until the user opts in / easily silenced; reversible in one tap; the honest one-line = "A neutral reminder at a time you choose. Silence it anytime."** No pre-ticked boxes; opt-in is an explicit tap; the safe choice is the visually primary control; each toggle's state is announced to screen readers per locale. Take: off by default, protective path is the easy path, one honest sentence.

- `docs/design-system/11-voice-and-tone.md` §3 (Tone-by-context matrix) — The "Daily session ready" row: tone is **calm, neutral statement of readiness** → "Your revision for today is ready." Never "Don't miss today!", urgency, or an exclamation. Notification copy uses the calmest rows only — one neutral daily line plus an optional, framed-as-help catch-up note, both fully silenceable with no nagging escalation. Take: the exact sanctioned reminder line and its tone.

- `docs/engineering/07-dates-calendars-and-correctness.md` §5 ("Today" is injected; the device's local zone is the only zone we read) — The local notification keys off the **same local civil day** as the engine's injected "today"; "Your revision for today is ready" fires for *today's local date*, not a UTC date. `flutter_local_notifications` schedules in local time at the app edge; the engine is uninvolved; **no `DateTime.now()` outside the single `todayFor`/provider edge** (a CI grep enforces it). Take: schedule for the local civil day, read the clock only at the injected edge.

## Supporting

- `docs/engineering/07-dates-calendars-and-correctness.md` §6 (Hijri honesty) — The daily reminder keys off the **local civil day, not a Hijri date being exact**; nothing keys a deadline or reminder to a Hijri date. Take: never schedule the reminder against a Hijri/observance date.

- `docs/engineering/07-dates-calendars-and-correctness.md` §4 (Hijri/Jalālī/Gregorian are display-only, behind one presentation helper) — The chosen reminder time, when displayed, goes through the one `CalendarPresenter` in the user's chosen calendar; numerals are remapped **downstream** of conversion to the locale digit set (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar), never raw ASCII concatenated into a string. Take: render the time via the presenter + locale numerals.

- `docs/design-system/10-privacy-and-trust-ux.md` §11 (Audit every screen against the five dark-pattern strategies) — The release-gate checklist: nagging / obstruction / sneaking / interface interference / forced action. The reminder structurally avoids all five (one optional reminder, silencing is one tap, no pre-checked option, protective path never buried, gates nothing). Take: the row is auditable against a named taxonomy, any instance is a logged defect.

- `docs/design-system/10-privacy-and-trust-ux.md` §6 (Frame the few network actions honestly) / §3 (Honesty must be specific and verifiable) — A reminder makes **no** network request; state the local-only fact plainly, not with "we care about your privacy" rhetoric. Take: the honest one-liner is a checkable fact, and the reminder phones home to nothing.

- `docs/design-system/11-voice-and-tone.md` §7 (No transactional or pressuring framing) — No manufactured urgency, no streak-pressure, no "keep your streak," no escalating nags; worship is served, not managed. Take: the reminder never drives engagement-for-its-own-sake.

- `docs/design-system/11-voice-and-tone.md` §9 (Tone is a per-locale QA gate) — The never-ship banned-phrase lint blocks guilt/fear/loss framing, "You haven't opened the app in N days," "Don't break your streak," exclamation marks/emoji, and mandates — run on every locale, release-blocking. Take: the reminder string must clear the banned-phrase gate in fa/ckb/ar.

- `docs/design-system/11-voice-and-tone.md` §8 (One voice across fa/ar/ckb requires transcreation) — The reminder line is transcreated, not literally translated; Arabic imperatives softened into statements of readiness; Sorani register/vocabulary pending native + scholarly review. Take: transcreate the reminder copy per locale.

## Sibling skills

- **ui-settings-picker** — the grouped Settings surface and single-choice picker pattern this reminder row sits beside (this row is a toggle + time, not a mutually-exclusive picker).
- **ui-catch-up-banner** — the on-screen, return-after-gap catch-up surface on Today; the optional "catch-up ready" notification note mirrors its calm, help-not-blame framing.
- **eng-define-service-boundary** — the injectable `NotificationScheduler` interface (`scheduleDaily`/`cancelAll`) and its deterministic fake double; the row calls this, never the OS directly.
- **eng-create-riverpod-store** — the long-lived notifier behind the toggle/time that persists transactionally **before** republishing in-memory state (the single write path).
- **eng-add-localized-string** — adding/transcreating the reminder and catch-up copy as fa/ckb/ar ARB keys through `gen_l10n`.
- **eng-rtl-and-bidi-layout** — `EdgeInsetsDirectional`, FSI/PDI isolation of the time run, and per-locale numerals for the row.
- **domain-calendars-and-hifzdate** — the local-civil-day fire time, the injected clock edge, and the calendar/numeral rendering of the chosen time.
- **domain-adab-and-religious-integrity** — the always-on conscience-check the reminder copy must pass: no guilt/fear/loss, no streak, no "safe to drop," servant-to-the-teacher.
