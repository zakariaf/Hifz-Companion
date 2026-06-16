# E01 — Repo Scaffold, Pub Workspace & CI Guardrails

Stand up the public GPL-3.0 pub workspace, the thin `app/` Flutter shell, and the nine local Dart/Flutter package stubs with their locked dependency graph, plus the four-job CI pipeline whose gates — symbol-level no-network / banned-import ban, SHA-256 text & asset integrity, engine golden-vector + invariant property run, pinned-OS muṣḥaf/RTL goldens, `reuse lint`, dependency allow-list, coverage — make every later epic's guarantee machine-checkable from the first commit. This epic turns the engineering decision log into enforceable structure before any feature code exists: after E01, "the engine is pure Dart," "networking lives in exactly one module," and "the muṣḥaf bytes cannot drift" are facts a stranger verifies from `pubspec.yaml` manifests and public CI logs — not promises.

## Why this epic exists

This app's audience — huffaz, teachers, scholars, privacy-literate reviewers — audits before it installs; the open repository *is* the product's credibility, the *waqf* form of the gift ([PRD §1, §17](../../docs/PRD.md); engineering 01 §6). The product's central promises are structural, not behavioural: "fully offline; no per-user data ever leaves the device" ([PRD C1, §17](../../docs/PRD.md)) and "Quran text fidelity is existential" ([PRD R1, §11](../../docs/PRD.md)) are reputation-ending if broken, and only believable because the source is open and the gates are public (engineering 01 §1, §6; engineering 13 §2, §8). The build order makes foundation-with-full-test-scaffolding first so the correctness gates exist before the first line of scheduling math or the first muṣḥaf glyph is written (engineering 11 §8). E01 is where those commitments become machine-checked.

The documented failure modes this epic structurally forecloses:

- **A privacy claim that is "just a claim."** The category's trust deficit is that the most skeptical users cannot verify an offline promise. An import-level grep alone is *unsound* here — `HttpClient` ships inside `dart:io`, which non-UI code may legitimately import — so E01 lands the three-layer no-network gate (dependency allow-list over the resolved graph, the DCM `avoid-banned-imports` analyzer scope, and a throwing `HttpOverrides` in the test bootstrap) and quarantines every networking symbol to the single `assets/` downloader (engineering 01 §6; engineering 11 §7; engineering 03 §7.2).
- **A single altered Quran byte.** Text fidelity ends the project if it slips ([PRD R1](../../docs/PRD.md)). E01 ships the `tool/verify_asset_hashes.dart` harness and the pinned-OS, real-font golden CI job that E05's muṣḥaf rendering plugs into, so the SHA-256 text-integrity gate and the diacritic-level visual-diff exist before any page is rendered (engineering 11 §5, §9).
- **A schedule that silently drifts or tells a ḥāfiẓ a page is "safe to drop."** The engine's covenant — "may only make a page *more* frequent, never less" ([PRD §7.6, §7.12](../../docs/PRD.md)) — is enforced by the pure-package boundary (`engine` depends on `meta` only, no Flutter, no `dart:io`, no wall clock) and by the `dart test engine/` golden-vector + `glados` invariant run that E04 fills in. E01 erects the boundary and the harness; E04 writes the math into them (engineering 01 §5; engineering 11 §3, §4).
- **A GPL App Store takedown / a forked, paywalled, telemetry-laden derivative.** The GPLv3 §7 App Store additional permission and the per-file REUSE SPDX headers ship in the first commit, and DCO sign-off makes every inbound contribution arrive under them — closing the VLC/GNU-Go failure mode before any second copyright holder exists (engineering 13 §1, §2, §3).
- **A supply-chain surface this audience will scrutinize.** One committed `pubspec.lock` for the whole workspace is the audit map; the dependency allow-list fails CI on any analytics/ads/backend/crash SDK or `google_fonts`, the F-Droid entry ticket verbatim (engineering 02 §1.1; engineering 13 §4, §5).

## Scope

### In scope

