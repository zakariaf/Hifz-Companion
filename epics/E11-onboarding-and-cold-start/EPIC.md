# E11 — Onboarding & Cold-Start

The first-run promise and the make-or-break placement: the welcome + privacy framing, language pick, riwāyah confirmation, the one-time core-pack download, juz coverage capture, per-juz Solid/Shaky/Rusty confidence with optional "when memorized," and the named cycle preset + daily budget. Together these turn "I am a ḥāfiẓ" into a seeded, conservative schedule without grading 604 pages on day one — seeding the engine through `coldStartCard` and committing it through the single write path, then handing off to a first generated day. It is genuinely make-or-break: a bad first impression here loses the user before the engine ever proves itself, and a half-seeded write on a mid-flow kill would breach the central covenant.

## Why this epic exists

A finished ḥāfiẓ carries 600+ pages that decay **invisibly** ([PRD §2](../../docs/PRD.md)), and the whole product exists to stop that silent loss — but the engine can only protect pages it knows the user holds. There is no review history on day one and nobody can grade 604 pages at once, so the entire schedule depends on a single honest self-assessment captured here ([PRD §7.10](../../docs/PRD.md), §12.1). The design's answer is **seed conservative priors and converge on real grades, no calibration grind**: coverage capture marks which juz are held (un-held stays `UNMEMORIZED`), a per-juz Solid/Shaky/Rusty pick seeds `(D, S)` through the engine's `coldStartCard` table, and an optional "when memorized" date ages a juz finished years ago back into reactivation ([PRD §7.10](../../docs/PRD.md) steps 1–5; [engineering 06 §5](../../docs/engineering/06-scheduling-engine.md)). The priors deliberately **under-estimate** strength so the first real recitation can only pleasantly surprise upward — better to over-review early than to skip a page the user has actually lost (the cost-asymmetry license, [CLAIMS C-009](../../docs/science/CLAIMS.md)).

This epic is also where three non-negotiables become real for the first time on a screen. The one-time core-pack download is **the only moment the app extends trust to the network** ([PRD C1, §11.1.1](../../docs/PRD.md)): it fetches a pinned, public asset pack, re-hashes every file SHA-256 fail-closed, and **refuses to render Quran text** from any unverified byte — text fidelity (R1) held by structure, not hope. The welcome states the privacy covenant plainly — no account, no microphone, no data leaves the device, airplane-mode-forever after this one download ([PRD R5, §17](../../docs/PRD.md); [CLAIMS C-048](../../docs/science/CLAIMS.md)) — and the cycle-preset pick is a **named tradition a teacher recognizes**, never a retention slider ([PRD §15.1](../../docs/PRD.md); [design-principles §3](../../docs/design-system/01-design-principles.md)). The whole flow is the user's own honest report, kept on this phone, that a future teacher can correct — so it never grades, never shames an un-held juz, and never speaks *for* the Quran ([voice-and-tone §3–§5](../../docs/design-system/11-voice-and-tone.md); [PRD R3, R6](../../docs/PRD.md)). E07's walking skeleton already proved a *minimal* seed path through the spine; this epic builds the full, honest, sub-20-minute flow that wraps it.

## Scope

### In scope

