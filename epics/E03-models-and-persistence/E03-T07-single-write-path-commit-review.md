# E03-T07 — The single write path: commitReview one-transaction persist-before-republish + a thrown-step rollback unit test (test-first)

| | |
|---|---|
| **Epic** | [E03 — Models & Persistence](EPIC.md) |
| **Size** | L (≈2-4 days) |
| **Depends on** | E03-T04, E03-T06 |
| **Skills** | eng-add-persisted-model, eng-add-drift-table-or-migration, eng-define-service-boundary, eng-write-dart-test |

## Goal

`ReviewRepository.commitReview(ReviewOutcome)` exists in `packages/data/lib/src/repositories/review_repository.dart` as the single write path for one review: it opens **exactly one** `db.transaction`, `await`s every query inside it, appends the immutable `review_log` row, upserts the `card` (D/S/`due_at`/flags/reps/lapses), conditionally inserts `line_block` rows and bumps `confusion_edge` weights, and the returned `Future` resolves **only after** the durable WAL commit — persist-before-republish, so no code path leaves memory newer than disk. A thrown step inside the transaction rolls back fully, commits nothing, and republishes nothing; a sealed persistence error type is surfaced (typed `catch`, no swallowed write error, no `print` of user data). The engine's `ReviewOutcome` is **consumed**, never recomputed — E04 owns the D/S/`due_at` math; this method only persists it. The test is written **first**: the thrown-step rollback unit fails before the method body exists.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/05-persistence-and-encryption.md` §3 (Crash safety) | The authoritative contract: one `db.transaction` per review; WAL + `synchronous=FULL` on the write connection (a *sanad* sign-off must survive power loss, so not `NORMAL`); the canonical `commitReview(ReviewOutcome r)` body in order — (1) append the `review_log` row, (2) update the `card` (D/S/`due_at`/flags/reps/lapses), (3) lazily insert `line_block`s if any, (4) bump `confusion_edge` weights via `insertOnConflictUpdate`; "When this Future completes, every row above is durably on disk … republishes state only AFTER this returns — persist-before-publish." The **await footgun** ("All queries inside the transaction must be `await`-ed … without `await`, some queries might be operating on the transaction after it has been closed → data loss"); "We refuse persist-after-publish"; `CouldNotRollBackException` is logged locally (never transmitted), the store treated as needing recovery, never swallowed |
| `docs/engineering/01-architecture-overview.md` §4 (Unidirectional data flow: one review, end to end) | The lifecycle steps 3–6: the repository is the single source of truth and the only place a `Card` is modified; step 4 calls the **pure** engine (`onReview`) with an injected `today` — no I/O there; step 5 commits the `ReviewLog` row + the `Card` upsert in ONE WAL transaction *before* any state republishes; step 6 republishes only after the commit succeeds; "We refuse 'republish then persist'"; "We refuse a second `due_at` computation anywhere" — `due_at` is produced only by the engine's trust clamp, one sink, one truth |
| `docs/engineering/05-persistence-and-encryption.md` §2 (Schema) | The row shapes this transaction writes: `review_log` is append-only (`INSERT` only — this method never `UPDATE`/`DELETE`s it); `card`'s `CHECK (track='UNMEMORIZED' OR due_at IS NOT NULL)` and range `CHECK`s a malformed `ReviewOutcome` must trip rather than silently store; `due_at`/`last_review_at` are `CalendarDate` serial-day integers, `reviewed_at` UTC; `confusion_edge` canonical `ayah_a < ayah_b`; no derived health is written |
| Skill `eng-add-persisted-model` (canonical pattern 7, 10; `template.dart` repository block) | "Read/write is reached only through a repository method that opens ONE `db.transaction` and commits before republishing"; every query `await`-ed; the engine stays Drift-free and total; throwing is confined to the `data` boundary — one sealed error type, typed `catch`, no swallowed write-path error, no `print`/logging of user data, no `!`/`late` on persistence values; a sign-off is acknowledged only after the commit resolves |
| Skill `eng-add-drift-table-or-migration` (canonical pattern 6, 7; `template.dart` `commitReview` body) | "One `db.transaction` per review; persist before publish; await every query"; WAL + `synchronous=FULL` + `foreign_keys=ON` re-asserted on every open (E03-T04 owns the pragmas this method relies on); `review_log` is `INSERT`-only; the repository `Future` resolves only after the durable commit |
| Skill `eng-define-service-boundary` (canonical pattern 7, 8) | "Mutating boundaries persist through the single write path — one Drift transaction, commit before republish, never called raw from a widget/controller"; the persistence handle (E03-T05) is the injected boundary this repository wraps; IO failure surfaces as a calm typed failure (user copy authored at the feature layer in fa/ckb/ar, never inside this method); a *sanad* act is never acknowledged before durable commit |
| Skill `eng-write-dart-test` (canonical pattern 1, 2, 3, 8, 9) | The rollback unit is a pure `dart test` over an in-memory `NativeDatabase.memory()` store (no `flutter_test`, no widget binding); `today`/days are literal `CalendarDate`s, no wall clock; assert behaviour (no commit, no republish) not lines; the throwing-`HttpOverrides` offline bootstrap is installed so a stray network call fails loudly; the real Drift/SQLite stack here is exercised at the DAO/repository unit tier, not a device journey |
| `docs/PRD.md` §7.7 (onReview outputs), §7.12 (engine invariants persisted), §10.3 (append-only audit / computed-not-stored health), §17 (privacy) | §7.7 names the several writes one review produces (audit row, card update, optional line-blocks, optional confusion bumps) — the reason a review is one atomic transaction; §7.12 the engine invariants whose *outputs* are persisted here, never recomputed; §10.3 `review_log` append-only and health computed-not-stored; §17 no PII/telemetry leaves the device — this method logs no user data |
| CLAIMS ids | **None.** `commitReview` renders no on-screen number, date, or copy — it persists value types. The "next due" date a feature later shows is the engine's `due_at` read back from `card` (no second computation here); any verdict/term-set label a `review_log` field maps to lives in `l10n`, owned by the feature epics. No claim ships from this method |
| Siblings: E03-T04, E03-T05, E03-T06, E03-T08, E04 | E03-T04 supplies the WAL/`synchronous=FULL`/`foreign_keys=ON` pragmas (re-asserted per open) this transaction's durability and FK enforcement depend on. E03-T05 supplies the injected persistence `Provider`/interface and the in-memory `NativeDatabase.memory()` + `FixedClock` doubles this test installs. E03-T06 supplies the append-only `review_log` DAO (no `UPDATE`/`DELETE`) and the `card`/`line_block`/`confusion_edge` DAOs whose row mappings this method composes (and the value→row→value round-trips it builds on). E03-T08 reuses this transaction discipline for the `seedColdStart` outer transaction (a sibling, not this task). **E04** owns the pure `onReview`/trust-clamp arithmetic that produces the `ReviewOutcome` this method writes — consumed, never recomputed |

