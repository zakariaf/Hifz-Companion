# E19-T03 — Riverpod read model exposing register rows (by group, by id) to the science screen — read-only, offline

| | |
|---|---|
| **Epic** | [E19 — Science Screen & Claims](EPIC.md) |
| **Size** | S (≈0.5–1 day) |
| **Depends on** | E19-T01 |
| **Skills** | eng-create-riverpod-store, domain-claims-register-and-science-screen, eng-write-dart-test |

## Goal

The thin read model between E19-T01's typed register data and the science View (E19-T04/T07): **one scoped Riverpod provider set** that exposes the bundled CLAIMS register rows to the UI — the full register **grouped A–J in register order** for the screen, plus a **by-id lookup** (`C-NNN` → the exact row) for a single row. The register is loaded and parsed **once** through T01's `loadClaimsRegister` boundary over the verified pack, then cached for the life of the app; the providers add nothing, derive-and-store nothing, and mutate nothing. Uniquely in this app, this store has **no write path at all** — nothing on the science surface writes state (the register is authored in `docs/science/CLAIMS.md`, out of scope for the whole epic) — so the single-source-of-truth rule holds by construction: no clock, no network, no model, no repository write, no second cache. An unknown grade was already rejected by T01's fail-closed parser as a data defect; this provider never invents a fallback row, and an unknown id resolves to a **typed absence**, never a placeholder claim.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/science/11-the-in-app-science-screen.md` §1 | The screen is "a view, not a source of truth" — a read-only projection of the register; the single point of authorship is `CLAIMS.md` and the screen (so, this read model) merely formats it; an on-screen fact with no register row is a release-blocking defect, so the provider must be structurally unable to supply one |
| `docs/science/11-the-in-app-science-screen.md` §2 | Bundled, static, offline: the register-derived content ships inside the binary / verified core pack and renders locally — no runtime fetch of claims or "latest research", no model; corrections ship as an app/pack update, never a silent remote edit; the data is present before render, behind the verified-`appReady` boundary from E07 |
| `docs/PRD.md` §1 — C1, C2 | The hard constraints this provider embodies: offline after setup (no backend, no live service, no socket in this layer) and no AI/ML anywhere (every word the provider carries is pre-written, reviewed, bundled) |
| `docs/science/CLAIMS.md` (groups A–J) | The grouping and order contract the provider preserves verbatim: A memory & forgetting · B spacing & scheduling · C engine math · D retrieval & self-testing · E interference & mutashābihāt · F serial recall & the page unit · G overlearning · H traditional methodology · I motivation & adab · J cross-cutting honesty — register order, never re-sorted or re-bucketed here |
| Skill `domain-claims-register-and-science-screen` (point 8; point 1) | Bundled/static/offline/no-AI is the shipping contract (point 8); "a claim earns a row before it earns a sentence" (point 1) — the read model is a renderer's data feed, never an author; it relies on the E05 verified pack and opens no socket |
| Skill `eng-create-riverpod-store` (+ `template.dart`) | The binding provider rules: modern shapes only — `Notifier`/`AsyncNotifier`, `Future`/`StreamProvider`, DI `Provider` (no legacy providers, no Bloc, no `get_it`); immutable state only; collaborators injected as `Provider`s, never constructed in the store (rule 7); **no `DateTime.now()` in shell logic** (rule 8); `family` + `autoDispose` keyed by a stable equatable value for parameterized lookups, app-scope singletons never `autoDispose`d (rule 9); the store holds value types, not rendered words (rule 12) |
| Skill `eng-write-dart-test` (§8) | The throwing-`HttpOverrides` shared test bootstrap (a stray socket is a loud named failure), deterministic pinning (injected fixtures, no wall clock), and the provider-test tier (`flutter test` with `ProviderContainer` + `overrideWith`, never a live service) |
| Skill `eng-add-feature-module` | The fixed `lib/src/<feature>/` anatomy this file slots into: `science_providers.dart` is the feature's **scoped** provider file (not app-composition wiring), with the downward-only dependency set — the feature layer knows engine/data/quran/l10n/profiles and nothing above the shell |
| `docs/engineering/01-architecture-overview.md` §6; `docs/engineering/11-testing-strategy.md` §7 | The auditable no-network guarantee this file must stay inside: networking imports are banned outside the one downloader module (a CI grep, not a convention), and every test runs under the throwing-`HttpOverrides` bootstrap |
| `docs/science/CLAIMS.md` — **C-035**, **C-046**, **C-047** | Representative science-screen-surface rows the tests exercise by id: C-035 (group H, `[TRAD]`, *Ṣaḥīḥ al-Bukhārī* 5032 — proves a `[TRAD]` collection+number row round-trips the read model untouched) and C-046/C-047 (group J — the servant-to-the-teacher and honesty-about-uncertainty rows). This task cites them as **lookup fixtures only**; it authors no claim copy |
| Sibling **E19-T01** | Supplies everything this task reads: the immutable `ClaimRow` (id, headline, value/rule, source(s), the **ordered non-empty `EvidenceGrade` list**, surface, caveat), the `ClaimsRegister` collection (`rows`, `byId`, `byGroup`), the fail-closed parser, and the one-time `loadClaimsRegister(AssetBundle)` loader. This task **never parses**, never touches the raw register text, and re-implements no lookup — T01 said "T03 decides when" the one load runs; that is this task's whole authority |
| Sibling **E19-T02** | The grade-coverage / no-orphan gate consumes T01's parsed rows directly in CI; this provider is the *runtime* read path — T03 does not gate, T02 does not provide |
| Siblings **E19-T04 / E19-T07** | The consumers: T04's `ScienceSourceRow` renders one row; T07's `science` feature module (dumb View + 1:1 ViewModel) watches the grouped read. Neither re-reads the asset — this provider set is the **only** runtime door to the register |
| **E07** app-shell-walking-skeleton | The `ProviderScope` composition root the providers plug into, and the `appReadyProvider` redirect guard guaranteeing the verified bundled data exists before any science route renders — this task consumes that guarantee, it re-verifies nothing (E05 owns the fail-closed verifier) and gates nothing (the router owns redirects) |

