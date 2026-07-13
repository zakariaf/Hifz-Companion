# Full-app product audit — 2026-07-10

**Tree audited:** branch `epic/redesign-mihrab-architecture` (clean, post-E19 + mihrab reskin).
**Method:** 12 independent auditors (5 persona journeys: absolute beginner, mid-journey student, complete ḥāfiẓ, teacher/halaqa, returner-after-gap; 7 subsystem deep-dives: engine-vs-PRD, daily-loop wiring, data integrity, onboarding/assets, PRD feature matrix, UX dead-ends, adab/claims). Findings were merged across auditors, then **every blocker/major was independently adversarially verified** against the code (a verifier tried to refute each claim before it was accepted). Two persona lanes (partial, returner) returned degraded output during a rate-limit window; their ground was covered by the other ten lanes.

**Companion evidence:** `flutter analyze` clean; **1,438 tests green** across all 11 packages on the CI-pinned SDK (Flutter 3.41.2); the only test failures are macOS-vs-Linux golden pixel diffs (environmental). The app builds and launches on iOS simulator.

---

## Verdict

**The foundations are genuinely well built. The product around them has holes — specific, listable, fixable holes. A full refactor is NOT warranted and would destroy real value.**

What is solid (verified, not assumed): the FSRS engine arithmetic and its invariants (trust clamp is `min` and runs on every review; a lapse demotes; the sacred-text guard caps a stumbled page at Hard; manzil-due pages are never dropped), the single-write-path persistence (WAL + `synchronous=FULL`, append-only `review_log`, transactional persist-before-republish, versioned migrations with integrity-check fixtures), the backup format (SHA-256-verified, all-or-nothing restore, careful set-union merge), the recite→grade→persist→re-emit spine, the muṣḥaf render architecture, l10n/RTL, and the heat-map read model.

What is wrong is a consistent pattern: **capabilities exist in the engine or data layer but were never wired into the app**, and **the entire "growing your hifz" half of the product was never built**. The owner's instinct — *"it doesn't consider someone who's just starting to hifz"* — is confirmed at blocker severity, in code, from seven independent auditors.

### Why the app "didn't work" on the new laptop (environment, not code)

1. The migrated Flutter SDK (3.24.3) cannot resolve this repo — fixed: SDK upgraded and pinned to 3.41.2 (CI parity), app builds and launches.
2. **F03 below:** the muṣḥaf assets (604 KFGQPC fonts + 3 data files) are deliberately gitignored, the runtime is bundle-first (never downloads), and the fetch tool is broken — so on any fresh checkout, onboarding permanently dead-ends at Core setup. The old laptop worked only because those files sat untracked in its working tree. **Short-term unblock: copy `app/assets/quran/` from the old laptop.**

---

## Blockers (5) — each confirmed by adversarial verification

| ID | Finding |
|---|---|
| **F01** | **No new-memorization (sabaq) intake exists anywhere.** There is no way to record "I memorized a new page" or introduce any page into the schedule after onboarding. `sabaqLines` — required by PRD §7.8 and E04-T08's own acceptance criteria — has zero hits in the codebase; `EngineConfig` has no intake field; `CardRepository` is read-only; grading a card-less page throws. The engine defers intake to the feature layer (`build_today.dart:105-106`); the feature layer never built it; E11 and E13 each defer the entry surface to the other. A beginner can never start; an existing ḥāfiẓ's schedule can never grow. |
| **F02** | **Onboarding hard-blocks a zero-juz beginner.** The coverage step's advance gate is `coverage.isNotEmpty` (`onboarding_view_model.dart:541`); the grid offers only 30 held/not-held toggles, no "I'm just starting" branch, no explanation. The only escape is lying — which seeds retrieval cards for unmemorized pages, explicitly wrong per the project's own science docs. |
| **F03** | **A from-source build dead-ends at Core setup.** Muṣḥaf assets are gitignored by design, the runtime is bundle-first (`core_install.dart` never downloads; the GitHub-Releases downloader stack is dead code), and `fetch_core_assets.sh` writes the wrong formats to the wrong directory with normalization deferred. Result: `CoreSetupPhase.integrityFailure` and a Retry that can never succeed — the correct fail-closed behavior with no path forward. There is no reproducible route from this repo to a runnable app. |
| **F04** | **Profiles created in-app are permanently empty.** `profiles_controller.dart:57` seeds `const []` (zero cards); the router only offers onboarding when no profile exists; the family-keyed onboarding controller designed for re-running placement (per E16) is unreachable dead code. A teacher's students and a parent's child profiles are stuck on "all done" forever, with nothing to sign off. |
| **F05** | **The Mutashābihāt trainer ships with no dataset.** The loader, parser, tables, drill UI, and engine confusion-bump were all built and tested — but no confusables data file exists in the repo, none is in the pinned manifest, and `loadMutashabihatInto` has zero production callers. A headline nav tab is a permanent empty state, and (E20 gate 7 note) a scholar sign-off is impossible because there is nothing to sign. |

