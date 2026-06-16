# E07 — App Shell & Walking Skeleton

The thin end-to-end spine, stitched before any breadth: the Flutter app shell with the Riverpod `ProviderScope` composition root, the `go_router` RTL `ShellRoute` bottom nav (Today · Muṣḥaf · Mutashābihāt · Progress · Settings), and one vertical slice that proves the whole system works as a system — seed a profile through a minimal cold start, see real `buildToday` engine-selected due pages on Today, grade one page through the single write path, and have the new card state survive a kill-and-relaunch. It wires the side-effect boundaries (the injected `CalendarDate` clock, the Drift handle, the verified-asset gate) as `Provider` overrides at the root, and makes the persist-before-republish, *sanad*-respecting write covenant testable for the first time while the surface is still small enough that a broken seam is a one-day fix.

## Why this epic exists

E02–E06 each prove a module in isolation — the date core, the persistence layer, the engine behind frozen vectors, the byte-exact muṣḥaf renderer, the design-system foundation — but nothing yet proves the *seams* between them, and the seams are where this category fails. The PRD's whole architecture (engineering 01 §4) is justified by one end-to-end loop: an injected `CalendarDate` crossing the clock boundary into a ViewModel, a real `Engine.buildToday(...)` plan rendered as the Today queue, a grade routed through `CardRepository.recordReview` that persists in one WAL transaction *before* the Drift stream re-emits, and a relaunch that reads the committed card back from disk. Until that loop runs once, "identical inputs → identical schedule" (PRD §7.12), "persist on every review" (engineering 01 §4, step 5 before step 6), and "no Quran screen renders before the core pack is verified and a profile exists" (engineering 04 §6 redirect guard; PRD R1) are assertions in three separate documents, not a working spine.

This epic forces each of those rules through the seam while the cost of fixing a break is a day, not an archaeology project at release hardening. It makes the *sanad* covenant real for the first time: a teacher sign-off — or any review — that republished optimistically before its WAL commit would acknowledge to a ḥāfiẓ a review the disk does not hold, the exact "did my hifz record survive?" moment that ends trust in a *ṣadaqah jāriyah* app (engineering 04 §4 Pitfalls; PRD §17). The kill-and-relaunch test is that covenant made executable. And it pins the redirect guard structurally, so a local-notification tap or a deep link can never bypass onboarding to render an unverified muṣḥaf (engineering 04 §6; PRD R1). Every feature epic after this — Today (E12), the reader (E13), the trainer (E14), Progress (E15), Settings/profiles (E16) — then extends a spine already known to work end-to-end, instead of integrating eight finished modules at the end and discovering seam bugs in a ḥāfiẓ's live schedule.

## Scope

### In scope

