# E18 — Reminders

One calm, opt-in, off-by-default local notification — "Your revision for today is ready" — fired once per day at a user-chosen time on the device, plus an optional, framed-as-help catch-up note after a gap. The reminder is a rebuildable derived cache, not a source of truth: the toggle and time are the only persisted state, and the OS schedule is re-derived from them, so a wipe-and-reschedule always converges. Neutral tone with no guilt, fear, loss, or streak framing and no escalation; device-local only, no push, no server, works in airplane mode forever.

## Why this epic exists

The notification layer is the single most dangerous surface in this app for *adab*: it is exactly where well-meaning Islamic apps slide into guilt-nagging and engagement-farming, and for a ḥāfiẓ who already carries the spiritual weight of what they hold, one wrong sentence — "You'll lose your hifz," a broken-streak shame state, a "you haven't opened the app in N days" — is a documented harm and a breach of *adab*, not a style slip ([PRD R3, §14](../../docs/PRD.md); [design-system 11 §3/§4](../../docs/design-system/11-voice-and-tone.md)). The market's defining cautionary case (Muslim Pro) and the meta-analytic evidence that guilt appeals persuade *less* and trigger reactance (C-043) make the calm path not merely kinder but more effective: shame's behavioral signature is to stop opening the app. So this epic exists to ship the one reminder the task actually warrants and to make every coercive default structurally impossible — off by default, opt-in by an explicit tap, silenced in one tap, no cadence escalation, no streak to break ([design-system 10 §9/§10](../../docs/design-system/10-privacy-and-trust-ux.md)). It is also a privacy fact: a reminder fires from `flutter_local_notifications` with no push and no server, so the "no per-user data leaves the device" guarantee (C1, R5) holds with the notification on. And it is a correctness surface: the fire time must key off the device's **local civil day** through the injected clock edge, never `DateTime.now()` in shell logic and never a UTC or Hijri instant, or the daily reminder drifts a day across a DST/timezone transition exactly as a `due_at` would ([engineering 07 §5/§6](../../docs/engineering/07-dates-calendars-and-correctness.md)). Treating the schedule as a derived cache rebuilt from persisted prefs is what keeps it honest after a restore, a locale change, or an OS reboot — there is nothing authoritative to lose.

## Scope

### In scope

- The **reminder configuration row** (`ui-reminder-row`): a single switch, off by default; opt-in is one explicit tap and one tap silences it; the reminder-time picker appears only once enabled; one honest transcreated sentence under the row ("A neutral reminder at a time you choose. Silence it anytime." — local-only, nothing sent).
- The **optional catch-up note** toggle: a second, independently off-by-default switch that, after a missed-day gap, surfaces one framed-as-help note mirroring the engine's re-spread plan — never blame, "N days lost", or a red overdue pile.
- The **persisted reminder preferences** (enabled, time-of-day, catch-up-note-enabled) written through the single write path — the only source of truth this epic owns.
- The **`NotificationScheduler` side-effect boundary** (`eng-define-service-boundary`): a Dart interface (`scheduleDaily`, `cancelAll`) with a live `flutter_local_notifications` implementation and a deterministic fake double, injected at the composition root — no view or controller reaches the OS directly.
- The **reschedule-as-derived-cache reconciler**: on app start, on preference change, and after a reboot/permission grant, `cancelAll` then re-derive the single daily fire from the persisted prefs and the injected local civil day — idempotent, convergent, no duplicate notifications.
- **Local-civil-day fire-time computation** at the app edge via the injected clock; the chosen/displayed time rendered in the user's calendar + locale numerals (`ui-numerals-calendar-text`) through the one presentation boundary.
- **OS notification-permission handling** (Android 13+ `POST_NOTIFICATIONS`, iOS authorization) requested in-context only when the user opts in, with an honest rationale and a calm, non-obstructive denied/blocked state — never a forced action.
- Full **fa/ckb/ar** transcreation of the row copy, the one-liner, the notification body, and the catch-up note, passing the banned-phrase voice gate; RTL-correct, bidi-safe, accessible row.
- Tests: write-path unit suite over the prefs notifier, scheduler-boundary unit tests over the fake, local-civil-day fire-time correctness (DST/timezone), the reschedule-idempotency/convergence test, a banned-phrase copy assertion, and the RTL/locale-numeral golden for the row.

