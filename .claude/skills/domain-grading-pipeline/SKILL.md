---
name: domain-grading-pipeline
description: Build or change how a Hifz revision is graded with NO AI and NO audio — reveal-on-tap self-rating plus on-device teacher (talaqqī) sign-off normalized into one (grade, error_lines, source) signal with per-source confidence weights, the sacred-text guard (a dropped/altered word is never "Good"), and the teacher-overrides rule. Use whenever building or editing the recite/grade flow, self-rating, teacher sign-off, error-line capture, source-confidence weighting, or anything that produces a grade for the scheduling engine.
---

# domain-grading-pipeline

The normalization layer between *a ḥāfiẓ reciting a page from memory* and *the scheduling engine*. It turns every kind of recitation verdict — a self-rating after reveal-on-tap, or an on-device teacher (talaqqī) sign-off — into exactly one value object, `ReviewInput(grade, errorLines, source, missedOrAlteredWord)`, carrying a per-source confidence weight, before the engine ever sees it. No microphone, no speech-to-text, no model: correctness is judged by a human, exactly as the tradition does.

This pipeline is where four non-negotiables meet in one funnel: **no AI/no audio** (C2), the **sacred-text guard** (a dropped/altered word is never "Good", R1), **servant to the talaqqī chain** (a teacher sign-off always overrides self-rating and algorithmic state, R6), and **privacy** (no recording, ever, R5). Everything the engine does downstream trusts that this layer produced an honest, confidence-tagged signal.

## When to use

Use when building or changing:
- the recite → reveal-on-tap → mark-stumble-lines → grade flow that produces a `ReviewInput`
- self-rating capture (Again/Hard/Good/Easy) and the stumble-count → suggested-grade mapping
- on-device teacher sign-off (talaqqī): the verdict-and-stumble-lines tap surface, `source = teacher`, `sourceConfidence = 1.0`
- error-line / stumble-line capture (the 1-based `errorLines` list) and the `missedOrAlteredWord` sacred-text flag
- source-confidence weighting (self ≈ 0.5 vs teacher 1.0) and how it scales the applied stability gain
- the append-only `review_log` write of `(grade, error_lines, source)`
- anything that hands a normalized grade to `SchedulingEngine.onReview`

Do NOT use this skill for:
- the FSRS arithmetic that *consumes* the grade (S/D update, trust clamp, intervals) → use **domain-scheduling-engine-rules**
- the visual recite/reveal screen chrome, the muṣḥaf glyph rendering, line-tap targets, RTL layout of the flow → use **ui-recite-grade-flow**
- pulling mutashābihāt siblings into the session / confusion-edge bookkeeping from a "swap" error → use **domain-mutashabihat-interference**
- the Drift schema + migration for `review_log` / `card` → use **eng-add-persisted-model**
- the pure-Dart engine package boundary (no I/O, injected `today`, no `DateTime.now()`) → use **eng-create-engine-package**
- the in-app copy that explains *why* reciting-from-memory beats re-reading → use **domain-claims-register-and-science-screen**

The grade is produced here; it is *applied* in the engine. A grading path that does its own interval math, reads a clock, or writes a `due_at` is the wrong layer.

## The canonical pattern

1. **Recite from memory first; reveal only after the attempt.** The core daily act is *retrieval*, not re-reading. The page is presented hidden; the ḥāfiẓ recites the whole page in flow; text is revealed (line-by-line or whole-page) **only after** the attempt, solely to enable feedback — never as a cue. Revealing first converts strong free-recall into weak recognition and forfeits most of the benefit. `docs/science/04-retrieval-practice-and-self-testing.md` §1 (testing changes memory) and §4 (recall beats recognition: free recall *g*=0.79 vs recognition *g*=0.32); `docs/PRD.md` §8.1 (reveal-on-tap).

2. **Mark the stumble lines, then suggest the grade from them.** After the reveal, the user taps the 1-based line indices where they stumbled → `errorLines`. The grade (Again/Hard/Good/Easy) is *suggested* from the stumble count but stays user-confirmable. Localized stumble marking is the targeted corrective-feedback signal that prevents re-retrieving a wrong continuation and seeds mutashābihāt detection. `docs/PRD.md` §8.1 (stumble lines → suggested grade); `docs/science/04-retrieval-practice-and-self-testing.md` §5 (mark error positions; feedback nearly doubles the effect, *g*=0.73 vs 0.39).

3. **Apply the sacred-text guard at normalization time — never "Good" for a dropped/altered word.** If a word was missed, added, or swapped, set `missedOrAlteredWord = true`; the normalized grade is then capped at `Grade.hard` **before** the `ReviewInput` leaves this layer. This is R1 in code: error positions can only *lower* a self-rated grade, never raise it. The engine re-asserts the same cap (`onReview`), but the pipeline must never emit a `Good`/`Easy` with `missedOrAlteredWord == true`. `docs/PRD.md` §8.3 + R1; `docs/engineering/06-scheduling-engine.md` §4 (sacred-text guard: `grade ≤ Hard`) and its property test "dropped word is never Good".

