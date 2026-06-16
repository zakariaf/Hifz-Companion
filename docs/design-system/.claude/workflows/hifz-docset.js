export const meta = {
  name: 'hifz-docset',
  description: 'Generate research-backed doc sets (science, engineering, design-system) for the Hifz app, matching the CycleVault standard — areas run sequentially with throttled concurrency',
  phases: [
    { title: 'Research', detail: 'web-researched, cited research notes' },
    { title: 'Foundation', detail: 'README with pillars/decision-log/file index' },
    { title: 'Synthesis', detail: 'numbered synthesis docs distilled from research' },
    { title: 'References', detail: 'CLAIMS (science) + master REFERENCES' },
  ],
}

const BASE = '/Users/zakariafatahi/Projects/MobileApps/hifz'
const CHUNK = 5 // max concurrent agents per batch — keep well under the burst rate limit

const RESEARCH_SCHEMA = {
  type: 'object',
  properties: {
    slug: { type: 'string' }, title: { type: 'string' }, summary: { type: 'string' },
    sources: { type: 'array', items: { type: 'object', properties: {
      citation: { type: 'string' }, url: { type: 'string' }, grade: { type: 'string' } }, required: ['citation'] } },
  }, required: ['slug', 'summary'],
}
const SYNTH_SCHEMA = {
  type: 'object',
  properties: {
    file: { type: 'string' }, summary: { type: 'string' },
    sources: { type: 'array', items: { type: 'object', properties: {
      citation: { type: 'string' }, url: { type: 'string' }, grade: { type: 'string' } }, required: ['citation'] } },
  }, required: ['summary'],
}
const README_SCHEMA = { type: 'object', properties: { written: { type: 'boolean' }, pillarsSummary: { type: 'string' } }, required: ['written'] }