- The **pub-workspace root**: `pubspec.yaml` with `workspace:` listing every member and carrying no application code, the single committed root `pubspec.lock`, `analysis_options.yaml` (flutter_lints baseline, `--fatal-infos`, formatter `page_width: 80`, the path-scoped `avoid-banned-imports` layering gates), `l10n.yaml` (`synthetic-package: false`, `ar` template), `.gitignore` (`.dart_tool/`, `build/`), and an optional `melos.yaml` task runner (engineering 02 §1, §1.1, §5, §6; engineering 03 §3, §7).
- The thin **`app/` shell** that only wires, gates, and declares: `main.dart` (`runApp(ProviderScope(child: HifzApp()))`, no logic), `app.dart` (`MaterialApp.router`, `localizationsDelegates`, `supportedLocales`, locale → `Directionality.rtl` by construction), an empty `composition/providers.dart` + `composition/router.dart` placeholder, a `bootstrap/first_run.dart` stub, `android/` + `ios/` platform glue with **no microphone usage description** in `Info.plist`, and bundled UI-font declarations only — building to a placeholder screen on an Android emulator and iOS simulator (engineering 02 §2; PRD R5).
- The **nine local package stubs** under `packages/` (plus `app/`) with manifests encoding the locked dependency matrix from engineering 02 §3.1: pure-Dart `engine` (→ `models`, `meta` only — no Flutter, no `dart:io`), pure-Dart `models` (`meta` only), pure-Dart `profiles`; Flutter `data` (→ `engine`, `profiles`; `drift`, `sqlite3`, `path`), `quran` (`flutter`; no local dep), `l10n` (`flutter`, `intl`), `features` umbrella (→ `engine`, `data`, `quran`, `l10n`, `profiles`; `flutter_riverpod`, `go_router`); and the network-quarantine `assets` package (`http`, `crypto` — **the only networking deps in the repo**). Each stub: `lib/<package>.dart` barrel over `lib/src/`, `resolution: workspace`, `sdk: ^3.6.0`, one passing placeholder test so every CI lane is green from commit one (engineering 02 §3.1–§3.3; eng-create-package).
- `tool/` **gate scripts**, each runnable locally with no arguments and exiting non-zero on violation, run verbatim by CI: `check_no_network.sh`, `check_engine_purity.sh`, `check_quran_isolation.sh`, `check_dep_allowlist.sh`, `check_l10n_complete.sh`, and the `verify_asset_hashes.dart` harness (manifest schema + real hashes arrive with E05 — see out of scope) (engineering 02 §1, §5, §7; eng-add-ci-check).
- The **test scaffolding**: a placeholder `dart test` case in each pure package and a `flutter_test` case in each Flutter package, a shared throwing-`HttpOverrides` offline bootstrap, the `@Tags(['golden'])` golden harness wiring (no masters yet), and an `integration_test/` skeleton with one trivially-green launch journey (engineering 11 §1, §2, §7, §8; eng-write-dart-test).
- `.github/workflows/ci.yml` — the **fast / golden / restraint / journeys** jobs — and `release.yml` skeleton, both pinning `subosito/flutter-action@v2` to an exact `flutter-version`, `channel: stable`, first-party actions only (engineering 11 §8; engineering 13 §4; eng-add-ci-check).
- The **trust-pack subset** in the first commit: `LICENSE` (GPL-3.0-or-later + the verbatim §7 App Store additional permission), `LICENSING.md`, `CONTRIBUTING.md` (DCO 1.1 `git commit --signoff`, ≤~400 LOC / one-concern PR rule, the `.github/PULL_REQUEST_TEMPLATE.md` checklist), `LICENSES/GPL-3.0-or-later.txt`, `.reuse/dep5`, and a `README.md` stub with the one-sentence promise; REUSE SPDX headers on every file (engineering 13 §1, §2, §3).

### Out of scope

- **Full OSS trust pack** — `SECURITY.md`, `PRIVACY.md`, `docs/verify-yourself.md`, issue templates, `PrivacyInfo.xcprivacy` finalization, `fastlane/metadata/`, reproducible-build + SLSA attestation, the store privacy declarations → **E20** (engineering 13 §2, §4, §6, §8).
- **Package implementations** — `CalendarDate`/HifzDate date math → **E02**; models, Drift schema, DAOs, repositories, migrations → **E03**; the FSRS curve, trust clamp, tracks, the frozen golden vectors and `glados` invariants → **E04**; QPC glyph rendering, layout geometry, overlay painter, the muṣḥaf goldens and asset manifest → **E05**; the asset-pack downloader / SHA-256 verifier / pinned-manifest internals → **E05** (engineering 09); the Mihrab design-system tokens/components → **E06**, **E10**.
- **The `verify_asset_hashes.dart` manifest content + the muṣḥaf golden masters** — the pinned per-file SHA-256 manifest, the authoritative Tanzil hash, and the 604 reference page images are produced by **E05**; E01 ships only the script harness and the tagged golden CI job, dormant until the assets land (engineering 11 §5, §9).
- **The `check_engine_purity.sh` and `glados` invariant *rules*** — the import-ban *script* harness ships here, but the engine math it guards and the INV-1…INV-6 properties are authored by **E04** (engineering 11 §3, §4).
- **Translated product strings** — the `l10n` package, `l10n.yaml`, `app_ar.arb` template, and the `fa`/`ckb` ARB files are scaffolded here with placeholder keys and the zero-missing-keys gate wiring; transcreated string content lands with each feature epic under **E09**'s rules (engineering 02 §6).
- **The optional reciter-audio and alt-muṣḥaf packs** — the `assets` package supports them by design but no pack is defined here → **E05** / post-v1 ([PRD §11.1](../../docs/PRD.md)).
- **At-rest DB encryption, backup format, notifications** — the `data` stub compiles but wires no encryption (→ **E03**); backup → **E17**; reminders → **E18**.

