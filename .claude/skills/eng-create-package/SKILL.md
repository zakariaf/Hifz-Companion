---
name: eng-create-package
description: Scaffold a new local Dart/Flutter package (or correct its pubspec) under the Hifz Companion pub workspace — especially the pure-Dart engine package with zero Flutter/IO imports. Use whenever adding any package under packages/, authoring or fixing a pubspec.yaml, wiring a resolution:workspace member, or setting the dependency boundary that keeps the engine pure and the layers (engine → data/assets/quran/l10n/profiles → features → app) separated and machine-checkable.
---

# eng-create-package

A package's `pubspec.yaml` is not boilerplate — it is the **audit artifact**. An auditor proves "the engine imports no Flutter and no I/O", "networking exists in exactly one module", and "no QPC glyph font is touched outside `quran`" by reading manifests, never source (`docs/engineering/02-project-structure.md` §3.1; `docs/engineering/01-architecture-overview.md` §3.3). Every rule below exists so each manifest stays one screen long and tells the whole truth: a package literally cannot import what it does not declare, so the dependency list *is* the layer boundary.

This skill scaffolds a package to the canonical Hifz layout: a `pub workspace` member (`resolution: workspace`), `sdk: ^3.6.0` minimum, a single public barrel `lib/<package>.dart` over a private `lib/src/` tree, the narrowest possible dependency set, and `dart test` for pure packages / `flutter_test` only where Flutter is genuinely needed. The seven canonical packages (`engine`, `data`, `assets`, `quran`, `features`, `l10n`, `profiles`) already define the shape; come here to add a genuinely new module or to correct any manifest so it passes the CI boundary gates.

## When to use

Use this skill when you:

- add any new local package under `packages/` (a new module beyond the seven canonical ones is a decision-log-level event — note it in the PR);
- create or reshape the pure-Dart `engine` package, or any pure value-type package, where the entire audit story is one empty-but-`meta` dependency line (`docs/engineering/02-project-structure.md` §3.3);
- author or correct any `pubspec.yaml` so it passes `dart pub get` in the workspace and the `tool/` + DCM `avoid-banned-imports` boundary gates (`docs/engineering/02-project-structure.md` §5);
- wire a new member into the root `workspace:` list and add `resolution: workspace` to its manifest (`docs/engineering/02-project-structure.md` §1.1).

Do **NOT** use this skill for:

- the thin `app/` shell wiring, `composition/providers.dart`, the router, or `bootstrap/first_run.dart` — that is the composition root, not a leaf package (`docs/engineering/02-project-structure.md` §2). It is the *one* target allowed to depend on every package, precisely because it computes nothing.
- a new **per-screen feature library** inside the `features` umbrella (View + 1:1 ViewModel, `widgets/`, scoped Riverpod providers) — that is feature-folder anatomy, governed by `docs/engineering/02-project-structure.md` §3.4; come back here only for the umbrella package's manifest entries.
- adding an **external** dependency without first justifying it on the `tool/check_dep_allowlist.sh` allow-list — a new external dep (especially anything pulling `http`/`dio`, analytics, ads, crash-reporting, or `google_fonts`) is a decision-log change and an F-Droid/offline risk, not a scaffold step (`docs/engineering/02-project-structure.md` §1, §6; `docs/engineering/13-oss-repo-and-release.md` §5).
- engine *logic* (the curve, trust clamp, tracks, golden vectors) → use **domain-scheduling-engine-rules**.
- persistence schema, DAOs, repositories, or migrations inside `data` → use **domain-asset-pack-integrity** for the asset/integrity side; schema/migration authoring belongs to the `data` package's own conventions (`docs/engineering/02-project-structure.md` §3.2).
- QPC glyph rendering or text-fidelity work inside `quran` → use **domain-mushaf-text-integrity**.
- the asset-pack downloader, SHA-256 verifier, or pinned manifest inside `assets` → use **domain-asset-pack-integrity**.

## The canonical pattern

### 1. Place the package and make it a workspace member
The package lives at `packages/<name>/`; `<name>` is a `lower_snake_case` noun (`engine`, `quran`, never `EngineKit`) (`docs/engineering/02-project-structure.md` §4 naming table). Add the path to the root `pubspec.yaml` `workspace:` list and put `resolution: workspace` in the new manifest — this is the modern first-party successor to `path:`/`dependency_overrides` wiring, and it makes the analyzer resolve the whole graph in **one analysis context** so an undeclared import is an analysis error, not a runtime surprise (`docs/engineering/02-project-structure.md` §1.1). Do not check in a per-package `pubspec.lock`; the workspace has exactly one committed lock at the root.

### 2. SDK constraint and environment
Every workspace member declares `environment: sdk: ^3.6.0` or higher (pub workspaces require it on all members; repo baseline is Dart 3.10) (`docs/engineering/02-project-structure.md` §1.1, §3.3). A package that imports Flutter adds `flutter: ">=3.38.0"` to `environment` and depends on `flutter: { sdk: flutter }`; a **pure** package adds neither — the absence of any Flutter line is itself audit evidence (`docs/engineering/02-project-structure.md` §3.3).

