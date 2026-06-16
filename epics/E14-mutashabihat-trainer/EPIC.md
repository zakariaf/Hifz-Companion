# E14 — Mutashābihāt Trainer

The interference subsystem and its trainer: load the scholar-reviewed objective-wording confusables dataset into the read-only reference tables, grow the personal `confusion_edge` graph from the user's own logged swap errors, wire the two interference behaviours into E04's single engine path (sibling-massing via `expandMutashabihat`, the confusion-aware `(11−D)` difficulty bump on **every** group member), and build the standalone discrimination-drill UI — siblings back-to-back with the distinguishing word(s) drawn as a coordinate overlay on E05's immutable glyph page, plus the calm personal confusion-hotspots view. This layer is *opposite* to the rest of the scheduler: everywhere else spacing is the friend; here spacing is the enemy and juxtaposition is the cure. It is pure bookkeeping — no AI, no microphone, no runtime inference — and a servant to the teacher, who outranks the graph.

## Why this epic exists

For a *finished* ḥāfiẓ who re-recites the whole muṣḥaf on a cycle, the dominant failure mode is not decay but **interference**: two near-identical passages (the *mutashābihāt*) share an opening, a rhythm, and a length, the brain merges their traces, and recitation runs down the wrong branch — and ordinary repetition can *deepen* the confusion rather than fix it (science 05 §1; PRD §2.4, §9). The PRD makes this a first-class subsystem, not a parameter tweak (PRD §9; CLAIMS C-026): interference is a property of the **pair**, scales *up* with how much one holds (the near-complete P1 persona is the most exposed — science 05 §2; CLAIMS C-030), and is cured by **discriminative contrast — juxtaposing the siblings back-to-back so the brain must notice the difference — not by more spacing** (science 05 §5; CLAIMS C-028). E04 already built the one deterministic engine path with the seams for this layer (`expandMutashabihat` co-scheduling and the `(11−D)` interference channel); E05 already built the verified immutable glyph page and the coordinate-overlay painter the anchor hint draws onto; E13 built the reader the drill composes. This epic fills those seams and builds the trainer — without ever forking a second, parallel "interference scheduler."

Three rules from the research bind every line. **Drill the whole group, never one sibling alone**: retrieving one twin in isolation actively *suppresses* the unpracticed one (retrieval-induced forgetting — science 05 §4; CLAIMS C-029), so a swap bumps difficulty on *every* member and a drill always presents the contrasting pair. **The dataset is objective wording only**: scoped to `identical | near_identical | structural` overlap, scholar-reviewed, never interpretive or thematic, and shipped read-only and checksummed — with **zero** bundled tafsīr or translation to "explain" the difference, which would encode a school of thought (PRD R2, R4; science 05 §3; CLAIMS C-027). And **the anchor is an overlay, never a re-typeset**: the distinguishing word is a highlight rectangle over the immutable KFGQPC glyph layer computed from `distinguishing_word_index_json` and the bundled word geometry — the sacred text is rendered, never edited, reshaped, or reconstructed (PRD R1, §11.2; science 05 §6). Above all this, the subsystem is honest about its bounds — it says drilling *reduces* swaps, never that a pair is "cured" or "safe to drop" — and yields to the teacher, who heard the swap with their own ears (science 05 §8; PRD R6, §7.12).

## Scope

### In scope

