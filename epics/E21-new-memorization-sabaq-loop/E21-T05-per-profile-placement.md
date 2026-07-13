# E21-T05 — Per-profile placement (F04) — a safe placement modal

| | |
|---|---|
| **Epic** | [E21 — New-Memorization (Sabaq) Loop & Beginner Path](EPIC.md) |
| **Size** | M |
| **Depends on** | E11 (capture widgets), E21-T02 |
| **Status** | **Built (2026-07-11).** Per the owner's choice: a placement flow reached from the Profiles screen, **without** touching the router redirect guard. |

## Built shape

A `ProfilePlacementScreen(profileId)` reached from the Profiles screen's per-profile menu ("Set up revision") as a pushed `MaterialPageRoute` — **no go_router route, no redirect-guard change**. It reuses the onboarding `CoverageCaptureGrid` (with the "I'm just starting" branch) + `ConfidenceStep`, captures the profile's held juz + Solid/Shaky/Rusty rating, and commits through a new `ColdStartSeeder.placeExistingProfile(profile, cycle, coverage, confidence, today)` — the same conservative engine priors as onboarding, scoped to the **existing** profile + its existing cycle, in one all-or-nothing `seedColdStart` transaction. A beginner student (no held juz) seeds nothing and grows via intake. The seed rule now lives in one shared `_seedsFor` helper (onboarding + placement). Copy ships fa/ckb/ar (PROVISIONAL). Tested: `placeExistingProfile` seeds the existing profile + cycle verbatim (one card per held+rated page), and the onboarding commit is unchanged.

**Both halves of F04 are now closed:** the blocker (in-app profiles born empty) by the intake surfaces, and the convenience (a quick per-juz placement for a student who already holds juz) by this modal — with no risk to the core router.

## What F04 was

"Profiles created in-app are permanently empty" — `profiles_controller.dart:57` seeds `const []`, the router only offers onboarding when **no** profile exists, and the `ProfileId`-keyed onboarding controller built to re-run placement is unreachable dead code. A teacher's students / a parent's child were "stuck on all done forever, with nothing to sign off."

## Why the blocker is now resolved

The intake surfaces close the "permanently empty" blocker: once you switch to an in-app-created profile, the reader's "I've memorized this page" control (T07) and Today's "start a new lesson" prompt (T06) let you grow that profile's schedule page by page — the `SabaqIntakeController` takes a `profileId` and is not tied to onboarding. An empty student/child profile is no longer a dead end.

## The residual (deferred, with reasons)

A student who **already holds several juz** would want a quick per-juz **placement** (the Solid/Shaky/Rusty cold-start rating) instead of marking every page. Making the built per-profile placement controller reachable requires a change to the **router redirect guard** (`app/lib/composition/router.dart`): today `if (onOnboarding) return '/today'` bounces any profiled device off `/onboarding`, so a scoped placement route needs the guard to permit onboarding for an active profile that "needs placement", plus `OnboardingScreen` scoping to a passed profile id and starting the flow at the coverage step (skipping the device-wide welcome/language/riwāyah/core steps).

This is **deliberately deferred** because: (1) it touches the core navigation guard, which has its own redirect-guard test and cannot be pixel/nav-verified on the dev machine (it needs an app-level integration run); (2) it is entangled with E16's profiles/teacher routing; and (3) the blocker it addresses is already resolved by intake. It belongs with the E16 teacher-loop work (audit chunk 5), where the halaqa switcher + active-profile persistence live.

## If/when built

- `OnboardingScreen` accepts an explicit profile scope; a `/onboarding` (or `/profiles/setup/:id`) route reachable for an active zero-card profile that opted into placement; the guard permits it via a `needsPlacement` signal; the flow starts at coverage.
- The integration journey asserts a per-profile placement writes only that profile's cards/log (the E16 halaqa write-isolation test stays green).
