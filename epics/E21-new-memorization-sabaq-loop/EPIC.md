# E21 — New-Memorization (Sabaq) Loop & Beginner Path

The missing "growing your hifz" half of the product: the intake path that turns a page you have **newly memorized** into a scheduled card inside the already-verified maintenance engine, so a beginner can start from zero and any ḥāfiẓ can keep adding pages. It adds the daily new-lesson (**sabaq**) surface — *"I've memorized this page / start revising it"* — on both the muṣḥaf reader and Today; the **"I'm just starting" onboarding branch** that no longer hard-blocks a zero-juz beginner; the **per-profile placement** path so an in-app student/child profile is not born empty; the wiring that finally makes **`newLinesPerDay`** and **"pause new sabaq"** do something; and prayer-critical seeding at intake. It reuses everything solid — the FSRS engine math, the track model, the single write path, the recite/grade loop — and only adds a *seed* primitive, a *write* path, and *entry surfaces*. No new scheduling algorithm, no change to the trust clamp, no gamification.

> **Design decision (resolved 2026-07-11): page-granular intake.** The docs specify how sabaq is *paced and consumed* (PRD §7.8) but leave the intake *mechanic* open — how a page moves `UNMEMORIZED → NEW`, and whether the sabaq *unit* is a page card or a multi-day line-by-line build. The owner confirmed the **page-granular** design: a newly-memorized page enters as a `NEW`-track card with conservative priors (a *seed* act, like cold-start) and is revised daily until it graduates — faithful to the engine's page-card unit (§7.1) and the "maintenance engine, not a memorization course" positioning, grounded entirely in the existing docs, with **zero change to the frozen D/S/R math**. Literal multi-day line-by-line building was considered and **deferred** as a docs-extending option needing its own design pass + scholarly review (see "Design decision" below).

## Why this epic exists

The product's founding complaint is that a ḥāfiẓ carries 600+ pages that decay **invisibly** ([PRD §2](../../docs/PRD.md)) — and the whole engine was built to *maintain* those pages. But the app can only ever maintain what it was handed at onboarding: `buildToday` filters out every `unmemorized` card, the only card-creating paths are cold-start (already-held pages) and backup-restore, and grading an un-seeded page throws. There is **no way to introduce a new page after onboarding**, and a from-zero beginner is hard-blocked at the coverage step. The owner's instinct — *"it doesn't consider someone who's just starting to hifz"* — is confirmed at blocker severity (`docs/audits/2026-07-10-full-app-audit.md` F01, F02, F04, F11).

This is not a coding oversight to be patched in one place; it is a **whole capability the specs never assigned an owner**. E04 (engine) defers sabaq intake to the feature layer (`packages/engine/lib/src/build_today.dart:104-106`; `load_balance.dart:74-75`; the reserved-but-unfilled config slot at `engine_config.dart:19-22`). E11 (onboarding) is scoped to placing *already-held* juz. E12 (Today) consumes the engine's day. E13 (reader) is display-only and hands writes to "the owning epic." **Each defers to another, so no epic owns the `UNMEMORIZED → NEW` transition, the card-create write, or the "start memorizing" surface.** This epic is that owner.

Three constraints shape every decision here. First, **the maintenance positioning holds** (PRD §2): the beginner story is not "teach me to memorize" but *"I memorize — with my teacher, on my own — you make sure I never lose it, page by page, from page one."* Intake feeds the existing retention engine; it is not a memorization course. Second, **the engine is verified and frozen**: introducing a page is a *seed* act analogous to cold-start (a new `Card` with conservative priors and a trust-clamped `due_at`), never a change to the D/S/R math, the trust clamp, or the graduation gate. Third, **the non-negotiables outrank the feature**: conservative cold-start priors, `due = min(ideal, ceiling)` from the moment a page enters, manzil never dropped, never "safe to drop", teacher-gated graduation, persist-before-republish through the single write path, offline/no-AI/no-microphone, adab (no streaks on the sabaq surface, "pause new sabaq" framed as protection not failure), and **no shown pacing number unless it traces to a registered CLAIMS row**.

