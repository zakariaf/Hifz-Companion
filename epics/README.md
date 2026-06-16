# Hifz Companion Epics — v1 Build Plan

This directory is the build plan for **Hifz Companion v1**: twenty epics, listed
in recommended build order, that turn the product requirements (`docs/PRD.md`),
the three doc sets (`docs/design-system/`, `docs/engineering/`,
`docs/science/`), and the skills (`.claude/skills/`) into shippable work for one
**free** (*ṣadaqah jāriyah*), **fully offline**, **no-AI** app.

- One directory per epic: `E##-<slug>/`, each containing a full `EPIC.md`
  (mission, scope, dependencies, acceptance criteria).
- Tasks live *inside* each epic directory as `E##-T##-<slug>.md` files (one file
  per PR-sized task); each epic's `EPIC.md` links every one of its task files.
- Build order is an **assembly sequence for one complete release** (PRD §16) —
  these are **not** phased releases. The whole gift ships at once, or not at all;
  nothing ships until E20 says every covenant is proven.

> **Plan status.** Epics **E01–E14** carry their full per-task files. Epics
> **E15–E20** are drafted to the same standard at the `EPIC.md` level — mission,
> scope, dependencies, acceptance criteria — but their per-task `E##-T##-*.md`
> files are **deferred** (marked *deferred* in the index below) and will be
> written when their wave is reached. The plan is complete and honest at the
> epic level end to end; it is task-complete through E14.

## Epic index

