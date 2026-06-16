# Hifz Companion — Project Contract

Hifz Companion is a **free** (built as *ṣadaqah jāriyah*, the zakat of knowledge), open-source, **fully offline**, no-account, **no-AI** Flutter app (Dart, Riverpod, Drift/SQLite, a pure-Dart engine) that helps huffaz and serious students **retain** the Quran across all 30 juz. The audience is maximally reverent and conservative — huffaz, teachers, and ulama who **will scrutinise this**. A single wrong diacritic in the muṣḥaf, a sectarian slip, a gamified sacred surface, or a fabricated citation is reputation-ending. Built for the sake of Allah, so *iḥsān* — excellence — is the bar, not "good enough because it's free".

This file is a **non-negotiable contract**. Everything below binds every session, every agent, every PR. It is deliberately short: it points at the governing documents instead of repeating them. When this file and a doc conflict, the doc wins; when docs conflict with each other, stop and surface it — never pick silently.

## Source of truth (read before you write)

| Layer | Where | What it governs |
|---|---|---|
| Product | `docs/PRD.md` | What ships and why — one complete free/offline version, not an MVP |
| Deep research | `research/RESEARCH-FINDINGS.md` | The evidence base the whole product rests on |
| Design system "Mihrab" | `docs/design-system/` (13 docs + README + REFERENCES + `research/`) | Tokens, components, color/type/spacing/motion, data-viz (the retention heat-map), a11y, privacy UX, voice & tone, localization/RTL, Islamic identity & adab |
| Engineering | `docs/engineering/` (13 docs; **the tech-decision log is in its README**) | Architecture, packages, persistence, **the scheduling engine**, dates/calendars, immutable Quran rendering, asset packs, backup, testing, CI, OSS release |
| Science | `docs/science/` (11 docs; **`CLAIMS.md` = every user-facing claim, graded `[MA]/[RCT]/[EXP]/[CS]/[OBS]/[TEXT]/[TRAD]` + sourced**) | Every number, rule, and methodology claim the app shows users |
| Skills | `.claude/skills/` (40 skills, see its README) | The HOW for every recurring pattern — they auto-load; follow them |
| Build plan | `epics/` (20 epics E01–E20; E01–E14 have task files, **E15–E20 drafted**; canonical index: `epics/README.md`) | What to build, in what order |

**Do not re-litigate locked decisions** (the engineering tech-decision log, the Mihrab tokens, the scope locks below). Propose changes as explicit amendments with rationale — never drift.

## Religious & user-facing non-negotiables (these outrank every feature)

1. **Quran text fidelity is existential.** Byte-exact Tanzil Uthmani text + a CI SHA-256 checksum that fails the build on any change; render **only** via bundled **KFGQPC QPC per-page glyph fonts** (never the OS text shaper); layout from the fixed QUL dataset (never recomputed); markers drawn as coordinate overlays on the immutable glyph layer (never re-typeset); CI visual-diff vs reference muṣḥaf. (`domain-mushaf-text-integrity`)
2. **Sect/madhhab neutrality.** The riwāyah is stated explicitly in-app ("Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"), never "the Quran" in the absolute; the muṣḥaf is a swappable asset; **ZERO bundled tafsīr/translation**; the mutashābihāt dataset is scholar-reviewed and scoped to objective near-identical wording only.
3. **No gamification of worship.** No streaks, badges, XP, scores, leaderboards, or confetti on sacred content; **no guilt/fear/loss notifications**; the register is calm loss-prevention and peace of mind. (`domain-adab-and-religious-integrity`)
4. **Nothing decays silently; never "safe to drop".** The engine may pull a weak page *forward*, never push it past its cycle ceiling, and is **forbidden** from ever telling a ḥāfiẓ a page is safe to stop revising; manzil is un-skippable.
5. **Servant to the teacher.** Teacher (talaqqī) sign-off is a first-class grade that **overrides** the machine; the app aids, never replaces, oral correction and the *sanad* chain; it issues **no fiqh rulings**.
6. **Privacy, and no microphone — ever.** No account, no telemetry, on-device only; grading is human (reveal-on-tap self-rating + on-device teacher), **never audio, never AI/ASR** — which also protects women's-audio privacy by construction.
7. **Every user-facing factual claim traces to `docs/science/CLAIMS.md`** with a verified source + grade; `[TRAD]` (methodology/religious) claims name their source and issue no ruling. **Fabricating or misattributing a citation is a product-killing error** — these sources are shown to users in the offline "The science we follow" screen. (`domain-claims-register-and-science-screen`)

## Engineering non-negotiables