## Design decision (resolved 2026-07-11 — page-granular)

The one place the docs are silent, resolved so it is decided, not drifted. **Chosen: page-granular** (below); the line-by-line build is **deferred** (docs-extending; needs scholarly review):

- **Intake unit — page-granular (chosen) vs literal line-by-line build (deferred).**
  - **Page-granular (CHOSEN — docs-faithful):** the scheduled unit stays the page card (§7.1: "lines are a *derived overlay*"). Starting a page creates a `NEW`-track card with conservative priors and `due_at = today`; because its stability is low it is due daily and revised *every day until it graduates* — which honors §7.8's "today's + yesterday's new lines, repeated to sign-off" at page granularity. `newLinesPerDay` paces how quickly the ḥāfiẓ opens the *next* new page and throttles the daily NEW load (the load-balancer gate). Line granularity for *diagnosis* reuses the **existing line-block / error-line machinery** (C-033) — no new model. Zero change to the engine's card math; one small additive concept (a page can be *born* on NEW).
  - **Line-by-line build (bigger, partly beyond the current docs):** a new sabaq sub-model tracks the line ranges of an in-progress page built over several days (the literal 3–5-lines/day tradition), consolidating into a page card only when the whole page is memorized + signed off. Closer to the halaqa method and §7.8's literal wording, but it invents an intake model the docs do not specify, adds engine/card state, and touches the golden vectors — so it needs its own design pass and **scholarly/pedagogical review** before it is specified.

Everything else in this epic (the beginner branch, profiles, the pause flag, the reader/Today surfaces, `newLinesPerDay` wiring, prayer-critical) is **identical under either choice** and is grounded in the existing docs. Only T01's card mechanic and T06's guided-revision shape depend on this decision.

## Scope

### In scope

- **Engine intake primitive** — a pure `sabaqSeed(pageId, today, {isPrayerCritical})` that produces a `NEW`-track `CardSeed` with conservative priors and a trust-clamped `due_at = today`, analogous to `coldStartCard` but for a *never-held* page; and filling the reserved `EngineConfig.newLinesPerDay` slot so the day-builder can read it.
- **The sabaq pace as an intake signal** — `newLinesPerDay` gates the intake surface (`sabaqIntakeActive`: `0` ⇒ paused/off, positive ⇒ active), **not** the engine's consolidating New band (which the time budget already bounds — a pace cap there would starve consolidation). A real one-write "pause new sabaq" sets the pace to 0. The engine's existing budget-first, manzil-never-dropped load balancer (§7.9) is unchanged.
- **The transactional intake write path** — a new `SabaqIntakeRepository.startMemorizing(profileId, pageId, …)` that, in one `db.transaction`, inserts the seed card and appends a provenance `review_log` row, persist-before-republish. `CardRepository` stays read-only; no raw upsert from a widget.
- **The "I'm just starting" onboarding branch** — a beginner path that allows **zero held juz**, relaxes the `coverage.isNotEmpty` advance gate for that branch, explains *"mark pages as you memorize them,"* and reaches the placement commit so a from-zero user can finish onboarding into a working (initially empty, ready-to-grow) schedule.
- **Per-profile placement** — a reachable entry point into the already-built `ProfileId`-keyed onboarding/placement controller so an **in-app-created** student/child profile can run placement (or begin a sabaq loop) instead of being seeded `const []` forever.
- **The reader intake surface** — *"I've memorized this page / start revising here"* on the muṣḥaf reader (PRD §12.3), handing the write off to `SabaqIntakeRepository` through the single write path (the reader itself mutates no card, per E13).
- **The Today intake surface** — a *"start a new lesson"* entry from Today's (currently unreachable) New (sabaq) section, and the guided daily new-lesson revision surfacing the current + previous sabaq page(s) "repeated to sign-off" (§7.8), grouped old-before-new.
- **Making the dead controls live (F11)** — `newLinesPerDay` (onboarding + settings steppers) actually pacing intake, and **"pause new sabaq"** becoming a persisted flag the day-builder honors (framed as protection), not a no-op deep-link.
- **Prayer-critical seeding (F18)** — allowing a page to be born `isPrayerCritical` at intake (or from a curated, scholar-review-flagged preset: al-Fātiḥa, al-Mulk, al-Kahf …) so the engine's already-honored 0.97 floor is finally reachable.
- **The beginner-from-zero integration journey** and per-locale (fa/ckb/ar) widget + golden coverage of every new surface and state.

