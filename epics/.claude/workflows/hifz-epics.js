export const meta = {
  name: 'hifz-epics',
  description: 'Generate the Hifz app build plan: 20 epics (EPIC.md) + one task file per task + the epics README, matching the CycleVault standard',
  phases: [
    { title: 'Epics', detail: 'one agent per epic writes EPIC.md and returns its task breakdown' },
    { title: 'Tasks', detail: 'one agent per task writes E##-T##-slug.md' },
    { title: 'Index', detail: 'epics/README.md build plan' },
  ],
}

const BASE = '/Users/zakariafatahi/Projects/MobileApps/hifz'
const CHUNK = 5

const TASK_LIST_SCHEMA = {
  type: 'object',
  properties: {
    epicId: { type: 'string' },
    title: { type: 'string' },
    category: { type: 'string' },
    mission: { type: 'string' },
    tasks: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },        // e.g. E04-T03
          slug: { type: 'string' },      // e.g. trust-clamp
          title: { type: 'string' },     // the long task title
          size: { type: 'string' },      // S | M | L
          dependsOn: { type: 'string' }, // e.g. "E04-T01, E04-T02"
          skills: { type: 'string' },    // comma-separated skill names
          scope: { type: 'string' },     // 1-2 sentence scope for the task agent
        },
        required: ['id', 'slug', 'title', 'scope'],
      },
    },
  },
  required: ['epicId', 'tasks'],
}

