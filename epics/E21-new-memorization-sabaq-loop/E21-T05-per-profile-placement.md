# E21-T05 — Per-profile placement (F04) — **largely mooted; residual needs a router decision**

| | |
|---|---|
| **Epic** | [E21 — New-Memorization (Sabaq) Loop & Beginner Path](EPIC.md) |
| **Size** | M |
| **Depends on** | E16 (profiles/router), E21-T02/T06/T07 |
| **Status** | **Blocker resolved by the intake surfaces; residual (per-juz placement re-run) deferred — a risky E16 router change.** |

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