## Implementation notes

**TEST-FIRST (correctness-critical).** Write `review_repository_rollback_test.dart`'s thrown-step case (and the persist-before-republish ordering case) **before** the `commitReview` body. The rollback test must compile and **fail** (red) against a stub/unimplemented `commitReview` first; only then implement the body to turn it green. This is a *sanad*-audit write path — an all-or-nothing guarantee proven by a failing test before the code exists is the whole point.

1. **File**: `packages/data/lib/src/repositories/review_repository.dart`, one primary type per file — `ReviewRepository`. It wraps the injected Drift handle from E03-T05 (the `data`-package interface over `HifzDatabase`, reached as a constructor dependency / `ref.watch`ed `Provider`, never a global singleton). It depends on `models` and the E03-T06 DAOs; `package:drift`/`package:sqlite3` stay confined to `data` — no Drift symbol crosses into `engine`/`features`/`quran`. Re-export from the package barrel `packages/data/lib/data.dart`.

2. **`ReviewOutcome` is the engine's output DTO, consumed not recomputed.** Its shape mirrors engineering 05 §3: the immutable `review_log` row to append, the `card` field-set to upsert (D/S/`due_at`/flags/reps/lapses), the optional `line_block` rows to insert, and the optional `confusion_edge` bumps. It is a `models`-level value type (or composed of them) carrying `CalendarDate` `dueAt`/`lastReviewedDay` and a UTC `reviewedAtInstant` — `commitReview` does **no** D/S/`due_at` arithmetic. If the `ReviewOutcome` value type does not yet exist in `models`, it is owned by the engine I/O DTO set (E04 / E03-T01's record family); resolve it as a typed dependency, do not re-derive a `due_at` here. The single sink for `due_at` is the engine's trust clamp (01 §4); this method only persists what it is handed.

