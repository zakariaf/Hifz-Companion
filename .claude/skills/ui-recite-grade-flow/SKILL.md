---
name: ui-recite-grade-flow
description: Build the Hifz app's full-screen recite-from-memory flow — the reveal-on-tap surface over the immutable muṣḥaf page, the four-level grade band (Again/Hard/Good/Easy), stumble-line tapping, and the optional teacher sign-off toggle — with calm receipt motion and no celebration. Use whenever building or changing the recite flow, the reveal-on-tap surface, the grade buttons, the stumble-line marker, the disabled-until-revealed grading state, the undo affordance, or the in-flow teacher sign-off control.
---

# ui-recite-grade-flow

The full-screen route a ḥāfiẓ enters by tapping a page card: the muṣḥaf page is **hidden**, they recite from memory, **reveal line-by-line on tap** to self-check, **tap the lines where they stumbled**, and grade the page with a **four-level band — Again / Hard / Good / Easy**. An optional **teacher sign-off** toggle in-flow switches the grade's source from self to teacher. There is no audio, no microphone, no AI — recall is judged by the human, exactly as talaqqī does. The grade landing is a quiet receipt, never a celebration.

This skill owns the **screen and its widgets**: the masked page, the reveal mechanics, the line hit-areas, the grade `FilledButton` row, the disabled-until-revealed state, the undo affordance, the teacher-present `Switch.adaptive`, and the RTL/motion/haptic treatment of all of it. It does **not** own the grade arithmetic or the normalized signal — it produces the user's taps and hands them to the grading pipeline (see **domain-grading-pipeline**), which the engine consumes.

## When to use

