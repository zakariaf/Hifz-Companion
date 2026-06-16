# Modern Flutter App Architecture (2025–2026)

**Topic:** Flutter's official app-architecture guidance — layered separation of a UI layer, a data layer, and an optional pure-Dart domain core; the MVVM pattern as Flutter recommends it; immutability and unidirectional data flow; and the local-first / offline-first patterns we will re-read for an app that has *no* server at all. Compiled as the evidence dossier behind `engineering/01-architecture-overview.md`, `02-project-structure.md`, and `04-flutter-and-state-patterns.md`.

**Compiled:** 2026-06-16 · Research agent topic: platform/architecture baseline · Scope: Flutter's official `docs.flutter.dev/app-architecture` guide, recommendations, design-patterns and case study; the Ink & Switch local-first essay and the Kleppmann et al. 2019 *Onward!* paper; current Flutter/Dart toolchain baseline.

> Framing note. Flutter's official architecture is written for apps that talk to a *remote* backend — its repositories "poll data from services," its offline-first pattern is about caching server data for when the network drops. Hifz Companion has **no backend we operate** (PRD §1 C1): the only network call in the product's life is a one-time, checksum-verified asset-pack download (PRD §11.1.1). So this note reads the official guidance twice — first for what it says, then for how each piece *degenerates* when "remote" is permanently absent. The valuable parts (the layer boundaries, MVVM, immutability, unidirectional flow, repository-as-source-of-truth, the pure-Dart domain core) survive that subtraction cleanly; the sync/polling machinery falls away and leaves exactly the local-first shape we want.

---

## 1. What the evidence says

### 1.1 Flutter now ships an *official* architecture, and it is MVVM with layers

For years Flutter had no opinion on architecture; the gap was filled by community "Clean Architecture" blog posts of wildly varying quality. That changed: Flutter's team published a first-party **Guide to app architecture** that names a concrete, recommended structure. Its first and load-bearing sentence is the one to anchor on: **"Separation-of-concerns is the most important principle to follow when designing your Flutter app"** ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)).

The recommended shape is two required layers plus one optional layer:

- **UI layer** — "views are the widget classes of your application … and shouldn't contain any business logic." Paired with **view models**, which is where "most of the logic in your Flutter application lives."
- **Data layer** — **repositories** ("the source of truth for your model data") and **services** ("the lowest layer … they wrap API endpoints … and hold no state").
- **Domain layer (optional)** — **use-cases / interactors**, added only to relieve view models of cross-repository or repeated logic.

Flutter states plainly that this *is* MVVM: **"MVVM is an architectural pattern that separates a feature of an application into three parts: the `Model`, the `ViewModel` and the `View` … Views and view models make up the UI layer … repositories and services represent the data layer (model layer)"** ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)). The reference implementation is the open-source **Compass** app, whose architecture Flutter says "most resembles the MVVM architectural pattern as described in Flutter's app architecture guidelines" ([Flutter: Architecture case study](https://docs.flutter.dev/app-architecture/case-study)).

### 1.2 The UI layer: dumb views, one view model each, commands out

Flutter is prescriptive about the View/ViewModel split, and it is exactly the discipline a daily-use recite/grade flow needs:

- **Views are "dumb."** The *only* logic a view should contain is "simple if-statements to show/hide widgets …, animation logic, layout logic based on device information, and simple routing logic" ([Flutter: UI layer case study](https://docs.flutter.dev/app-architecture/case-study/ui-layer)). Everything else moves up.
- **One view ↔ one view model.** "Views and view models should have a one-to-one relationship; for each view, there's exactly one corresponding view model that manages that view's state" ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)).
- **A view model has three jobs:** retrieve data from repositories and transform it into a UI-ready shape, hold the current view state, and expose **commands** — callbacks the view binds to event handlers ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)).
- The companion **command pattern** wraps each user action (e.g. "submit grade") in a small object that tracks running/error/result, so the view never has to manage `try/catch`/loading flags itself ([Flutter: Architecture design patterns](https://docs.flutter.dev/app-architecture/design-patterns)).

### 1.3 The data layer: the repository is the single source of truth

Flutter's repository definition is the hinge of the whole architecture, and it is worded as an absolute: **"Repository classes are the source of truth for your model data. They're responsible for polling data from services, and transforming that raw data into domain models."** Repositories own "caching, error handling, retry logic, refreshing data, and polling services for new data," and — critically for shared state — "because repositories are the single source of truth for application data, they are also the ideal place to manage app-wide … state" ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)).

The relationships are specified: repositories and view models are **many-to-many** (one view model may read several repositories; one repository may serve many view models). **Services** sit beneath repositories, isolate raw data-loading (a REST endpoint, a *local file*, a platform API), expose `Future`/`Stream`, and **hold no state** ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)). For us, "service" is not an HTTP client — it is the Drift DAO and the bundled-asset loader. The repository abstraction is identical regardless.

