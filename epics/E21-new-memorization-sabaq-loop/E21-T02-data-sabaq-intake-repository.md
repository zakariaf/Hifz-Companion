# E21-T02 — Data: the transactional sabaq-intake write path (`SabaqIntakeRepository`)

| | |
|---|---|
| **Epic** | [E21 — New-Memorization (Sabaq) Loop & Beginner Path](EPIC.md) |
| **Size** | M (≈1 day) |
| **Depends on** | E03 (the `Cards` table + `CardDao`, the single-transaction write discipline, the sealed `PersistenceException`), E21-T01 (the `CardSeed` the engine produces) |
| **Skills** | eng-persist-on-every-change, eng-define-service-boundary, eng-write-dart-test |

## Goal

Give the feature layer the one write path that introduces a newly-memorized page into a profile's schedule, so page-granular sabaq intake is durable and crash-safe like every other mutation. A new `SabaqIntakeRepository.startMemorizing(profileId, seed)` persists the engine's `CardSeed` (from E21-T01) as a single New card in **one `db.transaction`**, refusing a re-mark rather than clobbering a page's live D/S state, resolving only after the durable commit (persist-before-republish). `CardRepository` stays **read-only** — no raw upsert crosses to a widget. Intake is **not** a review, so it appends **no** `review_log` row (the append-only sanad stays a log of recitations); the card's creation is the record. This is the same write path the beginner onboarding (T04), the in-app-profile placement (T05), and the reader/Today surfaces (T06/T07) all call.

## Context & references

| Reference | What to take from it |
|---|---|
| `packages/data/lib/src/repositories/cold_start_repository.dart` | The pattern to mirror: an `abstract interface` + a `Live…` impl over `HifzDatabase`, one outer `db.transaction`, seeds persisted **verbatim** (no D/S/dueAt recompute), typed errors mapped from `SqliteException`/`CouldNotRollBackException`, the Future resolving only after the durable commit |
| `packages/data/lib/src/repositories/review_repository.dart` | The single-write-path discipline (append-only `review_log`, persist-before-republish) — intake reuses the transaction shape but writes **no** log row |
| `packages/data/lib/src/db/daos/card_dao.dart` | `insertAll` (plain `INSERT`, fails a duplicate `(profileId,pageId)`) and `byId` (the existence pre-check) — the two DAO primitives intake composes; no new DAO method needed |
| `packages/data/lib/src/persistence_exception.dart` | The one sealed `PersistenceException`; intake adds a `SabaqIntakeWriteException` subtree (`SabaqPageAlreadyStarted`, `SabaqIntakeFailed`, `SabaqIntakeRollbackFailed`, `SabaqIntakeConstraintViolated`) — never a parallel error type |
| `packages/data/lib/src/persistence_handle.dart`, `live_persistence_handle.dart` | The single injectable seam — add a `SabaqIntakeRepository get sabaqIntake` getter and wire the `Live…` impl; no Drift symbol crosses the interface |
| `docs/PRD.md` §7.8, §7.2 | A newly-memorized page enters the New track; the `Card` schema `CHECK (track != UNMEMORIZED OR due_at NOT NULL)` the seed must satisfy |
| Skill `eng-persist-on-every-change` | Every mutation through one transaction, WAL + `synchronous=FULL`, persist-before-republish, typed errors, append-only log — the covenant this write path joins |

## Implementation notes

