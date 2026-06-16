# E12-T06 — Grading pipeline (test-first): ReviewInput normalizer, sacred-text cap, source confidence, review_log append, onReview hand-off

| | |
|---|---|
| **Epic** | [E12 — Today & Recite/Grade](EPIC.md) |
| **Size** | L (≈3-4 days) |
| **Depends on** | E04, E07 |
| **Skills** | domain-grading-pipeline, eng-write-engine-golden-vector, eng-add-persisted-model, eng-write-dart-test |

## Goal

The normalization layer that turns the recite flow's taps into **exactly one** `ReviewInput(grade, errorLines, source, missedOrAlteredWord)` and hands it to the engine through the single write path — built **test-first**. A pure `RecitationGrading` normalizer maps the stumble count to a *suggested* (user-confirmable) grade, caps the normalized grade at `Grade.hard` whenever `missedOrAlteredWord` is set (the sacred-text guard, R1) **before the `ReviewInput` is emitted**, tags `source` (self → `kSelfConfidence ≈ 0.5` / teacher → `1.0`) by name, and carries `errorLines` at full strength regardless of source. The repository's single write path (`recordReview`) then appends `(grade, error_lines, source)` to the **append-only** `review_log` and calls `SchedulingEngine.onReview(card, review, today)` in one transaction, persist-before-republish. A `glados` property proves a dropped/altered word is **never** graded `Good`/`Easy`. This task computes no `due_at`, reads no clock, runs no stability math, and touches no microphone/audio.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §8 (8.1–8.3) | Two sources, one normalized signal `(grade, error_lines, source)`; reveal-on-tap → mark stumbles → *suggested* grade (user-confirmable); self `sourceConfidence ≈ 0.5` (cannot reach the top tier alone); teacher `1.0`, authoritative, appended to `review_log` with `source = teacher`; **no microphone / no audio / no STT / no mistake-detection** (§8.3) |
| `docs/PRD.md` §6.3 | The one 4-level scale for all sources (Again/Hard/Good/Easy) + optional **error positions**; "a grade is never just a number — *where* you stumbled is the most valuable signal" — this layer carries `errorLines` at full strength |
| `docs/PRD.md` §12.2 | The recite-flow contract this pipeline terminates: page hidden → recite → reveal-on-tap → mark stumble lines → grade → next; this task owns only the **normalize + persist + hand-off** tail, not the masked-page UI (E12-T07) |
| `docs/engineering/06-scheduling-engine.md` §2 | The exact `ReviewInput { Grade grade; List<int> errorLines; Source source; bool missedOrAlteredWord; }` shape and the `Source { self_, teacher }` / `Grade { again, hard, good, easy }` enums this normalizer constructs (value types in `engine/`, no persistence concern) |
| `docs/engineering/06-scheduling-engine.md` §4 | The engine re-asserts the same guards (`grade = missedOrAlteredWord && grade.index > hard ? hard : grade`; `conf = teacher ? 1.0 : kSelfConfidence`; `errorLines` applied at **full strength regardless of source**, only the S-magnitude is confidence-scaled); `Card onReview(Card, ReviewInput, SerialDay today)` is the hand-off seam — this task **emits the input**, it does not redo the arithmetic |
| `docs/engineering/05-persistence-and-encryption.md` §2, §3 | The `review_log` table (`grade`, `error_lines_json`, `source`, optional `teacher_label`, `reviewed_at` UTC instant, `elapsed_days` `CalendarDate`-serial delta) and the canonical `commitReview` transaction: **append the audit row FIRST**, then upsert the card, all-await-ed, `synchronous=FULL`, persist-before-republish; **no `UPDATE`/`DELETE` DAO on `review_log`** |
| `docs/engineering/04-flutter-and-state-patterns.md` §1.3, §4 | The verbatim single-write-path `recordReview({profile, pageId, grade, errorLines, source})` repository method + the `TodayController.grade(...)` command the recite View binds to; the write commits **before** the Drift `StreamProvider` re-emits (no manual republish, no optimistic UI) — this task extends `recordReview` to carry `missedOrAlteredWord` |
| Skill `domain-grading-pipeline` (+ `template.dart`) | The whole canonical pattern: reveal-after-attempt → stumble lines → *suggested* grade; the **sacred-text cap in this layer before emit** (Pattern 3); `source`/`kSelfConfidence` referenced by name, never inlined (Pattern 4); teacher = same shape, authoritative (Pattern 5); `errorLines` at full strength (Pattern 9); **one** `ReviewInput`, append-only `review_log`, hand to `onReview` — no `due_at`, no clock, no stability math here (Pattern 8); no mic / no celebration (Pattern 10) |
| Skill `eng-write-engine-golden-vector` (+ `template.dart`) | INV-3 (`Again ⇒ S'≤S ∧ track'≤track`) and INV-5 (a teacher `Again` overrides a prior self `Good`) as `glados` properties over generated `(Card, grades, today)` histories; the **sacred-text-cap property** ("a `missedOrAlteredWord` review never yields `Good`/`Easy`") as the §7.12-touching invariant this task pins; constants by name (`kSelfConfidence`), `today` as a `SerialDay` literal, never a clock |
| Skill `eng-add-persisted-model` (+ `template.dart`) | The `review_log` append: the DAO exposes **only** an `append`/insert (no `UPDATE`/`DELETE`); `error_lines_json` holds small decode-validated data; `reviewed_at`/`created_at` are UTC instants, `elapsed_days` is a `CalendarDate`-serial integer; no Drift symbol crosses the `data` boundary; one `db.transaction`, await every query, persist-before-republish |
| Skill `eng-write-dart-test` (+ `template.dart`) | Tier placement: the normalizer + invariants are **pure `package:test`/`glados` on `engine/`** (not a widget pump); the repository round-trip is a `flutter_test` DAO test on an in-memory Drift db; the throwing `HttpOverrides` offline guard; `closeTo(_,1e-6)` for any float; the grading covenants (dropped word never "Good", teacher supersedes self) are asserted, never just covered |
| `docs/science/CLAIMS.md` — **C-018** | Recite-from-memory (reveal-on-tap) protects hifz far more than re-reading ([MA]/[EXP]); the *reason* the normalizer grades a real recall attempt, not a re-read — relevant if any in-flow microcopy this task supplies frames the grade |
| `docs/science/CLAIMS.md` — **C-021**, **C-038**, **C-046** | A teacher who hears and corrects strengthens more than self-rating (`1.0` vs `≈0.5`), teacher overrides self + algorithm ([MA]/[TRAD], C-021); talaqqī/sanad is first-class and the app is *servant*, never authority (C-038, C-046) — the adab behind `source = teacher` being authoritative and appended, never silently overridden |
| `docs/science/CLAIMS.md` — **C-003**, **C-033** | A single stumble is **not** a lost page (a lapse localizes the error, never fails the whole page — C-003 [EXP]); page-level grade + line-level error positions (C-033 [EXP]) — the framing the suggested-grade mapping and `errorLines` must honor (calm, "a located weak join", never failure) |
| Sibling **E12-T07** | Owns the masked reader page, reveal-on-tap, the ≥48dp stumble hit-areas (coordinate overlay), the disabled-until-revealed grade band, and the undo affordance; it **collects** `(stumbleLineCount, errorLines, missedOrAlteredWord, grade)` and calls this task's normalizer/command — it does not normalize or persist |
| Sibling **E12-T08** | Owns the "Teacher present" `Switch.adaptive` source switch and the teacher-sourced marker; it flips `source` from `self` to `teacher` on the `ReviewInput` this task normalizes and writes — the override/authoritative semantics live here, the toggle UI lives there |
| Sibling **E12-T02** | The Today read model is a `StreamProvider` over a Drift query; the review this task commits re-emits that stream (the **only** refresh mechanism) — this task adds the write, T02 already wired the reactive read |
| Sibling **E12-T09** | Consumes this normalizer + write path inside the cold-start → `buildToday` → grade → next → catch-up integration journey on the real Drift/SQLite stack |
| Skills (out of scope here) **E04 scheduling-engine** | Owns the `onReview` arithmetic (S/D update, source-confidence S-scaling, trust clamp, tracks) that *consumes* the `ReviewInput`; this task produces the input and asserts the cap, it never redoes the math |