4. **Tag the source and its confidence; never inline the weight.** Set `source = Source.self_` (`kSelfConfidence = 0.5`) or `source = Source.teacher` (`1.0`). The weight is a named engine constant (`kSelfConfidence`), referenced, never a literal `0.5` at the call site. Self-rating is noisier, so it must move state *less*; the magnitude scaling lives in the engine, but this layer must label the source correctly so the engine can scale. `docs/engineering/06-scheduling-engine.md` §4 (`conf = teacher ? 1.0 : kSelfConfidence`; "noisy self-rating moves S LESS") and §8 (`kSelfConfidence` constant); `docs/PRD.md` §8.1–§8.2.

5. **Teacher sign-off is one extra `source = teacher` write — same shape, authoritative.** A physically-present teacher listens to the full recitation, then taps the verdict (and optionally the stumble lines) on the **same device** (or in the student's profile). Same `ReviewInput` shape, `sourceConfidence = 1.0`. Teacher grades are authoritative: they set weak-flags, can graduate/demote a page, and override prior self-rated state — the servant-to-talaqqī rule (R6). In halaqa mode the teacher switches student profiles on one device. `docs/PRD.md` §8.2 + R6; `docs/engineering/06-scheduling-engine.md` §4 ("teacher sign-off is the *sanad*-respecting ground truth").

6. **Feedback lands after the full attempt, slightly delayed — never a mid-recitation teleprompter.** The reveal/correction surfaces *after* the page is recited; the UI must not surface the next line before the ḥāfiẓ has tried to recall it. Recite-then-be-corrected is exactly talaqqī, and a short delay before correction helps more than instant correction. `docs/science/04-retrieval-practice-and-self-testing.md` §5 (delayed feedback beats immediate; no teleprompter).

7. **Keep genuinely-unmemorized pages out of the retrieval queue.** Only *successful* retrieval builds memory; repeated failure does not. A page the ḥāfiẓ has actually lost returns to active revision (NEW/sabaq) where success is reachable — the grading pipeline grades pages the user genuinely holds, not a too-hard test. `docs/science/04-retrieval-practice-and-self-testing.md` §7 (bounded by *successful* retrieval); `docs/PRD.md` §7.10 (cold start keeps un-held pages `UNMEMORIZED`).

8. **Emit one `ReviewInput`; persist `(grade, error_lines, source)` append-only; hand to the engine.** The single output is `ReviewInput(grade, errorLines, source, missedOrAlteredWord)`. It is written to the append-only `review_log` (with an optional teacher label — a local *sanad* audit trail, no server) and passed to `SchedulingEngine.onReview(card, review, today)`. This layer never computes a `due_at`, never reads a clock, never touches stability. `docs/PRD.md` §8.2 (append-only `review_log`, optional teacher label) + §10.2; `docs/engineering/06-scheduling-engine.md` §2 (`ReviewInput` shape) and §4 (`onReview` consumes it).

9. **Errors/edges at full strength; only the stability magnitude is confidence-scaled.** `errorLines` (localization) and any confusion-edge data are recorded at **full strength regardless of source** — even a self-reported "I swapped these two" is valuable graph data. Only the *magnitude of the stability move* is confidence-scaled (in the engine). So this layer never down-weights or discards a self-reported error. `docs/engineering/06-scheduling-engine.md` §4 ("errorLines and confusion-edge updates are applied at full strength regardless of source").

10. **No microphone, no recording, no celebration.** There is no audio path anywhere in this pipeline — no ASR, no recording, no on-device model (C2/R5; protects women's privacy by construction). A logged grade is a calm receipt, not a reaction: no streaks, badges, scores, or confetti on a `Good`, and a self-corrected hesitation is not treated as a true lapse. `docs/PRD.md` C2 + R5 (no microphone anywhere) + C6 (no gamification of worship); `docs/science/04-retrieval-practice-and-self-testing.md` §6 (correct the re-reading illusion by frictionless recall, never coercion).

## Do / Don't

| Do | Don't |
|---|---|
| Produce exactly one `ReviewInput(grade, errorLines, source, missedOrAlteredWord)` and hand it to `SchedulingEngine.onReview` | Compute a `due_at`, read a clock, or update stability/difficulty in the grading layer |
| Hide the page; reveal only **after** the recitation attempt, to enable feedback | Reveal text first, or auto-reveal the next line as a teleprompter (turns recall into recognition/reading) |
| Cap the normalized grade at `Grade.hard` whenever `missedOrAlteredWord == true` (R1, in this layer) | Emit a `Good`/`Easy` with a dropped/added/swapped word — ever |
| Tag `source` and reference `kSelfConfidence` (0.5) / teacher `1.0` by name | Hard-code `0.5`/`1.0` at the call site, or treat self-rating as equal to a teacher verdict |
| Let a teacher sign-off (`source = teacher`, conf `1.0`) override self-rating and algorithmic state | Let a self-rating reach the top retention tier with no teacher sign-off, or override a teacher verdict |
| Suggest the grade from the stumble-count, keep it user-confirmable | Auto-commit a grade with no chance to confirm, or grade before stumble lines are marked |
| Record `errorLines` + confusion edges at full strength regardless of source | Down-weight, drop, or skip a self-reported swap/stumble |
| Write `(grade, error_lines, source)` to the append-only `review_log` (optional teacher label) | Mutate or overwrite a prior `review_log` row, or persist a competing `due_at` |
| Keep `UNMEMORIZED`/lost pages out of the retrieval queue (grade only held pages) | Push a genuinely-lost page into manzil and let the user fail it repeatedly |
| Treat the grade as a calm receipt; identical path for every verdict | Add streaks/badges/confetti on a `Good`, or thrash stability on a self-corrected hesitation |
| Judge correctness by a human (ḥāfiẓ or teacher), no audio | Add a microphone, recording, ASR, mistake-detection, or any on-device model (C2/R5) |

## Checklist

Before this grading path is done:

- [ ] The flow recites from memory on a **hidden** page; text reveals only **after** the attempt (no pre-reveal, no next-line teleprompter).
- [ ] Stumble lines are captured as 1-based `errorLines`; the grade is *suggested* from the stumble count and stays user-confirmable.
- [ ] `missedOrAlteredWord` is set on a dropped/added/swapped word, and the normalized grade is capped at `Grade.hard` **in this layer** before the `ReviewInput` is emitted (R1).
- [ ] `source` is `self_` or `teacher`; the confidence weight is referenced by name (`kSelfConfidence` 0.5 / teacher 1.0), never inlined — and self-rating cannot reach the top tier alone.
- [ ] A teacher sign-off uses the same `ReviewInput` shape with `source = teacher`, conf `1.0`, and overrides self-rating + algorithmic state (R6); halaqa mode switches profiles on one device.
- [ ] `errorLines` and any confusion edges are recorded at **full strength regardless of source**; only the stability magnitude is confidence-scaled (in the engine, not here).
- [ ] Exactly one `ReviewInput` is produced; it is written append-only to `review_log` as `(grade, error_lines, source)` (with optional teacher label) and passed to `SchedulingEngine.onReview(card, review, today)` — no `due_at`, no clock, no stability math here.
- [ ] Genuinely-unmemorized/lost pages stay `UNMEMORIZED` (out of the retrieval queue); only held pages are graded.
- [ ] No microphone / no recording / no ASR / no model anywhere in the path (C2/R5); a logged grade is a calm receipt — no streaks/badges/confetti (C6).
- [ ] Flow strings (verdicts, "reveal", "you stumbled here", teacher-mode labels, the sabaq/sabqi/manzil terms) are localized for **fa / ckb / ar**, rendered RTL via `Directionality`; numerals are locale-appropriate; sect-/madhhab-neutral wording; no truncation of load-bearing labels.
- [ ] Pure-Dart engine boundary respected: the grading layer never imports the engine's internals beyond the `ReviewInput`/`onReview` surface, and the engine receives an injected `today` — the pipeline passes no `DateTime.now()`.

This pipeline produces the single most consequential input the engine receives. An over-generous or audio-faked grade would let a page drift; the sacred-text guard, the source-confidence split, and the teacher override are the integrity controls that keep the schedule honest and the talaqqī chain respected. When in doubt, grade conservatively — the first real recitation should only ever surprise upward.

## Files

- `template.dart` — copy-paste starting point: the `RecitationGrading` normalizer that builds a `ReviewInput`, the reveal-on-tap + stumble-line capture controller, the self-rating → suggested-grade mapping, the teacher sign-off path, the sacred-text guard, the `review_log` append, and the hand-off to `SchedulingEngine.onReview` — Riverpod + Material 3 + `Directionality`, with `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-scheduling-engine-rules** (the `onReview` arithmetic, source-confidence scaling, and trust clamp that consume this grade), **ui-recite-grade-flow** (the reveal-on-tap / stumble-line screen this drives), **domain-mutashabihat-interference** (the confusion-edge bookkeeping a "swap" error feeds), **eng-add-persisted-model** (the append-only `review_log` write path), **eng-create-engine-package** (the pure-Dart, injected-`today` engine boundary), **domain-claims-register-and-science-screen** (the testing-effect copy that frames why this flow exists).
