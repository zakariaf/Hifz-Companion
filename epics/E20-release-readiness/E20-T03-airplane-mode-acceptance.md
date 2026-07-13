# E20-T03 — Airplane-mode acceptance journey: every post-onboarding surface works with zero network and a throwing HttpOverrides

| | |
|---|---|
| **Epic** | [E20 — Release Readiness](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E20-T01 |
| **Skills** | eng-write-dart-test, domain-asset-pack-integrity, eng-add-ci-check |

## Goal

Prove the *integration half* of the offline covenant on a real device stack: after the ONE-time verified core install, every post-onboarding surface — **Today · Muṣḥaf · Mutashābihāt · Progress · Settings** — functions with a **throwing `HttpOverrides`** active and **zero** network, exactly the acceptance run 11 §7 names: "after a one-time mock-verified core-pack install, the integration suite runs with the throwing override installed, proving every post-onboarding screen works with zero network." This task authors **one** `integration_test` file (`app/integration_test/airplane_mode_acceptance_test.dart`) that joins the **existing** `journeys` job on the api-24 emulator; it does **not** author the no-network gate's three layers (the throwing bootstrap in `test_setup.dart`, `tool/check_dep_allowlist.sh`, `tool/check_no_network.sh` — all already exist and are E-owned), does not touch `ci.yml`/`release.yml` (→ E20-T01/T02), and writes **no** new screen, string, or claim — it drives the assembled app the feature epics built. Every stray connection attempt is a LOUD named failure plus a final explicit zero-socket assertion, never a silent 400.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/11-testing-strategy.md` §7 | The three-layer no-network gate this run *completes* (throwing override + dep allow-list + banned-import scope); the verbatim airplane-mode acceptance sentence; "only the asset-downloader test opts out" — this journey NEVER resets `HttpOverrides.global`; the refusal to rely on the silent 400 default |
| `docs/engineering/11-testing-strategy.md` §6 | The journey tier: `integration_test` on the real Drift/SQLite stack, `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`, the `BlockedClient`/injected-net pattern; the J1–J4 suite is closed — this run is §7's gate member, **not** a fifth journey, and must not duplicate J1–J4's flow-level assertions |
| `docs/engineering/11-testing-strategy.md` §8 | Gate 6 → `restraint` + `fast` (+ this run as its on-device dynamic half); the `journeys` job shape (`reactivecircus/android-emulator-runner@v2`, api-24); pinned `flutter-version` on every job; no merge on a skipped gate |
| `docs/PRD.md` §1 (C1, C2) | C1: offline after setup — the **core muṣḥaf is bundled in the binary**, fully usable offline from first launch; airplane mode forever after any optional fetch. C2: no AI/ML/audio — nothing this run drives may reach a mic or model |
| `docs/PRD.md` §17, §19.3 | Network is used **only** for static public asset packs; no per-user data ever sent; "after download, the app works in airplane mode permanently"; the only permitted network client is the assets downloader; the app refuses to render Quran text from unverified assets |
| `docs/PRD.md` §11.1.1, §21 ("Decided this round", 2026-06-18) | The bundled core is pinned by a **build-time** SHA-256 manifest (no core download, no offline-at-first-run failure mode); optional packs are runtime fail-closed — so the "one-time mock-verified core-pack install" of 11 §7 maps today to the offline verified-install step, and no download seam is exercised |
| `docs/PRD.md` §12, §20 gate 6 | The five bottom-nav surfaces in RTL order (rightmost = Today) this run must drive, and the gate this run serves: the only network client is the asset-pack downloader — here proven *dynamically*: it exists and is **not exercised** post-install |
| `docs/PRD.md` §12.1 | "Core muṣḥaf setup — the core is **bundled** in the binary, so this is a brief, offline build-verify step (no download), not a network gate" — why the journey's one-time install can and must complete under the throwing override |
| Repo: `tool/check_no_network.sh`, `tool/check_dep_allowlist.sh` | Layers (b) and (c) of the static gate — E-owned, already green in the `restraint` job; this run **complements** them dynamically and must never re-implement, edit, or weaken them |
| Skill `eng-write-dart-test` | Pattern 3 (injected `today`, never `DateTime.now()`), Pattern 6 (real bundled fonts, never Ahem), Pattern 8 (the throwing-`HttpOverrides` offline guard via the shared bootstrap), Pattern 9 (real stack only in `integration_test`; fakes everywhere else) |
| Skill `domain-asset-pack-integrity` | Exactly **one** HTTPS socket exists in the whole app (the assets downloader), fail-closed verification, and after the one-time fetch **no further network** — the invariant this acceptance run turns into a device-observable fact |
| Skill `eng-add-ci-check` | Every check names the PRD §20 gate it serves; pinned toolchain (`3.41.2`); a red gate blocks release — **no `continue-on-error`**; prove the gate against a deliberate violation before trusting it |
| Repo: `.github/workflows/ci.yml` (`journeys` job) | Already runs `flutter test app/integration_test` on the api-24 emulator and its comment already reserves "the airplane-mode acceptance run (throwing HttpOverrides)" — this file joins that glob; **no workflow edit** |
| Repo: `app/test/test_setup.dart` | The canonical `useOfflineTestPolicy()` throwing-override bootstrap (E-owned, layer (a)) this journey imports — extend by *use*, never fork or weaken |
| Repo: `app/integration_test/journey_daily_loop_test.dart` | The driving pattern to reuse: `ProviderScope` overrides (`persistenceProvider`, `todayProvider.overrideWithValue(...)`, `FakeNotificationScheduler`), the cold-start-to-Today helper, `seedReferenceFixture` from `data/testing` |
| Repo: `app/integration_test/mushaf_render_test.dart` + `packages/composition` (`installAndPrepareCore`) | The real first-launch verified install (register 604 fonts, verify bytes, build reference DB, stamp ready) and the `_bundledCorePresent()` Git-LFS guard pattern; `packages/assets/lib/testing.dart` (`FakeAssetDownloader`) is the mock seam if a pack step must be driven |
| Sibling **E20-T01** | Owns the committed gate→job mapping table; if this run needs a mapping row under gate 6, that row lands in T01's contract file, not here |
| Sibling **E20-T02** / **E20-T07** | T02 owns `release.yml` (which re-runs the gate suite from the signed tag); T07 cites this run as the "observe airplane-mode" walkthrough in `docs/verify-yourself.md` — neither is written here |

## Implementation notes

This task ships exactly one file — a test. It changes no production code, no workflow, no string. The proof style is *loud and named*: a socket attempt throws with a named message AND is counted, and the run ends with an explicit zero-attempts assertion, so the evidence is positive, never absence-of-crash.

1. **File:** `app/integration_test/airplane_mode_acceptance_test.dart`. First lines of `main`: `IntegrationTestWidgetsFlutterBinding.ensureInitialized();` then install the offline policy **before any pump**. The integration binding is a live binding — the `flutter_test` 400-fake is not there to catch you (11 §7), so the throwing override is the *only* guard; installing it late is the classic silent hole.
2. **Recording + throwing override:** wrap the `test_setup.dart` policy in a local recording variant — `createHttpClient` appends the attempt to a list, then throws the same named `StateError('Network access attempted…')`. Keep `useOfflineTestPolicy()`'s contract (never reset `HttpOverrides.global`; that opt-out belongs solely to the assets downloader test). The final assertion is `expect(socketAttempts, isEmpty)` — the brief's "no surface opens a socket" as a named check.
3. **The one-time install, offline by construction:** when the bundled core is really present (reuse the `_bundledCorePresent()` size guard — a Git-LFS pointer stub is ~130 bytes), run the real first-launch `installAndPrepareCore(handle)`; on the lean CI checkout fall back to the deterministic fixture path (`seedReferenceFixture` over the same `PersistenceHandle`). Either way **the acceptance assertions always run — the test never self-skips**; only muṣḥaf render depth varies (real glyph lines vs. reader chrome over fixture lines). If any onboarding pack seam must be driven, inject `FakeAssetDownloader` at the boundary — never a real client, never an `HttpOverrides` reset.
4. **Onboard once, then stay offline:** drive cold start to Today exactly per `journey_daily_loop_test.dart` — `ProviderScope` overrides for `persistenceProvider`, `todayProvider.overrideWithValue(CalendarDate(...))`, `FakeNotificationScheduler()` — then never touch the install path again.
5. **Drive all five surfaces via the real `HomeShell` bottom nav** (RTL order, Today rightmost), tapping the same controls a user taps — no test-only backdoor routes. Per-surface "functions" assertions: **Today** — the finite grouped due list renders from the seeded state, and one grade rides the single write path offline (a `review_log` row appends; the graded page leaves today); **Muṣḥaf** — `MushafReaderScreen` opens and page navigation works (real glyph lines on the bundled-core path); **Mutashābihāt** — the trainer renders groups/hotspots from the local dataset; **Progress** — the retention heat-map builds its juz grid from the local DB; **Settings** — opens, and one display-only preference flip persists across a rebuild.
6. **Determinism:** the injected `CalendarDate` is the only clock — advance days (if needed) by re-pumping with a new `todayProvider` override, never a real clock or `Future.delayed` wall-time; seeded fixtures only; no randomness. Finders prefer types/keys over literal strings (the run must not introduce or depend on a hardcoded user-facing string in any locale).
7. **Respect the closed journey suite:** this run is authorized by 11 §7 as the no-network gate's completing member, not a fifth PRD journey — do not re-assert J1–J4's flow-level correctness (reveal-gating, clamp math, catch-up spread live in the widget/engine/journey suites); assert only *renders-and-operates-with-zero-network* per surface.
8. **CI:** zero workflow edits — the file joins `flutter test app/integration_test` in the existing `journeys` job (pinned `3.41.2`, api-24, required, no `continue-on-error`), whose comment already names this run. Prove the gate once against a deliberate violation (temporarily create an `HttpClient` in the test body; watch it fail loud and named; remove it) per eng-add-ci-check — do not commit the violation.
9. **Pitfalls:** installing the override after the first pump; `pumpAndSettle()` on any indefinite indicator (pump explicit durations); asserting offline-ness only by absence of a crash; resetting `HttpOverrides.global` "just for setup"; a real download anywhere in the install step; `markTestSkipped` on the whole test when LFS assets are absent (only the render-depth branch may narrow); `DateTime.now()`; touching `ci.yml`, `release.yml`, T01's mapping table, or any production/l10n file.

## Acceptance criteria

- [ ] `app/integration_test/airplane_mode_acceptance_test.dart` exists; the recording+throwing offline policy is installed before the first pump and never reset; the file changes nothing outside `app/integration_test/`.
- [ ] The one-time verified core install completes offline (real `installAndPrepareCore` when the bundled core is present; the deterministic fixture path otherwise) — and the acceptance assertions run on **both** paths; the test never self-skips.
- [ ] Post-onboarding, all five surfaces — Today, Muṣḥaf, Mutashābihāt, Progress, Settings — are driven through the real `HomeShell` bottom nav and each passes its "renders and operates" assertion with the throwing override active.
- [ ] One offline mutation proves the write path end-to-end: grading a Today page appends a `review_log` row and reschedules the page, with zero network.
- [ ] The run ends with the named zero-socket assertion (`socketAttempts` empty); any connection attempt anywhere in the run fails loud with the named `StateError`, never a silent 400.
- [ ] Deterministic: the injected `CalendarDate` is the only clock, fixtures are seeded, no `DateTime.now()`/randomness in the file (grep-verifiable).
- [ ] The run is green inside the existing `journeys` job (api-24 emulator, pinned Flutter `3.41.2`) with no `continue-on-error` and no workflow modification by this task.
- [ ] The gate was proven against a deliberate (uncommitted) violation: a raw `HttpClient()` in the test body fails the run with the named error; the proof is noted in the task's commit/PR description.
- [ ] Boundary respected: no edit under `tool/`, to any `test_setup.dart`, to `ci.yml`/`release.yml`/`update-goldens.yml`, or to any production, l10n, or docs file — the static gate layers and the release contract stay exactly as their owning tasks left them.

## Tests

The deliverable *is* the test. It is deterministic, offline by construction, on the real Drift/SQLite stack and real bundled fonts where present, with the injected `CalendarDate` (never a real clock).

- `app/integration_test/airplane_mode_acceptance_test.dart` (integration, joins the `journeys` job) — pins, in order:
  - the offline policy is active from before the first frame (a socket in setup would already throw);
  - the one-time verified install → onboarding → Today lands with **zero** recorded socket attempts (the C1 "offline after setup" half);
  - per-surface function under the throwing override: Today's grouped finite list, the Muṣḥaf reader open + page navigation (real glyph lines on the bundled-core path), the Mutashābihāt trainer's groups, the Progress heat-map grid, a persisted Settings preference flip;
  - the offline write path: one grade → `review_log` append → page reschedules (persist-before-republish survives a rebuild);
  - the terminal named assertion: `socketAttempts` is empty across the entire run — the dynamic proof of PRD §20 gate 6 / §17 "airplane mode permanently".
- No unit/widget/golden files are added: flow-level correctness stays pinned where it lives (engine vectors, widget suites, J1–J4); the static no-network layers stay pinned by their own `tool/` meta-tests. Local run: `flutter test integration_test/airplane_mode_acceptance_test.dart -d <device>` from `app/`.

## Definition of Done

- [ ] All acceptance criteria met; the run is green in the `journeys` job and is release-blocking (required job, no `continue-on-error`), completing gate 6's dynamic half per the E20-T01 contract (any mapping-table row lands in T01's file).
- [ ] **Offline / no-network (C1, §20 gate 6):** the whole post-onboarding app operated under the throwing override with a named zero-socket assertion; the single permitted socket (the assets downloader) was never exercised post-install; no `HttpOverrides` reset exists outside the E-owned downloader test.
- [ ] **No AI / no microphone (C2, R5):** nothing this run drives records, transcribes, or infers; no mic permission, model, or audio surface is reachable from any of the five surfaces.
- [ ] **Quran text fidelity (R1):** the muṣḥaf renders only through the immutable verified pipeline (`installAndPrepareCore` on the bundled, build-time-hashed core); the run never re-typesets, masks, or mutates sacred text and renders no Quran text from an unverified source (§19.3).
- [ ] **Never "safe to drop" (§7.12):** this task adds no copy and no engine change; its assertions never encode a page as droppable — the graded page *reschedules*, it does not disappear from the system.
- [ ] **No gamification / no shame (R3):** the run introduces no strings and asserts no celebration/streak/guilt surface; it merely proves the calm surfaces already built keep working with the radio off.
- [ ] **RTL + fa/ckb/ar:** the journey drives the shell in its real RTL locale through the RTL-ordered bottom nav; finders use types/keys, so no hardcoded user-facing string is introduced in any locale.
- [ ] **Accessibility:** navigation happens through the same real ≥48dp user-facing controls (no test-only backdoors); the E08 audit machinery is untouched.
- [ ] **Deterministic tests:** injected `CalendarDate` + seeded fixtures only; the run is byte-stable across re-runs on the pinned toolchain (`3.41.2`); all existing gates stay green with zero production-code churn.
