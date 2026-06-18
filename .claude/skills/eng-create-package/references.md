# references — eng-create-package

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/engineering/02-project-structure.md` §1.1 (Why pub workspaces) — **The package is a `pub workspace` member, not a `path:` dependency.** Add it to the root `pubspec.yaml` `workspace:` list and put `resolution: workspace` in its manifest; every member needs `sdk: ^3.6.0`+; the workspace resolves the whole graph in one analysis context and keeps one committed lock. No `dependency_overrides`, no per-package lockfile.

- `docs/engineering/02-project-structure.md` §3.1 (Dependency matrix) — **The audit map, enforced by `pubspec.yaml` + `tool/` greps + DCM lints.** `engine` deps = none-but-`meta`, Flutter? No; `assets` is the only `http`/`crypto` package; `data` deps `drift`/`sqlite3`/`path`/`engine`/`profiles`; `quran` deps only `flutter`; `features` deps down on the leaves + riverpod/go_router; no leaf imports `features`.

- `docs/engineering/02-project-structure.md` §3.2 (Package internals) — **The full tree for each package**: `pubspec.yaml` + `lib/<package>.dart` barrel + `lib/src/` private + `test/`. Shows engine's `models/` value types, data's `daos/` behind `repositories/`, assets' `pack_downloader`/`sha256_verifier`/`pinned_manifest`, quran's glyph-isolation, and that `quran` golden-tests with the real KFGQPC fonts.

- `docs/engineering/02-project-structure.md` §3.3 (Exemplar manifests) — **The copy-from manifests.** The `engine` pubspec ("an auditor verifies purity from this file alone": `meta` only, `test`+`glados` dev-deps, deliberately-absent flutter/dart:io/clock) and the `features` excerpt (narrow downward `path:` deps, `flutter_riverpod` not legacy `provider`).

- `docs/engineering/02-project-structure.md` §4 (Naming & organization) — **`lib/` vs `lib/src/` is the public-API boundary, not style; never import another package's `lib/src`.** `lower_snake_case` package nouns; one public type per file; **no `utils/`/`helpers/`/`common/`/`core/` junk-drawer folders.**

- `docs/engineering/02-project-structure.md` §5 (Dependency rules) — **The boundaries are machine-checked two ways:** each `pubspec.yaml` (can't import what you don't declare) + DCM `avoid-banned-imports` (engine purity, no-network-outside-assets, quran isolation, no sideways feature imports) + `tool/check_*.sh` greps. "Convention is a comment, the lint and the grep are the guarantee."

## Supporting

- `docs/engineering/02-project-structure.md` §1 (Top-level tree) — **What is deliberately absent and kept absent:** no `google_fonts`, no analytics/ads/crash/backend SDK, no networking dep outside `packages/assets`. The committed root `pubspec.lock` is the one-file dependency audit.

- `docs/engineering/02-project-structure.md` §2 (The app shell) — **`app/` is the composition root — the one target that depends on every package because it computes nothing.** Any business logic discovered in `app/lib/` is a review-blocking bug, not a leaf package. Locale → `Directionality.rtl` by construction.

- `docs/engineering/02-project-structure.md` §3.4 (Feature folder anatomy) — **A new screen is a feature folder (View + 1:1 ViewModel + `widgets/` + scoped providers), not a new package.** Providers are scoped to the feature; the only global composition is `app/composition/providers.dart`.

- `docs/engineering/02-project-structure.md` §6 (Localization, fonts, generated sources) — **Every UI string lives in the `l10n` package** (`ar` template, `fa`/`ckb`), generated with `synthetic-package: false` and committed; UI fonts bundled in `app/`, QPC fonts download-then-verify. No scattered ARB, no `google_fonts`.

- `docs/engineering/01-architecture-overview.md` §2 (Layer model) — **Five layers, lower never imports upward; the boundary that matters runs between Layer 1 (engine) and Layer 2 (Flutter shell).** Riverpod is the DI mechanism; no second DI library, no `provider`+Riverpod, no global singletons.

- `docs/engineering/01-architecture-overview.md` §3.1 / §3.3 (Module map; engine is a *package*) — **The allowed-imports table is normative**, and "you cannot import something you haven't declared" is why the engine is a package, not a folder — its `pubspec.yaml` is the purity audit, the way CycleVault's `Package.swift` is.

- `docs/engineering/01-architecture-overview.md` §5 (Pure-Dart engine core) — **The engine refuses `DateTime.now()` ("today" is injected), refuses interval fuzzing, refuses the `fsrs` pub package as a runtime dep** (vendor the ~30 lines). A pure package has no `WidgetTester` and runs the fastest, CI-cheapest test tier under plain `dart test`.

- `docs/engineering/01-architecture-overview.md` §6 (Offline guarantee) — **Networking is quarantined to `assets/`; a banned-import lint + dependency allow-list fail the build on any networking import or analytics/ads/backend SDK elsewhere.** Tests install an `HttpOverrides` that throws so stray calls fail loudly.

- `docs/engineering/13-oss-repo-and-release.md` §2 (Trust pack & REUSE) — **Every file carries `SPDX-License-Identifier` + `SPDX-FileCopyrightText`; `reuse lint` is release-blocking.** New Dart files in the package need the `GPL-3.0-or-later` header.

- `docs/engineering/13-oss-repo-and-release.md` §5 (F-Droid entry ticket) — **A new dependency must not drag in Play Services/Firebase/Crashlytics or any ad/tracking SDK** — the dep allow-list catches it at PR time, and a single such transitive dep forfeits F-Droid eligibility. The pubspec is the FLOSS-everything audit.

## Sibling skills

- **domain-scheduling-engine-rules** — the pure DSR logic (curve, trust clamp, tracks, golden vectors) that lives *inside* the `engine` package this skill scaffolds; go there for the math, here for the manifest/boundary.
- **domain-mushaf-text-integrity** — the immutable QPC glyph-rendering rules inside the `quran` package; the manifest isolation this skill enforces is what keeps glyph handling there.
- **domain-asset-pack-integrity** — the bundled-core verifier, the optional-pack downloader, the SHA-256 verifier, and the pinned manifest inside the `assets` package, the single permitted network module.
- **domain-grading-pipeline** — the review→engine→persist single write path that crosses the `features`→`data`→`engine` packages this layout separates.
- **domain-mutashabihat-system** — the discrimination-trainer feature and dataset hosted by this package layout.