### 1.4 The domain layer is *optional* — and that is an official, deliberate stance

This is the single most-misunderstood point in the community "Clean Architecture" literature, which tends to mandate a full use-case layer for every screen. Flutter explicitly rejects that as over-engineering. Its recommendation for a domain layer is graded **Conditional**, with this wording: **"A domain layer is only needed if your application has exceeding complex logic that crowds your ViewModels, or if you find yourself repeating logic in ViewModels. In very large apps, use-cases are useful, but in most apps they add unnecessary overhead"** ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)). The guide's rule of thumb: "add use-cases only when needed," and a use-case earns its place only when it merges data from multiple repositories, is exceedingly complex, or is reused across view models ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)).

This matters enormously for Hifz Companion, because we have one piece of logic that is *exactly* the case the domain layer exists for — the scheduling engine — and a hundred pieces that are not. Flutter's own advice tells us to give the engine a first-class home and to keep everything else flat. (Note: PRD §19.1 already names the engine a "pure-Dart package," so the project pre-commits to this.)

### 1.5 The recommendations, with their official priority labels

Flutter's recommendations page grades each rule **Strongly recommend / Recommend / Conditional**. The ones that bind our build:

| Recommendation | Official label | Verbatim anchor |
|---|---|---|
| Separate into UI and data layers | **Strongly recommend** | "Separation of concerns is the most important architectural principle." |
| Use **abstract** repository classes | **Strongly recommend** | "allows you to create different implementations … for different app environments." |
| Use **immutable** data models | **Strongly recommend** | "Immutable data is crucial in ensuring that any necessary changes occur only in the proper place, usually the data or domain layer." |
| Follow **unidirectional data flow** | **Strongly recommend** | "Data updates should only flow from the data layer to the UI layer. Interactions in the UI layer are sent to the data layer where they're processed." |
| Use **dependency injection** | **Strongly recommend** | "prevents your app from having globally accessible objects, which makes your code less error prone." (Flutter suggests `provider`.) |
| Standardise component naming | **Recommend** | `HomeViewModel`, `HomeScreen`, `UserRepository`, `ClientApiService`. |
| Add a **domain layer** | **Conditional** | "in most apps they add unnecessary overhead." |
| Generate immutable models with `freezed`/`built_value` | **Recommend** | supports unidirectional flow. |

Source for all rows: [Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations).

Two of these are worth dwelling on. **Dependency injection** is "Strongly recommend"-ed but the *package* (`provider`) is only a suggestion — and since a sibling decision (Decision log: *state management*) selects Riverpod, Riverpod's providers double as our DI mechanism, satisfying the principle without `provider`. **Immutable models + unidirectional flow** are the pair that make a deterministic, testable engine possible at all: if state can be mutated in the UI layer, golden tests of the scheduler become meaningless.

### 1.6 Unidirectional data flow and immutability are what make the engine testable

Flutter ties immutability and unidirectional flow together for a reason the PRD already cares about. Immutable data "prevents accidental updates in the UI layer and supports a clear, unidirectional data flow," and updates "should only flow from the data layer to the UI layer" while user interactions travel the other way as commands ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)). In a system whose central guarantee is *"identical inputs → identical schedule"* (PRD §7.12), this is not stylistic: a mutable card object handed to a widget could be mutated mid-frame and corrupt the next review computation. Immutable cards + a one-way flow (engine computes new state → repository persists → view models read → views render; grade events flow back as commands) is the structural precondition for the golden tests in PRD §20 gate 3.