## Implementation notes

**TEST-FIRST.** This is the single most consequential input the engine receives and it carries the sacred-text guard, so the normalizer's unit table and the `glados` sacred-text-cap / teacher-override properties are **written first and must fail** before `RecitationGrading` and the extended `recordReview` exist. Place the deterministic logic at the cheapest tier (pure `engine/` `package:test` + `glados`); only the `review_log` round-trip is a Drift test.

1. **The normalizer is a pure value-in/value-out function in `engine/`** (domain-grading-pipeline Pattern 8; eng-write-engine-golden-vector §1). Add `packages/engine/lib/src/grading/recitation_grading.dart`:
   ```dart
   /// Normalizes a recite-flow verdict into ONE ReviewInput. Pure: no I/O, no clock,
   /// no stability math. The sacred-text cap is applied HERE, before the input is emitted.
   ReviewInput normalize({
     required Grade grade,            // the user-confirmed grade (suggested from stumbles, then confirmed)
     required List<int> errorLines,   // 1-based stumble lines; full strength regardless of source
     required Source source,          // self_ | teacher
     required bool missedOrAlteredWord,
   }) {
     final capped = missedOrAlteredWord && grade.index > Grade.hard.index ? Grade.hard : grade;
     return ReviewInput(
       grade: capped, errorLines: List.unmodifiable(errorLines),
       source: source, missedOrAlteredWord: missedOrAlteredWord,
     );
   }
   ```
   It imports only the `engine/` value types (`Grade`, `Source`, `ReviewInput` from §2). No Flutter, no Riverpod, no Drift, no `DateTime`. `errorLines` is wrapped unmodifiable and **never** down-weighted or dropped (Pattern 9).