| ID | Epic | Category | Depends on | Tasks | Mission |
|----|------|----------|------------|-------|---------|
| [E01](E01-repo-scaffold-and-ci/EPIC.md) | Repo Scaffold, Pub Workspace & CI Guardrails | foundation | — | 8 | Public GPL-3.0 repo, the pure-Dart-engine pub workspace with its layer boundaries, and the CI guardrails — no-network/banned-import, text & asset SHA-256, REUSE — that make every later covenant machine-checkable from the first commit. |
| [E02](E02-calendar-and-date-core/EPIC.md) | Calendar & Date Core | foundation | E01 | 10 | The pure integer serial-day `CalendarDate` and the single date boundary that make scheduling days un-driftable across any timezone or DST transition, with calendars (Jalālī · Hijri Umm al-Qurā · Gregorian) kept display-only. |
| [E03](E03-models-and-persistence/EPIC.md) | Domain Models & Drift Persistence | foundation | E01, E02 | 10 | The PRD §11 immutable value records plus the Drift/SQLite store: WAL + `synchronous=FULL` crash-safe writes, one transaction per review, the append-only `review_log`, and checksum-governed read-only reference tables. |
| [E04](E04-scheduling-engine/EPIC.md) | Scheduling Engine (FSRS-style DSR core) | foundation | E02, E03 | 11 | The pure, deterministic FSRS-style D/S/R engine — sabaq/sabqi/manzil tracks, stakes-tiered retention, cold-start priors, the load balancer, and the TRUST CLAMP that can only pull a page forward and never declares one "safe to drop"; golden-vector and invariant-property tested. |
| [E05](E05-quran-data-and-rendering/EPIC.md) | Quran Data, Asset Packs & Immutable Rendering | foundation | E01, E03 | 11 | Byte-exact Tanzil text + SHA-256, KFGQPC per-page glyph fonts drawn without the OS shaper, fixed QUL layout, the fail-closed one-time asset-pack downloader, and the named-riwāyah contract — the sacred text is never reflowed or re-typeset. |
| [E06](E06-mihrab-foundation/EPIC.md) | Mihrab Foundation — Tokens, Themes & Skeleton Kit | foundation | E01 | 11 | The Mihrab design-token API, light/sepia/dark themes, and exactly the skeleton component leaves — presentation-only, no date math, no engine, no Quran re-typesetting — that the shell and component library build on. |
| [E07](E07-app-shell-walking-skeleton/EPIC.md) | App Shell & Walking Skeleton | skeleton | E02, E03, E04, E05, E06 | 10 | The thin end-to-end spine: the Riverpod composition root, `go_router` RTL bottom-nav shell, and one vertical slice — a due page on Today, recite/reveal/grade it, persist through the single write path, see the engine re-schedule it. |
| [E08](E08-accessibility-foundation/EPIC.md) | Accessibility Foundation | crosscutting | E01, E06, E07 | 10 | Layered accessibility infrastructure — dynamic text sizing, screen-reader `Semantics` conventions, reduce-motion substitutions, color-independent encoding, and a PR-blocking accessibility audit harness — so a11y is Definition-of-Done, not a retrofit. |
| [E09](E09-localization-rtl-foundation/EPIC.md) | Localization & RTL Foundation | crosscutting | E01, E06, E07 | 10 | fa / ckb / ar (all RTL) as structure: the `gen_l10n` ARB pipeline with key-coverage and Arabic six-plural gates, logical start/end layout, FSI/PDI bidi isolation, per-locale numerals, and the swappable sabaq/sabqi/manzil term-sets. |
| [E10](E10-mihrab-component-library/EPIC.md) | Mihrab Component Library | foundation | E06 | 10 | Every remaining Mihrab component — page card, track chip, decay indicator, heat-map cell, certainty badge, source row — with full preview/golden matrices and accessibility anatomy, runnable as a parallel workflow off the skeleton's critical path. |
| [E11](E11-onboarding-and-cold-start/EPIC.md) | Onboarding & Cold-Start | feature | E07, E08, E09, E10, E05 | 10 | The first-run promise: the one-time core asset-pack download with fail-closed verification, then the make-or-break cold-start placement where a ḥāfiẓ marks held juz and rates each Solid/Shaky/Rusty so the engine seeds conservative priors. |
| [E12](E12-today-and-recite-grade/EPIC.md) | Today & Recite-Grade Loop | feature | E07, E08, E09, E10, E04 | 9 | The daily front door and core loop: the finite, time-budget-capped Far→Near→New revision list, the reveal-on-tap recite flow with the four-level grade band and optional teacher sign-off, the calm catch-up banner, and calm receipt motion — no celebration. |
| [E13](E13-mushaf-reader/EPIC.md) | Muṣḥaf Reader | feature | E05, E07, E10 | 10 | The immutable muṣḥaf reader: per-page glyph-font rendering, markers as coordinate overlays on the glyph layer, zoom/sepia/dark applied to the rendered layer (never the text), faithful page navigation, and the always-named riwāyah. |
| [E14](E14-mutashabihat-trainer/EPIC.md) | Mutashābihāt Trainer | feature | E04, E05, E13 | 12 | The similar-verse interference subsystem: the scholar-reviewed confusables dataset, discrimination drills presenting whole confusable groups with anchor words highlighted as overlays, the personal confusion log, confusion-aware grading, and interference difficulty bumps. |
| [E15](E15-progress-and-heatmap/EPIC.md) | Progress & Heat-map | feature | E04, E07, E08, E09, E10 | *deferred* | The whole-Quran retention heat-map — the 604-page / 30-juz cluster grid in muṣḥaf order, a calm green-receding-to-neutral ramp (never red), VSUP-muted uncertain pages, and a min-leaning juz roll-up — rendered read-only from streamed engine state; informs, never a streak, score, or scoreboard. |
| [E16](E16-settings-profiles-teacher/EPIC.md) | Settings, Profiles & Teacher Sign-off | feature | E07, E08, E09, E10, E04 | *deferred* | The grouped Settings surface and device-local multi-profile system: the language/calendar/numeral/term-set/theme/muṣḥaf pickers and named cycle-preset controls (display transforms that never perturb a `due_at`), the self/student/child profiles, and the halaqa "switch student → sign off → next" loop — offline, account-free, no microphone. |
| [E17](E17-backup-and-restore/EPIC.md) | Backup & Restore | feature | E03, E07, E10, E16 | *deferred* | The local, offline "never trapped" promise in bytes: the pure-Dart `.hifzbackup` container (magic + version + body SHA-256), the truth-only versioned JSON payload, replace-vs-merge restore as a set-union over the append-only `review_log`, optional Argon2id→ChaCha20-Poly1305 encryption, and the honest no-cloud tradeoff copy — the app never transmits the file. |
| [E18](E18-reminders/EPIC.md) | Reminders | feature | E02, E07, E09, E16 | *deferred* | One calm, opt-in, off-by-default daily local notification — "Your revision for today is ready" — plus an optional framed-as-help catch-up note, as a rebuildable derived cache keyed off the injected local civil day; no guilt/fear/loss/streak framing, no escalation, no push, no server. |
| [E19](E19-science-screen-and-claims/EPIC.md) | Science Screen & Claims | feature | E07, E09, E10, E04 | *deferred* | The offline "The science we follow" screen and the bundled CLAIMS register it renders read-only: each `C-NNN` claim a calm source row with a plain headline, a neutral evidence-certainty label, and a named/dated on-device source — no claim ships unsourced, every `[TRAD]` row names its source and issues no fiqh ruling. |
| [E20](E20-release-readiness/EPIC.md) | Release Readiness | release | E08–E19 | *deferred* | No new feature work — the gate that decides whether the gift may ship: every PRD §20 release-blocking check green in one suite, the airplane-mode acceptance run, the two human sign-offs (scholarly muṣḥaf proof + mutashābihāt review) and the adab checkpoint, the OSS trust pack, and the multi-channel release from one signed, provenance-attested tag. |