## Dependencies

### Depends on

- — (this is the root epic; nothing precedes it).

### Enables

- **E02, E03**, (transitively) **E04** — the pure `models`/`engine` package stubs, the `data` Flutter stub, the fast `dart test` lane, and the no-network / engine-purity / golden-vector harnesses their date, schema, and scheduling guarantees plug into.
- **E05** — the `quran` and `assets` package stubs, the pinned-OS golden CI job, and the `verify_asset_hashes.dart` harness the immutable-rendering and asset-integrity work fills in.
- **E06**, (transitively) **E10** — the design-system home and emulator/golden lanes the Mihrab tokens and components build inside.
- (transitively) **E07** — the thin `app/` shell, the `features` umbrella, the `ProviderScope` composition root, and the router the walking skeleton fleshes out.
- **E08, E09** — the CI jobs their accessibility-audit and localization-completeness (`check_l10n_complete.sh`, RTL goldens) gates extend; the `ar`/`fa`/`ckb` ARB scaffolding.
- (transitively) **E17, E18, E19, E20** — the `assets`/`data` stubs, the trust-pack files, and the public CI evidence trail backup, reminders, the science screen, and release readiness complete; every epic in between merges through the gates E01 erects.

## Foundation inputs

| Input | Where (doc / skill) | What this epic takes from it |
|---|---|---|
| Layer model & no-network guarantee | docs/engineering/01-architecture-overview.md | §1 hard-rule→mechanism table (each non-negotiable held by a structure, not review); §2 the five-layer model and the Layer 1↔2 pure-core/shell split; §3 the package map + the `engine/pubspec.yaml` purity manifest; §5 the pure-Dart engine boundary ("today" injected); §6 the four-pillar offline guarantee (quarantine, dep allow-list, banned-import lint, throwing `HttpOverrides`) |
| Package & workspace layout | docs/engineering/02-project-structure.md | §1 the canonical top-level tree incl. the `tool/` file list and committed root `pubspec.lock`; §1.1 pub workspaces (`workspace:` / `resolution: workspace`, `^3.6.0`, one lock, one analysis context); §2 the `app/` shell anatomy ("wires, gates, declares"; no mic in `Info.plist`); §3.1 the dependency matrix (the audit map every manifest encodes); §3.3 exemplar manifests; §5 the machine-checked boundary lints + grep gates; §6 l10n/fonts/`synthetic-package: false` |
| Coding standards & lint config | docs/engineering/03-coding-standards.md | §3 `dart format` page width 80; §5 immutability / total engine / sealed I/O errors / no `print`; §6 the `engine/` purity import rule; §7.1 the root `analysis_options.yaml`; §7.2 the path-scoped import bans (no-network, legacy-Riverpod, engine purity) at `severity: error`; §8 the PR workflow + checklist (`PULL_REQUEST_TEMPLATE.md`) |
| Testing strategy & CI | docs/engineering/11-testing-strategy.md | §1 the pyramid shape (broad pure-Dart base, thin device apex); §2 `package:test` for `engine`; §3/§4 the golden-vector + `glados` invariant harness (`dart test engine/`); §5/§6 the real-font muṣḥaf + RTL goldens; §7 the three-layer no-network gate + throwing `HttpOverrides`; §8 the fast/golden/restraint/journeys CI shape + pinned `flutter-version`; §9 the SHA-256 text-integrity gate; §10 published-not-gated coverage |
| OSS license & release | docs/engineering/13-oss-repo-and-release.md | §1 GPL-3.0-or-later + the verbatim §7 App Store additional-permission text (in commit one); §2 the REUSE trust pack (per-file SPDX, `LICENSES/`, `reuse lint`) + the E01 subset; §3 DCO 1.1 (no CLA); §4 the pinned-toolchain CI/release shape + the gate→job table; §5 the F-Droid dependency allow-list / no-anti-feature entry ticket |
| Skill: package scaffolding | .claude/skills/eng-create-package/SKILL.md | The manifest-as-audit-artifact contract for all nine stubs: `resolution: workspace`, `sdk: ^3.6.0`, one `lib/<package>.dart` barrel over `lib/src/`, the audit-minimal dependency set, `engine`-deps-are-`meta`-only purity, `http`/`crypto` confined to `assets`, no junk-drawer folders, the REUSE header |
| Skill: CI gates | .claude/skills/eng-add-ci-check/SKILL.md | The contract for every gate: map to one PRD §20 gate, pin `subosito/flutter-action`, the three-layer no-network gate, the SHA-256 re-hash, `dart test engine/` for vectors+invariants, `@Tags(['golden'])` on one pinned Linux runner, `reuse lint` + banned-SDK allow-list, published-never-gated coverage, no `continue-on-error` on a gate |
| Skill: coding standards | .claude/skills/eng-write-to-coding-standards/SKILL.md | Effective Dart casing, full-word/unit-bearing names, `CalendarDate` vs `DateTime` discipline, immutability + total engine, sealed I/O errors, no `print`, `///` on public APIs, the REUSE SPDX header — applied to every scaffold file |
| Skill: tests | .claude/skills/eng-write-dart-test/SKILL.md | The placeholder `dart test`/`flutter_test` cases in each stub, the shared throwing-`HttpOverrides` offline bootstrap, the `@Tags(['golden'])` golden harness wiring, and the single sanctioned `integration_test` launch skeleton so every CI lane is exercised from commit one |