- The thin `app/` shell as the composition root: `HifzApp` (`MaterialApp.router`), the root `ProviderScope`, the `supportedLocales` (`ar`/`fa`/`ckb`, all RTL) + `localizationsDelegates`, and `main()` that opens the Drift database (WAL) once and wires live services via `ProviderScope(overrides:)`.
- The DI `Provider` set in `composition/providers.dart`: `schedulerProvider` (the pure engine, injected, importing no Riverpod), `appDatabaseProvider`, `cardRepositoryProvider`, `clockProvider` (the injected `CalendarDate` "today"), `activeProfileProvider` (`Notifier<ProfileId>` — the only profile gate), and the `appReadyProvider` (core pack verified + a profile exists) — each a placeholder that **throws when read un-overridden**.
- The `go_router` `routerProvider`: one `ShellRoute` hosting the persistent RTL bottom nav (Today · Muṣḥaf · Mutashābihāt · Progress · Settings, rightmost = home), typed deep-link params, and the **redirect guard** routing an un-ready device to `/onboarding` before any Quran screen renders; a notification/deep-link tap resolves *after* the guard.
- The `HomeShell` bottom-nav scaffold (mirrored automatically under app-wide RTL `Directionality`; directional icons mirrored), with Muṣḥaf · Mutashābihāt · Progress · Settings as inert calm placeholder screens for this epic.
- The minimal **cold-start** seed path: a stripped onboarding step that captures held juz at juz-level + a single per-juz Solid/Shaky/Rusty rating, seeds conservative priors through `Engine.coldStartCard`, and writes the seeded cards via the single write path (the full flow — welcome, download, "when memorized", cycle picker — is E11).
- The minimal **Today** feature target (`features/lib/src/today/`): a dumb `ConsumerWidget` View + 1:1 `AsyncNotifier` ViewModel reading a `todayQueueProvider` `StreamProvider` over a Drift query that runs `Engine.buildToday` on the live card set, rendering due pages in Far → Near → New recitation order (page card + non-interactive track chip + calm decay indicator; no celebration, no streak).
- The minimal **grade-one-page** mutation: a single grade (Again/Hard/Good/Easy) on one Today row routed through `CardRepository.recordReview` — the named single-write-path method that opens one Drift transaction, appends the append-only `review_log` row, upserts the engine-updated `Card`, and commits **before** the stream re-emits (reveal-on-tap surface, teacher sign-off, stumble-line capture are E12).
- The **side-effect boundaries** wired as injectable `Provider`s behind Dart interfaces, each with a deterministic fake double: the `Clock` (live + `FixedClock`), the Drift handle (live + `NativeDatabase.memory()`), and the verified-asset/`appReady` gate (live + a fake-ready double).
- The **kill-and-relaunch crash-safety** verification: grade a page → terminate the process without graceful shutdown → relaunch → re-open the WAL database → the new card state and the appended `review_log` row are present (asserted primarily by a deterministic integration test, confirmed by the smoke flow).
- An `integration_test` spine journey: seed a profile (cold start) → land on Today → see a real engine-selected due page → grade it → the queue stream re-emits — with stable accessibility identifiers and `HttpOverrides` proving the radio stays off.

### Out of scope

- The full onboarding flow — welcome/privacy copy, the one-time core-pack download step, "when memorized" stale-time input, the named cycle-preset picker + daily budget → **E11 onboarding-and-cold-start** (this epic seeds a profile through a minimal sub-step only).
- The full reveal-on-tap recite/grade flow — line-by-line reveal, stumble-line tapping, the four-button grade band, the in-flow teacher sign-off toggle, undo, calm receipt motion → **E12 today-and-recite-grade** (this epic grades one page with one tap, no reveal surface).
- The full Today surface — time-budget cap, the Far/Near/New section headers, the catch-up banner, the honest budget-feedback line, the all-done terminal state → **E12 today-and-recite-grade** / the catch-up banner UI.
- The Muṣḥaf reader feature (jump-to-juz/ḥizb/surah, zoom/theme, overlays, "mark my memorized range") → **E13 muṣḥaf-reader** (this epic renders only an inert placeholder tab).
- The Mutashābihāt trainer, the Progress retention heat-map, and the full Settings/profiles/backup surfaces → **E14 / E15 / E16** (inert placeholder tabs here).
- The scheduling math itself — `onReview`, `buildToday`, `coldStartCard`, the trust clamp, load balancer — owned by **E04 scheduling-engine**; this epic *calls* the engine and renders its result, never re-derives a `due_at`.
- The Drift schema DDL, the `card`/`review_log`/`profile`/`cycle_config` tables, migrations, and the repository transaction *body* → **E03 models-and-persistence**; this epic wires the handle and routes the mutation through the existing single write path.
- The verified core-pack downloader, the SHA-256 fail-closed verifier, and the reference-data load → **E05 quran-data-and-rendering**; this epic consumes the `appReady` gate it exposes and never opens a socket.
- The full design-system component library and the accessibility/localization foundations → **E10 mihrab-component-library**, **E08 accessibility-foundation**, **E09 localization-rtl-foundation**; this epic references token *names* and ships fa/ckb/ar strings for the spine surfaces only.
- The CI no-network / banned-import / dependency-allow-list gates and the golden/coverage jobs → authored as gates in **E01 repo-scaffold-and-ci**; this epic must simply give them nothing to catch.

