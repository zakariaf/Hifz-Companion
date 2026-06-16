# E14-T05 — Seed expandMutashabihat: due-member pulls siblings into the same session, never spaced — test-first

| | |
|---|---|
| **Epic** | [E14 — Mutashābihāt Trainer](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E14-T01, E04 |
| **Skills** | domain-mutashabihat-system, domain-scheduling-engine-rules, eng-write-engine-golden-vector |

## Goal

Inside the pure-Dart `engine/` package, the `expandMutashabihat(...)` hook E04 left as a seam in `buildToday` is seeded with the bundled confusables dataset so that **when any confusable-group member is due, ALL of its siblings are pulled into the SAME `buildToday` session, adjacent (back-to-back), and never spaced across days**. This is the one place the engine *adds* a not-yet-due card — additive massed contrast, never a dropped review, never a re-ordered manzil item, never a spacing decision. The function stays a pure, deterministic function of `(cards, today, dataset)` with no clock, no RNG, no I/O. Authored **test-first**: a `glados` property asserting that for every generated card set with at least one due group member, every sibling of that member co-occurs in the same plan adjacent to it — written and **failing** before the seam is filled.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §9.2 (behavior 1) | "Discrimination interleaving: when a page in a group is due, its sibling(s) are pulled into the **same session** back-to-back so the brain practices telling them apart (massed contrast cures interference; spacing them apart worsens it)" — the exact end-state this task implements |
| `docs/engineering/06-scheduling-engine.md` §7 | The `buildToday` body and where `expandMutashabihat(...)` already sits: `farToday = expandMutashabihat(sortByWeakestR([...cycleSlice, ...pullFwd], rOf))`; "Interference is cured by massing, not spacing … the one place the engine *adds* a not-yet-due card — additive contrast, never a dropped review"; the pitfall "We refuse to space mutashābihāt siblings apart … the queue assembler pulls linked pages together even if not individually due"; manzil stays mandatory and recitation order (manzil → near → new) is preserved |
| `docs/science/05-interference-and-mutashabihat.md` §5 | The discriminative-contrast result (Kornell & Bjork 2008; Birnbaum et al. 2013; Carvalho & Goldstone 2014): the benefit comes from **temporal juxtaposition** of confusable items; spacing that *interrupts* the juxtaposition removes it — so siblings must be adjacent in one session, not merely both present |
| `docs/science/05-interference-and-mutashabihat.md` §7 | The group set is the bundled, scholar-reviewed static dataset (E14-T01) — no runtime inference of "similar verses"; this task consumes that dataset as a read-only prior and computes nothing about similarity itself |
| Skill `domain-mutashabihat-system` (+ `template.dart`) | Rule 3 (whole-group, never one sibling alone), Rule 4 (`expandMutashabihat` pulls due-siblings into the **same** `buildToday` plan back-to-back — the deliberate exception to the spacing rule), Rule 9 (RTL/offline/deterministic: no `DateTime.now()`, no `Random`, `today` injected); the Do/Don't "Pull siblings into the **same** session via `expandMutashabihat(...)`" / "Don't let ordinary due-date logic surface siblings on different days" |
| Skill `domain-scheduling-engine-rules` | Rule 19 (manzil un-skippable; recitation order manzil → near → new), Rule 20 ("Interference is cured by massing, not spacing — `expandMutashabihat` pulls confusable siblings into the *same* session back-to-back … additive contrast, never a dropped review; never space siblings apart"); the engine is pure Dart, zero I/O, `today` injected as a `SerialDay`; **no second/parallel "interference scheduler"** — this is policy layered on the one `buildToday` path |
| Skill `eng-write-engine-golden-vector` (+ `template.dart`) | The test artifact this task delivers: a `glados` property over generated `(cards, today)` histories under `engine/test/`, importing `package:test` + `package:glados` only (no `flutter_test`, no widget binding, no network); `today` a constructed `SerialDay` literal; encode the rule as a universal `∀` property with shrinking; reference constants by name; this is the §7 sibling-massing analogue of the INV register |
| `docs/science/CLAIMS.md` C-028 | "To stop confusing two similar passages, practice them back-to-back so you can tell them apart" → "When any group member is due, its sibling(s) are pulled into the **same session**, adjacent, for discrimination; spacing siblings apart is resisted" `[EXP]`. This task implements C-028's behavior; it renders **no** user-facing number or string, so it cites C-028 only as provenance and invents no new claim |
| Siblings: E14-T01, E14-T04, E04 | **E14-T01** loads the `mutashabih_group`/`mutashabih_member` dataset into read-only reference tables — this task consumes the in-engine projection of that dataset (the group→members map), not the Drift tables themselves. **E04** owns `buildToday`/`loadBalance`/the trust clamp/the `expandMutashabihat` seam *mechanism* — this task only seeds the seam, adding no second scheduler. **E14-T04** is the orthogonal interference channel (a swap bumps `D` on every member via `(11−D)`); massing (this task) and the `D` bump (T04) are independent and must not be conflated. The drill UI that renders the massed siblings is E14-T08 (not this task) |

## Implementation notes

**TEST-FIRST:** write the sibling-massing property and the adjacency/no-spacing cases in `## Tests` below **before** filling the seam. The "every sibling of a due member co-occurs adjacent in the same plan" property and the "siblings are never split across two days" property must exist and **fail** before `expandMutashabihat` has a real body.

1. **Where it lives — the engine, not the UI or the DB.** `expandMutashabihat(...)` is a pure function in the `engine/` package (e.g. `engine/lib/src/build_today.dart`, beside `buildToday`). It takes the already-ordered FAR slice (`[...cycleSlice, ...pullFwd]` sorted weakest-R-first, per 06 §7) and the confusables map, and returns an expanded ordered list. It imports no Flutter, opens no DB, reads no clock — `today` arrives as a `SerialDay`, the dataset arrives as an in-memory immutable map injected through `EngineConfig` (or a parameter), never read from Drift inside `engine/`.

2. **The dataset projection the engine consumes.** E14-T01 owns the read-only `mutashabih_group`/`mutashabih_member` tables; this task consumes a *pure in-memory projection* of them — a `MutashabihGroups` value type that answers "which group(s) is page/ayah X in, and who are its siblings" by integer id only. Define it (or accept E14-T01's already-defined value type) as an immutable map keyed by the engine's scheduling key (`pageId`), with each group a set of sibling page ids. The engine never parses JSON, never touches `distinguishing_word_index_json` (that is anchor-overlay data for E14-T09, irrelevant to massing), and never queries similarity at runtime — it reads a static, bundled prior.

   ```dart
   /// Immutable in-engine projection of the bundled confusables dataset (E14-T01):
   /// for each scheduling key, the set of sibling keys in its mutashābihāt group(s).
   /// Pure data — no Drift symbol, no JSON, no similarity computation at runtime.
   class MutashabihGroups {
     const MutashabihGroups(this._siblingsByPage);
     final Map<int, Set<int>> _siblingsByPage; // pageId -> sibling pageIds (excl. self)
     Set<int> siblingsOf(int pageId) => _siblingsByPage[pageId] ?? const {};
   }
   ```

3. **The massing rule (the whole task).** Walk the ordered FAR slice. For every card whose page is a member of a confusable group, gather all its siblings from `MutashabihGroups`; any sibling **not already in the slice** is materialized as an *additive* card and **inserted adjacent to its due member** (immediately after it), so the group recites back-to-back. A sibling already in the slice is **moved to sit adjacent** to the triggering member (not duplicated). The result is one ordered list where each confusable group's members are contiguous. Massing is **additive only** — it never removes, defers, or re-prioritizes a manzil/cycle item; the un-skippable manzil set and the manzil → near → new recitation order are preserved (06 §7; engine Rule 19).

4. **Additive, never a dropped review; never a spacing decision.** This is the single exception to the spacing rule and it only ever *adds* a not-yet-due sibling into *today*. It must not:
   - drop, defer, or push out any already-scheduled card to make room (overflow is the load balancer's calm-banner job, 06 §7 — not this function's),
   - place a sibling on a *different* day, a later session, or behind a spacing interval (that is the exact bug C-028/§5 forbid),
   - touch `D`/`S`/`dueAt`/`due_at` or call `onReview` (the `D` bump is E14-T04; this function changes no card's schedule state — a materialized sibling is a *session* inclusion, not a graded review).

5. **Materializing a not-yet-due sibling.** A sibling pulled in is a session entry, not a new persisted/graded card. Represent it the way `buildToday` already represents a planned item (the same `Card`/plan-item type the rest of the FAR slice uses) so the downstream `loadBalance` and recitation ordering treat it uniformly; tag it (if the plan-item type carries provenance) as massing-induced only if E04's `DayPlan` already exposes such a field — do **not** add a new field speculatively. The sibling's own `dueAt` is untouched; its ordinary schedule still owns its real next-due date. Pulling it into today does not reset, satisfy, or advance that schedule.

6. **Determinism and idempotence.** Given the same `(slice, today, groups)`, `expandMutashabihat` returns a byte-identical ordered list (no `Random`, no clock, stable iteration over the sets — sort sibling ids for a deterministic adjacency order). Applying it twice to its own output is a no-op (siblings already adjacent stay put) — assert this so a future refactor cannot make it grow the plan on re-entry. This preserves the engine's `buildToday`-determinism invariant (INV-4 in the golden-vector register).

7. **Group membership uses the engine's page key, consistently.** Massing is computed on the scheduling key (`pageId`) that `buildToday` already orders on — siblings are co-scheduled *as pages* (the recited unit), matching the page-card model (06 §2). Do not introduce an ayah-level second granularity here; the ayah-level `distinguishing_word_index_json` is overlay data for the drill (E14-T09), not a scheduling key.

8. **Pitfalls to avoid:**
   - **Spacing siblings across days** — surfacing a sibling on its own next-due date instead of massing it today; the property in `## Tests` must catch this directly.
   - **Pulling one sibling but not the rest of the group** — the whole group must co-occur (Rule 3); a group of three where only two land is a bug.
   - **A dropped/deferred manzil item** to "make room" for a materialized sibling — massing is purely additive; manzil stays mandatory (Rule 19), overflow is the balancer's banner.
   - **Duplicating a sibling** already present in the slice instead of moving it adjacent.
   - **Mutating schedule state** — bumping `D`/`S` or advancing `dueAt` when a sibling is massed (that conflates this with E14-T04 and corrupts the schedule).
   - **Reading Drift / `DateTime.now()` / `Random` inside `engine/`** — the dataset is an injected immutable map, `today` is an injected `SerialDay`, ordering is deterministic.
   - **A second, parallel "interference scheduler"** — massing is one helper inside the single `buildToday` path; it adds no new façade method and no bespoke frequency override.

## Acceptance criteria

- [ ] `expandMutashabihat(...)` is a pure function in `engine/`, taking the ordered FAR slice, the injected `today` (`SerialDay`), and an immutable in-memory confusables projection; it imports no Flutter, opens no DB, and reads no `DateTime.now()`/`Random` (verifiable by grep + the engine banned-import gate).
- [ ] When any card in the FAR slice is a member of a confusable group, **every** sibling in that group appears in the returned plan for the **same** `today`, **adjacent** (contiguous) to the triggering member — the whole group recites back-to-back.
- [ ] A sibling not already in the slice is **added** (additive contrast); a sibling already present is **moved adjacent**, never duplicated; no group member is left out.
- [ ] Massing is additive only: it removes, defers, or re-prioritizes **no** already-scheduled item; the un-skippable manzil set and the manzil → near → new recitation order are preserved; overflow remains the load balancer's calm-banner concern.
- [ ] A massed sibling's own `dueAt`/schedule state is untouched — no `D`/`S`/`dueAt` mutation, no `onReview` call; pulling it into today neither resets nor satisfies its real next-due date.
- [ ] Siblings are **never** placed on a different day or behind a spacing interval; there is no code path that surfaces two siblings of the same group on separate days when one is due.
- [ ] The function is deterministic (byte-identical output for identical inputs; stable sibling ordering) and idempotent (re-applying to its own output is a no-op) — preserving the `buildToday` determinism invariant.
- [ ] No new engine façade method, no bespoke frequency override, no second scheduler is introduced — massing is one helper on the single `buildToday` path.
- [ ] Every public declaration carries a `///` doc comment; the constant(s)/helper(s) are named (no magic literals); the file carries the REUSE SPDX header and passes `dart format`/analyzer.

## Tests

`engine/test/expand_mutashabihat_test.dart` (mirrors the source), `package:test` + `package:glados`, **pure Dart** — no `flutter_test`, no widget binding, no `FontLoader`, no `HttpOverrides`, no network (the engine is pure; its tests are too). `today` is a constructed `SerialDay` literal (`day(130)`); the confusables projection is an inline `MutashabihGroups` literal (no Drift). Runs under `dart test engine/` in CI on every PR. Required cases, written **FIRST**:

- **Siblings co-occur, adjacent (the property — C-028 / §5):** a `glados` property over generated `(cards, today, groups)` where at least one group member is due — assert that for every due member, **every** sibling of its group is present in the returned plan and the group's members are **contiguous** (no non-sibling item between them). Restate the covenant in a comment (`// PRD §9.2 / C-028: due member masses its whole group back-to-back, never spaced`). Let `glados` explore and rely on shrinking; no fixed lucky seed.
- **Never spaced across days (the inverse property):** for any generated card set, no two members of the same confusable group ever land on **separate** days when one is due — running `buildToday` for `today` includes the whole group today, and the absent sibling never appears only on a later `today` as the sole representative. (Encodes "we refuse to space mutashābihāt siblings apart," 06 §7.)
- **Whole-group, not one sibling:** a group of three with one member due pulls in **both** other siblings adjacent (not just one) — the unpracticed twin is never left behind (Rule 3 / C-029 adjacency invariant).
- **Additive, manzil preserved:** the returned plan is a superset of the input FAR slice (no original item dropped or deferred), and the manzil/cycle items retain their mandatory presence and relative recitation order; the manzil → near → new ordering of the surrounding `buildToday` plan is unchanged.
- **Move-not-duplicate:** when a sibling is already in the slice, the output contains it exactly once, now adjacent to the triggering member — assert no duplicate page id.
- **No schedule mutation:** before/after `expandMutashabihat`, every card's `D`/`S`/`dueAt` is unchanged (deep-equal); no `onReview` is invoked — massing is a session inclusion, not a graded review.
- **Determinism + idempotence:** two runs over identical `(slice, today, groups)` are fingerprint-equal; applying the function to its own output returns the same list (no plan growth on re-entry) — preserving INV-4.
- **No groups / no due member = identity:** with an empty `MutashabihGroups`, or when no FAR-slice card is a group member, the function returns the input slice unchanged (no spurious additions).

An end-to-end `buildToday` engine test (in `engine/test/build_today_test.dart` or alongside) seeds a card set with one due confusable member and asserts the assembled `DayPlan` has the group massed in the FAR section, manzil still mandatory, order preserved — proving the seam is wired into the single path, not a parallel one. All cases are pure `dart test engine/`; no socket is opened, so no `HttpOverrides` guard is needed at this tier (the offline guard lives on the data/feature tiers, E14-T03/E14-T12).

## Definition of Done

- [ ] All acceptance criteria met; the test-first sibling-massing property and the no-spacing property are green locally and in CI on every PR.
- [ ] **Massed, juxtaposed, whole-group (the behavior):** when any group member is due, its whole group is pulled into the **same** session adjacent and back-to-back; siblings are **never** spaced across days or behind a spacing interval; the property asserting co-occurrence + adjacency holds over generated histories (PRD §9.2; science 05 §5; CLAIMS C-028).
- [ ] **One engine path:** massing is policy layered on E04's single `buildToday` path via the existing `expandMutashabihat` seam — **no** second/parallel "interference scheduler," no bespoke frequency override; the layer is deterministic — no `DateTime.now()`, no `Random`; `today` injected as `SerialDay` (engineering 06 §7, §8).
- [ ] **Additive, nothing safe to drop, manzil un-skippable:** massing only ever *adds* a not-yet-due sibling into today; it drops/defers/retires no review, no manzil item is removed to make room, and no path implies a page is "safe to drop" (engineering 06 §7; PRD §7.12).
- [ ] **No schedule corruption:** a massed sibling's `D`/`S`/`dueAt` is untouched and its real next-due date is neither reset nor satisfied; massing changes session membership, not schedule state (the `D` bump is E14-T04).
- [ ] **Offline / no-network:** the dataset is the bundled, injected in-memory projection read offline forever; nothing in this path opens a socket; E01's banned-import/no-network gates stay green.
- [ ] **No AI / no microphone / no inference:** the group set is the bundled scholar-reviewed static dataset (E14-T01); nothing infers "similar verses," captures audio, or trains on user data at runtime (PRD C2, R5; science 05 §7).
- [ ] **Quran text fidelity:** this task schedules by integer page key only — it never renders, reconstructs, re-typesets, or reshapes Quran text and touches no glyph/page path (the anchor overlay is E14-T09).
- [ ] **RTL + fa/ckb/ar strings / accessibility:** N/A by construction — the engine emits opaque page ids and a plan only; it holds no locale, numeral, calendar, or user-facing string; presentation and RTL live in the feature/drill layer (E14-T07/E14-T08/E14-T11).
- [ ] **Sect-neutral adab:** the engine introduces no streak/score/badge/"cured"/"safe to drop" surface and no madhhab/sect ruling; massing is a calm, additive scheduling behavior only.
- [ ] **Deterministic tests / no unsourced number:** identical inputs yield an identical plan; the property tests rely on `glados` shrinking, not a fixed lucky seed; the task surfaces no user-facing number — C-028 is cited as provenance only and no CLAIMS id is invented.
- [ ] Every Dart file carries the REUSE SPDX header and `///` docs on public APIs; constants are named (no magic literals); passes the analyzer/lint config and `dart format`.
