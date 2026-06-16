# Hifz Companion Skills Library

This directory holds the Claude Code skills that lock in Hifz Companion's domain,
engineering, and UI patterns. Each skill encodes a recurring decision — how the
scheduling engine updates a card, how the muṣḥaf is rendered without ever altering
a glyph, how a date is counted, how a science claim earns its place on screen — so
that the same thing is always built the same way, no matter who (or which session)
builds it. This is a fully offline, no-AI, no-microphone Flutter app with RTL
fa/ckb/ar surfaces, built free as ṣadaqah jāriyah; the rules live here instead of
in someone's memory so reverence toward the sacred text and consistency both
survive across time.

Skills **auto-load when relevant**. You don't invoke them by hand — when a task
touches a pattern a skill governs (you start touching the engine math, drawing a
page overlay, wiring a Drift migration, writing a notification string), Claude Code
surfaces the matching skill and follows its rules. The descriptions below double as
the trigger: the "Use it when" column is what each skill watches for.

The skills encode the **HOW**, distilled from `docs/`, which are the **WHAT** and
the **WHY**. A skill never contradicts its governing doc; if they ever diverge, the
doc wins and the skill is corrected.

## Skills by category

### Domain (scheduling engine, sacred text, dates, grading, science, adab)

| Skill | Use it when | Governing docs |
|---|---|---|
| `domain-scheduling-engine-rules` | Adding, changing, or reviewing any revision-scheduling logic, FSRS-style D/S/R math, sabaq/sabqi/manzil tracks or phase transitions, graduation, stakes-tiered targets, cold start, the load balancer, the trust clamp (`due_at = min(ideal_due, ceiling_due)`), or any engine output / golden vector in the pure-Dart `engine/` package | `docs/engineering/06-scheduling-engine.md`, `docs/PRD.md` §7–§8, `docs/science/03-spaced-repetition-algorithms.md`, `06-overlearning-and-lifelong-retention.md`, `docs/science/CLAIMS.md` |
| `domain-mushaf-text-integrity` | Rendering or touching Quran text in any way — the reader/paged navigator, the 604 KFGQPC glyph fonts, assembling a page from QUL geometry, drawing a weak-line / ayah / mutashābihāt / error overlay, zoom or night/sepia themes, the SHA-256 + visual-diff integrity gates, naming the riwāyah, or anything that could reflow, re-typeset, or alter the sacred text | `docs/engineering/08-quran-data-and-immutable-rendering.md`, `docs/PRD.md` R1/R2/R3, §6.1, §11, `docs/design-system/13-islamic-identity-and-adab.md` |
| `domain-asset-pack-integrity` | Implementing or changing the `/assets` pack downloader, the runtime SHA-256 fail-closed verifier, the pinned exact-tag manifest, the onboarding core-pack step and its offline/interrupted states, optional reciter/alt-muṣḥaf packs, the TLS-without-cert-pinning transport, or anything that opens the single permitted socket | `docs/engineering/09-asset-packs-and-offline-integrity.md`, `docs/PRD.md` §11.1/§11.1.1, C1, §12.1, R1/R2, `docs/engineering/01-architecture-overview.md` §3.1/§6, `docs/design-system/10-privacy-and-trust-ux.md` |
| `domain-mutashabihat-system` | Building or changing the confusables dataset/graph (`mutashabih_group`/`_member`), discrimination interleaving (co-scheduling siblings), confusion-aware grading (a swap bumps D across the group), the personal confusion log (`confusion_edge`), anchor hinting, or interference penalties in the scheduler | `docs/science/05-interference-and-mutashabihat.md`, `docs/engineering/06-scheduling-engine.md` §1–§2/§4/§6–§8, `docs/PRD.md` §9, §10.1/§10.2, §11.2/R1, §8.2/R6, §21/R4 |
| `domain-grading-pipeline` | Building or changing how a review is graded — reveal-on-tap, self-rating + stumble-count mapping, on-device teacher (talaqqī) sign-off, error/stumble-line capture, the `missedOrAlteredWord` sacred-text guard, source-confidence weighting (self 0.5 / teacher 1.0), the append-only `review_log` write, or producing a normalized `ReviewInput` for `SchedulingEngine.onReview` | `docs/engineering/06-scheduling-engine.md` §2/§4/§8, `docs/science/04-retrieval-practice-and-self-testing.md`, `docs/PRD.md` §8, C2/C4/C6, R1/R5/R6 |
| `domain-calendars-and-hifzdate` | Adding or changing any date math, day counts, due-date computation, "elapsed days", date serialization, the `CalendarDate`/`SerialDay` value type, the injected "today", calendar display (Hijri Umm al-Qurā / Jalālī / Gregorian), locale numerals on dates, or scheduled local notifications | `docs/engineering/07-dates-calendars-and-correctness.md`, `docs/PRD.md` §13.3, §7.6/§7.12, §10.3, §20 gate 5, R2, `docs/engineering/06-scheduling-engine.md` §1/§8, `docs/science/CLAIMS.md` |
| `domain-claims-register-and-science-screen` | Adding/changing/removing any user-facing number, scheduling rule shown to users, educational/methodology copy, notification or tooltip text; editing `CLAIMS.md`/`REFERENCES.md`; surfacing any `[TRAD]` claim; or building the in-app "The science we follow" screen | `docs/science/CLAIMS.md`, `11-the-in-app-science-screen.md`, `REFERENCES.md`, `docs/design-system/11-voice-and-tone.md`, `docs/_DOC-SET-BLUEPRINT.md` §2–§4 |
| `domain-backup-format` | Changing the `.hifzbackup` container layout, the versioned JSON payload / `schemaVersion` / forward-migration, the integrity check, the optional Argon2id→ChaCha20-Poly1305 envelope, replace-vs-merge import (set-union over append-only `review_log`), the `VACUUM INTO` dump, export-to-share, the one-tap erase, or any `backup/` package test | `docs/engineering/10-backup-format.md`, `05-persistence-and-encryption.md`, `docs/PRD.md` §16, §17, §10.2/§10.3, R1/R2 |
| `domain-adab-and-religious-integrity` | The always-on conscience pass — authoring or reviewing ANY user-facing copy, notification, feature, motivational/progress mechanic, visual treatment of the muṣḥaf, attribution surface, or methodology/religious claim. Defer to the named sibling for the mechanism, then return here for the R1–R6 + adab gate | `docs/PRD.md` §4 (R1–R6), §7.12, C6/§1, `docs/design-system/13-islamic-identity-and-adab.md`, `11-voice-and-tone.md`, `docs/science/10-traditional-hifz-methodology.md` |

