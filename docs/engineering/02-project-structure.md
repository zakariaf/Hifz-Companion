# Project Structure

This document fixes the concrete repository and package layout for Hifz Companion: the top-level tree, the thin `app/` shell, the seven local Dart/Flutter packages that realize the PRD's module map (`engine`, `data`, `assets`, `quran`, `features`, `l10n`, `profiles`), the dependency rules that make each boundary machine-checkable, and where ARB strings, fonts, and generated localizations live. The layout is not cosmetic: each package's `pubspec.yaml` is the audit evidence that the scheduling engine is pure Dart with zero I/O ([PRD §19.1](../PRD.md)), that no user-data repository can reach the network ([PRD C1, §17](../PRD.md)), and that the muṣḥaf-rendering package is the only place QPC glyph fonts are touched ([PRD R1](../PRD.md)). The packages are wired together with **pub workspaces** (Decision log: *Flutter platform*), Dart's first-party monorepo mechanism, so the analyzer treats the whole repo as one analysis context and a single `pubspec.lock` pins every transitive dependency ([Dart: Pub workspaces](https://dart.dev/tools/pub/workspaces)). System design and unidirectional data flow live in [01-architecture-overview.md](01-architecture-overview.md); the Dart style and the import-ban lints that enforce these boundaries live in [03-coding-standards.md](03-coding-standards.md).

## 1. Top-level repository tree

```
hifz-companion/                          # public GitHub repo root (GPL-3.0-or-later — Decision log: license)
├── README.md                            # one-sentence promise, stack summary, doc index, "verify yourself" link
├── LICENSE                              # GPL-3.0-or-later + GPLv3 §7 App Store additional permission
├── CONTRIBUTING.md                      # DCO sign-off (no CLA), PR rules, review checklist (03 §8)
├── CHANGELOG.md                         # Keep a Changelog format (13 §7)
├── SECURITY.md                          # GitHub private vulnerability reporting
├── BACKUP_FORMAT.md                     # NORMATIVE public backup-file spec, kept at root so third-party
│                                        #   recovery-tool authors find it; 10-backup-format.md is its companion
├── pubspec.yaml                         # the WORKSPACE root: `workspace:` lists every package (§3); holds
│                                        #   NO source — it exists only to pin one shared resolution
├── pubspec.lock                         # committed: the single shared lock for the whole workspace
├── analysis_options.yaml               # root lints + the DCM `avoid-banned-imports` layering gates (§5, 03 §2)
├── l10n.yaml                            # gen_l10n config; `synthetic-package: false` (§6)
├── melos.yaml                           # OPTIONAL task runner over the workspace (bootstrap/test/format);
│                                        #   it orchestrates, it does not resolve — pub workspaces does that
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md         # the review checklist (03 §8)
│   └── workflows/
│       └── ci.yml                       # the pinned-version CI (Decision log: testing strategy & CI)
├── tool/                                # CI gates, all runnable locally before push
│   ├── check_no_network.sh              # grep ban: dart:io HttpClient, package:http, package:dio outside assets/
│   ├── check_engine_purity.sh           # ban: package:flutter, dart:io, DateTime.now() inside packages/engine
│   ├── check_quran_isolation.sh         # QPC-font + glyph-string handling allowed ONLY in packages/quran
│   ├── check_l10n_complete.sh           # zero missing ARB keys across ar/fa/ckb; no hardcoded UI strings
│   └── check_dep_allowlist.sh           # every external dep in any pubspec must appear in this script's list
├── app/                                 # the thin Flutter app shell — the one target that imports everything (§2)
├── packages/                            # the 7 local packages (§3)
│   ├── engine/                          # pure-Dart scheduler — no Flutter (§3.2)
│   ├── data/                            # Drift schema, DAOs, repositories
│   ├── assets/                          # the ONE network module: pack downloader + SHA-256 verifier
│   ├── quran/                           # immutable QPC rendering + overlay painter
│   ├── features/                        # one library per screen (§3.4)
│   ├── l10n/                            # ARB files + generated AppLocalizations + ckb delegate
│   └── profiles/                        # local multi-profile model + active-profile switching
└── docs/
    ├── engineering/                     # this doc set (README + 01–13) and research/ (cited source notes)
    ├── design-system/                   # the design-system docs (authored in parallel)
    └── science/                         # verified science citations shown to users in-app
```