const AREAS = {
  'science': {
    name: 'science',
    synthStyle: "Structure each numbered section as Statement → Evidence (every point cited to a REAL study you verified) → In practice (how it shapes the app/engine; reference the scheduler behavior from PRD.md) → Misconceptions/anti-patterns we refuse. End with ## References.",
    readmeExtra: "Note that CLAIMS.md is the load-bearing claims register and the in-app 'The science we follow' screen renders from it. Include the evidence-grade legend ([MA]/[RCT]/[EXP]/[CS]/[OBS]/[TEXT]/[TRAD]).",
    hasClaims: true,
    research: [
      { slug: 'forgetting-curve', prompt: "The forgetting curve and decay of memory: Ebbinghaus (1885) and modern replications (e.g. Murre & Dros 2015), savings on relearning, forgetting functions, and implications for scheduling Quran revision." },
      { slug: 'spacing-effect', prompt: "The spacing / distributed-practice effect: massed vs spaced, expanding vs fixed intervals, Cepeda et al. (2006, 2008) meta-analyses, optimal gap as a function of the retention interval." },
      { slug: 'spaced-repetition-algorithms', prompt: "Spaced-repetition algorithms: Leitner, SuperMemo SM-2 / SM-17/18, the open FSRS model (difficulty/stability/retrievability), Duolingo half-life regression; how desired retention sets intervals." },
      { slug: 'retrieval-practice', prompt: "Retrieval practice / the testing effect: Roediger & Karpicke (2006) and follow-ups, recall vs recognition, why active recitation from memory beats re-reading, feedback timing." },
      { slug: 'interference-theory', prompt: "Interference theory: proactive and retroactive interference, similarity-driven confusion, discrimination/contrast training — the cognitive basis of the mutashābihāt (similar-verse) problem." },
      { slug: 'overlearning-automaticity', prompt: "Overlearning, automaticity, and durable retention: overlearning effects, fluency, relearning savings, and how near-ceiling lifelong retention is achieved and maintained." },
      { slug: 'serial-recall-chunking', prompt: "Serial-order memory and chunking: recall of long ordered verbal sequences, chunking, production of memorized continuous text, and why a whole 'page in flow' is the natural recall unit (vs isolated ayah cards)." },
      { slug: 'sleep-and-consolidation', prompt: "Sleep and memory consolidation, and spacing practice across days: overnight consolidation, multi-session spacing, and strengthening of long-term verbal memory." },
      { slug: 'motivation-habit-noncoercive', prompt: "Motivation and habit without coercion: self-determination theory, habit formation (Lally et al. 2010), and evidence that gamification / streaks / guilt undermine intrinsic motivation and can harm — especially for worship." },
      { slug: 'hifz-methodology-evidence', prompt: "Traditional Quran-memorization methodology as empirical spaced repetition: sabaq / sabqi / manzil three tracks, the 7 manāzil, talaqqī, classical scholars' guidance on revision; map to modern SR. Cite identifiable scholarly/traditional sources; stay sect-neutral; never issue fiqh rulings." },
      { slug: 'quran-memorization-research', prompt: "Academic & applied research specifically on Quran memorization (hifz): studies on methods, retention, cognition/neuroscience of huffaz, and educational outcomes. Cite real studies with URLs." },
    ],
    docs: [
      { file: '01-memory-and-forgetting', scope: 'How human memory decays, the forgetting curve, and why revision is mathematically necessary — the foundation of the whole app.', notes: ['forgetting-curve', 'quran-memorization-research'] },
      { file: '02-the-spacing-effect', scope: 'Distributed practice beats massed; expanding intervals; the optimal-gap finding — the basis for spacing manzil revision.', notes: ['spacing-effect', 'spaced-repetition-algorithms'] },
      { file: '03-spaced-repetition-algorithms', scope: 'Leitner → SM-2 → FSRS: the algorithm family the engine adapts, and how desired retention sets intervals.', notes: ['spaced-repetition-algorithms', 'forgetting-curve'] },
      { file: '04-retrieval-practice-and-self-testing', scope: 'The testing effect: reciting from memory (not re-reading) is the act that strengthens hifz; reveal-on-tap grading.', notes: ['retrieval-practice'] },
      { file: '05-interference-and-mutashabihat', scope: 'Interference as the dominant hifz failure mode; discrimination/contrast training; the mutashābihāt subsystem.', notes: ['interference-theory', 'hifz-methodology-evidence'] },
      { file: '06-overlearning-and-lifelong-retention', scope: 'Why sacred text needs near-100% retention via overlearning + the cycle ceiling, not a 0.9 target.', notes: ['overlearning-automaticity', 'forgetting-curve'] },
      { file: '07-serial-recall-and-the-page-unit', scope: 'Serial recall and chunking justify scheduling the whole page (in flow), not isolated ayah/word cards.', notes: ['serial-recall-chunking'] },
      { file: '08-sleep-consolidation-and-scheduling', scope: 'Sleep and multi-day spacing; why daily sessions and overnight gaps matter for the schedule.', notes: ['sleep-and-consolidation', 'spacing-effect'] },
      { file: '09-motivation-without-coercion', scope: 'The science against streaks/guilt/gamification; sustaining revision through autonomy and calm, not coercion.', notes: ['motivation-habit-noncoercive'] },
      { file: '10-traditional-hifz-methodology', scope: 'Sabaq/sabqi/manzil and the 7 manāzil as time-tested empirical SR; tradition validated by science, never replaced.', notes: ['hifz-methodology-evidence', 'quran-memorization-research'] },
      { file: '11-the-in-app-science-screen', scope: "Spec of the in-app 'The science we follow' screen that renders the CLAIMS register in plain language with sources, bundled offline.", notes: ['retrieval-practice', 'motivation-habit-noncoercive', 'spacing-effect'] },
    ],
  },
  'engineering': {
    name: 'engineering',
    synthStyle: "Structure each section as Decision (state it; reference the README tech-decision log entry by name) → Rationale (cited to official docs / SE evidence) → Specification (Dart code blocks, schemas, tables, test vectors) → Pitfalls / what we refuse. Be implementation-grade.",
    readmeExtra: "Include a 'Stack at a glance' table and a canonical numbered tech-decision log table covering: Flutter + min SDK; Riverpod (or Bloc) state; Drift/SQLite + at-rest encryption; a pure-Dart deterministic FSRS-style engine (no I/O, 'today' injected); Quran assets as offline packs downloaded from GitHub Releases with runtime SHA-256 pinning; immutable QPC glyph-font rendering; Hijri/Jalālī/Gregorian calendar-date value type; NO networking beyond asset download (CI-asserted); golden/unit/integration testing + GitHub Actions CI; OSS license. Docs reference entries as 'Decision log: topic'.",
    hasClaims: false,
    research: [
      { slug: 'flutter-architecture-2026', prompt: "Modern Flutter app architecture (2025-2026): Flutter's official architecture guidance, layered separation of a pure-Dart domain core from UI, offline-first / local-first patterns." },
      { slug: 'dart-effective-clean-code', prompt: "Effective Dart and clean-code practices with evidence: Dart style/usage guidance, plus peer-reviewed evidence on clean code, complexity, naming, and maintainability." },
      { slug: 'state-management-riverpod', prompt: "Flutter state management: Riverpod (and Bloc) patterns, trade-offs, dependency injection, and testability; official guidance and community consensus." },
      { slug: 'drift-sqlite-persistence', prompt: "Local persistence in Flutter with Drift over SQLite: schema, migrations, transactional crash-safety, and at-rest encryption (sqlite3 + SQLCipher / sqflite_sqlcipher)." },
      { slug: 'fsrs-and-sr-implementations', prompt: "FSRS in practice: the open FSRS spec and parameters, reference implementations (py-fsrs, ts-fsrs, rs-fsrs, fsrs4anki, dart-fsrs if any), and how to implement a deterministic scheduler." },
      { slug: 'calendars-i18n-hijri-jalali', prompt: "Calendar correctness for Hijri (Umm al-Qurā), Solar-Hijri/Jalālī, and Gregorian in Dart/Flutter: algorithms/packages (hijri, shamsi/jalaali, timezone), date-vs-instant pitfalls, display conventions." },
      { slug: 'flutter-rtl-i18n', prompt: "Flutter i18n and RTL: intl + gen_l10n/ARB, Directionality, bidi isolation, locale-specific Eastern Arabic-Indic numerals, and RTL layout correctness." },
      { slug: 'arabic-script-rendering-fonts', prompt: "Rendering Arabic-script & Quran text faithfully in Flutter: complex-text shaping pitfalls, Persian/Arabic/Kurdish-Sorani font coverage, and the KFGQPC per-page glyph-font (QCF) immutable-muṣḥaf approach." },
      { slug: 'flutter-testing-ci', prompt: "Testing Flutter/Dart: unit, golden, and integration_test; deterministic engine testing; GitHub Actions CI including asserting no networking ships in release." },
      { slug: 'asset-integrity-and-distribution', prompt: "Distributing & verifying app assets offline: hosting static packs on GitHub Releases, runtime SHA-256 integrity pinning, supply-chain integrity, and provable offline operation." },
      { slug: 'oss-mobile-release-fdroid', prompt: "Open-sourcing & releasing a free mobile app: license choice (GPL/AGPL/MIT) for a sadaqah project, F-Droid + Play/App Store distribution, privacy manifests, auditability." },
    ],
    docs: [
      { file: '01-architecture-overview', scope: 'System shape: layers, the pure-Dart engine core vs Flutter shell, data flow, the offline (no-network) guarantee.', notes: ['flutter-architecture-2026'] },
      { file: '02-project-structure', scope: 'Repo & package layout (engine/data/quran/assets/features/l10n), folder conventions, dependency rules.', notes: ['flutter-architecture-2026', 'dart-effective-clean-code'] },
      { file: '03-coding-standards', scope: 'Dart style, evidence-based clean-code rules, analyzer/lint config, review checklist.', notes: ['dart-effective-clean-code'] },
      { file: '04-flutter-and-state-patterns', scope: 'State management (Riverpod), widget/view conventions, navigation, single-write-path persistence.', notes: ['state-management-riverpod', 'flutter-architecture-2026'] },
      { file: '05-persistence-and-encryption', scope: 'Drift/SQLite schema, migrations, transactional crash-safety, at-rest encryption.', notes: ['drift-sqlite-persistence'] },
      { file: '06-scheduling-engine', scope: 'The pure-Dart FSRS-style revision engine: data model, scheduling logic, trust clamp, cold-start, determinism, test vectors (the core IP — see PRD §7).', notes: ['fsrs-and-sr-implementations'] },
      { file: '07-dates-calendars-and-correctness', scope: 'Calendar-date value type; Hijri/Jalālī/Gregorian; integer day math; DST/timezone safety; test matrix.', notes: ['calendars-i18n-hijri-jalali'] },
      { file: '08-quran-data-and-immutable-rendering', scope: 'Immutable Quran text + QPC glyph-font rendering, layout from fixed data, overlay markers, CI visual-diff (PRD §11).', notes: ['arabic-script-rendering-fonts'] },
      { file: '09-asset-packs-and-offline-integrity', scope: 'Open-source GitHub asset packs, one-time download, runtime SHA-256 verification, offline-forever guarantee (PRD §11.1).', notes: ['asset-integrity-and-distribution'] },
      { file: '10-backup-format', scope: 'Local file backup/restore format (offline, no cloud): structure, versioning, integrity, import/merge.', notes: ['drift-sqlite-persistence', 'asset-integrity-and-distribution'] },
      { file: '11-testing-strategy', scope: 'Test pyramid, golden tests, engine golden vectors, invariants, coverage policy, CI gates (incl. no-network + text-integrity).', notes: ['flutter-testing-ci'] },
      { file: '12-localization-rtl-accessibility-impl', scope: 'gen_l10n/ARB for fa/ckb/ar, Directionality/bidi, numerals, calendars, accessibility (TalkBack/dynamic text) implementation.', notes: ['flutter-rtl-i18n', 'calendars-i18n-hijri-jalali'] },
      { file: '13-oss-repo-and-release', scope: 'License, repo hygiene, CI/CD, privacy manifest, F-Droid/store release, auditability for a free sadaqah project.', notes: ['oss-mobile-release-fdroid'] },
    ],
  },
  'design-system': {
    name: 'design-system',
    synthStyle: "Structure each section as Statement → Evidence (every point cited) → In practice (concrete; reference design tokens by name; cover fa/ckb/ar RTL) → Anti-patterns ('we will never'). End with ## References.",
    readmeExtra: "Give the design system a short name and metaphor. Include a Token discipline table assigning ownership: color.* → 03-color-and-themes, type.* → 04-typography, space.* → 05-layout-spacing-touch, motion.*/haptic.* → 06-motion-and-haptics.",
    hasClaims: false,
    research: [
      { slug: 'islamic-app-design-patterns', prompt: "Design patterns in well-made Islamic / Quran apps: muṣḥaf reading UX, reverence/adab in digital Quran presentation, what users value, and what to avoid (gamifying sacred content)." },
      { slug: 'material3-flutter-design', prompt: "Material 3 + Flutter theming: M3 color roles, typography, components, elevation, motion; adaptive/iOS considerations in Flutter; design-token practice." },
      { slug: 'arabic-persian-kurdish-typography', prompt: "Arabic-script UI typography (NOT the Quran text): legibility of Persian/Arabic/Kurdish-Sorani, fonts with full Sorani coverage (Vazirmatn/Estedad/Rabar/NRT), sizing/line-height, distinguishing UI type from the sacred QPC muṣḥaf type." },
      { slug: 'calm-non-gamified-design', prompt: "Calm technology & anti-gamification: evidence that streaks/badges/points reduce intrinsic motivation and cause stress; designing for peace and focus over engagement." },
      { slug: 'color-emotion-and-theming', prompt: "Color, emotion & theming: color-emotion research (arousal from saturation/brightness), low-arousal palettes, light/sepia/dark/night reading modes, contrast." },
      { slug: 'data-visualization-heatmap-uncertainty', prompt: "Visualizing a whole-Quran retention heat-map and strength/decay over time: effective, honest, accessible state visualization; color scales; avoiding alarm; uncertainty display." },
      { slug: 'accessibility-rtl-inclusive', prompt: "Accessibility for an RTL multilingual app: WCAG 2.2, screen readers (TalkBack/VoiceOver), dynamic text size, color-independence, RTL-specific accessibility." },
      { slug: 'privacy-trust-ux', prompt: "Trust & privacy UX for a fully offline, no-account app: making structural privacy felt and perceptible, honest communication, no dark patterns." },
      { slug: 'voice-tone-religious-adab', prompt: "Voice & tone for a reverent Islamic app across Persian/Arabic/Kurdish: respectful, non-guilt, non-coercive copy; adab in addressing the user; multilingual tone consistency." },
      { slug: 'behavior-habit-design', prompt: "Habit design without nagging: cue-based habit support, notification restraint, supporting lapses and return without shame." },
    ],
    docs: [
      { file: '01-design-principles', scope: 'The core design principles (reverence, calm, tradition-as-UI, honest-about-decay, private-by-feel, RTL-native, servant-to-teacher), each grounded in evidence + anti-patterns.', notes: ['islamic-app-design-patterns', 'calm-non-gamified-design'] },
      { file: '02-material-and-platform-foundations', scope: 'How Material 3 + Flutter are adopted (and adapted for iOS); design-token foundations.', notes: ['material3-flutter-design'] },
      { file: '03-color-and-themes', scope: 'Owns color.*: calm Islamic palette, light/sepia/dark/night, the heat-map scale, contrast audit.', notes: ['color-emotion-and-theming'] },
      { file: '04-typography', scope: 'Owns type.*: UI Arabic-script type for fa/ckb/ar vs the sacred QPC muṣḥaf glyph fonts; sizing, line-height, dynamic text.', notes: ['arabic-persian-kurdish-typography'] },
      { file: '05-layout-spacing-touch', scope: 'Owns space.*: spacing scale, grid, RTL layout, touch targets/thumb ergonomics, screen templates.', notes: ['material3-flutter-design'] },
      { file: '06-motion-and-haptics', scope: 'Owns motion.*/haptic.*: calm, informative (never celebratory) motion; reduce-motion; no confetti.', notes: ['calm-non-gamified-design'] },
      { file: '07-components', scope: 'Component library: the daily-session list, recite/grade flow, page card, heat-map cell, anatomy/states/accessibility.', notes: ['material3-flutter-design', 'islamic-app-design-patterns'] },
      { file: '08-data-visualization', scope: 'The whole-Quran retention heat-map and progress visuals: honest, accessible, non-alarming.', notes: ['data-visualization-heatmap-uncertainty'] },
      { file: '09-accessibility-and-inclusivity', scope: 'WCAG 2.2 targets, screen readers, dynamic type, color-independence, RTL accessibility, release checklist.', notes: ['accessibility-rtl-inclusive'] },
      { file: '10-privacy-and-trust-ux', scope: 'Trust as a design material: making offline/no-account/private felt; honest backup; no dark patterns.', notes: ['privacy-trust-ux'] },
      { file: '11-voice-and-tone', scope: 'Voice, tone-by-context, reverent non-guilt copy, sensitive framing, across fa/ckb/ar.', notes: ['voice-tone-religious-adab'] },
      { file: '12-localization-and-rtl', scope: 'RTL-first layout, mirror/do-not-mirror policy, locale numerals, calendars, localizable terminology for fa/ckb/ar.', notes: ['accessibility-rtl-inclusive', 'arabic-persian-kurdish-typography'] },
      { file: '13-islamic-identity-and-adab', scope: 'Islamic visual identity and adab toward the muṣḥaf: reverence, restraint, never gamifying/decorating the sacred.', notes: ['islamic-app-design-patterns', 'voice-tone-religious-adab'] },
    ],
  },
}