// 20 epics in build order. Each EPIC agent reads the cited docs/skills and writes EPIC.md,
// then returns a 6–12 task PR-sized breakdown.
const EPICS = [
  { id: 'E01', slug: 'repo-scaffold-and-ci', cat: 'foundation', deps: '—',
    docs: 'docs/engineering/01-architecture-overview.md, 02-project-structure.md, 03-coding-standards.md, 11-testing-strategy.md, 13-oss-repo-and-release.md',
    skills: 'eng-create-package, eng-write-to-coding-standards, eng-add-ci-check, eng-write-dart-test',
    mission: 'The public, free/OSS Flutter pub-workspace: the app target plus the local package stubs (engine, data, quran, assets, models, l10n, profiles, features), analyzer/lints, and the CI pipeline whose gates — no-network/banned-import, SHA-256 text & asset integrity, engine golden vectors, RTL/muṣḥaf goldens, coverage — make every later guarantee machine-checkable from the first commit.' },
  { id: 'E02', slug: 'calendar-and-date-core', cat: 'foundation', deps: 'E01',
    docs: 'docs/engineering/07-dates-calendars-and-correctness.md',
    skills: 'domain-calendars-and-hifzdate, eng-rtl-and-bidi-layout, eng-write-dart-test',
    mission: 'The CalendarDate value type (integer serial-day math, never DateTime instants) and the single date boundary that make timezone/DST scheduling drift impossible; Hijri (Umm al-Qurā) / Solar-Hijri Jalālī / Gregorian conversion and display-only presentation, the injected "today", locale numerals on dates, with the multi-decade sweep and hostile-timezone test matrices.' },
  { id: 'E03', slug: 'models-and-persistence', cat: 'foundation', deps: 'E01, E02',
    docs: 'docs/engineering/05-persistence-and-encryption.md, 01-architecture-overview.md',
    skills: 'eng-add-persisted-model, eng-add-drift-table-or-migration, eng-define-service-boundary, eng-write-dart-test',
    mission: 'The domain value models plus the Drift/SQLite (optionally encrypted) store: card, append-only review_log, profile, confusion_edge, cycle_config, line_block, app_meta; guided migrations, WAL + synchronous=FULL crash-safety, the persist-before-republish single write path, and reference tables governed by checksum.' },
  { id: 'E04', slug: 'scheduling-engine', cat: 'foundation', deps: 'E02, E03',
    docs: 'docs/engineering/06-scheduling-engine.md, docs/PRD.md §7, docs/science/03-spaced-repetition-algorithms.md, 06-overlearning-and-lifelong-retention.md',
    skills: 'domain-scheduling-engine-rules, eng-write-engine-golden-vector, domain-grading-pipeline, eng-create-package',
    mission: 'THE CORE: the pure-Dart, deterministic FSRS-style DSR engine — page card with D/S/R, the three sabaq/sabqi/manzil lifecycle tracks, phase graduation, stakes-tiered retention, the budget-aware load balancer, cold-start seeding, and the TRUST CLAMP (due = min(SR-ideal, cycle ceiling); manzil un-skippable; never "safe to drop") — pinned by frozen golden vectors and §7.12 invariant property tests, no I/O, "today" injected.' },
  { id: 'E05', slug: 'quran-data-and-rendering', cat: 'foundation', deps: 'E01, E03',
    docs: 'docs/engineering/08-quran-data-and-immutable-rendering.md, 09-asset-packs-and-offline-integrity.md, docs/PRD.md §11',
    skills: 'domain-asset-pack-integrity, domain-mushaf-text-integrity, ui-mushaf-page-view',
    mission: 'The offline Quran-data spine: the one-time asset-pack downloader (GitHub Releases, per-file SHA-256 fail-closed, pinned manifest), reference-data load (Tanzil text + QUL layout), and the immutable rendering primitive — select the page glyph font and draw it (never the OS shaper), markers as coordinate overlays — with the CI visual-diff and the explicit riwāyah.' },
  { id: 'E06', slug: 'mihrab-foundation', cat: 'foundation', deps: 'E01',
    docs: 'docs/design-system/02-material-and-platform-foundations.md, 03-color-and-themes.md, 04-typography.md, 05-layout-spacing-touch.md, 06-motion-and-haptics.md',
    skills: 'eng-write-to-coding-standards',
    mission: 'The Mihrab design foundation in Flutter: the token API (color/type/space/motion as a ThemeExtension), the light/sepia/dark themes, the UI Arabic-script type vs the sacred muṣḏaf type separation, and exactly the skeleton components the walking skeleton needs — presentation-only, RTL-native, no engine or date logic.' },
  { id: 'E07', slug: 'app-shell-walking-skeleton', cat: 'skeleton', deps: 'E02, E03, E04, E05, E06',
    docs: 'docs/engineering/01-architecture-overview.md, 04-flutter-and-state-patterns.md, docs/PRD.md §12',
    skills: 'eng-add-feature-module, eng-create-riverpod-store, eng-define-service-boundary',
    mission: 'The thin end-to-end spine: the Flutter app shell with the Riverpod composition root, go_router RTL bottom-nav (Today · Muṣḥaf · Mutashābihāt · Progress · Settings), and one vertical slice — seed a profile through a minimal cold start, see real engine-selected due pages on Today, grade one page, and have it persist through the single write path and survive a kill-relaunch.' },
  { id: 'E08', slug: 'accessibility-foundation', cat: 'crosscutting', deps: 'E01, E06, E07',
    docs: 'docs/design-system/09-accessibility-and-inclusivity.md, docs/engineering/12-localization-rtl-accessibility-impl.md',
    skills: 'eng-rtl-and-bidi-layout, eng-write-dart-test',
    mission: 'Accessibility as Definition-of-Done, not retrofit: dynamic text scaling, Semantics label/value/role conventions, screen-reader (TalkBack/VoiceOver) traversal, reduce-motion substitutions, never-color-alone enforcement, and a PR-blocking accessibility audit harness the feature epics ride on.' },
  { id: 'E09', slug: 'localization-rtl-foundation', cat: 'crosscutting', deps: 'E01, E06, E07',
    docs: 'docs/engineering/12-localization-rtl-accessibility-impl.md, docs/design-system/12-localization-and-rtl.md, docs/design-system/11-voice-and-tone.md',
    skills: 'eng-add-localized-string, eng-rtl-and-bidi-layout',
    mission: 'fa/ckb/ar and RTL as structure: the gen_l10n ARB pipeline (Arabic base content language), the locale-completeness CI gate, Directionality/logical-inset rules, FSI/PDI bidi isolation, per-locale numerals, the calendar-display layer, and the swappable sabaq/sabqi/manzil term-sets — with religious copy flagged for scholarly review.' },
  { id: 'E10', slug: 'mihrab-component-library', cat: 'foundation', deps: 'E06',
    docs: 'docs/design-system/07-components.md, 08-data-visualization.md, 09-accessibility-and-inclusivity.md',
    skills: 'ui-page-card, ui-cycle-preset-picker, ui-settings-picker, ui-certainty-label, ui-empty-state, ui-catch-up-banner, ui-reminder-row, ui-destructive-confirm, ui-numerals-calendar-text',
    mission: 'The breadth of the Mihrab component library with full widget/golden preview matrices and the design-09 accessibility anatomy — the page card + track chip, heat-map cell, grade band, certainty label, pickers, banners, rows, and destructive-confirm — deliberately off the skeleton critical path so it can run as a parallel workflow.' },
  { id: 'E11', slug: 'onboarding-and-cold-start', cat: 'feature', deps: 'E07, E08, E09, E10, E05',
    docs: 'docs/PRD.md §12.1 + §7.10, docs/design-system/11-voice-and-tone.md, docs/design-system/01-design-principles.md',
    skills: 'ui-cold-start-placement, ui-cycle-preset-picker, domain-asset-pack-integrity, ui-settings-picker',
    mission: 'The first-run promise and the make-or-break placement: the welcome + privacy framing, language pick, riwāyah confirmation, the one-time core-pack download, juz coverage capture, per-juz Solid/Shaky/Rusty confidence with optional "when memorized", and the named cycle preset + daily budget — seeding the engine without a calibration grind.' },
  { id: 'E12', slug: 'today-and-recite-grade', cat: 'feature', deps: 'E07, E08, E09, E10, E04',
    docs: 'docs/PRD.md §12.2 + §8 + §7.8-7.9, docs/design-system/07-components.md',
    skills: 'ui-daily-session-list, ui-recite-grade-flow, domain-grading-pipeline, ui-catch-up-banner, ui-page-card, ui-empty-state, ui-teacher-signoff',
    mission: 'The core daily loop: the Today "revise today" list grouped manzil→sabqi→sabaq in recitation order with honest budget feedback, the reveal-on-tap recite-from-memory flow with the four-grade band, stumble-line marking, the in-flow teacher (talaqqī) sign-off, the calm catch-up banner, and the all-done state — no audio, no AI, no celebration.' },
  { id: 'E13', slug: 'mushaf-reader', cat: 'feature', deps: 'E05, E07, E10',
    docs: 'docs/PRD.md §11.2, docs/engineering/08-quran-data-and-immutable-rendering.md, docs/design-system/04-typography.md',
    skills: 'ui-mushaf-page-view, domain-mushaf-text-integrity',
    mission: 'The in-app muṣḥaf reader built on the E05 rendering primitive: book-like immutable page rendering, RTL page navigation, jump to juz/ḥizb/sūrah/page, weak-line and mutashābihāt overlay toggles, sepia/dark/zoom by transforming the rendered layer, and the always-shown riwāyah.' },
  { id: 'E14', slug: 'mutashabihat-trainer', cat: 'feature', deps: 'E04, E05, E13',
    docs: 'docs/PRD.md §9, docs/science/05-interference-and-mutashabihat.md',
    skills: 'domain-mutashabihat-system, ui-mutashabihat-drill',
    mission: 'The mutashābihāt interference subsystem and its trainer: loading the scholar-reviewed confusables dataset, the discrimination-drill UI (siblings back-to-back, diverging words highlighted as overlays), the swap-error confusion log feeding confusion_edge, the anchor hint, and the personal confusion-hotspots view.' },
  { id: 'E15', slug: 'progress-and-heatmap', cat: 'feature', deps: 'E07, E10, E04',
    docs: 'docs/PRD.md §12.5, docs/design-system/08-data-visualization.md, 03-color-and-themes.md',
    skills: 'ui-retention-heatmap, ui-page-card, ui-numerals-calendar-text',
    mission: 'The Progress screen centered on the whole-Quran retention heat-map: the 604-page / 30-juz grid with the calm green-receding-to-neutral ramp (never red), redundant color+number+label cells, the min-leaning juz roll-up, the page-detail sheet, the weakest-juz list, and a calm upcoming-load forecast — informing, never a streak.' },
  { id: 'E16', slug: 'settings-profiles-teacher', cat: 'feature', deps: 'E07, E09, E10, E12',
    docs: 'docs/PRD.md §15, docs/design-system/12-localization-and-rtl.md, 07-components.md',
    skills: 'ui-settings-picker, ui-profile-switcher, ui-teacher-signoff, ui-numerals-calendar-text',
    mission: 'The grouped Settings surface and the local multi-profile system: language/calendar/numeral/term-set/theme/muṣḥaf pickers, cycle-preset and daily-budget controls, the device-local profiles (self/students/child), and the teacher/halaqa switch-student→sign-off loop — no cloud, no account.' },
  { id: 'E17', slug: 'backup-and-restore', cat: 'feature', deps: 'E03, E07, E10',
    docs: 'docs/engineering/10-backup-format.md, docs/PRD.md §16',
    skills: 'domain-backup-format, ui-backup-card, ui-destructive-confirm',
    mission: 'The local, offline backup/restore: the versioned, integrity-checked .hifzbackup file the user saves anywhere (no cloud, no account), the replace-vs-merge restore (set-union over the append-only review_log for teacher↔student transfer), the optional encryption envelope, the erase action, and the honest "lose phone + file = data gone" tradeoff copy.' },
  { id: 'E18', slug: 'reminders', cat: 'feature', deps: 'E02, E10, E12',
    docs: 'docs/PRD.md §14, docs/design-system/10-privacy-and-trust-ux.md, 11-voice-and-tone.md',
    skills: 'ui-reminder-row',
    mission: 'Local notifications as an opt-in, off-by-default, rebuildable derived cache: one calm daily reminder ("Your revision for today is ready") at a user-chosen time, the optional catch-up note, neutral tone with no guilt/fear/streak framing and no escalation — device-local only.' },
  { id: 'E19', slug: 'science-screen-and-claims', cat: 'feature', deps: 'E07, E10',
    docs: 'docs/science/11-the-in-app-science-screen.md, docs/science/CLAIMS.md, docs/design-system/10-privacy-and-trust-ux.md',
    skills: 'domain-claims-register-and-science-screen, ui-science-source-row, ui-certainty-label',
    mission: 'The offline "The science we follow" screen rendering the CLAIMS register: plain-language claims (why revision is spaced, whole-page recall, no streaks, never "safe to drop", the schedule = your own grades, no AI) each with a neutral certainty label and a tappable bundled source — sect-neutral, no fiqh rulings, no claim unsourced.' },
  { id: 'E20', slug: 'release-readiness', cat: 'release', deps: 'E08, E09, E10–E19',
    docs: 'docs/engineering/13-oss-repo-and-release.md, docs/PRD.md §20, docs/design-system/13-islamic-identity-and-adab.md',
    skills: 'eng-add-ci-check, domain-adab-and-religious-integrity, domain-mushaf-text-integrity',
    mission: 'No new feature work: every release-blocking gate green (no-network, SHA-256 text/asset integrity, engine golden vectors, RTL/muṣḥaf goldens, localization completeness, coverage), the adab/religious-integrity and scholarly-review checkpoints signed off, the OSS trust pack published, and the F-Droid + app-store release from a signed tag.' },
]