### Out of scope

- The FSRS **D/S/R math, the trust clamp, `onReview`, the graduation gate, and `buildToday`'s ordering/load-balance arithmetic** → owned by **E04**; this epic *seeds* pages into that engine and reads its config, it does not re-derive schedule math.
- The **recite/grade flow, the four-grade band, the sacred-text cap, and the `review_log` grade write** → owned by **E12**; a newly-memorized page is graded through E12's existing pipeline once it is a card.
- The **immutable muṣḥaf glyph rendering** the reader surface sits on → owned by **E13**; this epic adds one intake affordance to that reader, it renders/re-typesets no āyah.
- **Mutashābihāt sibling-massing and confusion edges** → owned by **E14**; a new page enters the normal loop and is picked up by E14 when it becomes confusable.
- The **cycle-preset / time-budget / profile-switcher settings plumbing and the halaqa loop** → owned by **E16**; this epic consumes the active profile + `CycleConfig` and adds only the intake-relevant wiring.
- The **retention heat-map** the new pages will appear in → owned by **E15**.
- Any **literal line-by-line multi-day sabaq-building sub-model** → explicitly deferred pending the design decision above and scholarly/pedagogical review.
- Registering a **numeric new-lines/day recommendation** → out of scope by decision (the traditional "3–5 lines/day" is `[TRAD]` prose in `docs/science/10-traditional-hifz-methodology.md`, not a registered CLAIMS row, so no number is shown; the control ships opt-in with default 0).

## Dependencies

### Depends on

- **E04 scheduling-engine** — the `Card`/`ReviewTrack` model, `bandForStability`, the trust clamp, `coldStartCard` (the seed pattern this epic mirrors), `buildToday`/`loadBalance` (which gain a `newLinesPerDay` read + pause gate), and `EngineConfig` (whose reserved intake slot this epic fills).
- **E03 domain-models & persistence** — the `Cards` table + `CardDao` insert primitives, the append-only `review_log`, and the single-transaction write discipline the intake repository rides.
- **E07 app-shell-walking-skeleton** — the Riverpod composition root, the injected `CalendarDate` clock, the `go_router` RTL shell, and the persist-before-republish seam.
- **E11 onboarding-and-cold-start** — the coverage/confidence/placement flow the beginner branch extends and the `ProfileId`-keyed onboarding controller the per-profile placement path finally reaches.
- **E12 today-and-recite-grade** — the Today list + New (sabaq) section this epic populates with an intake entry, and the recite/grade pipeline a new page is graded through.
- **E13 muṣḥaf-reader** — the display-only reader surface the *"I've memorized this page"* affordance is added to.
- **E16 settings-profiles-teacher** — the `CycleConfig` (`newLinesPerDay`), the profiles surface the placement entry point lives near, and the pause control.

### Enables

E15 (newly-memorized pages appear in the heat-map and its weakest-first rollups), E20 (the beginner-from-zero journey becomes part of the release-blocking acceptance run, and the "pause new sabaq" / "never drop manzil for new" behavior is an adab checkpoint item). Closes audit blockers **F01, F02, F04** and majors **F11, F18**.

## Foundation inputs