## Major findings (13) — confirmed

| ID | Finding |
|---|---|
| F06 | Mutashābihāt scheduling never fires in the live app: sibling massing not injected into `buildToday`, the confusion D-bump has zero callers, swaps are never logged from real flows. |
| F07 | Cold start makes the **entire held Quran due on day one** (up to 604 pages, all mandatory, permanent overflow) — the `dueFar` union defeats the PRD's "nobody can grade 604 pages on day one" calibration spread. |
| F08 | Graduation gates and the recent-juz window have no scheduling effect: `phaseOf` reads the stability band and ignores the stored track; `recentWindow` is never injected; the "near window (juz)" setting is inert. |
| F09 | "7-Manzil weekly khatm" never recites a contiguous manzil — index-modulo scatter re-sorted weakest-first; unrecognizable as the manzil system to the audience this app serves. The juz map needed to fix it already exists and is unused. |
| F10 | The missed-day catch-up plan is cosmetic: accept/defer is local `setState` only; the engine's re-spread is computed and thrown away. |
| F11 | Dead controls: the "new lines per day" stepper and "pause new sabaq" option persist values nothing reads (the user-facing face of F01). |
| F12 | Active profile is not persisted across relaunch — silently reverts to the first-created profile. The `app_meta.active_profile` key is documented and specced (E16-T08) but never implemented. On a teacher device this mis-attributes reviews to the wrong student's append-only sanad log. |
| F13 | Cross-device teacher↔student merge duplicates the student (profiles minted with fresh UUIDs per device; merge keys on UUID). The set-union machinery is sound; the identity model that would make it useful is missing. |
| F14 | No single-student export — only `exportAll`; sharing one student's file discloses every other student's record. The backup package is scope-ready; E16 and E17 each assigned the scope UI to the other. |
| F15 | No quick profile switcher or active-profile indicator anywhere in the chrome (specced in E16-T09/T10, skipped) — the teacher never sees whose log they are signing. |
| F16 | "Mark my memorized range" (PRD §12.3) absent — coverage is write-once at onboarding, forever. E11 defers it to E13, E13 defers it back to E11. |
| F17 | "Start revision here" from the reader (PRD §12.3) absent — recite is reachable only from a Today due-row; non-due pages are un-revisable on demand. |
| F18 | The prayer-critical retention tier (Fātiḥa, Mulk, Kahf… → 0.97 floor, PRD §7.2/§7.5) is honored by the math but **no card is ever marked prayer-critical** — no seeding, no UI. |

## Downgraded / clarified during verification

- **F19 (minor, scope-decision):** solo users' *stored track* never leaves New (teacher-gated sign-offs) — but scheduling ignores the stored track (F08), so users are unaffected today. Becomes load-bearing if F08 is fixed; needs an explicit design decision (PRD wording is self-contradictory: "N teacher/self sign-offs" vs "teacher sign-offs").
- **F20 (minor, docs-drift):** the dormant downloader is a documented bundle-first decision; the defect is stale docs (`app/assets/quran/README.md` still promises a runtime download) plus the broken fetch tool (folded into F03).
- **Refuted in an earlier pass:** "solo pages never leave the New *band*" — false; self grades raise stability and pages reach Near without a teacher.