const epicById = Object.fromEntries(EPICS.map(e => [e.id, e]))
const dir = (e) => `${BASE}/epics/${e.id}-${e.slug}`

const PRE = `You are building the Hifz Companion BUILD PLAN, matching the CycleVault epics/tasks standard exactly.
The app: free (ṣadaqah), fully offline (assets downloaded once then airplane-mode forever), NO AI / no audio recognition, Flutter + pure-Dart engine + Drift/SQLite, RTL Persian (fa) / Kurdish-Sorani (ckb) / Arabic (ar). The non-negotiables (Quran text fidelity, sect-neutrality, no gamification of worship, servant-to-teacher, privacy/no-microphone, nothing "safe to drop") outrank every feature.
Source of truth: docs/PRD.md, docs/design-system/, docs/engineering/, docs/science/, and the skills in .claude/skills/. For the exact EPIC.md / task-file FORMAT you MAY read one CycleVault example (/Users/zakariafatahi/Projects/MobileApps/CycleVault/epics/E06-app-shell-and-walking-skeleton/EPIC.md and its E06-T02 task file). COPY THE FORMAT, NOT THE CONTENT — never carry over Swift/iOS, menstrual, security-decoy, or purchase content.
Traceability is mandatory: every EPIC traces scope to PRD/doc sections; every task cites the skills it follows, the docs/decisions it implements, the CLAIMS ids behind any user-facing number, and concrete verifiable acceptance criteria (test-first for correctness-critical work). Never invent a rule with no doc behind it.`