Use when building or changing:
- the full-screen recite route opened from a page card (hidden page → recite → reveal → grade → next)
- the reveal-on-tap surface (line-by-line reveal of the masked muṣḥaf page)
- the four-level grade band (`FilledButton` row: Again / Hard / Good / Easy) and its disabled-until-revealed state
- the stumble-line marker (expanding a glyph line's hit-area to tap an error position)
- the in-flow teacher sign-off `Switch.adaptive` and the visual self/teacher distinction
- the undo affordance on a just-submitted grade
- the calm advance-to-next-page transition and its motion/haptics

Do NOT use this skill for:
- normalizing the taps into the `ReviewInput(grade, errorLines, source, missedOrAlteredWord)` signal, the source-confidence weights, or the sacred-text grade cap → use **domain-grading-pipeline**
- the FSRS D/S/R math, `onReview`, the trust clamp, graduation, or `due_at` → use **domain-scheduling-engine-rules**
- rendering the actual Quran glyphs, the per-page KFGQPC font, the coordinate overlay the stumble marker draws on → use **domain-mushaf-text-integrity**
- pulling mutashābihāt siblings into the session or logging a "swap" confusion → use **domain-mutashabihat-system**
- the page card, the daily-session list, the track chip, the decay indicator, the heat-map cell → use **ui-today-session-list** / **ui-page-card**
- the adab review of every verdict label and copy string → use **domain-adab-and-religious-integrity**
- the RTL/bidi scaffolding primitives (`Directionality`, `EdgeInsetsDirectional`, bidi-isolated numerals) → use **eng-rtl-and-bidi-layout**
- wiring the route, controller, and single write path → use **eng-add-feature-module** / **eng-create-riverpod-store**

This skill is the recite *surface*; the pipeline is the recite *signal*. A screen that does its own stability math, or caps a grade itself, is reaching across the boundary.

## The canonical pattern

1. **Reveal-on-tap, page hidden first.** The route opens with the page **masked**; the ḥāfiẓ recites from memory, then reveals line-by-line on tap. The grade band stays **disabled until at least one reveal**, so a grade always follows an actual recall attempt — revealing first would collapse retrieval practice into re-reading. `docs/design-system/07-components.md` §5 (Recite/grade flow: Hidden → Revealing → Grading stages; "grade band stays disabled until at least one reveal") and §6 (disabled grade band reads as *waiting*, not broken — `NN/g #1`); the flow verbatim in `docs/PRD.md` §8.1 and §12.2.

2. **Never render or re-typeset glyphs here.** The recite surface shows the immutable muṣḥaf page from the reader surface; this flow masks/reveals the page *surface* and never re-typesets an āyah. Compose the glyph layer via **domain-mushaf-text-integrity**; the mask is an overlay, not a re-layout. `docs/design-system/07-components.md` §2 (anti-pattern: never render Quran glyphs in a row / re-typeset for preview) and §5 ("the immutable glyph layer is never touched"); `docs/PRD.md` R1, §11.2.

3. **Stumble-line tapping = grown hit-area, coordinate overlay.** Map a tap to a line index by expanding each glyph line's *hit area* to ≥48dp `touch.min` with transparent padding; the error position is drawn as an **overlay of coordinates over the immutable glyph layer**, never by re-typesetting. The tap fires `haptic.selection` (a discrete, reversible choice). `docs/design-system/07-components.md` §5 ("expanding each glyph line's hit area to ≥48dp… drawn as an overlay of coordinates, never by re-typesetting"); `docs/design-system/06-motion-and-haptics.md` §4 (`haptic.selection` → `HapticFeedback.selectionClick()`, example: "tapping a stumble-line during reveal-on-tap"); `touch.min` per `docs/design-system/05-layout-spacing-touch.md`.

4. **Four large grade buttons, low in the thumb zone.** Render Again / Hard / Good / Easy as a row of M3 `FilledButton`s (elevation-less emphasis), kept large and low (**≥56dp tall, ≥48dp wide, `space.2` apart**) because a mis-tap on a sacred-text grade is costly. The row reads **right-to-left** in the user's verb set ("needed help / minor mistakes / recited clean / effortless"), localized and bidi-safe. `docs/design-system/07-components.md` §5 (grade band sizing + RTL verb order) and §6 (`FilledButton` over `SegmentedButton` for thumb-zone size); `space.2`/`touch.min` per `docs/design-system/05-layout-spacing-touch.md`; verbs from `docs/PRD.md` §6.3.

5. **The grade is suggested, not asserted — and the sacred-text guard belongs to the pipeline.** The band may *suggest* a grade from the stumble count, but it stays **user-confirmable**. This screen passes the user's taps (grade + 1-based `errorLines` + the `missedOrAlteredWord` flag a marked dropped/added/swapped word raises) to **domain-grading-pipeline**, which caps the grade at *Hard* — this UI never does stability math and never decides the final grade itself. `docs/design-system/07-components.md` §5 ("grade is suggested from the stumble count but stays user-confirmable; a sacred-text guard caps the grade at Hard"); the cap is enforced in `docs/PRD.md` §7.7 / §8.1 via **domain-grading-pipeline**.

6. **Calm motion: short/medium, standard easing, one permitted hero.** Line reveal fades in at `motion.duration.short` with `motion.curve.standard`; the grade lands with the same brief fade to the next item. The **page→recite hero** is the *only* place `motion.curve.emphasized` with a single `long` duration is permitted — and even that is calm: no overshoot, no spring, no chime. No M3 Expressive physics. `docs/design-system/06-motion-and-haptics.md` §1 (short/medium ladder + standard easing; the recite flow "is where motion earns its keep") and §3 (page-turn direction); `docs/design-system/07-components.md` §5 (motion column).

7. **No celebration — anywhere, on any channel.** A Good/Easy grade fires the **same** calm path as Again: no confetti, no chime, no streak bump, no haptic fanfare. Advancing to the next page is quiet. Celebratory motion is a tier that does not exist; a committed grade is acknowledged by `haptic.confirm` (`HapticFeedback.lightImpact()`) plus a state change, never a burst. `docs/design-system/06-motion-and-haptics.md` §2 (no celebratory motion — the single non-negotiable of that file) and §4 (`haptic.confirm` on commit; no "success" haptic); `docs/PRD.md` R3, C6.

8. **Disabled, pressed, focused — M3 state layers, never ad-hoc opacity.** The grade band's *disabled* (pre-reveal) state is styled as **waiting** (a calm dimmed band + a quiet "reveal to grade" hint), its *pressed* state is an M3 state layer, and it carries a **visible focus ring** (`color.outline`) for keyboard/switch-control users. States mirror correctly in RTL and are announced via `Semantics` flags. `docs/design-system/07-components.md` §6 (state model: enabled/pressed/disabled/focused via M3 state layers; disabled reads as waiting; visible focus ring per `WCAG 2.2 SC 2.4.7`); state-layer colors owned by `docs/design-system/03-color-and-themes.md`.

9. **Undo a just-submitted grade.** A submitted grade is **undoable** via a brief, non-intrusive "undo" affordance, so a fat-fingered tap on a sacred-text grade is recoverable without dread; the abort/exit stays in thumb reach. `docs/design-system/07-components.md` §5 ("a just-submitted grade is undoable… so a fat-fingered tap on a sacred-text grade is recoverable"; anti-pattern: never make a sacred-text grade irreversible — `NN/g #3`).

10. **Teacher sign-off: the human override, made first-class.** An `.adaptive` toggle ("Teacher present") in the grade band's lower region switches the verdict's **source** from self (default) to teacher (authoritative). It is **visually distinct** so self and teacher inputs are never conflated; flipping it changes only the `source` this screen reports — the override semantics (a teacher grade supersedes self-rating and algorithmic state) live in **domain-grading-pipeline**. Copy stays autonomy-supportive in fa/ckb/ar ("for your teacher to confirm"), never commanding. `docs/design-system/07-components.md` §7 (`Switch.adaptive`, source = self/teacher, visually marked, autonomy-supportive copy); `docs/PRD.md` §8.2, §7.12, R6.

11. **No audio, no microphone, no AI — ever.** This flow has no recording, no speech-to-text, no automatic mistake detection. The only inputs are taps. `docs/PRD.md` C2, §8.3, R5; `docs/design-system/07-components.md` §5 (anti-pattern: never add a microphone/recording/STT).

12. **RTL-native across fa/ckb/ar, reduce-motion honoured.** Verdict labels, "reveal", "you stumbled here", and the teacher-mode copy are localized term-sets rendered RTL via `Directionality`; numerals are locale-appropriate and bidi-isolated; nothing load-bearing truncates. Every animated transition reads `MediaQuery.disableAnimations` and degrades to a cross-fade or instant cut — nothing here is information-bearing in motion alone. `docs/design-system/06-motion-and-haptics.md` §5 (reduce-motion: the OS flag always wins) and §3 (RTL direction is the default); RTL primitives via **eng-rtl-and-bidi-layout**.

## Do / Don't

| Do | Don't |
|---|---|
| Open with the page **masked**; reveal line-by-line on tap; keep the grade band **disabled until ≥1 reveal** | Reveal the page before a recall attempt, or let the band be tapped pre-reveal (kills retrieval practice) |
| Compose the immutable glyph layer from **domain-mushaf-text-integrity**; mask the *surface* | Render or re-typeset any āyah inside this flow |
| Map stumble taps via a **≥48dp grown hit-area**, drawn as a **coordinate overlay** on the glyph layer | Re-typeset or reflow the glyph layer to mark an error position |
| Render grades as four `FilledButton`s, **≥56dp tall, `space.2` apart**, RTL verb order | Use a cramped `SegmentedButton` or shrink sacred-text grade targets toward 44dp |
| *Suggest* the grade from stumbles, keep it **user-confirmable**; pass taps to **domain-grading-pipeline** | Do stability math here, or decide/cap the final grade in the widget |
| Reference tokens by name: `motion.duration.short`, `motion.curve.standard`, `space.2`, `touch.min`, `haptic.selection`, `haptic.confirm` | Hardcode `Duration(milliseconds: 220)`, a raw `Curve`, 16dp, hex, or `HapticFeedback.heavyImpact()` at the call site |
| Fire `haptic.confirm` on the committed grade — the **same** path for Again and Easy | Fire a "success"/celebration haptic, a chime, confetti, or a streak bump on Good/Easy |
| Style *disabled* as **waiting** ("reveal to grade") via M3 state layers; show a visible focus ring | Invent per-component opacity for states, or ship the band with no focus indicator |
| Offer an **undo** on a just-submitted grade; keep abort/exit in thumb reach | Make a sacred-text grade irreversible or hide the exit out of reach |
| Make teacher sign-off a **visually distinct** `Switch.adaptive`; report only `source` | Conflate self/teacher visually, or let this UI assert "the app says you passed" |
| Localize verdicts/reveal/teacher copy for fa/ckb/ar, RTL via `Directionality`, locale numerals, no truncation | Hardcode English verbs, LTR layout, or truncate a load-bearing label |
| Degrade every animation under `MediaQuery.disableAnimations` | Play a "subtle" animation through a reduce-motion request |

## Checklist

Before this flow is done:

- [ ] The route opens with the page **masked**; text reveals only **after** a recall attempt; the grade band is **disabled until ≥1 reveal** and reads as *waiting* ("reveal to grade"), not broken.
- [ ] The glyph layer is composed from **domain-mushaf-text-integrity**; this flow masks/reveals the **surface** and never renders or re-typesets an āyah.
- [ ] Stumble lines are captured by **growing each line's hit-area to ≥48dp `touch.min`** and drawing a **coordinate overlay** on the immutable glyph layer; each tap fires `haptic.selection`.
- [ ] Grades are four `FilledButton`s — **≥56dp tall, ≥48dp wide, `space.2` apart** — in **RTL verb order** (needed help / minor mistakes / recited clean / effortless), localized and bidi-safe.
- [ ] The grade is **suggested** from the stumble count but stays **user-confirmable**; the screen passes `grade` + 1-based `errorLines` + the `missedOrAlteredWord` flag to **domain-grading-pipeline** and does **no** stability math and **no** grade cap itself.
- [ ] Reveal uses `motion.duration.short` + `motion.curve.standard`; only the page→recite hero may use `motion.curve.emphasized` + a single `long` duration, with no overshoot/spring.
- [ ] **No celebration on any channel**: Good/Easy fires the same calm path as Again — no confetti/chime/streak/haptic fanfare; a committed grade fires `haptic.confirm` + a state change only.
- [ ] State model via **M3 state layers** (enabled/pressed/disabled/focused), a **visible focus ring** (`WCAG 2.2 SC 2.4.7`), and `Semantics` flags; states mirror correctly in RTL.
- [ ] A just-submitted grade is **undoable** via a brief affordance; the abort/exit stays in thumb reach.
- [ ] Teacher sign-off is a **visually distinct** `Switch.adaptive` ("Teacher present") that changes only the reported `source`; copy is **autonomy-supportive** in fa/ckb/ar ("for your teacher to confirm"), never commanding.
- [ ] **No microphone / no recording / no STT / no model** anywhere in the path (C2/R5); the only inputs are taps.
- [ ] All copy (verdicts, "reveal", "you stumbled here", teacher-mode, sabaq/sabqi/manzil terms) is localized for **fa / ckb / ar**, RTL via `Directionality`, locale-appropriate numerals, **no truncation** of load-bearing labels.
- [ ] Every animated transition reads `MediaQuery.disableAnimations` and degrades to a cross-fade/instant cut; nothing is information-bearing in motion alone.
- [ ] `Semantics` announces each grade button's verdict **and its consequence** ("again — review again soon") so a non-visual user grades confidently.
- [ ] All verdict labels and in-flow copy have passed the adab review (**domain-adab-and-religious-integrity**): no guilt/fear, never "safe to drop", servant-to-the-teacher framing.

This flow is the single most consequential surface in the app: it is where worship meets the engine. Keep it reverent and calm — the page is hidden so recall is real, the grade is the user's own honest verdict, the teacher always outranks the algorithm, and the first real recitation should only ever surprise upward. When the screen is in doubt about a grade, it asks the human; it never decides for them.

## Files

- `template.dart` — copy-paste scaffold: the `ReciteGradeScreen` route, the reveal-on-tap surface over the composed glyph layer, the ≥48dp stumble-line hit-areas drawing a coordinate overlay, the disabled-until-revealed four-button grade band, the undo affordance, the teacher-present `Switch.adaptive`, and the hand-off of taps to **domain-grading-pipeline** — Riverpod + Material 3 + `Directionality`, with `// TODO` markers and tokens referenced by name only.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-grading-pipeline** (normalizes this screen's taps into the `ReviewInput` signal and applies the sacred-text cap and source-confidence weights), **domain-scheduling-engine-rules** (`onReview`, the D/S/R math, the trust clamp this flow never touches), **domain-mushaf-text-integrity** (renders the immutable glyph page this flow masks and overlays), **domain-mutashabihat-system** (the confusion edges a swap-error feeds and the siblings pulled into the session), **domain-adab-and-religious-integrity** (the conscience-check on every verdict label and in-flow string), **ui-today-session-list** / **ui-page-card** (the page card that opens this route), **eng-add-feature-module** / **eng-create-riverpod-store** (the route + controller + single write path), **eng-rtl-and-bidi-layout** (the RTL/bidi primitives this screen mirrors with).
