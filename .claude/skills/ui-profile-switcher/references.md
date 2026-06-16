# references — ui-profile-switcher

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/PRD.md` §15.3 (Profiles — local multi-user, no cloud) — **The rule.** Multiple profiles on one device (self, students, children); **teacher / halaqa mode** is a *quick profile switcher* so a teacher signs off each student in turn on the same device, with a **per-student `review_log`** and teacher labels; a **child profile is parent-managed, calm, no gamification**; profiles are **device-local**, and sharing across devices is **export/import only (§16), never a server**.

- `docs/PRD.md` §17 (Privacy & Security) — **No account, no PII.** "A profile is just a display name the user types." No login, no telemetry, no analytics; the only network use is the one-time public asset download — after which the app runs in airplane mode permanently. The switcher therefore collects only a name and opens no socket.

- `docs/design-system/07-components.md` §1/§2 (the daily-session list; building from the restrained set) — **Calm, flat construction.** Every component is built from the restrained Material 3 + Flutter widget set, flat at elevation Level 0–1, RTL-native across fa/ckb/ar; the all-done / informational surfaces are never confetti/streak/badge moments (Pillar 2, "calm, not cute"). The switcher and profile list inherit this restraint.

- `docs/design-system/10-privacy-and-trust-ux.md` §1 + §8 (privacy is religious; local-first ownership) — **The trust frame.** Privacy is a release-blocking, architecture-forced property (no account, no PII, "Data Not Collected" made true by the build); the user *owns* their record, it lives on the device, and is theirs to export or erase. Holding several profiles must not weaken any of this; a profile is owned local data, not an account.

## Supporting

- `docs/PRD.md` §8.2 (On-device teacher sign-off — talaqqī) — **The halaqa hand-off.** "In local halaqa mode the teacher switches between student profiles on one device" to sign off each against that student's append-only `review_log` with `source = teacher` + optional teacher label — no server. The switcher provides the switch; the verdict itself is **ui-teacher-signoff**.

- `docs/PRD.md` §5/§3 personas P4 + P5 — **Who it serves.** P4 the local teacher/halaqa needs "on-device multi-profile sign-off; no cloud"; P5 the parent needs "a child profile under the same device." The note: teacher/parent features are **local multi-profile on a shared device or via exported reports — never a server dashboard.**

- `docs/PRD.md` §16 (Backup & Data Portability) — **Cross-device sharing.** Export writes a versioned, encryption-optional backup of **all profiles, cards, logs, configs** to local storage / share-sheet; "teacher sees student data" works by export → user moves the file → import, with clear merge/replace semantics; erase wipes all local data. The app performs **no** network transfer.

- `docs/PRD.md` §19.3 (Determinism & offline guarantees) — **Injected "today".** The engine is pure and deterministic with no wall-clock inside ("today" is injected), so each profile's schedule is reproducible and golden-testable; a build-time check asserts no analytics/backend SDKs. The switcher must not introduce `DateTime.now()` or any socket.

- `docs/design-system/07-components.md` §6 (Grade band & component states) — **State model.** Enabled/pressed/disabled/focused/selected are drawn with M3 **state layers** over a role color; a **visible focus ring** is required (WCAG 2.2 SC 2.4.7); states mirror correctly in RTL and announce via `Semantics`. The active-profile chip / switch entries follow this exactly.

- `docs/design-system/07-components.md` §3 (the track chip — term-sets) — **Localized strings, never hardcoded.** Labels are regional **term-set strings** (a string resource, never a baked-in English glyph) that reflow in ckb's longer terms and wrap rather than truncate. Profile-switcher copy ("switch profile", "new profile", "teacher present") follows the same rule.

- `docs/design-system/07-components.md` §1 / §8 (anti-patterns) — **No celebration, no scoreboard.** The all-done state is never confetti/streak/badge; the map is never a leaderboard tile or "completion %" trophy. A profile switch and any per-profile progress must inherit both — no ranking students, no gamifying a child.

- `docs/design-system/10-privacy-and-trust-ux.md` §2/§3 (perceptibility; bidi-isolated links) — **Mixed runs.** Mixed Latin/RTL runs (URLs, and here user-typed Latin names) are wrapped in bidi isolation (FSI/PDI) so they never break the right-to-left line; numerals use the locale set. Apply to any Latin-script profile name in the switcher.

- `docs/design-system/10-privacy-and-trust-ux.md` §11 (dark-pattern release gate) — **No obstruction / forced action.** Switching, creating, renaming, exporting, and erasing a profile are each one straightforward action — never buried, never gated behind an account, upgrade, or unrelated step; the switcher is audited against the five dark-pattern strategies.

- `docs/PRD.md` §4 R3 / R5 — **The requirements behind it.** R3: no gamification of the sacred (binds the child profile and the switcher's quietness). R5: privacy is part of religious trust, no microphone, no telemetry — the profile system must not become a data-collection or surveillance surface.

## Sibling skills

- **ui-teacher-signoff** — the "Teacher present" `Switch.adaptive`, the teacher verdict, and the teacher-sourced marker that the halaqa loop switches into for each student.
- **ui-daily-session-list** — the finite three-track (manzil → near → new) session the switcher re-scopes to the active profile.
- **ui-page-card** — the recurring page row / cards rendered per active profile.
- **ui-retention-heatmap** — the per-profile whole-Quran retention map the switcher re-scopes.
- **domain-backup-format** — the offline `.hifzbackup` export/import (all profiles, merge/replace) by which a student's record reaches a teacher's device, plus erase.
- **eng-add-persisted-model** — the `profiles` table and the per-profile append-only `review_log` schema and migrations the switcher reads/writes.
- **eng-create-riverpod-store** — the app-scope active-profile provider + single write path (persist-before-republish) that scopes every query and mutation by `activeProfileId`.
- **eng-define-service-boundary** — the injected `CalendarDate` clock so each profile's schedule stays deterministic (no `DateTime.now()`).
- **eng-rtl-and-bidi-layout** — `EdgeInsetsDirectional` mirroring and FSI/PDI bidi isolation of user-typed names across fa/ckb/ar.
- **eng-add-localized-string** — the fa/ckb/ar term-set strings for the switcher and create/rename copy.
- **domain-adab-and-religious-integrity** — the always-on conscience-check on child-profile / no-gamification / servant-to-teacher / no-surveillance framing.