8. **Offline after one-time setup.** The **only** permitted network use is the one-time asset-pack download from the public GitHub Releases repo (per-file SHA-256, **fail-closed** — unverified Quran assets are refused). No backend, no accounts, no telemetry, no analytics/ads SDKs — CI bans them at the symbol level. After setup the app runs in airplane mode forever. (`domain-asset-pack-integrity`)
9. **Date math only via `CalendarDate`** (integer serial days; the injected "today"; no `DateTime` instants for scheduling days). Hijri (Umm al-Qurā) / Solar-Hijri Jalālī / Gregorian are **display-only** and never feed math, scheduling, or storage. (`domain-calendars-and-hifzdate`)
10. **Persist-on-every-change.** Every mutation goes through the single write path (a repository): transactional commit **before** republishing in-memory state; Drift/SQLite WAL + `synchronous=FULL`; the `review_log` is **append-only** (no UPDATE/DELETE). Crash-safe always.
11. **The scheduling engine stays pure and deterministic.** The `engine` package imports models only — no Flutter, no I/O, no `DateTime.now()`, no randomness. The **TRUST CLAMP** (`due = min(SR-ideal, cycle ceiling)`) and every PRD §7.12 invariant (manzil never dropped, a lapse demotes, teacher overrides, never "safe to drop") are pinned by **frozen golden vectors + property tests**. (`domain-scheduling-engine-rules`, `eng-write-engine-golden-vector`)
12. **Mihrab tokens by name only.** Color/type/space/motion come from the Mihrab theme tokens; a raw hex/px/ms/duration in app code is a lint failure. Token values are owned by design docs 03–06.
13. **Grading is human — no AI, no audio.** Reveal-on-tap self-rating + on-device teacher sign-off normalise to one `(grade, error_lines, source)` signal with per-source confidence; the sacred-text guard means a dropped/altered word is never "Good"; teacher always overrides. No microphone, no model. (`domain-grading-pipeline`)
14. **The `.hifzbackup` format.** A local, offline file the user saves anywhere — no cloud, no account; versioned + integrity-checked; restore validates fully before touching the live DB; teacher↔student merge is set-union over the append-only `review_log`; round-trip tests are release gates; changes only via the `domain-backup-format` skill.
15. **Tests are not optional.** `package:test` / `flutter_test` / `integration_test`; correctness-critical work (engine, dates, persistence, backup, muṣḥaf rendering) is **test-first**; engine golden vectors + `glados` invariants; migrations are versioned step-by-step; RTL + muṣḥaf goldens on the real bundled fonts.
16. **Every UI deliverable ships fa / ckb / ar** (Arabic ARB base), is accessible (dynamic text, screen reader, reduce-motion, **never color alone**), and **RTL-correct** (logical insets, the mirror policy, FSI/PDI isolation, locale numerals ۰۱۲ / ٠١٢). **Religious copy is never shipped without scholarly review.** (`eng-add-localized-string`, `eng-rtl-and-bidi-layout`)
17. **Dependency minimalism.** The approved third-party set lives in the engineering tech-decision log; anything new requires a written decision-log amendment.

## Scope locks (decided — do not reopen casually)

**Free *ṣadaqah* — NO monetization, ever** (no ads, no IAP, no subscription; the Quran is never paywalled) · fully offline, assets downloaded once · **NO AI / no audio recognition** · languages **fa / ckb / ar, all RTL** (Persian primary; **Kurmanji dropped**) · local multi-profile (self / students / child) — no cloud, no account, no server; sharing is via file export/import · muṣḥaf: **Ḥafṣ Madani 15-line** default, swappable (Warsh roadmapped before West Africa) · build plan currently **E01–E14** (E15–E20 drafted, task files deferred) · open-source (license TBD: GPL/AGPL for code, CC-BY for the Quran-data repo) · a **named scholar endorsement is a launch gate** for the traditional segment.

## How to work

- **Implementing?** Find the task file in `epics/E##-*/E##-T##-*.md` and follow it — it names its skills, tokens, decisions, CLAIMS ids, acceptance criteria, and tests. Build in epic order; respect `Depends on`.
- **Skills are binding, not advisory.** When a skill matches the work (they auto-load by trigger), its checklist is part of Definition of Done.
- **Never invent** a token, API, package, skill name, CLAIMS id, hadith, or citation. If it's not in the docs, point at the doc or leave a marked TODO — guessing is the failure mode this entire foundation exists to prevent.
- **Surgical changes only.** Touch what the task names; match existing style; every changed line traces to the task.
- **When unsure about a religious or methodology point, stop and flag it for scholarly review** — never improvise fiqh, grade a hadith, or soften a non-negotiable.

*Taqabbal Allāhu minnā wa minkum.*