### Out of scope

- The on-screen **catch-up banner** shown on Today after a gap (the in-app surface, not the notification) → **E12 — Today & Recite/Grade** (`ui-catch-up-banner`); this epic owns only the optional *notification* that mirrors it.
- The **engine's** catch-up re-spread computation and the daily revision list it produces → **E04 — Scheduling Engine** / **E12**; this epic reads "is there work today / is there a backlog" but computes no schedule.
- The grouped **Settings surface** the row sits in, plus profiles and the teacher loop → **E16 — Settings, Profiles & Teacher** (`ui-settings-picker`); this epic supplies the reminder row, not the Settings shell.
- The **injected clock provider / `CalendarDate` / `CalendarPresenter`** themselves → **E02 — Calendar & Date Core**; this epic consumes them, it does not define them.
- The **app shell, Riverpod composition root, and persistence/Drift schema mechanics** → **E07 — App Shell** / **E03 — Models & Persistence**; this epic adds one prefs record and one boundary onto the existing spine.
- Any **push notification, server, remote config, or scheduled-content delivery** → permanently out of scope by C1; there is no server to add.

## Dependencies

### Depends on

- **E02 — Calendar & Date Core** — the injected "today" / local-civil-day clock edge, `CalendarDate`, and the `CalendarPresenter` (Jalālī / Umm al-Qurā Hijri / Gregorian + locale numerals) the fire time keys off and renders through ([engineering 07 §4/§5/§6](../../docs/engineering/07-dates-calendars-and-correctness.md)).
- **E10 — Mihrab Component Library** — the design tokens, switch/row/time-picker primitives, and calm palette/type the reminder row composes from (it owns no token family).
- **E12 — Today & Recite/Grade** — the catch-up re-spread semantics and "work today / backlog exists" read model the optional catch-up note mirrors, and the recite/grade flow the daily reminder points the user toward.

### Enables

- **E16 — Settings, Profiles & Teacher** mounts the reminder row inside the grouped Settings surface and exposes it per profile.
- **E11 — Onboarding & Cold-Start** may offer the same opt-in reminder row as a calm, skippable step after the first day is generated.
- **E20 — Release Readiness** consumes this epic's banned-phrase copy gate, the no-network guarantee under an active notification, and the date-correctness vectors for the local-civil-day fire time.

## Foundation inputs