### 3. Public barrel over a private `lib/src/`
Expose exactly one public library: `lib/<package>.dart` that exports **only** the stable API surface; everything else lives under `lib/src/` and is package-private. The `lib/` vs `lib/src/` split is the public-API boundary, not a style choice — other packages may never import another package's `lib/src` (`docs/engineering/02-project-structure.md` §4). So `data.dart` exports repositories + DTOs, never the raw DAOs; `engine.dart` exports the API, never `trust_clamp.dart` internals.

### 4. The audit-minimal dependency set (the whole point)
Declare the *minimum* dependency list; an unused dependency is a review reject because it muddies the audit. Honor the dependency matrix exactly (`docs/engineering/02-project-structure.md` §3.1; `docs/engineering/01-architecture-overview.md` §3.1):
- **`engine` depends on nothing but `meta`** (and, in the §3.1 representation, the bottom-of-graph `models` value types) — no `flutter`, no `dart:io`, no clock, no package that transitively pulls them. This one line *is* the entire purity audit (`docs/engineering/02-project-structure.md` §3.3; PRD §19.1).
- **`assets` is the only package that may depend on `http`/`crypto`** (and the only one allowed `dart:io HttpClient`) — it is the single network quarantine (`docs/engineering/01-architecture-overview.md` §6; `docs/engineering/02-project-structure.md` §3.1).
- **`data`** depends on `drift`, `sqlite3`, `path`, plus the downward local edges `engine` and `profiles` — never `http`, never `features`.
- **`quran`** depends on `flutter` for rendering primitives and on **no other local package** — it receives page geometry as plain value types so it golden-tests in isolation (`docs/engineering/02-project-structure.md` §3.2).
- **`features`** depends down on `engine`, `data`, `quran`, `l10n`, `profiles` plus `flutter_riverpod` + `go_router`; no leaf package imports `features`. Dependencies point one way (`docs/engineering/02-project-structure.md` §3.1).
- Banned everywhere: `google_fonts` (UI fonts are bundled; QPC fonts download verified), and any analytics/ads/crash/backend SDK (`docs/engineering/02-project-structure.md` §1, §6; `docs/engineering/13-oss-repo-and-release.md` §5). Banned in `engine`: `package:flutter`, `dart:io`, `dart:ui`, and any `DateTime.now()`/`DateTime.timestamp()` — "today" is an injected `CalendarDate` parameter (`docs/engineering/01-architecture-overview.md` §5; `docs/engineering/02-project-structure.md` §5).

### 5. State management and the banned list
A package that holds UI state uses `flutter_riverpod` (Decision log: state management); `provider`, `get_it`, and Bloc are banned by the analyzer config (`docs/engineering/02-project-structure.md` §3.3). Two DI mechanisms is two sources of truth — Riverpod alone satisfies the "no global singletons" rule, and providers are scoped to a feature, never declared globally (the only global composition is `app/composition/providers.dart`) (`docs/engineering/01-architecture-overview.md` §2; `docs/engineering/02-project-structure.md` §3.4).

### 6. Tests: pure vs Flutter
A pure package (`engine`, `profiles`) declares `dev_dependencies: test` and runs under **plain `dart test`** with no widget binding — "the easiest layer to test" — plus `glados` for the §7.12 engine invariants (`docs/engineering/02-project-structure.md` §3.3; `docs/engineering/01-architecture-overview.md` §5). A Flutter package declares `flutter_test: { sdk: flutter }`; `quran` golden-tests with the **real** KFGQPC fonts (never Ahem) (`docs/engineering/02-project-structure.md` §3.2). Tests installing an `HttpOverrides` that *throws* make any stray network call fail loudly rather than silently 400-ing (`docs/engineering/01-architecture-overview.md` §6).

### 7. No junk-drawer folders
No `utils/`, `helpers/`, `common/`, or `core/` folders. A helper either belongs to the type it serves (a same-file extension) or is a named service/value type with a real home — junk-drawer folders are where undeclared dependencies and layer violations breed, and the import-ban lints cannot reason about a folder whose meaning is "miscellaneous" (`docs/engineering/02-project-structure.md` §4).

### 8. l10n placement (if the package surfaces strings)
There are no scattered ARB files: every UI string lives in the `l10n` package (`ar` template, `fa`/`ckb` translations), generated into source with `synthetic-package: false` and committed, so the zero-missing-keys / no-hardcoded-strings gate is a single-directory check (`docs/engineering/02-project-structure.md` §6). A new package never declares its own `l10n.yaml` or `flutter_gen`; it consumes `AppLocalizations` from the `l10n` package. All three locales are RTL — the app sets `Directionality.rtl` by construction from the locale (`docs/engineering/02-project-structure.md` §2).