### 1.7 The offline-first pattern — and how it degenerates to *local-only*

Flutter ships a dedicated **offline-first** design pattern. Its core: **"repositories act as the single source of truth … In offline-first applications, repositories combine different local and remote data sources to present data in a single access point, independently of the connectivity state of the device"** ([Flutter: Offline-first support](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)). The recommended read shape is a `Stream` that yields *local data first*, then *fresh network data*; the recommended write shape is *write to the local database first*, then attempt to sync, tracking a `synchronized` flag for what still needs pushing.

Read that pattern with the network branch deleted and you have Hifz Companion's persistence model exactly:

- The `Stream` that yields "local then remote" collapses to "local" — the repository reads Drift and is done. There is no second `yield`.
- The "write local, then sync" becomes "write local." There is no `putUserProfile` to the cloud; the `synchronized` flag does not exist because there is nothing to synchronize to.
- "Independently of connectivity state" becomes the *only* state — the app never observes connectivity because it never connects (PRD §17).

So the official offline-first pattern is, for us, not a feature to build but a description of the resting state. We inherit its discipline (repository as single source of truth; the local DB is authoritative) and discard its plumbing (sync flags, conflict handling, background refresh). The one true network event in the product — the one-time asset download (PRD §11.1) — is *not* this pattern: it is a verified static fetch that runs once at onboarding, behind a separate `assets/` downloader service, and never touches user data.

### 1.8 Local-first software: the deeper principle our constraints already satisfy

