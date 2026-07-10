# E17-T06 — Shell restore: separately-confirmed replace + merge (set-union by logId) in one Drift transaction, re-clamp, cross-muṣḥaf refusal

| | |
|---|---|
| **Epic** | [E17 — Backup & Restore](EPIC.md) |
| **Size** | L (≈2-3 days) |
| **Depends on** | E17-T03, E03, E04 |
| **Skills** | domain-backup-format, eng-create-riverpod-store, domain-scheduling-engine-rules, eng-write-dart-test |

## Goal

The shell-side restore controller: two **explicit, separately-confirmed** import modes over the validated `BackupSnapshot` the T01–T05 `backup/` façade returns. **Replace** (full restore) validates the file entirely in memory first — the live store is untouched through parse, so a corrupt file or wrong passphrase loses nothing — then, in ONE Drift transaction, deletes the in-scope user rows, inserts the snapshot's rows verbatim (UUIDs preserved), and recomputes every imported card's `dueAt` through the E04 engine's trust clamp. **Merge** (the teacher↔student transfer, PRD §16) runs one transaction that upserts profile metadata by `profileId` (conflicts surfaced, never a silent rename), set-unions the append-only `review_log` by `logId` (insert absent rows, skip present ones — never update or delete), unions `line_block` (`errorCount` max) and `confusion_edge` (`weight` summed-then-capped, `lastConfusedAt` max), then rebuilds each touched card **from the merged log** via the engine and re-applies the trust clamp; `cycle_config` is local-wins on merge. Both modes refuse a cross-`mushaf_id`/checksum import with a clear typed error, never coercing. The controller persists transactionally **before** republishing in-memory state. This task owns the orchestration and the controller methods only: it CALLS E04's recompute + clamp (builds no arithmetic), rides E03's `db.transaction` + DAOs (adds no schema), imports T01–T05's parse/crypto (builds no bytes), and supplies the methods the T08 confirmation widgets call (builds no UI).

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/10-backup-format.md` §7 | The normative spec this task implements verbatim: two explicit, separately-confirmed modes; the per-entity merge-resolution table (reproduced in note 4 below); the merge algorithm (`_assertSameMushaf` → upsert profile → union log/blocks/edges → `_recomputeCardsFromLog`); the replace flow steps (validate-in-memory → wipe-and-insert-verbatim → re-clamp → notifications post-commit); the distinct confirmation copy semantics; every "we refuse" (no log overwrite, no blind `dueAt` copy, no silent cross-muṣḥaf merge, no partial import) |
| `docs/engineering/10-backup-format.md` §1, §3 | The boundary: this controller receives an already-validated `BackupSnapshot` — the container/JSON/crypto parse order and its distinct `BackupError`s are T02/T03/T05's; `backup/` is store-blind, so all DB reads/writes happen here, through `/data` |
| `docs/engineering/05-persistence-and-encryption.md` §2 | `review_log` is the append-only *sanad* audit trail; **no DAO exposes `UPDATE` or `DELETE` against it** — the structural guarantee that the union cannot mutate a row; backup/restore is the only sanctioned bulk path that touches it |
| `docs/engineering/05-persistence-and-encryption.md` §3 | One `db.transaction` per mutation, atomic with automatic rollback on throw; **every query inside the transaction must be `await`-ed** (the release-blocking footgun); persist-before-publish — state is republished only after the write Future resolves |
| `docs/PRD.md` §7.6 | The trust clamp — `card.due_at = min(ideal_due, ceiling_due)` — recomputed after import under the **receiving** device's cycle config; SR may only pull a page forward |
| `docs/PRD.md` §7.12 | The invariants restore must not break: `due_at` never later than the cycle ceiling; FAR/manzil due items never silently dropped; never "safe to stop revising"; teacher sign-off supersedes; identical inputs → identical schedule |
| `docs/PRD.md` §10.3, §16 | `review_log` append-only (never updated/deleted by normal flows); the card/roll-ups are computed, never a stored authority — why the card is rebuilt from the merged log; the verbatim merge/replace requirement and the teacher-transfer path (export → user moves file → import) |
| Skill `domain-backup-format` (+ `template.dart`) | Patterns 13–14: replace/merge each in one transaction, separately confirmed; merge = content-addressed set union by `logId`, idempotent, no duplicate sign-off; card rebuilt from merged log; re-clamp to **this** device's ceiling; cross-muṣḥaf refusal — plus the checklist rows this task must tick |
| Skill `eng-create-riverpod-store` | The controller shape: an app-scope `AsyncNotifier` wired at the composition root; every mutation persists transactionally *before* republishing; injected `CalendarDate` clock — no `DateTime.now()` in shell logic |
| Skill `domain-scheduling-engine-rules` | The clamp and the D/S recompute are the engine's — this task calls `recomputeFromLog`-style E04 APIs and never re-derives interval math; the engine stays pure (the controller feeds it the merged log + injected today) |
| Skill `eng-write-dart-test` | The deterministic harness: seeded property tests (seed logged on failure), in-memory Drift database fixtures, the `HttpOverrides` offline guard |
| Sibling **E17-T01/T02/T03** | Supply `BackupSnapshot`/`BackupError` and `HifzBackup.import` — parse, integrity, schema-migration failures are typed *before* this controller runs; a `newerFormat`/`malformedPayload` file never reaches a transaction |
| Sibling **E17-T05** | The encrypted path: decryption happens inside `HifzBackup.import` (off-UI isolate); `wrongPasswordOrDamaged` is resolved before the restore methods are ever called |
| Sibling **E17-T07** | Owns the export & erase orchestration and the injected file/share boundaries — the other half of the shell; this task shares its controller conventions, not its flows |
| Sibling **E17-T08** | Renders the replace-vs-merge confirmation widgets and all user-facing copy (ARB, fa/ckb/ar); this task exposes the two distinct methods + typed results those widgets call and map to localized strings |
| Cross-epic **E03 / E04** | E03 owns the Drift schema, DAOs, and the transaction primitive (this task adds **no** table/column/index); E04 owns the recompute + trust-clamp arithmetic and its golden vectors (this task adds **no** engine math) |

## Implementation notes

The transaction bodies live in `/data` (the only code that sees Drift) as repository methods `replaceImport(BackupSnapshot, scope)` and `mergeImport(BackupSnapshot)`; a Riverpod restore controller in the shell orchestrates parse → confirm → repository call → republish. Test-first on the merge/idempotence/clamp invariants — they are the *sanad*-critical core.

1. **Two entry points, never one method with a mode flag.** The controller exposes `applyReplace(snapshot)` and `applyMerge(snapshot)` as distinct methods (plus a `parseBackupFile(bytes, {passphrase})` that delegates to `HifzBackup.import` off the UI isolate). T08's two separate confirmations map 1:1 onto them; there is no default mode and no path that picks one silently (10 §7: "explicit, separately-confirmed").
2. **Cross-muṣḥaf gate first, inside both transactions.** The first awaited statement of both repository methods asserts the snapshot's `mushaf {id, checksumSha256}` matches the local `mushaf` reference row; mismatch throws a typed refusal (e.g. `RestoreRefusal.mushafMismatch`) → automatic rollback, zero rows written. Never coerce, never offer to "convert" — cards index a layout-specific page space (R2).
3. **Replace = validate-in-memory → wipe → insert verbatim → re-clamp, all-or-nothing.** Parse/validation completes entirely in memory before any repository call (10 §7 replace step 1). Then one `db.transaction`: delete the in-scope user rows (`profile`, `cycle_config`, `card`, `line_block`, `review_log`, `confusion_edge` for the chosen scope — reference tables never touched), insert the snapshot's rows verbatim with UUIDs preserved, then recompute every imported card's `dueAt` via the engine trust clamp *inside the same transaction* (mirroring the §7 merge pseudocode's in-transaction `_recomputeCardsFromLog`) — so no commit point ever exists where a card's `dueAt` exceeds the local ceiling. Notification re-scheduling from `cycle_config` happens post-commit through the injected scheduler boundary, never inside the transaction.
4. **Merge = the §7 resolution table, verbatim.** Reproduced here as the binding rules; do not re-derive them:

   | Entity | Key | Rule |
   |---|---|---|
   | `profile` | `profileId` (UUID) | New id ⇒ insert. Existing id ⇒ keep local mutable fields unless the import is newer by `createdAt`+settings; **never silently rename**; conflicts surfaced to the user as a typed result, not auto-resolved |
   | `review_log` | `logId` (UUID) | **Set union.** Insert rows whose `logId` is absent; skip rows already present (idempotent). Existing rows **never** updated or deleted |
   | `card` | `(profileId, pageId)` | Last-review-wins by max `reviewedAt` across the *unioned* log, then the engine rebuilds D/S/`dueAt` from the merged log — the card is a cache of the log, rebuilt, never blindly copied |
   | `line_block` | `(profileId, pageId, lineStart, lineEnd)` | Union; `errorCount` = max (weak-spot evidence only accumulates) |
   | `confusion_edge` | `(profileId, ayahA, ayahB)` | Union; `weight` summed-then-capped; `lastConfusedAt` = max |
   | `cycle_config` | `profileId` | **Local wins on merge** (the device owner's chosen cycle); replace overwrites it |

5. **The log union is insert-if-absent by `logId` — never `insertOnConflictUpdate`.** An upsert against `review_log` would mutate a *sanad* row; the DAO exposes no `UPDATE`/`DELETE` (05 §2), so implement the union as a `logId`-membership check + batched plain inserts. A teacher's sign-off already present is skipped, never duplicated.
6. **The card is rebuilt, never imported as authority.** After the union, call E04's recompute-from-log for each touched `(profileId, pageId)` with the injected `CalendarDate` today and the *local* `cycle_config`; the trust clamp (`min(SR-ideal, cycle ceiling)`, PRD §7.6) is the engine's — this task passes inputs and writes the returned card state, nothing more.
7. **Persist-before-republish.** The controller republishes providers/streams (and lets T08 show success) only after the repository Future resolves — a crash between commit and republish loses UI freshness, never data. No optimistic state.
8. **Await discipline.** Every query inside both transaction bodies is `await`-ed (05 §3's release-blocking footgun); the batched log insert uses `db.batch` inside the outer transaction.
9. **No user-facing string ships from this task.** Typed results/refusals (`mushafMismatch`, profile-conflict, success-with-counts) are enums/values T08 maps to ARB keys; this task introduces no copy, no number, no claim — **CLAIMS: none**.
10. **Pitfalls to avoid:** a single `import(mode:)` method (kills the separate confirmations); validating replace against the store instead of in memory; deleting or upserting a `review_log` row; recomputing D/S in the shell (engine's job); copying an imported `dueAt` without re-clamping; keying profiles by `displayName` instead of `profileId`; touching a reference table; splitting a mode across two transactions; `DateTime.now()` anywhere in the path; republishing or confirming success before commit; letting a `newerFormat`/`malformedPayload`/`wrongPasswordOrDamaged` file reach a repository method.

## Acceptance criteria

- [ ] `applyReplace` and `applyMerge` are two distinct, separately-invoked controller methods; no shared mode flag, no default; parse (`HifzBackup.import`, off-UI) completes and returns a validated `BackupSnapshot` before either can run.
- [ ] Replace: the live store is untouched until the snapshot is fully validated in memory; then one Drift transaction deletes the in-scope user rows, inserts the snapshot's rows verbatim (every UUID preserved), and re-clamps every imported card — reference tables are never written.
- [ ] Merge: one Drift transaction applies exactly the note-4 resolution table — profile upsert by `profileId` with conflicts surfaced (never a silent rename), `review_log` set-union by `logId`, `line_block`/`confusion_edge` unions, each touched card rebuilt from the merged log via E04, `cycle_config` local-wins.
- [ ] No `UPDATE` or `DELETE` is ever issued against `review_log` in either mode (the DAO exposes none; a grep over the repository methods and a recording-executor test both confirm).
- [ ] After either mode, every imported card's `dueAt ≤` the receiving device's cycle ceiling (PRD §7.6/§7.12), computed by the engine with the injected `CalendarDate` — never arithmetic in the shell.
- [ ] A snapshot whose `mushaf` `{id, checksumSha256}` differs from the local muṣḥaf is refused with a typed error in both modes, with zero rows written (transaction rolled back).
- [ ] Merge is idempotent: applying the same file twice leaves the store identical to applying it once; no teacher sign-off is duplicated; no pre-existing log row is changed.
- [ ] On any throw mid-import (either mode), the live store is byte-identical to its pre-import state (Drift auto-rollback); in-memory state is republished only after commit, and success is surfaced only post-commit.
- [ ] This task adds no Drift table/column/index, no engine math, no widget, and no user-facing string (typed results only, mapped by T08).

## Tests

All deterministic, offline by construction: an in-memory Drift database (E03's schema), seeded fixtures, the injected `CalendarDate` — never a real clock; property tests use a seeded generator (seed logged on failure). Written first for the merge/clamp/rollback invariants.

- `data/test/backup/restore_merge_test.dart` — **written first**: the union inserts absent `logId`s and skips present ones; the note-4 rules per entity (profile conflict surfaced not auto-resolved; `errorCount` max; `weight` summed-then-capped + `lastConfusedAt` max; `cycle_config` local-wins); no `UPDATE`/`DELETE` reaches `review_log` (recording query executor asserts statement kinds).
- `data/test/backup/restore_merge_properties_test.dart` — merge idempotence: `merge(merge(∅,f),f) == merge(∅,f)` over generated multi-profile histories; merge superset: student log ∪ teacher's superset = teacher's superset — no duplicated sign-off, no pre-existing row deleted or mutated (byte-compare of prior rows).
- `data/test/backup/restore_replace_test.dart` — replace wipes exactly the in-scope user rows, inserts verbatim (UUIDs preserved), never touches a reference table; a snapshot that fails validation leaves the store untouched (validate-in-memory-first).
- `data/test/backup/restore_trust_clamp_test.dart` — export under a long cycle, import (both modes) under a shorter local `cycle_config` ⇒ every imported `dueAt ≤` the local ceiling; the recompute is the engine's (a fake engine records the calls; the shell computes nothing).
- `data/test/backup/restore_cross_mushaf_test.dart` — a mismatched `mushaf_id`/checksum snapshot ⇒ the typed refusal in both modes, zero rows written.
- `data/test/backup/restore_crash_mid_import_test.dart` — an injected throw mid-transaction (both modes) ⇒ the live store is byte-identical to before (full-table dump compare; Drift auto-rollback).
- `features/test/backup/restore_controller_test.dart` — two distinct entry points (no mode flag); persist-before-republish ordering (a recording repository + provider listener prove commit precedes republish); a `BackupError` from parse never reaches a repository method; runs under the `HttpOverrides` offline guard (eng-write-dart-test).

## Definition of Done

- [ ] All acceptance criteria met; the merge/clamp/rollback tests were written first and are green in CI.
- [ ] **Offline / no-network**: the restore path opens no socket — bytes come from the T07/T08 file-pick, parse is pure `backup/`, writes are local Drift; the `HttpOverrides` offline guard passes (C1, PRD §17).
- [ ] **No AI / no microphone**: restore is a deterministic re-application of stored truth; nothing records, infers, or scores (C2, R5).
- [ ] **Quran text fidelity (R1/R2)**: no Quran bytes enter or leave — the snapshot carries only `mushaf {id, riwayah, name, checksumSha256}`; reference tables are never written; a cross-muṣḥaf import is refused with a clear message, never coerced.
- [ ] **The append-only `review_log` is honored**: merge is a content-addressed set-union by `logId` — idempotent, no row updated or deleted, no teacher sign-off duplicated or dropped (PRD §10.3; 05 §2); the *sanad* trail survives transfer intact.
- [ ] **Never "safe to drop" / trust clamp survives transfer (§7.6, §7.12)**: every imported card is rebuilt from the (merged) log and re-clamped under the receiving device's cycle ceiling — an imported page can never end up due past the local cycle, FAR/manzil items are never dropped by import, and nothing in this task's results implies a page is safe to stop revising.
- [ ] **All-or-nothing**: each mode is one Drift transaction with automatic rollback; a crash mid-import leaves the live store byte-identical; replace validates fully in memory before touching the store.
- [ ] **No gamification / no shame (R3)**: restore emits plain typed results (counts, conflicts, refusals) — no celebration, no streak, no guilt framing anywhere in the surfaced semantics (copy itself is T08's, adab-reviewed there).
- [ ] **Single write path / dumb View**: all writes flow through the two `/data` repository methods; the controller persists transactionally before republishing; no widget mutates state; no `DateTime.now()` — the engine recompute uses the injected `CalendarDate`.
- [ ] **RTL + fa/ckb/ar**: this task ships zero user-facing strings; every typed result/refusal is an enum/value T08 maps to ARB keys in fa/ckb/ar — nothing here can leak an unlocalized message.
- [ ] **Accessibility**: no UI is introduced; the typed results are structured so T08 can announce them via `Semantics` (one result = one announceable outcome).
- [ ] **Deterministic tests**: seeded generators, in-memory Drift fixtures, injected clock, fake engine where the arithmetic is not under test; all gates (banned-import over `backup/`, no-network, analyzer) stay green.
