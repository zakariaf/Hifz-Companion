# E21-T08 — Prayer-critical seeding (F18) — **needs a decision before build**

| | |
|---|---|
| **Epic** | [E21 — New-Memorization (Sabaq) Loop & Beginner Path](EPIC.md) |
| **Size** | M |
| **Depends on** | E21-T01, E21-T02, E21-T07 |
| **Status** | **Specced, not built — blocked on the marking-affordance decision + (for any preset) scholarly review.** |

## Goal

Make the engine's already-honored prayer-critical retention tier (the 0.97 floor, PRD §7.2/§7.5; `kCriticalTargetR`) reachable, closing F18 ("honored by the math but no card is ever marked prayer-critical — no seeding, no UI"). The catch-up planner already sorts prayer-critical pages first (`load_balance.dart`), so the only gap is **birthing a card with `isPrayerCritical = true`** and giving the user an honest way to set it.

## The plumbing (mechanical, ready to build)

1. `CardSeed.isPrayerCritical` (models) — add the field (default false) + `copyWith`/`==`/`hashCode`.
2. `sabaqSeed(pageId, today, {bool isPrayerCritical = false})` (engine) → carry it onto the seed.
3. `LiveSabaqIntakeRepository` — set `Card(isPrayerCritical: seed.isPrayerCritical, …)` (currently defaults false).
4. `SabaqIntakeController.startMemorizing(pageId, {bool isPrayerCritical = false})` → pass through.
5. Golden vector for the prayer-critical seed; a repo test asserting the flag persists.

## The decision (why this is not built yet)

The **marking affordance is a genuine product/religious-framing call**, and shipping the plumbing without an honest trigger would recreate the very F11 dead-control anti-pattern this epic set out to close. Two sub-questions:

- **How does a user mark a page prayer-critical?** Options: (a) a second action in the reader intake ("add as prayer-critical — revised to a higher standard"); (b) a per-page toggle in the Progress page-detail sheet (a card-update write path, not intake); (c) a curated preset (al-Fātiḥa, al-Mulk, al-Kahf, the last two of al-Baqarah, …). Each is a distinct UX + write-path shape.
- **A curated preset needs scholarly review.** A bundled "these surahs are prayer-critical" list edges toward a ruling; per the epic's Risks and the non-negotiables, any bundled list must be scholar-reviewed and framed as a user-editable convenience (a retention *floor*, not a fiqh claim). A **user-driven** toggle (the user marks which pages matter for their own ṣalāh) needs no ruling and is the safest default.

**Recommendation:** ship the plumbing + a **user-driven** marker (no bundled list), placed in the Progress page-detail sheet (per-page settings) rather than cluttering the reader intake. Confirm the placement before building.

## Acceptance criteria (once the decision is made)

- [ ] A page can be born (or later marked) `isPrayerCritical`; the engine's 0.97 floor and catch-up priority take effect; the flag persists through the single write path.
- [ ] No bundled prayer-critical list ships without scholarly review; any user-facing framing is "revised to a higher standard", never a fiqh ruling.