2. **Stumble count → suggested grade is a separate pure function, user-confirmable** (domain-grading-pipeline Pattern 2; PRD §8.1). Add `Grade suggestGradeFromStumbles(int stumbleLineCount, {required int pageLineCount})` (a small monotone mapping: 0 → `good`/`easy` band, a few → `hard`, many/major-break → `again`). It only *suggests* — the View shows it pre-selected and the user confirms; it is **not** auto-committed. Pin the exact thresholds in the unit table below so a reordering off-by-one fails CI. The cap in step 1 still applies after confirmation: a low stumble count plus `missedOrAlteredWord` can never emit `Good`/`Easy`.
3. **Source confidence is referenced by name, never inlined** (domain-grading-pipeline Pattern 4). This layer sets `source = Source.self_` or `Source.teacher`; the weight `kSelfConfidence` (0.5) / teacher `1.0` is the engine's named constant and is applied **inside** `onReview` (S-magnitude scaling), not here. Do not write `0.5`/`1.0` at any call site in this task.
4. **The write rides the existing single write path — extend, don't fork** (04-flutter §4; eng-add-persisted-model). Extend the repository's `recordReview` (in `packages/data/`) to accept `required bool missedOrAlteredWord` and build the `ReviewInput` via `normalize(...)`:
   ```dart
   Future<void> recordReview({
     required ProfileId profile, required int pageId,
     required Grade grade, required List<int> errorLines,
     required Source source, required bool missedOrAlteredWord,
   }) async {
     final today = clock.today();                       // CalendarDate, injected — never DateTime.now()
     final review = normalize(grade: grade, errorLines: errorLines,
         source: source, missedOrAlteredWord: missedOrAlteredWord);
     await db.transaction(() async {                    // one review = one transaction (05 §3)
       final card = await db.cardDao.byKey(profile, pageId);
       final result = scheduler.onReview(card, review, today);   // hand-off — engine does the math
       await db.reviewLogDao.append(result.logRow);     // append-only audit row FIRST
       await db.cardDao.upsert(result.card);            // then the new card state
     });
     // No manual republish: the Today StreamProvider (T02) re-emits on commit.
   }
   ```
   Every query inside the transaction is `await`-ed (the Drift await footgun — a release-blocking item). The `review_log` row records `grade` (the **capped** grade), `error_lines_json`, `source`, optional `teacher_label`, `reviewed_at` (UTC instant), and `elapsed_days` (`CalendarDate`-serial delta) — the `logRow` is built by the engine result / DAO, not by the View.
