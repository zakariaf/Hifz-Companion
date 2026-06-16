# E12-T01 — Today feature module + dumb View/view-model + ShellRoute tab wiring on the E07 spine

| | |
|---|---|
| **Epic** | [E12 — Today & Recite/Grade](EPIC.md) |
| **Size** | M |
| **Depends on** | E07, E09 |
| **Skills** | eng-add-feature-module, eng-create-riverpod-store, eng-rtl-and-bidi-layout |

## Goal

The `today` feature is a fully-formed feature module — not the E07 spine's minimal vertical-slice body — at the canonical anatomy: a dumb `TodayScreen` View, its 1:1 `TodayController` view-model, a `widgets/` folder, and a scoped `today_providers.dart`. This task fixes the module's *shape* and its place in the app, so every later E12 task (the read model, the list sections, the budget line, the empty/catch-up states, the recite/grade route) lands inside a clean, audited folder. It confirms the Today tab is registered in the E07 `go_router` RTL `ShellRoute` bottom nav (Today rightmost = home), and that every scaffolding string is localized through the E09 ARB pipeline (`ar` template + `fa`/`ckb`). The View stays **dumb and downward-only** (engine/data/quran/l10n/profiles): no engine logic, no schedule, no budget/catch-up computation, no `DateTime.now()`. T01 ships the empty scaffold + the calm `loading`/`error`/`empty` `.when` shells; the real read model and section content arrive in E12-T02/T03+.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §12.2 | The Today IA this module hosts: a short, finite, capped "Revise today" list grouped Far → Near → New, each row tapping into the recite flow, the catch-up banner, the honest budget line — the spec the module is shaped to receive (the surfaces themselves are T02–T08; T01 fixes the container) |
| `docs/PRD.md` §8 | The grading boundary the module must never cross in T01: judgment is human (self reveal-on-tap + on-device teacher sign-off), **no microphone / no audio / no STT** — the feature opens no such input by construction |
| `docs/PRD.md` §7.8–§7.9 | `buildToday` order (manzil → near → new) and the catch-up re-spread are the **engine's**, rendered later by T02/T03/T05 — T01's View must contain no ordering/cap/re-spread logic so that boundary stays clean |
| `docs/design-system/07-components.md` §1 (daily-session list), §6 (state model) | The four-state model (`loading` skeleton / populated / all-done / catch-up) the module's `.when` shells are stubbed against; the calm, no-scoreboard register every Today surface inherits |
| `docs/engineering/02-project-structure.md` §3.4, §4 | The fixed `lib/src/today/` anatomy and `lower_snake_case` one-primary-type-per-file naming this task instantiates |
| `docs/engineering/04-flutter-and-state-patterns.md` §1.1, §1.3, §6 | View↔ViewModel is 1:1; the View is a dumb `ConsumerWidget` reading one controller; `.when` surfaces a calm `RetryView`, never a spinner-of-shame; the `ShellRoute` bottom-nav entry in RTL order; stores never navigate |
| Skill **eng-add-feature-module** (+ `template.dart`) | The `today` folder anatomy (`today_screen.dart` dumb View, `today_view_model.dart` 1:1 `AsyncNotifier`, `widgets/`, scoped `today_providers.dart`); downward-only deps; **no** `http`/`dio`/`drift`/DAO/cross-feature import; the single-write-path rule (no mutation lands in T01); the `GoRoute` under the one `ShellRoute` in RTL nav order Today · Muṣḥaf · Mutashābihāt · Progress · Settings |
| Skill **eng-create-riverpod-store** (+ `template.dart`) | `Notifier`/`AsyncNotifier` only (no legacy providers / `get_it` / Bloc); `family`-key by `ProfileId`; the controller publishes immutable UI state, never navigates, never reads a wall clock; placeholders throw if read un-overridden |
| Skill **eng-rtl-and-bidi-layout** (+ `template.dart`) | RTL is the default, never a mode: logical `start`/`end` insets only (`EdgeInsetsDirectional`/`AlignmentDirectional`); the nav bar mirrors under the app-wide locale-derived `Directionality`; the directional tab icon mirrors; any mixed-script scaffolding run is FSI/PDI-isolated; numerals via `numberFormatFor(locale)` (no number ships in T01) |
| `docs/science/CLAIMS.md` C-048 | The covenant the module embodies — fully offline, no microphone, render only after the one-time checksum-verified download; the feature opens no socket and uses no audio/model. **No on-screen number or methodology claim ships in T01** (tab label and scaffolding copy carry no numeral); the CLAIMS-backed numbers (budget line, "M-day" catch-up plan) arrive with their surfaces in T02–T05 |
| Sibling **E07-T07 / E07-T08** | The spine's minimal `today` body (`today_screen.dart`, `today_view_model.dart`, `today_providers.dart`, `todayQueueProvider`, `TodayController`, the page-card row + one-tap grade) this task **formalizes into the full module anatomy** — T01 promotes/cleans the spine slice, adds the empty `widgets/` + scoped-provider seams, and does not re-architect the read path |
| Sibling **E07-T03 / E07-T04** | T03 fixed the `/today` `GoRoute` order under the `ShellRoute`; T04 built `HomeShell` + the localized nav label — T01 **verifies** the Today tab is wired (rightmost = home) and does not redefine the route table or the redirect guard |
| Siblings **E12-T02 … E12-T08** | T01 hands them an audited module: T02 fills `TodayController` with the `StreamProvider` read model + four states; T03 adds the Far→Near→New section list; T04 the budget line + empty states; T05 the catch-up banner; T07/T08 the recite/grade route + teacher sign-off — each adds files **inside** this folder |

