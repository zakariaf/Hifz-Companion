# E21-T09 — The new-memorization lifecycle integration journey

| | |
|---|---|
| **Epic** | [E21 — New-Memorization (Sabaq) Loop & Beginner Path](EPIC.md) |
| **Size** | M |
| **Depends on** | E21-T01…T07 |
| **Skills** | eng-write-engine-golden-vector, eng-write-dart-test |

## Goal

Prove the whole sabaq loop holds together: a page a beginner memorizes **today** enters today's plan on the New (sabaq) track, is revised, and — with fluent teacher sign-off — graduates out of New toward the maintenance bulk, while a lapse keeps it in active revision (never dropped). This is the end-to-end verification that `sabaqSeed` (T01) feeds `buildToday` and `onReview` exactly like any other card, with every §7.12 invariant intact.

## Implementation notes

- `packages/engine/test/vectors/sabaq_lifecycle_test.dart` (pure `package:test`, no clock/DB): `sabaqSeed → Card → buildToday` (the page is in the day) → an `onReview` loop with fluent teacher grades → it graduates out of New (`trackStrength` rises, never `unmemorized`, `dueAt` stays finite); a separate `Again` lapse leaves it on the most-revised track with a finite due day (never "safe to drop").
- The per-layer journey is already covered: the from-zero onboarding branch (`onboarding_view_model_test.dart`, T04), the intake write path over a zero-card profile (`sabaq_intake_repository_test.dart`, T02), and the "start memorizing" command (`sabaq_intake_controller_test.dart`).

## Acceptance criteria

- [ ] The pure-engine lifecycle test passes: a fresh sabaq page enters `buildToday`, graduates out of New under fluent teacher review, and a lapse never drops it; the full engine suite stays green.

## Definition of Done

- [ ] The lifecycle test is green and deterministic (no clock/DB/network); it exercises the real `sabaqSeed → buildToday → onReview` path with the frozen engine.
- [ ] **Never "safe to drop" / manzil never dropped:** the lapse case asserts the page stays on the most-revised track with a finite `due_at`.

## Deferred to CI / a follow-up (recorded honestly, not silently)

- **Full-stack widget journey** (onboard-from-zero → mark a page in the reader → it appears in Today → grade it) as an `integration_test`, and the **per-locale Today/reader goldens** that gained the intake surfaces — these run on the Linux CI lane (the goldens are regenerated there via `[update-goldens]`; they cannot be pixel-verified on the macOS dev machine, matching the existing environmental golden posture).