| Input | Where (doc / skill / code) | What this epic takes from it |
|---|---|---|
| The three tracks as one card's lifecycle | docs/PRD.md §6.2, §7.4 | sabaq/sabqi/manzil = NEW/NEAR/FAR phases of one page card; graduate as `S` grows (New→Near needs stability + sign-offs; Near→Far needs `S ≥ FAR_MIN_S` + outside the recent window); a lapse demotes — intake produces a page that *starts* at NEW |
| Building the day + throttling new | docs/PRD.md §7.8, §7.9 | `day = far + near + new`, recited old-before-new; `newToday = sabaqLines(new_lines_per_day)`; **NEW only if budget remains and yesterday's sabaq is consolidated**; on overflow, offer *pause new sabaq* — never drop manzil |
| Conservative cold-start / err-early | docs/PRD.md §7.6, §7.10 | Priors deliberately under-estimate strength; `due = min(ideal, ceiling)` with a non-null `due_at` from entry — the intake seed obeys both |
| Engine invariants | docs/PRD.md §7.12 | manzil never dropped; never "safe to drop"; teacher supersedes; pure/deterministic/golden-tested — every intake path is written against these |
| Onboarding & the beginner personas | docs/PRD.md §3 (P2 active memorizer, P3 adult late-starter), §5, §12.1 | Beginners/active memorizers are in scope; onboarding today captures only *held* juz — the branch this epic adds is the missing from-zero path |
| Reader intake affordances | docs/PRD.md §12.3 | *"Mark my memorized range"* (feeds coverage) and *"start revision here"* — the reader affordances this epic implements as writes handed to the intake path |
| Custom cycle / new-lines control | docs/PRD.md §15.1 | `new_lines/day` is a Custom-preset field — the control this epic finally wires to the engine |
| Persistence & the intake write | docs/engineering/05-persistence-and-encryption.md (`new_lines_per_day` default 0), 03-* single write path | Ships opt-in (default 0); the transactional, append-only, persist-before-republish write the intake repository must use |
| Traditional method (context, not a shown number) | docs/science/10-traditional-hifz-methodology.md §1–§2 | sabaq / sabqi / manzil framing and the review-heavy, "protect what's earned" ethos — its numeric figures are `[TRAD]` prose, **not** registered, so they are not surfaced |
| Skill: scheduling-engine rules | .claude/skills/domain-scheduling-engine-rules | The trust clamp, cold-start priors, load-balancer/pause semantics, and "never safe to drop" the intake primitive + its consumption must honor |
| Skill: engine golden vector | .claude/skills/eng-write-engine-golden-vector | The frozen golden-vector + `glados` property discipline any engine change (config field, seed primitive, throttle) is pinned by |
| Skill: onboarding placement | .claude/skills/ (onboarding/cold-start) | The coverage/confidence/placement contract the beginner branch and per-profile path extend without breaking the "un-held → no card" rule for the *maintaining* ḥāfiẓ |
| Skills: adab & claims | .claude/skills/domain-adab-and-religious-integrity, domain-claims-register-and-science-screen | No streaks/scores on sabaq; "pause" = protection, never failure; servant-to-teacher; every shown number traces to a graded CLAIMS row first (here: none shown) |
| Skills: engineering scaffolding | .claude/skills/eng-add-feature-module, eng-create-riverpod-store, eng-define-service-boundary, eng-persist-on-every-change, eng-rtl-and-bidi-layout, eng-add-localized-string, eng-write-dart-test | The intake module anatomy, the transactional write path, the injected clock, the ARB/RTL pipeline, and the test harness |
| CLAIMS behind the loop | docs/science/CLAIMS.md — C-034, C-024, C-040, C-014, C-009, C-016, C-007 | Tracks-as-phases (C-034), fluency-gates-graduation (C-024), overlearn-then-cycle (C-040), tradition-is-SR (C-014), err-early priors (C-009), the cycle guarantee/trust clamp (C-016), growing gaps (C-007) — the graded, sourced basis for the loop's behavior |

## Deliverables