- Loading the bundled, scholar-reviewed mutashābihāt dataset (`mutashabih_group(group_id, type, note_key)` / `mutashabih_member(group_id, ayah_id, distinguishing_word_index_json)`) into E03's **read-only**, checksum-governed reference tables, scoped to `identical | near_identical | structural` objective wording only (PRD §9.1, §10.1; science 05 §3, §7).
- The `ConfusionEdge` value type and its append-grow-only `confusion_edge(profile_id, ayah_a, ayah_b, weight, last_confused_at)` table + DAO read/write surface through the single write path — the personal confusion log grown from the user's own logged swaps, `weight` a plain function of the user's own history (no ML, no inference) (PRD §9.1, §10.2; science 05 §7; C2).
- The swap-error logging path: a "wrong-branch" error (page A's wording recited while located in page B) writes/strengthens a `confusion_edge` at **full strength regardless of source**, persist-before-republish (engineering 06 §4; science 05 §7).
- Confusion-aware grading wired into E04's single `onReview` path: a logged swap bumps `D` (clamped `[1,10]`) on **every** member of the group, so the shorter interval falls out of the existing `(11−D)` channel — no bespoke frequency override (PRD §9.2; engineering 06 §4, §7; science 05 §4; CLAIMS C-029).
- Seeding E04's `expandMutashabihat(...)` with the dataset+graph so that when any group member is due, its sibling(s) are pulled into the **same** `buildToday` session back-to-back — additive contrast, never a dropped review; siblings are never spaced across days (PRD §9.2; engineering 06 §7; science 05 §5; CLAIMS C-028).
- The group/hotspot read models and scoped Riverpod providers the trainer reads (group with members + distinguishing-word indices; the user's `confusion_edge` rows as calm hotspots), reactive over Drift queries.
- The standalone **Mutashābihāt** trainer feature module (dumb `View` + 1:1 `ViewModel`) and its RTL bottom-nav tab in order **Today · Muṣḥaf · Mutashābihāt · Progress · Settings**: browse groups, run drills, view hotspots (PRD §9.3, §12.4, §19.2).
- The discrimination-drill choreography: iterate the whole group A→B→… back-to-back, each branch **hidden → reveal-on-tap → then anchor highlight**, composing E05's `MushafPageView` + `MushafOverlayPainter`; reveal uses `motion.duration.short`, no bounce/celebration, OS Reduce-Motion respected (PRD §9.2; science 05 §4, §5, §6).
- The anchor-word highlight: a coordinate `Rect` overlay computed from `distinguishing_word_index_json` + bundled word geometry, drawn over the glyph layer via E05's painter — never a re-typeset (PRD §9.2, §11.2, R1; science 05 §6).
- The personal **confusion-hotspots** view ("you keep swapping these two") reading `confusion_edge` read-only, each calm row tapping into its drill — actionable information, never a scoreboard (PRD §9.3, §12.4; science 05 §8; CLAIMS C-029).
- All trainer/drill/hotspot copy run through the adab conscience-check: *reduces* swaps (never "cured"/"safe to drop"), no points/badges/streaks/confetti, framed as an aid to revision and a servant to the teacher until the dataset has named scholarly sign-off (PRD R3, R4, R6, §21; science 05 §8; CLAIMS C-027, C-045).

### Out of scope

- The core FSRS curve/interval, the `onReview` arithmetic, `buildToday`/`loadBalance`, the trust clamp, and the `expandMutashabihat`/`(11−D)` *mechanisms themselves* → **E04 scheduling-engine** (this epic supplies the dataset, the graph, and the policy wiring those seams consume; it adds no second scheduler).
- The immutable KFGQPC glyph page, the `MushafOverlayPainter` coordinate-rect contract, the page geometry/fonts/checksums, and the reference-table DDL/migration → **E05 quran-data-and-rendering** (the dataset *load* rides E05's verified read-only reference tables) and **E03 models-and-persistence** (the table schema).
- The muṣḥaf reader tab, paging, jump-to-juz/ḥizb/surah → **E13 muṣḥaf-reader** (the drill composes the reader's page view; it does not own the reader).
- The recite-from-memory reveal/grade flow where a swap-error is first *captured* during ordinary revision, and the teacher sign-off control → **E12 today-and-recite-grade** (this epic owns the standalone-trainer drill and the `confusion_edge` *write*, and consumes the normalized swap signal E12 emits).
- The retention heat-map and the "why you still stumble" interference framing on Progress → **E15 progress-and-heatmap**.
- The muṣḥaf/riwāyah and term-set pickers, and the per-student halaqa profile switch behind a drill → **E16 settings-profiles-teacher**.
- Registering any user-facing number/claim the trainer surfaces (the science-screen rows behind C-026…C-030) and the science screen → **E19 science-screen-and-claims**.
- The CI banned-import / no-network / dataset-checksum gate scripts → **E01 repo-scaffold-and-ci** (this epic gives them nothing to catch and supplies the dataset-integrity test).
- The named scholarly sign-off of the dataset content itself (a release-blocking human gate) → **E20 release-readiness** (PRD §20.7, §21); this epic keeps copy framed as an aid until it lands.

## Dependencies

### Depends on

- **E04 scheduling-engine** — the single deterministic `onReview`/`buildToday` path with its `expandMutashabihat(...)` co-scheduling seam and the `(11−D)` interference channel that turns a `D` bump into a shorter interval; this epic seeds and wires those, never forks a parallel scheduler (engineering 06 §4, §7).
- **E05 quran-data-and-rendering** — the verified read-only reference tables the dataset loads into, the `MushafEdition`/page geometry, the immutable `MushafPageView`, and the `MushafOverlayPainter` coordinate-rect contract the anchor highlight draws through.
- **E13 muṣḥaf-reader** — the reader/page-view surface the discrimination drill composes each sibling onto (reveal-on-tap over the immutable page).

### Enables

- **E12 today-and-recite-grade** — consumes this epic's `confusion_edge` write path and the confusion-aware bump so a swap caught in the daily recite flow feeds the same graph.
- **E15 progress-and-heatmap** — reads `confusion_edge` for the calm "why you still stumble" interference framing beside the heat-map.
- **E19 science-screen-and-claims** — renders the graded CLAIMS rows (C-026…C-030) this subsystem's behaviour implements.
- **E16 settings-profiles-teacher** — the teacher-pin / per-student halaqa flow that can pin a confusable pair into drills overrides this layer's state.

## Foundation inputs

| Input | Where (doc/skill) | What this epic takes from it |
|---|---|---|
| Mutashābihāt product spec | docs/PRD.md §9 (§9.1 data, §9.2 behaviours, §9.3 trainer), §12.4 | Two-source design (bundled dataset + personal log), the three behaviours (interleaving, confusion-aware grading, anchor hinting), the standalone trainer screen, objective-wording-only scope (R4) |
| Interference science | docs/science/05-interference-and-mutashabihat.md §1–§8 | Interference ≠ decay (§1); scales up with mastery (§2); similarity gradient → objective scope (§3); whole-group drills / retrieval-induced forgetting (§4); juxtaposition not spacing (§5); anchor on the distinguishing word as overlay (§6); two-source bookkeeping (§7); bounded, teacher outranks (§8) |
| Engine interference seams | docs/engineering/06-scheduling-engine.md §4, §7 | The `(11−D)` channel as "interference for free", swap/confusion-edge updates at full strength (only the S move source-scaled), `expandMutashabihat(...)` massing inside `buildToday`, the refuse-to-space-siblings rule |
| Data model | docs/PRD.md §10.1 (reference), §10.2 (`confusion_edge`) | The `mutashabih_group`/`mutashabih_member` read-only tables, the `confusion_edge(profile_id, ayah_a, ayah_b, weight, last_confused_at)` user table, append-only audit discipline |
| Component anatomy / reveal-on-tap | docs/design-system/07-components.md §1, §5 | Overlays as coordinate rects over the glyph layer; reveal-on-tap is retrieval practice; calm-not-cute (no confetti/streak/badge); RTL-native, localized term-sets |
| Mutashābihāt subsystem skill | .claude/skills/domain-mutashabihat-system | The canonical 9-rule pattern + checklist: group-not-node, objective dataset, whole-group drills, `expandMutashabihat`, the `D` bump, the bookkeeping `confusion_edge`, anchor overlay, teacher outranks, offline/deterministic |
| Drill UI skill | .claude/skills/ui-mutashabihat-drill | The whole-group drill choreography, juxtaposition-not-spacing, anchor coordinate overlay, reveal-then-highlight, calm hotspots, RTL term-sets, the dumb View + 1:1 ViewModel feature shape |
| Adab conscience-check | .claude/skills/domain-adab-and-religious-integrity | The always-on guardrails on every drill string/hotspot label: no gamification of the sacred, reduces-not-cures, zero tafsīr, sect-neutral, servant-to-the-teacher, no microphone |
| Persistence + module scaffolds | .claude/skills/eng-add-persisted-model, eng-add-drift-table-or-migration, eng-add-feature-module, eng-create-riverpod-store | The `ConfusionEdge` value type + DAO through the single write path, the read-only dataset load, the `mutashabihat` feature folder + bottom-nav entry, the group/hotspot read-model providers |
| RTL + tests | .claude/skills/eng-rtl-and-bidi-layout, eng-write-dart-test, eng-add-localized-string | RTL-by-geometry + locale-numeral/bidi primitives, the muṣḥaf golden + offline-guard for the drill, fa/ckb/ar ARB coverage for every trainer string |
| Claims behind every number/behaviour | docs/science/CLAIMS.md C-026, C-027, C-028, C-029, C-030 (E. interference & mutashābihāt); C-024 (sequence drills after fluency); C-045 (no reward-chasing on worship) | The graded, sourced rows behind "interference not decay", "objective wording only", "back-to-back contrast", "whole-group drills", "worsens with more held", and the no-gamification adab |

## Deliverables

- [ ] The bundled mutashābihāt dataset loaded into E03's read-only `mutashabih_group`/`mutashabih_member` reference tables, checksum-governed, scoped to `identical | near_identical | structural` objective wording — never thematic/interpretive, never with bundled tafsīr/translation.
- [ ] `ConfusionEdge` immutable value type (in `models`) + the `confusion_edge` Drift table/DAO (in `data`) with read/write methods through the single write path (persist-before-republish); `weight` derived from the user's own logged swaps only.
- [ ] The swap-error logging method: a wrong-branch error writes/strengthens the `(ayah_a, ayah_b)` edge at full strength regardless of source, with `last_confused_at` stamped from the injected `today`.
- [ ] Confusion-aware grading wired into E04's `onReview`: a logged swap bumps `D` on **every** group member (clamped `[1,10]`); the shorter interval comes only from `(11−D)`, no bespoke override — pinned by a test.
- [ ] `expandMutashabihat(...)` seeded with the dataset+graph so a due group member pulls its sibling(s) into the same session back-to-back (additive contrast, never a dropped review), with a test that siblings are never spaced across days.
- [ ] The group read model (members + distinguishing-word indices) and the hotspots read model (`confusion_edge` rows) as scoped Riverpod providers over Drift queries.
- [ ] The `mutashabihat` feature module (dumb `MutashabihatTrainerScreen` + 1:1 `ViewModel`) and its RTL bottom-nav tab in order Today · Muṣḥaf · Mutashābihāt · Progress · Settings.
- [ ] The `DiscriminationDrillView`: iterates the whole group A→B→… back-to-back, each branch hidden → reveal-on-tap → anchor highlight, composing E05/E13's `MushafPageView`; no spacing/interstitial/unrelated page between siblings.
- [ ] The anchor-word highlight as a coordinate `Rect` overlay from `distinguishing_word_index_json` + bundled word geometry, via the `MushafOverlayPainter` — never a re-typeset.
- [ ] The `ConfusionHotspotsView` reading `confusion_edge` read-only as calm, tappable rows ("you keep swapping these two") — no scoreboard/leaderboard/guilt grid, no "cured"/"safe to drop" label.
- [ ] fa/ckb/ar ARB strings for every trainer/drill/hotspot label (locale numerals, bidi-isolated, wrapping not truncating), each run through the adab conscience-check.
- [ ] Test suites: the dataset-integrity/load unit, the `confusion_edge` write-path unit (full-strength swap, weight bookkeeping, persist-before-republish), the "swap bumps D on every member" + "siblings massed not spaced" engine-wiring tests, the drill muṣḥaf golden (whole-group, reveal→anchor, real fonts, RTL × fa/ckb/ar), and the offline-guard test.

## Definition of Done

- [ ] **Offline / no-network:** the dataset is bundled once and read offline forever; nothing in the load, graph, wiring, or drill path opens a socket; E01's banned-import/no-network gates stay green and the drill path passes an `HttpOverrides`-that-throws offline guard.
- [ ] **No AI / no microphone / no inference:** the group set is the bundled scholar-reviewed static dataset; `confusion_edge` is grown only from the user's own logged swaps as plain bookkeeping; nothing infers "similar verses" at runtime, captures audio, or trains on user data (PRD C2, R5; science 05 §7).
- [ ] **Text fidelity (existential):** the anchor is a coordinate `Rect` overlay over the immutable KFGQPC glyph layer (via E05's painter) computed from `distinguishing_word_index_json` + bundled geometry; the sacred text is never edited, reshaped, reflowed, or re-typeset to build a drill; the drill muṣḥaf golden runs with the real per-page fonts (PRD R1, §11.2; science 05 §6).
- [ ] **Objective wording only, zero tafsīr:** the dataset is `identical | near_identical | structural` wording overlap, scholar-reviewed, read-only, checksummed; no thematic/interpretive grouping, and **no** bundled tafsīr or translation to "explain" a difference; the drill shows wording divergence objectively and issues no interpretation (PRD R2, R4; science 05 §3; CLAIMS C-027).
- [ ] **Whole-group, juxtaposed, group-not-node:** every drill presents the contrasting pair / full group (no isolated single-sibling path when an unpracticed twin exists); siblings sit back-to-back in one session with no spacing/interstitial between them; a swap bumps `D` on **every** member and writes an edge on the *pair*, not the node (science 05 §4, §5; CLAIMS C-028, C-029).
- [ ] **One engine path:** the interference behaviour is policy layered on E04's single `onReview`/`buildToday`/`expandMutashabihat`/`(11−D)` path — no second, parallel "interference scheduler"; the layer is deterministic (no `DateTime.now()`, no `Random`; `today` injected) (engineering 06 §4, §7, §8).
- [ ] **Single write path:** every `confusion_edge` mutation persists transactionally before republishing in-memory state; the View reads read models via Riverpod and never mutates persisted state directly.
- [ ] **RTL + fa/ckb/ar localization:** the trainer is RTL-by-geometry across all three locales; page/juz identity uses locale numerals, bidi-isolated; every label is a transcreated term-set string that wraps rather than truncates; the bottom-nav tab keeps RTL order.
- [ ] **Accessibility:** reveal-on-tap and drill controls carry per-locale `Semantics` labels and meet thumb-zone/contrast norms; reveal uses `motion.duration.short` with OS Reduce-Motion respected; the anchor highlight is not encoded by colour alone.
- [ ] **Sect-neutral adab / nothing safe to drop:** copy says drilling *reduces* (never abolishes) swaps and defers to the teacher; no pair is ever "cured", "resolved", or "safe to stop drilling"; no points/badges/streaks/confetti on the drill, the anchor, or the hotspots; until the dataset has named scholarly sign-off, copy stays an aid to revision (PRD R3, R4, R6, §21; science 05 §8; CLAIMS C-027, C-045).
- [ ] **No unsourced number:** every user-facing claim the trainer surfaces is already a graded CLAIMS row (C-026…C-030); no citation or CLAIMS id is invented.
- [ ] **Tests:** the dataset-integrity/load, `confusion_edge` write-path, "swap bumps D on every member", "siblings massed not spaced", the real-font drill muṣḥaf golden (whole-group, reveal→anchor, RTL × fa/ckb/ar), and the offline guard all run in CI on every PR; every Dart file carries the REUSE SPDX header and `///` docs on public APIs and passes the analyzer/lint config.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E14-T01 | [Load the bundled scholar-reviewed mutashābihāt dataset into the read-only reference tables, checksum-governed — test-first](E14-T01-dataset-load.md) | M | E05, E03 |
| E14-T02 | [ConfusionEdge value type + confusion_edge Drift table/DAO with the migration](E14-T02-confusion-edge-model-and-table.md) | M | E03 |
| E14-T03 | [The swap-error logging path: write/strengthen an edge at full strength through the single write path — test-first](E14-T03-swap-logging-write-path.md) | M | E14-T02 |
| E14-T04 | [Confusion-aware grading: a swap bumps D on every group member via the (11−D) channel — test-first](E14-T04-confusion-aware-bump.md) | M | E14-T01, E14-T03, E04 |
| E14-T05 | [Seed expandMutashabihat: due-member pulls siblings into the same session, never spaced — test-first](E14-T05-sibling-massing.md) | M | E14-T01, E04 |
| E14-T06 | [Group and confusion-hotspots read models + scoped Riverpod providers over Drift](E14-T06-read-models-and-providers.md) | M | E14-T01, E14-T02 |
| E14-T07 | [The mutashabihat feature module + RTL bottom-nav tab](E14-T07-feature-module-and-nav.md) | S | E14-T06 |
| E14-T08 | [DiscriminationDrillView: whole-group back-to-back, hidden → reveal-on-tap → anchor, composing the immutable page](E14-T08-discrimination-drill-view.md) | L | E14-T07, E13, E05 |
| E14-T09 | [Anchor-word highlight as a coordinate Rect overlay from distinguishing_word_index_json](E14-T09-anchor-overlay.md) | M | E14-T08, E05 |
| E14-T10 | [ConfusionHotspotsView: calm "you keep swapping these two" rows from confusion_edge](E14-T10-confusion-hotspots-view.md) | M | E14-T06, E14-T07 |
| E14-T11 | [fa/ckb/ar trainer strings via gen_l10n + adab conscience-check pass](E14-T11-localized-strings-and-adab.md) | S | E14-T07, E14-T08, E14-T10 |
| E14-T12 | [Drill muṣḥaf golden (whole-group, reveal→anchor, RTL × fa/ckb/ar) + offline guard](E14-T12-drill-golden-and-offline-guard.md) | M | E14-T08, E14-T09, E14-T11 |

## Risks

- **A second, parallel "interference scheduler."** Building a bespoke frequency override beside E04 would fork the one golden-tested update path and let the two mechanisms drift apart. *Mitigation:* interference is policy layered on the single `onReview`/`buildToday` path — a swap only bumps `D`, and the shorter interval falls out of the existing `(11−D)` channel; the sibling-massing rides `expandMutashabihat`; T04/T05 assert no path outside `onReview` changes a schedule (engineering 06 §4, §7; domain-mutashabihat-system).
- **Drilling one sibling alone, or spacing siblings across days.** Either re-creates the very confusion the subsystem cures — isolated retrieval suppresses the twin, and spacing removes the discrimination benefit. *Mitigation:* the drill always iterates the whole group with no isolated-single path; T05 asserts a due member pulls its siblings into the *same* session; T08 asserts no spacing/interstitial between branches (science 05 §4, §5; CLAIMS C-028, C-029).
- **Re-typesetting the sacred text to build a drill.** Reconstructing or reshaping the wording to highlight a difference is the existential R1 break. *Mitigation:* the anchor is a coordinate `Rect` overlay over E05's immutable glyph layer from `distinguishing_word_index_json`; T09 forbids any text edit/reshape and T12's real-font muṣḥaf golden catches a shifted/reflowed page (PRD R1, §11.2; science 05 §6).
- **Thematic creep / a bundled gloss.** "Similar in meaning" groupings or a tafsīr snippet to explain a difference would stray into interpretation the app refuses to adjudicate. *Mitigation:* T01 loads only `identical | near_identical | structural` objective-wording rows, read-only and checksummed; no tafsīr/translation is bundled; the dataset-integrity test rejects a non-conforming type, and copy stays "aid to revision" until named scholarly sign-off (PRD R2, R4, §21; CLAIMS C-027).
- **Hotspots becoming a scoreboard / a "cured" label.** Turning "you keep swapping these two" into points, a leaderboard, a guilt grid, or marking a pair resolved would gamify worship and over-promise. *Mitigation:* T10 renders calm, tappable info only; the adab conscience-check (T11) forbids points/badges/streaks and any "cured"/"safe to drop" wording; copy says drilling *reduces* swaps (science 05 §8; PRD R3, R6; CLAIMS C-045).
- **A swap dropped because it wasn't a teacher sign-off.** Discarding a self-reported swap would starve the graph of valuable edge data. *Mitigation:* the swap is applied to the `confusion_edge` graph at **full strength regardless of source**; only the *magnitude of the stability move* is source-confidence-scaled (in E04), and a teacher sign-off still supersedes algorithmic state for the pair (engineering 06 §4; PRD R6).
- **Inference or audio sneaking in to detect a swap.** A heuristic or model that guesses confusion at runtime would void the no-AI/no-microphone covenant. *Mitigation:* the group set is the bundled static dataset and personalization is the user's own logged swaps only; T12's offline guard and E01's banned-import gate fail the build on any model/network/audio dependency (PRD C2, R5; science 05 §7).

## References

- docs/PRD.md — §9 (§9.1 data, §9.2 behaviours, §9.3 standalone trainer), §10.1 (reference tables), §10.2 (`confusion_edge`), §12.4 (Mutashābihāt screen), §11.2 (rendering rules / overlays), §4 R1/R2/R3/R4/R5/R6, §19.2 (module layout), §21 (open decisions — dataset sign-off), §20.7 (mutashābihāt dataset gate)
- docs/science/05-interference-and-mutashabihat.md — §1 (interference ≠ decay), §2 (scales up with mastery), §3 (similarity gradient → objective scope), §4 (whole-group drills / retrieval-induced forgetting), §5 (juxtaposition not spacing), §6 (anchor on the distinguishing word as overlay), §7 (two-source bookkeeping, no inference), §8 (bounded, no gamification, teacher outranks)
- docs/engineering/06-scheduling-engine.md — §4 (the review update + the `(11−D)` interference channel + full-strength confusion-edge updates), §7 (`expandMutashabihat(...)` massing inside `buildToday`, refuse-to-space-siblings)
- docs/design-system/07-components.md — §1 (overlays as coordinate rects, RTL-native, calm-not-cute), §5 (reveal-on-tap as retrieval practice)
- docs/science/CLAIMS.md — C-026 (interference not decay), C-027 (objective wording only), C-028 (back-to-back contrast), C-029 (whole-group drills), C-030 (worsens with more held), C-024 (sequence drills after fluency), C-045 (no reward-chasing on worship)
- .claude/skills/domain-mutashabihat-system/SKILL.md — the confusables dataset, `confusion_edge` graph, `expandMutashabihat(...)` co-scheduling, the confusion-aware `D` bump, anchor overlay, teacher-outranks rules
- .claude/skills/ui-mutashabihat-drill/SKILL.md — the whole-group drill choreography, juxtaposition, anchor coordinate overlay, reveal-then-highlight, calm hotspots, the dumb View + 1:1 ViewModel feature shape
- .claude/skills/domain-adab-and-religious-integrity/SKILL.md — the conscience-check on every drill string, hotspot label, and methodology claim
- .claude/skills/eng-add-persisted-model/SKILL.md, eng-add-drift-table-or-migration/SKILL.md, eng-add-feature-module/SKILL.md, eng-create-riverpod-store/SKILL.md, eng-rtl-and-bidi-layout/SKILL.md, eng-write-dart-test/SKILL.md, eng-add-localized-string/SKILL.md — the persistence/module/store/RTL/test/localization scaffolds the tasks follow
