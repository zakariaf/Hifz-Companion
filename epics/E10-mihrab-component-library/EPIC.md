# E10 — Mihrab Component Library

Build the breadth of the Mihrab reusable-widget library as a parallel workflow off the walking-skeleton critical path: the page card + non-interactive track chip + decay indicator, the heat-map cell, the four-level grade band, the evidence-certainty label, the cycle-preset and Settings pickers, the calm catch-up and empty-state banners, the reminder row, the destructive-confirm gate, and the numerals/calendar/text rendering primitive every other surface leans on. Each component ships as a token-only, RTL-native, fa/ckb/ar-localized leaf widget with a full `#Preview`-equivalent state matrix and per-locale golden coverage, plus the [09-accessibility-and-inclusivity.md](../../docs/design-system/09-accessibility-and-inclusivity.md) anatomy (semantic labels, color-independence, 48dp targets, contrast floors) baked in from the first commit. The library is the inventory the feature epics (E12–E19) assemble; it builds no screen, mutates no engine state, and opens no socket.

## Why this epic exists

The PRD's whole thesis is that *tradition is the interface and the math is invisible* (PRD §2, §7), which means the trust of huffaz and teachers is won or lost in the small, repeated surfaces — the track chip that names *manzil* in the teacher's own word, the decay indicator that says "needs revision" without ever shading toward an alarm-red scoreboard, the grade band that caps a dropped word at *Hard*. These are also the surfaces where the non-negotiables are most easily broken one widget at a time: a page card that leaks a raw `R` percentage (PRD §7.12), a heat-map cell colored green→red instead of the honest single-hue lightness ramp ([08-data-visualization.md](../../docs/design-system/08-data-visualization.md) §2–§3), a certainty label that promises "proven" instead of describing the strength of the evidence ([ui-certainty-label]; `docs/science/11-the-in-app-science-screen.md` §5), a reminder row that nags about loss (PRD R3, §14). Designing each component *once*, correctly, against [07-components.md](../../docs/design-system/07-components.md) and gating it with a per-locale golden matrix is how those rules become structural instead of a review-time hope. The work is deliberately split out of the E07 walking skeleton because none of it sits on the thin end-to-end spine — the skeleton needs only the few widgets it renders, while the *breadth* (every state of every component across fa/ckb/ar) is independent leaf work that would bloat the skeleton's critical path. Pulling it into its own epic lets it run as a parallel workflow on the E06 token/theme foundation, so the feature epics inherit a complete, golden-pinned, accessibility-audited inventory rather than discovering a dozen half-built widgets during feature integration. Every component is a *renderer* of state the engine and stores already computed; building them in isolation, with deterministic fakes and frozen goldens, is the cheapest tier at which the design-system's honesty rules can be made a build-or-fail check.

## Scope

### In scope

- **Page card + track chip + decay indicator** — the one-muṣḥaf-page row (leading chip + decay swatch, locale-numeral "Page N · Juz M" headline, optional supporting hint, trailing chevron) at elevation Level 0–1, in all six states (default / weak / due-today / pulled-forward / done / locked); the non-interactive *sabaq/sabqi/manzil* term-set chip; the three-way (color + glyph + label) decay indicator. Glyph-free: the row never draws Quran text.
- **Heat-map cell** — the single repeated `GridView` retention tile (single-hue lightness ramp, VSUP-style uncertainty muting, redundant color + number + label, min-leaning juz roll-up badge, selected/focus state) as a *component*, not the Progress screen it tiles into.
- **Grade band + interaction-state model** — the four-level Again/Hard/Good/Easy `FilledButton` row (enabled / pressed / disabled-until-revealed / focused), the canonical M3 state-layer model the rest of the library reuses, the teacher-present sign-off toggle as a labelled `Switch.adaptive` leaf.
- **Evidence-certainty label** — the calm, neutral, single-container badge mapping a sealed `EvidenceGrade` ([MA]/[RCT]/[EXP]/[CS]/[OBS]/[TEXT]/[TRAD]) to a lay confidence-about-the-evidence phrase, plus the plain-words legend; never a star rating, traffic-light color, or retention promise.
- **Pickers** — the named cycle-preset / Pure-cycle selector (the visible face of the cycle ceiling, never a retention slider) and the single-choice Settings picker pattern (language / calendar / numerals / term-set / theme / muṣḥaf) on the M3 single-select control.
- **Banners** — the calm missed-day catch-up banner (empathy → fact → re-spread plan → choice) and the empty / first-run / all-done / silent-welcome-back states, both as *states* of a host surface, non-shaming by construction.
- **Reminder row** — the opt-in, off-by-default daily-reminder toggle + time picker + optional catch-up-note toggle, with calm neutral copy and no escalation.
- **Destructive-confirm gate** — the two-step erase-all / wipe-profile consequence dialog with the safe (cancel) path visually primary and thumb-zone difficulty as the safety margin; an honest safeguard, never an obstruction dark pattern.
- **Numerals / calendar / text primitive** — the shared `numberFormatFor(locale)` numeral path and `CalendarPresenter` display boundary (locale digit set, chosen calendar, FSI/PDI bidi isolation) that every component above calls instead of re-implementing.
- For every component: a token-only build (all `color.*` / `type.*` / `space.*` / `touch.min` referenced by name, logical start/end only), a full preview/state matrix, and per-locale (fa/ckb/ar) golden tests on the **real** bundled UI fonts, with the §10 accessibility guidelines (`androidTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`, color-independence) asserted.

