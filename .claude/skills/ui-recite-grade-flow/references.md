# references — ui-recite-grade-flow

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/design-system/07-components.md` §5 (The recite/grade flow: reveal-on-tap, then a four-level grade) — **The whole flow, verbatim.** Page hidden → recite from memory → reveal line-by-line on tap → tap stumble lines → grade Again/Hard/Good/Easy → next. The grade band **stays disabled until at least one reveal** so a grade follows a real recall attempt; grades are four large `FilledButton`s (≥56dp tall, ≥48dp wide, `space.2` apart) in **RTL verb order**; the grade is *suggested* from the stumble count but **user-confirmable**; stumble-line tapping **grows each glyph line's hit-area to ≥48dp** and draws a **coordinate overlay** on the immutable glyph layer (never re-typeset); a submitted grade is **undoable**; motion is short/medium with the page→recite hero the only `emphasized`/`long` exception; **no microphone, no celebration**. Take: this is the shape — implement exactly this, do the math nowhere.

- `docs/design-system/07-components.md` §6 (Grade band & component states) — **The explicit state model.** enabled / pressed / disabled / focused / selected via **M3 state layers** over role colors (never ad-hoc opacity); the **disabled (pre-reveal) band reads as *waiting*** with a quiet "reveal to grade" hint, not a crash; a **visible focus ring** (`color.outline`) is required (`WCAG 2.2 SC 2.4.7`); `FilledButton`s are chosen over `SegmentedButton` for thumb-zone size; states mirror in RTL and are announced via `Semantics` flags. Take: model the states from tokens; disabled is intentional, not an error.

- `docs/design-system/07-components.md` §7 (The teacher sign-off control) — **The human override, made first-class.** A labelled `Switch.adaptive` ("Teacher present") in the grade band's lower region switches the verdict's **source** self→teacher; a teacher-sourced grade is **visually marked** so self/teacher are never conflated; copy stays **autonomy-supportive** ("for your teacher to confirm"), never commanding; in local halaqa mode a teacher switches profiles on one device. Take: this UI reports `source` and marks it distinctly; the *override semantics* belong to the pipeline.

- `docs/design-system/06-motion-and-haptics.md` §1 (Motion is calm and informative: short/medium ladder, standard easing) — **The motion budget.** `motion.duration.short` (150ms) for reveal-on-tap line reveal and grade-press feedback; `motion.duration.medium` (250ms) for transitions; `motion.curve.standard` for all routine motion; `motion.curve.emphasized` reserved for the single page→recite hero; no M3 Expressive spring/overshoot. The recite/grade flow is named here as "where motion earns its keep." Take: every animation resolves to a `motion.*` token; never inline a `Duration`/`Curve`.

- `docs/design-system/06-motion-and-haptics.md` §2 (Motion never celebrates) — **The single non-negotiable.** No confetti, fanfare, reward animation, streak flame, or "well done" pulse exists; a Good/Easy grade is acknowledged by calm copy + a quiet state change. There is **no `motion.celebrate.*` token**. Take: the grade landing is a receipt, not a reward — same path for every verdict.

- `docs/design-system/06-motion-and-haptics.md` §4 (The haptic vocabulary) — **Exactly three light pulses.** `haptic.selection` (`HapticFeedback.selectionClick()`) on a discrete reversible choice — **the named example is "tapping a stumble-line during reveal-on-tap"**; `haptic.confirm` (`HapticFeedback.lightImpact()`) when **a grade is recorded / a teacher sign-off lands**; `haptic.warning` for a gentle caution. **No success/reward haptic.** Each always accompanies an on-screen change and honours the OS haptics setting. Take: stumble-tap = selection, grade-commit = confirm, nothing celebratory.

- `docs/design-system/06-motion-and-haptics.md` §5 (Reduce-motion is honoured absolutely) — **The OS flag always wins.** Read `MediaQuery.disableAnimations`; substitute a cross-fade or instant cut; the page→recite hero collapses to a plain push; nothing in this flow is information-bearing in motion alone, so disabling it costs nothing. Take: branch motion at one helper, degrade everything, apologise for nothing.

- `docs/PRD.md` §8.1 (Self-rating) — **The primary flow contract.** After reciting **from memory**, the user grades Again/Hard/Good/Easy; the primary flow is **reveal-on-tap** (page hidden; recite; reveal line-by-line; tap stumble lines; grade *suggested* from the stumble count, still user-confirmable); self-rating carries **lower confidence (`sourceConfidence ≈ 0.5`)** and alone cannot push a page to the top retention tier without a teacher sign-off. Take: the flow exists to make self-rating honest; this UI captures it, the pipeline weights it.

## Supporting

- `docs/PRD.md` §12.2 — **The flow, one line.** "page hidden → recite from memory → reveal-on-tap → mark stumble lines → grade (Again/Hard/Good/Easy) → next," with an optional teacher sign-off toggle in-flow; the daily session is short, finite, and then *done* — no reason invented to keep the user inside it.

- `docs/PRD.md` §6.3 (Grading scale) — **The four verdicts and their localized verbs.** Again = "needed help", Hard = "minor mistakes", Good = "recited clean", Easy = "effortless"; a grade is never just a number — **where** you stumbled (line indices) is the most valuable signal. Take: the button labels are these traditional verbs, localized, not raw enum names.

- `docs/PRD.md` §7.7 / §8.3 — **The sacred-text guard lives downstream + the absolute no-audio rule.** A dropped/added/swapped word is never "Good" (`grade = min(grade, Hard)`) — but this UI only *raises the flag*; the cap is applied in **domain-grading-pipeline** / the engine. §8.3: no microphone, no recording, no speech-to-text, no automatic mistake detection — correctness is judged by a human. Take: mark the word, don't cap it; never add audio.

- `docs/PRD.md` §8.2 / §7.12 / R6 — **Teacher override semantics (not this UI's job to enforce).** A teacher sign-off (`sourceConfidence = 1.0`) **always supersedes** self-rating and algorithmic state for that page; it can graduate/demote, set/clear weak-flags, and is written `source = teacher` to the append-only `review_log`. Take: this screen flips the toggle and reports `source = teacher`; the pipeline/engine make it authoritative.

- `docs/PRD.md` R1 / §11.2 — **Text fidelity is existential.** The muṣḥaf is shown only in the immutable reader/recite surface; never re-typeset an āyah, and the stumble overlay is coordinates over the glyph layer. Take: mask the surface, overlay coordinates — never reflow the sacred text.

- `docs/PRD.md` R3 / C6 — **No gamification of worship.** No leaderboards, XP, badges, confetti, or guilt/streak nags on a grade; framing is calm. Underwrites the "calm receipt, no celebration" rule across motion and haptics.

- `docs/design-system/05-layout-spacing-touch.md` (touch targets + `space.*` grid) — **The sizing tokens this flow cites by name.** `touch.min` (≥48dp) for stumble-line hit-areas; ≥56dp tall / ≥48dp wide grade buttons `space.2` apart, low in the Easy thumb band; `EdgeInsetsDirectional` for RTL. Take: never inline a dp; resolve to `space.*` / `touch.min`.

- `docs/design-system/03-color-and-themes.md` — **Owns the concrete `color.*` roles** the grade band's state layers and focus ring use (`color.outline`, role colors). This skill names *which* state each control exposes; that file owns the hex.

## Sibling skills

- **domain-grading-pipeline** — normalizes this screen's taps into one `ReviewInput(grade, errorLines, source, missedOrAlteredWord)`, applies the **sacred-text cap** and the **source-confidence weights**, and writes the append-only `review_log`. This skill stops at producing the taps.
- **domain-scheduling-engine-rules** — owns `onReview`, the FSRS D/S/R update, source-confidence *scaling*, the trust clamp, `targetR` tiers, and `due_at`. This flow never does that math.
- **domain-mushaf-text-integrity** — renders the byte-exact, immutable KFGQPC glyph page this flow masks/reveals and draws the stumble overlay on; never re-typeset.
- **domain-mutashabihat-system** — owns the confusion-edge bookkeeping a "swap" error feeds and the siblings pulled into the same session.
- **domain-adab-and-religious-integrity** — the always-on conscience-check on every verdict label, "reveal" copy, and teacher-mode string (no guilt, never "safe to drop", servant-to-the-teacher).
- **ui-today-session-list** / **ui-page-card** — the daily list and the page card whose tap opens this route.
- **eng-add-feature-module** / **eng-create-riverpod-store** — the route registration, the AsyncNotifier controller, and the single write path the grade commit flows through.
- **eng-rtl-and-bidi-layout** — the `Directionality` / `EdgeInsetsDirectional` / bidi-isolated-numeral primitives this screen mirrors with across fa/ckb/ar.
