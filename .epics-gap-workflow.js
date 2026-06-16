export const meta = {
  name: 'hifz-epics-gapfill',
  description: 'Fill only the missing E09/E10/E14 task files + write the epics README (E01–E14 scope)',
  phases: [
    { title: 'Tasks', detail: 'write only the 15 missing task files' },
    { title: 'Index', detail: 'epics/README.md build plan (E01–E14)' },
  ],
}

const BASE = '/Users/zakariafatahi/Projects/MobileApps/hifz'
const CHUNK = 5

const PRE = `You are filling in MISSING task files for the Hifz Companion BUILD PLAN, matching the CycleVault epics/tasks standard exactly.
The app: free (ṣadaqah), fully offline (assets downloaded once then airplane-mode forever), NO AI / no audio recognition, Flutter + pure-Dart engine + Drift/SQLite, RTL Persian (fa) / Kurdish-Sorani (ckb) / Arabic (ar). Non-negotiables (Quran text fidelity, sect-neutrality, no gamification of worship, servant-to-teacher, privacy/no-microphone, nothing "safe to drop") outrank every feature.
For the exact task-file FORMAT you MAY read one CycleVault example (/Users/zakariafatahi/Projects/MobileApps/CycleVault/epics/E06-app-shell-and-walking-skeleton/E06-T02-cyclestore-write-path.md). COPY THE FORMAT, NOT THE CONTENT — never carry over Swift/iOS, menstrual, security-decoy, or purchase content.`

// Per-epic context for the missing tasks.
const EPICS = {
  E09: { slug: 'localization-rtl-foundation',
    docs: 'docs/engineering/12-localization-rtl-accessibility-impl.md, docs/design-system/12-localization-and-rtl.md, docs/design-system/11-voice-and-tone.md',
    mission: 'fa/ckb/ar and RTL as structure: the gen_l10n ARB pipeline (Arabic base), locale-completeness CI gate, Directionality/logical insets, FSI/PDI bidi isolation, per-locale numerals, the calendar-display layer, and swappable sabaq/sabqi/manzil term-sets.',
    siblings: 'E09-T01 ARB pipeline (ar base) | E09-T02 localization-completeness CI gate | E09-T03 ckb locale + delegate | E09-T04 RTL logical layout + mirror policy | E09-T05 bidi FSI/PDI helper | E09-T06 locale numerals | E09-T07 ICU plural Arabic categories | E09-T08 calendar-display layer | E09-T09 term-sets + region override | E09-T10 per-locale RTL+numeral golden suite + CI' },
  E10: { slug: 'mihrab-component-library',
    docs: 'docs/design-system/07-components.md, 08-data-visualization.md, 09-accessibility-and-inclusivity.md, 03-color-and-themes.md',
    mission: 'The breadth of the Mihrab component library with full widget/golden preview matrices and design-09 accessibility anatomy — page card + track chip, heat-map cell, grade band, certainty label, pickers, banners, rows, destructive-confirm — off the skeleton critical path.',
    siblings: 'E10-T01 numerals/calendar/text primitive | E10-T02 preview/gallery harness + state model | E10-T03 page card + track chip + decay | E10-T04 heat-map cell | E10-T05 grade band + sign-off toggle | E10-T06 certainty label + legend | E10-T07 cycle-preset + settings pickers | E10-T08 catch-up banner + empty states | E10-T09 reminder row + destructive-confirm | E10-T10 library a11y + golden CI gate' },
  E14: { slug: 'mutashabihat-trainer',
    docs: 'docs/PRD.md §9, docs/science/05-interference-and-mutashabihat.md, docs/engineering/08-quran-data-and-immutable-rendering.md',
    mission: 'The mutashābihāt interference subsystem and trainer: the scholar-reviewed confusables dataset, the discrimination-drill UI (siblings back-to-back, diverging words highlighted as overlays), the swap-error confusion log feeding confusion_edge, the anchor hint, and the personal confusion-hotspots view.',
    siblings: 'E14-T01 dataset load | E14-T02 confusion_edge model + table | E14-T03 swap-logging write path | E14-T04 confusion-aware D bump | E14-T05 sibling massing (expandMutashabihat) | E14-T06 read models + providers | E14-T07 feature module + nav tab | E14-T08 discrimination-drill view | E14-T09 anchor-word overlay | E14-T10 confusion-hotspots view | E14-T11 fa/ckb/ar strings + adab | E14-T12 drill muṣḥaf golden + offline guard' },
}

