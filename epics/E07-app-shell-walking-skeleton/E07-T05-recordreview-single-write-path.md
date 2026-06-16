# E07-T05 — CardRepository.recordReview single-write-path mutation + write-path unit suite (failed persist ⇒ no republish) — test-first

| | |
|---|---|
| **Epic** | [E07 — App Shell & Walking Skeleton](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E07-T01, E03, E04 |
| **Skills** | eng-create-riverpod-store, eng-write-dart-test, eng-write-to-coding-standards |

## Goal

`CardRepository.recordReview` exists in `packages/data/lib/src/repositories/card_repository.dart` as the **single write path** for a review: it reads the current immutable `Card` for `(profile, pageId)`, calls the pure `Engine.onReview(card, grade, errorLines, source, today)` with the **injected `CalendarDate`** (never `DateTime.now()`), and inside **one `db.transaction`** appends the append-only `review_log` row first and then upserts the engine-updated `card` — committing **before** any in-memory or Drift-stream state can re-emit. The transaction body and schema are E03's; this task routes the mutation through it and proves the covenant with a test-first write-path unit suite: a failed persist never republishes, memory is never newer than disk, and persist strictly precedes republish.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/04-flutter-and-state-patterns.md` §4 (the single write path) | The normative shape: exactly one route from a user action to a durable change — a repository method opening one `db.transaction`, appending `review_log` (never update/delete), upserting the card, committing **before** any in-memory/stream state becomes observable; the property table (atomicity, durability-before-acknowledgement, no double source of truth, engine purity preserved); the refusals (no optimistic republish, no "save later" for a review) |
| `docs/engineering/04-flutter-and-state-patterns.md` §1.3 (grade-a-page worked example) | The verbatim `recordReview` signature and body: `Future<void> recordReview({required ProfileId profile, required int pageId, required Grade grade, required List<int> errorLines, required ReviewSource source})`; `final today = clock.today()` then `db.transaction` → read card → `scheduler.onReview(...)` → `reviewLogDao.append` FIRST → `cardDao.upsert` → **no manual republish** (the Today list is a `StreamProvider` over a Drift query, so committing is what updates the UI) |
| `docs/engineering/01-architecture-overview.md` §4 (one review, end to end) | The six-step lifecycle: VIEW → COMMAND → REPOSITORY → ENGINE (today injected) → **PERSIST (step 5: append `review_log`, upsert card, before any republish)** → REPUBLISH (step 6, only after commit); "there is no code path where in-memory state is newer than disk"; the refusal "republish then persist" and "a second `due_at` computation anywhere" |
| `docs/engineering/05-persistence-and-encryption.md` §3 (crash safety) | WAL + `synchronous=FULL` on the write connection; **every review is exactly one `db.transaction`**, committed atomically or rolled back on throw; the `await` footgun (every query inside the transaction must be `await`-ed — a missing `await` is release-blocking); "We refuse persist-after-publish"; one transaction per review because a review is several writes |
| `docs/engineering/01-architecture-overview.md` §5 (the pure engine) | `Engine.onReview(card, grade, errorLines, source, today)` is total and pure — `today` is the last parameter, the engine reads no clock and does no I/O; the repository calls it for the new state, then persists; `due_at` is produced **only** by the engine's trust clamp, never re-derived here |
| Skill `eng-create-riverpod-store` (+ `template.dart`) | Step 3 (single write path: persist transactionally BEFORE republishing; the controller's `await` returns only after commit), step 6 (no swallowed write-path errors; failure propagates → calm `RetryView`, never a debounced/"save later" write for a *sanad* act), step 7 (the engine/clock injected as `Provider`s; the repository never constructs a live service), step 8 (no `DateTime.now()` — "today" is the injected `CalendarDate`) |
| Skill `eng-write-dart-test` (+ `template.dart`) | The write-path unit tier: a recording fake DAO/handle asserting persist-order at call time; `ProviderContainer.test()` + `overrideWith` to inject fakes; `package:test`/`flutter_test` placement; the throwing `HttpOverrides` offline guard installed in the bootstrap; assert behaviour (a meaningful `expect`), no coverage-percentage gate |
| Skill `eng-write-to-coding-standards` (+ `template.dart`) | `///` on the public `recordReview`; full-word unit-bearing names (`errorLines`, `today`); the covenant restated at the enforcement point as a why-comment (`// 05 §3: append review_log + upsert card in ONE transaction, commit before republish`); the one sealed I/O error type passes through untyped — never a bare `catch (_)`, never a swallowed write error; REUSE SPDX header |
| `docs/science/CLAIMS.md` C-016 | The cycle-ceiling guarantee behind the `due_at` this write commits: the trust clamp `due_at = min(ideal_due, ceiling_due)` is the engine's output, persisted verbatim — the repository never re-derives or relaxes it; the page is never marked "safe to drop" |
| `docs/science/CLAIMS.md` C-031 | One card = one of 604 muṣḥaf pages; `recordReview` keys on a `pageId` page card, never a verse-level card — the unit the `review_log` row and `card` upsert record |
| `docs/science/CLAIMS.md` C-048 | Fully offline, no microphone: the write path imports no networking and no audio/ML; grading is a human self-rating (`source: self`) reaching the repository as a `(grade, errorLines, source)` signal only |
| Siblings: E07-T01, E03, E04 | T01 supplies the injectable boundaries this routes through (the `Clock` → `clockProvider` `today()`; the Drift handle → `appDatabaseProvider`, live + `NativeDatabase.memory()`) each with a deterministic fake; **E03** owns the Drift schema, the `card`/`review_log` tables, the `CardDao`/`ReviewLogDao`, and the `db.transaction` body this method calls into; **E04** owns the pure `Engine.onReview` arithmetic and the trust clamp this method invokes — this task wires neither, it routes the mutation through both |
| Siblings: E07-T07, E07-T08, E07-T09 | T07's `todayQueueProvider` `StreamProvider` is the reactive read that re-emits *because* this transaction commits (the one source of truth — this method does no manual republish); T08's one-tap grade command calls `recordReview`; T09's kill-and-relaunch is the end-to-end confirmation of the persist-before-republish covenant this unit suite pins in-process |

## Implementation notes

**TEST-FIRST (correctness-critical):** write the write-path suite below **before** the `recordReview` body. The persist-order proof and the failed-persist-never-republishes case must exist and **fail** before the method is implemented — this is the single write path, the spine of the *sanad* covenant.

1. **File**: `packages/data/lib/src/repositories/card_repository.dart`, one primary type per file. `class CardRepository` constructed with the three injected collaborators it needs and nothing else: `CardRepository({required this.db, required this.scheduler, required this.clock})` where `db` is E03's `AppDatabase`, `scheduler` is E04's pure `Scheduler`/`Engine`, and `clock` is T01's `Clock`. The repository **never** constructs a live service and **never** reads a wall clock.

2. **The method** — verbatim per 04 §1.3, the only way a review reaches the database anywhere in the app:

   ```dart
   Future<void> recordReview({
     required ProfileId profile,
     required int pageId,
     required Grade grade,
     required List<int> errorLines,
     required ReviewSource source,   // self | teacher (E12 wires teacher; spine sends self)
   }) async {
     final today = clock.today();                 // CalendarDate, injected — never DateTime.now()
     await db.transaction(() async {              // 05 §3: one review = one transaction
       final card = await db.cardDao.byKey(profile, pageId);
       final result = scheduler.onReview(card, grade, errorLines, source, today);
       await db.reviewLogDao.append(result.logRow);  // append-only audit row FIRST (PRD §10.3)
       await db.cardDao.upsert(result.card);         // then the engine-updated card
     });
     // No manual republish: the Today queue is a StreamProvider over a Drift query (04 §3),
     // so committing the transaction is what makes the UI update. One source of truth.
   }
   ```

3. **`today` is injected, passed down.** `clock.today()` returns a `CalendarDate` (Gregorian-serial integer day) and is handed to the engine as its **last** argument. There is no `DateTime.now()`/`Calendar.current`/`TimeZone.current` anywhere reachable from this file — E01's CI grep bans it and the engine reads no clock at all (04 §1.3; 01 §5).

4. **`due_at` is the engine's output, persisted verbatim.** The repository does **not** compute or relax the due date — `onReview` returns it via the trust clamp `due_at = min(ideal, ceiling)` (C-016), and `cardDao.upsert(result.card)` stores exactly that. One sink, one truth; no SQL view, ViewModel, or this repository re-derives it (01 §4 refusal).

5. **Append-only `review_log`, append FIRST.** `reviewLogDao.append(result.logRow)` only ever inserts; there is no update/delete path (the DAO has none — E03). The audit row lands before the card upsert so a half-applied review can never leave a card state with no corresponding log entry; the transaction makes both all-or-nothing (05 §3).

6. **`await` every query inside the transaction.** Per Drift's transaction contract, an un-awaited query can execute after the transaction closes and cause data loss — a missing `await` inside the `db.transaction` block is a release-blocking review item (05 §3 the `await` footgun). The `byKey` read, the `append`, and the `upsert` are each `await`-ed.

7. **The transaction body/schema is E03's; this routes the mutation through it.** This task does not author the Drift tables, the `CardDao`/`ReviewLogDao`, `STRICT`/`CHECK` invariants, or the `@DriftDatabase` handle — those are E03 (`eng-add-persisted-model`). No Drift symbol crosses the `data` boundary: `recordReview` takes and returns plain value types (`ProfileId`, `Grade`, `ReviewSource`, `List<int>`), never a Drift `Companion`/`TableInfo`.

8. **Errors propagate; nothing is swallowed.** `recordReview` is `async` and lets E03's sealed persistence error type pass through untouched — no `try?`, no bare `catch (_) {}`, no debounced/"save later" write for a review (a durable *sanad* act, not draft text). The controller (T08) surfaces a failure as a calm `RetryView`; this method's job is to **not return success** until the commit resolves (eng-create-riverpod-store step 6; 05 §3 "We refuse persist-after-publish").

9. **Pitfalls to avoid**:
   - **Republish before commit** (the exact inversion the suite must catch) — emitting/observable in-memory state before `db.transaction` returns would acknowledge a review the disk does not hold.
   - **A manual stream poke / second cache** — there is no `_cards` field, no `setState`, no `StreamController` this method pushes to; the committed Drift stream is the single source of truth (T07's `StreamProvider` re-emits on commit).
   - **`DateTime.now()` for "today"** anywhere in the method or a helper.
   - **Re-deriving `due_at`** in the repository instead of persisting the engine's value.
   - **A missing `await`** inside the transaction block.
   - **Swallowing the write error** or marking the page "done"/droppable — the rescheduled card carries the engine's trust-clamped `due_at`, never a drop (C-016).

## Acceptance criteria

- [ ] `card_repository.dart` exists in `packages/data/lib/src/repositories/`; the package builds; `CardRepository` is constructed with the injected `db`, `scheduler`, and `clock` only and constructs no live service itself (verifiable by grep — no `AppDatabase(` / `NativeDatabase(` / `DateTime.now()` in the file).
- [ ] `recordReview(...)` is `async`, takes `{profile, pageId, grade, errorLines, source}`, reads `today` from the injected clock, and opens exactly **one** `db.transaction`.
- [ ] Inside the transaction: the current `Card` is read, `scheduler.onReview(card, grade, errorLines, source, today)` produces the new state, `reviewLogDao.append(result.logRow)` runs **before** `cardDao.upsert(result.card)`, and every query is `await`-ed.
- [ ] The method performs **no** manual republish, holds no second in-memory card cache, and never re-derives `due_at` — the persisted due date is the engine's trust-clamped value (C-016).
- [ ] A persist failure (any query inside the transaction throws) rolls back atomically, propagates to the caller untouched (no `try?`, no bare `catch`), and leaves both the `card` and `review_log` exactly as before the call.
- [ ] No `DateTime.now()`/`Calendar.current`/`TimeZone.current`, no networking import, no audio/ML import anywhere in the file (C-048).
- [ ] Every `public` declaration carries a `///` doc; the single-transaction line carries a why-comment restating the covenant (`// 05 §3 / 04 §4: append review_log + upsert card in ONE transaction, commit before republish`); REUSE SPDX header present.

## Tests

`packages/data/test/repositories/card_repository_test.dart` (mirrors the source name), `flutter_test`/`package:test` as the package requires, run under CI on every PR. The shared bootstrap installs the **throwing `HttpOverrides`** (offline guard) so any stray connection is a loud named failure. The Drift handle is E03's `NativeDatabase.memory()` (or a recording in-memory `CardDao`/`ReviewLogDao` double injected via constructor); `today` is a literal `CalendarDate` from a `FixedClock` (T01) — no wall clock. `Engine.onReview` is the real pure engine (E04) — its arithmetic is golden-tested in E04, here we assert the **write path** around it. Required cases, written **FIRST**:

- **Persist-order proof:** a recording double whose `reviewLogDao.append` / `cardDao.upsert` closure asserts, at call time, that no observable card state has changed yet and that `append` is called strictly before `upsert` — proving persist happens inside the transaction, in order, before any republish.
- **Failed persist never republishes:** a handle wired so a query inside the transaction throws; `expect(() => recordReview(...), throwsA(...))` surfaces E03's sealed error, the transaction rolls back, and a follow-up read shows the `card` and `review_log` byte-equal to their pre-call state (no new log row, no card change).
- **Memory never newer than disk:** after any sequence of successful and failing `recordReview` calls against a `NativeDatabase.memory()` store, a fresh read of the card and the `review_log` count equals exactly what was durably committed — there is no in-memory copy ahead of disk.
- **Persist strictly precedes republish (stream witness):** subscribing to the Today/card Drift stream, the new card value is observed **only after** the `recordReview` `Future` resolves — never before commit.
- **Append-only / engine value persisted:** a successful review appends exactly one `review_log` row (never updates one) and stores the engine's `result.card.dueAt` verbatim (the repository does not re-derive `due_at`); `source: self` round-trips (teacher sign-off is E12).
- **Injected today, no clock read:** with a `FixedClock` for two distinct days, the same `(card, grade, errorLines)` produces the engine's day-relative `due_at` for each — and a grep/analyzer assertion confirms no `DateTime.now()` is reachable from the file.

CI gates unchanged: no new `DateTime.now()`, no networking/audio symbols, no Drift import outside `data`, no `UPDATE`/`DELETE` on `review_log`.

## Definition of Done

- [ ] All acceptance criteria met; the write-path suite is green locally and in CI on every PR; the suite was written and failing **before** the method body existed (test-first).
- [ ] **Single write path / persist-before-republish (non-negotiable):** the grade commits through this one named `CardRepository` method in one `db.transaction` (append `review_log`, upsert card) **before** any stream re-emits; a unit test proves a failed persist never republishes and no code path leaves memory newer than disk (04 §4; 01 §4; 05 §3).
- [ ] **Offline / no-network:** the file imports no `package:http`/`dio`/`dart:io HttpClient`; the test bootstrap installs a throwing `HttpOverrides`; E01's banned-import + allow-list gates stay green (C-048).
- [ ] **No AI / no microphone:** the write path uses no ASR, ML, model, or audio; the review reaches the repository as a human `(grade, errorLines, source)` signal only (C-048).
- [ ] **Quran text fidelity:** the method touches no muṣḥaf glyphs and renders no Quran text; it keys on a `pageId` page card (one of 604 — C-031) and persists the engine's state for that page.
- [ ] **Determinism:** no `DateTime.now()`/`Calendar.current`/`TimeZone.current` reachable from the file; "today" is the injected `CalendarDate` clock, passed to the engine as its last parameter; tests use a `FixedClock`.
- [ ] **RTL + fa/ckb/ar strings:** N/A by construction — the repository holds value types and emits no user-facing string; any failure copy is mapped to the `l10n` ARB files (`ar` template, `fa`/`ckb`) at the feature layer (T08), never hardcoded here.
- [ ] **Accessibility:** N/A by construction — no widget, no rendered element in this task.
- [ ] **Sect-neutral adab / no gamification / nothing safe to drop:** the rescheduled card carries the engine's trust-clamped `due_at` (`min(ideal, ceiling)`, C-016) surfaced honestly — never a streak/score/badge, never a "done"/droppable/"safe to drop" mark; the `review_log` is append-only and nothing implies a madhhab/sect ruling.
- [ ] **No unsourced number:** the persisted `due_at` traces to C-016 (the cycle-ceiling guarantee, computed once in the engine), the page unit to C-031; no CLAIMS id or citation is invented.
- [ ] **Coding standards:** `///` on the public method, full-word/unit-bearing names, `dart format` clean, `dart analyze --fatal-infos` clean, typed `catch` (no bare/swallowed write error), no `print`/`!`/`late` on persistence values, REUSE SPDX header; the change is one concern through the single write path.