**Tasks: 142 task files across E01–E14; E15–E20 are epic-complete with their
per-task files deferred.**

## Dependency graph — build waves

Arrows show the critical edges; the table above is the authoritative full
dependency list. Epics on the same wave can run as parallel workflows.

```
                                  ┌─────┐
Wave 1 · foundation               │ E01 │ repo + workspace + CI guardrails
                                  └──┬──┘
              ┌──────────┬───────────┼───────────────────────┐
              ▼          ▼           ▼                        ▼
Wave 2     ┌─────┐    ┌─────┐     ┌─────┐                  ┌─────┐
parallel   │ E02 │    │ E05 │*    │ E06 │ Mihrab core      │     │
tracks     │dates│    │Quran│     └──┬──┘                  │     │
           └──┬──┘    └──┬──┘        ├──────────────┐      │     │
              ▼          │  *E05 also needs E03      ▼      │     │
Wave 3     ┌─────┐       │        (Wave 3)        ┌─────┐   │     │
           │ E03 │ ◄─────┘ persistence            │ E10 │ Mihrab breadth
           └──┬──┘                                └──┬──┘   (parallel —
              ▼                                      │       anytime after E06)
Wave 4     ┌─────┐  engine (DSR / trust clamp)       │
           │ E04 │                                   │
           └──┬──┘                                   │
              └───────────────┬─────────────────────┘
                              ▼
Wave 5 · skeleton    ┌───────────────────────────┐
                     │ E07   walking skeleton    │  (E02+E03+E04+E05+E06)
                     └─────────────┬─────────────┘
                         ┌─────────┴─────────┐
                         ▼                   ▼
Wave 6 · crosscutting ┌─────┐             ┌─────┐
(parallel)            │ E08 │ a11y        │ E09 │ l10n / RTL (fa·ckb·ar)
                      └──┬──┘             └──┬──┘
                         └─────────┬─────────┘
                                   ▼
Wave 7 · feature root    ┌───────────────────────┐
(parallel breadth)       │ E11   onboarding      │  E12   Today + recite/grade
                         │ E13   muṣḥaf reader   │  (E11 needs E05; E12 needs E04;
                         └───────────┬───────────┘   E13 needs E05+E10)
                                     ▼
Wave 8                            ┌─────┐
                                  │ E14 │ mutashābihāt (needs E04+E05+E13)
                                  └──┬──┘
        ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
        deferred per-task; epics drafted at EPIC.md level
                          ┌──────────┼──────────┐
                          ▼          ▼          ▼
Wave 9 · (parallel)    ┌─────┐    ┌─────┐    ┌─────┐
                       │ E15 │    │ E16 │    │ E19 │  progress ∥ settings/profiles ∥ science
                       └──┬──┘    └──┬──┘    └──┬──┘  (E15→E04; E16→E04; E19→E04)
                          │     ┌────┴────┐      │
                          │     ▼         ▼      │
Wave 10 · (parallel)      │  ┌─────┐   ┌─────┐   │   E17 needs E16;
                          │  │ E17 │   │ E18 │   │   E18 needs E16
                          │  └──┬──┘   └──┬──┘   │
                          └─────┴────┬────┴──────┘
                                     ▼
Wave 11 · release          ┌───────────────┐
                           │      E20      │   release readiness — gates on E08–E19
                           └───────────────┘
```

