---
name: ui-teacher-signoff
description: Build or modify the Hifz app's on-device teacher (talaqqī) sign-off control — the in-flow toggle that switches a page's grade source from self to a physically-present teacher, the authoritative verdict surface, and the per-student halaqa sign-off. Use whenever placing the "Teacher present" toggle in the recite/grade flow, the teacher verdict + stumble-line capture, the teacher-sourced badge on a card/log, or the halaqa profile-switch-then-sign-off path.
---

# ui-teacher-signoff

The optional **teacher sign-off** control in the recite/grade flow: a physically-present teacher (talaqqī) taps the verdict (and optionally the stumble lines), switching the grade's **source** from `self` (default, lower confidence) to `teacher` (authoritative, `sourceConfidence = 1.0`). A teacher verdict **overrides** self-rating and algorithmic state for that page, can set/clear weak-flags and graduate/demote it, and is written to the append-only `review_log`. The control is framed as the humble aide on the *teacher's* side of the relationship — it serves talaqqī, it never replaces or speaks for the teacher.

This control is the UI face of PRD R6 (servant to the talaqqī chain) and engine invariant "a teacher sign-off always supersedes self-rating and algorithmic state for that page." It is the one place the app explicitly defers its authority to a human.

## When to use

Use when building or placing:
- the **"Teacher present"** `Switch.adaptive` pinned in the grade band's lower region (flipping it changes the verdict's source)
- the **teacher verdict surface** — the verdict tap (+ optional stumble-line capture) attributed to a present teacher
- the **teacher-sourced marker** on the resulting page card / `review_log` entry (so self and teacher inputs are never conflated)
- the **local halaqa** per-student sign-off path: switch profile → recite → teacher signs off → next student, on one device

Do NOT use this skill for:
- the reveal-on-tap recite flow, the four-level grade band, or stumble-line tapping itself → use **ui-recite-grade-flow**
- the recurring page row, the teacher-locked / pinned affordance, or the decay indicator on a card → use **ui-page-card**
- the engine-side normalization of `(grade, error_lines, source)`, the per-source confidence weights, the sacred-text guard, or the teacher-overrides math → use **domain-grading-pipeline**
- the religious conscience-check on the sign-off copy (servant-to-teacher tone, no "safe to drop", no fiqh ruling) → use **domain-adab-and-religious-integrity**
- the local profiles / halaqa profile switcher plumbing and per-profile `review_log` → use **eng-add-persisted-model** (+ **domain-backup-format** for export to a teacher)

The sign-off is a *source switch + authoritative verdict*, not a second grade band. If you are drawing Again/Hard/Good/Easy buttons or hiding/revealing the page, you are in **ui-recite-grade-flow**, not here.

## The canonical pattern

1. **A labelled `Switch.adaptive`, visibly distinct from the self-grade.** The control is a labelled `Switch.adaptive` ("Teacher present") pinned in the grade band's **lower region**; `.adaptive` renders the native iOS switch while keeping our `ColorScheme` colors. It must be *visibly distinct* so it is never confused with a self-grade. `docs/design-system/07-components.md` §7 (teacher sign-off control: `Switch.adaptive`, "Teacher present", pinned in the grade band) + §5 table (Signed-off stage); `docs/PRD.md` §8.2.

2. **Flipping the toggle changes the verdict's `source`, not the grade band.** When on, the same Again/Hard/Good/Easy verdict (and the same optional stumble lines) is attributed to the teacher: the flow writes `source = teacher` with `sourceConfidence = 1.0` instead of self's `≈ 0.5`. Do not draw a second grade band — reuse **ui-recite-grade-flow**'s band and only swap the source. `docs/PRD.md` §8.1 + §8.2; `docs/design-system/13-islamic-identity-and-adab.md` §6 (teacher sign-off is a first-class grade with `sourceConfidence = 1.0`).

3. **The teacher verdict is authoritative — route it through the single write path; never let self/algorithm override it.** A teacher grade sets/clears weak-flags, can graduate/demote the page, and overrides prior state. The UI must never silently re-grade over a teacher verdict. Persist transactionally **before** republishing in-memory state, through a repository/store method — never mutate persisted state in the view. `docs/PRD.md` §7.12 (invariant: teacher sign-off supersedes) + R6; `docs/design-system/13-islamic-identity-and-adab.md` §6; route via **eng-create-riverpod-store** (single write path, persist-before-republish).

