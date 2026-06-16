# references — domain-grading-pipeline

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it. No rule in `SKILL.md` exists without a source here.

## Primary

- `docs/PRD.md` §8 (Grading (no-AI): self + on-device teacher) — **The whole contract.** Two sources, one normalized signal `(grade, error_lines, source)`; **no audio, no AI**. §8.1: recite from memory → reveal-on-tap → tap stumble lines → grade *suggested* from stumble count, still user-confirmable; self-rating carries lower confidence (`sourceConfidence ≈ 0.5`), moves stability less, and cannot reach the top tier alone. §8.2: teacher physically present, taps verdict + optional stumble lines on the same device, `sourceConfidence = 1.0`, authoritative (sets weak-flags, can graduate/demote, overrides); recorded in the **append-only `review_log`** with an optional teacher label (a local *sanad* trail, no server); halaqa mode switches profiles on one device. §8.3: **no microphone, no recording, no speech-to-text, no automatic mistake detection** — correctness is judged by a human.

- `docs/PRD.md` C2 (Hard constraint) — **No AI / no ML / no audio recognition.** Grading is self-rating + on-device teacher sign-off only; no ASR, no "listen and detect mistakes," no on-device model. This is the boundary the entire pipeline lives inside.

- `docs/PRD.md` R1 / §8.3 — **The sacred-text guard.** A dropped/added/swapped word is never "Good"; error positions can only *lower* a self-rated grade, never raise it. Enforce by capping the normalized grade at `Grade.hard` when `missedOrAlteredWord == true` before the `ReviewInput` is emitted.

- `docs/PRD.md` R5 / R6 — **R5 Privacy:** fully offline, no telemetry, the app never records audio (no microphone use, which also protects women's privacy by construction). **R6 Servant to the talaqqī chain:** teacher sign-off is a first-class grade that *overrides* any self-rating or algorithmic state; the app aids revision, never replaces oral correction (*talaqqī*) and the *sanad* chain.

- `docs/engineering/06-scheduling-engine.md` §4 (The review update: lapse vs success, and the sacred-text guard) — **How the engine consumes the grade.** `onReview(card, ReviewInput, today)` runs one deterministic update path: the sacred-text guard caps the grade (`grade ≤ Hard` when a word was missed/altered), `conf = teacher ? 1.0 : kSelfConfidence` scales the *applied stability gain* down for noisy self-rating, and **`errorLines` and confusion-edge updates are applied at full strength regardless of source** — only the magnitude of the S move is confidence-scaled. The grade-to-G map is Again 1 / Hard 2 / Good 3 / Easy 4. Take: produce the `ReviewInput` correctly; the engine does the math.

- `docs/engineering/06-scheduling-engine.md` §2 (Data model) — **The exact `ReviewInput` shape** the pipeline must emit: `Grade grade; List<int> errorLines (1-based, may be empty); Source source; bool missedOrAlteredWord;` and the `Grade { again, hard, good, easy }` / `Source { self_, teacher }` enums. The engine treats `today` as injected and computes `due_at` itself — the grading layer supplies none of that.

## Supporting (science — why the flow is shaped this way)

- `docs/science/04-retrieval-practice-and-self-testing.md` §1 (Testing changes memory) — Reciting from memory is itself a learning event, stronger than re-reading; the daily session is a sequence of *retrievals*, page hidden, recited **before** any glyphs appear. The reason the flow's primary verb is "recite," not "read."

- `docs/science/04-retrieval-practice-and-self-testing.md` §4 (Recall beats recognition) — Free recall (*g* = 0.79) ≫ recognition (*g* = 0.32); hiding the page makes the recite flow the strongest possible practice. The reveal exists only to enable feedback, never to cue the recitation — no read-along, no fill-in-the-word as an equivalent.

- `docs/science/04-retrieval-practice-and-self-testing.md` §5 (Feedback after the attempt, slightly delayed) — Feedback nearly doubles the effect (*g* = 0.73 with vs 0.39 without) and belongs **after** the full recitation, ideally slightly delayed; marking error positions delivers *targeted* corrective feedback and seeds mutashābihāt detection; talaqqī = retrieval with expert feedback. No mid-recitation teleprompter.

- `docs/science/04-retrieval-practice-and-self-testing.md` §7 (Bounded by *successful* retrieval) — The benefit requires retrieval that *succeeds*; keep genuinely-unmemorized/lost pages out of the retrieval queue (they return to NEW/sabaq); the sacred-text guard caps an error-laden attempt at `Hard` so it is registered honestly and reviewed sooner.

- `docs/science/04-retrieval-practice-and-self-testing.md` §6 (The re-reading illusion) — Re-reading *feels* more effective than it is; correct it by making recall the path of least resistance — calmly, never via guilt, streaks, or leaderboards. Underwrites the "calm receipt, no celebration" rule.

- `docs/PRD.md` C6 (No gamification of worship) — No leaderboards, XP, badges, confetti, or guilt/streak nags on a grade; framing is calm loss-prevention. A `Good` logs the same calm path as any other verdict.

## Sibling skills

- **domain-scheduling-engine-rules** — owns `onReview`, the FSRS S/D update, source-confidence *scaling*, the trust clamp, and `targetR` tiers. This skill stops at producing the `ReviewInput`.
- **ui-recite-grade-flow** — owns the reveal-on-tap screen, muṣḥaf glyph rendering, line-tap hit targets, and RTL layout of the recite/grade surface.
- **domain-mutashabihat-interference** — owns confusion-edge bookkeeping from a "swap" error and pulling siblings into the same session.
- **eng-add-persisted-model** — owns the Drift schema + append-only `review_log` / `card` write path.
- **eng-create-engine-package** — owns the pure-Dart engine boundary (no I/O, no `DateTime.now()`, injected `today`).
- **domain-claims-register-and-science-screen** — owns the cited in-app copy that explains why reciting-from-memory beats re-reading.
