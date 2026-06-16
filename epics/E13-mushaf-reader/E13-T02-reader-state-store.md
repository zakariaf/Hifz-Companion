# E13-T02 — Reader-state Riverpod store: current page, zoom, theme, overlay toggles — display-only, no engine mutation

| | |
|---|---|
| **Epic** | [E13 — Muṣḥaf Reader](EPIC.md) |
| **Size** | S (≈0.5–1 day) |
| **Depends on** | E13-T01 |
| **Skills** | eng-create-riverpod-store, eng-write-to-coding-standards |

## Goal

A scoped `autoDispose` reader-state notifier exists at `packages/features/lib/src/mushaf/mushaf_providers.dart` as the single source of presentation truth for the reader chrome: it holds one immutable `MushafReaderState` value — current `pageNumber` (1..604), `zoom` (a uniform scale factor), reader `theme` (`ReaderTheme.light`/`.sepia`/`.dark`), and the two overlay-visibility booleans (`isWeakLineOverlayVisible`, `isMutashabihatOverlayVisible`) — and exposes pure `copyWith`-style commands the `MushafReaderViewModel` (E13-T01) binds to. It is **display-only by construction**: every command rebuilds the immutable state and republishes; not one of them mutates a `card`, appends a `review_log`, re-derives a `due_at`, opens a `db.transaction`, calls the engine, or reads `DateTime.now()`. It owns *what the reader is looking at and how it is shown*, nothing about *what the page is worth*.

## Context & references

