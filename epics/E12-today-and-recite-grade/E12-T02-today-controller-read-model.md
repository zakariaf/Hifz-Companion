# E12-T02 — Today controller: StreamProvider read model over buildToday + the four list states, no engine calls in the View

| | |
|---|---|
| **Epic** | [E12 — Today & Recite/Grade](EPIC.md) |
| **Size** | M (≈1–2 days) |
| **Depends on** | E12-T01, E04 |
| **Skills** | eng-create-riverpod-store, eng-define-service-boundary, ui-daily-session-list |

## Goal

The Today feature has a controller (`TodayController extends AsyncNotifier<TodaySession>`) and a backing `StreamProvider.family<…, ProfileId>` that watch a Drift query, hand the live card set to the engine's pre-built `buildToday(cards, today)`, and expose **one immutable read model** the dumb View from E12-T01 renders. The read model resolves to exactly **four calm list states — loading / populated / all-done / catch-up** — over the day grouped **Far (manzil) → Near (sabqi) → New (sabaq)** in recitation order. `today` is read from the injected `clockProvider` (a `CalendarDate`), never `DateTime.now()`; the controller and View call **no engine schedule method directly** — the day arrives pre-ordered, pre-capped, pre-load-balanced from the engine, and any mutation rides the single write path (persist-before-republish) in a later task. This task delivers the read side only.

## Context & references

| Reference | What to take from it |
|---|---|
| [EPIC.md](EPIC.md) — Scope, DoD ("The View is dumb") | The controller renders the engine + controller's pre-built day and the injected `CalendarDate`; it never sorts/caps/load-balances, never calls the engine for the schedule, never reads `DateTime.now()`; reads are `StreamProvider`s over Drift. |
| `docs/PRD.md` §12.2 (Today) | The four-state surface verbatim: a short, finite, capped "Revise today" list grouped Far → Near → New in recitation order; the catch-up banner after a gap; honest budget feedback. The read model must distinguish populated / all-done / catch-up so the View can pick the right state. |
| `docs/PRD.md` §7.8 (Building the day) | `buildToday(profile, today)` produces `farToday + nearToday + newToday`, recited **OLD before NEW (manzil → near → new)**; the read model preserves this grouping/order exactly and never re-derives it. |
| `docs/PRD.md` §7.9 (Load balancing & catch-up) | `loadBalance(day, budget)` and the re-spread catch-up plan are the **engine's** output; the controller surfaces "a catch-up plan exists" as a state flag, never computes the spread itself. FAR/manzil items are mandatory in the plan the controller receives. |
| `docs/PRD.md` §7.12 (Engine invariants) | The controller must not weaken INV-2 (FAR never dropped), INV-4 (identical inputs ⇒ identical schedule), INV-6 (never "safe to drop") — it passes the engine's plan through untouched; no filtering, no re-sort, no `null`-due. |
| `docs/design-system/07-components.md` §1 (daily-session list) | The four states' names and register: *loading* = brief `surfaceContainerLow` skeleton (no spinner theatre); *populated*; *all-done* = calm closing surface (no confetti); *catch-up* = gentle banner (no red pile). The controller's read model is the source of which state renders. |
| `docs/design-system/07-components.md` §6 (component states) | Confirms the read model is a closed, explicit state set — no implicit/ambiguous state; the View maps each to a calm surface. |
| `docs/engineering/04-flutter-and-state-patterns.md` §1.3, §3 | The **canonical shapes** to copy verbatim: `TodayController extends AsyncNotifier<TodaySession>` whose `build()` watches `todayQueueProvider(profile).future`; `todayQueueProvider = StreamProvider.family<List<ReviewItem>, ProfileId>` reading `clockProvider.today()` and calling `repo.watchTodaySession(profile, today)` (which runs `engine.buildToday()` over the streamed cards); the View's `session.when(loading/error/data)` with `CalmLoadingView`/`RetryView`. |
| `docs/engineering/07-dates-calendars-and-correctness.md` §(clock) | `final todayProvider`/`clockProvider` is the only place "now" enters; engine/repository call sites receive `clock.today()` (a `CalendarDate`), never `DateTime.now()`. |
| Skill `eng-create-riverpod-store` (+ `template.dart`) | `AsyncNotifier`/`StreamProvider` only (legacy banned); the read model is a `StreamProvider` over a Drift query (no second cache; `R`/health computed on read); `family`-keyed by a stable equatable `ProfileId` + `autoDispose`; immutable UI state (`copyWith`); the engine reached only through the repository; error → calm `RetryView`; **no `DateTime.now()` in shell logic**. |
| Skill `eng-define-service-boundary` (+ `template.dart`) | "Today" enters through the injected `Clock`/`clockProvider` (a `FixedClock` returns a literal `CalendarDate` in tests); the repository is the injected collaborator the controller fakes in tests (`overrideWith`), never a mock framework; live services wired once in `main`'s `ProviderScope`; offline preserved (no networking symbol reachable here; `HttpOverrides` throws on a stray call). |
| Skill `ui-daily-session-list` | The four states are calm by contract; the View is dumb and renders the **pre-built** day; grouping Far→Near→New in recitation order is the engine's, never re-sorted in the controller; no gamification leaks into any state. |
| `docs/science/CLAIMS.md` | This task surfaces **no** user-facing number or copy of its own (the View owns strings; the budget line and catch-up plan text are E12-T04/T05). No CLAIMS id is implemented here; any number that later rides this read model must trace to a graded CLAIMS row in its own task. |
| Siblings: E12-T01, E12-T03, E12-T04, E12-T05, E12-T06 | **T01** supplies the `today` feature module (`today_screen.dart` dumb View, `today_view_model.dart`, `today_providers.dart`) and the `ShellRoute` tab this controller plugs into — the module skeleton is NOT this task. **T03** assembles the page-card rows into the Far→Near→New sections (consumes this read model). **T04** renders the budget-feedback line + all-done/silent-resume copy off the state flags this controller exposes. **T05** renders the catch-up banner off the catch-up state. **T06** owns the grade mutation/single write path — this task is the read side only and exposes no `grade()` command. |