## Minor findings (14, not adversarially verified)

F21 weekly-khatm budget mathematically unsatisfiable (~86 pages × 2 min > 120-min cap; "raise budget" is a non-solution offered daily) · F22 catch-up page cards have an empty `onOpen` · F23 backup-merge replay derives days from UTC instants instead of stored `elapsedDays` (±1-day drift; first replayed review gets elapsed 0) · F24 chronically-weak-line channel unwired (per-review stumbles passed instead of the persistent tally; line blocks never persisted) · F25 teacher manual-lock honored by the engine, settable nowhere · F26 no first-run "getting started" surface (day-1 zero-work user sees "Today's revision is complete") · F27 Today headers ignore the chosen term-set · F28 reader shows riwāyah in hardcoded Latin transliteration · F29 Settings missing the numeral-system picker and Quran font-size control (PRD §15.2) · F30 reciter-audio pack unimplemented, no build-plan home · F31 `app_meta.schema_version` written once, never bumped/read · F32 orphaned walking-skeleton placeholders exported · F33 ~2/3 of religious copy still "provisional — needs native + scholarly review" (a documented E20 launch gate) · F34 reminder opt-in lives in Settings, not onboarding — verified as working-as-designed, no gap.

---

## The pattern, and what it means for "refactor everything?"

Almost every serious finding is one of:

1. **Engine-ready, app-unwired** (F06, F08, F10, F18, F24, F25 — plus the dormant downloader): the pure layer was built and tested to spec; the composition/feature layer never passed the data or never called the function.
2. **Fell between two epics** (F01 entry surface, F14, F16): each epic's EPIC.md defers ownership to the other, and no task file ever owned it.
3. **Silently resolved doc conflicts** (F07's `dueFar` union vs PRD §7.10, F09's modulo slice vs the manzil tradition, F19's PRD self-contradiction) — exactly what CLAUDE.md says must be surfaced, not picked.

None of this indicts the architecture. The fix is **wiring, intake, and a handful of missing surfaces** — weeks of ordered task work, not a rewrite. A refactor would discard the verified engine, persistence, and backup layers that are this project's hardest-won assets.

## Recommended priority order

1. **F03** — a reproducible runnable build (fix the fetch/normalize tooling or commit a dev-asset path); nothing else can be verified end-to-end until this works on a fresh clone.
2. **F01 + F02 + F11 + F04** — the new-memorization loop: sabaq intake (engine `sabaqLines` + a "start memorizing" surface), a beginner path through onboarding, wire `newLinesPerDay`, and a placement path for in-app profiles. This is one coherent epic — the owner's core complaint.
3. **F07** — day-one calibration spread (cold-start staggering or a capped first-week plan).
4. **F05 + F06** — author/bundle the mutashābihāt dataset (scholar-reviewed) and wire massing + confusion logging.
5. **F12 + F15 + F14 + F13** — the teacher/halaqa loop: persist active profile, add the switcher chip, single-student export, and a cross-device identity answer.
6. **F09, F10, F16, F17, F18** — tradition-true manzil slicing, real catch-up persistence, coverage editing, reader hand-off, prayer-critical seeding.

*(The companion E15–E20 build-vs-spec comparison — `2026-07-10-e15-e20-build-vs-spec.md` — refines items 4–6 with per-task detail and adds two immediate remove-from-code honesty items: E19's C-048 grade coercion and E15's crisp per-page percentage. All 20 epics now carry complete task files.)*

---

*Report generated from the `hifz-full-audit` multi-agent workflow (33 agents, 12 audit lanes, merge + adversarial verification). Full per-finding evidence with file:line citations is preserved in the workflow journal; this document is the durable summary.*