**TEST-FIRST** for the write path (a lost or duplicated intake corrupts a profile's schedule).

1. **`packages/data/lib/src/repositories/sabaq_intake_repository.dart`** — `abstract interface class SabaqIntakeRepository { Future<void> startMemorizing(ProfileId, CardSeed); }` + `final class LiveSabaqIntakeRepository`. In one `db.transaction`: `byId` the page; if a card exists, throw `SabaqPageAlreadyStarted` (rethrown clean — an expected refusal, not a failure); else `cardDao.insertAll([card])` (plain INSERT). Map `CouldNotRollBackException → SabaqIntakeRollbackFailed`, `SqliteException → SabaqIntakeConstraintViolated`, other `Exception → SabaqIntakeFailed`. No `review_log` write.
2. **Exceptions** — add the `SabaqIntakeWriteException` sealed subtree to `persistence_exception.dart`.
3. **Handle** — add `SabaqIntakeRepository get sabaqIntake` to `PersistenceHandle`; construct `LiveSabaqIntakeRepository(database)` in `LivePersistenceHandle` (covers the in-memory test double, which wraps it).
4. **Barrel** — export the interface + the four exceptions from `package:data/data.dart`.
5. **Design note (deviation from the epic's aspirational text):** the epic floated "append a provenance `review_log` row"; on implementation this is **dropped** — `review_log` is the append-only sanad of *recitation grades*, and a non-grade intake row would pollute the progress history and the backup merge. The card's creation (with `lastReviewedDay = today`) is the intake record.
6. **Pitfalls:** exposing a card write on `CardRepository`; upserting (clobbering a live card) instead of plain-INSERT; recomputing D/S/dueAt in the data layer; writing a `review_log` row; mapping `SabaqPageAlreadyStarted` to a generic failure; leaking a Drift symbol across the handle.

## Acceptance criteria

- [ ] `SabaqIntakeRepository.startMemorizing(profileId, seed)` persists one New card in one transaction, verbatim (no D/S/dueAt recompute), resolving only after the durable commit; `CardRepository` is unchanged (read-only).
- [ ] A re-mark of a page that already has a card throws `SabaqPageAlreadyStarted` and leaves the existing card's D/S/due **untouched** (never a clobber).
- [ ] A malformed seed (e.g. a New card with a null due day) rolls the transaction back to zero new rows and throws a `SabaqIntakeWriteException`; the sealed subtree is exported and mapped exhaustively.
- [ ] Intake writes **no** `review_log` row; the `sabaqIntake` getter is on `PersistenceHandle` and wired in `LivePersistenceHandle`; no Drift symbol crosses the interface.

## Tests

`packages/data/test/repositories/sabaq_intake_repository_test.dart` (in-memory `HifzDatabase`, FK ON, a **zero-card** profile — the from-zero beginner / F04 state — seeded via `seedColdStart(profile, cycle, const [])`):
- happy path: starting a page commits exactly one New card, due today, with the seed's `(D, S)` verbatim;
- re-mark refusal: a second `startMemorizing` on the same page throws `SabaqPageAlreadyStarted`; the card count stays 1 and the original prior is unchanged;
- rollback: a null-due New seed throws `SabaqIntakeConstraintViolated` and leaves zero cards;
- no-sanad-pollution: after intake the `review_log` is empty;
- durability: the committed card is readable on disk over the same connection.

## Definition of Done

- [ ] All acceptance criteria met; the write-path test was written first and is green; `flutter analyze packages/data` is clean and the full `data` suite passes; downstream (`composition`, `features`) still analyzes (the added interface getter breaks no consumer).
- [ ] **Single write path / persist-before-republish:** one `db.transaction`, the Future resolves after the durable commit, the controller republishes strictly after; `CardRepository` exposes no write; no widget upserts a card.
- [ ] **No phantom data / append-only sanad:** intake creates exactly one auditable card row and writes nothing to `review_log`; a re-mark is refused, never a silent overwrite.
- [ ] **Consume-not-recompute:** the engine's conservative prior is persisted verbatim; no D/S/dueAt math in the data layer (the trust clamp is the only sink).
- [ ] **Offline / boundary:** no Drift/sqlite symbol crosses `PersistenceHandle`; the offline test policy is installed; nothing opens a socket.
- [ ] **Adab:** the failure/refusal types carry developer-facing messages only (UI copy is localized at the feature layer); `SabaqPageAlreadyStarted` is a calm expected case, never a guilt path.
- [ ] **Deterministic tests:** in-memory store, `CalendarDate` literals, no clock, no network; all gates stay green.