| Input | Where (doc / skill) | What this epic takes |
|---|---|---|
| Reminder row contract | .claude/skills/ui-reminder-row/SKILL.md | The canonical pattern: off-by-default toggle, opt-in tap, conditional time picker, one honest sentence, one calm line, no streak/escalation, the Do/Don't and the ten-item checklist this epic implements |
| The few real choices | docs/design-system/10-privacy-and-trust-ux.md §9 | Protective default (off / easily silenced), reversible, one plain sentence, no pre-ticked box, the safe path is the easy path |
| Calm peripheral reminder layer | docs/design-system/10-privacy-and-trust-ux.md §10 | One neutral optional daily reminder; no guilt/fear/streak/escalation; catch-up framed as help; reminder time in the user's calendar + numerals; OS default motion/sound only |
| Five dark-pattern release gate | docs/design-system/10-privacy-and-trust-ux.md §11 | Audit the row against nagging / obstruction / sneaking / interface interference / forced action — any instance is a logged defect |
| Tone-by-context matrix | docs/design-system/11-voice-and-tone.md §3 | "Daily session ready" → "Your revision for today is ready." (never urgency/exclamation); "Resume after a gap" resumes silently; the catch-up empathy-then-path row |
| Empathy / no-blame hard news | docs/design-system/11-voice-and-tone.md §4 | The catch-up note leads with understanding then a concrete plan, never fault; no loss imagery, no "you'll lose your hifz" |
| Banned-phrase voice gate | docs/design-system/11-voice-and-tone.md §6/§9 | The release-blocking never-ship list (guilt/fear/loss, mandates, "safe to drop", exclamation/emoji) every reminder string must pass in all three locales |
| Notifications spec | docs/PRD.md §14 | Local-only (`flutter_local_notifications`), one calm daily line, optional catch-up note framed as help, fully optional/silenceable, no nagging escalation |
| Privacy & no-microphone | docs/PRD.md §17, R5, C1 | The reminder is device-local, sends nothing, fires no network call, works in airplane mode; no per-user data leaves the device |
| Local-civil-day fire time | docs/engineering/07-dates-calendars-and-correctness.md §5/§6 | "Today" is injected; the reminder keys off the local civil day via the clock edge; `flutter_local_notifications` schedules in local time at the app edge; never a UTC/Hijri instant; the engine is uninvolved |
| Calendar + numeral rendering | docs/engineering/07-dates-calendars-and-correctness.md §4 · skill ui-numerals-calendar-text | The chosen/displayed reminder time rendered through the one `CalendarPresenter`, numerals remapped downstream (Extended Arabic-Indic fa/ckb, Arabic-Indic ar) |
| Scheduler service boundary | .claude/skills/eng-define-service-boundary/SKILL.md | The `NotificationScheduler` Dart interface + deterministic fake injected at the composition root, never a global singleton |
| Single write path | .claude/skills/eng-create-riverpod-store/SKILL.md | The prefs notifier persists transactionally **before** republishing; OS scheduling runs after the write commits |
| Localized strings | .claude/skills/eng-add-localized-string/SKILL.md | The fa/ckb/ar ARB keys for the row copy, one-liner, notification body, and catch-up note, transcreated not literally translated |
| RTL & bidi layout | .claude/skills/eng-rtl-and-bidi-layout/SKILL.md | `EdgeInsetsDirectional`, FSI/PDI isolation of the time run, locale numerals, 48×48dp control in the thumb band |
| Adab conscience-check | .claude/skills/domain-adab-and-religious-integrity/SKILL.md | The always-on guardrail on every reminder string: no guilt/fear/loss, no streak, no "safe to drop", servant-to-the-teacher |
| Calm-reminder claims | docs/science/CLAIMS.md C-043, C-042, C-041, C-008, C-013 | C-043 (calm/blameless reminder copy) governs the notification body; C-042/C-041 (a miss doesn't undo progress; no streaks/guilt) govern the catch-up note's framing; C-008/C-013 back the re-spread "help" framing |

## Deliverables

- [ ] `ReminderRow` widget — switch (off by default), conditional reminder-time picker, honest one-liner — composing E10 primitives, RTL-correct and accessible, with the catch-up-note toggle as a sibling switch.
- [ ] A persisted reminder-preferences record (enabled, time-of-day, catch-up-note-enabled) and its DAO/repository read-write surface, written through the single write path.
- [ ] A `ReminderController` (Riverpod notifier) that persists prefs transactionally before republishing, then calls the injected `NotificationScheduler`.
- [ ] The `NotificationScheduler` interface (`scheduleDaily`, `cancelAll`), a live `flutter_local_notifications` implementation, and a deterministic fake, injected at the composition root.
- [ ] The reschedule reconciler that re-derives the single daily fire from persisted prefs on start / change / reboot / permission grant — idempotent and convergent (a rebuildable derived cache).
- [ ] Local-civil-day fire-time computation at the app edge via the injected clock; the time rendered through the `CalendarPresenter` with locale numerals.
- [ ] In-context OS notification-permission request (Android 13+ / iOS) on opt-in, with an honest rationale and a calm denied/blocked state that obstructs nothing.
- [ ] fa/ckb/ar ARB entries for the row copy, one-liner, notification body, and catch-up note, transcreated and passing the banned-phrase voice gate.
- [ ] Tests: prefs write-path unit suite, scheduler-boundary units over the fake, local-civil-day fire-time DST/timezone correctness, reschedule idempotency/convergence, banned-phrase copy assertion, and the RTL/locale-numeral row golden.

## Definition of Done

- [ ] The reminder toggle is **off by default**; opt-in is one explicit tap; no pre-ticked box; one tap silences it and cancels the OS schedule. When on, exactly one local notification per day fires at the chosen time: "Your revision for today is ready." — neutral, no exclamation, no guilt/fear/loss, no countdown.
- [ ] **No streak, no escalation, no re-engagement**: one reminder per day at a fixed user-chosen time; the catch-up note is independently optional and framed as help; no cadence increases to re-engage a lapsed user; the row passes the five dark-pattern audit (no nagging / obstruction / sneaking / interface interference / forced action).
- [ ] **Offline / no-network / no-AI**: the reminder is `flutter_local_notifications` only — no push, no server, no network call, no microphone; it works in airplane mode and sends nothing about the user; the build's no-networking gate stays green with the notification active.
- [ ] **Derived-cache convergence**: prefs are the only source of truth; `cancelAll`-then-reschedule from persisted prefs is idempotent and never produces duplicate or stale notifications across start, change, restore, reboot, and permission grant — a test proves convergence.
- [ ] **Local-civil-day correctness**: the fire time keys off the device's local civil day via the injected clock edge; no `DateTime.now()` appears in the row, controller, or scheduler logic; a DST/timezone vector proves the fire day does not drift; the reminder keys off no UTC or Hijri instant.
- [ ] **Text fidelity**: this epic renders no Quran text and re-typesets nothing; the muṣḥaf integrity surface is untouched (N/A by construction, asserted).
- [ ] **Localization & RTL**: every user-facing string ships fa/ckb/ar transcreated (not literally translated) via `gen_l10n` with zero missing keys and no hardcoded text; the row uses `EdgeInsetsDirectional`; the time run is FSI/PDI-isolated; the time renders in the chosen calendar + locale numerals.
- [ ] **Accessibility**: the switch has a `Semantics` label + on/off value announced per locale; the primary control meets 48×48dp in the thumb band; OS text-scale is respected; the denied/blocked state is screen-reader legible.
- [ ] **Sect-neutral adab**: every reminder string passes the banned-phrase voice gate and the `domain-adab-and-religious-integrity` conscience-check in all three locales; no string speaks for the Quran, issues a ruling, frames forgetting as loss, or implies a page is "safe to drop"; the notification body traces to C-043 and the catch-up framing to C-042/C-041.
- [ ] **Single write path**: the toggle and time persist transactionally before any in-memory republish; OS scheduling runs only after the write commits; no view reaches the scheduler or the OS directly.
- [ ] **Tests**: the prefs write-path, scheduler-boundary, fire-time DST/timezone, reschedule-convergence, banned-phrase, and RTL/numeral-golden suites are green locally and in CI; correctness-critical suites (fire-time, convergence, write-path) are written test-first.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E18-T01 | [NotificationScheduler service boundary: interface, live flutter_local_notifications impl, deterministic fake, composition-root injection](E18-T01-notification-scheduler-boundary.md) | M | E02 |
| E18-T02 | [Reminder preferences persisted model + DAO through the single write path](E18-T02-reminder-prefs-model.md) | S | — |
| E18-T03 | [ReminderController notifier: persist-before-republish, then schedule via the injected boundary](E18-T03-reminder-controller.md) | M | E18-T01, E18-T02 |
| E18-T04 | [Local-civil-day fire-time computation at the app edge via the injected clock (test-first)](E18-T04-local-civil-day-fire-time.md) | M | E18-T01, E02 |
| E18-T05 | [Reschedule reconciler: rebuildable derived cache, idempotent cancel-and-reschedule on start/change/reboot/permission (test-first)](E18-T05-reschedule-reconciler.md) | M | E18-T03, E18-T04 |
| E18-T06 | [ReminderRow widget: off-by-default switch, conditional time picker, honest one-liner — RTL + accessible](E18-T06-reminder-row-widget.md) | M | E18-T03, E10 |
| E18-T07 | [Reminder time rendering through CalendarPresenter + locale numerals (fa/ckb/ar)](E18-T07-reminder-time-rendering.md) | S | E18-T06, E02 |
| E18-T08 | [In-context OS notification permission (Android 13+ / iOS) with honest rationale and calm denied state](E18-T08-notification-permission.md) | M | E18-T03, E18-T06 |
| E18-T09 | [Optional catch-up note: independent off-by-default toggle + help-framed note mirroring the engine plan](E18-T09-catch-up-note.md) | M | E18-T03, E18-T05, E12 |
| E18-T10 | [fa/ckb/ar reminder copy + banned-phrase voice gate (row, one-liner, notification body, catch-up note)](E18-T10-reminder-copy-and-voice-gate.md) | M | E18-T06, E18-T09 |
| E18-T11 | [RTL + locale-numeral golden for the reminder row across fa/ckb/ar](E18-T11-reminder-row-golden.md) | S | E18-T06, E18-T07 |

## Risks

- **The reminder layer slides into engagement-farming.** A "while I'm here" second reminder, a streak chip, or an escalating cadence is exactly the *adab* breach this epic exists to prevent. *Mitigation:* one reminder per day at a fixed user-chosen time is structural; the five-dark-pattern audit (design-system 10 §11) is a release gate; any added cadence, streak, or re-engagement surface is rejected in review and the copy re-passes the banned-phrase gate (11 §9).
- **A single wrong sentence breaches *adab*.** Guilt/fear/loss copy, "you haven't opened the app in N days", or a cheerful "Welcome back!" is a documented harm, not a style slip. *Mitigation:* every reminder string passes the banned-phrase lint and the `domain-adab-and-religious-integrity` conscience-check in fa/ckb/ar; the notification body traces to C-043, the catch-up framing to C-042/C-041; resume-after-gap is silent (11 §3).
- **`DateTime.now()` creeps into the fire-time path.** Notification scheduling is a natural place to read the clock directly, which would drift the reminder a day across DST/timezone. *Mitigation:* "today" is injected at the app edge (engineering 07 §5); a CI grep bans `DateTime.now()` outside the clock provider; a DST/timezone vector pins the fire day (T4-style).
- **The OS schedule and the persisted prefs diverge.** A reboot, a restore, an OS notification-channel reset, or a duplicate `scheduleDaily` leaves a stale or doubled reminder. *Mitigation:* treat the OS schedule as a derived cache — `cancelAll` then re-derive from prefs on every trigger; an idempotency/convergence test asserts no duplicate or stale fire (E18-T05).
- **A denied notification permission becomes an obstruction.** Forcing or nagging for the permission is a dark pattern; silently failing leaves the user thinking a reminder is set when it is not. *Mitigation:* request in-context only on opt-in with an honest rationale; on denial show a calm, non-blocking state that explains and offers the OS settings path, and reflect the true on/off state in the row — never a forced action (design-system 10 §6/§11).
- **The notification is mistaken for a network/AI surface.** A reminder that looks like it "phones home" undermines the privacy guarantee this audience parses critically. *Mitigation:* the honest one-liner states local-only; the build contains no push/analytics SDK; the no-networking gate runs with the notification active; nothing about the user is ever sent (PRD §17, C1).

## References

- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/PRD.md — §14 (notifications, local only), §17 + R5 + C1 (privacy / no-microphone / offline), R3 + C6 (no gamification / no guilt-fear nags)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/design-system/10-privacy-and-trust-ux.md — §6 (network actions honest in context), §9 (the few real choices: protective default, reversible, one sentence), §10 (calm peripheral reminder layer), §11 (five dark-pattern release gate)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/design-system/11-voice-and-tone.md — §3 (tone-by-context matrix), §4 (empathy-then-path hard news), §6 (invitation not command), §9 (banned-phrase voice gate)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/engineering/07-dates-calendars-and-correctness.md — §4 (CalendarPresenter + downstream numerals), §5 (injected "today" / local civil day), §6 (Hijri honesty; reminder keys off the local civil day)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/science/CLAIMS.md — C-043 (calm/blameless reminders), C-042 (a miss doesn't undo progress), C-041 (no streaks/badges/guilt), C-008 / C-013 (re-spread / catch-up framing)
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/ui-reminder-row/SKILL.md — the reminder-row canonical pattern, Do/Don't, and checklist (primary skill)
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/ — eng-define-service-boundary, eng-create-riverpod-store, eng-add-localized-string, eng-rtl-and-bidi-layout, ui-numerals-calendar-text, ui-settings-picker, ui-catch-up-banner, domain-calendars-and-hifzdate, domain-adab-and-religious-integrity, eng-write-dart-test

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
