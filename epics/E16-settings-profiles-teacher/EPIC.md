# E16 — Settings, Profiles & Teacher Sign-off

Build the grouped Settings surface and the device-local multi-profile system in one epic, because they share a single home and a single rule: a quiet preference change that re-renders the app without ever touching scripture or the engine's schedule. This delivers the language / calendar / numeral / term-set / theme / muṣḥaf pickers, the named cycle-preset and daily-budget controls, the self / student / child profiles on one device, and the teacher/halaqa "switch student → sign off → next" loop — all offline, account-free, microphone-free, and non-gamified.

## Why this epic exists

Two PRD promises that look like features are actually the app's trust posture made operable, and both land here. The first is **privacy-as-religious-trust** (R5, §17): the app holds a ḥāfiẓ's — and in halaqa mode, several students' and a child's — amāna with *no account, no login, no PII, no telemetry, no microphone*. A profile is "just a display name the user types" (§17), and the only way more than one person's record reaches another device is a user-moved export file (§15.3, §16) — there is no server because there is no socket. This epic is where that guarantee stops being prose and becomes the create-profile flow that asks for nothing but a name, the switcher that opens no socket, and the halaqa sign-off that writes only to a local append-only `review_log`. The second is **tradition-as-UI demoted-math** (§2, §7.6): the user steers the engine only through *named* choices a teacher recognizes — a cycle preset, a term-set, a calendar — never a "retention slider" or a target-R dial (design principle 1). Settings is the surface where every one of those named choices lives, and where the discipline that a preference is a *display transform over a single stored instant* (§10.3, localization-and-rtl §5) is enforced: changing the calendar re-renders dates and never perturbs a `due_at`; switching the numeral set reshapes digits and mutates nothing. Get that boundary wrong and a settings toggle silently rewrites the schedule — exactly the kind of invisible corruption the trust clamp exists to prevent. The teacher sign-off loop is the third reason: R6 makes talaqqī a first-class, *authoritative* grade that overrides the machine, and §15.3/§8.2 make it local-only (switch student on one device, sign off into that student's log). This epic owns the *halaqa wiring* — the profile switch that re-scopes the whole app before the teacher taps a verdict — so the servant-to-the-teacher covenant works on a shared phone with no dashboard and no surveillance.

## Scope

### In scope

- The **grouped Settings surface** (the Settings tab landing): calm one-handed template, content scrolls, rare/destructive controls in the hard-to-reach top corner; section grouping for Display, Cycle, Profiles, Backup, About.
- **Display-only single-choice pickers**, each a named radiogroup that persists a presentation choice through the single write path and re-renders the affected surfaces:
  - **UI language** (fa / ckb / ar — all RTL).
  - **Calendar system** (Solar-Hijri/Jalālī · Hijri Umm al-Qurā · Gregorian) — a display transform over the stored instant; never mutates a `due_at`.
  - **Numeral system** (Extended Arabic-Indic ۰۱۲ for fa/ckb · Arabic-Indic ٠١٢ for ar).
  - **Term-set** (the regional *sabaq / sabqi / manzil* vocabulary, switchable independently of UI language; ckb marked provisional).
  - **Theme** (light / sepia / dark) and Quran font-size / zoom preference.
  - **Muṣḥaf / riwāyah** (a *named* edition that states the riwāyah — "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"; stores the choice only).
- The **cycle-preset picker** (7-Manzil weekly khatm · 1 juz/day · ½ juz/day · 2 juz/day · Custom) + the **Pure-cycle mode** toggle + the **daily-budget** control, as the Settings-side surface that writes the already-defined `EngineConfig` (the cycle ceiling, near-window, new-lines/day, budget).
- The **device-local multi-profile system**: a profile = a typed display name (+ a parent-managed flag for a child); create / rename / delete; the quick **active-profile switcher** that re-scopes today's session, `review_log`, heat-map, and cards.
- The **teacher / halaqa loop wiring**: switch to a student profile → recite → teacher signs off into *that* student's append-only `review_log` → switch to next — device-local, no roster, no dashboard.
- The **delete-profile** destructive confirmation (consequence-stating, cancel-primary), distinct from the all-data erase owned by E17.
- A Settings **single write path** discipline test: every picker/profile mutation persists transactionally before republishing; an `HttpOverrides` offline guard proving no preference change or profile switch opens a socket.