## Locked scope decisions (v1)

These are settled; epics and tasks must not reopen them.

1. **Free forever — *ṣadaqah jāriyah*.** No price, no IAP, no subscription, no
   ads, no "pro" tier, no donation nag, no upsell, ever. The app is given away
   as a continuing charity; there is no monetization epic and no purchase code
   anywhere in the tree (PRD §16, §17). Optimize for benefit and reach, not
   revenue.
2. **Fully offline — assets downloaded once, then airplane-mode forever.** The
   only network event in the product's life is the one-time core asset-pack
   download during onboarding (and optional later packs), each verified
   fail-closed by per-file SHA-256 against a pinned manifest. After that the app
   opens no socket; every post-onboarding surface works in airplane mode. The
   no-network CI gate proves this structurally (PRD §19.3; → E05, E11, E20).
3. **No AI, no audio recognition, no microphone.** Grading is reveal-on-tap
   self-rating plus on-device teacher (talaqqī) sign-off — never a model, never
   a live call, never speech/audio capture. The word "AI" is not a feature here;
   the microphone permission is never requested (PRD C2, R5; → E04, E12).
4. **Languages fa / ckb / ar — all RTL; Kurmanji dropped.** Persian (fa),
   Kurdish-Sorani (ckb), and Arabic (ar) ship at launch, all right-to-left;
   RTL correctness, logical directions, locale numerals, and bidi safety are
   structural now (E09). Kurmanji (Latin-script Kurdish) is **out of scope** for
   v1. ckb term-sets ship marked provisional pending native review.
5. **Sect-neutral; no bundled tafsīr.** Zero bundled interpretation/tafsīr; the
   muṣḥaf ships byte-exact with its riwāyah named, never a madhhab- or
   sect-specific reading. Methodology and `[TRAD]` claims are surfaced as named,
   dated, graded scholarship issuing no fiqh ruling, with "needs scholarly
   review" shown where a sign-off is pending (PRD §4, R2, R6; → E05, E14, E19).

## Traceability convention

Every level of the plan cites the level above it; nothing is invented at task
time.

- **Epic → PRD.** Each `EPIC.md` traces its scope to PRD sections (e.g.
  "PRD §7.12", "PRD §10.3") and to the relevant `docs/design-system/`,
  `docs/engineering/`, and `docs/science/` files.
- **Task → skills, tokens, decisions, claims.** Each `E##-T##.md` task cites:
  - the **skills** it must follow (`ui-*`, `eng-*`, `domain-*` in
    `.claude/skills/`),
  - the **Mihrab tokens** it consumes (`docs/design-system/`),
  - the **engineering decisions** it implements (`docs/engineering/`),
  - the **CLAIMS `C-###` ids** behind any user-facing number or rule
    (`docs/science/CLAIMS.md`),
  - concrete, verifiable **acceptance criteria** — test-first for anything
    correctness-critical (the engine, the date core, the asset verifier, the
    backup format).
- **Claims → sources.** Every user-facing factual claim follows the
  one-directional chain *verified source → graded claim → CLAIMS row → app copy
  → science screen*. No claim ships without a verified citation and an evidence
  grade; a `[TRAD]` claim names its collection + number + grading and issues no
  ruling. Fabricating or vaguely attributing a source is a product-killing
  error.