const TASKS = [
  // E09
  { epic: 'E09', id: 'E09-T10', slug: 'rtl-numeral-golden-suite', size: 'M', deps: 'E09-T04, E09-T06, E09-T08, E09-T09', skills: 'eng-rtl-and-bidi-layout, eng-write-dart-test, eng-add-ci-check',
    title: 'Per-locale RTL + numeral golden suite on the real bundled fonts; wire the full gate into CI green',
    scope: 'The capstone of E09: a golden-test suite rendering the key localized surfaces in each of fa/ckb/ar (RTL, correct locale numerals, bundled Vazirmatn/Sorani UI font) and the CI wiring that makes the whole localization+RTL gate (key coverage, hardcoded-string grep, ASCII-digit grep, bidi-concat ban, adab banned-phrase lint) release-blocking green.' },
  // E10
  { epic: 'E10', id: 'E10-T01', slug: 'numerals-calendar-text-primitive', size: 'M', deps: 'E06', skills: 'ui-numerals-calendar-text, eng-rtl-and-bidi-layout, eng-write-dart-test',
    title: 'Numerals/calendar/text primitive: numberFormatFor + CalendarPresenter with locale-numeral and calendar goldens',
    scope: 'The shared leaf primitive every component uses to render a number or date: numberFormatFor(locale) (Extended Arabic-Indic ۰۱۲ for fa/ckb, Arabic-Indic ٠١٢ for ar) and a CalendarPresenter that renders E02 CalendarDate into the chosen calendar (Jalālī/Hijri/Gregorian) — with per-locale numeral and calendar goldens. No raw ASCII digits, no hardcoded Gregorian.' },
  { epic: 'E10', id: 'E10-T03', slug: 'page-card-track-chip-decay', size: 'L', deps: 'E10-T01, E10-T02', skills: 'ui-page-card, eng-rtl-and-bidi-layout',
    title: 'Page card + non-interactive track chip + decay indicator, six states, glyph-free, per-locale state goldens',
    scope: 'The page card component (page number + juz in locale numerals, the localized sabaq/sabqi/manzil track chip, and a calm decay indicator that is shape+glyph+label — never color alone), in its full state set, presentation-only (no Quran glyphs), with per-locale state goldens.' },
  { epic: 'E10', id: 'E10-T04', slug: 'heatmap-cell', size: 'L', deps: 'E10-T01, E10-T02', skills: 'ui-retention-heatmap, eng-write-dart-test',
    title: 'Heat-map cell: lightness ramp, VSUP uncertainty muting, redundant encoding, min-leaning roll-up badge',
    scope: 'The single retention heat-map cell: the calm single-hue green-receding-to-neutral lightness ramp (never red), VSUP-style uncertainty muting for thin data, redundant color+number+label encoding, and the min-leaning juz roll-up badge — the leaf the E15 whole-Quran grid composes.' },
  // E14 (all missing except T03)
  { epic: 'E14', id: 'E14-T01', slug: 'dataset-load', size: 'M', deps: 'E05, E03', skills: 'domain-mutashabihat-system, domain-mushaf-text-integrity, eng-write-dart-test',
    title: 'Load the bundled scholar-reviewed mutashābihāt dataset into the read-only reference tables, checksum-governed — test-first',
    scope: 'Load the scholar-reviewed confusables dataset (objective near-identical wording only) into read-only, checksum-governed reference tables (mutashabih_group, mutashabih_member with distinguishing_word_index_json), shipped in the asset pack; test-first with the integrity check.' },
  { epic: 'E14', id: 'E14-T02', slug: 'confusion-edge-model-and-table', size: 'M', deps: 'E03', skills: 'eng-add-persisted-model, eng-add-drift-table-or-migration',
    title: 'ConfusionEdge value type + confusion_edge Drift table/DAO with the migration',
    scope: 'The personal ConfusionEdge value type (model package) and the confusion_edge Drift table + DAO (data package) with its guided migration — per-profile, weighted, with last_confused_at as a CalendarDate serial day; no Drift symbol crosses the boundary.' },
  { epic: 'E14', id: 'E14-T04', slug: 'confusion-aware-bump', size: 'M', deps: 'E14-T01, E14-T03, E04', skills: 'domain-mutashabihat-system, domain-scheduling-engine-rules, eng-write-engine-golden-vector',
    title: 'Confusion-aware grading: a swap bumps D on every group member via the (11−D) channel — test-first',
    scope: 'In the pure engine, a swap (confusion) error bumps Difficulty on EVERY member of the confusable group (not just the recited page), via the (11−D) channel, raising their review frequency — pinned by golden vectors and an invariant property; deterministic, no I/O.' },
  { epic: 'E14', id: 'E14-T05', slug: 'sibling-massing', size: 'M', deps: 'E14-T01, E04', skills: 'domain-mutashabihat-system, domain-scheduling-engine-rules, eng-write-engine-golden-vector',
    title: 'Seed expandMutashabihat: due-member pulls siblings into the same session, never spaced — test-first',
    scope: 'The engine session-assembly hook expandMutashabihat: when any confusable-group member is due, pull ALL its siblings into the SAME session (massed contrast for discrimination), never spaced apart; test-first with a property asserting siblings co-occur.' },
  { epic: 'E14', id: 'E14-T06', slug: 'read-models-and-providers', size: 'M', deps: 'E14-T01, E14-T02', skills: 'eng-create-riverpod-store, eng-define-service-boundary',
    title: 'Group and confusion-hotspots read models + scoped Riverpod providers over Drift',
    scope: 'The reactive read models (confusable groups; personal confusion hotspots ranked by edge weight) as scoped Riverpod providers over Drift streams — read-only derivations, single-write-path respected, no DateTime.now() in shell.' },
  { epic: 'E14', id: 'E14-T07', slug: 'feature-module-and-nav', size: 'S', deps: 'E14-T06', skills: 'eng-add-feature-module, eng-rtl-and-bidi-layout',
    title: 'The mutashabihat feature module + RTL bottom-nav tab',
    scope: 'Scaffold the mutashabihat feature module (dumb View + 1:1 view-model + scoped providers) and wire its RTL bottom-nav tab (متشابهات) into the ShellRoute, downward-only deps.' },
  { epic: 'E14', id: 'E14-T08', slug: 'discrimination-drill-view', size: 'L', deps: 'E14-T07, E13, E05', skills: 'ui-mutashabihat-drill, ui-mushaf-page-view, domain-mushaf-text-integrity',
    title: 'DiscriminationDrillView: whole-group back-to-back, hidden → reveal-on-tap → anchor, composing the immutable page',
    scope: 'The discrimination-drill view: the WHOLE confusable group shown back-to-back (never one alone), hidden → reveal-on-tap → anchor, composing the E13/E05 immutable muṣḥaf page renderer (never re-typesetting), with the "which page?" disambiguation prompt.' },
  { epic: 'E14', id: 'E14-T09', slug: 'anchor-overlay', size: 'M', deps: 'E14-T08, E05', skills: 'ui-mushaf-page-view, domain-mushaf-text-integrity',
    title: 'Anchor-word highlight as a coordinate Rect overlay from distinguishing_word_index_json',
    scope: 'The anchor-word highlight: draw the distinguishing word(s) as a coordinate Rect overlay ON the immutable glyph layer, computed from distinguishing_word_index_json and the QUL word geometry — never by editing or re-typesetting the text.' },
  { epic: 'E14', id: 'E14-T10', slug: 'confusion-hotspots-view', size: 'M', deps: 'E14-T06, E14-T07', skills: 'ui-mutashabihat-drill, ui-page-card',
    title: 'ConfusionHotspotsView: calm "you keep swapping these two" rows from confusion_edge',
    scope: 'The personal confusion-hotspots view: calm, non-shaming "you keep swapping these two" rows from the confusion_edge graph, each linking to a drill — informative, never a scoreboard.' },
  { epic: 'E14', id: 'E14-T11', slug: 'localized-strings-and-adab', size: 'S', deps: 'E14-T07, E14-T08, E14-T10', skills: 'eng-add-localized-string, domain-adab-and-religious-integrity',
    title: 'fa/ckb/ar trainer strings via gen_l10n + adab conscience-check pass',
    scope: 'All trainer strings via gen_l10n ARB for fa/ckb/ar (Arabic base), plus the adab conscience-check pass (reverent, sect-neutral, no gamification, no fiqh ruling; mutashābihāt framed as objective wording only).' },
  { epic: 'E14', id: 'E14-T12', slug: 'drill-golden-and-offline-guard', size: 'M', deps: 'E14-T08, E14-T09, E14-T11', skills: 'eng-write-dart-test, domain-mushaf-text-integrity',
    title: 'Drill muṣḥaf golden (whole-group, reveal→anchor, RTL × fa/ckb/ar) + offline guard',
    scope: 'The release-blocking goldens for the drill: the whole-group reveal→anchor states rendered on the real bundled glyph fonts, RTL × fa/ckb/ar, plus the HttpOverrides offline guard proving no network during the trainer.' },
]

