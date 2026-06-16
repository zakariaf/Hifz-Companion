# references — eng-add-ci-check

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary — Testing strategy & CI (`docs/engineering/11-testing-strategy.md`)

- §8 (CI shape: fast feedback, a pinned golden job, the gates) — **The job layout and the contract-making table.** Four jobs: `fast` (`analyze` + engine unit/property + widget + coverage), a **pinned, Linux-only** `golden` job (`--tags golden`), a `restraint` job (dependency allow-list + banned-import + text-integrity hashing), and an emulator `journeys` job; runner is `subosito/flutter-action@v2` with a **pinned `flutter-version`**. The take: every gate maps to a job in the **PRD §20 gate→job table** (gate 1 integrity → `restraint`+runtime; gate 2 goldens → `golden`+`journeys`; gate 3 vectors → `fast`; gate 4 invariants → `fast`; gate 5 RTL → `golden`+`fast`; gate 6 network → `restraint`+`fast`; gate 7 mutashābihāt → `restraint`+sign-off; gate 8 manual review → human) — and a red gate blocks the release, full stop.

- §7 (The no-network gate: offline is a build invariant) — **Offline is three layers, not a grep.** (a) every test keeps the binding's default 400-block and installs a throwing `HttpOverrides`; (b) a CI dependency allow-list fails on any analytics/ads/backend/crash SDK in the resolved graph (`firebase_|google_analytics|sentry|crashlytics|facebook_|appsflyer|amplitude|mixpanel`); (c) an analyzer banned-import rule forbids `dart:io`/`package:http`/`package:dio` everywhere but the one `assets/` downloader. Plus the airplane-mode acceptance run. This is PRD gate 6.

- §9 (The text-integrity gate: the muṣḥaf cannot drift, even in CI) — **Re-hash everything against the binary manifest AND the Tanzil hash.** `tool/verify_asset_hashes.dart` SHA-256s every asset-pack file (text + 604 KFGQPC fonts + layout + mutashābihāt) and fails on any mismatch vs the manifest baked into the binary and the authoritative Tanzil text hash. Trust root is the in-binary manifest, never a sidecar `.sha256`; primitive is SHA-256 (FIPS 180-4), never MD5/SHA-1; CI proving the release is intact does not excuse the runtime verifier. This is PRD gate 1.

- §3 (Engine golden vectors) — **The fast job verifies frozen vectors; it never blesses them.** The `(state, grade, elapsed) → (D, S, due)` table is asserted with `closeTo(_, 1e-6)` and regenerated **only** by a local, human-reviewed `--update-vectors` run — CI only verifies, an auto-bless would make the gate assert nothing (the same failure mode as `--update-goldens` in CI). This is PRD gate 3.

- §4 (Invariants as property tests) — **The `glados` INV-1…INV-6 run in the fast job.** INV-1 trust clamp (`dueAt ≤ cycle ceiling`), INV-2 manzil never dropped, INV-3 lapse demotes, INV-4 determinism (fuzz OFF), INV-5 teacher overrides, INV-6 no "safe to drop". The gate is the covenant made mechanical; rely on shrinking, not a lucky fixed seed. This is PRD gate 4.

- §5 (Muṣḥaf-fidelity goldens: real glyphs, pinned everything) — **Why the golden job is pinned and isolated.** Real KFGQPC + UI fonts via `FontLoader` (never Ahem), one pinned OS + Flutter version, fixed DPR/size/theme, animations off; `@Tags(['golden'])` isolates them into the controlled job. Cross-OS/SDK golden drift is documented, so the runner is pinned and CI never `--update-goldens`. This is PRD gate 2.

- §6 (Widget, RTL, and integration tests) — **RTL goldens per locale and the four journeys.** Each key screen pumped under `Directionality.rtl` for `ar`/`fa`/`ckb` with locale numerals/calendars is gate 5's artifact (may use the font-independent strategy); the four `integration_test` journeys run on the emulator `journeys` job — do not grow them past four without a decision-log amendment.

- §10 (Coverage policy: auditable, honest, no vanity number) — **Publish coverage; never gate on a percentage.** `flutter test --coverage`, strip `*.g.dart`/`*.drift.dart`/`*.freezed.dart`/`*/generated/*` from `lcov.info`, publish for OSS auditability; **no global threshold** — invariants and vectors are the real bar, a percentage rewards asserting-nothing tests.