## Dependencies

### Depends on

- **E02 calendar-and-date-core** — the `CalendarDate`/`SerialDay` value type and the `Clock` interface contract; "today" crosses the boundary into every ViewModel and the repository as an injected `CalendarDate`, never `DateTime.now()`.
- **E03 models-and-persistence** — the Drift `AppDatabase` handle (WAL, `synchronous=FULL`), the `card`/`review_log`/`profile`/`cycle_config` schema, and the single-write-path transaction body the spine's `recordReview` and cold-start seed commit through.
- **E04 scheduling-engine** — the pure `Engine.buildToday(...)` plan the Today queue renders and the `Engine.onReview(...)` / `Engine.coldStartCard(...)` functions the repository calls; the engine is injected as a `Provider` and imports nothing from Riverpod or Flutter.
- **E05 quran-data-and-rendering** — the verified-asset/`appReady` gate the redirect guard consumes (no Quran screen renders before the core pack is verified) and the immutable page renderer the Muṣḥaf placeholder will later host.
- **E06 mihrab-foundation** — the design-system tokens (`color.*` / `type.*` / `space.*` / `motion.*`), themes, and `Directionality`/RTL scaffolding the shell chrome and the spine surfaces render with — referenced by name, never inlined.

### Enables

- **E08 accessibility-foundation** & **E09 localization-rtl-foundation** — audit and harden a real running RTL shell with live screens rather than mock-ups.
- **E10 mihrab-component-library** — the page card, track chip, and decay indicator the minimal Today instantiates are promoted/extended into the shared component library.
- **E11 onboarding-and-cold-start** — replaces the minimal seed sub-step with the full flow inside the wired shell, behind the same redirect guard.
- **E12 today-and-recite-grade** — extends the minimal Today queue and the one-tap grade into the full reveal-on-tap recite/grade flow over the same single write path.
- **E13 / E14 / E15 / E16** — replace the inert placeholder tabs with the reader, trainer, heat-map, and Settings/profiles, each extending the proven spine.
- **E17 backup-and-restore** & **E18 reminders** — the backup IO and local-notification scheduler boundaries ride the composition root and the wired stores established here.

## Foundation inputs