async function chunked(items, fn, size) {
  const out = []
  for (let i = 0; i < items.length; i += size) {
    const res = await parallel(items.slice(i, i + size).map((it, j) => () => fn(it, i + j)))
    out.push(...res)
  }
  return out
}

const epicPrompt = (e) => PRE + `

TASK: Write ${dir(e)}/EPIC.md for epic ${e.id} (${e.slug}, category: ${e.cat}).
Mission: ${e.mission}
Depends on: ${e.deps}
Governing docs: ${e.docs}
Primary skills: ${e.skills}

Read FIRST (use the Read tool): docs/PRD.md and the governing docs above and the cited skills' SKILL.md files. Then write EPIC.md following the CycleVault EPIC.md anatomy EXACTLY: H1 title + a 2–4 sentence mission; "## Why this epic exists" (ground it in the PRD/research — e.g. the manzil-decay problem, text-fidelity risk, no-AI/offline constraints); "## Scope" (### In scope / ### Out of scope, with out-of-scope pointing to the owning epic); "## Dependencies" (### Depends on / ### Enables); "## Foundation inputs" (a table: Input | Where (doc/skill) | What this epic takes); "## Deliverables" (checkbox list); "## Definition of Done" (checkbox list incl. the global non-negotiables — offline/no-network, no-AI, text fidelity, RTL+fa/ckb/ar localization, accessibility, sect-neutral adab, tests); "## Tasks" (a table: ID | Task | Size | Depends on — one row per task, linking [title](E##-T##-slug.md)); "## Risks" (bullets with mitigations); "## References" (the exact doc/skill paths + sections).

Break the epic into 6–12 PR-sized tasks (one unit of focused work each; correctness-critical ones test-first). Use ids ${e.id}-T01, ${e.id}-T02, … Make the Tasks table in EPIC.md match the tasks you return.

Use the Write tool to create EPIC.md, then return JSON {epicId:'${e.id}', title, category:'${e.cat}', mission, tasks:[{id, slug, title, size (S|M|L), dependsOn, skills, scope}]}.`