- §1 (The test pyramid) — **The gate→tier mapping at a glance.** The `Gate — no-network` and `Gate — text-integrity` rows in the tier table show these are CI-script gates, distinct from the unit/property/golden/widget/integration tiers a job runs.

## Supporting — OSS repo & release (`docs/engineering/13-oss-repo-and-release.md`)

- §4 (CI/CD: reproducible, signed, provenance-attested builds) — **The release gate suite and the pinned toolchain.** The release job (`on: push: tags: ['v*.*.*']`) runs the full gate suite — `reuse lint`, dependency/import/network-restraint gates, pinned-OS goldens, engine property tests, asset-manifest check — and refuses to publish if any fail. The **Gate table** (License clarity / DCO / Network restraint / Determinism / Muṣḥaf fidelity / Asset integrity / Privacy) names each gate's tool and where it's specified. A pinned `flutter-version` is the precondition for both stable goldens and the reproducible-build claim; the signing key lives only in secrets; never fetch Quran assets at app-build time.

- §2 (Repository trust pack and machine-readable license clarity) — **`reuse lint` is a release-blocking step.** `fsfe/reuse-action@v6` runs `reuse lint`; a missing/malformed per-file SPDX header (`GPL-3.0-or-later` + `SPDX-FileCopyrightText`) fails the job — the same fail-loud discipline as the network/golden gates. The repo *is* the audit; the trust pack turns the offline promise into a checkable claim.

- §5 (F-Droid as the primary channel and the entry-ticket constraints) — **The dependency allow-list is the F-Droid entry ticket.** The whole tree + toolchain must stay 100% FLOSS with no proprietary tracking/ads/analytics SDK; the banned-SDK list (Play Services/Firebase/Crashlytics) is verbatim the dependency-allow-list gate, and earning no **NonFreeNet**/**NonFreeAssets**/**Tracking** anti-feature is what the offline + asset-license checks protect.

- §8 (Auditability: "verify us yourself") — **The CI gates are what make the verify-yourself claims checkable.** The reproducible build + SLSA attestation, the single CI-enforced networking module, the airplane-mode walkthrough, and the re-derivable asset hashes each correspond to a gate this skill wires; an unverifiable claim is removed, not shipped.

## Supporting — Architecture overview (`docs/engineering/01-architecture-overview.md`)

- §6 (The offline guarantee, made auditable — four pillars) — **Why a grep is unsound and the gate needs all four pillars.** `HttpClient` ships inside `dart:io`, so an import-grep alone misses the most likely accidental/malicious network path: the network is quarantined to `assets/`, a dependency allow-list fails on any tracking/ads/backend/crash SDK, a per-path `avoid-banned-imports` lint bans networking everywhere else, and tests throw on any stray call (with a user-verifiable airplane-mode runtime). This is the architectural spec behind §7.

- §1 (Hard rules → structural mechanisms) — **The two outranking rules a gate must never weaken.** "Fully offline; no per-user data leaves the device" is held by the two-layer CI gate + the throwing `HttpOverrides`; "the engine may only make a page *more* frequent, never less" is held by the trust clamp as the single `due_at` sink, golden- and property-tested. A gate exists to hold one of these structurally, not by review discipline.

- §5 (The pure-Dart engine core: an architectural *and* a testing boundary) — **Why the engine gate runs `dart test`, not `flutter test`.** The engine imports no Flutter and reads no wall clock ("today" injected), so its vectors/properties run on the fastest, most stable tier with no widget binding; interval fuzzing is OFF so determinism (INV-4) is gateable.

## Sibling skills

- **eng-write-engine-golden-vector** — writes the frozen `FsrsVector` rows and the `glados` INV-1…INV-6 properties the engine gate runs; this skill wires `dart test engine/` into the fast job.
- **eng-write-dart-test** — writes every other test a gate runs (muṣḥaf/RTL goldens, the throwing-`HttpOverrides` bootstrap, the four journeys); this skill schedules the job.
- **domain-asset-pack-integrity** — owns the SHA-256 manifest, the pinned-tag scheme, and the runtime fail-closed verifier the text-integrity gate re-hashes against.
- **domain-mushaf-text-integrity** — defines what a correct fidelity-golden pixel is; this skill only pins the runner so the pixels stay stable.
- **eng-write-to-coding-standards** — owns the `avoid-banned-imports` rule definition and the REUSE SPDX headers the gates run/require.
- **eng-create-package** — the engine `pubspec` whose missing `flutter`/`http`/`dart:io` makes a networking or purity import a compile error, not just a lint.