### Engineering (packages, persistence, state, services, tests, CI)

| Skill | Use it when | Governing docs |
|---|---|---|
| `eng-create-package` | Adding any local package under `packages/` (engine/data/quran/assets/l10n/profiles/features), authoring or fixing a `pubspec.yaml`, wiring a `resolution: workspace` member, or setting the dependency boundary that keeps the engine pure and the layers separated | `docs/engineering/02-project-structure.md`, `01-architecture-overview.md`, `13-oss-repo-and-release.md` |
| `eng-add-feature-module` | Creating a new feature module / navigable screen or tab under `packages/features/lib/src/`, or splitting an over-grown feature folder | `docs/engineering/02-project-structure.md`, `04-flutter-and-state-patterns.md`, `01-architecture-overview.md` |
| `eng-create-riverpod-store` | Creating or extending an app-scope Riverpod provider/notifier (Notifier/AsyncNotifier, StreamProvider read model, DI Provider, family/autoDispose), wiring into the composition root, deriving a reactive read model from a Drift query, or adding a mutation that persists transactionally before republishing in-memory state | `docs/engineering/04-flutter-and-state-patterns.md`, `01-architecture-overview.md`, `05-persistence-and-encryption.md` |
| `eng-define-service-boundary` | Wiring any side effect (DB, local notifications, asset/file IO, the clock/"today", backup IO) as an injectable Riverpod dependency behind a Dart interface — its `Provider`, its single live override in `main`, and its deterministic fake — so the engine stays framework-free and tests stay deterministic | `docs/engineering/01-architecture-overview.md`, `04-flutter-and-state-patterns.md`, `11-testing-strategy.md` |
| `eng-write-to-coding-standards` | Writing or modifying any production Dart function, class, error type, value type, or async/I-O boundary — anytime style, naming, immutability, error handling, analyzer/lint conformance, or complexity limits are in play | `docs/engineering/03-coding-standards.md`, `01-architecture-overview.md` |
| `eng-write-dart-test` | Adding or extending any test (unit, widget, golden, RTL, integration) — engine arithmetic/cold-start/load-balancer/DAO units, frozen FSRS goldens, glados invariants (INV-1..INV-6), real-font muṣḥaf goldens, per-locale RTL goldens, an integration journey, or the throwing-`HttpOverrides` offline guard | `docs/engineering/11-testing-strategy.md`, `03-coding-standards.md` |
| `eng-write-engine-golden-vector` | Adding or changing deterministic golden vectors or invariant property tests for the engine — pinning the FSRS arithmetic with frozen `closeTo(_, 1e-6)` rows, the five cold-start seeds, a PRD §7.12 invariant as a glados property, the `scheduleCase` generators, or regenerating the oracle via `--update-vectors` | `docs/engineering/11-testing-strategy.md`, `06-scheduling-engine.md` §8/§6/§3–§5/§1–§2, `docs/PRD.md` §7.12 |
| `eng-add-drift-table-or-migration` | Changing the Drift/SQLite schema (tables, columns, indices, CHECK/FK), writing a versioned `stepByStep` migration with its committed snapshot, adding a DAO/repository `db.transaction` body, wiring the WAL/`synchronous=FULL`/`foreign_keys` pragmas, or touching the opt-in at-rest encryption toggle | `docs/engineering/05-persistence-and-encryption.md`, `11-testing-strategy.md` |
| `eng-add-persisted-model` | Adding a new persisted domain record (a `models` value type that needs a Drift table), a column/field + mapping, a DAO read/write method or the repository transaction behind it, a schema evolution (snapshot + migration + fixture), or the append-only audit row for a review/sign-off | `docs/engineering/05-persistence-and-encryption.md`, `03-coding-standards.md`, `01-architecture-overview.md` |
| `eng-add-localized-string` | Adding, renaming, or modifying any user-facing, notification, or screen-reader string, plural, or localizable term in fa/ckb/ar — ICU plurals, locale numerals/dates, bidi-isolated mixed-script runs, and the swappable sabaq/sabqi/manzil term-sets | `docs/engineering/12-localization-rtl-accessibility-impl.md`, `docs/design-system/11-voice-and-tone.md`, `12-localization-and-rtl.md` |
| `eng-rtl-and-bidi-layout` | Authoring directional layout, mirroring (or refusing to mirror) a custom-drawn graphic, wiring a direction-relative gesture, rendering numbers/dates/free-text in RTL chrome, or placing any widget in the fa/ckb/ar UI | `docs/design-system/12-localization-and-rtl.md`, `docs/engineering/12-localization-rtl-accessibility-impl.md`, `07-dates-calendars-and-correctness.md` §4 |
| `eng-add-ci-check` | Creating or modifying any CI job, gate script, grep/no-network ban, dependency allow-list, SHA-256 text/asset-integrity check, engine golden-vector or glados-invariant run, pinned-OS muṣḥaf/RTL golden check, `reuse lint` step, or coverage threshold/publication | `docs/engineering/13-oss-repo-and-release.md`, `11-testing-strategy.md`, `01-architecture-overview.md` |