- **Onboarding feature module** under `packages/features/lib/src/onboarding/` (dumb View ↔ 1:1 ViewModel, scoped providers), reached via the `/onboarding` `GoRoute` behind E07's redirect guard, with a finite, capped, calm step sequence and a back/resume-safe controller holding the captured state.
- **Welcome + privacy framing** — intent (built free, *ṣadaqah*), and the perceptible privacy covenant: no account, **no microphone / never records audio**, no data leaves the device, one-time download then airplane-mode-forever ([CLAIMS C-048](../../docs/science/CLAIMS.md)); servant-to-the-teacher framing ([CLAIMS C-046](../../docs/science/CLAIMS.md)).
- **Language pick** (fa / ckb / ar, all RTL) as a single-select picker, applied as a live display transform.
- **Riwāyah / muṣḥaf confirmation** — names the bundled edition explicitly ("Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"), never "the Quran" in the absolute (R2); stores the named choice only.
- **One-time core-pack download step** — the calm `awaitingFirstDownload` / `downloadInterrupted` / `ready` states over E05's `installCorePack` (download → verify → promote → build reference DB → stamp), with progress, offline-at-first-run retry, and the fail-closed refuse-to-render guard; the airplane-mode-after proof surfaced.
- **Coverage capture** — a fast juz-level tap grid in muṣḥaf order (juz 1 at start/right in RTL); un-held juz stay `UNMEMORIZED`, drawn calm and un-emphasized, never alarm-red / "missing" / "0%".
- **Per-juz confidence** — Solid / Shaky / Rusty single mutually-exclusive pick per held juz, worded as honest self-report; the choice is passed to the engine's `coldStartCard` (which owns the seed table) — the UI never invents `(D, S)`.
- **Optional "when memorized"** — a genuinely skippable per-juz `CalendarDate` (or coarse band) rendered in the user's calendar/numerals, fed to `coldStartCard`'s stale-time decay branch.
- **Named cycle-preset pick + daily budget** — 7-Manzil weekly khatm · 1 juz/day · ½ juz/day · 2 juz/day · Custom, plus the daily time budget; writes `EngineConfig` (`farCycleDays`/`dailyBudget`/…), never a `target_R` dial.
- **Placement commit + first-day handoff** — one repository method that calls `coldStartCard` per held page and persists the seeded cards + `cycle_config` **transactionally before** republishing and before "Done → first day generated" (E03's `seedColdStart` outer transaction); a mid-flow kill leaves no half-seeded state.
- Onboarding strings (ar template + fa/ckb transcreated) and a `Semantics`-labelled, redundantly-encoded, RTL-native treatment of every control; widget + per-locale goldens.

### Out of scope

- The cold-start **seeding math** — `coldStartCard`, the `_coldStartSeed` `(D, S)` table, stale-time `R`-decay, the calibration-pass invariant → **E04 scheduling-engine** (this flow *calls* the seeder, never re-derives it).
- The **download/verify/promote mechanics** themselves — `PackDownloader`, the chunked SHA-256 verifier, the pinned manifest, `installCorePack` → **E05 quran-data-and-rendering** (this epic embeds the step and renders its calm states).
- The **persisted `Card`/`cycle_config` schema and `seedColdStart` transaction body** → **E03 models-and-persistence** (this epic calls the single write path).
- The **reusable widgets** (cycle-preset picker, settings/single-select picker, welcoming first-run empty state) → **E10 mihrab-component-library** (this epic composes them).
- The **app shell, `/onboarding` route, and redirect guard** → **E07 app-shell-walking-skeleton** (this epic fills the route the guard points to).
- The Today screen, recite/grade flow, and catch-up banner the first generated day lands in → **E12 today-and-recite-grade**.
- The in-reader "mark my memorized range" tool that also feeds coverage later → **E13 mushaf-reader**.
- The ARB pipeline, RTL/numeral helpers, and term-set machinery → **E09 localization-rtl-foundation** (this epic adds its keys through that pipeline).
- The standalone Settings muṣḥaf/calendar/numeral/theme pickers and profile management → **E16 settings-profiles-teacher**.

## Dependencies

### Depends on

- **E07 app-shell-walking-skeleton** — the Riverpod `ProviderScope` composition root, the `go_router` `ShellRoute`/`/onboarding` `GoRoute` and the **redirect guard** that routes an un-ready device here before any Quran screen renders, the injected `CalendarDate` clock, and the minimal seed path this epic's full flow supersedes.
- **E08 accessibility-foundation** — the semantics conventions, text-scale path, screen-reader traversal order, and the per-screen accessibility audit gate the placement controls must pass; the recorded cold-start manual TalkBack/VoiceOver checklist runs over this flow.
- **E09 localization-rtl-foundation** — the `gen_l10n` ARB pipeline (ar template + fa/ckb), the locale-numeral / `CalendarDate` / bidi-isolation helpers, the swappable term-sets, and the completeness + RTL-golden gate every onboarding string ships through.
- **E10 mihrab-component-library** — the cycle-preset picker, the single-select Settings picker, and the welcoming first-run empty state this flow composes, plus the calm tokens/appearances they render against.
- **E05 quran-data-and-rendering** — the sequenced `installCorePack` (download → verify → promote → build reference DB → stamp `text_checksum_verified_at`) and the calm `awaitingFirstDownload` / `downloadInterrupted` / `ready` states this epic embeds as the download step.

### Enables

E12 today-and-recite-grade (the first generated day this flow seeds is what Today renders); E15 progress-and-heatmap (the seeded coverage is the first heat-map state); E16 settings-profiles-teacher (re-running placement / changing the cycle preset reuses these controls); E20 release-readiness (the cold-start → first day → review → catch-up journey and the recorded manual a11y pass run through this flow).

## Foundation inputs

| Input | Where (doc/skill) | What this epic takes |
|---|---|---|
| Onboarding/cold-start spec | docs/PRD.md §7.10 (steps 1–5), §12.1 | The exact five-step cold start (coverage → confidence → optional date → cycle/budget → done) and the §12.1 screen list (welcome+privacy, language, riwāyah confirm, download, coverage, confidence, cycle preset + budget, first day) |
| Placement flow pattern | .claude/skills/ui-cold-start-placement | Three finite passes, fast juz-level taps in muṣḥaf order, Solid/Shaky/Rusty self-report, "never invent `(D, S)`", optional `CalendarDate` date, persist-before-first-day, no readiness % / streak / shame |
| Cycle-preset control | .claude/skills/ui-cycle-preset-picker | Named single-select presets (no slider, no `target_R`), the preset → `EngineConfig` (`farCycleDays`/`dailyBudget`) mapping, Pure-cycle framed as fidelity, Custom as four bounded fields |
| Download integrity | .claude/skills/domain-asset-pack-integrity; docs/PRD.md §11.1, §11.1.1 | The one-time pinned HTTPS GET, fail-closed SHA-256 refuse-to-render contract, and the calm non-blaming `awaitingFirstDownload`/`downloadInterrupted`/`ready` onboarding states (mechanics owned by E05) |
| Language / riwāyah / calendar pickers | .claude/skills/ui-settings-picker | The single-select "display transform, never mutate the engine" pattern for language pick and riwāyah confirmation; the muṣḥaf named, never absolute (R2) |
| Cold-start seeding | docs/engineering/06-scheduling-engine.md §5; docs/PRD.md §7.10 | The `coldStartCard(pageId, JuzConfidence, today, {memorizedOn})` signature, the `_coldStartSeed` table (Solid D3/S60/FAR · Shaky D5/S14/NEAR · Rusty D7/S4/active), and the calibration "every held page due now" rule the flow calls |
| Single write path | docs/engineering/05-persistence-and-encryption.md §3; eng-create-riverpod-store; eng-add-feature-module | The `seedColdStart(...)` outer transaction (600+ cards + profile + `cycle_config`, all-or-nothing, persist-before-republish) the placement commit routes through; the feature-module View-never-writes rule |
| Voice & adab | docs/design-system/11-voice-and-tone.md §1–§5; .claude/skills/domain-adab-and-religious-integrity | The privacy/servant copy, the never-shame-an-un-held-juz framing, no readiness verdict, no "Welcome back!", riwāyah named — every string passes the adab gate |
| Calm-not-cute principles | docs/design-system/01-design-principles.md §1–§5 | Reverence first (riwāyah named, no chrome on the muṣḥaf), calm-not-cute (no streak/badge/confetti on a filled grid), tradition-as-interface (named cycle), private-by-feel (airplane-mode proof) |
| User-facing claims | docs/science/CLAIMS.md C-048, C-046, C-009, C-016, C-007 | The privacy/offline line (C-048), the servant-to-teacher line (C-046), the conservative-cold-start license (C-009), and the cycle-guarantee / interval-grows lines behind the preset copy (C-016, C-007) |
| RTL / numerals / dates | docs/design-system/12-localization-and-rtl.md; eng-rtl-and-bidi-layout; domain-calendars-and-hifzdate | Logical start/end geometry, locale numerals on juz numbers and budget minutes, FSI/PDI isolation of mixed runs, and the `CalendarDate` "when memorized" input in the user's calendar |
| Tests | .claude/skills/eng-write-dart-test | Widget + per-locale goldens on real bundled fonts, the seed→store→first-day commit test, the persist-before-republish proof, and the `HttpOverrides` offline guard on every step after download |

## Deliverables

- [ ] The `packages/features/lib/src/onboarding/` module (dumb `onboarding_screen.dart` View, 1:1 `onboarding_view_model.dart`, `widgets/`, scoped `onboarding_providers.dart`) wired to the `/onboarding` `GoRoute` behind E07's redirect guard, with a back/resume-safe controller holding `(locale, mushaf choice, download state, coverage set, JuzConfidence map, memorizedOn map, cycle preset, daily budget)`.
- [ ] The **welcome + privacy** step stating the offline / no-account / **no-microphone** / one-time-download covenant ([CLAIMS C-048](../../docs/science/CLAIMS.md)) and the servant-to-the-teacher framing ([CLAIMS C-046](../../docs/science/CLAIMS.md)), calm and exclamation-free.
- [ ] The **language pick** (fa/ckb/ar) single-select, applied as a live display transform, and the **riwāyah/muṣḥaf confirmation** that names the edition explicitly and stores only the named choice (R2).
- [ ] The **core-pack download step** rendering E05's `installCorePack` as calm `awaitingFirstDownload` / `downloadInterrupted` / `ready` states with progress, offline-at-first-run Retry, the fail-closed refuse-to-render guard, and the airplane-mode-after proof.
- [ ] The **coverage-capture** juz tap grid (muṣḥaf order, RTL, locale-numeral + selected-glyph cells, un-held = calm `UNMEMORIZED`).
- [ ] The **per-juz Solid/Shaky/Rusty** rater (single mutually-exclusive pick, transcreated self-report words) that passes `JuzConfidence` to `coldStartCard` and never shows a seeded `D`/`S`/`R` or a readiness %.
- [ ] The **optional "when memorized"** skippable `CalendarDate` input per juz, rendered in the user's calendar/numerals, fed to `coldStartCard`'s `memorizedOn` branch.
- [ ] The **named cycle-preset pick + daily budget** (composing E10's preset picker) that writes `EngineConfig` only.
- [ ] The **placement commit**: one repository method calling `coldStartCard` per held page and committing the seeded cards + `cycle_config` through E03's `seedColdStart` outer transaction **before** republishing and before the first generated day; a calm informational summary, not a celebration.
- [ ] Onboarding ARB keys (ar template + fa/ckb transcreated, term-sets review-pending) and every control `Semantics`-labelled, redundantly encoded, RTL-native.
- [ ] Widget + per-locale (fa/ckb/ar) golden tests on real bundled fonts, the offline `HttpOverrides` guard on every post-download step, and the seed→store→first-day integration commit test; CI green across the offline / l10n / a11y gates.

## Definition of Done

- [ ] The flow runs the full §12.1 sequence — welcome+privacy → language → riwāyah confirm → one-time download → coverage → per-juz confidence → optional "when memorized" → cycle preset + budget → done — finite, capped, calm, and **sub-20-minute with no per-page grading and no calibration grind**.
- [ ] **Offline / no-network (non-negotiable):** the only socket touched is E05's pinned one-time download; every step after `ready` runs in airplane mode; an `HttpOverrides`-throwing test proves the radio stays off post-download; no analytics/telemetry/second network client anywhere.
- [ ] **No AI / no audio (non-negotiable):** the flow captures self-report only; no microphone, no ASR, no model, no inference — and the welcome states this covenant ([CLAIMS C-048](../../docs/science/CLAIMS.md)).
- [ ] **Text fidelity (non-negotiable):** the download step is fail-closed — a mismatched/missing/truncated pack re-fetches once then **refuses to render Quran text**; no coverage/confidence step renders any muṣḥaf glyph before `text_checksum_verified_at` is stamped; the riwāyah is named explicitly, never "the Quran" absolutely (R1, R2).
- [ ] **Conservative seeding holds:** every held page is seeded via `coldStartCard` with the under-estimating priors and `dueAt = today`; the UI **never** invents `(D, S)`, shows a seeded `D`/`S`/`R`, or shows a "you're N% ready" verdict ([CLAIMS C-009](../../docs/science/CLAIMS.md); [engineering 06 §5](../../docs/engineering/06-scheduling-engine.md)).
- [ ] **Single write path:** the seeded cards + `cycle_config` commit through one `seedColdStart` transaction **before** republishing and before the first day; the View writes no rows; a kill mid-onboarding leaves no half-seeded state (a test proves a failed commit republishes nothing).
- [ ] **Named cycle, never a slider:** the preset pick writes only `EngineConfig`; no `target_R` dial, no FSRS number, no "recommended for you" appears.
- [ ] **Adab / no shame:** no streak, badge, confetti, or completion-% trophy; an un-held juz is calm `UNMEMORIZED`, never alarm-red / "missing" / "0%"; the flow ends on a calm informational summary; no string speaks *for* the Quran or overrides a future teacher — every string passes the adab gate.
- [ ] **RTL + fa/ckb/ar localization:** every string ships ar (template) + fa + ckb transcreated through `gen_l10n` (no hardcoded text); juz numbers and budget minutes render in the locale numeral set; mixed runs FSI/PDI-isolated; the grid and rows read start→end (right→left); the l10n completeness + RTL-golden gate is green.
- [ ] **Accessibility:** each cell/option is `Semantics`-labelled with its state ("Juz ۱۳, held" / "Shaky — needs regular revision"), grouped/toggle-flagged, with a visible focus ring; hit targets ≥48dp; redundant color+shape+label; readable in grayscale/deuteranope; the per-screen audit gate passes and the recorded cold-start manual TalkBack/VoiceOver checklist covers it.
- [ ] **Tests:** widget tests per step, per-locale goldens on real bundled fonts (never `Ahem`), the seed→store→first-day commit test, the skip-date path, the fail-closed download states, and the offline guard — all green in CI.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E11-T01 | [Onboarding feature module + /onboarding route, step controller, and resume-safe captured state](E11-T01-onboarding-module-and-controller.md) | M | E07, E08, E09 |
| E11-T02 | [Welcome + privacy framing step (offline/no-mic/servant copy, C-048/C-046)](E11-T02-welcome-privacy-step.md) | S | E11-T01 |
| E11-T03 | [Language pick + riwāyah/muṣḥaf confirmation single-select (display transform, edition named)](E11-T03-language-and-riwayah-step.md) | S | E11-T01, E10 |
| E11-T04 | [Core-pack download step: calm awaitingFirstDownload/downloadInterrupted/ready states over installCorePack, fail-closed](E11-T04-core-pack-download-step.md) | M | E11-T01, E05 |
| E11-T05 | [Coverage-capture juz tap grid (muṣḥaf order, RTL, un-held = calm UNMEMORIZED)](E11-T05-coverage-capture-grid.md) | M | E11-T01, E09 |
| E11-T06 | [Per-juz Solid/Shaky/Rusty confidence rater (self-report words, passes JuzConfidence, no D/S/R surfaced)](E11-T06-per-juz-confidence-rater.md) | M | E11-T05 |
| E11-T07 | [Optional "when memorized" skippable CalendarDate input per juz (locale calendar, memorizedOn branch)](E11-T07-when-memorized-input.md) | S | E11-T06 |
| E11-T08 | [Named cycle-preset pick + daily budget composing the preset picker (writes EngineConfig only)](E11-T08-cycle-preset-and-budget-step.md) | M | E11-T01, E10 |
| E11-T09 | [Placement commit: coldStartCard per held page → seedColdStart transaction → first-day handoff (test-first)](E11-T09-placement-commit-and-first-day.md) | M | E11-T06, E11-T07, E11-T08, E03, E04 |
| E11-T10 | [Onboarding strings (ar/fa/ckb) + Semantics/RTL pass + per-locale goldens and offline guard](E11-T10-strings-a11y-rtl-goldens.md) | M | E11-T02, E11-T03, E11-T04, E11-T05, E11-T06, E11-T07, E11-T08, E11-T09 |

## Risks

- **Placement drifts into a calibration grind.** "While I'm here" additions (per-page grading, a readiness quiz) turn the make-or-break step into the thing that loses the user. *Mitigation:* exactly three capture passes (coverage → confidence → optional date) plus the named cycle/budget; anything that asks the user to grade or open 604 pages is rejected in review per [ui-cold-start-placement](../../.claude/skills/ui-cold-start-placement/SKILL.md).
- **The UI fakes precision the engine refuses.** A seeded `D`/`S`/`R` or a "you're 87% ready" score leaks the internal numbers and contradicts the conservative-bias covenant. *Mitigation:* the UI passes `JuzConfidence` and never reads back seeds; a test asserts no D/S/R/percentage string renders; the conservative bias shows only as behavior ("we'll revise everything once, then adjust") ([CLAIMS C-009](../../docs/science/CLAIMS.md)).
- **A mid-onboarding kill leaves a half-seeded profile.** Seeding 600+ cards is the largest single write in the app. *Mitigation:* one `seedColdStart` outer transaction, persist-before-republish; the first day fires only after the durable commit; a failed-commit test proves nothing republished ([engineering 05 §3](../../docs/engineering/05-persistence-and-encryption.md)).
- **Download failure or offline-at-first-run reads as the user's fault.** The one network moment is where blame copy creeps in. *Mitigation:* calm non-blaming `awaitingFirstDownload`/`downloadInterrupted` states with Retry, no exclamation marks; fail-closed refuse-to-render is honest, not punitive ([domain-asset-pack-integrity](../../.claude/skills/domain-asset-pack-integrity/SKILL.md); [voice-and-tone §4](../../docs/design-system/11-voice-and-tone.md)).
- **An un-held juz gets shamed.** A red "missing"/"0%" tile weaponizes the exact spiritual fear R3 forbids. *Mitigation:* un-held juz are calm un-emphasized `UNMEMORIZED` cells with a number+selected-glyph encoding; no completion %, no alarm red; copy passes the adab gate ([domain-adab-and-religious-integrity](../../.claude/skills/domain-adab-and-religious-integrity/SKILL.md)).
- **The cycle pick becomes a retention dial.** A `target_R` slider would break tradition-as-interface. *Mitigation:* named single-select presets writing only `EngineConfig`; Custom is four bounded fields; Pure-cycle is one flag framed as fidelity ([ui-cycle-preset-picker](../../.claude/skills/ui-cycle-preset-picker/SKILL.md); [PRD §15.1](../../docs/PRD.md)).
- **The riwāyah confirmation drifts toward "the Quran."** Calling the muṣḥaf absolute breaches neutrality (R2). *Mitigation:* the confirmation always names "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"; the picker stores the named edition only and re-typesets nothing ([ui-settings-picker](../../.claude/skills/ui-settings-picker/SKILL.md)).
- **ckb's longer terms truncate or the term-set is treated as final.** Sorani vocabulary awaits native + scholarly review. *Mitigation:* term-sets are swappable ARB strings marked provisional; ckb wraps rather than truncates; per-locale goldens catch overflow ([PRD §13.4, §21](../../docs/PRD.md)).

## References

- docs/PRD.md — §7.10 (cold start steps 1–5), §12.1 (onboarding screen sequence), §11.1 / §11.1.1 (asset packs + download integrity), §15.1 (named cycle presets), §13.3–§13.4 (numerals/calendars/term-sets), R1/R2/R3/R5/R6, C1/C2/C6, §17
- docs/engineering/06-scheduling-engine.md — §5 (`coldStartCard`, `_coldStartSeed` table, stale-time decay, calibration pass)
- docs/engineering/05-persistence-and-encryption.md — §3 (`seedColdStart` outer transaction, persist-before-republish, WAL + `synchronous=FULL`)
- docs/engineering/09-asset-packs-and-offline-integrity.md — §1–§3 (pinned pack, fail-closed verify, onboarding download states)
- docs/engineering/04-flutter-and-state-patterns.md — §1.1, §4 (single write path; View never writes)
- docs/design-system/11-voice-and-tone.md — §1 (adab), §2 (four voice attributes), §3 (tone matrix), §4 (empathy-then-path), §5 (authority boundary)
- docs/design-system/01-design-principles.md — §1 (reverence), §2 (calm not cute), §3 (tradition is the interface), §4 (honest about decay), §5 (private by feel)
- docs/design-system/12-localization-and-rtl.md — §1 (RTL geometry), §3 (FSI/PDI isolation), §4 (locale numerals), §5 (display-transform calendars), §6 (term-sets), §8 (the muṣḥaf is never localized)
- docs/science/CLAIMS.md — C-048 (offline/no-mic privacy), C-046 (servant to the teacher, no fatwa), C-009 (conservative cold-start), C-016 (cycle guarantee), C-007 (interval grows with strength)
- .claude/skills/ — ui-cold-start-placement, ui-cycle-preset-picker, domain-asset-pack-integrity, ui-settings-picker, eng-add-feature-module, eng-create-riverpod-store, eng-add-persisted-model, domain-scheduling-engine-rules, domain-calendars-and-hifzdate, eng-rtl-and-bidi-layout, eng-add-localized-string, domain-adab-and-religious-integrity, eng-write-dart-test