4. **Append to `review_log` with `source = teacher` + optional teacher label — a local audit trail, no server.** Each sign-off is one append-only `review_log` row carrying `source = teacher` and an optional teacher label, honoring the *sanad* idea with **no network/account**. Sign-off must work fully offline; transfer to a teacher happens via export/import, never a backend. `docs/PRD.md` §8.2 (append-only `review_log`, optional teacher label) + §15.3; offline/export contract via **domain-backup-format**.

5. **Mark teacher-sourced results visibly on the card and log.** A teacher-sourced grade is **visually marked** (a calm, distinct affordance) on the resulting page card / `review_log` entry so self and teacher inputs are never conflated; pair the mark with shape/glyph + an accessible label, never color alone. `docs/design-system/07-components.md` §7 ("visually marked … so self and teacher inputs are never conflated") + §4/§8 anti-pattern (never color alone); `docs/PRD.md` §8.2.

6. **Halaqa mode = profile switch, then sign off, on one device — never a remote dashboard.** In local halaqa mode a teacher switches between **student profiles on one device** and signs off each in turn against that student's own `review_log`. The control and switcher are **device-local**; there is no server dashboard and no remote teacher-surveillance. `docs/PRD.md` §15.3 (quick profile switcher; per-student `review_log`) + §8.2; `docs/design-system/13-islamic-identity-and-adab.md` §6 anti-pattern (no remote teacher-surveillance dashboard).

7. **Autonomy-supportive, servant-to-teacher copy in fa/ckb/ar — never commanding, never an authority claim.** Copy frames the app as an aid the teacher operates ("for your teacher to confirm"), never the app asserting authority ("the app says you passed"). It never issues a fiqh ruling and never says a page is "safe to drop." All strings are localized term-sets in fa/ckb/ar, autonomy-supportive in each. `docs/design-system/13-islamic-identity-and-adab.md` §6 (servant to the teacher; never speak for the Quran/user); `docs/design-system/07-components.md` §7 (autonomy-supportive, "for your teacher to confirm", never commanding); copy reviewed under **domain-adab-and-religious-integrity**.

8. **A ≥`touch.min` row, RTL-native, fully semantic.** The toggle is a ≥48dp `touch.min` row, laid out with `EdgeInsetsDirectional` so it mirrors correctly across fa/ckb/ar, with a `Semantics` label + state ("Teacher present, off") in the user's locale. Its enabled/selected state uses M3 state layers over a role color and exposes a visible focus ring. `docs/design-system/07-components.md` §7 (≥48dp row, `Semantics` label + state, localized) + §6 (M3 state layers, visible focus ring); `docs/design-system/05-layout-spacing-touch.md` (`touch.min`, `EdgeInsetsDirectional`).

9. **No celebration on a teacher "Good"/"Easy" — recording a verdict is quiet.** A teacher verdict fires no confetti, chime, streak bump, or haptic fanfare; honest competence feedback only. Faking teacher accountability with streaks/badges is forbidden. `docs/design-system/13-islamic-identity-and-adab.md` §4 + §6 anti-pattern (no gamified "accountability"); `docs/PRD.md` R3; motion stays restrained per `docs/design-system/06-motion-and-haptics.md`.

## Do / Don't

| Do | Don't |
|---|---|
| Use one labelled `Switch.adaptive` ("Teacher present") pinned in the grade band's lower region | Draw a second Again/Hard/Good/Easy band, or a separate "teacher screen" |
| Flip the toggle to change the verdict's `source` (`self ≈ 0.5` → `teacher = 1.0`) | Flip it to change the *grade* or to bypass reveal-on-tap |
| Let a teacher verdict set/clear weak-flags, graduate/demote, and override prior state | Let a later self-grade or the algorithm silently override a teacher sign-off |
| Persist through a store/repository method (persist-then-republish), then append `review_log` | Mutate persisted state in the view, or gate sign-off behind a Save dialog |
| Write `source = teacher` + optional teacher label to the append-only `review_log`, fully offline | Send the log anywhere, require an account/network, or build a remote dashboard |
| Visually mark teacher-sourced results with shape/glyph + accessible label | Conflate self and teacher inputs, or mark the source by color alone |
| Halaqa = switch student profile on one device, sign off, next | Build a server "teacher mode" or any remote surveillance of students |
| Copy: "for your teacher to confirm" — autonomy-supportive in fa/ckb/ar | "The app says you passed", a fiqh ruling, or "this page is safe to drop" |
| ≥48dp `touch.min` row, `EdgeInsetsDirectional`, `Semantics` label + state, focus ring | Hardcode LTR layout, omit the screen-reader state, or skip the focus ring |
| Record a teacher verdict quietly | Celebrate a teacher Good/Easy with confetti, chime, streak, or haptic fanfare |

