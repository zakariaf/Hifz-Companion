# E21-T06 — Today "start a new lesson" intake prompt

| | |
|---|---|
| **Epic** | [E21 — New-Memorization (Sabaq) Loop & Beginner Path](EPIC.md) |
| **Size** | S–M |
| **Depends on** | E12 (Today), E21-T03 (the pace signal), E21-T07 (the reader marking control) |
| **Skills** | eng-add-localized-string, domain-adab-and-religious-integrity |

## Goal

Make new memorization **discoverable** from the daily home: a calm **"start a new lesson"** affordance in Today that opens the muṣḥaf reader, where the ḥāfiẓ marks the page memorized (T07). Unlike the always-available reader control, this prompt is **gated on the sabaq pace** (`sabaqIntakeActive` — `newLinesPerDay > 0`), so it appears only when new memorization is on and disappears when the pace is 0 / "pause new sabaq" is chosen — framed as protection, never a nag. No number, badge, streak, or celebration.

## Implementation notes

1. `_TodayDay` (a `ConsumerWidget`) watches `activeCycleConfigProvider` and shows a `_StartNewLessonPrompt` (a quiet `OutlinedButton` → `context.push('/mushaf')`) as a footer only when `sabaqIntakeActive(config)`. The existing budget-feedback line stays above; the day list stays complete (manzil never dropped).
2. One ARB string (`todayStartNewLesson`) in fa/ckb/ar, PROVISIONAL. Icon `bookmark_add_outlined` (not a gamification glyph).
3. The budget-line "pause new sabaq" keeps its deep-link to Cycle settings for now (a real one-tap `pauseNewSabaq()` writer exists from T03; wiring it here is deferred to avoid perturbing the budget-line navigation tests).
4. **Pitfalls:** showing the prompt when the pace is 0 (it must respect pause); a number/streak/celebration; dropping a manzil page to make room for the prompt (it is a footer, not a schedule change).

## Acceptance criteria

- [ ] A calm "start a new lesson" footer appears in Today only when `sabaqIntakeActive` (pace > 0) and opens the reader; it is hidden at the opt-in default (0) and when paused.
- [ ] No number/badge/streak/celebration; the string ships fa/ckb/ar (PROVISIONAL); `flutter analyze` clean; l10n completeness + adab lint green; only Today **golden** tests change (content), no logic regression.

## Definition of Done

- [ ] All acceptance criteria met; analyze + l10n + adab green; the Today golden regenerates on the Linux lane (`[update-goldens]`).
- [ ] **Adab:** the prompt is calm and optional; hiding it under a 0 pace / pause reads as protecting what's earned, never a nag; copy flagged for scholarly + native review.
- [ ] **Never "safe to drop":** the prompt is a footer — it changes no schedule, drops no manzil, and the day list stays complete.
- [ ] **RTL + fa/ckb/ar:** the string ships in three locales; logical-direction layout; no hardcoded user-facing string.

*The prompt's visibility logic rests on the unit-tested `sabaqIntakeActive`; the rendered states land in the Today goldens; a dedicated visibility widget test is consolidated in E21-T09.*
