# E16-T08 — Profile model + ProfilesNotifier + activeProfileProvider: the no-PII single write path (create/rename)

| | |
|---|---|
| **Epic** | [E16 — Settings, Profiles & Teacher Sign-off](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E16-T01, E09 |
| **Skills** | eng-add-persisted-model, eng-create-riverpod-store, ui-profile-switcher, eng-define-service-boundary, domain-adab-and-religious-integrity, eng-write-dart-test |

## Goal

Build the device-local multi-profile core that PRD §15.3/§17 promise: an immutable **`Profile` value type** (a typed display name + a `role` of self/student/child + a parent-managed flag for a child — **no PII field exists to fill**), the **`ProfilesNotifier`** whose create and rename mutations each route through one named repository method that commits a single Drift transaction **before** republishing in-memory state, and the **`activeProfileProvider`** (`Notifier<ProfileId>`) that keys every profile-scoped query — today's session, the `review_log`, the heat-map, the cards. A profile is "just a display name the user types" (§17): the create flow asks for nothing but a name (and, for a child, that it is parent-managed). This task consumes the E03 `profiles` DAO/schema — it defines no table and no migration. The switcher *widget* is E16-T09; the halaqa loop is E16-T10; delete's confirmation UI is E16-T11.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §15.3 | Profiles are local multi-user, no cloud: self / students / children on one device; teacher/halaqa switches per student into a per-student `review_log`; a **child profile is parent-managed, calm, no gamification**; sharing across devices is export/import (§16), **never a server** |
| `docs/PRD.md` §17, R5 | The privacy posture this task makes structural: "No account, no login, no PII required. **A profile is just a display name the user types**"; no telemetry; no microphone — there is no per-user credential because there is no server |
| `docs/PRD.md` §10.2 | The consumed `profile` row shape: `profile_id, display_name, role /* self\|student\|child */, locale, mushaf_id, created_at, settings_json` — no PII column exists; `app_meta` holds app-level keys including `active_profile` |
| `docs/PRD.md` §10.3 | `review_log` is append-only; strength roll-ups are **computed, never stored** — so no field of `Profile` may cache a health %, score, or rank |
| `docs/engineering/04-flutter-and-state-patterns.md` §4 | The single write path: every mutation is a named repository method opening one `db.transaction`, committed **before** any in-memory/stream state becomes observable; "switch the active profile's settings" is explicitly one of the named mutating entry points; no optimistic republish, no debounced save |
| `docs/engineering/04-flutter-and-state-patterns.md` §1.2, §5 | The composition root + profile gate: `activeProfileProvider` is a `NotifierProvider<ActiveProfileController, ProfileId>`; switching changes **one value** and every `family`-keyed feature provider recomputes for the new id; keys are stable equatable `ProfileId` values; **no global mutable "current user"** and no un-keyed "current profile data" provider |
| `docs/engineering/05-persistence-and-encryption.md` §2 | The consumed schema discipline: `STRICT` tables, `CHECK (role IN (...))` on enumerable columns, invariants in SQLite not Dart; derived state never persisted — this task writes through E03's DAO and adds no DDL |
| `docs/engineering/05-persistence-and-encryption.md` §3 | Crash safety: WAL + `synchronous = FULL` on the write connection; one transaction per mutation; when the write `Future` resolves the change is durably on disk — the notifier's `await` is the durability line |
| `docs/engineering/07-dates-calendars-and-correctness.md` §5 | "Today" is injected: a clock is read only at the app edge; `DateTime.now()` in shell logic is refused and CI-grepped — `createdAt` is read from the injected clock, never a wall-clock call in the notifier |
| `docs/design-system/12-localization-and-rtl.md` §3 | The user-typed display name is a mixed-direction run inside RTL chrome: wrap it in **FSI/PDI isolation** (never a hard-spliced substring) so a Latin/Arabic name neither reorders the row nor breaks screen-reader order; isolate the token, keep the label a single `Text` run |
| Skill `eng-create-riverpod-store` (+ `template.dart`) | Pattern 3 (persist transactionally **before** republishing; the controller's `await` returns only after commit), Pattern 8 (no `DateTime.now()` — the injected `CalendarDate` clock), Pattern 9 (`family` + `autoDispose` per-profile keying), Pattern 10 (the active-profile `Notifier` is the **only** profile gate), Pattern 12 (the store holds value types, never rendered words or scores) |
| Skill `eng-add-persisted-model` | Pattern 1 (the immutable value type lives in `models`, no Drift import — a `package:drift` import in `models` is a compile error), Pattern 2 (closed sets are enums — `role`; booleans as assertions — `isParentManaged`), Pattern 8 (`settings_json` carries small schema-shaped data only, never health facts) |
| Skill `ui-profile-switcher` (+ `template.dart`) | Pattern 1 (a profile = a typed display name, no account/login/PII), Pattern 3 (switching re-scopes the whole app through the single write path), Pattern 6 (device-local; sharing is export/import only — **never a socket**), Pattern 7 (the injected clock), Pattern 9 (no per-profile "score", quiet switching) |
| Skill `eng-define-service-boundary` | The clock as the canonical boundary: an interface returning a `CalendarDate`, exposed as a `Provider`, overridden once at the composition root; tests install a **fixed fake clock** with `overrideWith` — no mock framework |
| Skill `domain-adab-and-religious-integrity` | The conscience pass on create/rename copy and the child profile: no gamification, no guilt/fear/loss framing, no rank; any reassurance line stays calm and factual |
| `docs/science/CLAIMS.md` — **C-048** | "The app works fully offline and never records your voice or sends your data anywhere" — the privacy reassurance behind create-a-profile-asks-only-a-name; if the create sheet shows a reassurance line, its copy traces here |
| `docs/science/CLAIMS.md` — **C-044** | The **guard** claim: progress is your own, never a ranking — no per-profile rank, score, leaderboard, or "completion %" may exist as a field or render on any profile surface |
| Sibling **E16-T01** | Supplies the Settings scaffold's **Profiles section** slot where the profile list and the create/rename entry points live; this task fills that slot, it does not re-build the scaffold |
| Siblings **E16-T09 / T10 / T11** | T09 owns the quick-switcher **widget** (test-first re-scope); T10 owns the halaqa switch-then-sign-off wiring; T11 owns delete's destructive confirmation UI — this task supplies the notifier/provider surface they all consume and builds none of their chrome |
| Cross-epic **E03** | Owns the `profiles` table, DAO, and migrations (and `app_meta`); this task **consumes** the DAO through a repository — defining a Drift table, column, or migration here is a scope violation |

## Implementation notes

This task is the model/store layer of the profile system plus the minimal create/rename sheet — no switcher chrome, no delete dialog, no engine call, no schema change. The write-path and no-PII invariants are **test-first**: the recording-repository ordering test and the structural no-PII test are written before the notifier body.

1. **Files:**
   - `packages/models/lib/src/profile.dart` — the immutable `Profile` value type (`final` fields, `copyWith`): `ProfileId id`, `String displayName`, `ProfileRole role` (enum `self | student | child`, mirroring the schema `CHECK`), `bool isParentManaged` (an assertion, meaningful only for `child`), `locale`, `mushafId`, `createdAt`, and the small decode-validated settings value. **No other field.** No Drift, no Flutter import.
   - `features/lib/src/profiles/profiles_providers.dart` — `profilesProvider` (a `StreamProvider` over the E03 Drift query, the reactive profile list), `ProfilesNotifier` (create/rename commands), and `activeProfileProvider` (`Notifier<ProfileId>`).
   - `features/lib/src/profiles/widgets/profile_edit_sheet.dart` — the minimal create/rename sheet reachable from T01's Profiles section: **one text field** (the display name), a role choice, and — only when the role is child — the parent-managed flag. No other input exists on the surface.
2. **No PII, structurally.** There is no email, phone, username, password, photo, birthday, or token field anywhere in `Profile`, the notifier, the repository signature, or the sheet — nothing exists to fill (§17; ui-profile-switcher Pattern 1). Identity is the opaque `ProfileId`. The no-PII test asserts the field set is exactly the allowed one, so adding a credential "for later" fails CI.
3. **Create/rename through the single write path.** `createProfile(displayName, role, {isParentManaged})` and `renameProfile(id, displayName)` are the only mutation surfaces; each calls one named `ProfilesRepository` method that opens one `db.transaction` against the E03 DAO and **commits before** the notifier republishes or the Drift stream re-emits (04 §4; eng-create-riverpod-store Pattern 3). No widget or controller imports a DAO. Failure propagates as a calm retry state — never a silent swallow, never a partially-visible profile.
4. **`activeProfileProvider` keys everything.** The active profile is one `Notifier<ProfileId>` value — the only profile gate (04 §1.2). Setting it persists to E03's `app_meta` `active_profile` key through the same write path, so a cold start restores the same profile; every profile-scoped provider (today's session, `review_log` reads, heat-map, cards) is `family`-keyed by the stable `ProfileId` (04 §5) — switching changes one value and every keyed provider recomputes with no leakage between students.
5. **`createdAt` comes from the injected clock.** The notifier reads the injected `CalendarDate` clock boundary (eng-define-service-boundary; 07 §5) — never `DateTime.now()` in the notifier, sheet, or repository call site; the stored column shape is E03's. Tests override the clock provider with a fixed fake.
6. **The typed name is bidi-isolated everywhere it renders.** The display name in the list row and the rename sheet is wrapped via E09's FSI/PDI isolation helper as an isolated placeholder — never spliced raw into a localized string (12-localization-and-rtl §3); the surrounding label stays one `Text` run.
7. **No score, quietly.** No per-profile percentage, rank, streak, or "completion %" exists as a field or render (C-044; §10.3 — roll-ups are computed elsewhere, never cached here); creating or renaming fires no confetti, chime, or haptic fanfare; child-profile copy passes the adab conscience check.
8. **Optional reassurance line, sourced.** If the create sheet carries a one-line privacy reassurance ("works fully offline; your data never leaves this device"), its copy traces to **C-048** and stays calm and factual — no other claim renders on this surface.
9. **Strings via the ARB pipeline** (eng-add-localized-string conventions): every label (create, rename, role names, the parent-managed flag, `Semantics` labels) is an `l10n.*` key in fa/ckb/ar; layout is RTL by geometry (`EdgeInsetsDirectional`); ≥48dp targets; per-locale goldens are consolidated in E16-T12.
10. **Pitfalls to avoid:** defining a Drift table/column/migration here (E03 owns them); any PII field, even optional; republishing before the commit resolves; an un-keyed "current profile" provider or a mutable `family` key; `DateTime.now()` anywhere in the task's files; building switcher chrome (T09), halaqa wiring (T10), or the delete dialog (T11); a per-profile score/rank; any code path that could open a socket.

## Acceptance criteria

- [ ] `Profile` lives in the `models` package as an immutable value type whose fields mirror PRD §10.2 exactly (`id`, `displayName`, `role` enum, `isParentManaged`, `locale`, `mushafId`, `createdAt`, settings) — **no PII field of any kind**; no `package:drift`/Flutter import (verifiable by grep).
- [ ] `ProfilesNotifier.createProfile` and `.renameProfile` each route through exactly one named repository method opening one `db.transaction` against the E03 DAO, committed **before** any in-memory/stream state republishes; no widget or controller imports a DAO.
- [ ] The create sheet collects **only** a typed display name (+ role; + the parent-managed flag when the role is child); no other input widget exists in its tree; rename edits the name only.
- [ ] `activeProfileProvider` is a `Notifier<ProfileId>`; setting it persists to `app_meta.active_profile` through the write path and survives a cold start; profile-scoped read models are `family`-keyed by `ProfileId` and re-resolve on switch with no cross-profile leakage.
- [ ] `createdAt` is read from the injected clock boundary; no `DateTime.now()` appears in any file this task adds (CI grep).
- [ ] The user-typed display name renders FSI/PDI-isolated in every RTL surface this task touches; no raw string splice.
- [ ] No per-profile score, rank, percentage, streak, or "completion %" exists as a field or render (C-044); create/rename/switch is quiet — no celebration.
- [ ] Every user-facing string is an `l10n.*` ARB key in fa/ckb/ar; targets ≥48dp with `Semantics` labels; layout uses `EdgeInsetsDirectional` only.
- [ ] An `HttpOverrides` offline guard proves create, rename, and active-profile persistence open no socket.

## Tests

All deterministic and offline by construction: a fixed fake clock via provider override, an in-memory Drift double behind the repository, no hidden `DateTime.now()`, no network. Test-first on the write path and no-PII invariants.

- `features/test/profiles/profiles_notifier_test.dart` (unit) — **written first**: a recording repository logs `commit` and the notifier logs `republish`; create and rename each produce **exactly one** transactional write and the ordered log is always `commit → republish`, never the reverse; a repository throw surfaces as a calm retry state with no partial profile visible in the published list.
- `models/test/profile_no_pii_test.dart` (structural) — asserts `Profile`'s field set is exactly the allowed one and fails on any addition; a grep-style assertion over the task's files finds no `email`/`phone`/`password`/`photo`/`token` identifier and no `package:drift` import in `models`.
- `features/test/profiles/active_profile_scope_test.dart` (unit) — two seeded profiles: switching `activeProfileProvider` re-resolves the `family`-keyed read models to the new profile's data with zero leakage from the old; rebuilding the `ProviderContainer` (cold start) restores the persisted `app_meta.active_profile`.
- `features/test/profiles/profile_clock_test.dart` (unit) — `createdAt` of a created profile equals the fake injected clock's value, under two different fixed clocks; pins that the notifier reads the clock provider, not a wall clock.
- `features/test/profiles/profile_name_bidi_test.dart` (widget) — a mixed Latin/Arabic typed name ("Aram احمد") renders FSI/PDI-isolated inside the RTL list row and rename sheet: visual order asserted via the isolation wrapper, semantics order asserted for the screen reader.
- Offline guard: the suite runs under an `HttpOverrides` that throws on any socket open (eng-write-dart-test) — create, rename, and the active-profile write make no network call. (The switcher widget's re-scope journey is E16-T09's test; per-locale goldens are E16-T12.)

## Definition of Done

- [ ] All acceptance criteria met; the write-path ordering test and the no-PII structural test were written first and are green; the suite runs in CI.
- [ ] **Offline / no-network (C-048)**: profile create/rename and the active-profile switch work in airplane mode; the `HttpOverrides` guard passes; sharing a profile across devices is export/import only (E17) — nothing here performs a transfer.
- [ ] **No AI / no microphone**: no field, flow, or permission introduced by this task records, transcribes, or infers anything (R5, §17).
- [ ] **Quran text fidelity (R1)**: no surface in this task renders, masks, or re-typesets any āyah or glyph — profile chrome only.
- [ ] **Never "safe to drop" / engine untouched**: creating, renaming, or switching a profile mutates no `card`, no `due_at`, and no engine state; nothing here labels any page safe to stop revising (§7.12).
- [ ] **No gamification / no shame (R3, C-044)**: no per-profile score, rank, leaderboard, streak, or "completion %"; the child profile is parent-managed and calm with no guilt/fear/loss copy; mutations are quiet.
- [ ] **Single write path**: every mutation persists transactionally before republishing; `activeProfileProvider` is the only profile gate and keys every scoped query; no view writes persisted state; "today" is the injected `CalendarDate`, never `DateTime.now()`.
- [ ] **Privacy (§17, R5)**: a profile is created from only a typed display name (+ parent-managed flag); no email/phone/login/PII field exists anywhere in the type, notifier, repository, or sheet.
- [ ] **RTL + fa/ckb/ar localization**: all strings ship through the ARB pipeline in fa/ckb/ar; layout is RTL by geometry; the typed name is FSI/PDI-isolated visually and aurally; no hardcoded user-facing string.
- [ ] **Accessibility (WCAG 2.2 AA)**: the sheet's field and controls carry localized `Semantics` labels, ≥48dp targets, and a visible focus ring; OS text scale never shrinks a row below 48dp.
- [ ] **Sect-neutral adab**: create/rename and any reassurance copy (C-048) passed the domain-adab-and-religious-integrity conscience check — calm, factual, no ruling, no app-as-authority phrasing.
- [ ] **Deterministic tests**: fixed fake clock via provider override, seeded in-memory data, no hidden clock or network; all gates stay green.
