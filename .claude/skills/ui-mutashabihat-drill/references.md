# references — ui-mutashabihat-drill

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary — what the drill UI must obey

- `docs/science/05-interference-and-mutashabihat.md` §4 (retrieval-induced forgetting) — Drilling one twin in isolation can actively *suppress* the other; a drill therefore **always presents the contrasting pair or full group, never one sibling alone**. This is the screen's first non-negotiable.
- `docs/science/05-interference-and-mutashabihat.md` §5 (discriminative contrast, not spacing) — The cure is **temporal juxtaposition** of confusable passages, not more spacing; spacing removes the discrimination benefit. So the drill shows siblings immediately back-to-back, and the effortful feel is a *desirable difficulty* to name calmly, never to gamify or smooth away.
- `docs/science/05-interference-and-mutashabihat.md` §6 (anchor hinting as overlay) — Interference is localized to the **distinguishing word(s)**; the atomic act is contrasting that divergence, drawn as a **highlight rectangle over the KFGQPC glyph layer** computed from the bundled word geometry — never by editing or re-typesetting text. No tafsīr/translation to "explain the difference".
- `docs/science/05-interference-and-mutashabihat.md` §8 (bounded, not abolished; teacher outranks) — Copy says training *reduces* swaps, never "cured" / "no confusion" / "safe to drop"; the hotspots view is calm actionable information, never a scoreboard; the teacher's verdict is authoritative and the app records, never arbitrates, recitation.
- `docs/science/05-interference-and-mutashabihat.md` §3 & §7 (objective wording; no inference) — Groups are scoped to **near-identical / identical objective wording only** (never thematic/interpretive); the set is a reviewed **static** dataset and personalization is only the user's **own logged swaps** — no model, no runtime heuristic.
- `docs/PRD.md` §9.3 (standalone trainer) — The dedicated **Mutashābihāt** screen: browse groups, run discrimination drills on demand, and view personal **confusion hotspots** ("you keep swapping these two") — actionable in a way a spreadsheet cannot be.
- `docs/PRD.md` §9.1–§9.2 (data + behaviors) — Bundled scholar-reviewed dataset (each group links the ayāt + distinguishing word/phrase) and the personal confusion log; behaviors: **discrimination interleaving** (whole group, same session, back-to-back), **confusion-aware grading** (bump all members), **anchor hinting** as a glyph-page overlay.
- `docs/PRD.md` §11.2 & R1 (immutable rendering) — Overlays (weak line, **mutashābihāt anchor**, current ayah) are drawn as **rectangles/coordinates over the glyph layer**, computed from bundled line/word geometry — never by editing text; the sacred text is never re-shaped or re-typeset for a feature.

## Supporting — tokens, states, layout, RTL

- `docs/design-system/07-components.md` §5 (recite/grade flow) — Reveal-on-tap is a **retrieval-practice** device (hide → recite from memory → reveal → then the marker); page-turn/reveal use **standard easing, short/medium durations only**, no overshoot/confetti/success chime; OS Reduce-Motion respected. The drill borrows this reveal-then-contrast choreography.
- `docs/design-system/07-components.md` §1 (daily-session list) — **RTL by geometry** (`EdgeInsetsDirectional`); section/labels are **localized term-sets, never hardcoded English**; calm terminal states, **no confetti/celebration** (Pillar 2). The hotspots list inherits this calm, RTL, term-set discipline.
- `docs/design-system/07-components.md` §2 (page card) — Locale numerals (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar), mixed Latin/numeral runs **bidi-isolated**; never render Quran glyphs in a list row, never re-typeset an āyah for a preview. The hotspot rows carry page/juz identity the same way.
- `docs/design-system/07-components.md` §8 (heat-map cell) — The "informs, never a scoreboard / never a streak / never a leaderboard" rule for any per-item health surface — the model for keeping confusion hotspots calm and non-competitive.
- `docs/PRD.md` §12 (information architecture) — Bottom-nav **RTL order: Today · Muṣḥaf · Mutashābihāt · Progress · Settings**; §12.4 names the Mutashābihāt tab's job (browse groups, run drills, view hotspots).
- `docs/PRD.md` §13.3–§13.4 (numerals & term-sets) — Locale numeral sets and regional/transcreated term-set labels (switchable per region, awaiting native + scholarly review) — never baked-in English/single-dialect strings.
- `docs/PRD.md` §10.1–§10.2 (schema) — `mutashabih_group(type)`, `mutashabih_member(distinguishing_word_index_json)`, and `confusion_edge(profile_id, ayah_a, ayah_b, weight, last_confused_at)` — the exact read models this View consumes (read-only here).
- `docs/PRD.md` §19.2 (module layout) — `/mutashabihat trainer` is its own feature module: a dumb `View` + 1:1 `ViewModel`, reading via Riverpod, writing only through the single write path.

## Non-negotiables this screen must not violate

- `docs/PRD.md` C2 — **No AI / no ML / no audio recognition.** No microphone, no model, no runtime inference in the drill path.
- `docs/PRD.md` R4 & §21 — The mutashābihāt dataset is **scholar-reviewed and objective-wording-only**, and until named scholarly sign-off copy stays framed as an aid to revision (a servant to the teacher).
- `docs/PRD.md` R6, §8.2 — **Teacher sign-off supersedes** algorithmic/self state; a teacher can pin a pair into drills; the app never overrules a teacher who heard the swap.
- `docs/PRD.md` R3, C6, §7.12 — No gamification of worship; no "safe to drop" / "mastered"; honest, non-shaming framing.

## Sibling skills

- **domain-mutashabihat-system** — the data/engine half: the confusables dataset, the `confusion_edge` graph, `expandMutashabihat(...)` co-scheduling, and the confusion-aware difficulty bumps this View reads but never computes.
- **ui-mushaf-page-view** — the immutable glyph page + coordinate-overlay painter each drill member is rendered through.
- **ui-recite-grade-flow** — where a swap-error is actually captured and logged as a `confusion_edge`.
- **ui-page-card** — the track chip + decay indicator on Today/Progress (a separate component family).
- **domain-adab-and-religious-integrity** — the always-on conscience-check on every drill string, hotspot label, and methodology claim.
- **eng-add-feature-module** — the `mutashabihat` feature folder, route, and RTL bottom-nav entry.
- **eng-create-riverpod-store** — the group/hotspot read models and the single write path.
- **eng-rtl-and-bidi-layout** — the RTL/bidi + locale-numeral primitives.
- **eng-write-dart-test** — the muṣḥaf golden (real per-page font) and the offline-guard test for the drill path.