## Implementation notes

This task is **scaffolding, not correctness-critical math** — no test-first oracle is required (the read-model/grading test-first work is E12-T02 and E12-T06). The bar is the audited module shape, the dumb-View boundary, and the verified tab. Write the module + the widget/golden shell tests together.

1. **Folder anatomy** (eng-add-feature-module §2; project-structure §3.4): formalize `packages/features/lib/src/today/` to the canonical four-part shape:
   ```
   lib/src/today/
   ├── today_screen.dart        # dumb ConsumerWidget entry View (reads exactly todayControllerProvider)
   ├── today_view_model.dart    # 1:1 TodayController extends AsyncNotifier<TodaySession>
   ├── widgets/                  # leaf views (calm skeleton, RetryView, calm empty line) — one type per file
   └── today_providers.dart     # SCOPED providers (todayControllerProvider; todayQueueProvider lands in T02)
   ```
   One primary public type per file, `lower_snake_case` (project-structure §4). This is a feature **folder inside the existing `features` umbrella package** — never a new top-level package, and never a `pubspec.yaml` edit (that boundary is `eng-create-package`).

2. **`TodaySession` is an immutable UI-state value** (eng-create-riverpod-store §5): a small `copyWith` value type the controller publishes. In T01 it can hold an empty/`isEmpty` shape (the ordered `List<ReviewItem>` + the four-state discriminant are filled by T02) — but it is a value type, never a mutable `Card`/`DayPlan`, and lives in `models`/`engine`, not the widget. Do not stuff rendered strings or any Quran/health fact into it.

3. **`TodayController` (the 1:1 view-model)** (flutter §1.3; eng-create-riverpod-store §2): `class TodayController extends AsyncNotifier<TodaySession>` exposed as `final todayControllerProvider = AsyncNotifierProvider<TodayController, TodaySession>(TodayController.new);` in `today_providers.dart`. In T01 `build()` reads the active profile via `ref.watch(activeProfileProvider)` (the only profile gate) and returns the empty session; the `todayQueueProvider` `StreamProvider.family<…, ProfileId>` body is **E12-T02**. The controller holds **no** grade/mutation command in T01 (single write path is exercised in T06/T07), **never navigates** (eng-create-riverpod-store §11), and **never reads `DateTime.now()`** — "today" enters only through the injected `clockProvider` (`CalendarDate`) when T02 wires the read.

4. **`TodayScreen` (the dumb View)** (flutter §1.3; eng-add-feature-module §3): a `ConsumerWidget` reading exactly `todayControllerProvider` and rendering `session.when(...)`:
   - `loading:` → a calm `surfaceContainerLow` skeleton leaf (components §1) — **never** a bare spinner or "loading…" guilt text;
   - `error:` → `RetryView(onRetry: () => ref.invalidate(todayControllerProvider))` — calm copy, never a spinner-of-shame;
   - `data:` → for T01, a calm placeholder/empty line (the populated list, all-done, and catch-up surfaces are T03/T04/T05).
   No `try/catch` or business logic in `build()`; no engine/repository call from the widget; design tokens (`color.*`/`type.*`/`space.*`/`motion.*`) referenced **by name** only, no inlined hex/pt/ms.

5. **Downward-only dependency audit** (eng-add-feature-module §4): the feature imports down on `engine`, `data`, `quran`, `l10n`, `profiles` (+ `flutter_riverpod`, `go_router`) and nothing else — **no** `package:http`/`dio`, **no** `drift`/DAO import, **no** import of another feature's `src/`. The engine is never reached from a widget; the View reads its controller, the controller (in T02) reads the repository. Confirm the CI banned-import / no-network gate has nothing to catch in the new/cleaned files.