3. **The transaction body — one `db.transaction`, every query `await`-ed, in the §3 order**:
   ```dart
   // packages/data/lib/src/repositories/review_repository.dart — data sees drift; features await this.
   Future<void> commitReview(ReviewOutcome outcome) async {
     try {
       await _db.transaction(() async {
         // 1. APPEND the immutable audit row (never updated/deleted — sanad trail).
         await _reviewLogDao.append(outcome.logRow);            // await — the footgun
         // 2. UPSERT the card's engine state (D, S, due_at, flags, reps, lapses).
         await _cardDao.upsert(outcome.cardUpdate);             // await
         // 3. LAZILY insert line-blocks for a repeatedly-lapsing page (if any).
         if (outcome.newLineBlocks.isNotEmpty) {
           await _lineBlockDao.insertAll(outcome.newLineBlocks); // await
         }
         // 4. BUMP mutashābihāt confusion edges (if a wrong-branch stumble occurred).
         for (final bump in outcome.confusionBumps) {
           await _confusionEdgeDao.insertOnConflictUpdate(bump); // await
         }
       });
     } on CouldNotRollBackException catch (error) {
       // Even the ROLLBACK failed: surface as recovery-needed, log locally only, never transmit.
       throw const ReviewWriteError.rollbackFailed();           // map, do not swallow
     } on DriftRemoteException catch (error) {
       throw const ReviewWriteError.transactionFailed();        // typed, no bare catch
     }
   }
   // When this Future resolves, every row is durably on disk (synchronous=FULL).
   // The controller (E07) republishes ONLY AFTER this returns — persist-before-publish.
   ```
   Every query inside `transaction(() async` is `await`-ed (the §3 footgun: an un-awaited query can run after the transaction closes → data loss). There is no debounce, no deferred/"save later" write, no second transaction — a review is one atomic unit. The method does not `print`/`debugPrint` the `ReviewOutcome` or any row (no logging of user data, §17).

4. **`review_log` is `INSERT`-only here.** `commitReview` calls the DAO's `append` only; it never `UPDATE`s or `DELETE`s a `review_log` row (the DAO exposes no such method — E03-T06). The card upsert and the confusion-edge `insertOnConflictUpdate` are the only mutating writes; the audit trail is purely additive.

5. **Sealed persistence error type — one type, typed `catch`, never swallowed.** Define one sealed `ReviewWriteError` (e.g. a sealed class / `freezed` union with `transactionFailed`, `rollbackFailed`, `constraintViolated` cases) in `packages/data/lib/src/repositories/`, surfaced to the feature layer to handle exhaustively. Map Drift's `CouldNotRollBackException` and constraint/`DriftRemoteException` failures to it; every `catch` is typed (`on … catch (e)`, never bare `catch (_)`); no write error is swallowed and no sign-off is acknowledged before the commit resolves. User-facing copy is **not** authored here — the feature layer renders a calm retry in fa/ckb/ar (E03-T05 boundary rule; eng-define-service-boundary §8). The engine stays total and Drift-free; throwing is confined to this I/O boundary.

6. **Persist-before-republish is structural, not optional.** This method returns `Future<void>` and resolves only after the durable commit; the Riverpod controller (E07) republishes in-memory state strictly after the awaited `commitReview` completes. This task ships the repository method and its units only — the controller/`Notifier` wiring that *calls* it is E07 (eng-create-riverpod-store). Do not republish, emit a stream value, or flip a UI flag inside `commitReview`.