const taskPrompt = (t) => {
  const e = EPICS[t.epic]
  return PRE + `

TASK: Write ${BASE}/epics/${t.epic}-${e.slug}/${t.id}-${t.slug}.md — one PR-sized task file.
Task title: ${t.title}
Size: ${t.size} · Depends on: ${t.deps} · Skills: ${t.skills}
Task scope: ${t.scope}
Epic mission (context): ${e.mission}
Governing docs for this epic: ${e.docs}
Sibling tasks in this epic (for cross-linking & dependency realism): ${e.siblings}

Read FIRST (use the Read tool): the epic's EPIC.md at ${BASE}/epics/${t.epic}-${e.slug}/EPIC.md, the cited skills' SKILL.md in ${BASE}/.claude/skills/, and the precise governing doc sections. Then write the task file following the CycleVault task anatomy EXACTLY:
- H1: "# ${t.id} — ${t.title}"
- a metadata table with rows: Epic (link to EPIC.md), Size, Depends on, Skills.
- "## Goal" (1 short paragraph: the concrete end state).
- "## Context & references" (a table: Reference | What to take from it — the exact doc sections, the skills + their template, the CLAIMS ids if any user-facing number/copy is involved, and sibling tasks).
- "## Implementation notes" (numbered; concrete Dart/Flutter specifics — file paths in the right package, types, Riverpod/Drift/engine specifics; TEST-FIRST note for correctness-critical work; pitfalls).
- "## Acceptance criteria" (checkbox list, specific and verifiable).
- "## Tests" (exact test files + cases — unit/widget/golden/integration; engine golden vectors where relevant; offline/no-network guards).
- "## Definition of Done" (checkbox list incl. the relevant non-negotiables: offline/no-network, no-AI/no-microphone, Quran text fidelity, RTL + fa/ckb/ar strings, accessibility, sect-neutral adab, deterministic tests).
Implementation-grade and traceable. Use the Write tool, then return JSON {id:'${t.id}'}.`
}

