export const meta = {
  name: 'hifz-skills',
  description: 'Generate the Claude Code skills library for the Hifz app (domain/eng/ui), grounded in docs/, matching the CycleVault skills standard',
  phases: [
    { title: 'Skills', detail: 'one agent per skill writes SKILL.md + references.md + template' },
    { title: 'Index', detail: 'skills README index' },
  ],
}

const BASE = '/Users/zakariafatahi/Projects/MobileApps/hifz'
const CHUNK = 5

const SKILL_SCHEMA = {
  type: 'object',
  properties: { name: { type: 'string' }, description: { type: 'string' }, category: { type: 'string' }, useWhen: { type: 'string' }, docs: { type: 'string' } },
  required: ['name', 'description'],
}

// Each skill: name, category, trigger (for description), the governing docs, and what it governs.
const SKILLS = [
  // ---------- DOMAIN ----------
  { name: 'domain-scheduling-engine-rules', cat: 'domain', tmpl: 'dart',
    govern: 'The FSRS-style DSR scheduler: page card, Difficulty/Stability/Retrievability, the three lifecycle tracks (sabaq/sabqi/manzil), phase graduation, stakes-tiered retention, load balancer, cold-start, and above all the TRUST CLAMP (due = min(SR-ideal, cycle ceiling); never "safe to drop"; manzil un-skippable).',
    docs: 'docs/engineering/06-scheduling-engine.md, docs/PRD.md §7, docs/science/03-spaced-repetition-algorithms.md, docs/science/06-overlearning-and-lifelong-retention.md',
    useWhen: 'Adding, changing, or reviewing any revision-scheduling logic, DSR math, track/phase transitions, retention targets, load balancing, cold-start, or any engine output or golden test vector' },
  { name: 'domain-mushaf-text-integrity', cat: 'domain', tmpl: 'dart',
    govern: 'The existential text-fidelity rules: byte-exact Quran text + SHA-256, render ONLY via bundled KFGQPC QPC per-page glyph fonts (never the OS shaper), layout from fixed data (never recomputed), markers drawn as coordinate overlays on the immutable glyph layer (never re-typeset), explicit riwāyah, swappable muṣḥaf.',
    docs: 'docs/engineering/08-quran-data-and-immutable-rendering.md, docs/PRD.md §11 + R1/R2, docs/design-system/13-islamic-identity-and-adab.md',
    useWhen: 'Rendering or touching Quran text in any way: the muṣḥaf reader, glyph-font rendering, page layout, weak-line/ayah/mutashābihāt overlays, or anything that could reflow, re-typeset, or alter the sacred text' },
  { name: 'domain-asset-pack-integrity', cat: 'domain', tmpl: 'dart',
    govern: 'The offline asset-pack contract: Quran data lives in a public open-source GitHub repo, downloaded ONCE (core pack at onboarding, optional reciter/mushaf packs on demand), each pack SHA-256-verified against app-pinned hashes at runtime, app refuses unverified Quran assets, then fully offline forever.',
    docs: 'docs/engineering/09-asset-packs-and-offline-integrity.md, docs/PRD.md §11.1 + C1, docs/engineering/01-architecture-overview.md',
    useWhen: 'Implementing or changing asset download, integrity verification, pack versioning, the onboarding core-pack step, optional audio packs, or anything touching the (only) permitted network use' },
  { name: 'domain-mutashabihat-system', cat: 'domain', tmpl: 'dart',
    govern: 'The similar-verse interference subsystem: the scholar-reviewed confusables dataset (objective wording only), the personal confusion log, discrimination interleaving (co-schedule siblings in one session), confusion-aware grading, and anchor hinting.',
    docs: 'docs/science/05-interference-and-mutashabihat.md, docs/engineering/06-scheduling-engine.md, docs/PRD.md §9',
    useWhen: 'Building or changing the mutashābihāt trainer, the confusables graph/dataset, discrimination drills, confusion-error logging, or interference penalties in the scheduler' },
  { name: 'domain-grading-pipeline', cat: 'domain', tmpl: 'dart',
    govern: 'Grading with NO AI/audio: reveal-on-tap self-rating + on-device teacher (talaqqī) sign-off normalized to one (grade, error_lines, source) signal with per-source confidence weights; teacher always overrides; sacred-text guard (a dropped/altered word is never "Good"); never a microphone.',
    docs: 'docs/engineering/06-scheduling-engine.md, docs/science/04-retrieval-practice-and-self-testing.md, docs/PRD.md §8 + C2/R5',
    useWhen: 'Building or changing how a review is graded — the recite/grade flow, self-rating, teacher sign-off, error-line capture, confidence weighting, or anything that feeds a grade into the engine' },
  { name: 'domain-calendars-and-hifzdate', cat: 'domain', tmpl: 'dart',
    govern: 'Calendar-date correctness: a calendar-date value type with integer day math (no instants), Hijri (Umm al-Qurā) / Solar-Hijri-Jalālī / Gregorian display, DST/timezone safety, "today" injected for determinism.',
    docs: 'docs/engineering/07-dates-calendars-and-correctness.md, docs/PRD.md §13.3, docs/engineering/06-scheduling-engine.md',
    useWhen: 'Adding or changing any date math, day counts, due-date computation, date serialization, calendar display (Hijri/Jalālī/Gregorian), or scheduled local notifications' },
  { name: 'domain-claims-register-and-science-screen', cat: 'domain', tmpl: 'md',
    govern: 'The CLAIMS register and the in-app "The science we follow" screen: every user-facing factual claim is one graded, sourced row; the grade→lay-label mapping; the rule that no claim ships without a verified source; sect-neutral, no fiqh rulings for [TRAD] claims.',
    docs: 'docs/science/CLAIMS.md, docs/science/11-the-in-app-science-screen.md, docs/science/REFERENCES.md, docs/design-system/11-voice-and-tone.md',
    useWhen: 'Adding/changing/removing any user-facing number, scheduling rule shown to users, educational copy, or methodology claim; editing CLAIMS.md/REFERENCES.md; or building the science screen' },
  { name: 'domain-backup-format', cat: 'domain', tmpl: 'dart',
    govern: 'The local, offline backup/restore: a versioned export file the user saves anywhere (no cloud, no account), integrity-checked, clear merge/replace import semantics, and the honest "lose phone + file = data gone" tradeoff.',
    docs: 'docs/engineering/10-backup-format.md, docs/engineering/05-persistence-and-encryption.md, docs/PRD.md §16',
    useWhen: 'Changing the backup file layout, the export/import flow, versioning/migration of the backup, or the restore/merge semantics' },
  { name: 'domain-adab-and-religious-integrity', cat: 'domain', tmpl: 'md',
    govern: 'The non-negotiable religious guardrails that outrank every feature: reverence/adab toward the muṣḥaf, sect/madhhab neutrality, riwāyah stated explicitly, ZERO bundled tafsīr, NO gamification of worship, no guilt/fear, servant-to-the-teacher, never "safe to drop", privacy/no-microphone — and where scholarly review is required.',
    docs: 'docs/PRD.md §4 (R1-R6), docs/design-system/13-islamic-identity-and-adab.md, docs/design-system/11-voice-and-tone.md, docs/science/10-traditional-hifz-methodology.md',
    useWhen: 'Authoring ANY user-facing copy, feature, notification, visual treatment of the muṣḥaf, motivational mechanic, or methodology/religious claim — the always-on conscience check for the whole app' },

  // ---------- ENGINEERING ----------
  { name: 'eng-create-package', cat: 'eng', tmpl: 'dart',
    govern: 'Adding a local Dart/Flutter package (especially the pure-Dart engine package with zero Flutter/IO imports), its pubspec, and the dependency rules that keep the engine pure and the layers separated.',
    docs: 'docs/engineering/02-project-structure.md, docs/engineering/01-architecture-overview.md, docs/engineering/13-oss-repo-and-release.md',
    useWhen: 'Adding any local package under the workspace, creating the engine/data/quran/assets packages, or authoring a pubspec/dependency boundary' },
  { name: 'eng-add-feature-module', cat: 'eng', tmpl: 'dart',
    govern: 'Creating a new navigable feature (a tab or screen — Today, Muṣḥaf, Mutashābihāt, Progress, Settings) under the features layer, wired to providers and routing.',
    docs: 'docs/engineering/02-project-structure.md, docs/engineering/04-flutter-and-state-patterns.md, docs/engineering/01-architecture-overview.md',
    useWhen: 'Creating a new feature module / navigable screen or tab in the app' },
  { name: 'eng-create-riverpod-store', cat: 'eng', tmpl: 'dart',
    govern: 'Creating or extending a long-lived Riverpod provider/notifier, with the single-write-path rule (persist transactionally BEFORE republishing in-memory state).',
    docs: 'docs/engineering/04-flutter-and-state-patterns.md, docs/engineering/01-architecture-overview.md, docs/engineering/05-persistence-and-encryption.md',
    useWhen: 'Creating or extending an app-scope provider/notifier, or adding a mutation that writes persisted state' },
  { name: 'eng-define-service-boundary', cat: 'eng', tmpl: 'dart',
    govern: 'Introducing a side-effect boundary (persistence, local notifications, asset IO, the clock/"today", backup IO) as an injectable, testable dependency behind an interface.',
    docs: 'docs/engineering/01-architecture-overview.md, docs/engineering/04-flutter-and-state-patterns.md, docs/engineering/11-testing-strategy.md',
    useWhen: 'Wiring any side effect (DB, notifications, file IO, time/clock) as an injectable dependency so the core stays pure and testable' },
  { name: 'eng-write-to-coding-standards', cat: 'eng', tmpl: 'dart',
    govern: 'Authoring or modifying production Dart: style, naming, error handling, immutability, analyzer/lint conformance, complexity limits.',
    docs: 'docs/engineering/03-coding-standards.md, docs/engineering/01-architecture-overview.md',
    useWhen: 'Writing or modifying any production Dart function, class, error type, or async boundary in any package' },
  { name: 'eng-write-dart-test', cat: 'eng', tmpl: 'dart',
    govern: 'Adding unit / widget / golden / integration_test coverage following the test pyramid and coverage policy.',
    docs: 'docs/engineering/11-testing-strategy.md, docs/engineering/03-coding-standards.md',
    useWhen: 'Adding or extending any test (unit, widget, golden, or integration) for a package or the app' },
  { name: 'eng-write-engine-golden-vector', cat: 'eng', tmpl: 'dart',
    govern: 'Writing deterministic golden test vectors for the scheduler (fixed inputs + injected "today" → pinned schedule), asserting invariants (trust clamp never exceeds ceiling, manzil never dropped, lapse demotes).',
    docs: 'docs/engineering/11-testing-strategy.md, docs/engineering/06-scheduling-engine.md, docs/PRD.md §7.12',
    useWhen: 'Adding or changing deterministic test vectors / invariant tests for the scheduling engine' },
  { name: 'eng-add-drift-table-or-migration', cat: 'eng', tmpl: 'dart',
    govern: 'Changing the local SQLite/Drift schema: adding tables/columns, writing a versioned migration, transactional crash-safety, at-rest encryption.',
    docs: 'docs/engineering/05-persistence-and-encryption.md, docs/engineering/11-testing-strategy.md',
    useWhen: 'Changing the Drift/SQLite schema (tables, columns, indexes) or writing a schema migration' },
  { name: 'eng-add-persisted-model', cat: 'eng', tmpl: 'dart',
    govern: 'Introducing a new persisted record (card, review_log, profile, confusion_edge, cycle_config…) and its DAO read/write methods through the single write path.',
    docs: 'docs/engineering/05-persistence-and-encryption.md, docs/engineering/03-coding-standards.md, docs/engineering/01-architecture-overview.md',
    useWhen: 'Adding a new persisted domain record or a DAO/repository method for an existing one' },
  { name: 'eng-add-localized-string', cat: 'eng', tmpl: 'md',
    govern: 'Adding/renaming any user-facing or accessibility string via gen_l10n ARB for fa/ckb/ar, including plurals and the swappable religious term-sets (sabaq/sabqi/manzil regional names).',
    docs: 'docs/engineering/12-localization-rtl-accessibility-impl.md, docs/design-system/11-voice-and-tone.md, docs/design-system/12-localization-and-rtl.md',
    useWhen: 'Adding, renaming, or modifying any user-facing, notification, or screen-reader string, plural, or localizable term in fa/ckb/ar' },
  { name: 'eng-rtl-and-bidi-layout', cat: 'eng', tmpl: 'dart',
    govern: 'RTL-correct layout: Directionality, logical (start/end) insets, mirror vs do-not-mirror policy for custom graphics, bidi isolation (FSI/PDI) for mixed runs, locale numerals, calendar display.',
    docs: 'docs/design-system/12-localization-and-rtl.md, docs/engineering/12-localization-rtl-accessibility-impl.md, docs/engineering/07-dates-calendars-and-correctness.md',
    useWhen: 'Authoring directional layout, mirroring a custom-drawn graphic, wiring a direction-relative gesture, or rendering numbers/dates/free-text in RTL' },
  { name: 'eng-add-ci-check', cat: 'eng', tmpl: 'yml',
    govern: 'Creating or changing a CI gate: the no-network assertion, text/asset integrity (checksum + golden render), engine golden vectors, lint, coverage thresholds.',
    docs: 'docs/engineering/13-oss-repo-and-release.md, docs/engineering/11-testing-strategy.md, docs/engineering/01-architecture-overview.md',
    useWhen: 'Creating or modifying any CI job, gate script, grep/no-network ban, golden-render check, or coverage threshold' },

  // ---------- UI ----------
  { name: 'ui-daily-session-list', cat: 'ui', tmpl: 'dart',
    govern: 'The Today "revise today" surface: a finite, capped list grouped manzil(far)→sabqi(near)→sabaq(new) in recitation order, each row a page card; honest budget feedback; calm, no streaks.',
    docs: 'docs/design-system/07-components.md, docs/design-system/05-layout-spacing-touch.md, docs/PRD.md §12.2',
    useWhen: 'Building the Today screen, the daily revision list/queue, the grouped due-pages list, or the budget-feedback line' },
  { name: 'ui-recite-grade-flow', cat: 'ui', tmpl: 'dart',
    govern: 'The reveal-on-tap recite flow + grade buttons (Again/Hard/Good/Easy) with optional stumble-line marking and teacher-signoff toggle; no audio; calm receipt, no celebration.',
    docs: 'docs/design-system/07-components.md, docs/design-system/06-motion-and-haptics.md, docs/PRD.md §8.1',
    useWhen: 'Building the recite-from-memory flow, the reveal-on-tap surface, the grade buttons, or the stumble-line marker' },
  { name: 'ui-page-card', cat: 'ui', tmpl: 'dart',
    govern: 'A due-page tile: page number (locale numerals), juz, track chip (sabaq/sabqi/manzil, localized), and a calm decay indicator — shape+label, never color alone.',
    docs: 'docs/design-system/07-components.md, docs/design-system/03-color-and-themes.md, docs/design-system/09-accessibility-and-inclusivity.md',
    useWhen: 'Building a page tile/row, the track chip, or the per-page decay indicator used in lists and the heat-map detail' },
  { name: 'ui-mushaf-page-view', cat: 'ui', tmpl: 'dart',
    govern: 'The immutable muṣḥaf page renderer: select the page glyph font and draw it (never OS shaping/reflow), overlays as coordinate rectangles, zoom/sepia/dark by transforming the layer, riwāyah shown.',
    docs: 'docs/design-system/04-typography.md, docs/engineering/08-quran-data-and-immutable-rendering.md, docs/PRD.md §11.2',
    useWhen: 'Building the muṣḥaf reader, a page view, page navigation, or any rendering of Quran text on a page' },
  { name: 'ui-retention-heatmap', cat: 'ui', tmpl: 'dart',
    govern: 'The whole-Quran retention heat-map (604 pages / 30 juz): calm sequential single-hue scale (green receding to neutral, never alarming red), min-leaning juz roll-up, redundantly encoded (color+number+label), informs—never a streak.',
    docs: 'docs/design-system/08-data-visualization.md, docs/PRD.md §12.5, docs/design-system/03-color-and-themes.md',
    useWhen: 'Building the retention heat-map, the per-juz/per-page health visual, or any whole-Quran strength/decay visualization' },
  { name: 'ui-cycle-preset-picker', cat: 'ui', tmpl: 'dart',
    govern: 'The named-cycle selector (7-Manzil weekly khatm, 1 juz/day, ½ juz/day, Deobandi 3-track, Custom, Pure-cycle mode) — a named choice, NEVER a "retention slider".',
    docs: 'docs/design-system/07-components.md, docs/PRD.md §15.1, docs/design-system/01-design-principles.md',
    useWhen: 'Building the cycle/preset selection, the manzil-cycle settings, or the named-tradition picker' },
  { name: 'ui-cold-start-placement', cat: 'ui', tmpl: 'dart',
    govern: 'The onboarding placement flow: mark which juz are held, then per-juz Solid/Shaky/Rusty, optional "when memorized" — seeds conservative priors; sub-20-min onboarding; make-or-break.',
    docs: 'docs/design-system/07-components.md, docs/design-system/11-voice-and-tone.md, docs/PRD.md §7.10 + §12.1',
    useWhen: 'Building the onboarding/cold-start coverage capture, per-juz confidence rating, or first-day setup' },
  { name: 'ui-mutashabihat-drill', cat: 'ui', tmpl: 'dart',
    govern: 'The discrimination-drill UI: confusable siblings presented back-to-back with diverging words highlighted (as overlays on the immutable page), plus the personal confusion-hotspots view.',
    docs: 'docs/design-system/07-components.md, docs/science/05-interference-and-mutashabihat.md, docs/PRD.md §9.3',
    useWhen: 'Building the mutashābihāt trainer screen, a discrimination drill, the anchor-word highlight, or the confusion-hotspots view' },
  { name: 'ui-teacher-signoff', cat: 'ui', tmpl: 'dart',
    govern: 'The on-device teacher (talaqqī) sign-off control: present teacher taps verdict (+optional stumble lines); authoritative, overrides the machine; framed as servant to the teacher, never a replacement.',
    docs: 'docs/design-system/07-components.md, docs/PRD.md §8.2 + §15.3, docs/design-system/13-islamic-identity-and-adab.md',
    useWhen: 'Building the teacher sign-off control, the talaqqī verdict surface, or halaqa per-student sign-off' },
  { name: 'ui-catch-up-banner', cat: 'ui', tmpl: 'dart',
    govern: 'The missed-day catch-up banner: re-spread the backlog over several days, weakest/prayer-critical first, calm and supportive ("here is a 5-day catch-up plan") — never a red shame-pile.',
    docs: 'docs/design-system/11-voice-and-tone.md, docs/design-system/06-motion-and-haptics.md, docs/PRD.md §7.9',
    useWhen: 'Building the missed-day / backlog / catch-up surface, or any return-after-gap messaging on Today' },
  { name: 'ui-profile-switcher', cat: 'ui', tmpl: 'dart',
    govern: 'Local multi-profile (self / students / child) on one device — quick switcher for teacher/halaqa mode, parent-managed child profile; device-local only, sharing via export (no server).',
    docs: 'docs/design-system/07-components.md, docs/PRD.md §15.3, docs/design-system/10-privacy-and-trust-ux.md',
    useWhen: 'Building the profile switcher, teacher/halaqa multi-student mode, or child-profile management' },
  { name: 'ui-science-source-row', cat: 'ui', tmpl: 'dart',
    govern: 'A citation/source row on the science screen: plain attribution + certainty label + tappable source; external links clearly leave the app; renders only verified CLAIMS rows.',
    docs: 'docs/science/11-the-in-app-science-screen.md, docs/science/REFERENCES.md, docs/design-system/10-privacy-and-trust-ux.md',
    useWhen: 'Building a science topic page, a citation/source row, or the "why does the app say this?" affordance' },
  { name: 'ui-certainty-label', cat: 'ui', tmpl: 'dart',
    govern: 'The evidence-certainty badge: map a CLAIMS grade ([MA]/[RCT]/[EXP]/[CS]/[OBS]/[TEXT]/[TRAD]) to a neutral lay label; never show raw grade tags; neutral (not traffic-light) styling.',
    docs: 'docs/science/CLAIMS.md, docs/science/11-the-in-app-science-screen.md, docs/design-system/11-voice-and-tone.md',
    useWhen: 'Rendering an evidence-certainty label/badge or mapping a CLAIMS grade to a lay label' },
  { name: 'ui-settings-picker', cat: 'ui', tmpl: 'dart',
    govern: 'A single-choice Settings control for a preference (language, calendar system, numeral system, term-set, theme, muṣḥaf) inside the grouped Settings surface.',
    docs: 'docs/design-system/07-components.md, docs/design-system/12-localization-and-rtl.md, docs/design-system/05-layout-spacing-touch.md',
    useWhen: 'Building a Settings single-choice picker/dropdown (calendar, numerals, language, term-set, theme, muṣḥaf)' },
  { name: 'ui-backup-card', cat: 'ui', tmpl: 'dart',
    govern: 'The backup card: export/import buttons, status line, the honest no-cloud "lost phone + file = data gone" tradeoff copy, stale-backup state — no cloud iconography, no account.',
    docs: 'docs/design-system/10-privacy-and-trust-ux.md, docs/engineering/10-backup-format.md, docs/design-system/11-voice-and-tone.md',
    useWhen: 'Building the backup/export/restore card, its status line, or the no-recovery tradeoff copy' },
  { name: 'ui-empty-state', cat: 'ui', tmpl: 'dart',
    govern: 'Empty/first-run/return-after-gap states: calm, non-shaming, no "you haven\'t logged" guilt; the welcoming first day and the neutral welcome-back.',
    docs: 'docs/design-system/07-components.md, docs/design-system/11-voice-and-tone.md, docs/PRD.md §12',
    useWhen: 'Building an empty state, first-run screen, or return-after-gap view' },
  { name: 'ui-reminder-row', cat: 'ui', tmpl: 'dart',
    govern: 'An opt-in local-notification config row: off by default, one calm daily reminder, neutral tone ("Your revision for today is ready") — never guilt/fear; local-only.',
    docs: 'docs/design-system/10-privacy-and-trust-ux.md, docs/design-system/11-voice-and-tone.md, docs/engineering/07-dates-calendars-and-correctness.md',
    useWhen: 'Building a reminder/notification toggle row or any opt-in local-notification configuration' },
  { name: 'ui-destructive-confirm', cat: 'ui', tmpl: 'dart',
    govern: 'Irreversible destructive actions (erase-all / wipe a profile): double-confirmation, concrete consequence text, safe choice primary, no obstruction dark patterns.',
    docs: 'docs/design-system/10-privacy-and-trust-ux.md, docs/design-system/06-motion-and-haptics.md, docs/PRD.md §16',
    useWhen: 'Building an erase-all/wipe/irreversible action or any double-confirmation consequence flow' },
  { name: 'ui-numerals-calendar-text', cat: 'ui', tmpl: 'dart',
    govern: 'Rendering locale numerals (Extended Arabic-Indic ۰۱۲ for fa/ckb, Arabic-Indic ٠١٢ for ar) and dates in the chosen calendar (Hijri/Jalālī/Gregorian) — never raw ASCII digits in localized strings.',
    docs: 'docs/design-system/12-localization-and-rtl.md, docs/engineering/07-dates-calendars-and-correctness.md, docs/engineering/12-localization-rtl-accessibility-impl.md',
    useWhen: 'Rendering any number, page count, juz number, or date to the user — applying locale numerals and the chosen calendar' },
]