| Input | Where (doc/skill) | What this epic takes from it |
|---|---|---|
| Layer model & UDF single write path | docs/engineering/01-architecture-overview.md §2, §4 | The five-layer split, the shell-as-composition-root rule, and the one-review-loop (persist step 5 before republish step 6) the spine instantiates |
| Offline made auditable | docs/engineering/01-architecture-overview.md §6 | No networking symbol in any feature; tests install a throwing `HttpOverrides`; the spine runs in airplane mode after the core pack is verified |
| Riverpod composition root & profile gate | docs/engineering/04-flutter-and-state-patterns.md §1.2 | `ProviderScope` overrides as the only place live services are wired; throwing placeholders; the `activeProfileProvider` `Notifier<ProfileId>` gate |
| The single write path | docs/engineering/04-flutter-and-state-patterns.md §4; §1.3 worked example | `CardRepository.recordReview` shape: one `db.transaction`, append `review_log` first, upsert card, commit before republish |
| Reactive reads | docs/engineering/04-flutter-and-state-patterns.md §3 | The Today queue as a `StreamProvider` over a Drift query running `buildToday`; `R`/health computed on read, never stored |
| Navigation & redirect guard | docs/engineering/04-flutter-and-state-patterns.md §6 | The single `ShellRoute` RTL bottom nav (Today · Muṣḥaf · Mutashābihāt · Progress · Settings), typed routes, and the onboarding/`appReady` redirect guard |
| `family` + `autoDispose` keying | docs/engineering/04-flutter-and-state-patterns.md §5 | Per-profile providers keyed by `ProfileId`; app-scope db/engine singletons never `autoDispose`d |
| Information architecture & screens | docs/PRD.md §12 (§12.1 onboarding, §12.2 Today) | The bottom-nav set and order; the cold-start seed surface; Today as the core screen (grouped Far → Near → New, recitation order) |
| Cold-start seeding | docs/PRD.md §7.10; docs/engineering/06-scheduling-engine.md §5 | The minimal coverage-capture + Solid/Shaky/Rusty seed that drives `coldStartCard`; conservative under-estimate bias |
| Crash-safe persistence | docs/PRD.md §17, §10.3; docs/engineering/05-persistence-and-encryption.md §3 | WAL + `synchronous=FULL`, one transaction per review, append-only `review_log`, persist-before-publish — the kill-and-relaunch covenant |
| Skill: feature module | .claude/skills/eng-add-feature-module | The `features/lib/src/today/` anatomy (dumb View + 1:1 ViewModel + scoped providers + `widgets/`), the `ShellRoute` entry, and the downward-only dependency set |
| Skill: Riverpod store | .claude/skills/eng-create-riverpod-store | The `AsyncNotifier` controller, the `StreamProvider` read model, the persist-before-republish mutation, and the active-profile `Notifier` gate |
| Skill: service boundary | .claude/skills/eng-define-service-boundary | The `Clock`/Drift-handle/`appReady` boundaries behind Dart interfaces, wired once in `ProviderScope`, each with a deterministic fake |
| Skill: cold-start placement | .claude/skills/ui-cold-start-placement | The fast juz-level coverage taps + per-juz Solid/Shaky/Rusty rating the minimal seed sub-step renders |
| Skill: daily session list & page card | .claude/skills/ui-daily-session-list, ui-page-card | The Far → Near → New grouped queue and the page-card row (track chip + calm decay indicator) the minimal Today renders |
| Skill: tests | .claude/skills/eng-write-dart-test | The `ProviderContainer.test()` + `overrideWith` controller tests, the repository write-path unit, the `HttpOverrides`-that-throws guard, and the `integration_test` spine journey |
| Skill: localized strings | .claude/skills/eng-add-localized-string | The fa/ckb/ar ARB entries (`ar` template) for the spine surfaces and their `Semantics` labels |
| Claims behind on-screen facts | docs/science/CLAIMS.md C-009, C-016, C-031, C-048 | Cold-start conservative seeding (C-009); the cycle-ceiling guarantee behind a rendered due page (C-016); one card = one of 604 muṣḥaf pages (C-031); fully offline, no microphone, one-time verified download (C-048) |

## Deliverables

- [ ] `app/` shell: `HifzApp` (`MaterialApp.router`, RTL `supportedLocales` ar/fa/ckb, `localizationsDelegates`) and `main()` opening the WAL Drift database once and wiring live services via `ProviderScope(overrides:)`.
- [ ] `composition/providers.dart`: the DI `Provider` set — `schedulerProvider`, `appDatabaseProvider`, `cardRepositoryProvider`, `clockProvider`, `activeProfileProvider` (`Notifier<ProfileId>`), `appReadyProvider` — each a placeholder that throws when read un-overridden.
- [ ] `composition/router.dart`: the `routerProvider` with one `ShellRoute` RTL bottom nav, typed deep-link params, and the onboarding/`appReady` redirect guard; `HomeShell` with Muṣḥaf/Mutashābihāt/Progress/Settings inert placeholder screens.
- [ ] Side-effect boundaries wired in the shell, each with a deterministic fake: live `Clock` + `FixedClock`, live Drift handle + `NativeDatabase.memory()`, live `appReady`/asset gate + a fake-ready double.
- [ ] A minimal cold-start seed sub-step: juz-level coverage capture + per-juz Solid/Shaky/Rusty → `Engine.coldStartCard` → seeded cards written through the single write path (fa/ckb/ar, RTL).
- [ ] The `today` feature target: dumb `ConsumerWidget` View + 1:1 `AsyncNotifier` ViewModel, the `todayQueueProvider` `StreamProvider` over a Drift query running `Engine.buildToday`, rendering due pages Far → Near → New with page card + track chip + calm decay indicator, and the one-tap grade command.
- [ ] `CardRepository.recordReview` exercised end-to-end as the single write path (one `db.transaction`, append `review_log`, upsert card, commit before republish) for the spine's grade.
- [ ] Dart test suites: the repository write-path unit (failed persist ⇒ no republish; memory never newer than disk), the `TodayController` test (`ProviderContainer.test()` + faked repository), and the redirect-guard test (un-ready ⇒ onboarding; no Quran screen before `appReady`).
- [ ] The kill-and-relaunch crash-safety verification over the WAL store (deterministic integration test + the smoke confirmation).
- [ ] The `integration_test` spine journey (seed → Today → real due page → grade → stream re-emit) with stable accessibility identifiers, fa/ckb/ar strings, and a throwing `HttpOverrides`.

