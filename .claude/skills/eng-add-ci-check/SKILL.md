---
name: eng-add-ci-check
description: Create or change a CI gate for the Hifz Companion app — a GitHub Actions job or gate script that makes one of the eight release-blocking gates (PRD §20) a build either passes or fails: the no-network / banned-import gate, the SHA-256 text & asset-integrity hash, the engine golden-vector + invariant property run, the pinned-OS muṣḥaf/RTL goldens, `reuse lint`, the dependency allow-list, or coverage publication. Use whenever adding or editing a `.github/workflows/*.yml` job, a `tool/*.dart`/`*.sh` gate script, a grep/no-network ban, a golden-render check, an asset-hash check, or a coverage step.
---

# eng-add-ci-check

A CI gate in this repo is not a "nice to have green check" — it is the mechanism that converts a release-blocking gate (PRD §20) and a hard rule that "outranks everything" into a check a build either passes or fails, *without trusting a human*. The two outranking covenants decide which gates may never be advisory: **the sacred text is never put at risk** (the text & asset-integrity hash, the pinned-OS real-font muṣḥaf goldens) and **the engine may only make a page more frequent, never less** (the engine golden vectors + the trust-clamp invariant property). On top of those sit the structural guarantees of a *ṣadaqah*, fully-offline, no-AI app: the no-network / banned-import gate, the analytics/ads/backend dependency allow-list, `reuse lint`, and published-but-never-gating coverage. Every gate below traces to `docs/engineering/11-testing-strategy.md`, `docs/engineering/13-oss-repo-and-release.md`, or `docs/engineering/01-architecture-overview.md`.

This skill adds or changes the *job that runs a check*, the *script the job runs*, and the *PRD-gate→job mapping* — pinning the toolchain so goldens and reproducibility stay deterministic, scoping the job to the right runner (fast / golden / restraint / journeys), and keeping a red gate release-blocking. Come here to wire a gate; go to the domain/test skills for the *contract* the gate asserts and the *test* it runs.

## When to use

Use this skill when you:

- add or edit a **no-network / banned-import gate** — the dependency allow-list over the resolved graph, the `avoid-banned-imports` analyzer scope, or the throwing-`HttpOverrides` airplane-mode acceptance run (`docs/engineering/11-testing-strategy.md` §7; `docs/engineering/01-architecture-overview.md` §6);
- add or edit the **text & asset-integrity gate** — CI re-hashing every asset-pack file (Uthmani text, 604 KFGQPC page fonts, layout dataset, mutashābihāt dataset) with SHA-256 against the pinned manifest **and** the authoritative Tanzil hash (`docs/engineering/11-testing-strategy.md` §9);
- wire the **engine golden-vector + invariant property** run (`dart test engine/` — frozen FSRS vectors + the `glados` INV-1…INV-6 properties) into the fast job (`docs/engineering/11-testing-strategy.md` §3, §4, §8);
- wire the **pinned-OS, Linux-only golden job** — real-font muṣḥaf-fidelity goldens (`@Tags(['golden'])`) and the RTL `ar`/`fa`/`ckb` layout goldens — onto a pinned `flutter-version` (`docs/engineering/11-testing-strategy.md` §5, §6, §8);
- add the **`reuse lint`** license-clarity gate or the **dependency allow-list** that rejects analytics/ads/backend/crash SDKs (`docs/engineering/13-oss-repo-and-release.md` §2, §4, §5);
- add or change the **coverage** step — `flutter test --coverage`, strip generated files, publish for OSS auditability, **no percentage gate** (`docs/engineering/11-testing-strategy.md` §10);
- change the **CI shape** itself — the fast / golden / restraint / journeys jobs, the pinned `subosito/flutter-action` version, or the release-job gate suite (`docs/engineering/11-testing-strategy.md` §8; `docs/engineering/13-oss-repo-and-release.md` §4).

Do **NOT** use this skill for:

- authoring the **engine vectors/invariant properties** a gate runs → use **eng-write-engine-golden-vector** (you write the frozen `FsrsVector` rows and the `glados` properties there; you wire `dart test engine/` into a job here).
- authoring any **other test** a gate runs — widget tests, `matchesGoldenFile` muṣḥaf/RTL goldens, the throwing-`HttpOverrides` bootstrap, an `integration_test` journey → use **eng-write-dart-test** (it writes the check; this skill schedules the job that runs it).
- the **SHA-256 manifest format, the pinned-tag scheme, or the runtime fail-closed verifier** the hash gate re-hashes against → use **domain-asset-pack-integrity** (this skill *re-runs* the hash in CI; the integrity contract and the device-side verifier live there).
- the **glyph-rendering / text-fidelity rules** a fidelity golden compares against → use **domain-mushaf-text-integrity** (this skill pins the runner so the pixels are stable; that skill defines what correct pixels are).
- the **banned-import lint *rule definition*** in `analysis_options.yaml` and the engine-purity import boundary → use **eng-write-to-coding-standards** and **eng-create-package** (this skill runs `flutter analyze` as a gate; those own the rule and the package manifest that make the import a compile error).
- the **scheduling rule** a vector pins, or the **adab/claims** a copy check would guard → use **domain-scheduling-engine-rules** / **domain-claims-register-and-science-screen**.