## Checklist

Before this control is done:

- [ ] The control is a single labelled `Switch.adaptive` ("Teacher present"), pinned in the grade band's lower region, visibly distinct from the self-grade — no second grade band.
- [ ] Flipping it changes only the verdict's **`source`** (`self`, `sourceConfidence ≈ 0.5` → `teacher`, `sourceConfidence = 1.0`); the grade band and reveal-on-tap come from **ui-recite-grade-flow**, unchanged.
- [ ] A teacher verdict is authoritative: it can set/clear weak-flags and graduate/demote, overrides prior state, and is **never** silently overridden by a later self-grade or the algorithm.
- [ ] The verdict is persisted **transactionally before** republishing in-memory state, through a store/repository method (single write path), then appended to `review_log`.
- [ ] The `review_log` row carries `source = teacher` + optional teacher label; the whole flow works offline (no socket opened); transfer to a teacher is export/import only.
- [ ] Teacher-sourced results are visually marked on the card and log with shape/glyph **and** an accessible label — never color alone, never conflated with self.
- [ ] Halaqa path is profile-switch → recite → sign off → next student, device-local, writing each student's own `review_log`; no remote dashboard.
- [ ] Copy is autonomy-supportive and servant-to-teacher in **fa, ckb, ar** ("for your teacher to confirm"); no commanding voice, no fiqh ruling, no "safe to drop", no app-as-authority phrasing.
- [ ] The row is ≥48dp `touch.min`, RTL-native via `EdgeInsetsDirectional`, with a localized `Semantics` label + state ("Teacher present, off"), M3 state layers, and a visible focus ring.
- [ ] No celebration on any verdict: no confetti, chime, streak bump, or haptic fanfare; recording is quiet.
- [ ] No microphone, recording, speech-to-text, or auto mistake-detection is introduced — the teacher judges by ear, exactly as talaqqī does.
- [ ] Widget/golden tests cover: toggle off→on flips source; teacher verdict beats a prior self-grade; teacher-sourced marker renders; RTL goldens in fa/ckb/ar; an `HttpOverrides` offline guard.

The teacher sign-off is where the app most explicitly *defers* its authority. If any copy or behavior here reads as the app ruling, judging, or speaking for the teacher or the Quran, stop and run it through **domain-adab-and-religious-integrity** before shipping.

## Files

- `template.dart` — copy-paste scaffold: the `TeacherSignoffToggle` (`Switch.adaptive`, "Teacher present"), the source-switch wiring into the recite/grade view-model, the store method that persists-then-appends `review_log` with `source = teacher`, the teacher-sourced marker widget, and the RTL/`Semantics`/no-celebration scaffolding. Fill the `// TODO` markers; reference tokens (`type.*`, `color.*`, `space.*`, `touch.min`, `motion.*`) and engine names (`sourceConfidence`, `review_log`, `source = teacher`) by name only.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **ui-recite-grade-flow** (the recite flow + grade band this control extends), **ui-page-card** (the teacher-locked affordance and where the teacher-sourced marker lands), **domain-grading-pipeline** (the engine-side `(grade, error_lines, source)` normalization, confidence weights, sacred-text guard, teacher-overrides math), **domain-adab-and-religious-integrity** (the servant-to-teacher conscience-check on all copy), **eng-create-riverpod-store** (the single-write-path store method the sign-off calls), **eng-add-persisted-model** (the `review_log` / profiles persistence), **domain-backup-format** (offline export to a teacher).