phase('Epics')
const epicResults = await chunked(EPICS, (e) =>
  agent(epicPrompt(e), { label: `epic:${e.id}`, phase: 'Epics', agentType: 'general-purpose', schema: TASK_LIST_SCHEMA }), CHUNK)
const epicsOk = epicResults.filter(Boolean)
log(`epics written: ${epicsOk.length}/${EPICS.length}`)

// Flatten tasks
const allTasks = []
epicsOk.forEach(er => {
  const e = epicById[er.epicId]
  if (!e) return
  ;(er.tasks || []).forEach(t => allTasks.push({ ...t, epicId: er.epicId, epicSlug: e.slug, epicMission: er.mission || e.mission, epicCat: e.category || e.cat, epicDocs: e.docs, siblingList: (er.tasks || []).map(x => `${x.id} ${x.title}`).join(' | ') }))
})
log(`total tasks to write: ${allTasks.length}`)

const taskPrompt = (t) => PRE + `

TASK: Write ${BASE}/epics/${t.epicId}-${t.epicSlug}/${t.id}-${t.slug}.md — one PR-sized task file for epic ${t.epicId}.
Task title: ${t.title}
Size: ${t.size || 'M'} · Depends on: ${t.dependsOn || '—'} · Skills: ${t.skills || ''}
Task scope: ${t.scope}
Epic mission (context): ${t.epicMission}
Governing docs for this epic: ${t.epicDocs}
Sibling tasks in this epic (for cross-linking & dependency realism): ${t.siblingList}

Read FIRST (use the Read tool): the epic's EPIC.md at ${BASE}/epics/${t.epicId}-${t.epicSlug}/EPIC.md, the cited skills' SKILL.md, and the precise governing doc sections. Then write the task file following the CycleVault task anatomy EXACTLY:
- H1: "# ${t.id} — ${t.title}"
- a metadata table with rows: Epic (link to EPIC.md), Size, Depends on, Skills.
- "## Goal" (1 short paragraph: the concrete end state).
- "## Context & references" (a table: Reference | What to take from it — list the exact doc sections, the skills + their template, the CLAIMS ids if any user-facing number/copy is involved, and sibling tasks).
- "## Implementation notes" (numbered; concrete Dart/Flutter specifics — file paths in the right package, types, Riverpod/Drift/engine specifics; TEST-FIRST note for correctness-critical work; list the pitfalls to avoid).
- "## Acceptance criteria" (checkbox list, specific and verifiable).
- "## Tests" (the exact test files + cases — unit/widget/golden/integration; engine golden vectors where relevant; offline/no-network guards).
- "## Definition of Done" (checkbox list incl. the relevant non-negotiables: offline/no-network, no-AI/no-microphone, Quran text fidelity, RTL + fa/ckb/ar strings, accessibility, sect-neutral adab, deterministic tests).
Keep it implementation-grade and traceable. Use the Write tool, then return JSON {id:'${t.id}'}.`

