---
name: ui-profile-switcher
description: Build or modify the Hifz app's local multi-profile system — the quick profile switcher (self / students / child) on one device, the teacher/halaqa "switch student → sign off → next" loop, and parent-managed child profiles. Use whenever placing the active-profile chip/switcher, the profile list/create/rename flow, the halaqa per-student switch, or a child profile under one device. Device-local only; sharing is via export/import, never a server.
---

# ui-profile-switcher

The **local multi-profile** layer: several profiles (self, students, a child) on one device, with a **quick switcher** that re-scopes the whole app — the daily session, the `review_log`, the heat-map, the cards — to the active profile. Its headline use is **teacher / halaqa mode**: a teacher switches between student profiles on the same device to sign off each in turn, against that student's own append-only `review_log`. A profile is just a display name the user types — no account, no login, no PII — and profiles never leave the device except as a user-initiated export/import file.

This control is the UI face of PRD §15.3 (profiles — local multi-user, no cloud), persona P4 (the local teacher/halaqa) and P5 (the parent). It is the one place the app holds *more than one person's* hifz record — and it must do so the same private, offline, non-gamified way it holds one.

## When to use

Use when building or placing:
- the **active-profile chip / quick switcher** (the affordance that shows whose data is on screen and switches it)
- the **profile list, create, and rename** flow (a profile = a typed display name, no account)
- the **teacher / halaqa loop**: switch to a student → recite → teacher signs off → switch to next student, on one device
- a **parent-managed child profile** under the same device — calm, no gamification

Do NOT use this skill for:
- the **"Teacher present" toggle**, the teacher verdict, or the teacher-sourced marker inside the recite flow → use **ui-teacher-signoff**
- the daily three-track session that the switcher re-scopes → use **ui-daily-session-list**
- the recurring page row / cards re-scoped per profile → use **ui-page-card**
- the per-profile retention map → use **ui-retention-heatmap**
- the **export/import file** that moves a student's data to a teacher's device (and the all-profiles backup, erase) → use **domain-backup-format**
- the **`profiles` table / per-profile `review_log` schema and migrations** → use **eng-add-persisted-model**
- the **active-profile provider / single write path** that scopes every query and mutation → use **eng-create-riverpod-store**
- the religious conscience-check on child-profile copy, no-gamification, servant-to-teacher framing → use **domain-adab-and-religious-integrity**

The switcher *re-scopes*; it does not grade. If you are drawing Again/Hard/Good/Easy, a "Teacher present" switch, or a verdict, you are in **ui-teacher-signoff** / **ui-recite-grade-flow**, not here.

## The canonical pattern

1. **A profile is a typed display name — no account, no login, no PII.** Creating a profile collects only a display name (and, for a child, that it is parent-managed); never an email, phone, login, or any identifier. This is the privacy guarantee from §17 made structural: there is no per-user credential because there is no server. `docs/PRD.md` §17 ("A profile is just a display name the user types"; no account/login/PII) + §15.3; the no-collection / local-first posture in `docs/design-system/10-privacy-and-trust-ux.md` §1 (architecture-forced "no data collected") and §8 (local-first ownership).

2. **The switcher is a quick, calm affordance — not a server dashboard.** Surface the active profile and the switch as a quiet control (an active-profile chip opening a short list, or a compact menu), reachable in the bottom thumb band, never a remote "teacher dashboard" or roster of surveilled students. Built from the restrained M3/Flutter widget set; cards/list items sit flat at elevation Level 0–1, no brand tint to "pop". `docs/PRD.md` §15.3 ("a quick profile switcher"; device-local) + §5.1 P4 note ("never a server dashboard"); `docs/design-system/07-components.md` §1/§2 (built from the restrained M3 widget set, flat Level 0–1, calm not cute) and `docs/design-system/10-privacy-and-trust-ux.md` §11 (no dark patterns — no obstruction/forced action on switch).