## Implementation notes

This is a **read-model** task: derive state, do not mutate. The grade write path is E12-T06. Resist adding a `grade()` command here — the epic's first risk is the View doing the engine's job; the mirror risk is this controller doing the write path's job.

1. **Files (in the `features` package, the E12-T01 module).**
   - `packages/features/lib/src/today/today_providers.dart` — add `todayQueueProvider` (the `StreamProvider.family` read model) and the `TodaySession` derivation, scoped to the `today` feature.
   - `packages/features/lib/src/today/today_view_model.dart` — `TodayController extends AsyncNotifier<TodaySession>` + `todayControllerProvider` (the existing 1:1 view-model file from T01; fill its `build()`).
   - `packages/features/lib/src/today/today_session.dart` (or co-located in the view-model file if T01 placed it there) — the immutable `TodaySession` read-model value type + the `TodayListState` enum.
   - No new file under `data/`, `engine/`, or `models/`: the repository surface (`watchTodaySession`, `ReviewItem`) is consumed, not authored here (it lands with E04 / the persisted-model tasks). If `watchTodaySession` does not yet exist, add a thin façade interface usage and a fake in the test — do **not** inline a DAO call.

2. **The `StreamProvider.family` read model (copy `04-flutter-and-state-patterns.md` §3 verbatim).**
   ```dart
   final todayQueueProvider = StreamProvider.family<List<ReviewItem>, ProfileId>((ref, profile) {
     final repo  = ref.watch(cardRepositoryProvider);
     final today = ref.watch(clockProvider).today();        // CalendarDate — never DateTime.now()
     return repo.watchTodaySession(profile, today);          // engine.buildToday() over the streamed cards
   });
   ```
   The engine call (`buildToday`) lives **inside the repository**, not in the provider or controller. The provider is a thin wire: watch the repo, read the injected clock, return the stream. `autoDispose` is implied by `family` per the project convention; the app-scope DB/engine providers are **not** `autoDispose`d.

3. **The controller (`04-flutter-and-state-patterns.md` §1.3 shape).** `TodayController.build()` reads `activeProfileProvider`, `await`s `ref.watch(todayQueueProvider(profile).future)`, and maps the `List<ReviewItem>` into an immutable `TodaySession`. Expose **no** mutation command in this task. The controller holds value types only — no strings, no gamified affordance, no Quran/health claim.