| Reference | What to take from it |
|---|---|
| [E13 EPIC.md](EPIC.md) — Scope (reader-state store), Deliverables #2, DoD (single write path / no engine mutation) | The store's exact charter: current `pageNumber`, `zoom`, `theme`, weak-line + mutashābihāt overlay toggles as display-only state that mutates no engine state and persists no review; the "reader state is display-only" DoD sentence held verbatim |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §5 | The value types this state carries straight into E05's render frame: `mushafPageView(int pageNumber, ReaderTheme theme, double zoom)` — `zoom` is a **uniform `Transform.scale`** factor (no re-flow), `theme` selects a `ColorFilter` (sepia/dark = filter, never a font swap); the store holds these three as plain immutable fields and decides nothing about how they are drawn |
| `docs/design-system/04-typography.md` §1 | Two pipelines, one rule: the reader's `zoom` is the muṣḥaf's *own* scale, **independent of OS chrome text-scale** — so `zoom` is a store field the user changes, never `MediaQuery.textScaler`; the store holds no `type.*` token and no `TextStyle` |
| `docs/engineering/04-flutter-and-state-patterns.md` §1.1 (ownership table), §1.5 (pitfalls) | Per-feature presentation state = a `Notifier` over one immutable value; View-local-ish reader chrome state is scoped to the feature, never an app-scope store; no legacy providers, no `get_it`/Bloc/`provider`, no business logic inside a provider |
| `docs/engineering/02-project-structure.md` §3.4, §4 | The file home: `packages/features/lib/src/mushaf/mushaf_providers.dart` (providers scoped to the feature, never global); the state value type lives in the same feature library (it is presentation state, not a persisted `models` record); one primary type per file, `lower_snake_case` |
| Skill `eng-create-riverpod-store` (+ `template.dart`) | The notifier shape: modern `Notifier` only (no `legacy.dart` import), immutable UI state via `copyWith`, `autoDispose` for a screen-scoped controller, **no `DateTime.now()` in shell logic**, the store does not navigate, the store holds value types only (no streak/badge/score, no Quran/factual claim). Here the single-write-path rule is satisfied *by absence*: this store performs **no** mutation, so it opens no `db.transaction` and reaches no repository |
| Skill `eng-write-to-coding-standards` (+ `template.dart`) | Effective Dart casing; full-word unit-bearing names (`pageNumber`, `zoom`, never `p`/`z`); the one fixed transliteration (`mushaf`, `mutashabihat`); immutable value type with `final` fields, `const` ctor, `copyWith`; `///` on the public state type and commands; no hardcoded user-facing string (labels are E13-T09's ARB job); no `!`/`late`/`dynamic` to dodge nullability |
| `docs/science/CLAIMS.md` C-031, C-048 | No on-screen number/copy is authored here, so **no CLAIMS row is rendered by this task**. The covenants the store must not breach: C-031 (one card = one muṣḥaf page, 604 — the store names a page, never grades it) and C-048 (fully offline, no microphone — the store opens no socket and couples to no audio); cited so the no-engine-mutation/offline DoD traces to source |
| Siblings: E13-T01, E13-T03, E13-T06, E13-T05 | T01 owns the `MushafReaderViewModel` and the `go_router` deep-link params that **seed** this store's initial `pageNumber` — construction/wiring of the ViewModel is T01, not this task; T03 (RTL paged navigator) calls `setPage` when the `PageController` settles and reads `pageNumber` to drive it; T06 (reader controls) binds the zoom/theme commands; T05 (overlay toggles) binds the two visibility commands. This task authors **only** the state type + the notifier + its unit suite |

## Implementation notes

TEST-FIRST: write the notifier unit suite below before the notifier body. The "display-only — every command is a pure state rebuild" cases and the "no clock / no engine / no DAO symbol in the file" assertions must exist and fail before `MushafReaderNotifier` is implemented.

1. **State type** — `packages/features/lib/src/mushaf/mushaf_reader_state.dart`, one primary type per file. An immutable value: `final int pageNumber` (1..604), `final double zoom`, `final ReaderTheme theme` (the E05/eng-08-§5 enum, imported from `quran` — not redeclared here), `final bool isWeakLineOverlayVisible`, `final bool isMutashabihatOverlayVisible`. `const` constructor, a `const MushafReaderState.initial(int pageNumber)` named ctor (zoom `1.0`, theme `light`, both overlays `false`), a hand-written `copyWith`, plus `==`/`hashCode` (or `freezed`) so the widget rebuild is value-keyed. `///` doc on the type and each field with its unit/range.
2. **Notifier** — in `packages/features/lib/src/mushaf/mushaf_providers.dart`: `final mushafReaderStateProvider = NotifierProvider.autoDispose<MushafReaderNotifier, MushafReaderState>(MushafReaderNotifier.new);` and `class MushafReaderNotifier extends AutoDisposeNotifier<MushafReaderState>`. `build()` returns `MushafReaderState.initial(...)` seeded from the route's entry page (the seed is read from a small `family` arg or an injected `Provider` the ViewModel sets per E13-T01 — *not* from a clock and *not* recomputed). `autoDispose` because the reader chrome state is bounded to the open reader screen; the database/engine app-scope singletons are never `autoDispose`d, but this presentation store is.
3. **Commands** — all are pure `state = state.copyWith(...)` rebuilds, nothing else:
   - `setPage(int pageNumber)` — clamp/assert `1 <= pageNumber <= 604` (an `assert`, not a `throw` — this is in-app navigation, not an I/O boundary), set `pageNumber`. Called by T03 when the `PageController` settles and by T04's jump-to seek.
   - `setZoom(double zoom)` — set the uniform scale factor; `assert` it is finite and within the reader's min/max band. This is the muṣḥaf's own zoom (eng-08 §5 / type-04 §1), **independent of OS text-scale**; the command must never touch `MediaQuery`/`textScaler`.
   - `setTheme(ReaderTheme theme)` — set `light`/`sepia`/`dark`; no font swap implied — the value is handed to E05's `ColorFilter` frame downstream.
   - `toggleWeakLineOverlay()` / `toggleMutashabihatOverlay()` — flip the corresponding bool. The store toggles **visibility only**; it owns no overlay *refs* (weak-line refs come from the active profile's card/line-block state via E13-T05; mutashābihāt refs from the confusables dataset) and decides which words to mark for nothing.
4. **What this store must NOT contain** (the whole point of the task): no `ref.read`/`ref.watch` of a repository, DAO, or the engine; no `db.transaction`; no `await` (every command is synchronous and total); no `DateTime.now()`/`Calendar.current`/`TimeZone.current`; no `review_log`/`card`/`due_at`/`CalendarDate` reference; no navigation (`go_router` calls live in the View/redirect guard, per the skill); no hardcoded `Text` string (chrome labels are E13-T09); no streak/badge/score/percentage field.
5. **Pitfalls**: making a command `async` or routing it through a repository (there is nothing to persist — reader chrome is not a durable act like a review); storing a mutable list of overlay refs in this state (refs belong to T05's derived read, keyed off the active profile); reading `MediaQuery.textScaler` into `zoom` (couples the sacred zoom to OS chrome text-scale — forbidden by type-04 §1); leaving the provider app-scope/un-`autoDispose`d (it would leak reader state across reader sessions); redeclaring `ReaderTheme` here instead of importing the `quran`/E05 enum (a second source of truth for the theme the render frame consumes).

## Acceptance criteria

- [ ] `mushaf_reader_state.dart` and `mushaf_providers.dart` exist under `packages/features/lib/src/mushaf/`; the feature library builds with its declared deps only; the file contains **no** `import '.../legacy.dart'`, no `get_it`/Bloc/`provider`, no Drift/DAO symbol, no `package:engine` call, no `DateTime`/`Calendar.current`/`TimeZone.current` (verifiable by grep over the two files).
- [ ] `MushafReaderState` is immutable: `final` fields, a `const` constructor, a `const .initial(pageNumber)` factory, a `copyWith`, and value equality; `pageNumber`/`zoom`/`theme`/the two booleans are all present and unit/range-documented.
- [ ] `mushafReaderStateProvider` is a `NotifierProvider.autoDispose`; `build()` returns the initial state seeded from the entry page (not a clock, not recomputed).
- [ ] `setPage`, `setZoom`, `setTheme`, `toggleWeakLineOverlay`, `toggleMutashabihatOverlay` each rebuild the state via `copyWith` and **only** that — each is synchronous, total (never throws; bounds are `assert`s), and changes exactly the one field it names, leaving the others byte-equal.
- [ ] No command opens a transaction, reaches a repository/DAO/engine, appends a `review_log`, or re-derives a `due_at`; the store performs no mutation of persisted state at all (verifiable by the file having zero repository/DAO/engine references).
- [ ] `setZoom` reads no `MediaQuery`/`textScaler`; the reader's zoom is the muṣḥaf's own scale, independent of OS chrome text-scale (type-04 §1).
- [ ] `ReaderTheme` is **imported** from the `quran`/E05 render layer, not redeclared; the store holds the value E05's `ColorFilter` frame consumes (eng-08 §5).
- [ ] Every public declaration carries a `///` doc passing the analyzer's `public_member_api_docs`; the "display-only — mutates no engine state" intent is restated as a why-comment on the notifier class; `dart format` and `dart analyze --fatal-infos` are clean.

## Tests

`packages/features/test/mushaf/mushaf_reader_state_test.dart` and `packages/features/test/mushaf/mushaf_providers_test.dart` (mirroring the source tree, eng-11 §2/§3), `flutter_test` + `ProviderContainer`, run under CI Job 1 (fast: analyze + unit + widget) on every push. No database, no asset load, no clock — the notifier is pure presentation state. An `HttpOverrides`-that-throws guard wraps the suite so any accidental socket fails the test (offline covenant, C-048). Required cases, written FIRST:

- **Initial state**: a fresh `ProviderContainer` reading `mushafReaderStateProvider` seeded at entry page N exposes `pageNumber == N`, `zoom == 1.0`, `theme == ReaderTheme.light`, both overlays `false`.
- **Each command is a pure single-field rebuild**: `setPage`, `setZoom`, `setTheme`, `toggleWeakLineOverlay`, `toggleMutashabihatOverlay` each change exactly their one field and leave every other field equal to the prior state (assert field-by-field, and assert the prior state object is unmutated — immutability proof).
- **Toggles flip**: two `toggleWeakLineOverlay()` calls return to the original visibility; the two overlay booleans are independent (toggling one never moves the other).
- **Bounds are total, not throwing**: `setPage`/`setZoom` use `assert` in debug for out-of-range and never `throw` in release — a release-mode pump with an out-of-range value does not crash the reader (the command is total).
- **Display-only / no side effects** (the load-bearing case): with a `ProviderContainer` whose engine/repository/DAO providers are overridden with **spies that fail the test if read**, exercising every reader-state command touches none of them — no engine call, no repository call, no transaction, no `review_log` append, no `due_at` re-derivation.
- **No clock**: a source-level guard test (or a grep gate) asserts the two files contain no `DateTime.now()`/`Calendar.current`/`TimeZone.current` — "today" never enters reader chrome.
- **autoDispose**: the provider disposes when its last listener is removed (no leaked reader state between reader sessions).

CI Job 3 gates unchanged: no new `DateTime.now()`, no networking symbol, no Drift/DAO import inside `features`, no `legacy.dart` import.

## Definition of Done

- [ ] All acceptance criteria met; both suites green locally and in CI Job 1.
- [ ] **Single write path / no engine mutation (epic DoD, verbatim):** reader state (page, zoom, theme, toggles) is display-only and mutates no card, writes no `review_log`, and re-derives no `due_at`; a test proves every command touches no engine/repository/DAO/transaction. Any hand-off that *does* write (start-revision → E12, mark-range → E11) routes through the owning epic's single write path, never this store.
- [ ] **Offline / no-network:** the store opens no socket and reads nothing at runtime; the `HttpOverrides`-that-throws guard proves the radio stays off while paging/zooming/toggling (C-048); E01's banned-import + no-network gates stay green.
- [ ] **No AI / no microphone:** the reader-state path uses no AI, ASR, or audio and couples to no microphone (C-048) — it holds four scalar/bool presentation values and nothing else.
- [ ] **Text fidelity (existential):** the store re-shapes, re-typesets, and re-derives nothing — `zoom` is a uniform scale factor and `theme` selects E05's `ColorFilter` (no per-theme font swap, no re-flow); the store carries no glyph, no `TextStyle`, no overlay *text* (overlays are coordinate refs owned elsewhere); `zoom` is the muṣḥaf's own scale, independent of OS text-scale.
- [ ] **Sect-neutral adab:** the store asserts no Quran/factual claim, calls the page nothing absolute, and surfaces no badge/counter/streak/score/percentage over the page — it is a calm reference-state holder; the riwāyah label/attribution chrome is E13-T07, not this store.
- [ ] **RTL + fa/ckb/ar localization:** N/A by construction — the store holds value types only and no user-facing string; the muṣḥaf is identical across all three locales (only chrome localizes), so no string ships here. RTL paging direction is T03; chrome strings are T09.
- [ ] **Accessibility:** the store keeps the muṣḥaf's `zoom` independent of OS chrome text-scale (the page never reflows); `Semantics` labels for the controls that drive these commands are owned by their feature tasks (T06/T05/T09), not this store.
- [ ] **Nothing safe to drop:** the store never marks a page droppable/optional/done and exposes no raw D/S/R or percentage — it names the current page and nothing about its worth.
- [ ] **Deterministic tests:** modern `Notifier` only (no `legacy.dart`), immutable state via `copyWith`, `autoDispose`d, no `DateTime.now()`; the suites are pure (no DB, no asset, no clock) and run on every PR.