## Definition of Done — non-negotiable across all epics

These apply to every epic in addition to its own acceptance criteria. They
outrank every feature: any one, gotten wrong, ends the project.

1. **Offline, provably.** The symbol-level no-network / banned-import grep bans
   and undeclared-dependency checks (E01) stay green. The pure engine and the
   `backup/` package literally cannot open a socket. The only permitted network
   path is the one-time, manifest-pinned asset download; an `HttpOverrides`
   offline guard and the airplane-mode acceptance run (E20) prove every other
   surface works with no network.
2. **No AI, no microphone.** Grading is reveal-on-tap self-rating plus on-device
   teacher sign-off only. No model, no live inference, no audio/speech capture;
   the microphone permission is never requested and the word "AI" never appears
   as a feature claim.
3. **Quran text fidelity.** The Quran text is byte-exact Tanzil verified by
   SHA-256; pages are drawn from KFGQPC per-page glyph fonts via the pre-shaped
   glyph codes (never the OS shaper) on the fixed QUL layout; markers are
   coordinate overlays on the immutable glyph layer (never a re-typeset); the
   riwāyah is always named. The text & asset integrity gate (E01/E20) is
   release-blocking.
4. **Nothing "safe to drop."** The engine may only ever pull a page *forward* —
   the TRUST CLAMP (`due = min(SR-ideal, cycle ceiling)`) never exceeds the
   cycle ceiling, the manzil is never dropped, a lapse always demotes, the
   teacher overrides the machine, and no surface (Today, Progress roll-up,
   science copy) ever tells a ḥāfiẓ a page or juz is safe to forget. Pinned by
   golden vectors and `glados` invariant properties (E04).
5. **No phantom data.** Every stored record is user-initiated, persisted
   immediately in one `db.transaction` (WAL + `synchronous=FULL`,
   persist-before-republish), and auditable; the `review_log` is append-only
   with no `UPDATE`/`DELETE` path; derived health (R/D/S) is never stored.
   Nothing is silently inserted or deleted.
6. **RTL + fa/ckb/ar localization is DoD.** Every user-facing string lands as a
   key in the ARB pipeline with fa/ckb/ar values (key-coverage and Arabic
   six-plural CLDR gates green), logical start/end directions only, FSI/PDI
   bidi-isolated interpolations, per-locale numerals and calendar dates through
   the one presentation boundary. E09 owns the infrastructure; each feature
   epic owns its strings. No religious copy ships without scholarly review.
7. **Accessibility is DoD.** Dynamic text sizing (no fixed font sizes),
   screen-reader labels/values/actions, reduce-motion substitutions, and
   color-never-alone encoding (decay/state carry shape + glyph + label as well
   as hue), with the PR-blocking accessibility audit passing — E08 owns the
   infrastructure, each feature epic owns its own audit.
8. **Sect-neutral adab.** Reverence toward the muṣḥaf; riwāyah stated; zero
   bundled tafsīr; madhhab/sect neutrality; no gamification of worship (no
   streaks, scores, scoreboards, or celebration of revision); no guilt / fear /
   loss copy; servant-to-the-teacher; "needs scholarly review" surfaced where
   pending. The always-on adab/religious-integrity checkpoint (E20) signs this
   off.
9. **Tests are not optional.** Dart/Flutter tests throughout; test-first for
   correctness-critical work; the named suites — engine golden vectors +
   invariant properties, the date 1990–2100 / hostile-timezone sweep, the
   asset & text SHA-256 checks, the backup property suite, the pinned-OS muṣḥaf
   and RTL/locale goldens — are owned by their epics and must stay green;
   coverage is published.
10. **Claims are sourced.** Any new user-facing number, rule, or disclaimer goes
    through the CLAIMS register with a verified citation and a lay
    certainty-about-the-evidence label before it appears in copy; a claim with
    no register row is a release-blocking defect, not a copy nit.
