# references — ui-teacher-signoff

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/design-system/07-components.md` §7 (The teacher sign-off control) — **The component spec.** The control is a labelled `Switch.adaptive` ("Teacher present") pinned in the grade band's **lower region**; flipping it changes the verdict's **source** from `self` (default, lower confidence) to `teacher` (authoritative); a teacher verdict overrides self-rating and algorithmic state, can set/clear weak-flags and graduate/demote, and is written to the append-only `review_log` with an optional teacher label. A teacher-sourced grade is **visually marked** so self and teacher inputs are never conflated. In **local halaqa mode** the teacher switches between student profiles on one device. The toggle is a ≥48dp `touch.min` row with a localized `Semantics` label + state ("Teacher present, off"); copy stays **autonomy-supportive** ("for your teacher to confirm"), never commanding.

- `docs/PRD.md` §8.2 (On-device teacher sign-off — talaqqī) — **The rule.** A teacher, *physically present*, listens and taps the verdict (+ optionally the stumble lines) on the same device / in the student's profile, `sourceConfidence = 1.0`; teacher grades set weak-flags, can graduate/demote, and override prior state; in local halaqa mode the teacher switches profiles to sign off each; sign-offs are recorded in the **append-only `review_log`** with `source = teacher` and an optional teacher label — a local audit trail honoring the *sanad* idea **without any server**.

- `docs/PRD.md` §15.3 (Profiles — local multi-user, no cloud) — **Halaqa.** Multiple device-local profiles; **teacher/halaqa mode** is a *quick profile switcher* so a teacher signs off each student in turn on the same device, with a per-student `review_log` and teacher labels; sharing across devices is export/import only, never a server.

- `docs/design-system/13-islamic-identity-and-adab.md` §6 (Servant to the teacher and the sanad) — **The adab frame.** Teacher sign-off is a first-class grade with `sourceConfidence = 1.0` that **overrides** self-rating and algorithmic state; the sign-off control is plain and dignified, recorded in the append-only `review_log`; copy frames the app as an aid/servant to the teacher — never an authority over the qārī, never a fiqh ruling, never "safe to drop", never a remote teacher-surveillance dashboard, never gamified "accountability".

## Supporting

- `docs/PRD.md` §8.1 (Self-rating) — **The other source.** Self-rating carries lower confidence (`sourceConfidence ≈ 0.5`), moves stability less aggressively, and **alone cannot push a page to the top retention tier** without at least one teacher sign-off — the asymmetry the toggle's source-switch encodes.

- `docs/PRD.md` §7.12 (Engine invariants) — **The non-negotiable.** "A teacher sign-off always supersedes self-rating and algorithmic state for that page" and the engine "never displays or implies 'this page is safe to stop revising.'" The UI must never violate either.

- `docs/PRD.md` §8.3 (What we explicitly do NOT do) — **The hard no.** No microphone, recording, speech-to-text, or automatic mistake detection; the teacher judges correctness by ear, exactly as the tradition does.

- `docs/design-system/07-components.md` §5 (The recite/grade flow) — **Where it lives.** The "Signed-off" stage of the recite flow hosts the `Switch.adaptive` + verdict; the four-level grade band and reveal-on-tap are this section's job — the sign-off only swaps the source on top of it.

- `docs/design-system/07-components.md` §6 (Grade band & component states) — **State model.** Enabled/pressed/disabled/focused/selected are drawn with M3 **state layers** over a role color; a **visible focus ring** (`color.outline`) is required; states mirror correctly in RTL and announce via `Semantics`.

- `docs/design-system/07-components.md` §4 / §8 (Decay indicator / heat-map cell anti-patterns) — **Color independence.** Never encode meaning by color alone; pair every state (incl. the teacher-sourced marker) with shape/glyph + an accessible label.

- `docs/design-system/13-islamic-identity-and-adab.md` §4 (Never gamify worship) — **No celebration.** Recording a teacher Good/Easy is quiet — no confetti, chime, streak, badge, or haptic fanfare; honest competence feedback only.

- `docs/PRD.md` §4 R6 / R3 — **The requirements behind it.** R6: teacher sign-off is first-class and overrides; servant to the talaqqī chain. R3: no gamification of the sacred.

## Sibling skills

- **ui-recite-grade-flow** — the reveal-on-tap recite flow, the four-level grade band, and stumble-line tapping this control extends (the sign-off swaps only the source).
- **ui-page-card** — the recurring page row, the teacher-locked/pinned affordance, and where the teacher-sourced marker lands.
- **domain-grading-pipeline** — the engine-side normalization of `(grade, error_lines, source)`, per-source confidence weights, the sacred-text guard, and the teacher-overrides math.
- **domain-adab-and-religious-integrity** — the always-on conscience-check on the sign-off copy (servant-to-teacher tone, no "safe to drop", no fiqh ruling).
- **eng-create-riverpod-store** — the single-write-path store/notifier method (persist-before-republish) the sign-off calls.
- **eng-add-persisted-model** — the `review_log` append-only table and the local profiles the halaqa path writes.
- **domain-backup-format** — the offline `.hifzbackup` export/import by which a student's signed-off log reaches a teacher (no server).