## Definition of Done

- [ ] **The spine works end-to-end** on device/simulator: seed a profile through the minimal cold start → land on Today → see a real `Engine.buildToday`-selected due page (Far → Near → New order) → grade it → the queue stream re-emits with the page rescheduled.
- [ ] **Single write path / persist-before-republish:** the grade and the cold-start seed commit through one named `CardRepository` method in one `db.transaction` (append `review_log`, upsert card) **before** any stream re-emits; a unit test proves a failed persist never republishes and no code path leaves memory newer than disk.
- [ ] **Kill-and-relaunch green:** the process is terminated mid-session without graceful shutdown; relaunch re-opens the WAL database and the graded card's new state and its appended `review_log` row are present — the review either fully happened or did not.
- [ ] **Offline / no-network:** no feature or shell file imports `package:http`/`dio`/`dart:io HttpClient`; tests install a throwing `HttpOverrides`; after the (E05) core-pack verification the entire spine runs in airplane mode; E01's banned-import + allow-list gates stay green.
- [ ] **No AI / no microphone:** nothing in the shell, cold-start seed, Today queue, or grade path uses ASR, ML, a model, or audio; grading is a human self-rating only (teacher sign-off and reveal-on-tap arrive in E12).
- [ ] **Text fidelity / redirect guard:** the redirect guard prevents any Quran-rendering route from resolving before the core pack is verified and a profile exists; a notification/deep-link tap is resolved only after the guard; the spine renders no muṣḥaf glyphs itself (the Muṣḥaf tab is an inert placeholder).
- [ ] **Determinism:** no `DateTime.now()` / `Calendar.current` anywhere reachable from the shell or a feature; "today" is the injected `CalendarDate` clock, passed down to the engine as a parameter; the spine integration test uses a `FixedClock`.
- [ ] **RTL + fa/ckb/ar localization:** every spine string ships in the `ar` template + `fa`/`ckb` translations via `gen_l10n` (no hardcoded literals); the bottom nav and chrome mirror under app-wide RTL `Directionality`; numerals are locale-appropriate via `intl`; mixed runs use FSI/PDI isolation.
- [ ] **Accessibility:** every interactive element (nav items, grade control, seed taps) has a stable accessibility identifier and a `Semantics` label in each locale; tap targets meet thumb-zone norms; Dynamic Type via text styles; the spine screens pass the accessibility audit in the smoke flow.
- [ ] **Sect-neutral adab / no gamification:** the spine surfaces carry no streak, score, badge, confetti, or guilt/fear copy; a graded page is framed as strengthening, never failure; nothing implies a madhhab/sect ruling; failure surfaces as a calm `RetryView`, never a spinner-of-shame.
- [ ] **Nothing safe to drop:** the Today queue and the rescheduled card never mark a page droppable, optional, or "done"; the rendered due date is the trust-clamped engine value (C-016), surfaced honestly.
- [ ] **No unsourced number:** any on-screen number in the spine (page index, juz, a rendered due date) traces to a CLAIMS row (C-031 page model; C-016 cycle-ceiling due date; C-009 cold-start seed); no citation or CLAIMS id is invented.
- [ ] **Tests:** the write-path unit, the controller test, the redirect-guard test, the kill-and-relaunch integration test, and the `integration_test` spine journey all run in CI on every PR; controllers are tested by faking the repository, not the `Notifier`; every Dart file carries the REUSE SPDX header and passes the analyzer/lint config.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E07-T01 | [Side-effect boundaries: Clock, Drift handle, and appReady/asset gate as injectable Providers with deterministic fakes](E07-T01-service-boundaries.md) | M | E02, E03, E05 |
| E07-T02 | [DI Provider set + ProviderScope composition root with throwing placeholders (engine, repository, clock, active-profile gate)](E07-T02-composition-root-providers.md) | M | E07-T01, E04 |
| E07-T03 | [go_router routerProvider: ShellRoute RTL bottom nav + onboarding/appReady redirect guard — test-first](E07-T03-router-shellroute-redirect-guard.md) | M | E07-T02 |
| E07-T04 | [HifzApp entry point + HomeShell bottom-nav scaffold with inert Muṣḥaf/Mutashābihāt/Progress/Settings placeholders](E07-T04-app-shell-home-scaffold.md) | M | E07-T02, E07-T03, E06 |
| E07-T05 | [CardRepository.recordReview single-write-path mutation + write-path unit suite (failed persist ⇒ no republish) — test-first](E07-T05-recordreview-single-write-path.md) | M | E07-T01, E03, E04 |
| E07-T06 | [Minimal cold-start seed sub-step: juz coverage + Solid/Shaky/Rusty → coldStartCard → seeded cards via the single write path](E07-T06-minimal-cold-start-seed.md) | M | E07-T04, E07-T05 |
| E07-T07 | [Today feature target: AsyncNotifier ViewModel + todayQueueProvider StreamProvider running buildToday (Far → Near → New)](E07-T07-today-feature-queue.md) | M | E07-T04, E07-T05 |
| E07-T08 | [Today page-card row: track chip + calm decay indicator + the one-tap grade command through recordReview](E07-T08-today-page-card-grade.md) | M | E07-T07 |
| E07-T09 | [Kill-and-relaunch crash-safety verification over the WAL store (deterministic integration test)](E07-T09-crash-safety-kill-relaunch.md) | S | E07-T05, E07-T08 |
| E07-T10 | [integration_test spine journey: seed → Today → real due page → grade → stream re-emit, with HttpOverrides + a11y identifiers](E07-T10-integration-spine-journey.md) | M | E07-T06, E07-T08, E07-T09 |