// Throttled fan-out: run `items` through `fn` in batches of `size` to avoid burst rate limits.
async function chunked(items, fn, size) {
  const out = []
  for (let i = 0; i < items.length; i += size) {
    const batch = items.slice(i, i + size)
    const res = await parallel(batch.map((it, j) => () => fn(it, i + j)))
    out.push(...res)
  }
  return out
}

const PRE = (areaName) => `You are authoring ONE document in the Hifz Companion "${areaName}" documentation set, which must match the quality bar of the CycleVault doc set.
MUST READ FIRST (use the Read tool): ${BASE}/docs/_DOC-SET-BLUEPRINT.md , ${BASE}/docs/PRD.md , and ${BASE}/research/RESEARCH-FINDINGS.md.
Follow the blueprint's document anatomy, citation convention, tone, and evidence grades EXACTLY. The app is a FREE (sadaqah), fully-offline, NO-AI, Flutter, RTL (Persian/Sorani-Kurdish/Arabic) Quran-memorization RETENTION app. Citations must be REAL and web-verified — never fabricate. `

async function runArea(areaName) {
  const area = AREAS[areaName]
  const dir = `${BASE}/docs/${area.name}`
  const files = area.docs.map(d => d.file)
  const pre = PRE(area.name)

  const researchPrompt = (r) => pre +
    `\nTASK: Write the research note at ${dir}/research/${r.slug}.md following blueprint §4c (Title; **Topic:**/**Compiled:**; ## What the evidence says [numbered, themed, each finding cited]; ## Implications for Hifz Companion [numbered, actionable]; ## Citations [numbered, full, with URLs${area.hasClaims ? ' and trailing — [GRADE]' : ''}]).` +
    `\nTopic to research deeply: ${r.prompt}` +
    `\nFirst load web tools: call ToolSearch with query 'select:WebSearch,WebFetch'. Run 6+ real searches, read primary sources, and verify every URL. Aim ~130–230 substantive lines. Use the Write tool to create the file, then return JSON {slug,title,summary,sources[]}.`

  const readmePrompt = (digest) => pre +
    `\nTASK: Write ${dir}/README.md following blueprint §4a for the ${area.name} area.` +
    `\nInclude: a one-paragraph overview; the non-negotiable values/pillars (blueprint §1 for this area) each backed by the single strongest REAL citation; one or two outranking rules; a File index table covering exactly these files: README.md, ${files.map(f => f + '.md').join(', ')}, ${area.hasClaims ? 'CLAIMS.md, ' : ''}REFERENCES.md, and research/; the citation convention (point to the blueprint); Status; References. ${area.readmeExtra}` +
    `\nResearch notes already written (summaries to ground you):\n${digest}` +
    `\nUse the Write tool to create the file, then return JSON {written:true, pillarsSummary}.`

  const synthPrompt = (d) => pre +
    `\nTASK: Write ${dir}/${d.file}.md following blueprint §4b. Scope: ${d.scope}` +
    `\nRead for grounding (use Read): ${dir}/README.md and these research notes (if present on disk): ${d.notes.map(n => `${dir}/research/${n}.md`).join(' , ')}. If a referenced note is missing, proceed using the README plus your own web research (load WebSearch/WebFetch via ToolSearch).` +
    `\n${area.synthStyle}` +
    `\nCite every significant claim with a real, verified source; cross-link sibling docs by filename; end with a ## References section listing only sources cited here. Use the Write tool to create the file, then return JSON {file:'${d.file}', summary, sources[]}.`

  const claimsPrompt = () => pre +
    `\nTASK: Write ${dir}/CLAIMS.md following blueprint §4d — the load-bearing register of EVERY user-facing factual claim the app makes (memory/SR science + traditional hifz methodology + adab/motivation), grouped into tables with columns ID | Claim (as the app states it) | Value/rule the app uses | Source(s) | Grade | App surface | Notes/caveats. Read the science research notes already on disk in ${dir}/research/ for verified sources. Every claim needs ≥1 verified source; religious/methodology claims graded [TRAD] and scoped (no fiqh rulings, sect-neutral). End with ## References. Use the Write tool, then return JSON {summary, sources[]}.`

  const referencesPrompt = (sources) => pre +
    `\nTASK: Write ${dir}/REFERENCES.md following blueprint §4e — the deduplicated, ${area.hasClaims ? 'graded ' : ''}master bibliography for the ${area.name} set. Here is the union of sources cited across the notes/docs (dedupe and format fully — authors, year, title, venue, URL${area.hasClaims ? ', trailing — [GRADE]' : ''}; add a brief "what it informed" note where useful; sort sensibly):\n${JSON.stringify(sources).slice(0, 12000)}` +
    `\nIf any well-known source is obviously missing, you may add it only if you can verify it. Use the Write tool to create the file, then return JSON {summary}.`

  // Phase 1: Research (throttled)
  phase(`${area.name} · Research`)
  const research = await chunked(area.research, (r) =>
    agent(researchPrompt(r), { label: `${area.name}/research:${r.slug}`, phase: `${area.name} · Research`, agentType: 'general-purpose', schema: RESEARCH_SCHEMA }), CHUNK)
  const researchOk = research.filter(Boolean)
  const digest = researchOk.map(r => `- ${r.slug}: ${r.summary || ''}`).join('\n')
  log(`${area.name}: ${researchOk.length}/${area.research.length} research notes written`)

  // Phase 2: Foundation (README)
  phase(`${area.name} · Foundation`)
  const readme = await agent(readmePrompt(digest), { label: `${area.name}/README`, phase: `${area.name} · Foundation`, agentType: 'general-purpose', schema: README_SCHEMA })

  // Phase 3: Synthesis (throttled)
  phase(`${area.name} · Synthesis`)
  const synth = await chunked(area.docs, (d) =>
    agent(synthPrompt(d), { label: `${area.name}/doc:${d.file}`, phase: `${area.name} · Synthesis`, agentType: 'general-purpose', schema: SYNTH_SCHEMA }), CHUNK)
  const synthOk = synth.filter(Boolean)
  log(`${area.name}: ${synthOk.length}/${area.docs.length} synthesis docs written`)

  // Phase 4: References (+ CLAIMS for science)
  phase(`${area.name} · References`)
  const allSources = []
  researchOk.forEach(r => (r.sources || []).forEach(s => allSources.push(s)))
  synthOk.forEach(r => (r.sources || []).forEach(s => allSources.push(s)))
  let claims = null
  if (area.hasClaims) {
    claims = await agent(claimsPrompt(), { label: `${area.name}/CLAIMS`, phase: `${area.name} · References`, agentType: 'general-purpose', schema: SYNTH_SCHEMA })
    if (claims && claims.sources) claims.sources.forEach(s => allSources.push(s))
  }
  const seen = new Set(); const deduped = []
  allSources.forEach(s => { const k = (s && s.url) || (s && s.citation) || JSON.stringify(s); if (!seen.has(k)) { seen.add(k); deduped.push(s) } })
  const refs = await agent(referencesPrompt(deduped), { label: `${area.name}/REFERENCES`, phase: `${area.name} · References`, agentType: 'general-purpose', schema: { type: 'object', properties: { summary: { type: 'string' } } } })

  return {
    area: area.name, researchWritten: researchOk.length, docsWritten: synthOk.length,
    readme: !!(readme && readme.written), claims: !!claims, references: !!refs, uniqueSources: deduped.length,
  }
}

let ARGS = args
if (typeof ARGS === 'string') { try { ARGS = JSON.parse(ARGS) } catch (e) { ARGS = { area: ARGS } } }
ARGS = ARGS || {}
const requested = ARGS.area && ARGS.area !== 'all' ? [ARGS.area] : ['science', 'engineering', 'design-system']
const valid = requested.filter(a => AREAS[a])
if (!valid.length) throw new Error('No valid area in args: ' + JSON.stringify(args))

const results = []
for (const a of valid) {
  log(`=== Starting area: ${a} ===`)
  results.push(await runArea(a))
}
return valid.length === 1 ? results[0] : results