## Deliverables

- [ ] Pub-workspace root: `pubspec.yaml` (`workspace:` members, no app code), committed root `pubspec.lock`, `analysis_options.yaml` (flutter_lints + `--fatal-infos` + `page_width: 80` + path-scoped import bans), `l10n.yaml` (`synthetic-package: false`, `ar` template), `.gitignore`.
- [ ] Thin `app/` shell building and launching to a placeholder screen on an Android emulator and iOS simulator; `MaterialApp.router`, RTL by construction, **no `NSMicrophoneUsageDescription`** in `Info.plist`; bundled UI fonts only (no `google_fonts`).
- [ ] Nine package stubs (`engine`, `models`, `profiles`, `data`, `quran`, `l10n`, `features`, `assets`, + `app/`), each compiling with one passing placeholder test; manifests byte-for-byte consistent with the engineering 02 §3.1 dependency matrix.
- [ ] `engine` and `models` manifests prove purity from one read: deps are `meta` (+ `models`) only — no `flutter`, no `dart:io`, no clock; `assets` is the only manifest declaring `http`/`crypto`.
- [ ] `tool/` gates active: `check_no_network.sh`, `check_engine_purity.sh`, `check_quran_isolation.sh`, `check_dep_allowlist.sh`, `check_l10n_complete.sh`; `verify_asset_hashes.dart` harness present and wired (dormant until E05).
- [ ] Shared throwing-`HttpOverrides` offline bootstrap installed in the test harness; `@Tags(['golden'])` golden lane and `integration_test/` launch skeleton present and green.
- [ ] `.github/workflows/ci.yml` with the fast / golden / restraint / journeys jobs green on a real PR; `release.yml` skeleton; `subosito/flutter-action@v2` pinned to an exact `flutter-version`; first-party actions only; coverage published, generated files stripped, no percentage gate.
- [ ] `LICENSE` (GPL-3.0-or-later + §7 App Store exception), `LICENSING.md`, `CONTRIBUTING.md` (DCO + PR rules), `LICENSES/`, `.reuse/dep5`, `README.md` stub, `.github/PULL_REQUEST_TEMPLATE.md` — all in the first commit; `reuse lint` green.
- [ ] `app_ar.arb` template + empty `app_fa.arb` / `app_ckb.arb`, generated `AppLocalizations` committed (`synthetic-package: false`); `check_l10n_complete.sh` passes on the placeholder key set.

## Definition of Done

