# E21-T07 — Reader "I've memorized this page" intake surface

| | |
|---|---|
| **Epic** | [E21 — New-Memorization (Sabaq) Loop & Beginner Path](EPIC.md) |
| **Size** | M |
| **Depends on** | E13 (reader), E21-T02 (write path), the sabaq intake controller (`7a52b45`) |
| **Skills** | eng-add-localized-string, eng-rtl-and-bidi-layout, domain-adab-and-religious-integrity, domain-mushaf-text-integrity |

## Goal

The primary sabaq intake surface (PRD §12.3): a calm **"I've memorized this page"** control in the muṣḥaf reader's auto-hiding chrome that records the **current** page as newly memorized — it enters the revision schedule via the intake controller's single write path — then confirms calmly. The reader mutates no card directly and re-typesets no glyph (it hands the write to `SabaqIntakeController`); the control lives in the chrome band, never on the immutable glyph layer (R1).

**Design decision — always available, not pace-gated.** The control does **not** gate on `sabaqIntakeActive` (the `newLinesPerDay` pace). The default pace is 0 (opt-in), so pace-gating the *marking* affordance would hide intake by default and make F01 unusable for a beginner. Recording what you have memorized is user-initiated and always permitted; the pace only governs the Today *prompt* (T06) and "pause new sabaq" (which stops prompting, not manual marking). An already-in-revision page returns a calm note, never a failure.

## Implementation notes

1. **`_MemorizedPageControl`** (a `ConsumerWidget` in `mushaf_chrome.dart`), added to the `_ControlsBand` `Wrap` after the jump control. It reads the **current** page via `mushafReaderStateProvider(entryPage).select((s) => s.pageNumber)`, and on tap calls `sabaqIntakeControllerProvider.startMemorizing(page)`, then shows a `SnackBar` mapped from `SabaqIntakeResult` (started / already-in-revision / retry; no-profile is silent). Context-derived objects (l10n, messenger) are captured before the async gap.
2. **Copy** — `mushafMemorizedThisPage` + `sabaqStartedNote` / `sabaqAlreadyInRevision` / `sabaqIntakeFailedNote` in fa/ckb/ar, PROVISIONAL (needs native + scholarly review). Icon `bookmark_add_outlined` (not a gamification glyph).
3. **Pitfalls:** touching the glyph layer (the write is the controller's, the control is chrome); pace-gating the affordance (breaks the default-0 beginner); a `DateTime.now`/`streak`/haptic/celebration symbol in the chrome source (the source-scan gate bans the substrings — even in comments).

## Acceptance criteria

- [ ] A calm "I've memorized this page" control sits in the reader chrome band; tapping it records the current page via the intake controller and confirms with a calm SnackBar; an already-in-revision page is a calm note, not a failure.
- [ ] The control is **not** gated on the sabaq pace (works at the opt-in default of 0); it mutates no glyph and re-typesets nothing (R1); copy ships fa/ckb/ar (PROVISIONAL).
- [ ] `flutter analyze` clean; the reader-chrome suites + l10n completeness + adab lint + the chrome no-gamification source-scan pass.

## Definition of Done

- [ ] All acceptance criteria met; the chrome tests pass; the reader golden regenerates on the Linux lane (`[update-goldens]`).
- [ ] **Quran fidelity (R1):** the control is chrome; the page glyph layer is untouched; the write is the intake controller's single write path.
- [ ] **Adab / no gamification:** calm, factual copy; no streak/score/celebration on marking; an already-started page reads calmly; copy flagged for scholarly + native review.
- [ ] **RTL + fa/ckb/ar:** all four strings ship in three locales; the control is logical-direction; no hardcoded user-facing string.
- [ ] **Offline / single write path:** the write rides the transactional intake repository (persist-before-republish); no socket, no clock in the control.

*Widget/golden coverage of the tap→SnackBar flow is consolidated in E21-T09; the controller logic is unit-tested (`sabaq_intake_controller_test.dart`).*