3. **Switching re-scopes the whole app through the single write path; it never mutates state in a view.** The active profile is one piece of app-scope state; switching it re-points every read model (today's session, `review_log`, heat-map, cards) at that profile and is persisted **transactionally before** republishing in-memory state, through a store/repository method — never a view writing persisted state directly. `docs/PRD.md` §15.3 (per-student `review_log`; profiles device-local); route via **eng-create-riverpod-store** (single write path, persist-before-republish; active-profile provider keys every query); the data model via **eng-add-persisted-model**.

4. **Teacher / halaqa mode = switch student → sign off → next, on one device.** The halaqa loop is purely local: select a student profile, run the recite flow, the physically-present teacher signs off into *that* student's append-only `review_log`, then switch to the next student. The switcher is the only halaqa-specific UI here; the sign-off itself is **ui-teacher-signoff**. No network, no account, no remote roster. `docs/PRD.md` §15.3 (teacher/halaqa mode: quick switcher, per-student `review_log` with teacher labels) + §8.2 (in local halaqa mode the teacher switches between profiles); the sign-off control is **ui-teacher-signoff**.

5. **The child profile is parent-managed and calm — no gamification, ever.** A child profile is created and managed by the parent and carries the same non-negotiable: no streaks, badges, scores, confetti, or competitive framing, and no guilt/fear/loss copy — for a child least of all. The all-done and progress surfaces stay informational, never a reward. `docs/PRD.md` §15.3 ("Child profile: parent-managed; calm, no gamification") + R3/C6; `docs/design-system/07-components.md` §1 anti-patterns (no confetti/streak/badge on the all-done state) and §8 (the heat-map is never a scoreboard); enforce via **domain-adab-and-religious-integrity**.

6. **Profiles are device-local; cross-device sharing is export/import only — never a socket.** Moving a student's record to a teacher's device, or a teacher's roster between phones, happens by exporting an `.hifzbackup` file the user moves by any means and imports — the app performs **no** network transfer of user data, and the switcher opens **no** socket. `docs/PRD.md` §15.3 ("sharing across devices is via export/import (§16), never a server") + §16; `docs/design-system/10-privacy-and-trust-ux.md` §8 (backup is a file you keep; we never upload it) — file format and merge/replace via **domain-backup-format**.

7. **"today" is injected; per-profile schedules are deterministic.** Nothing in the switcher reads `DateTime.now()`; the active profile's day is computed by the pure engine against an injected `CalendarDate`, so a profile's session is reproducible and golden-testable. `docs/PRD.md` §19.3 (engine is pure; "today" is injected; reproducible schedules) — inject the clock via **eng-define-service-boundary**, never `DateTime.now()` in the switcher or its view-model.

8. **RTL-native, localized term-sets, fully semantic.** The switcher, profile names, and create/rename copy are laid out with `EdgeInsetsDirectional` and mirror across **fa/ckb/ar**; user-typed names are bidi-isolated (FSI/PDI) so a mixed Latin/Arabic name never breaks the right-to-left row; every control carries a localized `Semantics` label + state ("Active profile: Aïsha; switch profile"), with M3 state layers and a visible focus ring. `docs/design-system/07-components.md` §6 (M3 state layers, visible focus ring, RTL mirroring, `Semantics`) and §3 (term-set strings, never hardcoded English); `docs/design-system/10-privacy-and-trust-ux.md` §2/§3 (bidi-isolated mixed runs); RTL/bidi mechanics via **eng-rtl-and-bidi-layout**, strings via **eng-add-localized-string**.

9. **Switching is quiet — no celebration, no per-profile "score".** Changing profile fires no confetti, chime, streak, or haptic fanfare; it is a restrained state change. The switcher never shows a per-profile percentage, rank, or "completion %" to compare students or shame a child. `docs/design-system/07-components.md` §1 / §8 anti-patterns (no celebration; the map is never a leaderboard/"completion %" trophy); `docs/PRD.md` R3; motion stays restrained per `docs/design-system/06-motion-and-haptics.md`.

## Do / Don't

| Do | Don't |
|---|---|
| Collect only a typed display name per profile (parent-managed flag for a child) | Ask for an email, phone, login, or any account/PII to create a profile |
| Surface a quiet active-profile chip / compact switcher in the thumb band | Build a "teacher dashboard", student roster, or any remote/server view |
| Switch by setting one app-scope active-profile state through a store method (persist-then-republish) | Mutate the active profile or any persisted state directly inside a view |
| Re-scope today's session, `review_log`, heat-map, and cards to the active profile | Mix two profiles' data on one screen, or leak one student's record into another |
| Halaqa = switch student → recite → teacher signs off → next, on one device | Sync students to a server, or sign off remotely (sign-off is **ui-teacher-signoff**) |
| Keep child + every profile calm: no streaks/badges/scores/confetti, no guilt copy | Gamify a child profile, rank students, or show a per-profile "completion %" |
| Share across devices via `.hifzbackup` export/import only | Open a socket to transfer a profile, or imply the switcher syncs anywhere |
| Compute each profile's day from the injected `CalendarDate` (engine, pure) | Read `DateTime.now()` in the switcher or its view-model |
| `EdgeInsetsDirectional`, bidi-isolated names, localized `Semantics` in fa/ckb/ar | Hardcode LTR layout, let a Latin name break the RTL row, or skip the focus ring |
| Switch quietly (state change only) | Celebrate a profile switch with confetti, a chime, or a haptic fanfare |

## Checklist

Before this control is done:

- [ ] A profile is created from **only** a typed display name (+ a parent-managed flag for a child); no email, phone, login, or PII is collected anywhere.
- [ ] The switcher is a quiet, device-local affordance (active-profile chip → short list / compact menu) in the thumb band — **no** server dashboard, remote roster, or networked "teacher mode".
- [ ] Switching sets one app-scope active-profile state through a store/repository method that **persists transactionally before** republishing; no view mutates persisted state.
- [ ] Switching re-scopes today's session, the `review_log`, the heat-map, and the cards to the active profile; no two profiles' data appear together or leak across profiles.
- [ ] Halaqa path is switch student → recite → **ui-teacher-signoff** → next student, on one device, each write landing in that student's own append-only `review_log`; no remote sign-off.
- [ ] The child profile is parent-managed and calm: no streaks/badges/scores/confetti, no per-profile percentage/rank, no guilt/fear/loss copy.
- [ ] Cross-device sharing is **export/import only** (`.hifzbackup` via **domain-backup-format**); the switcher opens **no** socket and performs no network transfer of user data.
- [ ] Each profile's day/schedule is computed by the pure engine from an **injected** `CalendarDate`; no `DateTime.now()` in the switcher or its view-model.
- [ ] The switcher, names, and create/rename copy are RTL-native via `EdgeInsetsDirectional`, with bidi-isolated user-typed names and localized strings + `Semantics` label/state in **fa, ckb, ar**; M3 state layers and a visible focus ring are present.
- [ ] Switching is quiet — no confetti, chime, streak bump, or haptic fanfare; no per-profile leaderboard or "completion %".
- [ ] No microphone, recording, speech-to-text, AI, or auto mistake-detection is introduced by this control.
- [ ] Widget/golden tests cover: create/rename a profile; switch re-scopes the read models; halaqa switch writes the correct student's `review_log`; RTL goldens in fa/ckb/ar; an `HttpOverrides` offline guard proving no socket opens on switch.

The profile switcher is where the app holds more than one person's amāna. If any surface ranks students, gamifies a child, asks for an account, or implies a server is watching, stop and run it through **domain-adab-and-religious-integrity** and **ui** privacy review before shipping.

## Files

- `template.dart` — copy-paste scaffold: the `Profile` value type (display name + parent-managed flag, no PII), the `activeProfileProvider` + `ProfilesNotifier` (create/rename/switch through the single write path, persist-then-republish), the `ProfileSwitcher` quick-switch widget (RTL + bidi-isolated names + `Semantics`), and the halaqa "switch → sign off → next" note. Fill the `// TODO` markers; reference tokens (`type.*`, `color.*`, `space.*`, `touch.min`, `motion.*`) and engine/data names (`activeProfileId`, `review_log`, `CalendarDate`) by name only.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **ui-teacher-signoff** (the "Teacher present" toggle + verdict the halaqa loop hands off to), **ui-daily-session-list** (the three-track session the switcher re-scopes), **ui-page-card** (the per-profile cards), **ui-retention-heatmap** (the per-profile map), **domain-backup-format** (the `.hifzbackup` export/import that shares a profile across devices, plus all-profiles backup + erase), **eng-add-persisted-model** (the `profiles` table + per-profile `review_log` schema and migrations), **eng-create-riverpod-store** (the active-profile provider + single write path that scopes every query/mutation), **eng-define-service-boundary** (the injected `CalendarDate` clock), **eng-rtl-and-bidi-layout** (RTL mirroring + bidi isolation of typed names), **eng-add-localized-string** (the term-set strings in fa/ckb/ar), **domain-adab-and-religious-integrity** (the conscience-check on child-profile / no-gamification / servant-to-teacher copy).