### Out of scope

- The **Today daily-session list** container (the finite, capped Far→Near→New sliver list, its loading/populated/all-done sequencing, the honest budget-feedback line) and the **recite/grade flow** route — these *assemble* the page card and grade band → **E12 today-and-recite-grade**.
- The **Progress retention heat-map screen** (the 604-cell whole-Quran grid, the page-detail sheet, the upcoming-load forecast) that lays out the heat-map cell → **E15 progress-and-heatmap**.
- The **science screen** that renders certainty labels beside CLAIMS source rows, and the CLAIMS register itself → **E19 science-screen-and-claims**.
- The **onboarding / cold-start placement** flow that hosts the cycle-preset pick → **E11 onboarding-and-cold-start**; the **Settings / profiles** screens that host the Settings picker, reminder row, and destructive-confirm → **E16 settings-profiles-teacher**.
- The **backup card** (export/restore/erase status surface) the destructive-confirm gate fronts → **E17 backup-and-restore**; the **notification scheduling** the reminder row configures → **E18 reminders**.
- The **muṣḥaf page renderer / overlay painter** and any Quran-glyph drawing → **E13 mushaf-reader** (governed by **domain-mushaf-text-integrity**); no component here draws a glyph.
- The **engine state** each component reads — the schedule, track assignment, `due_at`, `R`, the trust clamp, the catch-up re-spread math, the cold-start seeds → **E04 scheduling-engine** (the widgets render the result, never re-derive it).
- The **Riverpod stores / single-write-path mutations**, **DAOs/migrations**, and **ARB string authoring** the components consume → owned by the eng-* skills and wired in the feature epics; this epic builds domain-blind leaves fed by deterministic fakes and fixture strings.

## Dependencies

### Depends on

- **E06 mihrab-foundation** — the design-system token families (`color.*` incl. the `color.heatmap.*` ramp and `color.semantic.warning`, `type.*`, `space.*`, `touch.min`, `motion.*`/`haptic.*`), the Material 3 + theme setup, and the four appearances (light / sepia / dark / night) every component renders and is golden-tested against. Every widget here references those tokens by name; none defines a value.

### Enables