- [ ] A fresh clone runs `dart pub get` (workspace resolves with one lock, no `dependency_overrides`, no clash), builds, tests, and passes every `tool/` gate locally with no arguments before any CI run — CI runs the same files, no CI-only logic.
- [ ] **Offline / no-network is a build invariant:** the dependency allow-list fails on any analytics/ads/backend/crash SDK or `google_fonts` in the resolved graph; `avoid-banned-imports` forbids `package:http`/`dart:io HttpClient`/`package:dio` everywhere but `assets/`; the test bootstrap installs a throwing `HttpOverrides`; the manifest audit shows `http`/`crypto` in exactly one package (`assets`).
- [ ] **No AI / no microphone by construction:** no ML/ASR/audio-recognition dependency anywhere; `ios/Runner/Info.plist` carries no `NSMicrophoneUsageDescription` and no microphone permission is requested on either platform ([PRD C2, R5](../../docs/PRD.md)).
- [ ] **Text-fidelity harness live:** `verify_asset_hashes.dart` runs in the `restraint` job and the `@Tags(['golden'])` real-font golden job exists, both dormant on the empty asset set, so E05's text-integrity (gate 1) and visual-diff (gate 2) gates have a home and fail closed once assets land — never auto-blessed in CI.
- [ ] **Engine purity holds:** `engine`/`models` import no Flutter, no `dart:io`, no `DateTime.now()`; `check_engine_purity.sh` and the analyzer ban confirm it; the `dart test engine/` lane runs the placeholder vector test, ready for E04's frozen vectors + `glados` INV-1…INV-6 (the trust-clamp / no-"safe-to-drop" covenant harness).
- [ ] **Each gate proven by a deliberate violation:** a `package:http` import in `engine`, a `DateTime.now()` in `engine`, an `import 'package:flutter/…'` in `engine`, a QPC-glyph reference outside `quran`, and an undeclared/banned external dependency each fail their script (non-zero exit) and fail the matching CI job; revert leaves all green.
- [ ] **Manifest audit holds:** `engine` → `models` + `meta` only; dependencies point downward (`features → engine/data/quran/l10n/profiles`); no leaf package imports `features`; `quran` has no local package dep; only `assets` declares `http`/`crypto`.
- [ ] **RTL + fa/ckb/ar localization scaffolded:** `MaterialApp` sets `Directionality.rtl` by construction from the locale; `app_ar.arb` is the template with `fa`/`ckb` present; `AppLocalizations` is generated into source and committed; the placeholder screen resolves its one string via `l10n.*`, not a hardcoded literal (full transcreation: E09).
- [ ] **Accessibility & sect-neutral adab triage recorded:** no muṣḥaf, no engine output, no user-facing claim, no notification, no gamification surface, and no streak/score ships in this epic, so the text-fidelity, certainty-label, no-"safe-to-drop", and adab duties attach at E05/E04/E19 respectively — but the structures that make them enforceable (pure-engine manifest, `quran` isolation, no-network ban, the strings-from-`l10n`-only rule) are live here.
- [ ] **License & provenance:** the first commit's `LICENSE` contains the §7 App Store additional permission verbatim (engineering 13 §1); every commit carries a DCO `Signed-off-by:` line; every file carries a REUSE SPDX header and `reuse lint` is green; one root `pubspec.lock` is committed and no per-package lock exists.
- [ ] All four CI jobs green on the epic's final PR; public logs show the gate results, so the auditable-by-strangers trust story (engineering 13 §8) is live from the first merge.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E01-T01 | [Repo bootstrap: GPL-3.0 + §7 App Store exception, DCO, REUSE trust-pack subset, PR template](E01-T01-repo-bootstrap-license-dco.md) | S | — |
| E01-T02 | [Pub-workspace root + analysis_options + l10n.yaml; thin app/ shell building to a placeholder screen](E01-T02-workspace-root-app-shell.md) | M | E01-T01 |
| E01-T03 | [Pure-Dart package stubs: engine (meta + models only), models, profiles](E01-T03-pure-package-stubs.md) | M | E01-T02 |
| E01-T04 | [Flutter package stubs: data, quran, l10n, features + the assets network-quarantine package](E01-T04-flutter-package-stubs.md) | M | E01-T02 |
| E01-T05 | [tool/ gates: no-network, engine purity, quran isolation, dependency allow-list, l10n completeness + dormant asset-hash harness](E01-T05-tool-gate-scripts.md) | M | E01-T03, E01-T04 |
| E01-T06 | [Test scaffolding: per-package placeholder tests, throwing HttpOverrides bootstrap, golden + integration_test skeletons](E01-T06-test-scaffolding-offline-bootstrap.md) | M | E01-T03, E01-T04 |
| E01-T07 | [CI pipeline: fast / golden / restraint / journeys jobs + release skeleton, pinned flutter-action, reuse lint, coverage](E01-T07-ci-pipeline-four-jobs.md) | M | E01-T05, E01-T06 |
| E01-T08 | [Deliberate-violation gate proofs + fresh-clone DoD sweep, all jobs green on final PR](E01-T08-gate-violation-proof-dod-sweep.md) | S | E01-T07 |