4. **The four list states as a closed model.** `TodaySession` carries the grouped items plus a derived `TodayListState`:
   - `loading` — represented by the `AsyncValue.loading` of `todayControllerProvider` (the View renders `CalmLoadingView`); no skeleton logic in the controller.
   - `populated` — the queue is non-empty; the read model exposes the items already grouped Far→Near→New (the grouping is the engine's `farToday`/`nearToday`/`newToday` order — the controller preserves index order, it does **not** re-sort or re-group).
   - `allDone` — the engine returned an empty plan for `today` and there is **no** outstanding backlog/re-spread (the day is genuinely complete). The View (T04) renders the calm closing line.
   - `catchUp` — the engine's plan carries a re-spread/backlog signal after a gap (a boolean/struct the engine surfaces on the plan, e.g. `plan.hasCatchUpPlan`). The controller exposes the flag; it does **not** compute the spread (that is §7.9 engine work; T05 renders it). A `catchUp` state may coexist with a populated list — model it as a flag on `TodaySession`, not a fifth mutually-exclusive enum that hides the list.
   - The mapping from `(items, planMetadata)` → `TodayListState` is the only logic this task adds, and it is total (every input yields exactly one state); pin it with the unit suite below before wiring the controller.

5. **Determinism / clock.** The controller and provider read "today" **only** through `clockProvider`. In tests, inject a `FixedClock(CalendarDate(...))` via `overrideWith`. A grep over `features/lib/src/today/` must find **zero** `DateTime.now()` / `Calendar.current` / `TimeZone.current`. The engine receives `today` as its last parameter inside the repository — the controller never passes a clock to the engine directly.

6. **Immutability & single source of truth.** `TodaySession` is an immutable value type with `copyWith`/`==`/`hashCode` (the read model is a golden-test precondition; a mutable `Card`/list handed to a widget is a silent golden-test killer). There is **no** second cache: a committed review (T06) re-emits the Drift stream, which rebuilds the queue — the controller never manually republishes.

7. **Error → calm retry.** A stream/repository failure surfaces as `AsyncValue.error`; the View renders `RetryView(onRetry: () => ref.invalidate(todayControllerProvider))`. No `try?`-swallow, no guilt/fear copy, no spinner-of-shame.

8. **Pitfalls to avoid.**
   - **The View/controller doing the engine's job** — sorting, capping, load-balancing, or computing the catch-up spread. The plan arrives pre-built; touch only the `items → state` mapping.
   - **A `grade()`/write command here** — this is the read side; the single write path is E12-T06.
   - **`DateTime.now()` anywhere** in the controller, provider, or session derivation.
   - **A second cache / stored `R`** — derive from the stream; never cache the queue in a field or persist `R`.
   - **A mutable list/`Card` in `TodaySession`** — wrap in `List.unmodifiable` / immutable value types.
   - **Folding catch-up into a mutually-exclusive state that hides the populated list** — catch-up is a flag that coexists with items, per §7.9.
   - **Re-grouping or re-sorting** the engine's `farToday/nearToday/newToday` order (breaks INV-4 reproducibility and the tradition ordering ui-daily-session-list mandates).
   - **A networking import** reachable from this file (offline by construction).

## Acceptance criteria

- [ ] `todayQueueProvider` is a `StreamProvider.family<List<ReviewItem>, ProfileId>` that reads `clockProvider.today()` and returns `repo.watchTodaySession(profile, today)`; it calls the engine **only** through the repository (no `buildToday` in the provider/controller).
- [ ] `TodayController extends AsyncNotifier<TodaySession>`; `build()` watches `activeProfileProvider` + `todayQueueProvider(profile).future` and exposes **no** mutation command.
- [ ] `TodaySession` is an immutable value type (`copyWith`, `==`, `hashCode`) holding the day grouped Far→Near→New in the engine's order plus a derived `TodayListState` and a `catchUp` flag; it holds value types only (no strings, no streak/score, no Quran/factual claim).
- [ ] The `(items, planMetadata) → TodayListState` mapping is **total** and resolves exactly to `populated` / `allDone` (empty plan, no backlog) — with `catchUp` modelled as a coexisting flag, and `loading`/`error` represented by the `AsyncValue`.
- [ ] No `DateTime.now()` / `Calendar.current` / `TimeZone.current` appears anywhere under `features/lib/src/today/` (verifiable by grep); "today" enters only via `clockProvider`.
- [ ] The provider/controller hold **no** caching field and never manually republish; a committed review re-emits the Drift stream as the only update mechanism.
- [ ] No `import 'flutter_riverpod/legacy.dart'`, no `get_it`/Bloc/`provider`, no `drift`/DAO import, and no networking import in any file this task touches (verifiable by grep).
- [ ] Every public declaration (`TodayController`, `TodaySession`, `TodayListState`, `todayQueueProvider`, `todayControllerProvider`) carries a `///` doc comment; `dart format` + analyzer clean.

## Tests

`packages/features/test/today/today_controller_test.dart` — `flutter_test` + `ProviderContainer` with `overrideWith`, no widget tree, no mock framework, no network. Collaborators are faked: a `FixedClock(CalendarDate(...))` for `clockProvider`, an in-memory fake `CardRepository` whose `watchTodaySession` emits a `StreamController`-driven `List<ReviewItem>` plan (with controllable `hasCatchUpPlan`). All dates are explicit `CalendarDate` literals — no host wall clock. Required cases:

- **Populated maps through, order preserved**: a non-empty plan with Far→Near→New items yields `TodayListState.populated` and the read model's item order is **byte-identical** to the engine plan's order (no re-sort/re-group).
- **All-done**: an empty plan with no backlog yields `TodayListState.allDone`.
- **Catch-up flag**: a plan carrying `hasCatchUpPlan == true` (after a simulated gap) sets the `catchUp` flag on `TodaySession`; the flag coexists with a populated list (it does not hide the items).
- **State mapping is total**: a table-driven test over `(empty/non-empty) × (backlog/no-backlog)` asserts exactly one `TodayListState` per input and that the mapping never throws.
- **Clock is injected, schedule is timezone-independent**: with the **same** `FixedClock` value, the read model is identical under `overrideWith` regardless of host TZ (mirrors `07-dates-calendars-and-correctness.md` T4 at the read-model seam); a grep test asserts no `DateTime.now()` in the feature folder.
- **Error → retry surface**: a repository whose stream emits an error drives `todayControllerProvider` to `AsyncValue.error`; `invalidate` re-runs `build()` (proving the `RetryView` path); no swallowed error.
- **No write path here**: a reflection/compile-time assertion that `TodayController` exposes no public mutation method (the read side adds none).
- **Offline guard**: the suite installs a throwing `HttpOverrides`; any stray socket from this read model fails the test loudly.

`packages/features/test/today/today_session_test.dart` — pure unit tests for `TodaySession`: `copyWith` round-trips, value equality, `List.unmodifiable` items (a write to the exposed list throws), and the `TodayListState` derivation in isolation. Engine golden vectors are **not** re-asserted here (they live in E04 / `engine/test/vectors/`); this task trusts the engine's plan and tests only the read-model mapping over a faked plan.

## Definition of Done

- [ ] All acceptance criteria met; both test files green locally and in CI (under the project's TZ pins).
- [ ] **Offline / no-network**: no surface in this task opens a socket; the `HttpOverrides` offline guard passes; no networking import is reachable from `features/lib/src/today/`.
- [ ] **No AI / no microphone / no audio**: nothing in the read model records, transcribes, or infers recitation; the only input modelled is the engine's pre-built plan over taps (the grade is E12-T06).
- [ ] **Quran text fidelity (R1)**: the read model holds page identity (page/juz ids in `ReviewItem`) and renders **no** Quran glyph and re-typesets **no** āyah; it carries no text-layout responsibility.
- [ ] **The View is dumb / engine purity**: the controller and View call **no** engine schedule method directly — `buildToday`/`loadBalance` run inside the repository; the controller never sorts/caps/load-balances, never reads `DateTime.now()`, and the read is a `StreamProvider` over Drift (no second cache).
- [ ] **Servant to the teacher (R6) preserved**: the read model passes the engine's plan through untouched, so a teacher-superseded card state surfaces exactly as the engine produced it — this task adds no rule that could override a sign-off.
- [ ] **No gamification / no shame (R3, C6)**: the read model exposes no streak/score/percentage/completion-count; `allDone` is a calm state flag (copy is T04), `catchUp` is a calm flag (banner is T05) — never a red overdue pile or "welcome back, N days".
- [ ] **RTL + fa/ckb/ar**: this task adds **no** user-facing string (strings live in `l10n`, rendered by the View in T03/T04/T05); any future string riding this read model lands through the ARB pipeline in fa/ckb/ar with locale numerals and bidi isolation — asserted N/A here by construction.
- [ ] **Accessibility**: N/A at the read-model layer (no widget added); the `TodayListState` set is the closed model the View's `Semantics`/states map to in T03–T05.
- [ ] **Sect-neutral adab**: the read model asserts no fiqh ruling and no app-as-authority phrasing; it holds value types only — cleared by construction.
- [ ] **Deterministic tests**: every test injects a `FixedClock`; identical inputs yield an identical read model; no host wall clock, no hidden timer, no flaky stream timing.