phase('Tasks')
const taskResults = await chunked(allTasks, (t) =>
  agent(taskPrompt(t), { label: `task:${t.id}`, phase: 'Tasks', agentType: 'general-purpose', schema: { type: 'object', properties: { id: { type: 'string' } } } }), CHUNK)
const tasksOk = taskResults.filter(Boolean)
log(`tasks written: ${tasksOk.length}/${allTasks.length}`)

phase('Index')
const indexRows = epicsOk.map(er => {
  const e = epicById[er.epicId]
  return `${er.epicId} | ${er.title || e.slug} | ${e.category} | ${e.deps} | ${(er.tasks || []).length} | ${(er.mission || e.mission).slice(0, 200)}`
}).join('\n')
const readmePrompt = PRE + `

TASK: Write ${BASE}/epics/README.md — the Hifz Companion v1 build plan, matching the CycleVault epics/README.md (you MAY read it for format). Include: an intro (one directory per epic E##-<slug>/ with EPIC.md + E##-T##-<slug>.md task files; this is an assembly sequence for ONE complete free/offline release, not phased releases — nothing ships until E20); the "## Epic index" table with columns ID | Epic | Category | Depends on | Tasks | Mission (link each ID to its EPIC.md); a "## Dependency graph — build waves" ASCII diagram grouping epics that can run in parallel; a "## Locked scope decisions (v1)" section (free/ṣadaqah — no monetization ever; fully offline, assets downloaded once; NO AI / no audio; languages fa/ckb/ar all RTL, Kurmanji dropped; sect-neutral, no bundled tafsīr); a "## Traceability convention" section (epic→PRD/docs, task→skills/decisions/CLAIMS); and a "## Definition of Done — non-negotiable across all epics" section (offline/no-network provable, no-AI/no-microphone, Quran text fidelity via checksum+glyph fonts, nothing "safe to drop", RTL+fa/ckb/ar localization is DoD, accessibility is DoD, sect-neutral adab, tests not optional, claims sourced).
Epics (id | title | category | depends | #tasks | mission):
${indexRows}

Use the Write tool, then return JSON {written:true}.`
await agent(readmePrompt, { label: 'epics-README', phase: 'Index', agentType: 'general-purpose', schema: { type: 'object', properties: { written: { type: 'boolean' } } } })

return { epicsWritten: epicsOk.length, tasksWritten: tasksOk.length, totalTasks: allTasks.length }