### Out of scope

- The recite flow's **"Teacher present" in-flow toggle, the verdict surface, and the teacher-sourced marker** on a card/log → owned by **E12 (today-and-recite-grade)**; this epic only re-scopes to the right student before that flow runs.
- The **`EngineConfig` value type, the trust-clamp / `cycleCeilingDays` math, and `buildToday`** → owned by **E04 (scheduling-engine)**; the cycle picker here only writes config.
- The **muṣḥaf reader, glyph-font registration, and applying the chosen riwāyah to the page** → owned by **E13 (mushaf-reader)** / **E05 (quran-data-and-rendering)**; the picker only persists the named choice.
- The **export / import `.hifzbackup` file, restore semantics, the backup card, and all-data erase** → owned by **E17 (backup-and-restore)**.
- The **daily reminder toggle / time picker** → owned by **E18 (reminders)**.
- The **"The science we follow" / About-screen claims content** → owned by **E19 (science-screen-and-claims)** (this epic only places the About section entry that routes to it).
- The **`profiles` / `cycle_config` table schema and migrations, and the `review_log` model** → owned by **E03 (models-and-persistence)**; this epic consumes the DAOs.
- The **`CalendarPresenter` / `numberFormatFor(locale)` rendering primitive and the ARB string pipeline** → owned by **E09 (localization-rtl-foundation)**; pickers *call* them.

## Dependencies

### Depends on

- **E07 — app-shell-walking-skeleton** — the Settings tab, the `ShellRoute` bottom-nav slot, the Riverpod composition root, and `go_router` the Settings sub-screens hang off.
- **E09 — localization-rtl-foundation** — the `numberFormatFor(locale)` numeral path, the `CalendarPresenter`, the FSI/PDI isolation helper, and the ARB / term-set pipeline every picker renders and persists against.
- **E10 — mihrab-component-library** — the picker rows, selectable cards, switches, chips, and destructive-confirm scaffolding the Settings and profile surfaces are built from.
- **E12 — today-and-recite-grade** — the recite/grade flow and the in-flow teacher sign-off control that the halaqa loop hands a re-scoped student profile off to.

### Enables

E17 (the backup/erase card and the export-to-a-teacher path ride the profile system and the Settings surface this epic establishes), E18 (the reminder row lands in this Settings surface), E19 (the About section routes to the science screen), and the full halaqa journey (a teacher signs off several students on one device end-to-end).

## Foundation inputs