## Implementation notes

This task is data plumbing only: no widget, no string, no schema, no gate. It is the *only* provider work in E19, and it is deliberately smaller than the store skill's general case because there is no mutation to route — build it as the degenerate (and therefore safest) instance of the pattern.

1. **File**: `packages/features/lib/src/science/science_providers.dart` — the scoped `<feature>_providers.dart` slot fixed by `eng-add-feature-module`. This task creates the folder's providers file; T07 later scaffolds `science_screen.dart` / `science_view_model.dart` around it. Do not put these providers in the app composition root — they are feature-scoped reads, not app wiring.
2. **Two providers, established by this task** (names are this task's API deliverable):
   - `claimsRegisterProvider` — a `FutureProvider` (modern shape; cached by default) that awaits T01's injected loader once and exposes the immutable `ClaimsRegister` value: all groups A–J in register order, rows in register order within each group. App-scope; **not** `autoDispose`d (static app-wide reference data, like the engine — skill rule 9).
   - `claimRowByIdProvider` — a **`family` + `autoDispose`** derived provider keyed by the validated `C-NNN` id string (the same stable, equatable key T01's `byId` takes — never a row object), watching `claimsRegisterProvider` and resolving via T01's `byId` to the exact row **or a typed absence** (T01's lookup shape — a nullable row or its sealed result; follow T01's value types, do not add a parallel result type).
3. **Parse once, cache forever.** The loader/parser runs exactly once regardless of how many widgets watch or how many by-id families spawn. The by-id family is a thin derivation over the cached register (T01's `byId`) — it must never re-invoke the loader and re-implements no lookup logic. A counting fake in the tests pins this.
4. **Read-only by construction.** No public method mutates, persists, refreshes, or invalidates; no repository/DAO/Drift import; the register is bundled reference data, not persisted state. The single-write-path rule is satisfied by having no write. Corrections reach the user only as an app/pack update (skill point 8) — do not add a "reload register" affordance.
5. **No clock, no network, no model.** No `DateTime.now()`/`clockProvider` dependency (nothing here is time-varying), no networking import (the banned-import gate must stay green over this file), nothing generated at runtime.
6. **Surface the rows and nothing derived-and-stored.** No group counts, no "N of M" aggregates (an engagement-mechanic seed — PRD R3/C6), no pre-rendered strings, no re-sorting: grouping and order come from T01's parsed structure verbatim. Expose unmodifiable collections; rows are T01's immutable `ClaimRow` values passed through untouched — including the ordered `EvidenceGrade` list as *values* (T04 renders a grade as text tag + non-color glyph; this store never maps it to words or colors, per store rule 12: value types, not rendered words).
7. **Never invent a fallback row.** An unknown grade cannot reach this layer (T01's parser rejects it fail-closed); an unknown id returns the typed absence. A placeholder/default row here would be an unsourced claim one widget away from a ḥāfiẓ — the exact defect this epic exists to make impossible.
8. **The surface back-link rides through untouched.** Each row's **app surface** field (11 §1: the register links a claim to where it acts) is part of the row value the provider passes through — T07 decides whether to render it; this task neither strips nor interprets it, exactly as with grades, source(s), and caveat.
9. **Pitfalls to avoid:** a legacy `StateProvider`/`StateNotifierProvider` (CI-failing import); constructing the loader inside the provider instead of injecting it (skill rule 7 — the live loader is wired once in the composition root, the placeholder throws loudly un-overridden); keying the family on a mutable object or a `ClaimRow`; returning a mutable `List`; re-parsing per watch; adding retry/refresh/mutation methods; re-verifying pack checksums here (E05's job) or gating on `appReady` here (the router's job); embedding any user-facing string (T09/l10n own every word the screen shows).

## Acceptance criteria

- [ ] `packages/features/lib/src/science/science_providers.dart` exists and declares exactly the two read providers (`claimsRegisterProvider`, `claimRowByIdProvider`); modern Riverpod shapes only — no `flutter_riverpod/legacy.dart`, no Bloc/`get_it`/`provider` (grep-verifiable).
- [ ] The grouped read yields **all** A–J groups in register order, with rows in register order within each group — no re-sorting, re-bucketing, filtering, or added aggregates.
- [ ] The by-id lookup returns the exact T01 row (value-equal) for a known id, and a **typed absence** for an unknown id — never a placeholder/fallback row, never a throw-as-flow-control.
- [ ] T01's loader/parser is invoked **exactly once** across repeated reads, multiple watchers, and multiple by-id families (pinned by a counting fake).
- [ ] The file has **no write surface**: no mutation/refresh/invalidation method, no repository/DAO/Drift import, no `DateTime.now()`, no networking import (grep-verifiable; the banned-import gate stays green).
- [ ] Exposed collections are unmodifiable and every row is T01's immutable `ClaimRow` carrying its id, headline, value/rule, source(s), ordered `EvidenceGrade` list, surface, and caveat untouched.
- [ ] The loader arrives as an injected `Provider` (overridable in tests); its un-overridden placeholder throws loudly rather than returning silent empty data.
- [ ] No user-facing string, no color/style mapping, and no derived "read/progress" state exists anywhere in the provider set.

## Tests

All deterministic and offline by construction: T01's bundled fixture data via `overrideWith`, no clock anywhere, the shared throwing-`HttpOverrides` bootstrap installed.

- `packages/features/test/science/claims_read_model_test.dart` (provider unit tests, `ProviderContainer` + `overrideWith` over T01 fixture data):
  - the grouped read contains every group A–J in register order, and rows within each group in register order (pinned against the fixture's known ordering);
  - by-id lookup for known ids returns the value-equal row — including **C-035** (a `[TRAD]` collection+number row round-trips with sources, grade list, and caveat untouched) and **C-046**/**C-047** (group J rows destined for this screen);
  - an unknown id (e.g. a syntactically valid but unregistered `C-999`) resolves to the typed absence — and asserts no fallback/placeholder row is constructed;
  - **parse-once**: a counting fake loader proves exactly one load across two reads of the register, three watchers, and two distinct by-id families;
  - **`autoDispose` does not evict the cache**: disposing a by-id family (listener removed, container pumped) and looking the same id up again still triggers **zero** further loads — the family derives from the cached app-scope register, never from the loader;
  - **read-only**: the provider set's public API exposes no mutation method (the harness exercises the full surface against a recording double and asserts zero writes); attempting to mutate a returned collection throws (unmodifiable);
  - **deterministic**: two independent containers over the same fixture yield value-identical results.
- Offline guard: the suite runs under the shared throwing-`HttpOverrides` bootstrap (eng-write-dart-test §8) — any socket open is a loud named failure, proving the read model never fetches. (The screen-level offline/golden sweep is E19-T10; the CI grade-coverage gate is E19-T02 — neither is re-tested here.)

## Definition of Done

- [ ] All acceptance criteria met; the provider unit suite is green, deterministic, and runs in CI on every PR.
- [ ] **Offline / no-network (C1)**: no networking import in the file; the throwing-`HttpOverrides` guard passes; the register is read only from T01's loader over the bundled verified-pack data — no runtime fetch of claims, citations, or "latest research".
- [ ] **No AI / no microphone (C2)**: nothing here records, generates, or infers; every row the provider carries is pre-written, reviewed, bundled data.
- [ ] **Renderer, never author**: the provider surfaces T01's rows verbatim — it invents no row, edits no field, re-grades nothing, and cannot supply an unregistered claim; an unknown id is a typed absence, an unknown grade is unreachable (rejected upstream, fail-closed).
- [ ] **Quran text fidelity (R1)**: this layer renders nothing and re-typesets nothing; a `[TRAD]` row's collection+number citation (C-035) passes through as data untouched.
- [ ] **Never "safe to drop"**: the read model computes no retention, safety, or health signal and attaches no interpretation to any row — it adds zero semantics on top of the register.
- [ ] **No gamification / no shame (R3, C6)**: no read-count, progress, streak, or engagement state exists in or is derivable from this provider set; it is a static reference feed.
- [ ] **Read-only / single source of truth**: no mutation path exists (no repository write, no second cache, no derived-and-stored value); the single-write-path rule holds by construction, and the bundled register — versioned with the app — is the sole authority.
- [ ] **RTL + fa/ckb/ar**: no user-facing string ships in this task (store rule 12: value types, not rendered words); every word the screen shows is owned by T09's ARB pipeline, and the provider carries the typed grade list so T04 can render it as text + glyph, never color alone.
- [ ] **Accessibility**: nothing rendered here, so nothing to audit visually — but the provider preserves every field (headline, sources, grades, caveat, surface) the T04 row needs to build its one merged, localized `Semantics` phrase; it drops none.
- [ ] **Deterministic tests**: no clock, no randomness, injected fixture data only; identical inputs yield value-identical provider output across containers; all existing gates (banned-import, no-network, lints) stay green over the new file.