7. **Determinism / clock.** `commitReview` reads no wall clock — `reviewedAtInstant` (UTC) and the `CalendarDate` days arrive inside the `ReviewOutcome` (the injected `Clock`/today entered upstream at the feature layer, E03-T05). The method never calls `DateTime.now()`. Tests inject the days as literal `CalendarDate`s.

8. **Pitfalls to avoid**: a missing `await` inside `transaction(() async` (the release-blocking footgun — the rollback test and a grep audit catch it); splitting the review across two transactions (loses atomicity); republishing/optimistic UI before the commit resolves (a window where the UI shows a review the disk does not hold — fatal for a *sanad* act); recomputing `due_at`/D/S anywhere in this method (the engine is the only sink — 01 §4); an `UPDATE`/`DELETE` against `review_log` (append-only breach); a bare `catch (_)` or a swallowed write error; `print`/`debugPrint`ing the outcome or a row (no user-data logging, §17); a Drift `Companion`/`TableInfo` escaping `data`; persisting a derived health/streak/score; `synchronous=NORMAL` assumptions (the write connection is `FULL`, E03-T04).

## Acceptance criteria

- [ ] `commitReview(ReviewOutcome)` exists in `packages/data/lib/src/repositories/review_repository.dart`, re-exported from `packages/data/lib/data.dart`; it opens **exactly one** `db.transaction` and `await`s every query inside it (verifiable by reading the body + a grep audit of `transaction(() async` blocks for un-awaited calls).
- [ ] Inside the one transaction, in order: the `review_log` row is appended (`INSERT` only), the `card` is upserted (D/S/`due_at`/flags/reps/lapses), `line_block` rows are inserted iff present, and `confusion_edge` weights are bumped via `insertOnConflictUpdate` iff present.
- [ ] The returned `Future` resolves only after the durable commit; the method republishes nothing, emits no stream value, and flips no UI state (persist-before-republish; republish is the E07 controller's job, after the await).
- [ ] A thrown step inside the transaction rolls back fully — **no** `review_log` row, **no** `card` change, **no** `line_block`/`confusion_edge` write is committed — and the method surfaces a sealed `ReviewWriteError` (no partial write, no swallowed error).
- [ ] No `due_at`/D/S arithmetic occurs in `commitReview` — the `ReviewOutcome` from the engine (E04) is persisted verbatim (the trust clamp is the only `due_at` sink; this method does not recompute it).
- [ ] `commitReview` performs no `UPDATE`/`DELETE` against `review_log`; it calls the DAO's append only (append-only audit preserved).
- [ ] One sealed `ReviewWriteError` type is defined and surfaced; every `catch` is typed (`on … catch`), no write error is swallowed, no `print`/`debugPrint` of the outcome or any row; no `!`/`late` on a persistence value.
- [ ] No `package:drift`/`package:sqlite3` symbol crosses the `data` boundary out of this method; it reads no wall clock (`DateTime.now()` absent); WAL + `synchronous=FULL` (E03-T04) are relied on, not weakened.
- [ ] `dart analyze --fatal-infos` and `dart format --set-exit-if-changed` clean; `///` doc on the public method (the persist-before-republish intent stated as a why-comment); CI green.

## Tests

All tests are pure `dart test` under `packages/data/test/repositories/`, run against an in-memory `NativeDatabase.memory()` store (E03-T05's double) with a `FixedClock` and literal `CalendarDate`s — no `flutter_test`, no widget binding, no wall clock. Each file carries the REUSE SPDX `GPL-3.0-or-later` header, uses full-word/unit-bearing names, typed `catch`, and asserts behaviour (commit/republish state) not lines. The shared throwing-`HttpOverrides` offline bootstrap is installed so any stray network call fails loudly. Required file and cases (the rollback + ordering cases written **first**, red before the body):

- `review_repository_rollback_test.dart`
  - **Thrown-step rolls back fully (written first)**: a `ReviewOutcome` whose step 2 (card upsert) is forced to throw — e.g. a constraint-violating `cardUpdate` that trips the `card` `CHECK`, or an injected DAO that throws on the second await. Assert: after the call, the store holds **no** new `review_log` row, the `card` is byte-equal to its pre-call state, and **no** `line_block`/`confusion_edge` write landed — all-or-nothing. Assert the method throws the sealed `ReviewWriteError`, not a raw Drift exception, and republishes nothing.
  - **Persist-before-republish ordering (written first)**: a recording DAO/handle whose `append`/`upsert` closure asserts, at call time, that no observable in-memory republish has occurred yet — proving the commit precedes any republish (the controller's republish is out of scope here; the method itself emits nothing mid-transaction).
  - **Happy path is exactly one transaction, all rows present**: a full `ReviewOutcome` (audit row + card update + one `line_block` + one `confusion_edge` bump) commits; after the awaited call the store holds the appended `review_log` row, the upserted `card` (D/S/`due_at`/flags/reps/lapses match the outcome verbatim — no recomputation), the `line_block`, and the bumped edge. A read-back `due_at` equals the `ReviewOutcome.dueAt` exactly (CalendarDate-serial identity), proving consume-not-recompute.
  - **Append-only**: the `review_log` DAO surface reachable from this path exposes no `UPDATE`/`DELETE` (enforced by absence — assert the happy path only appended, and a second `commitReview` for the same page adds a new row rather than mutating the first).
  - **Empty optionals are no-ops**: an outcome with no `line_block`s and no `confusion_edge` bumps commits the audit row + card upsert only, writing neither optional table.
  - **Memory never newer than disk**: after any sequence of successful and failing `commitReview` calls, the store's `card`/`review_log` content equals exactly what the successful commits wrote — a failed call leaves the store at its last-committed state.

No golden, widget, or `integration_test` is in scope — this is a `data`-tier write-path unit. The end-to-end recite → grade → commit journey on a device is E12; the muṣḥaf/RTL goldens belong to the feature epics.

## Definition of Done

- [ ] All acceptance criteria met; `dart test` green for `packages/data/`; the rollback + ordering cases were committed red (failing against the unimplemented method) before the body, per test-first; `dart analyze --fatal-infos` and `dart format --set-exit-if-changed` clean; CI green.
- [ ] **Crash-safe single write path (non-negotiable)**: every review persists in exactly one `db.transaction` that commits *before* any state republishes; a unit proves a thrown step rolls back fully and publishes nothing — no code path leaves memory newer than disk; a teacher sign-off is never acknowledged before its durable commit (engineering 05 §3; 01 §4).
- [ ] **Offline / no-network**: `review_repository.dart` imports no networking package and no `dart:io HttpClient`; tests install the throwing `HttpOverrides`; no telemetry, no account, no per-user data leaves the device; `commitReview` logs no user data (§17).
- [ ] **No-AI / no-microphone**: the method references no audio, microphone, recognizer, or ML/AI artifact; it persists a `(grade, error_lines, source)` signal the engine produced — `source` is only `self`/`teacher`, never an inferred score.
- [ ] **Quran text fidelity**: the transaction writes no reference (`page`/`line`/`ayah`/`surah`/`mushaf`/`mutashabih_*`) table — those are read-only by construction; `error_lines_json` holds line indices only, never Quran text; no runtime write can re-typeset or alter the sacred text (R1).
- [ ] **RTL + fa/ckb/ar strings**: no user-facing string is authored in this method — error copy is mapped to a sealed `ReviewWriteError` and rendered as a calm retry in `l10n` (`ar` template, `fa`/`ckb`), RTL via `Directionality`, at the feature layer; the repository carries only value/enum data.
- [ ] **Accessibility**: N/A by construction (no widget, no rendered surface) — a11y labels for any displayed result are the owning feature's responsibility, not this `data`-tier method.
- [ ] **Sect-neutral adab**: the write path encodes no streak/badge/score/confetti, no "safe to drop" flag, no fiqh ruling, no tafsīr/translation, no sect/madhhab marker; `signoffs`/the `review_log` are a *sanad* audit trail, never a gamified tally; a sign-off is durably committed before it is ever acknowledged.
- [ ] **Deterministic tests**: every test is pure `dart test`, constructs days as literal `CalendarDate`s and instants as explicit UTC `DateTime`s (no `DateTime.now()`, no wall clock), asserts commit/rollback behaviour with full-word names and typed `catch`, carries the REUSE SPDX header, and is reproducible across machines and timezones.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
