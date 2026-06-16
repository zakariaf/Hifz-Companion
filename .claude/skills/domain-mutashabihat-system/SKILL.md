---
name: domain-mutashabihat-system
description: Build or change the Hifz app's mutashābihāt (similar-verse) interference subsystem — the scholar-reviewed confusables dataset, the personal confusion log, discrimination interleaving, confusion-aware grading, and anchor hinting. Use whenever you touch the Mutashābihāt trainer screen, the confusables graph/dataset, discrimination drills, swap-error (confusion) logging, the `confusion_edge` graph, or interference difficulty bumps in the scheduler.
---

# domain-mutashabihat-system

The interference subsystem: the part of the engine that treats *similarity* — not time — as the adversary. It co-schedules confusable siblings into one session (massed contrast, not spacing), bumps difficulty on every group member when a "wrong-branch" swap is logged, hints the distinguishing word as a highlight overlay on the immutable glyph page, and feeds itself from two sources only — a bundled scholar-reviewed objective-wording dataset and the user's own logged swap errors.

This subsystem is *opposite* to the rest of the scheduler. Everywhere else spacing is the friend; here spacing is the enemy and juxtaposition is the cure. Build it as a deterministic, no-AI policy layer on top of the one FSRS update path, never as a parallel scheduler.

## When to use