async function chunked(items, fn, size) {
  const out = []
  for (let i = 0; i < items.length; i += size) {
    const res = await parallel(items.slice(i, i + size).map((it, j) => () => fn(it, i + j)))
    out.push(...res)
  }
  return out
}

const tmplFile = (t) => t === 'md' ? 'template.md' : t === 'yml' ? 'template.yml' : 'template.dart'

const skillPrompt = (s) => `You are authoring ONE Claude Code skill for the Hifz Companion app, matching the quality and exact format of the CycleVault skills library.

READ FIRST (use the Read tool):
- ${BASE}/docs/_DOC-SET-BLUEPRINT.md (tone/constraints)
- the governing docs for THIS skill: ${s.docs}
- For the exact SKILL.md / references.md / template format, you MAY read one CycleVault example: /Users/zakariafatahi/Projects/MobileApps/CycleVault/.claude/skills/ui-quick-log-chip/SKILL.md and its references.md. COPY THE FORMAT, NOT THE CONTENT — our app is a Flutter (Dart), fully-offline, NO-AI, RTL (Persian/Sorani/Arabic) Quran-memorization app; CycleVault is a Swift menstrual tracker. Never carry over Swift, SwiftUI, iOS-only, menstrual, or medical content.

APP CONTEXT: free ṣadaqah, fully offline (assets downloaded once then airplane-mode forever), no AI/no audio recognition, Flutter + pure-Dart engine + Drift/SQLite, RTL fa/ckb/ar. The non-negotiables (text fidelity, sect-neutrality, no gamification of worship, servant-to-teacher, privacy) outrank everything.

SKILL: "${s.name}" (category: ${s.cat})
WHAT IT GOVERNS: ${s.govern}
USE IT WHEN: ${s.useWhen}
GOVERNING DOCS: ${s.docs}

Write THREE files into ${BASE}/.claude/skills/${s.name}/ (use the Write tool for each):

1) SKILL.md — with YAML frontmatter:
---
name: ${s.name}
description: <one or two sentences: "Build/Do X for the Hifz app. Use whenever <triggers>." This is the auto-load trigger — make it specific and keyword-rich.>
---
Then the body, following the CycleVault SKILL.md anatomy EXACTLY: H1 (the skill name); a short purpose paragraph; "## When to use" (bullets, plus a "Do NOT use this skill for → use **other-skill-name**" list cross-linking sibling skills); "## The canonical pattern" (numbered steps; EACH step must cite the precise governing doc section in backticks, e.g. \`docs/engineering/06-scheduling-engine.md\` §N, and reference design tokens / engine rules by name); "## Do / Don't" (a two-column table); "## Checklist" (a checkbox list that is the done-criteria, Flutter/Dart-specific, including RTL fa/ckb/ar, offline, no-AI, and adab/integrity checks where relevant); a closing note; "## Files" (template + references.md); and "Related skills:" cross-links. Make every rule trace to a governing doc; never invent a rule with no doc behind it.

2) references.md — "# references — ${s.name}", then the precise governing doc sections grouped (Primary / supporting / sibling skills), each bullet naming the exact file + section and "the one thing to take from it." End with a "Sibling skills" list.

3) ${tmplFile(s.tmpl)} — a copy-paste scaffold (${s.tmpl === 'md' ? 'markdown/ARB-style' : s.tmpl === 'yml' ? 'GitHub Actions YAML' : 'Flutter/Dart'}) with // TODO markers, referencing token/engine/rule names by name. Keep it realistic and idiomatic for ${s.tmpl === 'dart' ? 'Flutter/Dart (Riverpod, Material 3, Directionality/RTL)' : s.tmpl}.

Return JSON {name:'${s.name}', description, category:'${s.cat}', useWhen, docs}.`