## The canonical pattern

### 1. A gate exists to make a PRD §20 release-blocker machine-checked — name the gate it serves
Every CI check maps to exactly one of the eight release-blocking gates and is added to the PRD-gate→job table, so the release contract stays auditable (`docs/engineering/11-testing-strategy.md` §8, mapping table). Gates 1–6 are machine-checked and **required**; gates 7–8 carry a recorded human sign-off artifact (mutashābihāt scholar sign-off; manual on-device muṣḥaf review). A new check that does not serve a named gate either is not a gate (make it advisory and say so) or needs a decision-log amendment — do not invent a release-blocker with no doc behind it (`docs/engineering/13-oss-repo-and-release.md` §4).

### 2. Pin the toolchain — a floating SDK is forbidden on any gate
Use `subosito/flutter-action@v2` with an **explicit `flutter-version`** matching the README baseline (e.g. `3.38.0`) and `channel: stable` on every job (`docs/engineering/11-testing-strategy.md` §8). Pinning is a precondition for two things at once: stable muṣḥaf goldens (a glyph must move only on a *real* change, never an SDK bump) and the reproducible-build / rebuild-the-bytes claim (`docs/engineering/13-oss-repo-and-release.md` §4). A floating `flutter-action` silently re-renders goldens and breaks reproducibility — refuse it.

### 3. The no-network gate is three layers, not one grep
"Fully offline" is enforced as **(a)** a throwing `HttpOverrides` in the test bootstrap so a stray call is a loud named failure (not a silent 400), **(b)** a CI **dependency allow-list** that fails if any analytics/ads/backend/crash SDK appears in the resolved graph, and **(c)** an analyzer **banned-import** rule (`flutter analyze`) forbidding networking imports everywhere but the one whitelisted `assets/` downloader (`docs/engineering/11-testing-strategy.md` §7; `docs/engineering/01-architecture-overview.md` §6). A grep alone is *unsound* — `HttpClient` ships inside `dart:io`, which non-UI code may legitimately import — so all three layers are required, and the **airplane-mode acceptance** run proves every post-onboarding screen works with zero network (`docs/engineering/01-architecture-overview.md` §6, pillar 4). This is PRD gate 6.

### 4. The text & asset-integrity gate re-hashes everything against the pinned manifest *and* the upstream Tanzil hash
A `tool/verify_asset_hashes.dart` step in the `restraint` job re-computes SHA-256 for every asset-pack file — the Uthmani text, all **604** KFGQPC page fonts, the layout/segmentation dataset, the mutashābihāt dataset — and fails the build on any mismatch against (a) the manifest **baked into the app binary** (never a sidecar `.sha256` an attacker could also swap) and (b) the **authoritative Tanzil text hash**, so the manifest itself cannot silently drift (`docs/engineering/11-testing-strategy.md` §9). The primitive is SHA-256 (FIPS 180-4) — never MD5/SHA-1. This is the build-time half of R1; it does **not** excuse the runtime fail-closed verifier (`domain-asset-pack-integrity`). This is PRD gate 1.

### 5. The engine gates run on the cheapest tier — `dart test engine/`, fuzz OFF
The frozen golden vectors (gate 3) and the `glados` invariant properties (gate 4) run in the **fast** job as `dart test engine/` — pure `package:test`, no widget binding, `today` injected as a `SerialDay` literal (`docs/engineering/11-testing-strategy.md` §3, §4, §8). CI only ever **verifies** vectors; regeneration is a local, human-reviewed `--update-vectors` run — an auto-bless in CI would make the gate assert nothing (`docs/engineering/11-testing-strategy.md` §3 pitfalls). The trust-clamp property (INV-1, `dueAt − today ≤ cycleCeilingDays`) and INV-6 (no "safe to drop") are the engine half of the outranking covenant; a `max`-where-`min`-belongs fails the gate before it changes a ḥāfiẓ's schedule.