6. **Tab wiring — verify, do not redefine** (eng-add-feature-module §9; flutter §6; E07-T03/T04): confirm the `/today` `GoRoute` is the **rightmost = home** child of the single `ShellRoute` in RTL nav order Today · Muṣḥaf · Mutashābihāt · Progress · Settings, and that `HomeShell` renders the Today tab with its localized label + the auto-mirroring directional icon. Do **not** add a route table, a second `ShellRoute`, or an imperative `Navigator.push`; do not bypass the onboarding/`appReady` redirect guard; do not navigate from the controller. If E07-T03/T04 already satisfy this, T01's contribution here is the verifying widget test, not a route edit.

7. **RTL + bidi by construction** (eng-rtl-and-bidi-layout §2, §5, §7): all positioning is logical `start`/`end` (`EdgeInsetsDirectional`/`AlignmentDirectional`/`Positioned.directional`) — no `EdgeInsets.only(left:/right:)`, no `Alignment.centerLeft/Right`, no `Positioned(left:/right:)` (grep-banned in `features/**`). Do **not** wrap the screen in a hardcoded `Directionality`; RTL comes from the locale (`supportedLocales: [ar, fa, ckb]` + `GlobalWidgetsLocalizations`, set in `app/`). Any mixed-script scaffolding run is routed through the bidi-isolation helper (FSI/PDI); any number would format via `numberFormatFor(locale)` — but **T01 renders no number**, so no numeral path is exercised yet (it lands with the rows in T03).

8. **Localized scaffolding only** (eng-add-feature-module §12; eng-create-riverpod-store §12): every user-facing scaffolding string (the screen title / "Revise today" container label, the calm empty-data line, the retry copy, the tab label if owned here) is a key in the E09 ARB pipeline — added to `app_ar.arb` (template/base) and transcreated to `fa`/`ckb`, `nullable-getter: false` key coverage — never a hardcoded literal. Copy stays calm and sect-neutral (no guilt/fear/loss, no streak/score/badge, nothing "safe to drop"); religious or methodology copy is deferred to its surface and its adab/CLAIMS review — none ships in T01.

9. **Pitfalls to avoid:** a second top-level package or a `pubspec.yaml` edit (wrong skill — `eng-create-package`); two primary types in one file or naming the View `today_view.dart`; an engine/repository call or `try/catch` business logic in `build()`; importing `drift`/a DAO or another feature's `src/`; a `StateProvider`/`StateNotifierProvider`/`legacy.dart` import, or adding `get_it`/Bloc; `DateTime.now()` anywhere in the feature; `autoDispose` on an app-scope singleton, or an un-keyed "current profile" provider; a hardcoded `Directionality` or any physical left/right inset; a hardcoded UI literal or a fa/ckb-incomplete ARB key; an imperative `Navigator.push`, a controller-triggered navigation, or a redefined route table; any streak/badge/score/confetti, or any microphone/audio/model/HTTP reference.

## Acceptance criteria

- [ ] `packages/features/lib/src/today/` has the canonical anatomy: `today_screen.dart` (dumb `ConsumerWidget` entry View), `today_view_model.dart` (1:1 `TodayController extends AsyncNotifier<TodaySession>`), a `widgets/` folder (one primary type per file), and a scoped `today_providers.dart`; no new top-level package, no `pubspec.yaml` edit.
- [ ] `TodayScreen` reads exactly `todayControllerProvider` and renders `session.when(loading / error / data)`; no engine/repository call and no business `try/catch` in `build()`; `loading` is a calm skeleton and `error` is a calm `RetryView`, never a spinner-of-shame or a guilt message.
- [ ] `TodaySession` is an immutable value type (`copyWith`) in `models`/`engine`, never a mutable `Card`/`DayPlan`; the controller publishes it, never navigates, and never reads `DateTime.now()`.
- [ ] Dependencies point down only (engine/data/quran/l10n/profiles + riverpod/go_router); **no** `http`/`dio`, **no** `drift`/DAO import, **no** cross-feature `src/` import; the no-network / banned-import gate has nothing to catch.
- [ ] The Today tab is the **rightmost = home** child of the single `ShellRoute` in RTL order Today · Muṣḥaf · Mutashābihāt · Progress · Settings, with a localized label and an auto-mirroring directional icon; the route table, the redirect guard, and `HomeShell` chrome from E07-T03/T04 are unchanged (verified, not redefined); no imperative `Navigator.push`, no controller-triggered navigation.
- [ ] Layout is RTL by geometry: logical `start`/`end` only (no `left/right` inset survives the `features/**` grep); no hardcoded `Directionality`; the screen renders correctly in all three locales (fa/ckb/ar).
- [ ] Every scaffolding string is an ARB key present in `app_ar.arb` (template) **and** transcreated `fa`/`ckb`, with `nullable-getter: false` coverage; zero hardcoded UI literals; copy is calm and sect-neutral (no streak/score/badge, no guilt/fear/loss, nothing "safe to drop").
- [ ] No microphone, audio, on-device model, or network anywhere in the feature; no `DateTime.now()`; no legacy Riverpod / `get_it` / Bloc import.
- [ ] Tokens referenced by name (`color.*`/`type.*`/`space.*`/`motion.*`); no inlined hex/pt/ms; every `public` declaration carries a `///` doc comment; the file carries the REUSE SPDX header (`GPL-3.0-or-later`) and passes the analyzer/lint config and `dart format`.