## Risks

- **Gates that pass because they check nothing.** A grep with a bad path glob, or an asset-hash harness pointed at an empty manifest, exits zero forever and everyone trusts a hollow guarantee. *Mitigation:* the deliberate-violation proof in the Definition of Done (E01-T08) exercises each ban with a real violation and a revert; kept as a documented manual procedure for every future gate change per eng-add-ci-check.
- **The asset-hash and golden gates ship dormant and are forgotten.** Because the muṣḥaf manifest and the 604 reference images arrive in E05, the integrity (gate 1) and visual-diff (gate 2) gates have no data to check at E01 and could be left as no-ops. *Mitigation:* the harness and the tagged golden job are wired and run on the empty set now (a present-but-empty manifest is an explicit, reviewed state), and E05's scope is the first consumer that supplies real hashes/images, fail-closed; the gate→job table records the hand-off.
- **Floating toolchain drift.** An unpinned `subosito/flutter-action` silently re-renders goldens and breaks the rebuild-the-bytes reproducibility claim weeks later. *Mitigation:* an exact `flutter-version` (README baseline) and `channel: stable` on every job, Linux-only for the golden job, deliberate-update-only policy; the pin is a release-blocking precondition, not a convenience (engineering 11 §8; engineering 13 §4).
- **Scope creep into the stubs.** "While I'm here" implementation code in `engine`, `data`, or `quran` would land without E03/E04/E05's golden/property/integrity rigor. *Mitigation:* stubs are empty-but-compiling by definition; the ≤~400 LOC / one-concern PR rule; the review checklist rejects any non-scaffold logic in this epic (engineering 03 §8).
- **Pub-workspace resolution clash hidden by `dependency_overrides`.** Reaching for `dependency_overrides` to paper over a version conflict would hide a layer violation and break the one-lock audit. *Mitigation:* no `dependency_overrides` anywhere; a clash is fixed at `dart pub get` time, which is the point of the workspace; the dependency allow-list and the single committed root lock are the audit evidence (engineering 02 §1.1, §5).
- **License/DCO gap at the worst moment.** An outside PR merged before the §7 permission text or without sign-off recreates the VLC/GNU-Go takedown trigger. *Mitigation:* `LICENSE` complete with the §7 exception in commit one (hard rule, engineering 13 §1), per-file REUSE headers and `reuse lint` from the first PR, DCO required in `CONTRIBUTING.md` and checked on every commit (engineering 13 §2, §3).
- **Engine purity eroded by a transitive dependency.** A dependency added to a pure package that transitively pulls `flutter` or `dart:io` would silently re-couple the deterministic core. *Mitigation:* `engine`/`models` declare `meta` (+ `models`) only; `check_engine_purity.sh` greps for `package:flutter`/`dart:io`/`DateTime.now()` and the analyzer ban runs on every PR; any new external dependency is a decision-log event on the allow-list, never a quiet add (engineering 01 §5; engineering 02 §5; eng-create-package).

## References

- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/PRD.md — C1, C2, C5, C6, R1, R5, §11.1, §17, §19, §20
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/engineering/01-architecture-overview.md — §1, §2, §3 (incl. §3.1, §3.3), §5, §6
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/engineering/02-project-structure.md — §1, §1.1, §2, §3.1, §3.2, §3.3, §4, §5, §6, §7
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/engineering/03-coding-standards.md — §3, §5, §6, §7.1, §7.2, §8 (incl. §8.1)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/engineering/11-testing-strategy.md — §1, §2, §3, §4, §5, §6, §7, §8, §9, §10
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/engineering/13-oss-repo-and-release.md — §1, §2, §3, §4, §5, §8
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-create-package/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-add-ci-check/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-write-to-coding-standards/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-write-dart-test/SKILL.md

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