### UI (Today, recite/grade, muṣḥaf, progress, onboarding, Settings)

| Skill | Use it when | Governing docs |
|---|---|---|
| `ui-daily-session-list` | Building the Today screen, the daily revision list/queue, the grouped due-pages list, the Far→Near→New section headers, the page-card row placement, the loading/all-done/catch-up states, or the honest budget-feedback line | `docs/design-system/07-components.md` §1–§2, `05-layout-spacing-touch.md` §1/§3–§5, `docs/PRD.md` §12.2, §7.9 |
| `ui-recite-grade-flow` | Building the recite-from-memory flow, the reveal-on-tap surface, the four grade buttons (Again/Hard/Good/Easy), the stumble-line marker, the disabled-until-revealed state, the undo affordance, or the in-flow teacher sign-off toggle | `docs/design-system/07-components.md` §5–§7, `06-motion-and-haptics.md`, `05-layout-spacing-touch.md`, `03-color-and-themes.md`, `docs/PRD.md` §8, §6.3, §7.12, R1/R3/R6 |
| `ui-page-card` | Building a page-card row in the Today list or heat-map detail; the non-interactive track chip (sabaq/sabqi/manzil, localized); the per-page decay indicator (color + glyph + label); or the card's state emphasis (default/weak/due/pulled-forward/done/locked) | `docs/design-system/07-components.md` §2–§4/§6, `03-color-and-themes.md` §2/§5/§6, `09-accessibility-and-inclusivity.md` §3–§4/§6–§8 |
| `ui-mushaf-page-view` | Building the muṣḥaf reader, a single page view, page navigation across 604 pages, the zoom or light/sepia/dark control, a coordinate overlay layer (weak-line / ayah / anchor / error), or the riwāyah/edition chrome | `docs/design-system/04-typography.md` §1/§5/§7, `docs/engineering/08-quran-data-and-immutable-rendering.md` §1–§6, `docs/PRD.md` §11.2/§11.1.1, §18/§12.3 |
| `ui-retention-heatmap` | Building the whole-Quran retention heat-map (604-page / 30-juz grid, overview → juz → page), a per-juz/page health visual, the page detail sheet, the upcoming-load forecast, or any whole-Quran strength/decay visualization | `docs/design-system/08-data-visualization.md`, `docs/PRD.md` §12.5, §7.10/§7.12, §8.1, §10.2, §13.2/§13.3, `docs/design-system/03-color-and-themes.md` §5/§2/§6/§7, `09-accessibility-and-inclusivity.md` |
| `ui-cycle-preset-picker` | Building the cycle/preset selection, the manzil-cycle settings, the named-tradition picker, the Pure-cycle toggle, the Custom-cycle editor, or any control that only sets `EngineConfig.farCycleDays`/`nearCeilingDays`/`newLinesPerDay`/`dailyBudget`/`pureCycleMode` | `docs/PRD.md` §15.1, §7.6/§7.11, §15.2/§15.3, §17/§18, `docs/design-system/01-design-principles.md`, `docs/engineering/06-scheduling-engine.md` §6, `docs/design-system/07-components.md` §6 |
| `ui-cold-start-placement` | Building the onboarding/cold-start coverage capture, the per-juz Solid/Shaky/Rusty rating, the optional "when memorized" input, or first-day placement/seeding for a partial or complete ḥāfiẓ | `docs/PRD.md` §7.10/§12.1, §7.12, §13.3/§13.4/§21, C1/C2, `docs/design-system/07-components.md` §1/§6/§8, `11-voice-and-tone.md`, `docs/engineering/06-scheduling-engine.md` §5 |
| `ui-mutashabihat-drill` | Building the Mutashābihāt trainer screen, a discrimination drill presenting a confusable group back-to-back, the anchor-word highlight over the glyph page, or the personal confusion-hotspots view | `docs/design-system/07-components.md` §1/§5/§8, `docs/science/05-interference-and-mutashabihat.md` §3–§8, `docs/PRD.md` §9.1–§9.3, §10.1–§10.2, §11.2/R1, §12/§12.4, §13.3–§13.4, §19.2 |
| `ui-teacher-signoff` | Building the teacher sign-off control, the talaqqī verdict surface, the teacher-sourced marker on a card/`review_log`, or the local halaqa per-student path — the "Teacher present" `Switch.adaptive` that flips a grade source from self (≈0.5) to teacher (1.0, authoritative) | `docs/design-system/07-components.md` §4–§8, `docs/PRD.md` §8.2, §8.1, §7.12, §15.3, §8.3, R6/R3, `docs/design-system/13-islamic-identity-and-adab.md` §6/§4 |
| `ui-catch-up-banner` | Building the missed-day / backlog / catch-up surface on Today, the "catch-up ready" note, or any return-after-gap messaging — the calm re-spread framing of a backlog (not the re-spread math) | `docs/design-system/11-voice-and-tone.md` §2–§4/§6/§8/§9, `docs/PRD.md` §7.9/§12.2/§14, `docs/design-system/08-data-visualization.md` §3, `06-motion-and-haptics.md`, `07-components.md` §1, `10-privacy-and-trust-ux.md` |
| `ui-profile-switcher` | Building the profile switcher, the active-profile chip, the create/rename flow, the teacher/halaqa multi-student switch-then-sign-off loop, or a parent-managed child profile — anything holding more than one person's record on one device | `docs/PRD.md` §15.3, §17, §8.2, §16, §19.3, R3/R5, `docs/design-system/07-components.md` §1–§3/§6/§8, `10-privacy-and-trust-ux.md` §1–§3/§8/§11 |
| `ui-science-source-row` | Building a science topic page row, a citation/source row, the evidence-grade tag, the on-device citation block, a `[TRAD]`/hadith source row, or the "why does the app say this?" affordance on the science screen | `docs/science/11-the-in-app-science-screen.md`, `REFERENCES.md`, `docs/design-system/10-privacy-and-trust-ux.md` §3/§7 |
| `ui-certainty-label` | Rendering an evidence-certainty label/badge, mapping a CLAIMS grade enum to its lay confidence phrase, or showing the plain-words grade legend on the science screen | `docs/science/CLAIMS.md`, `11-the-in-app-science-screen.md` §2–§7, `docs/design-system/11-voice-and-tone.md` §2/§5/§8 |
| `ui-settings-picker` | Building a Settings single-choice picker/dropdown (calendar, numerals, language, term-set, theme, muṣḥaf/riwāyah) or any mutually-exclusive preference row in the grouped Settings surface | `docs/design-system/07-components.md` §6, `12-localization-and-rtl.md` §1–§6/§8, `05-layout-spacing-touch.md` §3–§5 |
| `ui-backup-card` | Building the backup/export/restore card, its status line, the no-recovery tradeoff copy, the optional-encryption toggle and passphrase prompt, the stale-backup nudge, the replace-vs-merge restore confirmation, or the erase entry point in Settings | `docs/design-system/10-privacy-and-trust-ux.md` §2–§3/§8–§11, `docs/engineering/10-backup-format.md` §1–§2/§6–§7/§9, `docs/design-system/11-voice-and-tone.md` §2–§4/§7–§9 |
| `ui-empty-state` | Building an empty state, first-run / zero-data screen, the calm "all caught up" / nothing-due surface on Today, or the neutral silent welcome-back after a gap | `docs/design-system/07-components.md` §1, `11-voice-and-tone.md` §2–§4/§6–§9, `docs/PRD.md` §12.2, §13.2/§13.3/§13.4 |
| `ui-reminder-row` | Building a reminder/notification toggle row, a "remind me daily" setting, a reminder-time picker, the optional catch-up note toggle, or any opt-in local-notification configuration in Settings or onboarding | `docs/design-system/10-privacy-and-trust-ux.md` §3/§6/§9/§10/§11, `11-voice-and-tone.md` §3/§7/§8/§9, `docs/engineering/07-dates-calendars-and-correctness.md` §4–§6 |
| `ui-destructive-confirm` | Building an erase-all / wipe / delete-profile / irreversible action, a two-step "type to confirm" or "hold to confirm" gate, or any consequence dialog for an action that cannot be undone — and verifying it is an honest safeguard, not an obstruction dark pattern | `docs/design-system/10-privacy-and-trust-ux.md` §8/§9/§11, `06-motion-and-haptics.md` §2/§4/§5, `05-layout-spacing-touch.md` §5, `11-voice-and-tone.md` §4/§6, `docs/PRD.md` §16, §19.3/R3/R5 |
| `ui-numerals-calendar-text` | Rendering any number, page/juz count, percentage, minute count, or date — applying the locale numeral set (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) and the chosen calendar via `intl`, formatting a "Page N · Juz M" mixed run, rendering a due/last-reviewed date, or wiring the `numberFormatFor(locale)` / `CalendarPresenter` path | `docs/design-system/12-localization-and-rtl.md` §3–§5/§8, `docs/engineering/07-dates-calendars-and-correctness.md` §2/§4/§6, `12-localization-rtl-accessibility-impl.md` §1/§4–§6 |