5. **`review_log` is append-only** (eng-add-persisted-model Pattern 6). `reviewLogDao` exposes `append`/insert only — **no** `update`/`delete` method exists (enforced by absence, reviewed in CI). A teacher sign-off (`source = teacher`) is a *new appended row*, never an in-place edit of a prior self-grade row; the teacher verdict overrides by being the latest authoritative review the engine consumes, not by mutating history (C-021, R6).
6. **The controller command threads `missedOrAlteredWord` through** (04-flutter §1.3). Extend `TodayController.grade(...)` (the command E12-T07's band binds to) to pass `missedOrAlteredWord` and `source` down to `recordReview`. The controller does **not** normalize or cap — it forwards; the cap lives in `normalize` so it holds for every caller (recite band, teacher sign-off, the integration journey). No `DateTime.now()` in the controller; "today" enters only via the injected `clockProvider` inside the repository.
7. **No `due_at`, no clock, no stability math in this layer** (domain-grading-pipeline Pattern 8). The normalizer and the command never compute an interval, read `R`, or set `dueAt`; the engine's `onReview` owns all of it. A grep over `packages/engine/lib/src/grading/` and the new repository code finds no `retrievability`/`interval`/`trustClamp`/`dueAt =` call and no `DateTime.now()`.
8. **Pitfalls to avoid:**
   - Emitting a `Good`/`Easy` `ReviewInput` while `missedOrAlteredWord == true` (the cap must run **before** emit, not only in the engine).
   - Inlining `0.5`/`1.0` for source confidence anywhere in this task.
   - Down-weighting, truncating, or dropping a self-reported `errorLines` (it is full-strength graph data — Pattern 9).
   - An `UPDATE`/`DELETE` on `review_log`, or "fixing" a prior self-grade row when a teacher signs off (append a new row instead).
   - A missing `await` inside the `db.transaction` (data-loss footgun), or republishing before the commit returns (optimistic UI).
   - Computing an interval / reading the clock / setting `dueAt` in the normalizer or command.
   - Auto-committing a grade with no confirm step, or grading before stumble lines are markable.
   - Any microphone, recording, ASR, on-device model, or HTTP reachable from this path; any streak/badge/score/confetti/success-haptic on a `Good` (a logged grade is a calm receipt).
   - A `DateTime` stored as a scheduling day (`elapsed_days` is a `CalendarDate`-serial integer; `reviewed_at` is a UTC instant).

## Acceptance criteria

- [ ] `packages/engine/lib/src/grading/recitation_grading.dart` exists with a pure `normalize(...)` returning exactly one `ReviewInput`; it imports only `engine/` value types — no Flutter, Riverpod, Drift, `dart:io`, or `DateTime` (verifiable by grep).
- [ ] `normalize` caps the grade at `Grade.hard` whenever `missedOrAlteredWord == true` **and** the incoming grade is `Good`/`Easy`; it leaves `Again`/`Hard` unchanged; the `ReviewInput` is never emitted with a `Good`/`Easy` + `missedOrAlteredWord`.
- [ ] `suggestGradeFromStumbles(...)` is pure, monotone, and only *suggests*; its thresholds are pinned by the unit table; nothing auto-commits a grade without a confirm step.
- [ ] `source` is set to `Source.self_` or `Source.teacher`; the confidence weight is **never** inlined as `0.5`/`1.0` in this task — `kSelfConfidence` and the teacher `1.0` live as the engine's named constants and are applied inside `onReview`.
- [ ] `errorLines` is carried at full strength regardless of source (wrapped `List.unmodifiable`, never down-weighted, truncated, or dropped).
- [ ] `recordReview(...)` is extended to accept `missedOrAlteredWord`, builds the `ReviewInput` via `normalize`, and in **one** `db.transaction` appends the `review_log` row **first** then upserts the card, with every query `await`-ed; it reads "today" only via the injected `clock`; it persists before the Drift stream re-emits (no manual republish).
- [ ] `reviewLogDao` exposes only `append`/insert — no `update`/`delete` method exists; a teacher sign-off appends a new `source = teacher` row, never edits a prior row (verifiable by grep + DAO surface review).
- [ ] No `retrievability`/`interval`/`trustClamp`/`dueAt =` call and no `DateTime.now()` appears in `packages/engine/lib/src/grading/` or the new repository/command code (verifiable by grep); the engine's `onReview` owns all scheduling math.
- [ ] No microphone/audio/ASR/model/HTTP reference is reachable from this path; no streak/badge/score/confetti/success-haptic is introduced.
- [ ] Every public declaration carries a `///` doc comment; the cap line carries a why-comment (intent: R1 sacred-text guard); `dart format` + analyzer clean; REUSE SPDX header on every new file.

## Tests

All deterministic and offline by construction (a throwing `HttpOverrides` in the shared bootstrap; only the asset-downloader test opts out). The normalizer + invariants run as pure `package:test`/`glados` on `engine/` with `today` as a `SerialDay` literal; the round-trip is a `flutter_test` DAO test on an in-memory Drift db. **Written first; red before green.**

- `packages/engine/test/grading/recitation_grading_test.dart` (`package:test`, **written first**):
  - **Sacred-text cap table** — for `missedOrAlteredWord = true`: `Good → Hard`, `Easy → Hard`, `Hard → Hard`, `Again → Again`; for `missedOrAlteredWord = false`: every grade passes through unchanged. One row per case.
  - **Suggested-grade mapping** — the pinned `stumbleLineCount → Grade` thresholds (0 stumbles → clean band; few → `hard`; many/major-break → `again`), asserted as exact rows; monotone (more stumbles never suggests a *better* grade).
  - **Source tagging** — `source` round-trips `self_`/`teacher` untouched; no `0.5`/`1.0` literal appears in the file.
  - **errorLines full strength** — a self-sourced `errorLines:[3,7]` is present and unmodified on the emitted `ReviewInput`; the returned list is unmodifiable.
- `packages/engine/test/grading/grading_invariants_test.dart` (`package:glados`, **written first**) — properties over generated `(Card, grade-sequence, today)` histories via `any.scheduleCase`, shrinking relied on, no fixed lucky seed:
  - **Sacred-text-cap property (R1)** — for every generated review with `missedOrAlteredWord == true`, the `ReviewInput` the normalizer emits has `grade.index ≤ Grade.hard.index`; equivalently, **a dropped/altered word is never `Good`/`Easy`** (the property names the covenant in a comment).
  - **INV-3** — for any history, `Again ⇒ S' ≤ S ∧ track' ≤ track` after `onReview` (a lapse demotes; the cap feeds it).
  - **INV-5 (teacher overrides self)** — a teacher `Again` on a page after a prior self `Good` leaves the page in the demoted/weak state the teacher verdict implies; a self grade never overrides a later teacher verdict.
- `packages/data/test/review_log_dao_test.dart` (`flutter_test`, in-memory Drift):
  - **Append-only** — `reviewLogDao` has `append` but **no** `update`/`delete`; two reviews on one page produce **two** rows (a teacher sign-off after a self-grade appends, never edits); a `PRAGMA integrity_check` passes.
  - **Round-trip** — the persisted `review_log` row carries the **capped** `grade`, `error_lines_json` decoding back to the exact `errorLines`, `source`, optional `teacher_label`, a UTC `reviewed_at` instant, and an integer `CalendarDate`-serial `elapsed_days`.
- `packages/data/test/record_review_write_path_test.dart` (`flutter_test`, in-memory Drift + an `engine` `Scheduler` + a `FixedClock(CalendarDate(...))`):
  - **Persist-before-republish** — within `recordReview`, the `review_log` row is appended before the card upsert, and the call commits before any observer is notified; a recording double proves no republish precedes the commit.
  - **Cap rides the write path** — `recordReview(grade: Good, missedOrAlteredWord: true, …)` persists a `review_log` row with `grade = hard` and the resulting card reflects a capped (non-`Good`) update.
  - **Teacher override end-to-end** — a self `Good` then a teacher `Again` on the same page yields two appended rows and a card the teacher verdict demoted; the self row is untouched.
  - **No clock leak** — the test uses the injected `FixedClock`; a grep asserts no `DateTime.now()` in the write path.
- Offline guard: the whole suite runs under the throwing `HttpOverrides` (eng-write-dart-test §8); the cold-start → `buildToday` → grade → next → catch-up integration journey that also exercises this path lives in **E12-T09**.

## Definition of Done

- [ ] All acceptance criteria met; the normalizer unit table, the `glados` sacred-text-cap / INV-3 / INV-5 properties, and the write-path tests were **written first** and are green; engine tests run under `dart test`, DAO/write-path under `flutter test`, all gates green.
- [ ] **Offline / no-network**: no surface in this task opens a socket; the `HttpOverrides` offline guard passes; the only inputs are taps normalized into a value object.
- [ ] **No AI / no audio / no microphone**: no recording, no speech-to-text, no on-device model, no mistake-detection anywhere in the normalize or write path (C2, R5, PRD §8.3); correctness is a human verdict.
- [ ] **Quran text fidelity (R1) — the sacred-text guard**: a dropped/added/swapped word sets `missedOrAlteredWord` and caps the normalized grade at `Grade.hard` **in this layer before the `ReviewInput` is emitted**; a `glados` property proves a dropped word is never `Good`/`Easy`; this layer renders/re-typesets no āyah (it normalizes taps only).
- [ ] **Servant to the teacher (R6)**: a teacher sign-off is the **same** `ReviewInput` shape with `source = teacher` (conf `1.0`), is authoritative, overrides self-rating + algorithmic state, and is **appended** to `review_log` as a new row — never a silent overwrite of a prior self-grade; the verdict persists before the stream republishes (C-021, C-038, C-046).
- [ ] **Append-only audit / single write path**: the review commits in one `db.transaction` (audit row first, card upsert second, all `await`-ed, `synchronous=FULL`), persist-before-republish; `review_log` has no `UPDATE`/`DELETE` DAO method; no second cache, no optimistic UI.
- [ ] **Determinism**: no `due_at`, no clock, no stability math in this layer; "today" is the injected `CalendarDate`; `elapsed_days` is a `CalendarDate`-serial integer (never a `DateTime` instant); engine tests construct `today` as a `SerialDay` literal; any float asserted `closeTo(_, 1e-6)`.
- [ ] **No gamification / no shame (R3, C6)**: a logged grade is a calm receipt — no streak, badge, score, confetti, or success-haptic on any grade or sign-off; a single stumble is framed as a located weak join, never a failed page (C-003).
- [ ] **RTL + fa/ckb/ar localization**: this task adds no rendered Quran text and no new screen, but any suggested-grade verb label or in-flow microcopy it supplies is an ARB key in fa/ckb/ar via the swappable verb set (Again/Hard/Good/Easy → localized verbs, PRD §6.3), bidi-safe, sect-neutral — no hardcoded user-facing string (the grade band UI itself is E12-T07).
- [ ] **Accessibility**: N/A for rendered chrome here (the band/toggle a11y lives in E12-T07/T08); the normalizer carries no UI — but the value object it emits must not encode any guilt/streak/score that a downstream `Semantics` label could surface.
- [ ] **Sect-neutral adab**: the teacher-authoritative, servant-to-the-sanad semantics and any grade-framing copy cleared the adab conscience pass — no fiqh ruling, no app-as-authority phrasing, calm and autonomy-supportive (C-021, C-038, C-046, R6).
- [ ] **Tests**: the sacred-text-cap and teacher-override covenants are property-tested, not example-covered; coverage is published, never gated; REUSE SPDX headers present; `dart format` clean; deterministic, offline, on the injected clock.
</content>
</invoke>
