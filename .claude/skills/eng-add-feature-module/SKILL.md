---
name: eng-add-feature-module
description: Scaffold a new navigable feature (a tab or screen — Today, Muṣḥaf, Mutashābihāt, Progress, Onboarding, Settings) inside the Hifz Companion `features` umbrella package, wired to Riverpod and `go_router`. Use whenever adding a new screen or bottom-nav tab — it fixes the `lib/src/<feature>/` folder anatomy (`<feature>_screen.dart` dumb View, 1:1 `<feature>_view_model.dart`, `widgets/`, scoped `<feature>_providers.dart`), the downward-only dependency set (engine/data/quran/l10n/profiles), the single-write-path mutation rule, the `ShellRoute` bottom-nav entry in RTL order, and the matching widget/golden tests.
---

# eng-add-feature-module

Add one feature library to the `features` umbrella package so a new screen or tab becomes reachable through the app shell. A feature is **Layer 3 (UI)**: it knows the pure-Dart `engine`, the `data` repositories, the `quran` renderer, `l10n`, and `profiles` — and **nothing above the shell**. The work is mechanical and audited by the manifest and the folder shape: add the `lib/src/<feature>/` tree (a dumb `ConsumerWidget` View + its 1:1 `AsyncNotifier` ViewModel + `widgets/` + scoped providers), wire it into the `ShellRoute` bottom nav, and let every mutation flow down through a `data` repository — the **single write path**. The feature never opens the database, never reads a wall clock, never reaches the network, and never recomputes a `due_at`.

The architecture grades the domain layer "conditional"; Hifz Companion has exactly one domain citizen (the engine) and a flat UI layer of feature folders above it (`docs/engineering/01-architecture-overview.md` §2). This skill is how a new folder joins that layer without crossing a boundary.

## When to use

Use this skill when you:

- create a brand-new navigable feature — a new bottom-nav tab (Today / Muṣḥaf / Mutashābihāt / Progress / Settings-shaped) or a new screen under `packages/features/lib/src/` (`docs/engineering/02-project-structure.md` §3.4);
- split an over-grown feature into a second feature folder with its own View + 1:1 ViewModel;
- need the canonical `lib/src/<feature>/` anatomy plus its `ShellRoute`/`GoRoute` entry and scoped Riverpod providers (`docs/engineering/04-flutter-and-state-patterns.md` §6).

Do **NOT** use this skill for:

- creating a **new top-level package** under `packages/` (a new module beyond the seven canonical ones, or correcting any `pubspec.yaml`) → use **eng-create-package**. This skill only adds a feature folder *inside* the existing `features` package — it never touches a manifest except to confirm the dependency set is already correct (`docs/engineering/02-project-structure.md` §3.1).
- the thin `app/` shell — `composition/providers.dart`, `composition/router.dart`, or `bootstrap/first_run.dart` — that is the composition root, the one target that depends on every package because it computes nothing (`docs/engineering/02-project-structure.md` §2). Wiring the *live* db/asset/clock providers happens there, not in a feature.
- the **scheduling math** the ViewModel calls (curve, trust clamp, tracks, `buildToday` ordering, load balance, cold-start seeds) → use **domain-scheduling-engine-rules**. The feature reads the result; it never re-derives a schedule or a `due_at`.
- the **review → engine → persist** repository mutation itself (the transactional `recordReview`/sign-off write) → use **domain-grading-pipeline**. The feature *calls* the single write path; it does not author it.
- **immutable QPC glyph rendering** inside the Muṣḥaf reader (page fonts, overlay painters, layout geometry) → use **domain-mushaf-text-integrity**. A feature composes the `quran` widget; it never lays out Quran text itself.
- the **Mutashābihāt discrimination dataset and drill logic** → use **domain-mutashabihat-system**; the **retention heat-map honesty / "never safe to drop"** semantics on Progress → use **domain-scheduling-engine-rules** + the heat-map rules; the **calm, non-coercive, no-gamification** copy and adab of any new surface → use **domain-adab-and-religious-integrity**.
- per-locale **numerals, bidi isolation, and RTL mirroring** mechanics → see **eng-create-package** §8 for placement and the `l10n` package; this skill only requires that you *use* them.