The intellectual foundation for "your data lives on your device" is the Ink & Switch essay **"Local-first software: you own your data, in spite of the cloud,"** by Kleppmann, Wiggins, van Hardenberg & McGranaghan, published at *Onward!* 2019. Its central inversion: cloud apps treat "the data on the server [as] the primary, authoritative copy … if a client has a copy … it is merely a cache"; local-first apps "swap these roles: we treat the copy of the data on your local device … as the primary copy" ([Kleppmann et al., 2019](https://www.inkandswitch.com/essay/local-first/); [ACM DOI](https://doi.org/10.1145/3359591.3359737)).

The essay's **seven ideals** are a checklist we can grade ourselves against — and Hifz Companion satisfies the privacy-relevant ones not by engineering effort but by *construction* (there is no server to fail any of them):

| Ideal (Kleppmann et al., 2019) | Hifz Companion |
|---|---|
| 1. No spinners: your work at your fingertips | All reads are local Drift queries; no request blocks the recite flow. |
| 2. Your work is not trapped on one device | File-based export/import (PRD §16) — the user moves data by any means. |
| 3. The network is optional | Network is used **once** (asset download), then airplane-mode forever (PRD §17). |
| 4. Seamless collaboration | *Deliberately out of scope* — no multi-user CRDT sync; "teacher sees data" is export→import (PRD §16). |
| 5. The Long Now (data outlives the vendor) | Documented, versioned JSON/SQLite export; no proprietary cloud lock-in (PRD §16). |
| 6. Security and privacy by default | No account, no telemetry, no audio; data never leaves the device (PRD §17, R5). |
| 7. You retain ultimate ownership and control | One-tap erase = right-to-be-forgotten by construction (PRD §16). |

The essay's hard part — multi-device collaboration via CRDTs (Automerge) — is the one ideal we consciously *decline*. Conflict-free replication exists to merge concurrent edits across devices; we have no concurrent edits because we have no sync. This is the right trade for a sacred-text retention app where privacy is religious trust (PRD R5) and simplicity is a non-negotiable engineering value. The lesson we take from local-first is the framing and the seven-ideal audit, not the CRDT machinery.

### 1.9 The pure-Dart domain core: an architectural *and* a testing decision

Flutter's optional domain layer and the broader Dart ecosystem agree on one practice that the PRD has already locked in: business logic that does not need Flutter should live in a package that does not *import* Flutter. A pure-Dart package (depending on `package:meta`/`dart:core` only, never `package:flutter`) "contains pure business logic with no Flutter or framework dependencies, making it the easiest layer to test" ([Flutter: Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)). The concrete payoff is that such a package is tested with the plain Dart `test()` runner and runs on `dart test` **without a simulator or a widget binding** — fast, deterministic, CI-cheap ([Flutter: Testing — unit tests](https://docs.flutter.dev/cookbook/testing/unit/introduction)).

This is precisely what PRD §19.1 specifies for the scheduler: "a pure-Dart package (`engine/`) with zero I/O — deterministic, fully unit/golden-tested, independently versioned." The architectural justification (Flutter's domain layer is the home for "exceedingly complex" reusable logic) and the testing justification (no Flutter import ⇒ no `WidgetTester` ⇒ pure `dart test` golden suites) point at the same boundary. Injecting "today" rather than reading the wall clock (PRD §19.3) is the final piece that keeps the package pure and its tests reproducible.

### 1.10 Toolchain baseline (mid-2026)

The architecture above is stable across recent Flutter versions; the toolchain only affects rendering and tooling, not the layer model.

- **Stable line:** Flutter 3.38 / Dart 3.10 shipped November 2025; Flutter 3.41 / Dart 3.11 followed in early 2026, with Flutter 3.44 / Dart 3.12 announced at Google I/O 2026 ([State of Flutter 2026](https://devnewsletter.com/p/state-of-flutter-2026/); [Flutter CHANGELOG](https://github.com/flutter/flutter/blob/master/CHANGELOG.md)).
- **Impeller is the default and effectively mandatory renderer:** Skia was removed on iOS with no opt-out, and Flutter 3.38 deprecated opting out of Impeller on Android (Vulkan, with an OpenGL fallback for old devices) ([State of Flutter 2026](https://devnewsletter.com/p/state-of-flutter-2026/)). This matters downstream for the muṣḥaf glyph-rendering pipeline (a separate research topic) but not for the layering here.
- **The architecture docs are version-agnostic.** Nothing in §1.1–§1.9 depends on a specific Flutter release; the guide, recommendations, and design-patterns pages describe a structure, not an API surface.

---

## 2. Implications for Hifz Companion

1. **Adopt Flutter's official MVVM as the app shell, verbatim.** UI layer = View + ViewModel (1:1, dumb views, commands for events); data layer = repositories over Drift DAOs and the asset loader. This is the first-party recommendation, it matches the feature-folder layout already in PRD §19.2 (`/features/today`, `/mushaf`, `/mutashabihat`, …), and it gives every screen a predictable shape for the daily recite/grade flow.

2. **Treat repositories as the single source of truth, with the local DB beneath them — the offline-first pattern minus the network.** Build the read/write paths exactly as Flutter's offline-first pattern prescribes (repository is the only place data is modified; local store is authoritative), then delete the sync branch: no `synchronized` flag, no remote `put`, no connectivity observation. Document each repository as "local-only; no remote source" so the absence is intentional and auditable, not an oversight.

3. **Make the scheduler the *one* domain-layer citizen; keep everything else flat.** Flutter says add use-cases "only when needed" and that most apps don't need a domain layer. The engine is the textbook exception (complex, reused across Today/Progress/Onboarding view models, must be reusable and isolatable). Put it in the pure-Dart `engine/` package per PRD §19.1; do **not** manufacture a use-case class for every screen. This keeps the codebase at the simplicity bar the project demands while giving the sacred logic a hard boundary.

4. **Enforce immutability + unidirectional flow as a release-relevant invariant, not a style preference.** Cards, review logs, and engine outputs are immutable value types (`freezed` or hand-written `copyWith`). State flows engine → repository → view model → view; grade events flow back as commands. This is the structural precondition for PRD §20 gate 3 (golden tests) and gate 4 (invariant property tests): you cannot golden-test a scheduler whose inputs a widget can mutate.

5. **Use Riverpod's providers as the DI mechanism and satisfy Flutter's "no global singletons" rule.** Flutter strongly recommends dependency injection (it suggests `provider`); Riverpod (Decision log: *state management*) supersedes `provider` and provides the same DI. Repositories and the engine are injected, never reached through globals — which also makes them trivially fake-able in tests, matching Flutter's "make fakes for testing" guidance ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)).

6. **Grade ourselves against the seven local-first ideals, and own the one we decline.** Ideals 1–3, 5–7 are satisfied by construction; ideal 4 (collaboration/CRDT sync) is deliberately out of scope and replaced by file export/import (PRD §16). State this explicitly in `01-architecture-overview.md` so reviewers see the omission is a considered trade (privacy + simplicity over multi-device sync), not a missing feature.

7. **Quarantine the one network call behind a dedicated service that never sees user data.** The asset-pack downloader (PRD §11.1, §19.2 `/assets`) is a *service* in Flutter's sense — it loads raw bytes, holds no state, and is wrapped by an asset repository that verifies SHA-256 before anything renders. It is architecturally separate from every user-data repository, which keeps the "no per-user data ever leaves the device" guarantee (PRD C1, §17) structurally provable: grep the data-layer repositories and find no `http` import at all.

8. **Treat the official architecture as a recommendation, adapted — exactly as Flutter says to.** Flutter explicitly frames its guidance as recommendations to "adapt to your app's unique requirements," not rules. Our adaptations are principled: no remote services, no domain layer except the engine, Riverpod-as-DI instead of `provider`. Each deviation traces to a hard constraint (C1/C2) or a named decision, and should be recorded as such in the decision log so the engineering doc set stays auditable.

---

## 3. Citations

1. Flutter (Google). *Guide to app architecture.* Flutter documentation. https://docs.flutter.dev/app-architecture/guide — the canonical UI/data/domain layer definitions, MVVM framing, repository-as-source-of-truth, and one-to-one view/view-model rule.
2. Flutter (Google). *Architecture recommendations and resources.* Flutter documentation. https://docs.flutter.dev/app-architecture/recommendations — the graded recommendations (Strongly recommend / Recommend / Conditional) for separation of concerns, abstract repositories, immutable models, unidirectional flow, dependency injection, the conditional domain layer, naming, and testing.
3. Flutter (Google). *Architecture design patterns.* Flutter documentation. https://docs.flutter.dev/app-architecture/design-patterns — optimistic state, key-value and SQL persistence, offline-first, the command pattern, and Result objects.
4. Flutter (Google). *Offline-first support.* Flutter documentation. https://docs.flutter.dev/app-architecture/design-patterns/offline-first — repository as single source of truth across local/remote sources; local-then-network `Stream` reads; write-local-then-sync with a `synchronized` flag; "the local database maintains the authoritative state."
5. Flutter (Google). *Architecture case study* and *UI layer case study* (the Compass app). Flutter documentation. https://docs.flutter.dev/app-architecture/case-study · https://docs.flutter.dev/app-architecture/case-study/ui-layer — the reference MVVM implementation; the exhaustive list of what logic a "dumb" view may contain.
6. Flutter (Google). *Developing packages & plugins.* Flutter documentation. https://docs.flutter.dev/packages-and-plugins/developing-packages — pure-Dart packages with no Flutter dependency as the most testable layer.
7. Flutter (Google). *An introduction to unit testing.* Flutter cookbook. https://docs.flutter.dev/cookbook/testing/unit/introduction — `package:test` / `dart test` for pure-Dart logic without a widget binding.
8. Kleppmann, M., Wiggins, A., van Hardenberg, P., & McGranaghan, M. (2019). *Local-first software: you own your data, in spite of the cloud.* Onward! 2019 (ACM SIGPLAN), pp. 154–178. Essay: https://www.inkandswitch.com/essay/local-first/ · DOI: https://doi.org/10.1145/3359591.3359737 — the local-vs-cloud "primary copy" inversion and the seven ideals of local-first software.
9. *State of Flutter 2026.* Developer Newsletter. https://devnewsletter.com/p/state-of-flutter-2026/ — current Flutter/Dart stable versions (3.38/3.10 → 3.41/3.11 → 3.44/3.12), Impeller default/mandatory status, and the Skia removal timeline.
10. Flutter (Google). *flutter/flutter CHANGELOG.* GitHub. https://github.com/flutter/flutter/blob/master/CHANGELOG.md — primary release record corroborating the version baseline.