Use when building or changing:
- the standalone **Mutashābihāt** trainer screen (browse groups, run discrimination drills, view personal confusion hotspots)
- the confusables dataset (`mutashabih_group` / `mutashabih_member`) or the graph it seeds
- discrimination **interleaving** at session build (`expandMutashabihat(...)` pulling siblings into today's plan)
- **confusion-aware grading** — a swap/wrong-branch error bumping `D` on every group member
- the **personal confusion log** (`confusion_edge`) grown from the user's own swaps
- **anchor hinting** — drawing the distinguishing word(s) as a highlight overlay on the glyph page

Do NOT use this skill for — use the named skill instead:
- the FSRS curve, interval, S/D update, trust clamp, or day-plan assembly in general → use **domain-scheduling-engine**
- the immutable KFGQPC glyph rendering the overlay is drawn *onto* (page geometry, font, checksums) → use **domain-quran-rendering**
- the Drift/SQLite schema, read-only-dataset bundling, and checksums → use **eng-drift-persistence**
- the recite/sign-off flow that normalizes a grade and emits the swap signal before it reaches the engine → use **domain-recite-signoff-flow**
- the retention heat-map and "why you still stumble" Progress surfaces → use **ui-retention-heatmap**

The trainer is the *contrast* path; the ordinary scheduler is the *time* path. A drill that surfaces one sibling alone, or that spaces siblings across days, is the wrong component.

## The canonical pattern

1. **Two mechanisms, never one.** The FSRS backbone models decay of an *independent* page; this layer models *cross-page* competition. They coexist — one never subsumes the other. Confusion is a property of the **group**, not a single page. `docs/science/05-interference-and-mutashabihat.md` §1 (interference ≠ decay) and §2 (it scales *up* with mastery — the near-complete ḥāfiẓ is most exposed); `docs/PRD.md` §9 (first-class subsystem). Keep this layer as policy on the single `onReview` / `buildToday` path in `domain-scheduling-engine`, not a second engine.

2. **The dataset is objective wording only.** The bundled `mutashabih_group(group_id, type, note_key)` / `mutashabih_member(group_id, ayah_id, distinguishing_word_index_json)` tables (`docs/PRD.md` §9.1, §10.1) ship **read-only and checksummed**, scoped to `identical | near_identical | structural` wording overlap — **never** thematic or interpretive links, and never tafsīr/translation to "explain" the difference. `docs/science/05-interference-and-mutashabihat.md` §3 (similarity gradient → objective scope, R4) and §6 (no re-typeset, no tafsīr, R2). The group set is a *static reviewed prior*, not inferred at runtime (`docs/science/05` §7, C2). Until named scholarly sign-off, copy stays framed as an aid, not authority (`docs/PRD.md` §21, R4/R6).

3. **Whole-group drills — never one sibling alone.** Drilling one twin in isolation *suppresses* the unpracticed twin (retrieval-induced forgetting). A discrimination drill always presents the **contrasting pair / full group**; the trainer is forbidden from surfacing a single sibling as isolated review when an unpracticed twin exists. `docs/science/05-interference-and-mutashabihat.md` §4 (Anderson, Bjork & Bjork 1994); `docs/PRD.md` §9.2.

4. **Co-schedule siblings into one session via `expandMutashabihat`.** When any group member is due, pull its sibling(s) into the **same** `buildToday` plan back-to-back — the one place the engine *adds* a not-yet-due card (additive contrast, never a dropped review). `docs/engineering/06-scheduling-engine.md` §7 ("Interference is cured by massing, not spacing"; `expandMutashabihat(...)` inside `buildToday`); `docs/science/05-interference-and-mutashabihat.md` §5 (discriminative-contrast: spacing *removes* the benefit). This is the deliberate exception to the spacing rule — siblings are juxtaposed, not spread across days.

5. **Confusion-aware grading bumps `D` on every member.** A logged "wrong-branch" swap raises difficulty (and thus review frequency) on **all** group members at once, so the unpracticed twin is never left to rot. Route it through the existing `D` channel: `(11−D)` in `stabilityOnSuccess` turns a higher `D` into a shorter interval automatically — no special-case scheduler. `docs/engineering/06-scheduling-engine.md` §4 (the `(11−D)` interference channel; `kWeakLineFactor`-style bump into `D` clamped `[1,10]`); `docs/science/05-interference-and-mutashabihat.md` §4 ("bumps difficulty on every group member"); `docs/PRD.md` §9.2.

6. **The personal confusion log is pure bookkeeping.** A swap (page A's wording recited while located in page B) writes a `confusion_edge(profile_id, ayah_a, ayah_b, weight, last_confused_at)` whose `weight` grows/decays from the user's own history — no ML, no inference (`docs/science/05-interference-and-mutashabihat.md` §7, C2; `docs/PRD.md` §9.1, §10.2). The swap signal is applied at **full strength regardless of source** — even a self-reported swap is valuable graph data; only the *magnitude of the S move* is confidence-scaled. `docs/engineering/06-scheduling-engine.md` §4 (errorLines / confusion-edge updates at full strength; `kSelfConfidence` scales only the stability gain).

7. **Anchor the distinguishing word as an overlay — never re-typeset.** Interference is localized to where the continuations diverge, so the atomic drill is contrasting the distinguishing word(s). Draw a **highlight rectangle over the KFGQPC glyph layer** computed from `distinguishing_word_index_json` and the bundled word geometry — never by editing, re-shaping, or reconstructing the sacred text. `docs/science/05-interference-and-mutashabihat.md` §6 (anchor hinting as overlay, R1); `docs/PRD.md` §9.2, §11.2. Render via `domain-quran-rendering`; this skill only supplies the word indices and toggles the overlay.

8. **Teacher outranks the machine; honest, non-gamified copy.** A teacher can flag a confusion, pin a pair into drills, and override algorithmic state (`manual_lock`, `sourceConfidence = 1.0`) — *talaqqī* is authoritative. The trainer shows hotspots ("you keep swapping these two") as calm, actionable information; it says discrimination training *reduces* swaps, never that a pair is "cured" or "safe to drop." `docs/science/05-interference-and-mutashabihat.md` §8 (teacher sign-off, no gamification, honest bounds); `docs/PRD.md` §8.2, §7.12, R3/R6.

9. **RTL-native, offline, deterministic.** The trainer is built for fa/ckb/ar with `Directionality.rtl`; the contrast drill (recite branch A → branch B, attention on the anchor) *feels harder* than blocked repetition — frame that desirable difficulty calmly, never smooth it away or gamify it. No network: the dataset is bundled once and read offline forever. The interference policy is part of the deterministic engine — no `DateTime.now()`, no `Random`. `docs/science/05-interference-and-mutashabihat.md` §5 (the difficulty *is* the mechanism, C6/R3); `docs/engineering/06-scheduling-engine.md` §8 (determinism: no clock, no RNG, `today` injected).

## Do / Don't

| Do | Don't |
|---|---|
| Model confusion as a property of the **group** on top of the single FSRS update path | Build a second, parallel "interference scheduler" beside the engine |
| Ship `mutashabih_group`/`mutashabih_member` read-only, checksummed, objective wording only | Ship thematic/meaning-based groupings, or bundle tafsīr/translation to "explain" a difference |
| Pull siblings into the **same** session via `expandMutashabihat(...)` | Let ordinary due-date logic surface siblings on different days (spacing them apart) |
| Always drill the **contrasting pair / full group** | Surface one sibling alone as isolated review when an unpracticed twin exists |
| Bump `D` on **every** group member on a swap; let `(11−D)` shorten the interval | Add a special-case frequency override outside the one `onReview` path |
| Apply the swap to the `confusion_edge` graph at full strength; scale only the S move by source | Drop a self-reported swap because it wasn't a teacher sign-off |
| Grow `confusion_edge.weight` from the user's own logged swaps only — plain bookkeeping | Infer "similar verses" at runtime with a model/heuristic, or train on user data |
| Draw the anchor as a highlight overlay from `distinguishing_word_index_json` | Re-typeset, re-shape, or reconstruct Quran text to build a drill |
| Let a teacher flag/pin/override (`manual_lock`, `sourceConfidence = 1.0`) | Let the algorithm overrule a teacher who heard the swap |
| Say drilling *reduces* swaps; surface hotspots as calm information | Mark a pair "cured" / "safe to drop", or turn hotspots into a scoreboard/streak |

## Checklist

Before this subsystem is done:

- [ ] Interference is modeled as a **group** property layered on the single `onReview`/`buildToday` path — no parallel scheduler.
- [ ] The bundled dataset (`mutashabih_group`/`mutashabih_member`) is **read-only, checksummed, objective wording only** (`identical|near_identical|structural`); no thematic links, no tafsīr/translation bundled.
- [ ] Discrimination drills always present the **contrasting pair / full group**; no isolated single-sibling review path exists.
- [ ] `expandMutashabihat(...)` pulls due-siblings into the **same session** back-to-back; siblings are never spaced across days.
- [ ] A logged swap bumps `D` on **every** group member (clamped `[1,10]`); the shorter interval comes from `(11−D)`, not a bespoke override.
- [ ] Swaps write a `confusion_edge` with a user-history `weight`; pure bookkeeping, **no ML/inference**, applied at full strength while only the S move is source-scaled.
- [ ] Anchor hinting is a **highlight overlay** from `distinguishing_word_index_json` over the immutable glyph layer — text is never re-typeset (rendered via **domain-quran-rendering**).
- [ ] Teacher can flag/pin/override (`manual_lock`, `sourceConfidence = 1.0`); the machine never overrules *talaqqī*.
- [ ] Copy says drilling *reduces* swaps; no "cured"/"safe to drop"; hotspots are calm, no points/badges/streaks/confetti.
- [ ] Trainer wrapped in `Directionality.rtl` and verified in **fa, ckb, ar**; numerals/labels localized, no truncation of the distinguishing phrase.
- [ ] Fully offline (bundled dataset, airplane-mode forever) and deterministic (no `DateTime.now()`, no `Random` in the engine path; `today` injected).
- [ ] The "contrast feels harder" desirable difficulty is framed calmly, never smoothed away or gamified.

The drill surfaces objective *wording* divergence and issues no interpretation. If a screen ever adds a textual gloss of *why* two verses differ, that is interpretation the app refuses to adjudicate — keep it out (R2). Everything here is a servant to the teacher; the *sanad* and oral correction outrank the graph.

## Files

- `template.dart` — copy-paste scaffold: the `MutashabihGroup`/`MutashabihMember`/`ConfusionEdge` value types, `expandMutashabihat(...)` session co-scheduling, the confusion-aware `D` bump, the `confusion_edge` logging method, the anchor-overlay widget, and the RTL trainer screen with a deterministic preview. Fill the `// TODO` markers; reference tokens/engine rules by name only.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-scheduling-engine** (the FSRS `onReview`/`buildToday`/trust-clamp path this layer rides on), **domain-quran-rendering** (the immutable glyph layer the anchor overlay is drawn onto), **eng-drift-persistence** (the read-only dataset bundling/checksums and `confusion_edge` table), **domain-recite-signoff-flow** (normalizes the grade and emits the swap signal before the engine), **ui-retention-heatmap** (where "why you still stumble" interference framing also surfaces).