### 9. Per-file license header and the workspace gates
Every Dart file carries the REUSE header `// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors` + `// SPDX-License-Identifier: GPL-3.0-or-later`; `reuse lint` is release-blocking (`docs/engineering/13-oss-repo-and-release.md` §2). Before pushing, the new manifest must pass `dart pub get` (workspace resolves with no clash — no `dependency_overrides`), the DCM `avoid-banned-imports` lint, and the matching `tool/` grep gates (`check_engine_purity.sh`, `check_no_network.sh`, `check_quran_isolation.sh`, `check_dep_allowlist.sh`) which run identically locally and in CI (`docs/engineering/02-project-structure.md` §5, §7).

## Do / Don't

| Do | Don't |
|---|---|
| Add the package to the root `workspace:` list and set `resolution: workspace` | Use `path:`/`dependency_overrides` wiring or check in a per-package lockfile |
| Set `environment: sdk: ^3.6.0` on every member | Omit the SDK constraint or use a lower bound |
| Keep `engine`'s deps to `meta` (+ `models`) — no flutter, no dart:io, no clock | Add any Flutter/IO/`DateTime.now()` path to the engine |
| Confine `http`/`crypto`/`HttpClient` to `assets` alone | Let any other package gain a networking import |
| Expose one `lib/<package>.dart` barrel over private `lib/src/` | Let another package import your `lib/src/` |
| Declare the minimum deps; remove unused edges | Leave a speculative dependency "for later" |
| Point dependencies downward (`features → engine/data/quran/l10n/profiles`) | Make any leaf package import `features` |
| Use `flutter_riverpod`; scope providers to a feature | Add `provider`/`get_it`/Bloc, or declare a global provider |
| Use `dart test` for pure packages, `flutter_test` only where Flutter is needed | Pull `flutter_test` into a pure package to "borrow" a matcher |
| Consume strings from the `l10n` package | Add a second `l10n.yaml`, `flutter_gen`, or `google_fonts` |
| Add a REUSE SPDX header to every Dart file | Leave license-in-README ambiguity |

## Checklist

Before the manifest is done:

- [ ] Package is at `packages/<lower_snake_case_noun>/`, added to the root `workspace:` list, with `resolution: workspace` in its manifest.
- [ ] `environment: sdk: ^3.6.0` (or higher); a Flutter package also pins `flutter: ">=3.38.0"` and `flutter: { sdk: flutter }`; a pure package declares neither.
- [ ] Exactly one public barrel `lib/<package>.dart` exporting the stable API only; all else under `lib/src/`; no cross-package `lib/src` import.
- [ ] Dependency list is audit-minimal and matches the §3.1 matrix; no unused edge; no external dep absent from `tool/check_dep_allowlist.sh`.
- [ ] If this is `engine` (or a pure package): deps are `meta`(+`models`) only — no `flutter`, no `dart:io`/`dart:ui`, no `DateTime.now()`/`DateTime.timestamp()`; "today" is an injected `CalendarDate`.
- [ ] Networking imports (`http`/`dio`/`HttpClient`) appear **only** if this package is `assets`; nowhere else.
- [ ] QPC glyph-font / glyph-string handling appears **only** if this package is `quran`.
- [ ] Dependencies point downward; no leaf package imports `features`; `quran` has no local package dep.
- [ ] State-bearing packages use `flutter_riverpod`; no `provider`/`get_it`/Bloc; providers scoped to a feature, never global.
- [ ] Tests wired: `test` (+`glados`) for pure packages via `dart test`; `flutter_test` for Flutter packages; `quran` goldens use the real KFGQPC fonts; a throwing `HttpOverrides` guards stray network calls.
- [ ] No `utils/`/`helpers/`/`common/`/`core/` folder; helpers live on their type or as named services.
- [ ] Any UI strings come from the `l10n` package (ar template, fa/ckb); RTL is structural; no per-package `l10n.yaml`/`flutter_gen`/`google_fonts`.
- [ ] Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`).
- [ ] Boundary gates pass locally: `dart pub get` (no clash, no `dependency_overrides`), DCM `avoid-banned-imports`, and the `tool/check_*.sh` greps; CI runs the same files.

This skill scaffolds manifests and package skeletons only — it never authors scheduling math, a Quran glyph render, an asset hash, or a user-facing factual claim, so the text-fidelity, sect-neutrality, no-gamification, servant-to-teacher, and privacy non-negotiables are *inherited* by the packages it wires up, enforced where that logic lives (see the domain skills below). The manifest's job is to make those guarantees provable by `grep`, not by trust.

## Files

- `template.dart` — a copy-paste scaffold for a new package: the `pubspec.yaml` shown for both a pure host-testable package and a Flutter UI package, the `lib/<package>.dart` public barrel, a `lib/src/` private unit, and the matching `dart test`/`flutter_test` shape, with `// TODO:` markers for the specifics. (Named `.dart` for editor support; copy each labelled block into the right file.)
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-scheduling-engine-rules** (the pure logic that lives inside the `engine` package this skill scaffolds), **domain-mushaf-text-integrity** (the QPC rendering rules inside `quran`), **domain-asset-pack-integrity** (the downloader/verifier inside `assets` — the one network module), **domain-grading-pipeline** (the review→persist write path that crosses the `features`→`data`→`engine` packages), **domain-mutashabihat-system** (the discrimination feature/data this layout hosts).