- [ ] **Engine:** a pure `sabaqSeed(...)` intake primitive (NEW track, conservative priors, trust-clamped `due_at = today`), golden-vector tested; the D/S/R math, trust clamp, and load balancer are unchanged. The sabaq **pace** lives in the feature layer as an intake signal (`sabaqIntakeActive`) + a one-write "pause" — never an `EngineConfig` field or a cap on the consolidating New band.
- [ ] **Data:** `SabaqIntakeRepository.startMemorizing(...)` — one transaction inserting the seed card + appending a provenance `review_log` row, persist-before-republish; `CardRepository` unchanged (read-only); unit + crash-safety tests.
- [ ] **Onboarding:** the "I'm just starting" branch — zero held juz allowed, the gate relaxed for that path, calm explanatory copy, and a clean placement commit into an empty-but-ready schedule (F02).
- [ ] **Profiles:** a reachable per-profile placement entry point so an in-app student/child profile runs placement / starts a loop instead of `const []` (F04).
- [ ] **Reader surface:** *"I've memorized this page / start revising here"* (§12.3) → intake write path; the reader mutates no card.
- [ ] **Today surface:** a *"start a new lesson"* entry from the New (sabaq) section + the guided daily new-lesson revision (old-before-new, repeated to sign-off).
- [ ] **Wiring (F11):** `newLinesPerDay` consumed by the engine; **"pause new sabaq"** a persisted flag the day-builder honors, framed as protection.
- [ ] **Prayer-critical (F18):** intake can birth `isPrayerCritical` (or a curated, review-flagged preset) → the 0.97 floor becomes reachable.
- [ ] **Tests:** the beginner-from-zero integration journey (onboard zero-juz → start memorizing a page → it enters the day → grade → it graduates New→Near) + per-locale (fa/ckb/ar) widget/goldens on real bundled fonts + an `HttpOverrides` offline guard.

## Definition of Done

- [ ] A from-zero beginner can complete onboarding, mark a page memorized from the reader **or** Today, see it enter the day, recite/grade it through the existing pipeline, and watch it graduate — end-to-end on the real spine, surviving a kill-and-relaunch.
- [ ] An in-app-created student/child profile can run placement / begin a sabaq loop instead of being permanently empty (F04).
- [ ] **Offline / no-network / no-AI / no-microphone:** every intake surface is taps only; an `HttpOverrides` offline guard test passes; nothing records, transcribes, or infers.
- [ ] **Engine untouched where it must be:** the D/S/R math, trust clamp, `onReview`, and graduation gate are unchanged; intake is a *seed* act producing a conservative-prior, trust-clamped (`due ≤ ceiling`, non-null) NEW card; the engine's golden vectors + `glados` invariants stay green (any new config field/primitive gets its own frozen vectors).
- [ ] **Never "safe to drop" / manzil never dropped:** adding new pages never displaces a due manzil/FAR item; "pause new sabaq" pauses *new intake only* and never implies any page is safe to stop revising (§7.9, §7.12).
- [ ] **Single write path / persist-before-republish:** every intake mutation is one `db.transaction` (seed card insert + append-only `review_log`), committed before the in-memory state republishes; `CardRepository` exposes no write; no widget upserts a card.
- [ ] **Conservative priors / honest pacing:** a newly-memorized page enters under-estimated (first real recitation can only surprise upward); `newLinesPerDay` ships opt-in (default 0); **no numeric new-lines recommendation is shown** (no registered CLAIMS row exists for one).
- [ ] **Servant to the teacher:** a new page's graduation still requires the sign-offs the engine already gates on; nothing here weakens teacher authority.
- [ ] **No gamification / no shame:** no streak, count-up, badge, "pages learned" score, or celebration on any intake or sabaq surface; the beginner's empty start reads as calm and ready, never "0 / behind"; "pause new sabaq" is framed as protecting what's earned.
- [ ] **RTL + fa/ckb/ar:** every new string (the intake affordances, the beginner branch copy, the pause framing, the guided-revision headers) ships through the ARB pipeline in all three locales via the swappable term-sets, RTL by geometry, locale numerals bidi-isolated; religious/beginner copy is flagged for scholarly review; no hardcoded user-facing string.
- [ ] **Accessibility:** every intake affordance is ≥48dp, announces its label + consequence, and carries state by more than color; reduce-motion honored; the per-screen audit passes.
- [ ] **Adab & claims:** every new label cleared the adab conscience pass and banned-phrase lint in all three locales; any user-facing methodology copy traces to a graded CLAIMS row (C-034/C-024/C-040/C-014/C-009/C-016/C-007) or is not shown.
- [ ] **Tests:** the intake primitive + repository are test-first; the beginner-from-zero integration journey and per-locale goldens run in CI on the real bundled fonts; all existing gates (engine purity, no-network, adab, l10n, claims coverage) stay green.