async function chunked(items, fn, size) {
  const out = []
  for (let i = 0; i < items.length; i += size) {
    const res = await parallel(items.slice(i, i + size).map((it, j) => () => fn(it, i + j)))
    out.push(...res)
  }
  return out
}

phase('Tasks')
const results = await chunked(TASKS, (t) =>
  agent(taskPrompt(t), { label: `task:${t.id}`, phase: 'Tasks', agentType: 'general-purpose', schema: { type: 'object', properties: { id: { type: 'string' } } } }), CHUNK)
const ok = results.filter(Boolean)
log(`gap task files written: ${ok.length}/${TASKS.length}`)

phase('Index')
// Index data for E01–E14 (task counts after the gap fill).
const INDEX = [
  ['E01', 'Repo Scaffold & CI Guardrails', 'foundation', '—', 8],
  ['E02', 'CalendarDate & Date Correctness Core', 'foundation', 'E01', 10],
  ['E03', 'Domain Models & Drift Persistence', 'foundation', 'E01, E02', 10],
  ['E04', 'Scheduling Engine (FSRS-style DSR core)', 'foundation', 'E02, E03', 11],
  ['E05', 'Quran Data, Asset Packs & Immutable Rendering', 'foundation', 'E01, E03', 11],
  ['E06', 'Mihrab Foundation — Tokens, Themes & Skeleton Kit', 'foundation', 'E01', 11],
  ['E07', 'App Shell & Walking Skeleton', 'skeleton', 'E02, E03, E04, E05, E06', 10],
  ['E08', 'Accessibility Foundation', 'crosscutting', 'E01, E06, E07', 10],
  ['E09', 'Localization & RTL Foundation', 'crosscutting', 'E01, E06, E07', 10],
  ['E10', 'Mihrab Component Library', 'foundation', 'E06', 10],
  ['E11', 'Onboarding & Cold-Start', 'feature', 'E07, E08, E09, E10, E05', 10],
  ['E12', 'Today & Recite-Grade Loop', 'feature', 'E07, E08, E09, E10, E04', 9],
  ['E13', 'Muṣḥaf Reader', 'feature', 'E05, E07, E10', 10],
  ['E14', 'Mutashābihāt Trainer', 'feature', 'E04, E05, E13', 12],
]
const indexRows = INDEX.map(r => `${r[0]} | ${r[1]} | ${r[2]} | ${r[3]} | ${r[4]}`).join('\n')
const readmePrompt = PRE + `

TASK: Write ${BASE}/epics/README.md — the Hifz Companion build plan, matching the CycleVault epics/README.md (you MAY read /Users/zakariafatahi/Projects/MobileApps/CycleVault/epics/README.md for format). The plan currently covers E01–E14 with full task files; epics E15–E20 are DRAFTED (their EPIC.md exist on disk: E15-progress-and-heatmap, E16-settings-profiles-teacher, E17-backup-and-restore, E18-reminders, E19-science-screen-and-claims, E20-release-readiness) but their per-task files are DEFERRED — list them in the index table with a "tasks: deferred" note so the plan is honest.
Include: an intro (one directory per epic E##-<slug>/ with EPIC.md + E##-T##-<slug>.md task files; assembly sequence for ONE complete free/offline release, not phased); the "## Epic index" table (columns ID | Epic | Category | Depends on | Tasks | Mission) linking each ID to its EPIC.md, reading each EPIC.md for its mission; a "## Dependency graph — build waves" ASCII diagram; a "## Locked scope decisions" section (free/ṣadaqah — no monetization ever; fully offline, assets downloaded once; NO AI / no audio; languages fa/ckb/ar all RTL, Kurmanji dropped; sect-neutral, no bundled tafsīr); a "## Traceability convention"; and a "## Definition of Done — non-negotiable across all epics" (offline/no-network provable, no-AI/no-microphone, Quran text fidelity via checksum+glyph fonts, nothing "safe to drop", RTL+fa/ckb/ar localization is DoD, accessibility is DoD, sect-neutral adab, tests not optional, claims sourced).
Epics E01–E14 (id | title | category | depends | #tasks):
${indexRows}
Plus the deferred E15–E20 (read their EPIC.md H1 + mission for the index rows; mark Tasks = "deferred").

Use the Write tool, then return JSON {written:true}.`
await agent(readmePrompt, { label: 'epics-README', phase: 'Index', agentType: 'general-purpose', schema: { type: 'object', properties: { written: { type: 'boolean' } } } })

return { gapTasksWritten: ok.length, total: TASKS.length, ids: ok.map(r => r.id) }
