# references — ui-cold-start-placement

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/PRD.md` §7.10 (Cold start — the make-or-break onboarding) — **The five-step contract this flow implements:** (1) coverage capture via fast juz-level taps, un-held stays `UNMEMORIZED`; (2) per-juz **Solid/Shaky/Rusty** → seeds initial `(D, S)`; (3) optional stale-time decay from a "when memorized" date; (4) **conservative bias** — priors *under*-estimate strength so the first recitation can only surprise upward; (5) **convergence** — real grades dominate within ~2–3 weeks, with a light calibration pass that reviews each held page once early. The one thing: this is a *seed-and-converge* flow, never a day-one grading marathon.

- `docs/PRD.md` §12.1 (Onboarding / Cold-start) — **The screen sequence:** welcome + privacy ("we never record audio / never charge") → language + muṣḥaf/riwāyah confirmation → one-time core-pack download → **coverage capture** → **per-juz confidence + optional "when memorized"** → cycle preset + daily budget → **Done → first day generated**. The one thing: placement sits *after* the verified download and *ends* by triggering the first generated day through the store.

- `docs/design-system/07-components.md` §6 (Grade band & component states) — **The control vocabulary to reuse:** `SegmentedButton` is the M3 control for a single mutually-exclusive choice; large `FilledButton`s win when a mis-tap is costly; every interactive control declares explicit M3 **state layers** over a role color, a visible **focus ring** (`color.outline`, SC 2.4.7), and announces enabled/disabled/selected via `Semantics`. The one thing: build Solid/Shaky/Rusty as one single-selection, large, focus-visible, redundantly-encoded picker.

- `docs/design-system/07-components.md` §8 (The heat-map cell) — **The coverage grid's encoding model:** a `GridView` of cells in muṣḥaf order (juz 1 at the start/right in RTL), **redundantly encoded** (color + value/label + glyph, never color alone, SC 1.4.1), tappable, with a `Semantics` label and a selected/focus state — and never a green→red alarm scale, a streak tile, or a completion-% trophy. The one thing: model the "which juz held?" grid on this calm, redundantly-encoded, muṣḥaf-ordered cell.

- `docs/design-system/07-components.md` §1 (The daily-session list) — **The finite-capped principle:** surfaces are finite, capped, and *end* with a calm informational terminal state — never an infinite feed, a count-up, or a confetti moment. The one thing: placement is a bounded three-pass sequence that ends quietly, not an engagement surface.

- `docs/design-system/11-voice-and-tone.md` §2 (Four fixed voice attributes) — **reverent / calm / plain-and-warm / honest** apply to every placement string; the *honest* attribute forbids dressing up estimates and forbids "safe to drop"/"mastered." The one thing: word the confidences and the summary as honest self-report, never praise or a manufactured "ready" score.

- `docs/design-system/11-voice-and-tone.md` §4 (Lead with empathy, never blame) + §5 (Never speak *for* the Quran; teacher outranks the machine) — An un-held or rusty juz is never opened with fault; the app states methodology, issues no verdict on the user's hifz, and never overrides a future teacher sign-off. The one thing: an un-held juz is a neutral fact, not a failure, and placement is a self-report a teacher can later correct.

- `docs/design-system/11-voice-and-tone.md` §6 (Invitation, never command) + §8 (Transcreation, not literal translation) — The optional date is offered, never demanded; Solid/Shaky/Rusty and every label are **transcreated** per locale (fa/ar/ckb register differs), not literally mapped, with locale numerals via `intl` and bidi isolation. The one thing: skippable by default, and the three confidence words carry the same *feeling* in each language, set by native + scholar review.

## Supporting

- `docs/engineering/06-scheduling-engine.md` §5 (Phases, graduation, stakes-tiered retention, and cold start) — **The seeding math the flow calls, never re-implements:** the `_coldStartSeed` table (Solid→D3/S60/FAR · Shaky→D5/S14/NEAR · Rusty→D7/S4/active), the `coldStartCard(pageId, JuzConfidence, today, {memorizedOn})` pure function, the `memorizedOn` stale-time `R`-decay branch, the calibration `dueAt = today`, and the *Pitfalls*: "we refuse optimistic cold-start priors." The one thing: the engine owns `(D, S)` and `today`; the UI only supplies the captured choice.

- `docs/PRD.md` §7.12 (Engine invariants) — All seeding math is pure Dart, deterministic, golden-tested; the engine never implies a page is "safe to stop revising"; a teacher sign-off always supersedes. The one thing: the flow must not leak any non-deterministic input (no `DateTime.now()`) into seeding, and must not assert a verdict the engine forbids.

- `docs/PRD.md` §13.3 / §13.4 / §21 (Localization, term-sets, review) — Locale numerals (Extended Arabic-Indic fa/ckb, Arabic-Indic ar); the section/track/confidence vocabulary is **regional and awaits native + scholarly review**; defaults are placeholders. The one thing: never hardcode a confidence/juz term in English or one dialect — it is a reviewed term-set string.

- `docs/PRD.md` C1 / C2 (Offline; no audio, no AI) — Placement uses no network (the core pack is already verified locally), records no audio, and infers nothing. The one thing: the flow touches no socket and no microphone — it is pure local capture.

## Sibling skills

- **domain-scheduling-engine-rules** — owns `coldStartCard`, the `(D, S)` seed table, stale-time decay, the conservative-bias / calibration-pass / "never safe to drop" invariants; this flow *calls* the seeder and never re-derives the math.
- **domain-asset-pack-integrity** — owns the one-time core-pack download (HTTPS-GET, SHA-256 verify, `awaitingFirstDownload`/`interrupted` states) that precedes coverage capture.
- **eng-add-feature-module** — owns the `lib/src/onboarding/` scaffold, the `GoRoute`, and the dumb-View/ViewModel split this flow lives in.
- **eng-create-riverpod-store** — owns the single write path that persists the seeded cards transactionally before republishing state and generating day one.
- **eng-add-persisted-model** — owns the `Card` / coverage Drift rows the seeded cards land in.
- **domain-calendars-and-hifzdate** — owns the `CalendarDate` value type, the injected "today", and the Hijri/Jalālī/Gregorian rendering of the "when memorized" date.
- **ui-mushaf-page-view** — owns the in-reader "mark my memorized range" tool that also feeds coverage after onboarding.
- **eng-rtl-and-bidi-layout** — owns locale numerals, bidi isolation (FSI/PDI), and RTL mirroring of the grid and rows.
- **domain-adab-and-religious-integrity** — owns the calm, never-shaming, servant-to-teacher copy, the un-held framing, and the privacy line.
- **eng-write-dart-test** — owns the per-locale widget/golden harness on the real bundled fonts and the tap-target/deuteranope checks.