## Tasks

> **Build status (2026-07-11).** The sabaq loop is **functionally complete and
> tested end-to-end**: T01 (engine seed), T02 (write path), T03 (pace + pause),
> T04 (zero-juz beginner onboarding), the shared intake controller, T07 (reader
> "I've memorized this page"), T06 (Today "start a new lesson"), and T09 (the
> pure-engine lifecycle proof) are built and green — a beginner can start from
> zero and any ḥāfiẓ can grow their hifz page by page (F01/F02/F11 closed).
> **T08** (prayer-critical, F18) and **T05** (per-profile placement re-run, F04
> residual) are specced but not built — each is blocked on an explicit decision
> (T08: the marking affordance + scholarly review for any preset; T05: a risky
> E16 router change, and the blocker is already resolved by the intake surfaces).
> The UI tasks' per-locale goldens regenerate on the Linux CI lane.

> Ordering: engine seed + config (T01) and the transactional write (T02) first; then the engine consumption/pause (T03); then the two entry surfaces (T04 onboarding, T06 Today, T07 reader) and profiles (T05); prayer-critical (T08) and the integration/goldens (T09) close it. T01/T06 implement the resolved **page-granular** design.

| ID | Task | Size | Depends on |
|---|---|---|---|
| E21-T01 | Engine: `EngineConfig.newLinesPerDay` + pure `sabaqSeed` intake primitive (NEW track, conservative priors, trust-clamped `due_at=today`), golden-vector + property tested | L | E04 |
| E21-T02 | Data: `SabaqIntakeRepository.startMemorizing` transactional writer (seed card insert + append-only `review_log`, persist-before-republish); `CardRepository` stays read-only; unit + crash-safety tests | M | E03, E21-T01 |
| E21-T03 | Sabaq pace + real "pause new sabaq" (F11): remove the superfluous `EngineConfig.newLinesPerDay` (the pace is an *intake* signal, not an engine cap — a cap on the consolidating New band would starve it), add the pure `sabaqIntakeActive(CycleConfig)` signal the surfaces gate on, and `CycleConfigWriter.pauseNewSabaq()` (pace → 0, no migration) | S–M | E21-T01, E16 |
| E21-T04 | Onboarding "I'm just starting" branch: zero held juz allowed, gate relaxed for the branch, calm copy, clean placement commit into an empty-ready schedule (F02) | L | E11, E21-T02 |
| E21-T05 | Per-profile placement: reach the built-but-unreachable `ProfileId`-keyed onboarding controller so in-app profiles run placement / start a loop (F04) | M | E21-T04, E16 |
| E21-T06 | Today intake surface: *"start a new lesson"* entry from the New (sabaq) section + the guided daily new-lesson revision (old-before-new, repeated to sign-off, §7.8) | L | E12, E21-T02 |
| E21-T07 | Reader intake surface: *"I've memorized this page / start revising here"* (§12.3) → intake write path; reader mutates no card | M | E13, E21-T02 |
| E21-T08 | Prayer-critical seeding at intake (F18): a page can be born `isPrayerCritical` (or a curated, review-flagged preset) → the 0.97 floor becomes reachable | M | E21-T02 |
| E21-T09 | Beginner-from-zero integration journey (onboard zero → start memorizing → enter day → grade → graduate) + per-locale goldens + offline guard | M | E21-T04, E21-T06, E21-T07 |

## Risks