### 6. Goldens get their own pinned, Linux-only job — never blessed in CI
Muṣḥaf-fidelity goldens (real KFGQPC fonts via `FontLoader`, never Ahem) and the RTL `ar`/`fa`/`ckb` layout goldens are isolated by `@Tags(['golden'])` into a dedicated job running `flutter test --tags golden` on one pinned Linux runner and one pinned `flutter-version` (`docs/engineering/11-testing-strategy.md` §5, §6, §8). Cross-OS golden drift is documented and real — never run muṣḥaf goldens on macOS/Windows in CI; the cross-device fidelity proof is the on-device visual-diff (gate 2/gate 8), not the shared masters. CI never runs `--update-goldens` (that would make the gate assert nothing). This is PRD gates 2 and 5.

### 7. License & dependency hygiene: `reuse lint` + the banned-SDK allow-list
The `restraint`/release path runs **`reuse lint`** (via `fsfe/reuse-action`) so a missing or malformed per-file SPDX header (`GPL-3.0-or-later`) fails the build — the same fail-loud discipline as the integrity and network gates (`docs/engineering/13-oss-repo-and-release.md` §2). The **dependency allow-list** walks `flutter pub deps`/`pubspec.lock` and fails on any `firebase_|crashlytics|sentry|google_analytics|facebook_|appsflyer|amplitude|mixpanel`-class package — the F-Droid entry ticket, verbatim, and PRD gate 6 (`docs/engineering/13-oss-repo-and-release.md` §4, §5; `docs/engineering/11-testing-strategy.md` §7). These keep the app FLOSS-everything and earn no NonFreeNet/NonFreeAssets/Tracking anti-feature.

### 8. Coverage is published, never a gate
The fast job runs `flutter test --coverage --exclude-tags golden`, strips generated files (`*.g.dart`, `*.drift.dart`, `*.freezed.dart`, `*/generated/*`) from `lcov.info`, and publishes the report for OSS auditability — but sets **no global percentage threshold** (`docs/engineering/11-testing-strategy.md` §10). A covered line that asserts nothing is worthless; the engine's invariants and frozen vectors are the real bar. Do not add a coverage-percentage gate — it rewards asserting-nothing tests and is explicitly refused.

### 9. A red gate blocks the release — gates are not advisory
Gates 1–6 are required machine-checks; the release job (`release.yml`, `on: push: tags: ['v*.*.*']`) re-runs the full suite and **refuses to publish** if any fail (`docs/engineering/13-oss-repo-and-release.md` §4; `docs/engineering/11-testing-strategy.md` §8 pitfalls). Never `continue-on-error: true` on a gate, never merge on a skipped gate, never let CI fetch the Quran assets at app-build time (the binary ships lean with only the pinned tag + manifest hashes). The signing key lives only in encrypted CI secrets, never in the repo.

### 10. The gate is itself code held to the standards, and stays adab-safe
A gate script (`tool/*.dart`/`*.sh`) obeys the coding standards: REUSE SPDX header, full-word names, typed errors, `dart format` clean, no `print` of user data (`docs/engineering/13-oss-repo-and-release.md` §2). A CI check never transmits anything off the runner about a user (there is none — CI runs on source/assets only), never weakens a covenant to make a build green, and the integrity/golden gates exist precisely to protect the muṣḥaf's text fidelity and sect-neutrality. The text-integrity job must stay locale- and madhhab-blind: it hashes bytes, it does not interpret them.

## Do / Don't

| Do | Don't |
|---|---|
| Map every new check to one PRD §20 gate and add it to the gate→job table | Add a green check that serves no named gate, or invent a release-blocker with no doc behind it |
| Pin `subosito/flutter-action@v2` to an explicit `flutter-version` on every job | Float the SDK / use `channel: stable` alone (re-renders goldens, breaks reproducibility) |
| Enforce offline with all three layers: throwing `HttpOverrides` + dep allow-list + banned-import lint | Rely on a single grep or the default 400 alone (a `dart:io` import has no obvious networking symbol) |
| Re-hash every asset (text + 604 fonts + layout + mutashābihāt) vs the **binary** manifest **and** the Tanzil hash | Trust a sidecar `.sha256`, hash a subset, or use MD5/SHA-1 |
| Run engine vectors + `glados` invariants as `dart test engine/` in the fast job | Drive the engine through a widget/golden job, or auto-bless vectors in CI |
| Isolate goldens with `@Tags(['golden'])` on one pinned Linux runner | Run muṣḥaf goldens on macOS/Windows, or run `--update-goldens` in CI |
| Run `reuse lint` + the banned-SDK allow-list; fail loud on a violation | Allow a missing SPDX header, or let a Firebase/Crashlytics/analytics SDK into the graph |
| Publish coverage with generated files stripped, transparency only | Add a coverage-percentage gate, or count `*.g.dart`/`*.drift.dart` |
| Keep gates 1–6 required and release-blocking; record sign-off for gates 7–8 | `continue-on-error: true` a gate, or merge/publish on a red or skipped gate |
| Keep signing keys in encrypted secrets; ship the binary lean (pinned tag + hashes) | Store a key in the repo, or fetch Quran assets at app-build time |
| Give the gate script a REUSE SPDX header, typed errors, no `print` of user data | Let the integrity job interpret bytes by locale/madhhab, or weaken a covenant to go green |

