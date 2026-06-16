# E07-T09 — Kill-and-relaunch crash-safety verification over the WAL store (deterministic integration test)

| | |
|---|---|
| **Epic** | [E07 — App Shell & Walking Skeleton](EPIC.md) |
| **Size** | S (≈half-day) |
| **Depends on** | E07-T05, E07-T08 |
| **Skills** | eng-write-dart-test, eng-define-service-boundary |

## Goal

The persist-before-republish covenant becomes a tested fact over the **real WAL Drift store**: a deterministic `integration_test` proves that a page graded through `CardRepository.recordReview` (E07-T05) survives ungraceful process termination. The test opens an on-disk `AppDatabase` (WAL, `synchronous=FULL`) at a per-run path, grades one page for a fixed `today` (injected `FixedClock`), then **drops every reference with no graceful teardown** — no checkpoint, no `db.close()`, no `wal_checkpoint` — re-opens a *fresh* `AppDatabase` over the same file family, and asserts both that the graded card carries its new engine state (D/S/`due_at`/reps) **and** that exactly one appended `review_log` row for that page is present: the review either fully happened or did not. This is the "did my hifz record survive?" moment — a *sanad* act the disk must hold — held green on every PR; the E07-T10 smoke flow is the end-to-end UI confirmation.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/05-persistence-and-encryption.md` §3 (Crash safety) | The covenant under test verbatim: **WAL + `synchronous = FULL`**, **one `db.transaction` per review** committed atomically or not at all, "when a write method returns, the change is durably on disk," and "no *sanad* act is acknowledged before it is committed" — the property is that the transaction was durable the *moment* `recordReview` returned, so nothing may depend on graceful shutdown |
| `docs/engineering/05-persistence-and-encryption.md` §3 Pitfalls | **We refuse persist-after-publish** (the worked counter-mutation that must turn the test red); the WAL **three-file family** (`hifz.sqlite`, `-wal`, `-shm`) — reopening must use the same file path so uncheckpointed `-wal` commits are seen; **never file-copy the live store** (this test re-opens, it does not copy) |
| `docs/engineering/01-architecture-overview.md` §4 (unidirectional data flow) | The one-review loop step ordering: append `review_log` (step 5) → persist transactionally → **republish only after the write returns** (step 6); "today is INJECTED (a `CalendarDate`)" — the test fixes it with a `FixedClock`, never `DateTime.now()` |
| `docs/engineering/11-testing-strategy.md` §6 (`integration_test` exercises the real stack) | The real SQLite stack runs only in `integration_test/` after `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`; widget tests use in-memory fakes — this crash-safety test belongs at the integration tier because it needs a **real on-disk WAL file**, not `NativeDatabase.memory()`; do not `pumpAndSettle()` an indefinite indicator |
| `docs/engineering/11-testing-strategy.md` §7 (no-network gate) | Install the throwing `HttpOverrides` (`useOfflineTestPolicy()`) so any stray socket during the crash-safety run is a loud, named failure; the airplane-mode acceptance posture is preserved |
| `docs/engineering/11-testing-strategy.md` §3, §10 | Assert engine doubles (`due_at`/D/S) with `closeTo(expected, 1e-6)`, never `==` on doubles; every assertion checks behaviour (a meaningful `expect`), no coverage-percentage gate |
| Skill `eng-write-dart-test` (patterns 1, 3, 8, 9, 11; `template.dart` integration-journey + throwing-`HttpOverrides` scaffolds) | Tier placement (real stack only in `integration_test`); inject `today` as a literal `SerialDay`/`CalendarDate` (no wall clock); the throwing-`HttpOverrides` bootstrap; `try`-typed `catch`, no `print`/`!`/`late`, REUSE SPDX header, full-word names; assert behaviour to tolerance |
| Skill `eng-define-service-boundary` (pieces 4–7; `template.dart`) | The Drift handle is an injected boundary wired at the composition root — the test builds the **live** on-disk `AppDatabase` and the `FixedClock` exactly as `main()` does and supplies them via `ProviderScope(overrides:)`; the mutating boundary is consumed through the single write path (one transaction, persist-before-republish); a sign-off/persistence boundary never acknowledges a *sanad* act before durable commit |
| CLAIMS — C-016 (cycle-ceiling guarantee), C-031 (one card = one of 604 muṣḥaf pages), C-048 (fully offline, no microphone) | The reopened card's `due_at` is the trust-clamped engine value the spine surfaces honestly (C-016); the graded record is one of the 604 page cards (C-031); the no-network guard upholds C-048. **No user-facing string is authored in this task** — these name the covenants the test must not break, not rendered copy |
| Sibling **E07-T05** (`CardRepository.recordReview` single write path) | The exact method whose durability is proven: one `db.transaction` that appends the `review_log` row then upserts the engine-updated `card`, committing **before** the stream re-emits — this task does not modify it, it verifies it survives a kill |
| Sibling **E07-T08** (one-tap grade command through `recordReview`) | The grade command this test drives at the repository layer (T08 drives it through the UI; this task calls `recordReview` directly with a fixed grade and `today`, keeping the test deterministic and headless of the widget tree) |
| Sibling **E07-T10** (integration spine journey) | The end-to-end UI confirmation (seed → Today → grade → stream re-emit) that *consumes* this proof; T10 may add the literal-process-kill UI leg, this task owns the deterministic disk-durability assertion |
| Dependency **E03** (models & persistence) | Owns the `AppDatabase` Drift class (WAL, `synchronous=FULL`), the `card`/`review_log` schema, and the `openAppDatabase(path)`-style factory the test opens on disk — this task consumes them, it does not redefine the schema or the transaction body |

## Implementation notes

**TEST-FIRST** (correctness-critical: this task *is* a test — the crash-safety covenant is the deliverable). Write the failing assertions against the wired spine first; the only production glue this task may force into existence is a test-visible on-disk `AppDatabase` factory if E03 does not already expose one.

1. **Tier & file**: `integration_test/crash_safety_relaunch_test.dart` in `packages/app/` (the only target that composes the full stack), beginning with `IntegrationTestWidgetsFlutterBinding.ensureInitialized();` and `useOfflineTestPolicy()` (the throwing `HttpOverrides`, `11` §7). The real on-disk WAL file is exactly why this is an integration test, not a widget test with `NativeDatabase.memory()` (`11` §6; `eng-write-dart-test` pattern 9).
2. **Per-run isolated store path**: build the live `AppDatabase` over a unique temp directory (e.g. `Directory.systemTemp.createTempSync('hifz_crash_')`) so reruns never collide and a stale file never masks a regression. Open it through E03's live `openAppDatabase(file)` factory / `NativeDatabase(file)` — the **same WAL `PRAGMA`s `main()` sets** (`journal_mode = WAL`, `synchronous = FULL`), never an in-memory connection (`05` §1, §3).
3. **Session 1 — write through the single write path**: construct the spine's collaborators as the composition root does — the on-disk `AppDatabase`, a `FixedClock(CalendarDate.ymd(2026, 6, 16))`, and the `CardRepository` over that handle (via `ProviderScope(overrides:)` or by direct construction mirroring `main()`; `eng-define-service-boundary` piece 4). Seed one due `card` for a fixed `pageId`, then call `recordReview(...)` with a fixed grade (e.g. `Good`) and the fixed `today`. **Do not** route through the widget tree — call the repository method directly so the assertion isolates disk durability, not UI plumbing (T08/T10 own the UI legs).
4. **The "kill"**: after `recordReview` returns, **drop every reference with no graceful teardown** — no `db.close()`, no `customStatement('PRAGMA wal_checkpoint')`, no scene-phase hook. The property under test (`05` §3) is that the transaction was durable the moment the write Future resolved; the `-wal`/`-shm` files are left exactly as a hard kill would leave them. (The literal OS process kill is the T10 smoke flow's job.)
5. **Relaunch — re-open a fresh stack over the same file**: construct a brand-new `AppDatabase` over the **same** temp file path (so uncheckpointed `-wal` commits are read; `05` §3 pitfall — the three-file family). Re-run the card query and the `review_log` query for that `pageId`/`profileId`.
6. **Assertions** (both halves of "fully happened or did not"): `expect` the reopened `card`'s engine state equals the post-review state — D/S/`due_at`/reps the engine produced — with `due_at` and any double asserted via `closeTo(_, 1e-6)` (`11` §3); `expect` **exactly one** appended `review_log` row exists for that page with the written grade and the fixed review day (`findsOneWidget`-equivalent count). Optionally assert `PRAGMA integrity_check` returns `ok` on the reopened store (consistency of the WAL replay; mirrors the migration-fixture posture in `05` §4). Tear down the temp directory in a `addTearDown`/`finally` **after** the assertions — never the mid-test "crash" state.
7. **Red-first proof**: with a locally inverted republish-before-persist mutation (the §3 "persist-after-publish" anti-pattern — republish in memory, then await the transaction) **not committed**, this test must fail. Note this in the test doc comment so a reviewer can reproduce the red.
8. **Pitfalls** (`05` §3 / `11` §6): never re-seed or inject state on the relaunch leg — the reopened card and log row must come **from disk**, or the test masks a persistence failure; never `db.close()`/checkpoint before the kill (that would smuggle in graceful shutdown — surviving *without* one is the point); never file-copy the store (re-open the same path; copying only `hifz.sqlite` loses `-wal` commits, `05` §3); use `closeTo`, never `==`, on `due_at`/D/S; no `DateTime.now()` anywhere in the test — `today` is the `FixedClock`'s `CalendarDate` (E01's CI grep bans the wall clock); no networking import (the throwing `HttpOverrides` makes any stray socket loud, C-048); do **not** add a graceful-shutdown hook to production code to make the test pass.

## Acceptance criteria

- [ ] `integration_test/crash_safety_relaunch_test.dart` exists in `packages/app/`, calls `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`, installs the throwing `HttpOverrides`, and runs the real on-disk WAL `AppDatabase` (never `NativeDatabase.memory()`).
- [ ] The write leg grades one page through `CardRepository.recordReview` (E07-T05) — the single write path, one `db.transaction`, append `review_log` then upsert `card` — with a fixed grade and a `FixedClock` `today`; no `DateTime.now()` appears in the test.
- [ ] The "kill" drops every reference with **no** graceful teardown (no `db.close()`, no `wal_checkpoint`, no checkpoint) before reopening; the WAL `-wal`/`-shm` files are left as a hard kill leaves them.
- [ ] The relaunch leg opens a **fresh** `AppDatabase` over the **same** temp file path (not a copy, not a new path) and reads the card and `review_log` purely from disk — no state is seeded or injected on reopen.
- [ ] The reopened `card` carries the post-review engine state (D/S/`due_at`/reps), asserted with `closeTo(_, 1e-6)` for any double; `due_at` is the trust-clamped engine value (C-016), not a recomputed date.
- [ ] **Exactly one** appended `review_log` row for the graded page is present after reopen, with the written grade and the fixed review day — the review fully happened (atomic), with no half-applied state.
- [ ] Red-first verified: with a locally inverted republish-before-persist mutation (not committed), the test fails — proving it actually pins the covenant; the doc comment records how to reproduce the red.
- [ ] The per-run store directory is isolated and torn down after the assertions; reruns do not collide; the test installs no graceful-shutdown crutch in production code.
- [ ] Optional but preferred: `PRAGMA integrity_check` on the reopened store returns `ok`.
- [ ] The test file carries the REUSE SPDX header (`GPL-3.0-or-later`), uses full-word/unit-bearing names, typed `catch` (no bare/`print`/`!`/`late`), and passes `dart format` + the analyzer/lint config.

## Tests

TEST-FIRST — this task is the test; no production behaviour is added beyond an on-disk `AppDatabase` factory if E03 does not already expose one.

- `packages/app/integration_test/crash_safety_relaunch_test.dart` — the **integration tier** (real on-disk WAL SQLite; `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`), one named case (e.g. `gradedPageSurvivesUngracefulKillAndRelaunch`):
  - **write** one grade through `recordReview` over an on-disk WAL `AppDatabase` with a `FixedClock` `today`;
  - **kill** — drop references with no checkpoint/close;
  - **relaunch** — reopen a fresh `AppDatabase` over the same file;
  - **assert** the card's new D/S/`due_at`/reps (`closeTo(_, 1e-6)`) **and** exactly one appended `review_log` row for the page; optionally `PRAGMA integrity_check == ok`.
- Offline guard: the shared throwing `HttpOverrides` (`useOfflineTestPolicy()`) is installed so any network attempt fails loudly (`11` §7) — no real network is reachable.
- This **complements, never duplicates**, E07-T05's write-path unit (failed persist ⇒ no republish; memory never newer than disk, on `NativeDatabase.memory()`) — T05 proves the in-memory transaction shape; this task proves on-disk durability across a kill.
- Run in CI on the `integration_test` job on every PR; no `pumpAndSettle()` on an indefinite indicator; engine doubles asserted to tolerance, never `==`.

## Definition of Done

- [ ] All acceptance criteria met; the deterministic crash-safety integration test is green in CI on every PR, and red under the inverted republish-before-persist mutation.
- [ ] **Persist-before-republish proven on disk:** the graded card's new state and its single appended `review_log` row survive ungraceful termination, re-read from a freshly opened WAL store — the review either fully happened or did not, with no code path leaving memory newer than disk (`05` §3).
- [ ] **Offline / no-network:** the test imports no networking package and installs the throwing `HttpOverrides`; any stray socket fails loudly; the crash-safety run needs zero network (C-048); E01's banned-import + allow-list gates stay green.
- [ ] **No AI / no microphone:** the test exercises only the human-self-rating grade through `recordReview`; no ASR, ML, model, or audio is touched anywhere in the path.
- [ ] **Quran text fidelity:** the test renders no muṣḥaf glyph and re-typesets nothing; it asserts only persisted scheduling state for one of the 604 page cards (C-031); the graded `due_at` is the trust-clamped engine value (C-016), never recomputed in the test.
- [ ] **Determinism:** `today` is the injected `FixedClock`'s `CalendarDate`; no `DateTime.now()`/`Calendar.current` anywhere in the test; engine doubles asserted with `closeTo(_, 1e-6)`; the per-run store path is isolated so the test is reproducible.
- [ ] **RTL + fa/ckb/ar:** no user-facing string is authored in this task; no hardcoded copy is introduced — the covenant is asserted at the data layer, below the localized surfaces.
- [ ] **Accessibility:** not applicable to this deterministic data-layer test (the spine's accessibility identifiers and `Semantics` labels are exercised by E07-T10's smoke flow); this task introduces no UI.
- [ ] **Sect-neutral adab / *sanad* integrity:** the test pins that a graded page — a *sanad* act — is acknowledged only after it is durably committed; nothing implies a madhhab/sect ruling; no streak/score/guilt assertion is introduced; a graded page is never marked droppable or "done."
- [ ] **Standards & tests:** the file carries the REUSE SPDX header, full-word/unit-bearing names, typed `catch`, no `print`/`!`/`late`; `dart format` and the analyzer/lint config pass; no graceful-shutdown crutch is added to production code to make the test pass.