- **Scope creep into a memorization course.** The sabaq surface invites lesson-scheduling, content presentation, or audio — all against the positioning and the no-AI/no-microphone floor. *Mitigation:* intake only *seeds* a page into the existing maintenance engine; the reader stays display-only; no content is taught, presented, or recorded; the "Open design decision" fences the line-by-line build behind explicit sign-off.
- **Touching the frozen engine.** Adding a config field or a seed primitive risks perturbing the golden-tested D/S/R math or the trust clamp. *Mitigation:* intake is a pure *seed* (like `coldStartCard`), never a new transition or math change; every engine addition gets its own frozen golden vectors + `glados` invariants; the existing vectors must stay byte-identical.
- **New pages crowding out manzil.** A naïve intake could let new sabaq displace mandatory manzil/FAR review. *Mitigation:* old-before-new and budget-first are the engine's (§7.9); a property test asserts no due manzil item is ever dropped to admit a new page; "pause new sabaq" throttles *new only*.
- **A dishonest empty-start reads as "behind."** A beginner's empty schedule could feel like a 0-score failure. *Mitigation:* the empty state is the calm "ready to grow" surface, never a count or a shame-pile; adab review + the banned-phrase lint gate every word.
- **Showing an unsourced pacing number.** The traditional "3–5 lines/day" is tempting to surface. *Mitigation:* it is `[TRAD]` prose, not a registered CLAIMS row — the control ships opt-in with no recommended number; the claims-coverage gate would fail any bundled number without a row.
- **Reviving the unreachable placement controller wrong.** The `ProfileId`-keyed controller is dead code; re-wiring it could mis-scope writes to the wrong profile. *Mitigation:* the integration journey asserts a per-profile placement writes only that profile's cards/log; the halaqa write-isolation test (E16) stays green.
- **Prayer-critical becomes a curated fatwa.** A bundled "prayer-critical" surah list edges toward a religious ruling. *Mitigation:* the preset is flagged for scholarly review and framed as a user-editable convenience (a retention *floor*, not a fiqh claim); the user may mark any page; nothing is presented as an obligation.

## References

- docs/PRD.md — §2 (positioning: maintenance, not a course), §3 (P2/P3 personas), §5 (in scope: partial/complete cold-start), §6.2 (tracks as one card's phases), §7.4 (graduation gates), §7.6/§7.10 (trust clamp, conservative priors), §7.8–§7.9 (build-the-day, sabaqLines, load-balance/pause), §7.12 (engine invariants), §12.1 (onboarding), §12.3 (reader "mark my range"/"start revision here"), §15.1 (Custom cycle: new-lines/day); R3/R5/R6, C1/C2/C6
- docs/engineering/05-persistence-and-encryption.md (`new_lines_per_day` default 0), 06-scheduling-engine.md (load-balance / pause semantics), 03-* (single write path)
- docs/science/CLAIMS.md — C-034, C-024, C-040, C-014, C-009, C-016, C-007; docs/science/10-traditional-hifz-methodology.md §1–§2 (context only; figures are `[TRAD]`, not shown)
- docs/audits/2026-07-10-full-app-audit.md — F01 (no sabaq intake), F02 (zero-juz beginner blocked), F04 (empty in-app profiles), F11 (dead new-lines/pause controls), F18 (prayer-critical never seeded)
- .claude/skills/ — domain-scheduling-engine-rules, eng-write-engine-golden-vector, domain-adab-and-religious-integrity, domain-claims-register-and-science-screen, eng-add-feature-module, eng-create-riverpod-store, eng-define-service-boundary, eng-persist-on-every-change, eng-rtl-and-bidi-layout, eng-add-localized-string, eng-write-dart-test
- Code seams this epic fills — `packages/engine/lib/src/build_today.dart:104-106` &amp; `load_balance.dart:74-75` (intake deferral), `engine_config.dart:19-22` (reserved slot), `cold_start.dart:44-68` (the seed pattern to mirror), `packages/features/lib/src/today/review_recorder.dart:65-68` (the card-less throw intake removes), `onboarding/onboarding_view_model.dart:541` (the coverage gate F02), `onboarding/onboarding_providers.dart:15` (the unreachable per-profile controller F04), `profiles/profiles_controller.dart:57` (the `const []` seed F04)
