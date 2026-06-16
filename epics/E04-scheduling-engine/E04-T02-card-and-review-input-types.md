# E04-T02 — Card and ReviewInput value types with the non-null dueAt invariant

| | |
|---|---|
| **Epic** | [E04 — Scheduling Engine](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E04-T01 |
| **Skills** | domain-scheduling-engine-rules, domain-grading-pipeline, eng-write-to-coding-standards |

## Goal

The immutable `Card` value type and the `ReviewInput` grading signal it consumes exist in the pure-Dart `engine/` package, exactly as engineering 06 §2 specifies — `pageId 1..604`, `d ∈ [1,10]`, `s` in days, `track`, `reps`, `lapses`, `weakFlag`, `signoffs`, `manualLock`, `prayerCritical`, and a **non-nullable `dueAt` for every memorized card** asserted at construction so that a memorized card (`track != unmemorized`) with a null ceiling is *unrepresentable in the type system*. Alongside them land the `Track`, `Grade`, `Source`, and `JuzConfidence` enums the engine façade signatures reference, and a `Card.copyWith` that returns a new instance. No persistence concern (no Drift symbol, no `owner_id`/`enabled` column, no clock) crosses into these types; they carry only the fields the schedule depends on.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §7.2 (Per-card state) | The canonical `Card` field list — `page_id 1..604`, `D ∈ [1..10]`, `S` (days), `last_review_at`, `due_at` ("always set for memorized cards; never null"), `reps`, `lapses`, `weak_flag`, `signoffs`, `manual_lock` ("auto-graduation suppressed"), `prayer_critical` ("higher retention floor") — and the `NEW | NEAR | FAR | UNMEMORIZED` track set |
| `docs/PRD.md` §7.10 (Cold start) | The `JuzConfidence` value set — **Solid / Shaky / Rusty** — that `coldStartCard` consumes (seeding happens in E04-T06; this task only declares the enum the façade references) |
| `docs/engineering/06-scheduling-engine.md` §2 (page card) | The verbatim Dart shape: the four enums (`Track`, `Grade`, `Source`, plus `JuzConfidence` from the façade §1), the `Card` class with `SerialDay? lastReview` / `SerialDay dueAt`, the `ReviewInput(grade, errorLines, source, missedOrAlteredWord)` shape, the rule that the engine value types *mirror but carry no persistence concern* from 05 §2, and the stated invariant "`dueAt != null` for every memorized card … asserted at construction and property-tested (§8)" |
| `docs/engineering/06-scheduling-engine.md` §1 (façade) | The exact signatures these types feed — `onReview(Card, ReviewInput, SerialDay)`, `coldStartCard(int, JuzConfidence, SerialDay, {SerialDay? memorizedOn})` — fixing which enums/types must exist and that `SerialDay` (E02-owned) is the day type, never `DateTime` |
| Skill `domain-scheduling-engine-rules` (+ `template.dart`) | Rule 18 / the Do-Don't row: "Keep `dueAt` non-null for every memorized card (assert at construction)" / "Allow a nullable/infinite `dueAt` on a `track != unmemorized` card"; rule 3 (vendor, no `fsrs` runtime dep); rule 11 (phase is derived from `S`, so the card stores no redundant phase field); the purity/no-I/O boundary the types live inside |
| Skill `domain-grading-pipeline` (+ `template.dart`) | The `ReviewInput(grade, errorLines, source, missedOrAlteredWord)` contract this task *declares* (the recite flow that builds it is E12) — `errorLines` are 1-based and may be empty; `source` is `self_`/`teacher`; `missedOrAlteredWord` is the sacred-text-guard flag the engine (E04-T04) reads to cap the grade at `Hard`; this task encodes the *shape*, not the guard logic |
| Skill `eng-write-to-coding-standards` (+ `template.dart`) | Immutable value type pattern: `final` fields, `const` constructor, hand-written `copyWith`; full-word identifiers with units in the name (`stabilityDays`-style intent is met by `///`-documenting the terse FSRS `d`/`s` at the field and citing the formula); `///` on every public API; `assert` for engine invariants (engine is *total*, never throws); one fixed transliteration per sacred term |
| `docs/science/CLAIMS.md` C-016, C-009, C-021, C-024 | No number is *rendered* by this task (it ships no UI, no copy), but the field semantics trace to graded rows: the non-null `dueAt` invariant *is* the trust-clamp covenant (C-016) and the cost-asymmetry that licenses erring early (C-009); `source`/`signoffs` carry the teacher-authority rule (C-021); `signoffs`/`prayerCritical` feed fluency-gated graduation and the higher floor (C-024). Cited so later tasks that *do* emit a number inherit a registered claim — this task invents no citation |
| Siblings: E04-T01, E04-T03, E04-T04, E04-T06, E04-T11 | T01 scaffolds the pure-Dart `engine/` package and barrel these types export through; T03 consumes `Card`/the curve; T04's `onReview` reads `missedOrAlteredWord`/`source`/`weakFlag` and returns a new `Card` via `copyWith`; T06's `coldStartCard` consumes `JuzConfidence` and emits cards with `dueAt = today`; T11 property-tests the non-null-`dueAt` invariant over generated `(Card, …)` histories — this task supplies the types those generators construct |

## Implementation notes

TEST-FIRST: the construction invariant is correctness-critical (it is the data-model expression of "nothing decays silently"). Write the constructor-invariant suite below — the rejected-case (`memorized + null dueAt` must fail an `assert`) and the accepted-cases — *before* the `Card` body, and watch the rejected case fail before the assertion exists.

1. **Files** (in the package scaffolded by E04-T01): `packages/engine/lib/src/card.dart` for `Card` + `Card.copyWith`, `packages/engine/lib/src/review_input.dart` for `ReviewInput`, and `packages/engine/lib/src/enums.dart` for `Track`, `Grade`, `Source`, `JuzConfidence`. Re-export all four/three files from the `packages/engine/lib/engine.dart` barrel. Every file carries the REUSE SPDX header (`GPL-3.0-or-later`).

2. **Enums** (`enums.dart`), names verbatim from engineering 06 §2 / §1:
   - `enum Track { unmemorized, near, far, newLesson }` — `newLesson` because `new` is a reserved word; `///`-comment the NEW/NEAR/FAR/UNMEMORIZED mapping.
   - `enum Grade { again, hard, good, easy }` — `///` the FSRS `G ∈ {1,2,3,4}` map (Again 1 … Easy 4); do not store the integer, derive it where the math needs it (E04-T04).
   - `enum Source { self_, teacher }` — `self_` trailing-underscore to avoid the `this`/keyword clash; `///` the per-source confidence split (self ≈ 0.5, teacher 1.0) but **inline no weight literal here** — `kSelfConfidence` is an E04-T10 constant.
   - `enum JuzConfidence { solid, shaky, rusty }` — `///` that it is the cold-start self-assessment (PRD §7.10) consumed by `coldStartCard`; declare it now because the façade signature (§1) names it. Seed values (`D=3,S=60` …) are **not** here — they are E04-T06.

3. **`Card`** (`card.dart`) — immutable per eng-write-to-coding-standards §5: all `final`, a `const` constructor, hand-written `copyWith`. Fields exactly engineering 06 §2 / PRD §7.2:
   `final int pageId;` (1..604, the scheduling key) · `final Track track;` · `final double d;` (Difficulty [1,10]) · `final double s;` (Stability, days for R→0.9) · `final SerialDay? lastReview;` (nullable — a never-reviewed cold-start card has none) · `final SerialDay dueAt;` (**non-nullable**, the next-due ceiling) · `final int reps;` · `final int lapses;` · `final bool weakFlag;` · `final int signoffs;` · `final bool manualLock;` · `final bool prayerCritical;`. `SerialDay` comes from E02 (the engine's only models/date dependency); `Card` constructs no `DateTime`. **Store no `phase` field** — phase is derived from `s` (rule 11); **store no persistence column** (`owner_id`, `enabled`) — those are the Drift row in E03, not this type.

4. **The construction invariant** — in the `const` (or a `Card._` + factory if a non-trivial assert body is needed) constructor, the `assert` that makes the silent-drop state unrepresentable:
   ```dart
   // PRD §7.6 / §7.12: a memorized page without a due ceiling is silently
   // droppable — the one state this engine exists to forbid. Unrepresentable.
   assert(
     track == Track.unmemorized || /* dueAt is non-null by type */ true,
     ...,
   );
   ```
   Because `dueAt` is a *non-nullable* `SerialDay`, the type already forbids `null` for *all* cards; the assert additionally guards the cross-field rule and documents the covenant at its enforcement point. Add bound asserts only as the spec states them: `assert(pageId >= 1 && pageId <= 604)`, `assert(d >= 1 && d <= 10)`, `assert(s > 0)`, `assert(reps >= 0 && lapses >= 0 && signoffs >= 0)`. Asserts only — the engine is total and **never throws** (eng-write-to-coding-standards §6); these strip in release and are caught in tests/property runs (E04-T11).

5. **`copyWith`** — hand-written, every field with a sentinel-free nullable-aware pattern. Because `lastReview` is nullable, use an explicit wrapper (e.g. an `Object? lastReview = _sentinel` or a small `Wrapped<SerialDay?>`) so a caller *can* set it back — but `dueAt` is **non-nullable in the signature too**, so `copyWith` cannot produce a memorized card with no ceiling. Returns a new `Card`; mutates nothing. Document why the trust clamp's only product (`dueAt`) is non-optional even in `copyWith`.

6. **`ReviewInput`** (`review_input.dart`) — immutable, `const` constructor, exactly the domain-grading-pipeline shape:
   `final Grade grade;` · `final List<int> errorLines;` (1-based, may be empty — `///` it; consider `const []` default and storing an unmodifiable view to keep the value type honestly immutable) · `final Source source;` · `final bool missedOrAlteredWord;` (the sacred-text-guard flag; `///` that E04-T04 caps the grade at `Hard` when true — this type only *carries* it). No `due_at`, no clock, no stability field — this is a pure signal, not a result.

7. **Equality** — give both types value `==`/`hashCode` (so golden vectors and the T11 property generators can compare cards). Hand-written or `package:meta`'s `@immutable` + manual operators; do **not** pull in `freezed`/`equatable` if E04-T01 fixed the dep line to `meta` (+ `models`) only — match whatever boundary T01 set.

8. **Pitfalls to avoid**: making `dueAt` nullable "for symmetry" with `lastReview` (the exact state the invariant forbids — PRD §7.12, rule 18); storing a redundant `phase`/`retrievability`/`isDue` field (derived, never stored — engineering 06 §2 pitfall "we refuse to roll page health up into stored state"); importing anything from `drift`/`flutter`/`dart:io` or constructing a `DateTime` (breaks the engine purity gate from E04-T01); inlining `0.5`/`1.0` source weights or `D=3,S=60` seeds in the enums (those are E04-T10 / E04-T06 constants); a `throw` instead of `assert` (the engine is total); spelling drift on a sacred term in a doc comment (`mushaf`, `juz`, `manzil` — one fixed transliteration).

## Acceptance criteria

- [ ] `card.dart`, `review_input.dart`, `enums.dart` exist under `packages/engine/lib/src/` and are re-exported from the `engine.dart` barrel; each carries the REUSE SPDX header.
- [ ] `Track`, `Grade`, `Source`, `JuzConfidence` declare exactly the engineering 06 §2 / §1 / PRD §7.10 members (`unmemorized/near/far/newLesson`, `again/hard/good/easy`, `self_/teacher`, `solid/shaky/rusty`); no integer/weight/seed value is stored on the enums.
- [ ] `Card` carries every PRD §7.2 field, all `final`, with a `const` constructor; `dueAt` is a **non-nullable** `SerialDay`; `lastReview` is the only nullable date; there is no `phase`, `retrievability`, `owner_id`, or `enabled` field.
- [ ] A `Card` constructed with `track != Track.unmemorized` and no `dueAt` is **uncompilable** (the type is non-nullable), and the cross-field/bound `assert`s reject out-of-range `pageId`/`d`/`s`/negative counters in debug.
- [ ] `Card.copyWith` returns a new instance, mutates nothing, supports updating `lastReview` (including back to a non-null), and cannot produce a memorized card without a `dueAt`.
- [ ] `ReviewInput` carries `(grade, errorLines, source, missedOrAlteredWord)` and nothing else — no `dueAt`, no clock, no stability; `errorLines` is exposed as an effectively-immutable 1-based list.
- [ ] Both types have value `==`/`hashCode`; the `engine/` package still imports only `meta` (+ `models`) — no `drift`, `flutter`, `dart:io`, `DateTime`, or runtime `fsrs` — verifiable by grep and the E04-T01 purity gate.
- [ ] Every public declaration carries a `///` summary-first doc comment; the trust-clamp covenant is restated as a why-comment at the construction assert; `dart format` and `dart analyze --fatal-infos` are clean.

## Tests

`packages/engine/test/card_test.dart` and `packages/engine/test/review_input_test.dart`, `package:test` (pure Dart — no `flutter_test`, this package has no Flutter dep), deterministic, no clock. `SerialDay` fixtures are explicit integer-day literals (no `DateTime`, no "today"). Written FIRST where they pin the invariant:

- **Memorized card needs a ceiling (the invariant)**: constructing every `track != unmemorized` value with a valid `dueAt` succeeds; the non-nullable type forbids the null-`dueAt` case at compile time (assert in a doc/comment that this is type-enforced, and `copyWith` cannot route around it). An `UNMEMORIZED` card with a `dueAt` is still valid (it carries one harmlessly).
- **Bound asserts fire in debug**: `pageId` outside `1..604`, `d` outside `[1,10]`, `s <= 0`, and negative `reps`/`lapses`/`signoffs` each trip an `assert` (`expect(() => Card(...), throwsA(isA<AssertionError>()))`), and valid boundary values (`pageId == 1`, `pageId == 604`, `d == 1`, `d == 10`) construct.
- **`copyWith` round-trips**: changing one field leaves all others byte-equal; setting `lastReview` to a value and back to a fresh value both work; `copyWith` with no args equals the original (`==`); the result is a distinct instance.
- **`ReviewInput` shape**: a default `errorLines` is empty; a populated `errorLines` keeps its 1-based indices; mutating the passed-in list does not mutate the stored value (immutability proof); `missedOrAlteredWord` defaults to `false` and round-trips.
- **Value equality**: two `Card`s / two `ReviewInput`s with identical fields are `==` and share a `hashCode`; differing one field breaks equality — so T11's property generators and the golden-vector comparisons can rely on structural equality.
- **Offline / purity guard** (lightweight, complements the E04-T01 banned-import grep gate): a test or the package's grep gate asserts these two files import no `dart:io`/`flutter`/`drift` and reference no `DateTime` — the types are airplane-mode-safe by construction.

(No golden *vector* table is added here — these are value types, not arithmetic; the FSRS golden vectors begin at E04-T03. No widget/integration test — `engine/` renders nothing.)

## Definition of Done

- [ ] All acceptance criteria met; both suites green under `dart test` in the `engine/` package locally and in CI; the test-first invariant case existed and failed before the constructor was written.
- [ ] **The trust-clamp covenant (non-negotiable)**: a memorized card with no `dueAt` is unrepresentable — the field is non-nullable, `copyWith` preserves that, and the covenant is restated in a why-comment at the assert (PRD §7.6, §7.12; CLAIMS C-016; domain-scheduling-engine-rules rule 18).
- [ ] **Offline / no-network**: these types open no socket and link no http/analytics SDK; the `engine/` dependency line stays `meta` (+ `models`) — verifiable by grep (PRD C1; engineering 06 §1).
- [ ] **No AI / no audio / no microphone**: `ReviewInput` carries only a human-produced `(grade, errorLines, source, missedOrAlteredWord)` signal — no recording, ASR, model, or audio field anywhere (PRD C2, R5; domain-grading-pipeline).
- [ ] **Determinism**: no `DateTime`, no `DateTime.now()`, no `Random`, no I/O reachable from either file; dates are `SerialDay` integers; both types are pure immutable values — identical fields → equal instances (PRD §7.12; engineering 06 §1).
- [ ] **Quran text fidelity**: N/A by construction — these types hold a page *id* and a grading signal, never muṣḥaf glyphs or layout; nothing here can reflow or re-typeset sacred text. The boundary is stated, not assumed.
- [ ] **RTL + fa/ckb/ar localization**: N/A by construction — the types emit opaque integers/enums and no user-facing string; no locale, numeral, or calendar logic leaks in (those live in E02 and the fa/ckb/ar UI layer that renders a card).
- [ ] **Accessibility**: N/A by construction — `engine/` renders no widget; a11y lives wherever the card is displayed (E12/E15).
- [ ] **Sect-neutral adab**: no streak/score/badge/shame field; nothing implies a madhhab/sect ruling; `manualLock`/`signoffs` model the teacher's authority as servant-to-the-talaqqī, not a verdict the app issues (PRD R3, R6; domain-grading-pipeline; CLAIMS C-021).
- [ ] **No unsourced number**: this task renders no number; the field semantics trace to already-graded CLAIMS rows (C-016, C-009, C-021, C-024) and no citation or CLAIMS id is invented (domain-claims-register-and-science-screen).
- [ ] Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`); `///` docs on every public API; `dart format` and `dart analyze --fatal-infos` clean; no `print`/`debugPrint`; no `!`/`late`/`dynamic` used to dodge the non-null-`dueAt` honesty (eng-write-to-coding-standards §4, §5, §7).