## Risks

- **The skeleton grows breadth.** The minimal slice invites "while I'm here" additions — reveal-on-tap, the catch-up banner, the full onboarding — that belong to E11/E12. *Mitigation:* scope is one cold-start sub-step, a `buildToday`-ordered queue, and a one-tap grade; anything beyond the ten tasks is rejected in review and filed against the owning epic (engineering 04 §1.4 — the staged-state-machine escape hatch is opened only by E11, not here).
- **Optimistic republish before the WAL commit.** Republishing in-memory state before the transaction returns would acknowledge a review the disk does not hold — fatal for a *sanad* act and for crash safety. *Mitigation:* the single write path is one repository method that commits before the stream re-emits; the write-path unit proves a failed persist never republishes (T05); the kill-and-relaunch test is the end-to-end confirmation (T09); per engineering 04 §4 Pitfalls.
- **Date leakage at the first UI boundary.** The first feature code is where `DateTime.now()` habits creep in, breaking the engine's "identical inputs → identical schedule" guarantee. *Mitigation:* "today" enters only through the injected `clockProvider` (`CalendarDate`); the spine test uses a `FixedClock`; E01's CI grep bans `DateTime.now()`/`Calendar.current` on every PR including this epic's new targets (engineering 04 §1.3; eng-define-service-boundary).
- **The redirect guard is bypassed.** An imperative `Navigator.push` or a notification tap that resolves before the guard could render an unverified muṣḥaf, breaking PRD R1. *Mitigation:* all primary navigation is typed `go_router` routes under the one `ShellRoute`; the guard is test-first (T03) asserting an un-ready device cannot reach a Quran route and a deep link resolves only after `appReady` (engineering 04 §6).
- **Store re-creation silently resets state.** A store constructed inside a widget build is re-created on rebuild, losing the seeded profile. *Mitigation:* live services are constructed once in `main`'s `ProviderScope` overrides; placeholders throw if read un-overridden; an integration assertion confirms store identity survives tab switches (engineering 04 §1.2).
- **A second network client or a gamified affordance creeps into the shell.** A "check for updates", crash reporter, or a celebratory streak on a graded page would void the offline covenant and the no-gamification non-negotiable. *Mitigation:* no feature imports networking (the socket is quarantined to E05's `/assets`); the grade renders a calm receipt with no confetti/score/streak; E01's allow-list + banned-import gates and the adab review (domain-adab-and-religious-integrity) catch any drift.
- **Throwaway-quality minimal screens become permanent debt.** *Mitigation:* the spine screens are minimal in *scope*, not quality — they compose real E06 tokens, fa/ckb/ar strings, `Semantics` labels, and the single write path from day one, so E11/E12 replace layouts, not foundations.

## References

- docs/PRD.md — §12 (information architecture & screens: §12.1 onboarding/cold-start, §12.2 Today), §7.10 (cold-start seeding), §7.6/§7.12 (trust clamp the rendered due date obeys), §10.3/§17 (append-only `review_log`, crash-safe local persistence), §13 (RTL/localization), §18 (accessibility), §19.1–§19.3 (Flutter shell, pure engine, offline guarantees), C1/C2/C4/C5/C6, R1/R3/R5/R6
- docs/engineering/01-architecture-overview.md — §2 (layer model, shell as composition root), §4 (unidirectional data flow — one review end to end, persist before republish), §5 (the pure engine, "today" injected), §6 (offline made auditable — no networking outside `assets/`, throwing `HttpOverrides`)
- docs/engineering/04-flutter-and-state-patterns.md — §1.1 (ownership rules, three hard rules), §1.2 (composition root + profile gate), §1.3 (the grade-a-page worked example), §1.4 (the MVVM-lite escape hatch — opened by E11, not here), §3 (reactive reads via `StreamProvider`), §4 (the single write path), §5 (`family` + `autoDispose`), §6 (navigation, `ShellRoute`, redirect guard)
- docs/engineering/05-persistence-and-encryption.md — §3 (one transaction per review, WAL + `synchronous=FULL`, persist-before-publish — the kill-and-relaunch covenant)
- docs/engineering/06-scheduling-engine.md — §5 (`coldStartCard` seeding), §6 (trust clamp), §7 (`buildToday` ordering the Today queue renders)
- docs/engineering/README.md — decision log: #1 (Flutter/Impeller), #2 (Riverpod 3.x state + DI, single write path), #3 (read-only reference tables / single write path), #4 (pure-Dart engine), #8 (no networking beyond asset download)
- docs/science/CLAIMS.md — C-009 (conservative cold-start seeding), C-016 (cycle-ceiling guarantee behind a rendered due date), C-031 (one card = one of 604 muṣḥaf pages), C-048 (fully offline, no microphone, one-time checksum-verified download)
- .claude/skills/eng-add-feature-module/SKILL.md — the `features/lib/src/today/` anatomy, the `ShellRoute` entry, the downward-only dependency set, the single-write-path mutation rule
- .claude/skills/eng-create-riverpod-store/SKILL.md — the `AsyncNotifier` controller, the `StreamProvider` read model, persist-before-republish, the active-profile `Notifier` gate
- .claude/skills/eng-define-service-boundary/SKILL.md — the `Clock`/Drift-handle/`appReady` boundaries behind Dart interfaces, wired once in `ProviderScope`, each with a deterministic fake
- .claude/skills/ui-cold-start-placement/SKILL.md, ui-daily-session-list/SKILL.md, ui-page-card/SKILL.md — the minimal seed sub-step, the Far → Near → New queue, and the page-card row the spine renders
- .claude/skills/eng-write-dart-test/SKILL.md, eng-add-localized-string/SKILL.md — the `ProviderContainer.test()`/`overrideWith` + `integration_test` harness and the fa/ckb/ar ARB + `Semantics` strings
