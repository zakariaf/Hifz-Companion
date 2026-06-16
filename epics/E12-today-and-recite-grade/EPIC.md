# E12 — Today & Recite/Grade

The core daily loop, assembled from the proven spine: the Today "revise today" list — finite, time-budget-capped, grouped **Far (manzil) → Near (sabqi) → New (sabaq)** in recitation order — with one honest line of budget feedback; the full-screen reveal-on-tap recite-from-memory flow with the four-grade band (Again / Hard / Good / Easy), stumble-line marking, and the in-flow teacher (talaqqī) sign-off that switches the grade's source from self to a present teacher; the calm catch-up banner after a gap; and the calm all-done / silent-resume states. No audio, no AI, no celebration: recall is judged by the human, the grade is the ḥāfiẓ's own honest verdict normalized through the grading pipeline, and the teacher always outranks the algorithm.

## Why this epic exists

The whole product exists because a ḥāfiẓ carries 600+ pages that decay **invisibly**, and the dominant failure is silent forgetting ([PRD §2](../../docs/PRD.md)). This epic is the one screen the user opens after ṣalāh — the daily ritual surface where the silent engine's three humble jobs (order the weakest first, flag decay before a page rots, fit the day into a time budget and re-spread after a gap) become a calm, finite list a teacher recognizes. E07 proved the spine works as a system (a minimal Today queue, a one-tap grade, a kill-and-relaunch-surviving write); this epic extends that minimal slice into the full reveal-on-tap recite/grade flow over the same single write path, without re-architecting the seam.

Three documented failure modes shape every decision here. First, the **dumping problem**: existing trackers fail by dumping an overwhelming or rigid pile of due items, so Today is a bounded queue capped to the user's time budget that visibly *ends*, never an infinite feed or a count-up, and a return after a gap shows the engine's re-spread catch-up plan, never a red overdue shame-pile ([PRD §7.9, §12.2](../../docs/PRD.md); `research/RESEARCH-FINDINGS.md` §2–§3). Second, **text fidelity** (R1): the recite surface masks and reveals the immutable KFGQPC glyph page composed by the reader — it never renders or re-typesets an āyah, and a stumble mark is a coordinate overlay on the immutable glyph layer. Third, **honesty and adab**: the grade is *suggested* from the stumble count but stays the user's own, the sacred-text guard means a dropped/added/swapped word is never "Good", a teacher sign-off always supersedes self-rating and algorithmic state (R6), and no surface here ever celebrates, gamifies, shames a gap, or tells a ḥāfiẓ a page is "safe to drop" (R3, C6). All of this is offline and microphone-free by construction (C1, C2, R5) — the only inputs are taps.

## Scope

### In scope

- The **Today screen** as a feature module: the dumb `Today` View + 1:1 view-model, a `StreamProvider` reading the engine + controller's pre-built day, wired into the E07 `ShellRoute` bottom-nav tab.
- The **daily-session list**: a single finite, time-budget-capped `ListView` grouped **Far (manzil) → Near (sabqi) → New (sabaq)**, recited old-before-new, with localized term-set section headers, that visibly ends — assembling the E10 page-card rows into the three sections.
- The list's **four states**: loading skeleton, populated, calm **all-done** terminal surface, and **catch-up** banner (composing the E10 empty-state family and catch-up banner).
- The **honest budget-feedback line**: when the chosen scope can't fit the daily time budget, one calm informational line offering *raise budget / lengthen cycle / pause new sabaq* — FAR/manzil due items are never dropped.
- The **catch-up banner** state: rendering the engine's pre-built re-spread plan (empathy → honest fact → concrete plan → choice) after a gap, most-decayed and prayer-critical first.
- The **all-done / silent-resume** states: a calm closing line when the day is complete; a silent resume into the normal day after a gap with nothing to catch up.
- The **recite/grade flow** as a full-screen route opened from a page-card tap: the masked muṣḥaf page over the E13 reader surface, reveal-on-tap line-by-line, ≥48dp stumble-line hit-areas drawing a coordinate overlay, the disabled-until-revealed four-grade band, the undo affordance, and the calm advance-to-next motion.
- **Stumble-line marking + the suggested grade**: capturing 1-based `errorLines`, suggesting the grade from the stumble count (user-confirmable), and raising the `missedOrAlteredWord` flag.
- The **grading pipeline**: normalizing the flow's taps into one `ReviewInput(grade, errorLines, source, missedOrAlteredWord)`, applying the sacred-text grade cap, tagging source confidence, appending the `review_log` row, and handing to `SchedulingEngine.onReview` through the single write path.
- The **in-flow teacher sign-off**: a "Teacher present" `Switch.adaptive` that changes only the verdict's `source` (self → teacher), the teacher-sourced marker on the resulting card/log, and the halaqa profile-switch → sign-off → next path on one device.
- An **integration journey** (cold-start seed → buildToday day → grade → next page → catch-up after a simulated gap) and the per-locale (fa/ckb/ar) widget + golden coverage of every state.

