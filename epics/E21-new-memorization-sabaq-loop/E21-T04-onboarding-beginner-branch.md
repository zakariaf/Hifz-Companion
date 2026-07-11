# E21-T04 — The zero-juz "I'm just starting" onboarding branch (F02)

| | |
|---|---|
| **Epic** | [E21 — New-Memorization (Sabaq) Loop & Beginner Path](EPIC.md) |
| **Size** | L |
| **Depends on** | E11 (onboarding), E21-T02 (the intake path a beginner grows into) |
| **Skills** | eng-add-localized-string, eng-rtl-and-bidi-layout, eng-write-dart-test, domain-adab-and-religious-integrity |

## Goal

Let a from-zero beginner finish onboarding. Today the coverage step hard-blocks anyone holding zero juz (`_canLeave(coverage)` is `coverage.isNotEmpty`), and `coldStartCard` refuses to seed a page you don't already hold — so a beginner is trapped (F02). This adds an **"I'm just starting"** affordance on the coverage step that: allows zero held juz through the gate, is mutually exclusive with holding any juz (choosing it clears any held juz + ratings; holding a juz clears it), **skips** the now-empty confidence step, and commits into an **empty, ready-to-grow** schedule (cold-start already seeds zero cards for empty coverage). Pages are added later through the intake surfaces (T06/T07). Calm, non-judgemental copy — starting is never "behind" or "0%".

## Implementation notes

1. **State** — add `OnboardingState.justStarting` (bool, default false) with `copyWith`/`==`/`hashCode`.
2. **Controller** — `setJustStarting({required bool value})` (clears coverage/confidence/memorizedOn when true); `toggleJuz` clears `justStarting` when the result is non-empty (mutual exclusion).
3. **Gates** — `coverage => coverage.isNotEmpty || justStarting`; `confidence => coverage.isEmpty || everyHeldJuzRated` (vacuously passes for a beginner).
4. **Skip** — `next()`/`back()` skip `OnboardingStep.confidence` when `coverage.isEmpty` (nothing to rate).
5. **View** — a `_JustStartingToggle` on the coverage step (selected carried by shape + label, not hue; ≥48 dp toggled Semantics; the grid dims but stays tappable so tapping a juz exits the branch). Two ARB strings (`onboardingJustStarting`, `onboardingJustStartingNote`) in fa/ckb/ar, marked PROVISIONAL (needs native + scholarly review).
6. **Pitfalls:** hard-locking the grid when "just starting" (keep it tappable); seeding a phantom card for a beginner (the commit stays empty); a "0%"/"behind"/shame frame; reusing the cell glyph counts in a way that breaks the grid unit tests (scope those to the `GridView`).

## Acceptance criteria

- [ ] A zero-juz beginner can select "I'm just starting", advance past coverage, skip the empty confidence step, and reach `cyclePreset` → `done`; the placement commit seeds zero cards (ready to grow).
- [ ] "Just starting" and holding juz are mutually exclusive; the copy carries no number, no "behind", no shame; the toggle is ≥48 dp with shape+label state encoding.
- [ ] `flutter analyze` clean; the onboarding view-model + coverage-grid suites pass; l10n completeness + adab lint green.

## Tests

- `onboarding_view_model_test.dart` (extended): blocked-until-just-starting; coverage → cyclePreset skipping confidence (and back symmetrically); empty commit; holding a juz clears the branch; choosing the branch clears held juz + ratings.
- `coverage_capture_grid_test.dart`: cell-count/glyph finders scoped to the `GridView` (the toggle is a separate control); the ≥48 dp tap-target guideline still holds.

## Definition of Done

- [ ] All acceptance criteria met; analyze clean; the two suites + l10n + adab gates green; the coverage golden regenerates on the Linux lane (`[update-goldens]`).
- [ ] **No phantom data:** a beginner commits zero cards — pages enter only through the real intake path (T06/T07).
- [ ] **Adab / no shame:** starting from zero reads as calm and ready, never "0%", "behind", or a failure; copy is flagged for scholarly + native review.
- [ ] **RTL + fa/ckb/ar:** both strings ship in all three locales through the ARB pipeline; the toggle is logical-direction + ≥48 dp with non-colour state.
- [ ] **Deterministic tests:** pure in-memory controller, injected today, no clock/network.