## How these relate to docs and tasks

The `docs/` folders (`design-system/`, `engineering/`, `science/`) and `PRD.md`
are the source of truth — they explain **what** Hifz Companion does and **why**.
These skills encode the **how**: the executable, always-apply rules distilled from
those docs so the patterns are enforced at build time instead of re-derived per
task. A skill never contradicts its governing doc; if they ever diverge, the doc
wins and the skill is corrected.

The boundaries are deliberate. The domain skills own the non-negotiable mechanisms
— the pure engine math, the immutable sacred text, the date arithmetic, the grading
signal, the backup format — and `domain-adab-and-religious-integrity` runs as the
always-on conscience pass over anything a user reads, feels, or sees marked on the
page. The engineering skills own the package boundaries, the single write path, the
service injection, the tests, and the CI gates that make the offline / no-AI /
no-network guarantees grep-provable. The UI skills own the calm, RTL, never-gamified
surfaces that read from the domain layer but never reach into the engine. When a
task touches more than one of these, defer to the named sibling for the underlying
mechanism, then return to the surface skill for presentation.

Upcoming work will **reference skills by name**. A task that says "build the Today
tab" expects it to ride on `ui-daily-session-list`, `ui-page-card`,
`ui-catch-up-banner`, `eng-add-feature-module`, and `eng-create-riverpod-store` —
the skill is the contract for how each piece is built, so the work can stay focused
on scope while the skills guarantee the implementation comes out uniform and
reverent.

## Contributing

When a pattern recurs and you find yourself re-explaining the same rules, that's a
new skill — but only if it's grounded in a `docs/` file. No skill without a doc
behind it; the doc is the citation, the skill is the enforcement. Each skill ships
a `SKILL.md`, a `references.md` pointing back at the governing sections, and a
`template.dart` (or `template.md`) scaffold whose tokens and engine rules are
referenced by name only.