phase('Skills')
const results = await chunked(SKILLS, (s) =>
  agent(skillPrompt(s), { label: `skill:${s.name}`, phase: 'Skills', agentType: 'general-purpose', schema: SKILL_SCHEMA }), CHUNK)
const ok = results.filter(Boolean)
log(`skills written: ${ok.length}/${SKILLS.length}`)

phase('Index')
const rows = ok.map(r => `| \`${r.name}\` | ${r.useWhen || ''} | ${r.docs || ''} |`).join('\n')
const byCat = (c) => ok.filter(r => (r.category || '').startsWith(c))
const readmePrompt = `Write ${BASE}/.claude/skills/README.md — the index for the Hifz Companion skills library, matching the CycleVault skills README (you MAY read /Users/zakariafatahi/Projects/MobileApps/CycleVault/.claude/skills/README.md for format; adapt to our app — Flutter, offline, no-AI, RTL fa/ckb/ar, ṣadaqah). Include: an intro paragraph (skills auto-load when relevant; they encode the HOW distilled from docs/, which are the WHAT/WHY; a skill never contradicts its governing doc — the doc wins); then three "Skills by category" tables (Domain, Engineering, UI) with columns Skill | Use it when | Governing docs; then a "How these relate to docs and tasks" section; and a "Contributing" note (no skill without a doc behind it). Here are the skills (name | use-when | docs):\n\nDOMAIN:\n${byCat('domain').map(r => `${r.name} | ${r.useWhen} | ${r.docs}`).join('\n')}\n\nENGINEERING:\n${byCat('eng').map(r => `${r.name} | ${r.useWhen} | ${r.docs}`).join('\n')}\n\nUI:\n${byCat('ui').map(r => `${r.name} | ${r.useWhen} | ${r.docs}`).join('\n')}\n\nUse the Write tool, then return JSON {name:'README'}.`
await agent(readmePrompt, { label: 'skills-README', phase: 'Index', agentType: 'general-purpose', schema: { type: 'object', properties: { name: { type: 'string' } } } })

return { skillsWritten: ok.length, total: SKILLS.length, names: ok.map(r => r.name) }