## Checklist

Before a CI gate is done:

- [ ] The check maps to exactly one PRD §20 gate (1–8) and is reflected in the gate→job mapping table; gates 1–6 are required machine-checks, 7–8 carry a recorded human sign-off.
- [ ] Every job pins `subosito/flutter-action@v2` to an explicit `flutter-version` (README baseline) with `channel: stable` — no floating SDK on any job, especially the golden job.
- [ ] The no-network gate is all three layers: the throwing `HttpOverrides` bootstrap, the dependency allow-list over the resolved graph, and the `flutter analyze` banned-import scope (`assets/` is the only socket); the airplane-mode acceptance run is included.
- [ ] The integrity gate re-hashes the Uthmani text, all 604 KFGQPC fonts, the layout dataset, and the mutashābihāt dataset with SHA-256 against the **binary-baked** manifest **and** the authoritative Tanzil hash; mismatch fails the build; no sidecar checksum, no MD5/SHA-1.
- [ ] Engine golden vectors and the `glados` INV-1…INV-6 properties run as `dart test engine/` in the fast job; CI only verifies (no `--update-vectors`); fuzzing stays OFF.
- [ ] Muṣḥaf-fidelity goldens (real `FontLoader`, never Ahem) and RTL `ar`/`fa`/`ckb` layout goldens are `@Tags(['golden'])`, run on one pinned Linux runner, and are never blessed (`--update-goldens`) in CI.
- [ ] `reuse lint` and the banned analytics/ads/backend/crash-SDK allow-list both run and fail loud; the resolved graph stays FLOSS-everything (no F-Droid anti-feature earned).
- [ ] Coverage is generated with `flutter test --coverage`, generated files stripped from `lcov.info`, published for auditability — and **no percentage threshold gate** is introduced.
- [ ] No gate is `continue-on-error`; the release job (`on: tags: v*.*.*`) re-runs the full suite and blocks publish on any red gate; signing keys are in secrets only; the binary ships lean (pinned tag + hashes), assets are not fetched at app-build time.
- [ ] Any gate script carries the REUSE SPDX header (`GPL-3.0-or-later`), uses typed errors, is `dart format` clean, prints no user data, and stays locale/madhhab-blind (the integrity job hashes bytes, it does not interpret them).

This skill schedules the *checks*, not the *contracts* they enforce. The text-fidelity, offline, no-AI, sect-neutrality, no-gamification, servant-to-teacher, and privacy non-negotiables are defined in the domain docs/skills below and merely *proven* here — the integrity hash proves the muṣḥaf bytes are untouched, the trust-clamp property proves the engine only adds frequency, the allow-list + throwing `HttpOverrides` prove the app stayed offline and collected nothing. A gate that would weaken any covenant (auto-blessing goldens, gating on a coverage number, letting a network call or telemetry SDK through, or marking a required gate advisory) is itself the bug.

## Files

- `template.yml` — copy-paste GitHub Actions scaffold: the pinned-toolchain `fast` / `golden` / `restraint` / `journeys` jobs and the tag-triggered `release` job, with the no-network allow-list, the SHA-256 asset-hash step, the `dart test engine/` vector+invariant run, the `@Tags(['golden'])` pinned-OS golden run, `reuse lint`, and the strip-and-publish coverage step. Fill every `# TODO:` and keep the gate→job mapping in sync.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **eng-write-engine-golden-vector** (writes the frozen vectors + `glados` invariants the engine gate runs), **eng-write-dart-test** (writes every other test a gate runs — goldens, the throwing-`HttpOverrides` bootstrap, the journeys), **domain-asset-pack-integrity** (owns the SHA-256 manifest + pinned tag + runtime fail-closed verifier the hash gate re-checks), **domain-mushaf-text-integrity** (defines what a correct fidelity-golden pixel is), **eng-write-to-coding-standards** (owns the banned-import rule definition and the REUSE SPDX headers the gates run/require), **eng-create-package** (the engine `pubspec` whose missing `flutter` makes the purity import a compile error).