- **E11 onboarding-and-cold-start** (places the cycle-preset picker and the welcoming first-run empty state), **E12 today-and-recite-grade** (assembles the page card + grade band + catch-up banner into the Today list and recite flow), **E15 progress-and-heatmap** (lays out the heat-map cell into the whole-Quran grid), **E16 settings-profiles-teacher** (composes the Settings picker, reminder row, and destructive-confirm gate), **E17 backup-and-restore** (fronts erase with the destructive-confirm gate), **E18 reminders** (drives the reminder row's scheduled notification), and **E19 science-screen-and-claims** (renders the certainty label beside each CLAIMS source). Every feature epic draws from this inventory instead of inventing widgets.

## Foundation inputs

| Input | Where (doc / skill) | What this epic takes |
|---|---|---|
| Component anatomies | docs/design-system/07-components.md §1–§8 | The page card / track chip / decay indicator / grade band / state model / teacher sign-off / heat-map cell specs — anatomy, states, a11y contract, science note — this library instantiates verbatim |
| Heat-map visual grammar | docs/design-system/08-data-visualization.md §2–§6 | The single-hue lightness ramp, VSUP-style uncertainty muting, redundant color+number+label, min-leaning juz roll-up, and "never a scoreboard" rules the heat-map *cell* obeys |
| Accessibility anatomy | docs/design-system/09-accessibility-and-inclusivity.md §3–§8, §10 | Contrast floors (4.5:1 text / 3:1 non-text), color-independence (1.4.1), 200% text-scale reflow, 48dp/44pt targets, localized semantic labels, RTL focus order, and the `meetsGuideline` release gates each component's golden suite asserts |
| Tokens & themes | docs/design-system/03-color-and-themes.md, 04-typography.md, 05-layout-spacing-touch.md, 06-motion-and-haptics.md | The `color.*`/`type.*`/`space.*`/`touch.min`/`motion.*` names every component references — never a raw value — via E06 |
| Engine invariants behind the cards | PRD §7.12, §10.3 | What the page card and heat-map cell may *never* surface — raw D/S/R, a percentage, "safe to drop" — and the min-leaning roll-up they honor |
| Evidence grades | docs/science/CLAIMS.md (grade legend); 11-the-in-app-science-screen.md §4–§6 | The seven `EvidenceGrade` values and the "translate grades into honest confidence language, no star rating, no proven" rule the certainty label renders |
| CLAIMS behind user-facing numbers | docs/science/CLAIMS.md | Any number a component shows (decay band derived from `R`; the certainty phrase) traces to a CLAIMS row; the decay/heat-map honesty rules trace to C-001/C-016 and PRD §7.12 |
| Skill: page card | ui-page-card | The row/chip/decay-indicator anatomy, the six states, the glyph-free rule, and its per-locale state golden harness |
| Skill: pickers | ui-cycle-preset-picker, ui-settings-picker | The named-cycle (cycle-ceiling, not a slider) selector and the single-choice display-only preference picker patterns |
| Skill: certainty label | ui-certainty-label | The pure `certaintyLabel(EvidenceGrade)` mapping, the neutral single-container badge, and the plain-words legend |
| Skills: banners | ui-empty-state, ui-catch-up-banner | The calm-face-of-absence empty/all-done/welcome-back states and the empathy→fact→plan→choice catch-up banner |
| Skills: rows & gates | ui-reminder-row, ui-destructive-confirm | The opt-in off-by-default reminder row and the honest two-step irreversible-action gate (safe path primary) |
| Skill: numerals/calendar/text | ui-numerals-calendar-text | The `numberFormatFor(locale)` numeral path and `CalendarPresenter` boundary every component renders numbers/dates through |
| Skill: RTL & bidi | eng-rtl-and-bidi-layout | Logical start/end insets, the icon-mirror policy, and FSI/PDI isolation each component's layout obeys |
| Skill: adab conscience-check | domain-adab-and-religious-integrity | The always-on review of every label, chip term, banner line, and grade verb — no guilt/fear/loss, no "safe to drop", servant-to-teacher, sect-neutral |
| Skill: tests | eng-write-dart-test | The widget + per-locale (fa/ckb/ar) golden matrix on real fonts, the `meetsGuideline` assertions, the grayscale/deuteranope check, and the throwing-`HttpOverrides` offline guard |

## Deliverables

- [ ] `PageCard` + non-interactive `TrackChip` + `DecayIndicator` leaf widgets, six states, glyph-free, fed a domain-blind view model, with a per-locale six-state golden matrix.
- [ ] `HeatmapCell` leaf widget (ramp + VSUP muting + redundant encoding + min-leaning roll-up badge + selected/focus state) with a golden matrix across strength/uncertainty levels and a grayscale/deuteranope readability check.
- [ ] `GradeBand` (Again/Hard/Good/Easy) + the shared M3 interaction-state model + the `TeacherSignoffToggle` leaf, with enabled/pressed/disabled-until-revealed/focused goldens.
- [ ] `CertaintyLabel` badge + pure `certaintyLabel(EvidenceGrade)` mapping + grade legend, with a seven-grade × three-locale golden matrix proving the neutral (non-traffic-light) styling.
- [ ] `CyclePresetPicker` (incl. Pure-cycle toggle) and the `SettingsPicker` single-select pattern, with selected-state and per-locale goldens.
- [ ] `CatchUpBanner` and the `EmptyState` family (first-run / all-done / silent-welcome-back), with goldens and the no-shame/no-streak copy invariants.
- [ ] `ReminderRow` (toggle + time picker + catch-up-note toggle) and the `DestructiveConfirm` two-step gate, with off-by-default and safe-path-primary goldens.
- [ ] The shared `numberFormatFor(locale)` formatter and `CalendarPresenter` display boundary, with locale-numeral and calendar-rendering unit + golden coverage, consumed by every component above.
- [ ] A component preview/gallery harness (the `#Preview`-equivalent state matrix) so each widget's full state set is renderable in isolation without a host screen.
- [ ] Widget + golden CI job green across fa/ckb/ar in all four appearances on the real bundled UI fonts, with `androidTapTargetGuideline` / `labeledTapTargetGuideline` / `textContrastGuideline` and color-independence asserted, under the throwing-`HttpOverrides` offline guard.

## Definition of Done

- [ ] Every component renders correctly in **all three locales (fa, ckb, ar), all RTL**, in all four appearances (light / sepia / dark / night); the per-locale golden matrix is green and the ckb transcreation (the longest string) reflows without clipping at 200% text scale.
- [ ] **Offline / no-network by construction**: no component fetches, no `google_fonts` runtime call, no socket; the widget-test bootstrap installs a throwing `HttpOverrides` and the banned-import gate stays green over the new widget code.
- [ ] **No AI / no audio / no microphone**: no component records, infers, or invokes any model; the grade band and teacher toggle capture a *human* verdict only.
- [ ] **Text fidelity**: no component renders a Quran glyph or re-typesets any āyah — the muṣḥaf lives only in the E13 reader; goldens use the real bundled UI fonts, never `Ahem`, and never the QPC glyph fonts.
- [ ] **Engine-honesty invariants hold at the widget layer**: no card or cell ever shows a raw D/S/R, a retention percentage, or a "safe to drop" / "mastered" state; the decay band and juz roll-up are derived (min-leaning) and read only as solid…needs-revision (PRD §7.12, §10.3).
- [ ] **No gamification of worship**: no streak, points, badge, leaderboard, confetti, celebratory motion, or loss/guilt/fear copy on any component; the catch-up banner and empty states are calm and non-shaming; the heat-map cell is never a scoreboard (PRD R3, C6).
- [ ] **Accessibility (WCAG 2.2 AA)**: every interactive component is ≥48×48dp / 44×44pt with a localized `Semantics` label; multi-part items use `MergeSemantics`; decoration uses `ExcludeSemantics`; color is never the sole signal; text ≥4.5:1 and non-text ≥3:1 in every appearance — all asserted by `meetsGuideline` and a grayscale/deuteranope check (09 §10 gates A1–A8).
- [ ] **Adab / sect-neutrality**: every label, chip term-set, banner line, grade verb, and certainty phrase passes the **domain-adab-and-religious-integrity** conscience-check; `[TRAD]` issues no fiqh ruling and is not ranked above empirical grades; copy is servant-to-the-teacher.
- [ ] **Localization**: every user-facing string is an `AppLocalizations` key (ar template + fa/ckb transcreation), no hardcoded literal; every number/date renders through `numberFormatFor(locale)` / `CalendarPresenter` in the locale digit set with FSI/PDI isolation — never raw ASCII.
- [ ] **Token-only**: all visual properties come from named `color.*`/`type.*`/`space.*`/`touch.min`/`motion.*` tokens (E06); no inline hex/pt/dp; logical start/end only.
- [ ] **Tests**: each component has a widget test plus a per-locale golden matrix on real fonts; the suite runs in CI on every PR; correctness-critical mappings (the `certaintyLabel` function, the decay-band derivation, the numeral/calendar formatter) are unit-tested test-first.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E10-T01 | [Numerals/calendar/text primitive: numberFormatFor + CalendarPresenter with locale-numeral and calendar goldens](E10-T01-numerals-calendar-text-primitive.md) | M | E06 |
| E10-T02 | [Component preview/gallery harness + shared M3 interaction-state model and golden-matrix scaffolding](E10-T02-preview-harness-and-state-model.md) | M | E06 |
| E10-T03 | [Page card + non-interactive track chip + decay indicator, six states, glyph-free, per-locale state goldens](E10-T03-page-card-track-chip-decay.md) | L | E10-T01, E10-T02 |
| E10-T04 | [Heat-map cell: lightness ramp, VSUP uncertainty muting, redundant encoding, min-leaning roll-up badge](E10-T04-heatmap-cell.md) | L | E10-T01, E10-T02 |
| E10-T05 | [Grade band (Again/Hard/Good/Easy) + disabled-until-revealed state + teacher sign-off toggle leaf](E10-T05-grade-band-and-signoff-toggle.md) | M | E10-T02 |
| E10-T06 | [Evidence-certainty label: pure certaintyLabel(EvidenceGrade) mapping + neutral badge + plain-words legend](E10-T06-certainty-label-and-legend.md) | M | E10-T02 |
| E10-T07 | [Cycle-preset picker (incl. Pure-cycle toggle) + single-choice Settings picker pattern](E10-T07-cycle-preset-and-settings-pickers.md) | M | E10-T01, E10-T02 |
| E10-T08 | [Catch-up banner + empty-state family (first-run / all-done / silent welcome-back), no-shame invariants](E10-T08-catchup-banner-and-empty-states.md) | M | E10-T01, E10-T02 |
| E10-T09 | [Reminder row (opt-in, off-by-default, time picker, catch-up-note toggle) + destructive-confirm gate](E10-T09-reminder-row-and-destructive-confirm.md) | M | E10-T01, E10-T02 |
| E10-T10 | [Library accessibility + per-locale golden CI gate: meetsGuideline, color-independence, offline guard across all components](E10-T10-accessibility-and-golden-ci-gate.md) | M | E10-T03, E10-T04, E10-T05, E10-T06, E10-T07, E10-T08, E10-T09 |

## Risks

- **The library grows into screens.** A "while I'm here" temptation turns the page card into the Today list, or the heat-map cell into the Progress grid. *Mitigation:* each task is a domain-blind *leaf* fed a fixture view model; any list container, route, screen, or store wiring is rejected in review and filed against the owning feature epic (E12/E15/E16/E19), per the explicit Out-of-scope pointers.
- **An honesty rule is broken one widget at a time.** A leaked `R` percentage, a green→red heat-map, a "proven" certainty badge, or a guilt-framed reminder each individually violates a non-negotiable. *Mitigation:* the engine-honesty / adab / color-independence rules are encoded as golden + unit assertions (no percentage in the card golden, neutral-styling golden for the badge, grayscale check for the cell) so a violation fails CI, not just review; the adab conscience-check runs on every label.
- **Goldens authored in one locale rot in the others.** A widget that passes in `ar` clips or mis-orders in `ckb` (the longest transcreation) or breaks bidi in a mixed numeral run. *Mitigation:* every golden is a fa × ckb × ar matrix on the real bundled fonts at 1× and 200%, and the numeral/calendar primitive (T01) is the single rendering path so a bidi/numeral fix lands once for the whole library.
- **Components built before the consuming feature drift from real need.** A leaf shaped for an imagined screen needs rework when E12–E19 assemble it. *Mitigation:* each component's view-model contract is taken straight from its skill's canonical pattern and the 07-components anatomy, which the feature epics also cite — so the leaf is built to the documented contract, not a guess, and the feature epic replaces layout, not the component.
- **State-matrix breadth balloons the epic.** Six page-card states × four appearances × three locales is large; multiplied across nine components it can sprawl. *Mitigation:* the shared preview harness and state model (T02) and the shared numeral primitive (T01) are built first so every later task reuses one scaffold; the matrix is generated, not hand-duplicated.
- **Accessibility deferred to the end.** Treating the §10 gates as a final task invites per-component shortcuts. *Mitigation:* every component task carries its own `Semantics`/contrast/target acceptance criteria, and T10 is the *aggregate* CI gate that proves the whole library together — not the first place accessibility is considered.

## References

- docs/PRD.md — §2 (tradition-is-the-interface), §6.2–§6.3 (tracks, grade scale), §7.5–§7.12 (retention targets, trust clamp, engine invariants), §10.3 (min-leaning roll-up), §13 (localization & RTL), §14 (notifications), §18 (accessibility), R3/C6 (no gamification), C1/C2 (offline, no-AI)
- docs/design-system/07-components.md — §1 daily-session list (context), §2 page card, §3 track chip, §4 decay indicator, §5 recite/grade flow, §6 state model, §7 teacher sign-off, §8 heat-map cell
- docs/design-system/08-data-visualization.md — §2 single-hue ramp, §3 decay-not-alarm, §4 VSUP uncertainty muting, §5 redundant encoding, §6 min-leaning roll-up, §8 never-a-scoreboard
- docs/design-system/09-accessibility-and-inclusivity.md — §3 contrast floors, §4 color-independence, §5 text scaling, §6 touch targets, §7 semantic labels, §8 RTL focus order, §10 release-gate checklist (A1–A9)
- docs/design-system/03-color-and-themes.md, 04-typography.md, 05-layout-spacing-touch.md, 06-motion-and-haptics.md — token families referenced by name (E06)
- docs/science/CLAIMS.md — evidence-grade legend and the C-001/C-016/§7.12-honesty rows behind the decay/heat-map/certainty surfaces; docs/science/11-the-in-app-science-screen.md §4–§6 (certainty wording)
- .claude/skills/ — ui-page-card, ui-cycle-preset-picker, ui-settings-picker, ui-certainty-label, ui-empty-state, ui-catch-up-banner, ui-reminder-row, ui-destructive-confirm, ui-numerals-calendar-text, eng-rtl-and-bidi-layout, eng-write-dart-test, domain-adab-and-religious-integrity