### Out of scope

- The page-card / track-chip / decay-indicator, grade-band, catch-up-banner, and empty-state **leaf widgets** themselves (anatomy, states, goldens) → owned by **E10 mihrab-component-library**; this epic *assembles* them into screens.
- The engine that **produces** the ordered, capped, load-balanced day and the catch-up re-spread (`buildToday`, `loadBalance`, FSRS D/S/R, trust clamp, `onReview` arithmetic) → owned by **E04 scheduling-engine**; this epic renders its output and feeds it grades.
- The **immutable muṣḥaf glyph rendering** the recite flow masks and overlays (KFGQPC fonts, layout geometry, the overlay painter) → owned by **E13 muṣḥaf-reader**.
- Pulling **mutashābihāt siblings** into the session and the swap-error confusion-edge bookkeeping → owned by **E14 mutashabihat-trainer**; the flow only records the stumble lines it feeds on.
- The **cold-start placement** flow that seeds the first day (coverage capture, per-juz Solid/Shaky/Rusty) → owned by **E11 onboarding-and-cold-start**; this epic consumes the seeded cards.
- The **cycle-preset / time-budget settings** and the **local-profile / halaqa switcher** plumbing → owned by **E16 settings-profiles-teacher**; this epic uses the active profile and config.
- The **retention heat-map** and progress stats → owned by **E15 progress-and-heatmap**.
- The **local-notification** scheduling of the "catch-up ready" note → owned by **E18 reminders**.

## Dependencies

### Depends on

- **E04 scheduling-engine** — `buildToday(profile, today)` produces the grouped, capped, ordered day this epic renders; `onReview(card, review, today)` consumes the normalized grade; the re-spread plan and trust clamp are the engine's, never the View's.
- **E07 app-shell-walking-skeleton** — the Riverpod composition root, the `go_router` RTL `ShellRoute` bottom-nav Today tab, the injected `CalendarDate` clock, the Drift handle, and the persist-before-republish single write path the grade write rides.
- **E08 accessibility-foundation** — the `Semantics` label/value/role + merge/exclude conventions, the never-color-alone helper, the reduce-motion substitutions, the 48dp touch floor, and the PR-blocking audit harness the announce path for the list / grade / sign-off rides.
- **E09 localization-rtl-foundation** — the `gen_l10n` ARB pipeline (Arabic base), logical-inset `Directionality` layout, the FSI/PDI bidi-isolation helper, per-locale numerals, and the swappable sabaq/sabqi/manzil term-sets every string and page-identity run uses.
- **E10 mihrab-component-library** — the page card + track chip + decay indicator, the four-level grade band + sign-off toggle leaf, the catch-up banner, and the empty-state family this epic composes into the Today list and recite flow.

### Enables