## The canonical pattern

1. **One folder per feature, inside the `features` umbrella.** A feature is a folder under `packages/features/lib/src/<feature>/`, `lower_snake_case`, named for the screen (`today`, `mushaf`, `mutashabihat`, `progress`, `onboarding`, `settings`) — **not** a new package (`docs/engineering/02-project-structure.md` §3.4). `features` is an umbrella package: one Dart library per screen, each with the same shape. A genuinely new screen beyond the existing six is a normal addition here; a new *package* is not (that is **eng-create-package**).

2. **Fixed folder anatomy** (`docs/engineering/02-project-structure.md` §3.4):
   ```
   lib/src/<feature>/
   ├── <feature>_screen.dart        # the navigable entry View — a "dumb" ConsumerWidget
   ├── <feature>_view_model.dart    # the 1:1 ViewModel: an AsyncNotifier/Notifier
   ├── widgets/                     # leaf views (rows, grade buttons, reveal-on-tap), one type per file
   └── <feature>_providers.dart     # the screen's Riverpod providers, SCOPED to the feature
   ```
   File naming follows `docs/engineering/02-project-structure.md` §4: each file is `lower_snake_case`, named after its single primary public type; the entry view is `<feature>_screen.dart`, the ViewModel `<feature>_view_model.dart`. Deviations need a comment in the PR.

3. **The View is dumb; the ViewModel is 1:1.** Views and view models have a one-to-one relationship; the View is a `ConsumerWidget` that reads exactly one feature controller and renders, holding only "simple if-statements to show/hide widgets, animation/layout logic, simple routing" (`docs/engineering/04-flutter-and-state-patterns.md` §1.3, §2). The ViewModel is a `Notifier`/`AsyncNotifier` exposing an immutable UI-state value and the commands the View binds to event handlers (`docs/engineering/04-flutter-and-state-patterns.md` §1.1). The `AsyncNotifier` `.when(loading/error/data)` surfaces failure as a **calm retry**, never a spinner-of-shame or a guilt message (`docs/engineering/04-flutter-and-state-patterns.md` §1.3).