| Input | Where (doc/skill) | What this epic takes |
|---|---|---|
| Settings, presets & profiles spec | docs/PRD.md §15 | The named cycle presets, the term-set/calendar/numeral/language/muṣḥaf selectors, local multi-profile (self/student/child), the teacher/halaqa switch-and-sign-off loop |
| Privacy as trust | docs/PRD.md §17, R5 | A profile is a typed display name; no account/login/PII/telemetry/microphone; sharing is export/import, never a server |
| Servant to the teacher | docs/PRD.md R6, §8.2, §7.12 | Teacher sign-off is authoritative and overrides the machine; halaqa is local profile-switch-then-sign-off, written to the append-only `review_log` |
| Display transform, not mutation | docs/PRD.md §10.3, §7.6 | A calendar/numeral choice re-renders over a single stored instant; a preference never touches a `due_at` or engine state |
| Pickers & state model | docs/design-system/07-components.md §6 (+ §1, §7) | The M3 single-select state model (enabled/pressed/disabled/focused/selected via state layers); the teacher sign-off control anatomy; flat, calm chrome |
| RTL & localization contract | docs/design-system/12-localization-and-rtl.md §1–§8 | RTL-by-geometry, FSI/PDI isolation, locale numerals, user-selectable calendars, swappable term-sets, 100% ARB coverage, the Quran-is-never-localized boundary |
| Settings picker pattern | .claude/skills/ui-settings-picker | Named single-select rows, selected = shape+text, display-transform-not-mutation, muṣḥaf names-the-edition, persist-before-republish, no recommendation/score |
| Profile switcher pattern | .claude/skills/ui-profile-switcher | Typed-display-name-only profiles, quiet re-scoping switcher, halaqa loop, calm child profile, export/import-only sharing, injected clock |
| Teacher sign-off pattern | .claude/skills/ui-teacher-signoff | Source switch (self ≈0.5 → teacher 1.0), authoritative verdict, teacher-sourced marker, device-local halaqa, servant-to-teacher copy |
| Numerals & calendar rendering | .claude/skills/ui-numerals-calendar-text | The `numberFormatFor(locale)` / `CalendarPresenter` path the calendar & numeral pickers' options render through, downstream-numeral remap, Hijri-as-civil-courtesy |
| Cycle-preset control | .claude/skills/ui-cycle-preset-picker | Named cycle cards (never a slider), Pure-cycle as fidelity, Custom as four bounded fields, writes only `EngineConfig` |
| Destructive confirm | .claude/skills/ui-destructive-confirm | The delete-profile consequence dialog: cancel-primary, thumb-zone safety margin, honest not obstructive |
| Single write path | .claude/skills/eng-create-riverpod-store | The persist-before-republish notifier method behind every preference and the active-profile provider that keys every query |
| String & RTL plumbing | .claude/skills/eng-add-localized-string, eng-rtl-and-bidi-layout | ARB keys (fa/ckb/ar) for every option and label; `EdgeInsetsDirectional`, bidi-isolated names, locale numerals |
| Persistence surface | .claude/skills/eng-add-persisted-model, eng-define-service-boundary | The `profiles` / `cycle_config` DAOs consumed; the injected `CalendarDate` clock — never `DateTime.now()` |
| Feature scaffold & tests | .claude/skills/eng-add-feature-module, eng-write-dart-test | The `features/settings` + `profiles` module anatomy; widget/RTL-golden/offline-guard tests |

## Deliverables

- [ ] A grouped **Settings screen** (dumb View + 1:1 view-model) in `features/settings`, sectioned Display / Cycle / Profiles / Backup / About, on the calm one-handed template with destructive controls in the top corner.
- [ ] Six **display-only single-choice pickers** (language, calendar, numeral, term-set, theme, muṣḥaf/riwāyah), each a named radiogroup persisting through one notifier method and re-rendering its affected surfaces; the calendar and numeral options render through E09's `CalendarPresenter` / `numberFormatFor`.
- [ ] The **cycle-preset picker** (named cards), the **Pure-cycle** toggle, and the **daily-budget** control, writing only `EngineConfig` and triggering a deterministic `buildToday` rebuild.
- [ ] The **multi-profile system** in `features`/`profiles`: a `Profile` value type (display name + parent-managed flag, no PII), create / rename / delete flows, and the `activeProfileProvider` + `ProfilesNotifier` single write path.
- [ ] The **quick active-profile switcher** widget (RTL, bidi-isolated names, `Semantics`) that re-scopes today's session, `review_log`, heat-map, and cards.
- [ ] The **teacher / halaqa loop** wiring: switch student → (E12 recite + sign-off) → next, each write landing in that student's own append-only `review_log`; no remote dashboard.
- [ ] The **delete-profile destructive confirmation** (consequence-stating, cancel-primary), distinct from E17's all-data erase.
- [ ] Widget / RTL-golden / offline-guard **test suites** per surface, including: a calendar-switch leaves the stored instant unchanged; a switch re-scopes the read models; no `Slider` in any picker tree; an `HttpOverrides` guard proving no socket opens on any preference change or profile switch.
- [ ] Full **fa/ckb/ar ARB coverage** for every option and label (ckb term-set marked provisional); per-locale RTL golden screenshots of the Settings surface and switcher.

## Definition of Done