E14 (the recite flow's stumble lines feed the mutashābihāt confusion edges and the trainer pulls siblings into the session), E15 (the heat-map echoes the per-page decay the Today rows surface and reads the `review_log` this flow appends), E20 (the recorded cold-start → review → catch-up integration journey becomes the release-blocking human a11y/RTL pass and the headline daily loop a reviewer exercises).

## Foundation inputs

| Input | Where (doc / skill) | What this epic takes from it |
|---|---|---|
| Today IA & the daily loop | docs/PRD.md §12.2 | The verbatim Today spec: finite/capped list grouped Far→Near→New in recitation order; recite flow (hidden → recite → reveal-on-tap → mark stumble → grade → next) with optional teacher sign-off; catch-up banner never a shame-pile; honest budget feedback |
| Grading (no-AI) | docs/PRD.md §8 | Self-rating via reveal-on-tap, lower source confidence; on-device teacher sign-off (`sourceConfidence = 1.0`, authoritative); the explicit "no microphone / no audio / no STT" boundary |
| Engine: building the day, load-balance, catch-up | docs/PRD.md §7.8–§7.9 | `buildToday` order (manzil → near → new), the mandatory-FAR / re-spread-never-dump catch-up plan, and the budget-overflow honesty the feedback line surfaces — all produced by the engine, rendered here |
| Component anatomies | docs/design-system/07-components.md §1–§7 | Daily-session list (§1), page-card placement (§2), recite/grade flow stages (§5), state model (§6), teacher sign-off control (§7) — the states, copy, motion, and a11y contract the screens instantiate |
| Skill: Today list | .claude/skills/ui-daily-session-list | The finite/capped/tradition-ordered list, localized section headers, four calm states, the honest budget-feedback line, RTL-by-geometry, the dumb-View rule |
| Skill: recite/grade flow | .claude/skills/ui-recite-grade-flow | Reveal-on-tap, the disabled-until-revealed four-button band, ≥48dp stumble hit-areas drawing a coordinate overlay, the undo affordance, calm motion, the in-flow sign-off toggle, reduce-motion |
| Skill: grading pipeline | .claude/skills/domain-grading-pipeline | The `ReviewInput(grade, errorLines, source, missedOrAlteredWord)` normalizer, the sacred-text grade cap, `kSelfConfidence`/teacher weighting, the append-only `review_log` write, the `onReview` hand-off |
| Skill: catch-up banner | .claude/skills/ui-catch-up-banner | The empathy → fact → plan → choice template, rendering the engine's pre-built re-spread, calm visual register, never-greet-the-gap, FAR-mandatory |
| Skill: page card | .claude/skills/ui-page-card | How a row is placed in the list (one ≥48dp tap, no glyphs, no D/S/R), the `MergeSemantics` phrase, the track + decay labels — the row whose internals E10 owns |
| Skill: empty state | .claude/skills/ui-empty-state | The calm all-done terminal surface, the silent welcome-back after a gap, the no-shame / no-celebration floor |
| Skill: teacher sign-off | .claude/skills/ui-teacher-signoff | The "Teacher present" `Switch.adaptive` source switch, the authoritative-verdict single-write-path, the teacher-sourced marker, the device-local halaqa path |
| Adab guardrails | .claude/skills/domain-adab-and-religious-integrity | The conscience-check on every verdict label, decay framing, budget/catch-up copy, and term-set: no guilt/fear/loss, never "safe to drop", servant-to-the-teacher, sect-neutral |
| Engineering scaffolding | .claude/skills/eng-add-feature-module, eng-create-riverpod-store, eng-define-service-boundary, eng-rtl-and-bidi-layout, eng-write-dart-test | The `features/today/` module anatomy, the StreamProvider + single-write-path controller, the injected clock (never `DateTime.now()`), the bidi/mirroring primitives, and the per-locale widget/golden/integration test harness |
| CLAIMS behind any number | docs/science/CLAIMS.md | Any user-facing number or methodology copy (the re-spread "M-day plan", the budget line, the testing-effect framing) traces to a graded, sourced CLAIMS row before it ships |

## Deliverables

- [ ] `features/today/` feature module: the dumb `Today` View, its 1:1 view-model, scoped providers, and the `ShellRoute` bottom-nav wiring (RTL order) on the E07 spine.
- [ ] The daily-session list: a finite, budget-capped `ListView` grouped Far→Near→New with localized term-set section headers, assembling E10 page-card rows, that visibly ends.
- [ ] The four list states wired to the controller's read model: loading skeleton, populated, all-done terminal surface, catch-up banner.
- [ ] The honest budget-feedback line (raise budget / lengthen cycle / pause new sabaq), FAR/manzil never dropped.
- [ ] The catch-up banner: empathy → fact → plan → choice, rendering the engine's pre-built re-spread, never a red shame-pile, never a "welcome back, N days" greeting.
- [ ] The all-done and silent-resume empty states (no celebration, no greeting, no streak).
- [ ] The full-screen recite/grade route: masked page over the E13 reader surface, reveal-on-tap, ≥48dp stumble-line hit-areas drawing a coordinate overlay, disabled-until-revealed four-grade band, undo affordance, calm advance motion.
- [ ] The grading pipeline: the `ReviewInput` normalizer, stumble-count → suggested grade, the sacred-text cap, source-confidence tagging, the append-only `review_log` write, and the `onReview` hand-off through the single write path.
- [ ] The in-flow teacher sign-off: the "Teacher present" `Switch.adaptive` source switch, the teacher-sourced marker on the card/log, and the device-local halaqa profile-switch → sign-off → next path.
- [ ] Test-first pipeline unit suite (sacred-text cap, source confidence, teacher override, append-only log) + the cold-start → buildToday → grade → next → catch-up integration journey.
- [ ] Per-locale (fa/ckb/ar) widget + golden coverage of every Today state and every recite/grade stage on the real bundled fonts, with an `HttpOverrides` offline guard.

## Definition of Done

- [ ] The daily loop works end-to-end on the E07 spine: open Today → see the engine's grouped, capped, ordered day → tap a page → recite on a hidden page → reveal → mark stumbles → grade → advance to next → the new card state survives a kill-and-relaunch.
- [ ] **Offline / no-network**: no surface in this epic opens a socket; an `HttpOverrides` offline guard test passes; the only inputs are taps.
- [ ] **No AI / no audio / no microphone**: no recording, no speech-to-text, no on-device model, no mistake-detection anywhere in the recite or grade path (C2, R5).
- [ ] **Text fidelity (R1)**: the recite flow masks/reveals the immutable glyph page composed by the E13 reader and never renders or re-typesets an āyah; every stumble mark is a coordinate overlay on the immutable glyph layer, never a re-layout.
- [ ] **Sacred-text guard**: a dropped/added/swapped word sets `missedOrAlteredWord` and caps the normalized grade at `Grade.hard` in the pipeline before the `ReviewInput` is emitted; a property test proves a dropped word is never "Good".
- [ ] **Servant to the teacher (R6)**: a teacher sign-off changes only the `source` (self → teacher, conf 0.5 → 1.0), is authoritative, and is never silently overridden by a later self-grade or the algorithm; the verdict is persisted before republishing through the single write path and appended to `review_log` with `source = teacher`.
- [ ] **No gamification / no shame (R3, C6)**: no streaks, badges, scores, XP, completion %, confetti, fanfare, or success haptic on any state, grade, or sign-off; all-done is a calm closing line; a return after a gap shows the calm re-spread plan, never a red overdue pile or a "welcome back, N days" greeting; nothing is ever "safe to drop".
- [ ] **The View is dumb**: it renders the engine + controller's pre-built, capped, ordered day and the injected `CalendarDate`; it never sorts/caps/load-balances, never calls the engine for the schedule, never reads `DateTime.now()`; reads are `StreamProvider`s over Drift and the grade flows through the single write path (persist-before-republish), never mutated in a widget.
- [ ] **RTL + fa/ckb/ar localization**: every string (section headers, verdicts, "reveal", budget/catch-up copy, sign-off, page identity) ships through the ARB pipeline in fa/ckb/ar via swappable term-sets; layout is RTL by geometry (`EdgeInsetsDirectional`/`AlignmentDirectional`); page/juz/day/page counts render in the locale numeral set with mixed runs bidi-isolated (FSI/PDI); ckb's longer copy reflows; no hardcoded user-facing string; no truncation of a load-bearing label.
- [ ] **Accessibility (WCAG 2.2 AA)**: the list announces "Revise today" with section roles; each row is one merged labelled phrase; each grade button announces its verdict *and* its consequence; the disabled grade band reads as *waiting* with a visible focus ring; the sign-off toggle announces label + state; every interactive target is ≥48dp; reduce-motion degrades every transition to a cross-fade/instant cut; the per-screen accessibility audit passes.
- [ ] **Sect-neutral adab**: every verdict label, decay framing, budget/catch-up string, and term-set has cleared the adab review — no fiqh ruling, no app-as-authority phrasing, autonomy-supportive in each locale.
- [ ] **Tests**: the grading-pipeline unit suite is written test-first and green; the §7.12-touching invariants exercised here (sacred-text cap, teacher override) are property-tested; the integration journey and per-locale state goldens run in CI on the real bundled fonts; all gates stay green.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E12-T01 | [Today feature module + dumb View/view-model + ShellRoute tab wiring on the E07 spine](E12-T01-today-feature-module-and-tab.md) | M | E07, E09 |
| E12-T02 | [Today controller: StreamProvider read model over buildToday + the four list states, no engine calls in the View](E12-T02-today-controller-read-model.md) | M | E12-T01, E04 |
| E12-T03 | [Daily-session list: finite, budget-capped Far→Near→New sections assembling E10 page-card rows, RTL by geometry](E12-T03-daily-session-list.md) | L | E12-T02, E10, E08 |
| E12-T04 | [Honest budget-feedback line + all-done / silent-resume empty states, no-shame invariants](E12-T04-budget-feedback-and-empty-states.md) | M | E12-T03, E10 |
| E12-T05 | [Catch-up banner state: render the engine's pre-built re-spread plan, empathy→fact→plan→choice](E12-T05-catch-up-banner-state.md) | M | E12-T03, E10 |
| E12-T06 | [Grading pipeline (test-first): ReviewInput normalizer, sacred-text cap, source confidence, review_log append, onReview hand-off](E12-T06-grading-pipeline.md) | L | E04, E07 |
| E12-T07 | [Recite/grade route: masked reader page, reveal-on-tap, stumble hit-areas as coordinate overlay, disabled-until-revealed band, undo](E12-T07-recite-grade-route.md) | L | E12-T06, E13, E10, E08 |
| E12-T08 | [In-flow teacher sign-off: "Teacher present" source switch, teacher-sourced marker, device-local halaqa path](E12-T08-teacher-signoff-in-flow.md) | M | E12-T07, E12-T06 |
| E12-T09 | [Integration journey (cold-start → buildToday → grade → next → catch-up) + per-locale state/stage goldens + offline guard](E12-T09-integration-journey-and-goldens.md) | M | E12-T04, E12-T05, E12-T08 |

## Risks

- **The View reaches across the boundary and does the engine's job.** Tempting to sort, cap, or compute the catch-up spread in the widget. *Mitigation:* the controller renders only the engine's pre-built day; a code-review rule and the integration journey assert the View calls no engine schedule method and never reads `DateTime.now()`; the injected `CalendarDate` owns "today" (eng-define-service-boundary).
- **Breadth creep into the recite surface.** The reader (glyph rendering), the mutashābihāt sibling-massing, and the heat-map all border this flow and invite "while I'm here" additions. *Mitigation:* this epic masks/overlays the E13 page and only *records* stumble lines; glyph rendering, sibling-massing (E14), and the heat-map (E15) are rejected in review and filed against the owning epic.
- **A dishonest or audio-faked grade lets a page drift silently.** The grade is the single most consequential engine input. *Mitigation:* reveal-on-tap forces a real recall attempt before the band enables; the sacred-text guard caps a missed-word grade at Hard in the pipeline (property-tested); self-rating alone cannot reach the top retention tier without a teacher sign-off; no microphone exists by construction.
- **A teacher verdict gets silently overwritten.** A later self-grade or an algorithmic update could clobber an authoritative sign-off. *Mitigation:* the sign-off persists through the single write path before republishing and is appended (never updated) to `review_log`; a widget/golden test asserts a teacher verdict beats a prior self-grade and the teacher-sourced marker renders.
- **A gap reads as failure.** A blank or backlogged Today after a missed gap can land as shame. *Mitigation:* the catch-up banner follows empathy → fact → plan → choice and renders the engine's re-spread (never a red pile); the silent-resume path greets nothing; the never-ship banned-phrase lint and the adab review gate every word.
- **Celebration leaks in through motion or haptics.** A "subtle" success animation on a Good/Easy would violate the no-gamification floor. *Mitigation:* Good/Easy fires the *same* calm path as Again (`haptic.confirm` + a state change only); goldens and the motion/haptic checklist forbid any celebratory tier; reduce-motion is honoured.

## References

- docs/PRD.md — §12.2 (Today & recite flow), §8 (grading: self + on-device teacher, no-AI/no-audio), §7.8–§7.9 (building the day, load-balance, catch-up re-spread), §6.2–§6.3 (tracks, the four-grade scale), §7.12 (engine invariants), §13 (localization & RTL), §18 (accessibility), R1/R3/R5/R6, C1/C2/C6
- docs/design-system/07-components.md — §1 daily-session list, §2 page-card placement, §5 recite/grade flow, §6 state model, §7 teacher sign-off
- docs/science/CLAIMS.md — the graded, sourced rows behind any user-facing number or methodology copy on Today / in the recite flow / in the catch-up plan
- .claude/skills/ — ui-daily-session-list, ui-recite-grade-flow, domain-grading-pipeline, ui-catch-up-banner, ui-page-card, ui-empty-state, ui-teacher-signoff, domain-adab-and-religious-integrity, eng-add-feature-module, eng-create-riverpod-store, eng-define-service-boundary, eng-rtl-and-bidi-layout, eng-write-dart-test
