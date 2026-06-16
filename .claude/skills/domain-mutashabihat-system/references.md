# references — domain-mutashabihat-system

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary — the science of interference

- `docs/science/05-interference-and-mutashabihat.md` §1 (interference, not decay) — **The two-mechanism rule:** the FSRS backbone models decay of an *independent* page; a separate mutashābihāt layer models *cross-page* competition. They coexist; never collapse one into the other. A red page is never labeled "decayed" when the cause is interference.
- `docs/science/05-interference-and-mutashabihat.md` §2 (both directions, scales with mastery) — Confusion is a property of the **group**, not one page, and it *scales up* with how much is memorized — the near-complete ḥāfiẓ is the **most** interference-exposed user (surface the subsystem prominently for them). A confusion event raises difficulty on **all** members.
- `docs/science/05-interference-and-mutashabihat.md` §3 (similarity gradient) — Because interference is predictable from *objective* wording overlap, the dataset is scoped to near-identical/identical wording only (`identical|near_identical|structural`); each group records the **distinguishing word(s)** where responses diverge. Never thematic/interpretive (R2, R4).
- `docs/science/05-interference-and-mutashabihat.md` §4 (retrieval-induced forgetting) — Drilling one twin alone **suppresses** the other. So: whole-group drills always; confusion-aware grading bumps difficulty on every member; siblings are co-scheduled into one session. Never surface a lone sibling when a twin is unpracticed.
- `docs/science/05-interference-and-mutashabihat.md` §5 (discriminative contrast) — **The cure is juxtaposition, not spacing.** Spacing — the friend of ordinary recall — is the *enemy* of discrimination; carve mutashābihāt out of the spacing rule and run back-to-back contrast. The effortful feel is the mechanism (desirable difficulty), not a UX defect — never smooth it away or gamify it.
- `docs/science/05-interference-and-mutashabihat.md` §6 (anchor hinting) — Make the distinguishing word the unit of practice; render it as a **highlight overlay on the faithful glyph page** from the bundled word geometry — never re-typeset, never bundle tafsīr/translation (R1, R2).
- `docs/science/05-interference-and-mutashabihat.md` §7 (two inputs, no AI) — Two feeds only: the bundled scholar-reviewed objective dataset (a static reviewed prior) and the personal confusion log grown from the user's own logged swaps (`confusion_edge` weight). Both are plain bookkeeping; never infer similar verses with a model/heuristic at runtime (C2).
- `docs/science/05-interference-and-mutashabihat.md` §8 (honesty + teacher) — Discrimination training *reduces* swaps; it never "cures" a pair or marks it "safe to drop." The teacher's verdict is authoritative (`manual_lock`, `sourceConfidence = 1.0`); confusion hotspots are calm information, never a scoreboard/streak (C6, R3, R6).

## Primary — the engine that carries it

- `docs/engineering/06-scheduling-engine.md` §7 (Building the day) — `expandMutashabihat(...)` runs inside `buildToday`: when a group member is due, its sibling(s) are pulled into the **same** session back-to-back. This is the one place the engine *adds* a not-yet-due card — additive contrast, never a dropped review. "We refuse to space mutashābihāt siblings apart."
- `docs/engineering/06-scheduling-engine.md` §4 (the review update) — The `(11−D)` factor is the **interference channel for free**: raising a confused page's `D` shortens its interval through the *same* equation — no special-case scheduler. `errorLines`/confusion-edge updates apply at **full strength regardless of source**; only the magnitude of the S move is scaled by `kSelfConfidence` (self 0.5 vs teacher 1.0). The weak-line/`D` bump is clamped `[1,10]`.
- `docs/engineering/06-scheduling-engine.md` §1–§2 (engine boundaries, data model) — The engine is **pure Dart, zero I/O**: no Flutter import, no DB, no clock, no RNG; it takes value objects and an injected `today`. The interference layer is *policy on top of* the one deterministic update path — not a parallel engine. The line overlay that seeds mutashābihāt links is diagnosis-only, created lazily.
- `docs/engineering/06-scheduling-engine.md` §8 (determinism + golden tests) — No `DateTime.now()`, no `Random` anywhere in `engine/`; identical inputs → identical schedule. Encode interference invariants as `glados` property tests (e.g. a swap bumps `D` on every member; the trust clamp still holds; a built day always contains the due sibling alongside its twin).
- `docs/engineering/06-scheduling-engine.md` §6 (the trust clamp) — The clamp (`due_at = min(ideal_due, ceiling_due)`) still governs: nothing the interference layer does may let a page drift past its cycle ceiling or mark it "safe to drop."

## Supporting — product spec & schema

- `docs/PRD.md` §9.1 (Data) — Two inputs: the bundled scholar-reviewed dataset (objective wording only, R4) and the personal confusion log from the user's own logged "swap" errors. Pure bookkeeping, no ML.
- `docs/PRD.md` §9.2 (Behaviors) — The three behaviors verbatim: (1) discrimination interleaving into the same session, (2) confusion-aware grading bumping difficulty/frequency on all group members, (3) anchor hinting as a highlight overlay on the immutable glyph page.
- `docs/PRD.md` §9.3 / §12.4 (Standalone trainer) — The dedicated Mutashābihāt screen: browse groups, run drills on demand, view personal confusion hotspots ("you keep swapping these two").
- `docs/PRD.md` §10.1 (schema, read-only) — `mutashabih_group(group_id, type, note_key)` and `mutashabih_member(group_id, ayah_id, distinguishing_word_index_json)`; shipped read-only/checksummed.
- `docs/PRD.md` §10.2 (schema, per profile) — `confusion_edge(profile_id, ayah_a, ayah_b, weight REAL, last_confused_at)` — the personal graph.
- `docs/PRD.md` §11.2 / R1 (immutable rendering) — The anchor is an overlay of coordinates on the glyph page; the Quran is rendered, never re-typeset.
- `docs/PRD.md` §8.2 / R6 (teacher authority) — Teacher sign-off and *talaqqī* outrank the machine; the algorithm never overrules a heard swap.
- `docs/PRD.md` §21 / R4 (sign-off pending) — Until named scholarly sign-off, dataset copy is framed as an aid to revision, not authority.

## Sibling skills

- **domain-scheduling-engine** — the FSRS `onReview` / `buildToday` / trust-clamp path this interference layer is policy on top of (curve, interval, S/D update, day plan).
- **domain-quran-rendering** — the immutable KFGQPC glyph layer the anchor highlight is drawn onto; owns page/word geometry and checksums.
- **eng-drift-persistence** — Drift/SQLite schema, the read-only bundled-dataset packaging with checksums, and the `confusion_edge` table.
- **domain-recite-signoff-flow** — normalizes the grade (self vs teacher) and emits the swap/wrong-branch signal before it reaches the engine.
- **ui-retention-heatmap** — the Progress heat-map and the calm "why you still stumble" interference framing.