- [ ] **Offline / no-network:** every picker, profile mutation, and profile switch works in airplane mode; an `HttpOverrides` test proves no socket opens; sharing across devices is export/import only (E17), never a transfer this epic performs.
- [ ] **No-AI / no-microphone:** nothing here introduces a model, inference, "recommended for you", telemetry on a chosen option, or any audio/recording path; defaults are plain per-locale constants (Jalālī for fa, Umm al-Qurā lead for ar, the locale's numeral block).
- [ ] **Display-transform discipline (non-negotiable):** a unit/widget test proves switching the calendar or numeral system re-renders over the unchanged stored instant and mutates **no** `due_at` or engine state; no picker computes a date or reorders a page.
- [ ] **Text fidelity:** the muṣḥaf/riwāyah picker stores a *named* edition and states the riwāyah; it never re-typesets, mirrors, translates, applies UI numerals/fonts to the glyph page, or calls the muṣḥaf "the Quran" in the absolute.
- [ ] **Single write path:** every preference and profile mutation persists transactionally **before** republishing; no View writes persisted state; the active-profile provider keys every scoped query; "today" is the injected `CalendarDate`, never `DateTime.now()`.
- [ ] **Servant to the teacher:** the halaqa loop re-scopes to a student before E12's sign-off; a teacher verdict (owned by E12) is never silently re-graded here; copy is autonomy-supportive ("for your teacher to confirm"), never app-as-authority.
- [ ] **Privacy:** a profile is created from only a typed display name (+ parent-managed flag for a child); no email/phone/login/PII anywhere; no per-profile score, rank, leaderboard, or "completion %"; the switcher is no server dashboard.
- [ ] **No gamification:** switching a preference or a profile is quiet — no confetti, chime, streak, badge, or haptic fanfare; a child profile carries no gamification or guilt/fear/loss copy; no preference framed as making revision "lighter", "safe", or "done".
- [ ] **RTL + fa/ckb/ar localization:** all surfaces are RTL by `EdgeInsetsDirectional`; every option/label is an ARB string in fa/ckb/ar (ckb term-set marked provisional, no hardcoded English); numbers use the locale set via `intl`; mixed runs are FSI/PDI-isolated; per-locale RTL goldens pass.
- [ ] **Accessibility:** each option is a ≥48dp `touch.min` row, a labelled radiogroup member with a selected/not-selected value and a visible focus ring; OS text scale never shrinks a row below 48dp; states mirror correctly under RTL; the destructive delete dialog is cancel-primary.
- [ ] **Sect-neutral adab:** any preference, profile, or Hijri/observance copy passes the **domain-adab-and-religious-integrity** conscience-check; the Hijri option is a labelled civil-courtesy date with the standing caveat, issuing no observance ruling.
- [ ] **Tests:** widget tests for selection-routes-through-controller and no-`Slider`; RTL goldens per locale; the calendar-switch-preserves-instant test; the switch-re-scopes test; the halaqa-writes-correct-student-`review_log` test; the offline guard — all green in CI on every PR.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E16-T01 | [Grouped Settings screen scaffold + sectioned one-handed template](E16-T01-settings-screen-scaffold.md) | M | E07, E10 |
| E16-T02 | [Display-only single-choice picker primitive (named radiogroup, selected=shape+text, persist-before-republish)](E16-T02-settings-picker-primitive.md) | M | E16-T01, E09, E10 |
| E16-T03 | [Language, theme & font-size/zoom pickers](E16-T03-language-theme-pickers.md) | S | E16-T02 |
| E16-T04 | [Calendar & numeral pickers as display transforms over the stored instant (test-first: switch never mutates a due_at)](E16-T04-calendar-numeral-pickers.md) | M | E16-T02, E09 |
| E16-T05 | [Term-set picker (regional sabaq/sabqi/manzil vocabulary, ckb provisional)](E16-T05-term-set-picker.md) | S | E16-T02, E09 |
| E16-T06 | [Muṣḥaf / riwāyah picker (names the edition, states the riwāyah, never re-typesets)](E16-T06-mushaf-riwayah-picker.md) | S | E16-T02 |
| E16-T07 | [Cycle-preset picker + Pure-cycle toggle + daily-budget control (writes EngineConfig only)](E16-T07-cycle-preset-budget.md) | M | E16-T02 |
| E16-T08 | [Profile model + ProfilesNotifier + activeProfileProvider single write path (create/rename, no PII)](E16-T08-profile-model-store.md) | M | E16-T01, E09 |
| E16-T09 | [Quick active-profile switcher that re-scopes the app (test-first: switch re-scopes read models, opens no socket)](E16-T09-profile-switcher.md) | M | E16-T08 |
| E16-T10 | [Teacher / halaqa loop wiring: switch student → sign off (E12) → next, into that student's review_log](E16-T10-halaqa-loop.md) | M | E16-T09, E12 |
| E16-T11 | [Delete-profile destructive confirmation (cancel-primary, consequence-stating)](E16-T11-delete-profile-confirm.md) | S | E16-T08 |
| E16-T12 | [Settings & profiles localization + per-locale RTL goldens + offline guard](E16-T12-l10n-rtl-goldens.md) | M | E16-T03, E16-T04, E16-T05, E16-T06, E16-T07, E16-T09 |

## Risks

- **A "harmless" picker silently mutates the schedule.** A calendar or numeral switch that recomputes a `due_at` is the exact invisible corruption the trust clamp guards against. *Mitigation:* the picker primitive is a pure display transform by construction; T04 is test-first with an explicit "switch leaves the stored instant and every `due_at` unchanged" assertion; the calendar choice routes through E09's `CalendarPresenter`, never a view-built calendar.
- **The cycle picker reaches past "store a choice" into engine math.** It is tempting to compute or reorder here. *Mitigation:* T07 writes only `EngineConfig` fields and triggers a deterministic `buildToday` rebuild; no `due_at`, no `target_R`, no D/S/R surfaces anywhere in Settings; the engine math stays in E04.
- **Halaqa wiring duplicates or overrides the teacher verdict.** Re-implementing the grade band or letting a switch re-grade would break R6. *Mitigation:* T10 only re-scopes the active profile and hands off to E12's sign-off control unchanged; a test asserts each sign-off lands in the *switched* student's append-only `review_log`, and no Again/Hard/Good/Easy band is drawn in this epic.
- **A profile surface drifts toward an account or a roster.** A "teacher dashboard", a login, or a per-student score would violate §17 and R3. *Mitigation:* the `Profile` type holds only a display name + parent-managed flag; no PII field exists to fill; no per-profile percentage/rank renders; an `HttpOverrides` guard proves the switcher opens no socket; child copy passes the adab check.
- **ckb term-set ships as if final.** Locking provisional Sorani terminology pre-review breaks the localization contract. *Mitigation:* the ckb term-set is data-only and marked **provisional** in-surface and in ARB, correctable without code change (localization-and-rtl §6).
- **Delete-profile becomes a dark pattern or is confused with full erase.** An obstructive or mislabeled destructive flow erodes trust. *Mitigation:* T11 is an honest cancel-primary consequence dialog (ui-destructive-confirm), scoped to one profile and explicitly distinct from E17's all-data erase.

## References

- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/PRD.md — §15 (settings, presets & profiles), §17 + R5 (privacy/no-account/no-mic), R6 + §8.2 + §7.12 (servant-to-teacher, halaqa), §10.3 + §7.6 (display-transform / trust clamp), §13.3–§13.4 (numerals, calendars, term-sets), §18 (accessibility)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/design-system/12-localization-and-rtl.md — §1 (RTL by geometry), §2 (icon mirroring; muṣḥaf never mirrored), §3 (FSI/PDI isolation), §4 (locale numerals), §5 (user-selectable calendars; display-over-instant), §6 (swappable term-sets; ckb provisional), §7 (ARB coverage; canonical ckb), §8 (the Quran is never localized)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/design-system/07-components.md — §6 (the explicit component state model; M3 state layers; focus ring), §7 (teacher sign-off control), §1 (calm/flat chrome, no celebration)
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/ui-settings-picker/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/ui-profile-switcher/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/ui-teacher-signoff/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/ui-numerals-calendar-text/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/ui-cycle-preset-picker/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/ui-destructive-confirm/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-create-riverpod-store/SKILL.md, eng-add-localized-string/SKILL.md, eng-rtl-and-bidi-layout/SKILL.md, eng-add-persisted-model/SKILL.md, eng-define-service-boundary/SKILL.md, eng-add-feature-module/SKILL.md, eng-write-dart-test/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/domain-adab-and-religious-integrity/SKILL.md