Deliberately absent, and kept absent by `tool/check_dep_allowlist.sh` and review: any `google_fonts` dependency (all fonts are bundled — [PRD §13.5](../PRD.md)), any analytics/ads/crash-reporting/backend SDK ([PRD C1, §20 gate 6](../PRD.md)), and any networking dependency outside `packages/assets`. `pubspec.lock` is committed at the workspace root; `.dart_tool/` and `build/` are gitignored. Committing the lockfile is the standard reproducibility practice for an application ([Dart: Pubspec — pubspec.lock](https://dart.dev/tools/pub/pubspec)), and with pub workspaces there is exactly **one** lockfile for the whole repo rather than one per package ([Dart: Pub workspaces](https://dart.dev/tools/pub/workspaces)).

### 1.1 Why pub workspaces, not per-package `path:` dependencies

**Decision.** The repo is a single **pub workspace** (Decision log: *Flutter platform* — the layered architecture is realized as Dart packages). The root `pubspec.yaml` carries no application code; it lists every package under `workspace:`, and each package adds `resolution: workspace`. This is the modern, first-party successor to ad-hoc `dependency_overrides`/`path:` wiring and to third-party bootstrappers.

**Rationale.** Pub workspaces (Dart 3.6+) give "shared resolution between packages in a monorepo": all packages "share a consistent set of dependencies," which "forces you to resolve dependency conflicts between your grouped packages as they arise, rather than facing confusion when you start using the packages" ([Dart: Pub workspaces](https://dart.dev/tools/pub/workspaces)). Crucially for a long-lived, auditable codebase, "the Flutter analyzer processes all of the packages in a pub workspace in a single analysis context," which both speeds the language server and means the import-ban lints in `analysis_options.yaml` see the whole graph at once ([Dart: Pub workspaces](https://dart.dev/tools/pub/workspaces)). A single committed `pubspec.lock` makes the dependency audit (PRD §20 gate 6) a one-file read. `melos` may sit on top purely as a task runner (`melos run test`, `melos run analyze`) — it orchestrates commands across packages but no longer needs to manage linking, since pub workspaces does the resolution ([melos](https://pub.dev/packages/melos)).

**Specification.** The root manifest:

```yaml
# pubspec.yaml  (workspace root — NO application code)
name: hifz_companion_workspace
publish_to: none
environment:
  sdk: ^3.6.0          # pub workspaces require ^3.6.0 on every member; baseline is Dart 3.10 (README)
workspace:
  - app
  - packages/engine
  - packages/data
  - packages/assets
  - packages/quran
  - packages/features
  - packages/l10n
  - packages/profiles
```

Each member declares `resolution: workspace` and its **own** narrow dependency set (see §3.1). All workspace packages must keep an SDK constraint of `^3.6.0` or higher — "all your workspace packages (but not your dependencies) must have an SDK version constraint of `^3.6.0` or higher" ([Dart: Pub workspaces](https://dart.dev/tools/pub/workspaces)).

**Pitfalls / what we refuse.** No `dependency_overrides` to paper over a version clash — a clash is a signal to fix, and the workspace surfaces it at `dart pub get` time, which is the point. No per-package lockfiles checked in (the workspace has one). No package may widen its dependency list to "borrow" a transitive dependency it does not declare; every external package a target uses appears in *that* target's `pubspec.yaml`, so the manifest stays the truthful audit map.

## 2. The app shell (`app/`) — wiring, gating, declaring

The app target wires, gates, and declares. It never computes a schedule, persists a row, or renders a muṣḥaf glyph — those live in packages. If a file in `app/` is not composition (wiring providers), platform glue (entitlements, manifests, icons), or the one onboarding/lock surface, it belongs in a package. This is Flutter's own rule that views are "dumb" and "most of the logic in your Flutter application lives" in the layers below the shell ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)).

```
app/                                     # the Flutter application (the only target that imports every package)
├── pubspec.yaml                         # resolution: workspace; depends on EVERY package — this is expected
│                                        #   here and ONLY here (the composition root)
├── lib/
│   ├── main.dart                        # runApp(ProviderScope(child: HifzApp())); no logic
│   ├── app.dart                         # MaterialApp.router; localizationsDelegates; supportedLocales;
│   │                                    #   locale → Directionality.rtl by construction (Decision log: l10n)
│   ├── composition/
│   │   ├── providers.dart               # the Riverpod root overrides: live Drift db, live asset loader,
│   │   │                                #   injected `today` clock — the ONE place real implementations
│   │   │                                #   are bound (Decision log: state management)
│   │   └── router.dart                  # GoRouter table; bottom-nav RTL order (PRD §12)
│   └── bootstrap/
│       └── first_run.dart               # triggers the one-time core-pack download via the assets package,
│                                        #   verifies SHA-256, builds the local DB, THEN routes to onboarding
├── android/                             # Gradle, AndroidManifest (no INTERNET-dependent services beyond
│                                        #   the asset fetch), signing config (Decision log: license)
├── ios/                                 # Info.plist, entitlements; NO microphone usage description — there is
│                                        #   no microphone use anywhere by construction (PRD R5)
└── assets/                              # BUNDLED binary assets shipped IN the app (not the downloaded packs):
    ├── fonts/                           #   UI fonts only — Vazirmatn/Estedad (fa/ar), a Sorani-covering
    │                                    #   font for ckb; declared in pubspec `fonts:` (PRD §13.5)
    └── .gitkeep                         #   Quran QPC fonts are NOT here — they arrive in the downloaded
                                         #   core pack and live in app-support storage (PRD §11, 09)
```

The shell is the single target that may import every package, because it is the composition root: `composition/providers.dart` is the only file that sees the Drift database, the asset loader, and the engine at once and binds the live implementations behind Riverpod providers (Flutter's "use dependency injection / no global singletons" rule, satisfied by Riverpod — [Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations); Decision log: *state management*). Two platform facts shape this folder: UI fonts are bundled in the binary (declared in the app `pubspec.yaml` `fonts:` section per the [Flutter: Use a custom font cookbook](https://docs.flutter.dev/cookbook/design/fonts)), while the Quran QPC fonts are **not** bundled — they download once into app-support storage and are loaded at runtime via `FontLoader` ([Flutter API: FontLoader](https://api.flutter.dev/flutter/services/FontLoader-class.html)), so a font byte can never enter the binary unverified (PRD §11.1.1; specified in [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)). The iOS `Info.plist` carries **no** `NSMicrophoneUsageDescription` — its absence is a structural privacy guarantee (PRD R5), not an oversight.

## 3. The packages (`packages/`)

### 3.1 Dependency matrix

This table is the audit map. Every row is enforced by a `pubspec.yaml` (resolution-time) and re-checked by the `tool/` grep gates and the DCM import-ban lints (Decision log: *no networking*; Decision log: *scheduling engine*). "Flutter?" records whether the package may import `package:flutter` at all — the answer for `engine` is **no**, which an auditor confirms from one manifest line.

| Package | Public library | Local deps | Notable external deps | Flutter? | Tested via |
|---|---|---|---|---|---|
| `engine` | `engine.dart` | **none** | **none** (vendored FSRS arithmetic; `meta` only) | **No** | `dart test` (pure) |
| `data` | `data.dart` | `engine`, `profiles` | `drift`, `sqlite3`, `path` | Yes | `dart test` + `drift` test backend |
| `assets` | `assets.dart` | **none** | `http`, `crypto` — the ONLY networking deps in the repo | Yes (no UI) | `dart test` (mocked client) |
| `quran` | `quran.dart` | **none** (consumes layout via value types) | `flutter` (rendering) | Yes | golden tests, real fonts |
| `profiles` | `profiles.dart` | **none** | `meta` only | minimal | `dart test` |
| `l10n` | `l10n.dart` | **none** | `flutter`, `intl` | Yes | `dart test` (numeral/bidi helpers) |
| `features` | one library per screen (§3.4) | `engine`, `data`, `quran`, `l10n`, `profiles` | `flutter_riverpod`, `go_router` | Yes | widget + golden tests |

Three structural rules this matrix encodes:

- **`engine` depends on nothing.** Its `pubspec.yaml` dependency list is empty but for `meta`; this single fact is the entire purity audit (Decision log: *scheduling engine*; [PRD §19.1](../PRD.md)). It imports neither `package:flutter` nor `dart:io`, so it runs under plain `dart test` with no widget binding — "the easiest layer to test" ([Flutter: Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)).
- **`assets` is the only package allowed to import `http`/`dio`.** It is Flutter's "service" in the architectural sense — it loads raw bytes, holds no state, verifies SHA-256, and is wrapped by an asset repository ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)). Every other package is forbidden any networking import by the DCM `avoid-banned-imports` rule, whose `entries` ban an import regex within a `paths` regex ([DCM: avoid-banned-imports](https://dcm.dev/docs/rules/common/avoid-banned-imports/)) — and by `tool/check_no_network.sh` (Decision log: *no networking*).
- **`features` depends on the leaf packages, never the reverse.** Dependencies point one way (features → engine/data/quran/l10n/profiles); no leaf package imports `features`. This is the unidirectional dependency rule that keeps the engine and data layers reusable across Today, Progress, and Onboarding view models ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)).

### 3.2 Package internals — full tree

```
packages/
├── engine/                              # PURE Dart: curve, interval, tracks, trust clamp, load balance,
│   │                                    #   cold start — NO Flutter, NO dart:io, NO wall clock (PRD §7, §19.1)
│   ├── pubspec.yaml                     # dependencies: meta  ← the entire audit story in one line
│   ├── lib/
│   │   ├── engine.dart                  # the public barrel: exports ONLY the stable API surface
│   │   └── src/                         # everything else is private to the package (lib/src convention)
│   │       ├── curve.dart               # retrievability(t,S), interval(S,R) — DECAY/FACTOR named consts
│   │       ├── review_update.dart       # onReview: lapse vs success, S/D updates (PRD §7.7)
│   │       ├── trust_clamp.dart         # due_at = min(ideal_due, ceiling_due) (PRD §7.6) — the covenant
│   │       ├── build_today.dart         # far → near → new ordering (PRD §7.8)
│   │       ├── load_balance.dart        # budget fit + graceful catch-up (PRD §7.9)
│   │       ├── cold_start.dart          # Solid/Shaky/Rusty → (D,S) seeds (PRD §7.10)
│   │       └── models/                  # immutable value types: Card, Grade, CycleConfig, ReviewResult
│   └── test/                            # golden vectors + glados property tests of the §7.12 invariants
│
├── data/                                # Drift schema, DAOs, repositories — the local single source of truth
│   ├── pubspec.yaml                     # dependencies: drift, sqlite3, path, engine, profiles
│   ├── lib/
│   │   ├── data.dart                    # exports repositories + DTOs only — never the raw DAOs
│   │   └── src/
│   │       ├── db/
│   │       │   ├── database.dart        # @DriftDatabase; WAL + synchronous=FULL (Decision log: persistence)
│   │       │   ├── tables/              # one file per table group (reference/, user/)
│   │       │   └── migrations/          # one file per migration; append-only, NEVER edited after merge (§4)
│   │       ├── daos/                    # CardDao, ReviewLogDao, … — package-private, behind repositories
│   │       └── repositories/           # CardRepository, ReviewRepository — the public write path
│   └── test/                            # in-memory NativeDatabase tests; migration round-trips
│
├── assets/                              # the ONE network module: pack downloader + integrity verifier
│   ├── pubspec.yaml                     # dependencies: http, crypto, path  ← the ONLY http/crypto in the repo
│   ├── lib/
│   │   ├── assets.dart                  # AssetPackService + AssetRepository (verify-then-expose)
│   │   └── src/
│   │       ├── pack_downloader.dart     # HTTPS GET to a pinned GitHub Release tag; no auth, no cookies
│   │       ├── sha256_verifier.dart     # fail-closed: mismatch ⇒ reject, re-fetch once, then refuse
│   │       └── pinned_manifest.dart     # baked-in tag + per-file SHA-256 (604 fonts, text, layout, mutash.)
│   └── test/                            # HttpOverrides-mocked client; tamper-detection cases
│
├── quran/                               # immutable muṣḥaf rendering — the ONLY package that touches QPC fonts
│   ├── pubspec.yaml                     # dependencies: flutter (rendering primitives)
│   ├── lib/
│   │   ├── quran.dart                   # PageView widget + overlay API
│   │   └── src/
│   │       ├── glyph_page.dart          # selects the page's dedicated QPC font, draws glyph codes —
│   │       │                            #   the glyph-code string is NEVER parsed as Arabic text (PRD R1)
│   │       ├── overlay_painter.dart     # weak-line / mutashābihāt anchors as COORDINATES over the glyph
│   │       │                            #   layer, from bundled geometry — never re-typeset (PRD §11.2)
│   │       └── page_geometry.dart       # line/word rects from the bundled layout dataset
│   └── test/                            # golden tests with the REAL KFGQPC fonts loaded (never Ahem) (PRD §20)
│
├── profiles/                            # local multi-profile model + active-profile selection (no cloud)
│   ├── pubspec.yaml                     # dependencies: meta
│   ├── lib/
│   │   ├── profiles.dart
│   │   └── src/profile.dart             # Profile value type (display name, role, locale, mushaf_id)
│   └── test/
│
└── l10n/                                # ARB strings + generated AppLocalizations + the ckb custom delegate
    ├── pubspec.yaml                     # dependencies: flutter, intl
    ├── lib/
    │   ├── l10n.dart                    # exports AppLocalizations + the numeral/bidi/calendar helpers
    │   └── src/
    │       ├── arb/                      # app_ar.arb (template) · app_fa.arb · app_ckb.arb (§6)
    │       ├── generated/               # gen_l10n output (committed; synthetic-package: false — §6)
    │       ├── ckb_material_localizations.dart  # vendored Material delegate for the custom ckb locale
    │       ├── numerals.dart            # per-locale NumberFormat (Extended Arabic-Indic fa/ckb; Arabic-Indic ar)
    │       └── bidi.dart                # one FSI…PDI isolation helper for mixed-script runs (PRD §13.2)
    └── test/                            # numeral + bidi golden strings per locale
```

`packages/data` carries the `profiles` dependency (a card belongs to a profile) and the `engine` dependency (the review repository persists the immutable `ReviewResult` the engine returns) — both point *downward*, never back. The `quran` package depends on `flutter` for its rendering primitives but on **no** other local package: it receives page geometry as plain value types, so it can be golden-tested in isolation against reference muṣḥaf images (PRD §20 gate 2).

### 3.3 Exemplar manifests

`engine` — an auditor verifies purity from this file alone:

```yaml
# packages/engine/pubspec.yaml
name: engine
description: Pure-Dart Hifz scheduling engine — no Flutter, no I/O, "today" injected.
publish_to: none
resolution: workspace                    # member of the root workspace (§1.1)
environment:
  sdk: ^3.6.0                            # workspaces require ^3.6.0; repo baseline is Dart 3.10
dependencies:
  meta: ^1.15.0                          # @immutable annotations ONLY — no other dependency exists
dev_dependencies:
  test: ^1.25.0                          # plain `dart test`; NOT flutter_test
  glados: ^1.1.0                         # property tests for the §7.12 invariants
# Deliberately absent: flutter, dart:io, any clock, any package that transitively pulls them.
# tool/check_engine_purity.sh greps this tree for `package:flutter`, `dart:io`, `DateTime.now()`.
```

`features` (excerpt) — per-screen libraries with the same narrow dependency set, consuming `data` only through its repository exports:

```yaml
# packages/features/pubspec.yaml (excerpt)
name: features
publish_to: none
resolution: workspace
environment:
  sdk: ^3.6.0
  flutter: ">=3.38.0"
dependencies:
  flutter: { sdk: flutter }
  flutter_riverpod: ^3.0.0               # Decision log: state management
  go_router: ^16.0.0
  engine: { path: ../engine }            # path deps inside a workspace resolve locally, share one lock
  data: { path: ../data }
  quran: { path: ../quran }
  l10n: { path: ../l10n }
  profiles: { path: ../profiles }
  # Deliberately NO http/dio (no feature fetches anything),
  # NO drift (features touch the DB only through data's repositories).
dev_dependencies:
  flutter_test: { sdk: flutter }
```

The `path:` references inside a workspace are resolved against the shared lockfile rather than re-resolved per package, which is exactly the conflict-surfacing behavior pub workspaces is designed to give ([Dart: Pub workspaces](https://dart.dev/tools/pub/workspaces)). Pinning `flutter_riverpod` (not legacy `provider`/`state_notifier`) follows Decision log: *state management*; `provider`, `get_it`, and Bloc are banned by the analyzer config (03 §2).

### 3.4 Feature folder anatomy

`packages/features` is an umbrella package: one Dart library per screen, each in its own folder, each with the same shape. Deviations need a comment in the PR.

```
packages/features/lib/src/
├── today/                               # the core recite/grade screen (PRD §12.2)
│   ├── today_screen.dart                # the navigable entry View — "dumb" per Flutter (Decision log: state)
│   ├── today_view_model.dart            # the 1:1 ViewModel: reads CardRepository, calls engine, exposes
│   │                                    #   commands (submitGrade, signOff) — "most of the logic lives here"
│   ├── widgets/                         # leaf views: revise-item row, reveal-on-tap, grade buttons
│   └── today_providers.dart             # the screen's Riverpod providers (scoped, not global)
├── mushaf/                              # the reader; renders via the quran package (PRD §12.3)
├── mutashabihat/                        # the discrimination trainer (PRD §12.4)
├── progress/                            # the retention heat-map (PRD §12.5)
├── onboarding/                          # cold-start: coverage capture, per-juz confidence (PRD §7.10, §12.1)
└── settings/                            # presets, profiles, backup (PRD §15, §16)
```

Each feature is a `View` + a 1:1 `ViewModel` (Flutter's "views and view models should have a one-to-one relationship" — [Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)); the ViewModel reads repositories from `data`, hands immutable cards to the `engine`, and exposes commands the View binds to event handlers. Providers are **scoped to the feature**, never declared globally — the only global composition is in `app/composition/providers.dart` (§2). The full View/ViewModel and command patterns are specified in [04-flutter-and-state-patterns.md](04-flutter-and-state-patterns.md).

## 4. File naming and organization conventions

| Item | Convention | Example |
|---|---|---|
| Dart file | `lower_snake_case`, named after its primary type ([Dart: Effective Dart — Style](https://dart.dev/effective-dart/style)) | `trust_clamp.dart` |
| One type per file | One primary public type per file; small private helpers may share it | `card.dart` + a private extension |
| Public library barrel | `lib/<package>.dart` exports the public API only | `engine.dart` exports the API |
| Private implementation | everything under `lib/src/` is package-private ([Dart: Package layout](https://dart.dev/tools/pub/package-layout)) | `lib/src/curve.dart` |
| Migration | `m###_short_description.dart`, sequential, immutable once merged | `m002_add_line_blocks.dart` |
| ViewModel | `<feature>_view_model.dart`, 1:1 with the screen | `today_view_model.dart` |
| Feature entry view | `<feature>_screen.dart` | `mushaf_screen.dart` |
| Test file | `<source>_test.dart`, mirroring the source tree | `trust_clamp_test.dart` |
| Package names | `lower_snake_case` nouns | `engine`, `quran` |

Organization rules that carry audit weight:

- **The `lib/` vs `lib/src/` split is the package's public-API boundary, not a style choice.** "By convention, implementation code is placed under `lib/src`," it "remains private to the package" unless re-exported, and code "should never import from another package's `lib/src` directory" ([Dart: Package layout conventions](https://dart.dev/tools/pub/package-layout)). So the only stable surface of `engine` is what `engine.dart` exports; the trust-clamp internals can be refactored freely. The analyzer's `implementation_imports` and `depend_on_referenced_packages` lints enforce the cross-package half of this ([Dart: Linter rules](https://dart.dev/tools/linter-rules)).
- **Migrations are append-only files.** A migration merged to `main` is never edited; a schema fix is a new `m###` file. This keeps the migration history a linear, reviewable diff (Decision log: *persistence*; specified in [05-persistence-and-encryption.md](05-persistence-and-encryption.md)).
- **No `utils/`, `helpers/`, `common/`, or `core/` junk-drawer folders.** A helper either belongs to the type it serves (a same-file extension) or it is a named service/value type with a real home. Junk-drawer folders are where undeclared dependencies and accidental layer violations breed; the import-ban lints (§5) cannot reason about a folder whose meaning is "miscellaneous."

## 5. Dependency rules (the machine-checked boundaries)

The dependency matrix (§3.1) is not documentation that drifts from reality — it is enforced two ways, and a PR that violates it fails CI. This is the project-structure expression of the no-network and engine-purity values ([README §non-negotiable values](README.md)).

**Decision.** Layer boundaries are enforced by (a) each package's `pubspec.yaml` dependency list (a package simply cannot import what it does not declare), and (b) the DCM `avoid-banned-imports` rule plus the `tool/` grep scripts for the rules a manifest cannot express (e.g. "no `DateTime.now()` *inside* `engine`," "no QPC font handling *outside* `quran`"). This is Decision log: *no networking* and Decision log: *scheduling engine*, made structural.

**Rationale.** A `pubspec.yaml` is the strongest possible boundary for cross-package imports: pub workspaces resolves the whole graph in one analysis context, so an undeclared import is a resolution/analysis error, not a runtime surprise ([Dart: Pub workspaces](https://dart.dev/tools/pub/workspaces)). For the finer rules, `avoid-banned-imports` lets us scope a banned-import regex to a `paths` regex with a custom message, so a banned import is flagged in the IDE and in CI with an explanation ([DCM: avoid-banned-imports](https://dcm.dev/docs/rules/common/avoid-banned-imports/)). Belt-and-suspenders grep scripts in `tool/` catch the symbol-level bans (a bare `DateTime.now()`, a `package:http` outside `assets`) that an import-path lint alone would miss, and they run identically locally and in CI so there is no CI-only logic to drift.

**Specification.** The root `analysis_options.yaml` (excerpt):

```yaml
# analysis_options.yaml  (workspace root — one analysis context covers every package)
analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
dart_code_metrics:                       # DCM, run in CI (Decision log: testing strategy & CI)
  rules:
    - avoid-banned-imports:
        entries:
          # 1. Engine purity: the scheduler may not see Flutter or I/O.
          - paths: ['packages/engine/.*\.dart']
            deny: ['package:flutter/.*', 'dart:io', 'dart:ui']
            message: 'The engine is pure Dart (PRD §19.1). Move I/O to data/ or assets/.'
          # 2. No-network: only the assets package may reach the network.
          - paths: ['(?!packages/assets/).*\.dart']
            deny: ['package:http/.*', 'package:dio/.*', 'dart:io.*HttpClient']
            message: 'Networking is allowed ONLY in packages/assets (PRD C1, §17).'
          # 3. Quran isolation: QPC glyph handling lives only in the quran package.
          - paths: ['(?!packages/quran/).*\.dart']
            deny: ['package:quran/src/glyph_page.dart']
            message: 'Glyph-font rendering is owned by packages/quran (PRD R1).'
          # 4. Features depend down, never sideways into another feature's src.
          - paths: ['packages/features/lib/src/(\w+)/.*\.dart']
            deny: ['package:features/src/(?!\1/).*']
            message: 'Features must not import another feature internals; share via a leaf package.'
```

The matching grep gate (run before push and in CI):

```bash
# tool/check_engine_purity.sh  (exits non-zero on any hit)
set -euo pipefail
! grep -rnE "package:flutter|dart:io|DateTime\.now\(|DateTime\.timestamp\(" \
    packages/engine/lib packages/engine/test \
  || { echo "engine purity violated — see PRD §19.1"; exit 1; }
```

**Pitfalls / what we refuse.** We refuse to rely on convention alone — "the engine should stay pure" is a comment, not a guarantee; the lint and the grep are the guarantee. We refuse a single mega-package with internal folders standing in for packages: folder boundaries are not enforced by resolution, so the engine's purity would be unprovable from any manifest. We refuse `dependency_overrides` as a workaround for a banned import (it would hide, not fix, a layer violation). And we refuse to let `app/` push logic upward — the shell may import everything precisely *because* it computes nothing; any business logic discovered in `app/lib/` is a review-blocking bug, not a shortcut.

## 6. Localization, fonts, and generated sources

**Decision.** ARB files and the generated `AppLocalizations` live in the `l10n` package; `gen_l10n` is configured with `synthetic-package: false` so the generated Dart is emitted into source and committed, with `ar` as the template/base locale and `fa`/`ckb` as translations (Decision log: *localization, RTL & accessibility impl*). UI fonts are bundled in the `app/` binary; Quran QPC fonts are not (they download in the core pack — §2).

**Rationale.** Flutter removed the synthetic `package:flutter_gen`: "the `flutter` tool will no longer generate a synthetic `package:flutter_gen`… Applications or tools that referenced `package:flutter_gen` should instead reference source files generated into the app's source directory directly," and `generate: true` is now required in `pubspec.yaml` ([Flutter: Generate localizations into source](https://docs.flutter.dev/release/breaking-changes/flutter-generate-i10n-source)). Generating into a real package directory (not `.dart_tool`) means the localizations are diffable in review, the `ckb` custom-locale delegate can sit beside them, and the l10n-completeness gate (PRD §20 gate 5) reads committed files. Placement and the per-locale numeral/bidi rules are detailed in [12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md).

**Specification.** The workspace-root `l10n.yaml`:

```yaml
# l10n.yaml
arb-dir: packages/l10n/lib/src/arb
template-arb-file: app_ar.arb            # ar is the base content language (Decision log: l10n)
output-dir: packages/l10n/lib/src/generated
output-localization-file: app_localizations.dart
output-class: AppLocalizations
synthetic-package: false                 # emit into source, commit it (Flutter breaking change)
```

Resource placement:

| Resource | Lives in | Notes |
|---|---|---|
| UI font files (fa/ar/ckb) | `app/assets/fonts/`, declared in `app/pubspec.yaml` `fonts:` | Bundled; no `google_fonts` runtime fetch ([Flutter: Use a custom font](https://docs.flutter.dev/cookbook/design/fonts); PRD §13.5) |
| ARB strings | `packages/l10n/lib/src/arb/app_{ar,fa,ckb}.arb` | One file per locale; `ar` is the template |
| Generated `AppLocalizations` | `packages/l10n/lib/src/generated/` | Committed; produced by `gen_l10n` |
| `ckb` Material delegate | `packages/l10n/lib/src/ckb_material_localizations.dart` | Custom locale lacks first-party Material l10n (Decision log: l10n) |
| Quran QPC glyph fonts | downloaded core pack → app-support storage | NOT bundled; verified then `FontLoader`-loaded ([09](09-asset-packs-and-offline-integrity.md)) |

**Pitfalls / what we refuse.** We refuse `synthetic-package: true` (or omitting `synthetic-package`, which is removed) — the generated code must be in-tree and committed so the completeness gate and review can see it. We refuse to scatter ARB files across feature folders — one `l10n` package owns every string, so the "zero missing keys / no hardcoded UI strings" gate is a single-directory check (PRD §20 gate 5). We refuse any `google_fonts` dependency entirely: a runtime font fetch is a network call (PRD C1) and would risk a wrong glyph (PRD R1); every UI font is bundled and every Quran font is verified by hash before load.

## 7. CI, scripts, and docs

- `.github/workflows/ci.yml` is the only workflow; its jobs (pure-`engine` `dart test`, widget/golden tests with real fonts, the dependency/import-restraint job, emulator journeys) are specified in [11-testing-strategy.md](11-testing-strategy.md) and the decision log (Decision log: *testing strategy & CI*). It pins `subosito/flutter-action` to an exact `flutter-version` so goldens stay stable across runs ([Flutter API: matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)).
- Every script in `tool/` runs locally with no arguments and exits non-zero on violation; run them before pushing. CI runs the same files — there is no CI-only logic to drift.
- `docs/engineering/` is this doc set; `docs/engineering/research/` holds the dated research notes the decisions cite. `docs/design-system/` and `docs/science/` are authored on parallel tracks; engineering docs reference them generically and never restate their values.

## References

- Dart team. *Pub workspaces (monorepo support)* (shared resolution; single analysis context; `workspace:` / `resolution: workspace`; `^3.6.0` requirement). https://dart.dev/tools/pub/workspaces
- Dart team. *Package layout conventions* (`lib/` public API; `lib/src/` private implementation; never import another package's `lib/src`). https://dart.dev/tools/pub/package-layout
- Dart team. *The pubspec file* (committed `pubspec.lock` for applications). https://dart.dev/tools/pub/pubspec
- Dart team. *Effective Dart: Style* (`lower_snake_case` file names). https://dart.dev/effective-dart/style
- Dart team. *Linter rules* (`implementation_imports`, `depend_on_referenced_packages`). https://dart.dev/tools/linter-rules
- Flutter (Google). *Guide to app architecture* (MVVM; dumb views; 1:1 view/view-model; repositories as source of truth; services as the lowest layer). https://docs.flutter.dev/app-architecture/guide
- Flutter (Google). *Architecture recommendations and resources* (separation of concerns; dependency injection / no global singletons; unidirectional flow). https://docs.flutter.dev/app-architecture/recommendations
- Flutter (Google). *Developing packages & plugins* (pure-Dart packages are the easiest layer to test). https://docs.flutter.dev/packages-and-plugins/developing-packages
- Flutter (Google). *Use a custom font* (bundled fonts declared in `pubspec.yaml` `fonts:`). https://docs.flutter.dev/cookbook/design/fonts
- Flutter (Google). *Localized messages are generated into source, not a synthetic package* (`synthetic-package: false`; `generate: true` required). https://docs.flutter.dev/release/breaking-changes/flutter-generate-i10n-source
- Flutter API. *FontLoader class* (runtime font loading for the downloaded QPC packs). https://api.flutter.dev/flutter/services/FontLoader-class.html
- Flutter API. *matchesGoldenFile function* (goldens are OS/font/version sensitive; pin the runner). https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html
- DCM. *avoid-banned-imports rule* (`entries` with `paths`/`deny`/`message`/`severity` for per-directory import bans). https://dcm.dev/docs/rules/common/avoid-banned-imports/
- Invertase. *melos — Dart/Flutter monorepo task runner.* https://pub.dev/packages/melos
- Hifz Companion. *Engineering README & tech-decision log.* [README.md](README.md)
- Hifz Companion. *Product Requirements Document.* [PRD.md](../PRD.md)

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
