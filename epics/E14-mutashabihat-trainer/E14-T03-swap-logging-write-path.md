# E14-T03 — The swap-error logging path: write/strengthen an edge at full strength through the single write path — test-first

| | |
|---|---|
| **Epic** | [E14 — Mutashābihāt Trainer](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E14-T02 |
| **Skills** | domain-mutashabihat-system, eng-create-riverpod-store, eng-write-dart-test |

## Goal

A wrong-branch swap error — page A's wording recited while the ḥāfiẓ is located in page B — writes or strengthens the one `confusion_edge` for the unordered `(ayah_a, ayah_b)` pair, **at full strength regardless of source** (self or teacher), through a single repository method that persists transactionally **before** any in-memory/stream state republishes. The edge's `weight` grows as a plain function of the user's own logged-swap history (no ML, no inference), and `last_confused_at` is stamped from the **injected `today`**, never a wall clock. The write is pure bookkeeping layered on the one write path — it does *not* re-implement the FSRS `onReview` arithmetic, does *not* bump `D` (that is E14-T04), and refuses any second mutation surface for the graph. Authored test-first: the full-strength write, the weight bookkeeping, the canonical-pair ordering, and the "a failed persist never republishes" guarantee all exist and fail before the method body is written.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §9.1, §10.2 | The personal confusion log is grown **only** from the user's own logged swap errors (page A's wording recited while in page B's location); "pure bookkeeping; no ML"; the `confusion_edge(profile_id, ayah_a, ayah_b, weight, last_confused_at)` user table this method writes |
| `docs/engineering/06-scheduling-engine.md` §4 (the review update; the note after `onReview`) | The load-bearing rule: `errorLines` and **any confusion-edge updates are applied at full strength regardless of source** — even a self-reported "I swapped these two" is valuable graph data; **only** the *magnitude of the S move* is `sourceConfidence`-scaled (that scaling lives in `onReview`, not here). This task writes the edge at full strength and touches no S/D |
| `docs/science/05-interference-and-mutashabihat.md` §7 | Two inputs feed the layer: the bundled scholar-reviewed dataset (E14-T01) and the personal log grown **only** from the user's own swaps; both are plain bookkeeping, no AI/inference (PRD C2); a swap writes a `confusion_edge` whose weight decays/grows from the user's own history |
| `docs/science/05-interference-and-mutashabihat.md` §8 | Teacher *talaqqī* is authoritative and outranks the machine, but a **self**-reported swap is still recorded — never dropped because it was not a teacher sign-off; honest, non-gamified framing |
| `docs/engineering/05-persistence-and-encryption.md` §2 (DDL), §3 (crash safety) | The committed `confusion_edge` DDL: `STRICT`, `PRIMARY KEY (profile_id, ayah_a, ayah_b)`, `CHECK (ayah_a < ayah_b)` (one edge per **unordered** pair, canonical ordering), `weight REAL NOT NULL DEFAULT 0`; the bump rides one `db.transaction` (WAL + `synchronous = FULL`), `insertOnConflictUpdate` for the upsert, persist-before-republish |
| `docs/engineering/04-flutter-and-state-patterns.md` §1.1, §4 | The single write path: a controller/widget never mutates persisted state or calls a DAO directly; the mutation is one named **repository** method that commits before the controller's `await` returns; the failed-persist→`RetryView` calm-error branch (no guilt copy) |
| `docs/engineering/07-dates-calendars-and-correctness.md` (`CalendarDate`) | `last_confused_at` is stamped from the injected `today` (`CalendarDate` serial day), never `DateTime.now()`/`Calendar.current`; the clock arrives via the injected `clockProvider` |
| Skill `domain-mutashabihat-system` (+ `template.dart`) | Rule 6 — confusion log is pure bookkeeping, the swap writes a `confusion_edge` at **full strength regardless of source**, only the S move is source-scaled; confusion is a property of the **group/pair**, not the node; no ML/inference; Rule 9 — deterministic, no `DateTime.now()`/`Random` |
| Skill `eng-create-riverpod-store` (+ `template.dart`) | The single-write-path mutation shape: a repository method that opens one `db.transaction` and **commits before** the controller republishes; the controller propagates failure to a calm `RetryView`; the engine/repository/clock injected as `Provider`s; no `DateTime.now()` in shell logic; the active-profile `Notifier` gate; immutable value types |
| Skill `eng-write-dart-test` (+ `template.dart`) | Test-first; DAO/repository unit tests with an in-memory Drift database; inject `today` as a literal `CalendarDate` (no wall clock); assert behaviour (a meaningful `expect`); typed `catch`; the throwing `HttpOverrides` offline guard; REUSE SPDX header |
| CLAIMS | None surfaced by this task — it writes a value, renders no user-facing number or string. The hotspots copy that *reads* this graph (C-029, C-045) is E14-T10/E14-T11; the `(11−D)` behaviour (C-029) is E14-T04 |
| Siblings: E14-T02, E14-T04, E14-T06, E12 | T02 owns the `ConfusionEdge` value type (in `models`) and the `confusion_edge` Drift table + DAO + migration this method calls — the table/DAO is **not** this task. T04 consumes the strengthened edge to bump `D` on every group member via `(11−D)` — the difficulty bump is **not** this task. T06 reads these rows as hotspots. E12 (today-and-recite-grade) emits the normalized swap signal this method consumes from the daily recite flow |

## Implementation notes

**TEST-FIRST:** write the write-path suite in `## Tests` below before the method body. The full-strength-regardless-of-source case, the weight-bookkeeping (first-swap vs repeat-swap) case, the canonical-pair-ordering case, and the failed-persist-never-republishes case must exist and **fail** before `logSwap` is implemented.

1. **Repository method (the single write path), in `data`.** Add one method to the confusion-edge repository (the `data`-package type that owns the `ConfusionEdgeDao` from E14-T02 — e.g. `packages/data/lib/src/repositories/confusion_repository.dart`):
   ```dart
   /// Records a wrong-branch swap between two ayāt for [profileId], strengthening
   /// (or creating) the single canonical-ordered confusion_edge — at FULL strength
   /// regardless of [source]; only the engine's stability move is source-scaled.
   Future<void> logSwap({
     required ProfileId profileId,
     required AyahId ayahX,
     required AyahId ayahY,
     required CalendarDate today,
   });
   ```
   The body opens **one** `db.transaction` (WAL + `synchronous = FULL` already configured on the write connection), reads the existing edge for the canonical pair, computes the next `weight`, and upserts via the DAO's `insertOnConflictUpdate`. The transaction commits before the `Future` returns — persist-before-republish; the controller/stream observes the change only after.
2. **Canonical pair ordering is computed here, not assumed from the caller.** The DDL enforces `CHECK (ayah_a < ayah_b)` and `PRIMARY KEY (profile_id, ayah_a, ayah_b)` — **one edge per unordered pair**. Order `(ayahX, ayahY)` into `(ayah_a, ayah_b)` with `ayah_a < ayah_b` *inside* this method so the same swap logged in either direction (A-recited-in-B vs B-recited-in-A) lands on the **same** row and strengthens it, never a mirror duplicate. Compare on the stable `AyahId` ("s:a") ordering E14-T02 defines (do **not** invent a second ordering). Reject `ayahX == ayahY` as a programming error (a swap is between two distinct ayāt).
3. **Weight bookkeeping is a plain, deterministic function of the user's own history — no ML.** On first swap of a pair the row is created with `weight = kInitialConfusionWeight` (a named constant, not a magic literal); each subsequent swap of the same pair strengthens it by a named, pure increment (e.g. `weight = nextConfusionWeight(prior.weight)`), monotonic and bounded — never an inferred or trained value. Keep the weight rule a small pure function so it is unit-testable in isolation and re-used by no other path. This task does **not** implement decay-over-time of the weight; if the science rule calls for decay it is a separate, explicitly-scoped change, not smuggled in here.
4. **`last_confused_at` from the injected `today`.** Stamp `last_confused_at` from the `CalendarDate today` argument the controller passes down from the injected `clockProvider`. Do not read `DateTime.now()`/`Calendar.current`/`TimeZone.current` anywhere in this path; serialize the `CalendarDate` exactly as E14-T02's column mapping defines (the repository must not invent a second serialization).
5. **Full strength regardless of source — and source is not even an input to the weight.** Per engineering 06 §4, the edge is written at full strength whether the swap came from a self-rating or a teacher sign-off; the `Source` confidence scales only the *stability* move in `onReview` (E04/E14-T04), never this weight. So `logSwap` takes **no** `source`/`confidence` parameter that throttles the weight — a self-reported swap is recorded identically to a teacher-flagged one (science 05 §8; the mutashabihat skill's Do/Don't: "Don't drop a self-reported swap because it wasn't a teacher sign-off").
6. **Controller wiring (the seam, kept thin).** The Mutashābihāt/recite controller that triggers a swap (this task only wires the *write seam*; the standalone-trainer drill that calls it is E14-T08, the daily-recite caller is E12) exposes one `async` command that reads the active `ProfileId` (from the active-profile `Notifier` gate) and `today` (from `clockProvider`), then `await`s `logSwap`. It republishes nothing of its own — the `confusion_edge` `StreamProvider` read model (E14-T06) re-emits after commit and the hotspots view rebuilds. On failure the command surfaces a calm error state (`RetryView`), never a guilt/loss message, never a `try?` swallow, never a debounced/"save later" write (a swap is a durable bookkeeping act).
7. **No engine math here.** This task writes the edge only. It must **not** call `onReview`, must **not** mutate `D`/`S`/`due_at`, and must **not** pull siblings into a session — the `(11−D)` difficulty bump on every group member is E14-T04 and the sibling-massing is E14-T05. Keep `logSwap` free of any FSRS symbol; a grep over the method should find no `onReview`/`stabilityOnSuccess`/`nextDifficulty` reference.
8. **Pitfalls to avoid:**
   - **Republishing before the transaction commits** — the exact inversion the suite must catch; assign/emit only after `await` returns.
   - **A mirror-duplicate edge** because ordering was done by the caller (or not at all) — order inside `logSwap` and rely on the `(ayah_a < ayah_b)` `CHECK` + PK as the backstop.
   - **Throttling the weight by source** — the weight is full-strength always; source scales only the engine S move elsewhere.
   - **`DateTime.now()`** sneaking into the timestamp — `today` is injected.
   - **A second write surface** (a DAO call from a widget, or a parallel "confusion service") — there is one repository method, on the single write path.
   - **`insert` instead of `insertOnConflictUpdate`** — the second swap of a pair must strengthen the existing row, not throw on the PK.
   - **Importing `drift` into `models`/`features`** — the DAO/table stay confined to `data`; no Drift symbol crosses the boundary.

## Acceptance criteria

- [ ] One repository method `logSwap({profileId, ayahX, ayahY, today})` (returning `Future<void>`) is the **only** code path that writes/strengthens a `confusion_edge`; no widget, controller, or other repository writes the table directly (verifiable by grep — the DAO write is reachable only from this method).
- [ ] The method orders the pair into canonical `(ayah_a < ayah_b)` form internally, so the same swap logged in either direction strengthens the **same** single row (no mirror duplicate); `ayahX == ayahY` is rejected.
- [ ] First swap of a pair creates the row with `weight = kInitialConfusionWeight`; each subsequent swap of that pair strengthens `weight` by the named pure increment, monotonically and bounded — derived **only** from the user's own logged swaps (no ML/inference).
- [ ] The edge is written at **full strength regardless of source**: `logSwap` has no source/confidence parameter that scales the weight; a self-reported swap and a teacher-flagged swap produce an identical weight change.
- [ ] `last_confused_at` is stamped from the injected `today` (`CalendarDate`); the file contains no `DateTime.now()`/`Calendar.current`/`TimeZone.current` (verifiable by grep).
- [ ] The write rides **one** `db.transaction` and commits **before** the method's `Future` completes; a forced persist failure propagates to the caller and leaves the persisted edge (and any in-memory/stream read model) exactly as before the call — no partial write, no republish.
- [ ] The method touches no FSRS state: no `D`/`S`/`due_at` mutation, no `onReview` call, no sibling-massing — it writes the edge only (E14-T04/E14-T05 own those).
- [ ] Every public declaration carries a `///` doc comment; the file carries the REUSE SPDX header and passes `dart format`/analyzer; the weight rule is a named pure function, no magic literals.

## Tests

`packages/data/test/repositories/confusion_repository_test.dart` (mirrors the source name), `package:test` + `drift`'s in-memory `NativeDatabase.memory()` executor seeded with a profile and the two ayāt (FK-valid), `today` constructed as a literal `CalendarDate` — no wall clock. The shared throwing-`HttpOverrides` offline bootstrap stays installed (this path opens no socket). Required cases, written **FIRST**:

- **First-swap create:** `logSwap` on a previously-unconfused pair inserts exactly one `confusion_edge` row with `weight == kInitialConfusionWeight`, the canonical `(ayah_a < ayah_b)` ordering, and `last_confused_at` equal to the injected `today`.
- **Repeat-swap strengthen (weight bookkeeping):** logging the same pair twice (and N times) leaves **one** row whose `weight` follows the named increment exactly and is monotonic/bounded; the row count never grows past one per unordered pair.
- **Canonical ordering / no mirror duplicate:** `logSwap(ayahX: A, ayahY: B)` and `logSwap(ayahX: B, ayahY: A)` strengthen the **same** single row (assert one row, ordered `ayah_a < ayah_b`); `ayahX == ayahY` throws/asserts.
- **Full strength regardless of source:** two runs that differ only in the originating source (self vs teacher, simulated at the caller) produce an **identical** weight delta — the source never throttles the edge weight (engineering 06 §4).
- **Failed persist never republishes:** a transaction wired to throw mid-write leaves the persisted edge byte-equal to its pre-call state (create *and* strengthen variants), the error propagates (typed `catch`), and the read-model stream emits no new value.
- **`today` injection, not a clock:** with `today` pinned to a fixed `CalendarDate`, `last_confused_at` is exactly that day across runs (determinism); a second run with a different injected `today` updates the stamp without re-reading any wall clock.
- **No engine mutation:** after `logSwap`, the `card` rows' `D`/`S`/`due_at` are unchanged (this task does not bump difficulty — that is E14-T04).

Controller seam unit (`packages/features/test/mutashabihat/...` or the feature's controller test, with in-memory Riverpod overrides): the swap command reads the active `ProfileId` and injected `today`, `await`s `logSwap`, republishes nothing of its own, and on a thrown write surfaces the calm error/`RetryView` state — no guilt copy, no `try?` swallow, no "save later". All cases run under `dart test`/`flutter test` in CI on every PR; the offline guard fails the build on any network attempt.

## Definition of Done

- [ ] All acceptance criteria met; the test-first write-path suite is green locally and in CI on every PR.
- [ ] **Single write path (non-negotiable):** the edge is written/strengthened through exactly one repository method that commits inside one `db.transaction` **before** republishing; a unit test proves a failed persist never republishes and no read model is left newer than disk; no widget/controller writes the DAO directly.
- [ ] **Full strength regardless of source:** a self-reported swap is recorded at the same strength as a teacher-flagged one; `Source` confidence scales only the engine's stability move elsewhere, never this weight (engineering 06 §4; science 05 §8).
- [ ] **No AI / no microphone / no inference:** `weight` is a plain, named pure function of the user's own logged swaps; nothing infers, trains, or guesses confusion at runtime; no audio is captured (PRD C2; science 05 §7).
- [ ] **Offline / no-network:** the path opens no socket; the throwing-`HttpOverrides` guard stays green and E01's banned-import/no-network gates pass.
- [ ] **Quran text fidelity:** this task writes integer/`AyahId` bookkeeping only — it never renders, reconstructs, re-typesets, or reshapes Quran text; no glyph/page path is touched (the anchor overlay is E14-T09).
- [ ] **Deterministic:** no `DateTime.now()`/`Calendar.current`/`TimeZone.current`/`Random` anywhere in the path; `today` is the injected `CalendarDate`; identical inputs produce an identical write.
- [ ] **Group-not-node / nothing safe to drop:** the swap writes an edge on the **pair**, the unit of confusion; this task adds no "cured"/"resolved"/"safe to drop" flag, no scoreboard, and no gamified affordance to the graph (the calm hotspots reading it are E14-T10).
- [ ] **RTL + fa/ckb/ar strings / accessibility:** N/A by construction at the write layer — `logSwap` and the seam command hold value types and render no user-facing string; any error copy is a localized, sect-neutral, calm `RetryView` string owned by `l10n` at the feature layer (E14-T11), never hard-coded here.
- [ ] **No unsourced number:** the task surfaces no user-facing number or claim; no CLAIMS id is invented (the hotspots copy that reads this graph cites C-029/C-045 in E14-T10/E14-T11).
- [ ] Every Dart file carries the REUSE SPDX header and `///` docs on public APIs; typed `catch`, no `print`/`!`/`late` on persistence values; passes the analyzer/lint config and `dart format`.
