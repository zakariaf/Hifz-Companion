# references — domain-adab-and-religious-integrity

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it. This skill is the always-on conscience check, so its primary source is the release-blocking R-series; the design-system and science docs supply the *why* and the concrete wording.

## Primary — the non-negotiables (release-blocking)

- `docs/PRD.md` §4 R1 (Text fidelity is existential) — Quran text byte-for-byte unmodified (Tanzil, CC BY 3.0), SHA-256 gated in CI, rendered **only** through bundled KFGQPC per-page glyph fonts (never the OS shaper), layout from the fixed dataset (never recomputed), markers as overlays on the immutable glyph layer — **a single wrong diacritic ends the project.**
- `docs/PRD.md` §4 R2 (State the riwāyah; stay neutral) — show **"Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf,"** never "the Quran" absolutely; muṣḥaf is a swappable asset; **zero bundled tafsīr/translation/commentary** — it inevitably encodes a school of thought.
- `docs/PRD.md` §4 R3 (No gamification of the sacred) — no leaderboards/XP/badges-on-āyāt/confetti; **no guilt or fear notifications** ("Your revision for today is ready," never "You'll lose your hifz"); progress is a calm heat-map, not a punishable streak.
- `docs/PRD.md` §4 R5 (Privacy is part of religious trust) — fully offline, no account/telemetry/data-egress; **the app never records audio** (no microphone — also protects women's privacy by construction).
- `docs/PRD.md` §4 R6 (Servant to the talaqqī chain) — teacher sign-off is a first-class grade that **overrides** any self-rating or algorithmic state; the app is an aid to revision, never a replacement for oral correction or the *sanad* chain.
- `docs/PRD.md` §7.12 (Engine invariants) — the engine **never** displays or implies a page is "safe to stop revising"; a teacher sign-off always supersedes self-rating and algorithmic state. The honesty contract, in code.
- `docs/PRD.md` C6 (No gamification of worship) and §1 (Hard Constraints) — no leaderboards/XP/badges/confetti/guilt nags; framing is calm loss-prevention and peace of mind. The hard-constraint root of R3.

## Supporting — adab synthesis (the *why* and the visual/identity rules)

- `docs/design-system/13-islamic-identity-and-adab.md` §1 (page is the unit of reverence) — render faithfully through per-page glyph fonts; never re-typeset; markers are coordinate overlays; the muṣḥaf fonts are immutable assets, **not** styleable tokens.
- `docs/design-system/13-islamic-identity-and-adab.md` §2 (reverence in intent, not device gating) — **never** gate the muṣḥaf/revision behind wuḍūʾ, a pledge, or a ritual checkpoint; an optional, dismissible reverent framing is allowed; etiquette is attributed methodology, never a ruling.
- `docs/design-system/13-islamic-identity-and-adab.md` §3 (never decorate the sacred text) — the reader is "no dashboard"; markers are diagnostic, never congratulatory; no flip sound/gilt border/glow over the glyphs; honorifics + correct transliteration are the *one* adab "decoration."
- `docs/design-system/13-islamic-identity-and-adab.md` §4 (never gamify worship) — extrinsic rewards corrode intrinsic worship motivation (Deci, Koestner & Ryan 1999); replace the whole reward apparatus with honest competence feedback (the heat-map, green receding to neutral, min-leaning aggregate); no broken-streak shame anywhere.
- `docs/design-system/13-islamic-identity-and-adab.md` §5 (state the riwāyah, attribute, stay neutral) — name the transmission; attribute Tanzil/QUL/KFGQPC (license obligation); ship no tafsīr/translation/commentary; Quran text identical across locales.
- `docs/design-system/13-islamic-identity-and-adab.md` §6 (servant to the teacher and the sanad) — teacher sign-off overrides the machine; never issue a fiqh ruling, never speak *for* the Quran, never build a remote teacher-surveillance dashboard; flag "needs scholarly review" where pending.
- `docs/design-system/13-islamic-identity-and-adab.md` §7 (aniconic restraint — the *miḥrāb*, not the mascot) — identity is quiet geometry, calligraphic restraint, a low-arousal green palette; never figurative mascots, cartoon Qurans, neon, or "Islamic-themed" clip-art.

## Supporting — voice and tone (the concrete wording rules)

- `docs/design-system/11-voice-and-tone.md` §1 (adab is the governing concept) — gentleness (*al-rifq*) is the **top** constraint; the adab gate is the first step of copy review, ahead of clarity and brevity, and is release-blocking.
- `docs/design-system/11-voice-and-tone.md` §2 (four fixed voice attributes) — every string is **reverent, calm, plain-and-warm, honest**; no exclamation marks, no emoji in product copy; numerals in the locale set via `intl`/`type.numeral`.
- `docs/design-system/11-voice-and-tone.md` §3 (tone-by-context matrix) — the voice is constant, only warmth/density flex; clean recite = quiet confirmation (no praise theatre); lapse = matter-of-fact, no blame; never a "Welcome back!" that implies a lapse.
- `docs/design-system/11-voice-and-tone.md` §4 (lead with empathy on hard news) — the empathy → fact → path → choice template; budget honesty surfaces three equal choices (raise budget / lengthen cycle / pause new sabaq); never use the spiritual stakes as leverage.
- `docs/design-system/11-voice-and-tone.md` §5 (speak as a teacher's aide, never *for* the Quran) — never say "safe to drop"/"mastered"; no rulings; credit the teacher ("Recorded with your teacher's sign-off"), never the app ("Approved").
- `docs/design-system/11-voice-and-tone.md` §6 (invitation, never command) — ban "must / have to / should / don't" and scolding imperatives; restoration-of-freedom by default; provide choices, never mandate one fix.
- `docs/design-system/11-voice-and-tone.md` §7 (no transactional/pressuring framing) — no "upgrade/premium/unlock," no urgency/scarcity/FOMO/streak-pressure; the app is free as *ṣadaqah jāriyah*, so there is nothing to sell.
- `docs/design-system/11-voice-and-tone.md` §8 (one voice across fa/ar/ckb via transcreation) — strings are transcreated against one voice charter, not literally translated; per-locale register set deliberately; Arabic imperatives softened into statements of readiness; Sorani register/vocabulary pending native review.
- `docs/design-system/11-voice-and-tone.md` §9 (tone is a per-locale QA gate) — the never-ship banned-phrase lint (release-blocking, every locale) + native-speaker register review + scholar review of religious terminology; zero missing ARB keys, zero hardcoded user-facing strings.

## Supporting — traditional methodology (the methodology/claim guardrails)

- `docs/science/10-traditional-hifz-methodology.md` §6 (the decay axiom) — the Quran "escapes faster than camels" (Bukhārī 5032; Muslim 791); forgetting is inevitable, so the engine may never tell a ḥāfiẓ a page is finished — and the warning is **never** used to frighten.
- `docs/science/10-traditional-hifz-methodology.md` §8 (talaqqī & the sanad) — correctness is judged by a qualified human ear; teacher sign-off overrides; **no microphone, no ASR, no machine mistake-detection** — that would arrogate the teacher's role.
- `docs/science/10-traditional-hifz-methodology.md` §9 (one skeleton, regional vocabulary) — labels are swappable string resources; the app surfaces methodology, names its sources, stays madhhab/sect-neutral, and **issues no ruling** about which regional method is "correct."
- `docs/science/10-traditional-hifz-methodology.md` §10 + "A note on honesty" — near-100% comes from overlearning + the cycle ceiling, never a promised "99%"; the [TRAD] half documents what the tradition does and never claims religious authority; where a claim needs a scholar, it says so plainly.

## Sibling skills

- **domain-mushaf-text-integrity** — enforces R1 in code: byte-exact Tanzil text + SHA-256, KFGQPC per-page glyph fonts (never the OS shaper), layout from the fixed QUL dataset, markers as overlays. This skill is the adab *around* that mechanism.
- **domain-asset-pack-integrity** — enforces the R5/C1 covenant: the one-time HTTPS download, the fail-closed per-file SHA-256 verifier, no telemetry, no per-user data egress, airplane-mode forever.
- **domain-scheduling-engine-rules** — owns the "never safe to drop" engine invariant, the trust clamp, and stakes-tiered retention; this skill keeps the surrounding copy honest and non-coercive.
- **domain-grading-pipeline** — owns the talaqqī-overrides-the-machine rule, per-source confidence, and the sacred-text grade guard (a dropped/altered word is never "Good").
- **domain-mutashabihat-system** — owns the scholar-reviewed, objective-wording-only confusables dataset and the discrimination drills; this skill is the neutrality + scholar-review obligation behind it.