## Tests

`packages/features/test/today/` — `flutter_test` widget tests + per-locale goldens, run with `flutter test` in the fast CI job. The shared bootstrap installs the throwing `HttpOverrides` (the feature must touch no socket); the controller is exercised with `ProviderContainer.test()` + `overrideWith` faking the repository/queue, never the `Notifier`.

- `today_screen_test.dart` (widget): pump `TodayScreen` with `todayControllerProvider` overridden to (a) `loading` → asserts the calm skeleton leaf, no bare `CircularProgressIndicator` text-of-shame; (b) `error` → asserts the `RetryView` renders and `onRetry` invalidates the controller; (c) `data` (empty session) → asserts the calm empty/placeholder line. No engine/repository symbol is touched by the widget.
- `today_controller_test.dart` (provider, no pump): with the repository/queue faked via `overrideWith`, assert `TodayController.build()` reads `activeProfileProvider`, publishes the immutable empty `TodaySession`, exposes no navigation and no grade command, and reads no `DateTime.now()` (no clock call escapes the injected `clockProvider` seam). Runs in milliseconds.
- `today_tab_wiring_test.dart` (widget): pump the `routerProvider`/`HomeShell` (T03/T04) with `appReadyProvider` overridden true; assert the Today tab is present at the **rightmost = home** position under the `ShellRoute`, carries its localized label, and `context.go('/today')` resolves to `TodayScreen` — no second `ShellRoute`, no imperative push.
- `today_golden_test.dart` (golden): per-locale `matchesGoldenFile` for the `loading` and empty `data` shells in **fa, ckb, ar** on the **real bundled UI fonts** with a pinned runner — proving RTL geometry (start/end), the mirrored directional tab icon, and that the Sorani extra letters / Persian digits path is exercised (never `Ahem`/a placeholder font).
- **Offline guard:** the suite runs under the throwing `HttpOverrides`; a stray connection attempt is a named failure; the no-network / `DateTime.now()` / banned-import CI gates stay green over the new and cleaned files.

(The `StreamProvider` read-model ordering/re-emit tests, the four populated/all-done/catch-up state goldens, the grading-pipeline test-first suite, and the cold-start → buildToday → grade → catch-up integration journey are owned by E12-T02 … E12-T09 respectively — T01 does not duplicate them.)

## Definition of Done

- [ ] All acceptance criteria met; all tests above green in CI on every PR.
- [ ] **Offline / no-network**: the feature opens no socket; the `HttpOverrides` offline guard passes; the only inputs are taps (C-048).
- [ ] **No AI / no audio / no microphone**: no recording, no speech-to-text, no on-device model anywhere in the module (PRD C1/C2/R5).
- [ ] **Quran text fidelity**: T01 renders no Quran glyph and re-typesets no āyah; the module composes the `quran` reader only where later tasks (T07) mount it — the immutable glyph layer is never touched here.
- [ ] **The View is dumb, downward-only**: it reads one controller and renders; it never sorts/caps/load-balances, never calls the engine for a schedule, never reads `DateTime.now()`; no mutation lands in T01 (the single write path is exercised in T06/T07).
- [ ] **RTL + fa/ckb/ar strings**: every scaffolding string ships through the E09 ARB pipeline (`ar` template + `fa`/`ckb`); layout is RTL by geometry (`EdgeInsetsDirectional`/`AlignmentDirectional`); no hardcoded `Directionality`, no physical left/right; ckb's longer copy reflows; no hardcoded literal.
- [ ] **Accessibility**: the Today container exposes a `Semantics` label; the tab is a labelled ≥48 dp target with a visible focus ring; `loading`/`error`/empty shells read calmly; reduce-motion is honoured (no celebratory motion exists to begin with). (The full per-screen a11y audit of the populated list and grade band rides E12-T03+/E08.)
- [ ] **Sect-neutral adab**: all scaffolding copy is calm, autonomy-supportive, and free of guilt/fear/loss, streaks/scores/badges, and any "safe to drop" framing; no fiqh ruling or app-as-authority phrasing; no religious/methodology claim ships in T01 (those are deferred to their surfaces and the adab/CLAIMS review).
- [ ] **Deterministic tests**: the widget/golden/controller suite is deterministic (faked repository, injected clock seam, pinned golden runner, real bundled fonts); the no-network / `DateTime.now()` / banned-import / physical-side and ASCII-digit grep gates stay green.