4. **Downward-only dependencies — the audit map.** The `features` package depends down on `engine`, `data`, `quran`, `l10n`, `profiles` (plus `flutter_riverpod` + `go_router`); **no leaf package imports `features`** (`docs/engineering/02-project-structure.md` §3.1; `docs/engineering/01-architecture-overview.md` §3.1). A feature **never** imports `package:http`/`dio` (no feature fetches anything), **never** imports `drift` or a DAO directly (it touches the DB only through `data`'s repositories), and **never** imports another feature's `src/` — features depend down, never sideways; share via a leaf package (`docs/engineering/02-project-structure.md` §5, ban #4). The engine is never reached from a widget: the View reads its controller, the controller reads repositories and calls the engine (`docs/engineering/04-flutter-and-state-patterns.md` §1.1, rule 2).

5. **Single write path; the View never mutates persisted state.** Every mutation — grade a page, teacher sign-off, edit cycle config, mark onboarding coverage — is a command on the ViewModel that calls a **named `data` repository method** which opens a Drift transaction, appends to the append-only `review_log`, upserts, and commits **before** republishing (`docs/engineering/04-flutter-and-state-patterns.md` §1.1 rule 1, §4). No optimistic "republish then persist"; no `setState`/manual cache poke; no debounced "save later" for a review or sign-off — these are durable *sanad* acts (`docs/engineering/04-flutter-and-state-patterns.md` §4 Pitfalls). View-local UI state (which line is revealed, sheet visibility, in-flight text) stays in the widget or a small `autoDispose` feature provider — `useState` is not used (`docs/engineering/04-flutter-and-state-patterns.md` §1.1 table).

6. **Reactive reads are `StreamProvider`s over Drift, never stored state.** Derived read models — Today's queue (Far → Near → New recitation order), the whole-Quran retention heat-map, per-juz/page health — are `StreamProvider`s watching a Drift query, so a committed review re-emits the stream and rebuilds the UI automatically; there is no second place to update (`docs/engineering/04-flutter-and-state-patterns.md` §3). `R` (retrievability) and juz health are **computed on read, never persisted** — and juz health is the **min-leaning** aggregate (one weak page is what fails a ḥāfiẓ in ṣalāh, so surface the weakest link, not the mean) (`docs/engineering/04-flutter-and-state-patterns.md` §3 Specification).

7. **"Today" is injected; never `DateTime.now()`.** The ViewModel reads "today" as an injected `CalendarDate` from the clock provider (`ref.watch(clockProvider).today()`), never `DateTime.now()` / `Calendar.current` — this is what keeps the engine's "identical inputs → identical schedule" guarantee testable end-to-end (`docs/engineering/04-flutter-and-state-patterns.md` §1.3, §3). Date logic and calendar conversion (Hijri / Jalālī / Gregorian) belong to the injected clock and the `l10n` helpers — see **domain-calendars-and-hifzdate**.

8. **Per-profile / per-page state is `family` + `autoDispose`.** Any provider that depends on the active profile or a specific page is parameterized with `family` (keyed by `ProfileId` or `pageId`) and disposed with `autoDispose` on unmount — so switching profiles yields the right data with no leakage, and the heavy reader/per-page providers do not survive their screen on low-end Android (`docs/engineering/04-flutter-and-state-patterns.md` §5). Never an un-keyed "current profile data" provider; never `autoDispose` on the app-scope db/engine singletons; `family` keys must be stable, equatable values (a `ProfileId`, never a `Card`).

9. **Wire it into the `ShellRoute` bottom nav, in RTL order.** Add a `GoRoute` for the screen under the single `ShellRoute` that hosts the persistent bottom nav; deep-linkable params are typed (`page/:pageId` → `int.parse`) (`docs/engineering/04-flutter-and-state-patterns.md` §6). The bottom nav, in RTL order (rightmost is "home"), is **Today · Muṣḥaf · Mutashābihāt · Progress · Settings**; the bar mirrors automatically under the app-wide RTL `Directionality` and directional icons are mirrored (`docs/engineering/04-flutter-and-state-patterns.md` §6 Specification). The router's redirect guard ensures no Quran screen renders before the core pack is verified and a profile exists — a new route inherits this; do not bypass it with an imperative `Navigator.push` (`docs/engineering/04-flutter-and-state-patterns.md` §6). Navigation is never triggered from inside a controller's business logic — controllers publish state; the View or a redirect decides what is on screen.

10. **Compose, don't grow `build`; reuse domain-blind widgets.** Extract named leaf widgets into `widgets/`; a widget is promoted to a shared `ui/` library only when reused by ≥2 features **and** it can be made domain-blind (it knows nothing of `Card`, `Grade`, or the muṣḥaf) — the feature maps domain values onto its primitives (`docs/engineering/04-flutter-and-state-patterns.md` §2). The arrow is one-way: features import `ui/`, never the reverse; shared components never read providers — everything arrives through the constructor. The Muṣḥaf glyph widgets are a special case owned entirely by **domain-mushaf-text-integrity** and never go through the OS text shaper.

11. **No hard-coded tokens; design comes from the design system.** Reference colors, type, and spacing **by name** (`color.*`, `type.*`, `space.*`, `motion.*`) — the `docs/design-system/` docs own the values; no inlined hex / pt / ms in any widget (`docs/engineering/04-flutter-and-state-patterns.md` §2 Pitfalls). **No gamified affordances anywhere** — no confetti, badge animations, streak counters, scores: they are forbidden by the non-negotiables, not merely discouraged (`docs/engineering/04-flutter-and-state-patterns.md` §2 Pitfalls). A new surface's copy and adab (servant-to-teacher tone, no guilt/fear, sect-neutral) is governed by **domain-adab-and-religious-integrity**.

12. **All strings localized; RTL by construction; offline by construction.** Every user-facing string comes from `AppLocalizations` in the `l10n` package (`ar` template, `fa`/`ckb` translations) — no hardcoded UI literals (`docs/engineering/02-project-structure.md` §6). All three locales are RTL, so use logical (start/end) directions only — never hard-coded left/right — and let the app-wide `Directionality` mirror the layout (`docs/engineering/04-flutter-and-state-patterns.md` §6 Pitfalls). The feature performs **no AI / no audio / no network** by construction; if you reach for a microphone, a model, or an HTTP call inside a feature, you are in the wrong layer and the CI gates will fail the build (`docs/engineering/01-architecture-overview.md` §6).

13. **The ViewModel is tested by faking the repository.** A feature controller is tested with `ProviderContainer.test()` and `overrideWith`, faking the repository — not the `Notifier` — so no widget pump is needed and it runs in milliseconds; the controller test verifies wiring and UI-state mapping only, not the FSRS math (which has its own pure golden/property tests in `engine`) (`docs/engineering/04-flutter-and-state-patterns.md` §7). Add widget + golden tests for the View; goldens load the **real** fonts and pin the runner so they stay stable (`docs/engineering/02-project-structure.md` §3.1, §7).

## Do / Don't

| Do | Don't |
|---|---|
| Add a `lib/src/<feature>/` folder inside the existing `features` package | Create a new top-level package under `packages/` (that's **eng-create-package**) |
| Name the entry View `<feature>_screen.dart`, the ViewModel `<feature>_view_model.dart`, one primary type per file | Put two primary types in one file, or name the View `<feature>_view.dart` |
| Make the View a dumb `ConsumerWidget` reading one controller; logic lives in the `AsyncNotifier` | Put repository calls, engine calls, or `try/catch` business logic in `build()` |
| Mutate only through a `data` repository method (single write path), persist-before-republish | Open a Drift transaction, call a DAO, or persist from the View/controller; republish optimistically |
| Read derived data via `StreamProvider` over a Drift query; compute `R`/juz-health on read | Persist `R` or juz health as a stored column, or cache the heat-map separately |
| Get "today" from `ref.watch(clockProvider).today()` as a `CalendarDate` | Call `DateTime.now()` / `Calendar.current` anywhere in the feature |
| Key per-profile/per-page providers with `family` + `autoDispose` | Use an un-keyed "current profile" provider, or `autoDispose` the app-scope db/engine |
| Add a `GoRoute` under the `ShellRoute`; RTL nav order Today · Muṣḥaf · Mutashābihāt · Progress · Settings | Imperative `Navigator.push` of a `MaterialPageRoute`, or navigate from inside a controller |
| Reference `color.*` / `type.*` / `space.*` / `motion.*` tokens by name; use logical start/end | Hard-code hex / pt / ms, or hard-code left/right in nav chrome |
| Pull every string from `AppLocalizations` (ar template, fa/ckb) | Inline a UI literal, or ship a string in one locale only |
| Promote domain-blind visuals to shared `ui/`; keep domain-aware views in the feature | Put `Card`/`Grade`/muṣḥaf types into a shared component, or import another feature's `src/` |
| Add gamification-free, calm surfaces; defer copy/adab to **domain-adab-and-religious-integrity** | Add streaks, badges, scores, confetti, or guilt/fear copy |
| Keep the feature AI-free, audio-free, network-free; test the ViewModel by faking the repo | Add a microphone, a model, or an `http`/`dio` import; mock the `Notifier` instead of the repository |

## Checklist

Before this feature is done:

- [ ] New feature lives under `packages/features/lib/src/<feature>/` — a folder inside the `features` package, not a new package.
- [ ] Folder anatomy present: `<feature>_screen.dart` (dumb `ConsumerWidget` entry View), `<feature>_view_model.dart` (1:1 `Notifier`/`AsyncNotifier`), `widgets/` (one primary type per file), `<feature>_providers.dart` (scoped, not global).
- [ ] The View reads exactly one controller and renders; no repository/engine call or business `try/catch` in `build()`; `.when` surfaces a calm retry, never a guilt message.
- [ ] Dependencies point down only (engine/data/quran/l10n/profiles); **no** `http`/`dio`, **no** `drift`/DAO import, **no** import of another feature's `src/`; the engine is never reached from a widget.
- [ ] Every mutation routes through a named `data` repository method (single write path), persisting transactionally **before** republishing; no optimistic republish, no `setState`, no debounced write for a review/sign-off.
- [ ] Derived reads are `StreamProvider`s over Drift queries; `R` and juz health are computed on read (juz health is min-leaning), never persisted or separately cached.
- [ ] "Today" is an injected `CalendarDate` via `clockProvider`; no `DateTime.now()` / `Calendar.current` in the feature; calendar conversion deferred to the clock / `l10n` helpers.
- [ ] Per-profile / per-page providers are `family`-keyed (`ProfileId`/`pageId`) and `autoDispose`d on unmount; keys are stable equatable values; app-scope singletons are not `autoDispose`d.
- [ ] A `GoRoute` is added under the single `ShellRoute`; typed params for deep links; RTL nav order Today · Muṣḥaf · Mutashābihāt · Progress · Settings preserved; the onboarding redirect guard is not bypassed; no navigation from a controller.
- [ ] Reusable domain-blind visuals promoted to shared `ui/` (no provider reads, no domain types); domain-aware views kept in the feature; design tokens referenced by name only; no hard-coded hex/pt/ms.
- [ ] RTL by construction: logical start/end directions only, no hard-coded left/right; directional icons mirror; verified under all three locales (fa / ckb / ar).
- [ ] All user-facing strings come from `AppLocalizations` (ar template, fa + ckb translations); zero hardcoded UI literals.
- [ ] Offline / no-AI by construction: no microphone, no model/inference, no network anywhere in the feature; CI no-network and import-ban gates pass.
- [ ] No gamification (streaks/badges/scores/confetti); copy and adab (servant-to-teacher, no guilt/fear, sect-neutral) follow **domain-adab-and-religious-integrity**.
- [ ] ViewModel tested with `ProviderContainer.test()` + `overrideWith` faking the repository (not the `Notifier`); View has widget + golden tests with real fonts and a pinned runner.

If the new feature renders a retention surface (Progress heat-map, juz health), it must stay **honest about decay** — never show a page as "safe to drop"; surface the weakest link, not the mean — per **domain-scheduling-engine-rules** and the heat-map honesty rule. If it renders the muṣḥaf, the glyph layer is composed from `quran` and never re-typeset (**domain-mushaf-text-integrity**). The standard is *iḥsān*, because the work is built free, *lillāh*.

## Files

- `template.dart` — copy-paste scaffold: the four feature files (`<feature>_screen.dart` dumb View, `<feature>_view_model.dart` `AsyncNotifier`, a `widgets/` leaf, `<feature>_providers.dart` scoped providers) plus the `GoRoute` entry to add to `app/composition/router.dart`, all with `// TODO` markers and tokens referenced by name.
- `references.md` — the exact governing doc sections that own this scaffold, each with the one thing to take from it.

Related skills: **eng-create-package** (the umbrella package's manifest + the seven-package boundary this feature sits inside), **domain-grading-pipeline** (the review → engine → persist single-write-path repository method the ViewModel calls), **domain-scheduling-engine-rules** (the pure schedule/`due_at`/heat-map logic the feature reads but never re-derives), **domain-mushaf-text-integrity** (the immutable QPC reader a Muṣḥaf feature composes), **domain-mutashabihat-system** (the discrimination drill dataset behind the Mutashābihāt feature), **domain-calendars-and-hifzdate** (the injected `CalendarDate` clock and Hijri/Jalālī/Gregorian conversion), **domain-adab-and-religious-integrity** (the calm, non-gamified, servant-to-teacher copy and adab of every new surface).
