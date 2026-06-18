# references — ui-empty-state

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/design-system/11-voice-and-tone.md` §3 (Tone-by-context matrix) — **the load-bearing section.** The *Resume after a gap* row: resume **silently into the normal day**; "Welcome back! You haven't opened the app in N days." is in the **Never** column. The *Daily session ready* and *Clean recite logged* rows model the calm-neutral register an empty/all-done surface uses. The Anti-patterns forbid greeting a returning user with cheerful resumption that implies they lapsed, and forbid a red overdue pile / broken-streak after missed days. Take: the welcome-back face is the *absence* of a reproach; choose the calm-neutral register, not the hard-news one.

- `docs/design-system/11-voice-and-tone.md` §2 (The four fixed voice attributes) — every empty-state string must be **reverent, calm, plain-and-warm, honest**; sentence case, no exclamation marks, no emoji, key fact first then the option then stop, buttons are verbs in the locale's idiom. Take: the four attributes are the voice every empty-state line passes before anything else.

- `docs/design-system/11-voice-and-tone.md` §6 (Phrase as invitation and information, never command) — first-run copy uses **statements of readiness over orders** ("Your revision will appear here" not "Start revising"); banned mandate words ("you must / have to / should / don't"); restoration-of-freedom by default. Take: a first-run next step is a gentle invitation, never a command.

- `docs/design-system/11-voice-and-tone.md` §4 (Lead with empathy when the news is hard) — the **empathy-then-path** template (acknowledge → fact → path → choice) governs **hard-news** strings only (decay, backlog, lapse, budget). Take: a *pure* empty state has no hard news, so it does NOT manufacture this template — that register is the catch-up banner's, not the empty state's.

- `docs/design-system/07-components.md` §1 (The daily-session list) — In practice: the **all-done** state is "a calm closing surface … informational, never a confetti/celebration moment, per Pillar 2," in `color.text.secondary`; the *catch-up* state (after missed days) is the sibling banner, never a red overdue pile. Anti-patterns: never celebrate all-done with confetti/streak/badge/exclamation; the list is finite, capped, and ends. Take: the all-done terminal surface is calm and informational, never a celebration.

## Supporting

- `docs/design-system/11-voice-and-tone.md` §7 (No transactional or pressuring framing) — no manufactured urgency, scarcity, FOMO, streak-pressure, or commercial-transaction language ("upgrade / premium / unlock"); the app is free as ṣadaqah jāriyah. Take: an empty Today is never an engagement prompt.

- `docs/design-system/11-voice-and-tone.md` §9 (Tone is a per-locale QA gate) — the **never-ship banned-phrase lint** (release-blocking, run on every locale) blocks guilt/fear/loss ("you haven't opened the app in N days", "you're falling behind", "don't break your streak"), controlling mandates, "safe to drop"/"mastered"/"done", exclamation marks/emoji, and commercial-transaction words; native + scholar review per locale. Take: the forbidden phrases are a build failure, not a style note.

- `docs/design-system/11-voice-and-tone.md` §8 (One voice across fa/ar/ckb — transcreation) — strings are **transcreated** against the one voice charter, not literally translated; Arabic imperatives softened into statements of readiness, Persian warm-respectful, ckb pending review; locale numerals via `intl` (never concatenated), mixed runs wrapped in FSI/PDI bidi isolation. Take: transcreate, don't translate; isolate mixed runs; format numerals per locale.

- `docs/design-system/06-motion-and-haptics.md` §2 (Motion) — **no celebratory motion anywhere**; milestones (including reaching all-done) acknowledged by copy + a `motion.duration.short` fade with standard easing; reduce-motion honoured. Take: no confetti/fanfare/streak-repair on empty or all-done.

- `docs/design-system/06-motion-and-haptics.md` §4 (Haptics) — the small meaning-bearing vocabulary; `haptic.confirm` (`lightImpact`) on a commit, always paired with a visual change, OS-gated; **no success/reward haptic**, and never a haptic to manufacture guilt for a gap. Take: only `haptic.confirm` on a gentle commit; never a reward or nag pulse.

- `docs/PRD.md` §12.2 (Today, the core screen) — the list is **finite, capped**, grouped Far→Near→New, with a calm catch-up banner after a gap (never a red shame-pile) and honest budget feedback; it resumes calmly. Take: the all-done / nothing-due / resume faces are states of this finite Today screen.

- `docs/PRD.md` §13.4 (regional term-sets) — sabaq/sabqi/manzil and cycle vocabulary is **regional and swappable**; ckb terminology is pending native + scholarly review. Take: any track/cycle term an empty-state names comes from the localized term-set, never hardcoded English.

- `docs/PRD.md` §13.2 / §13.3 (RTL layout; numerals & calendars) — `Directionality.rtl` app-wide, logical start/end insets, mirror directional widgets; numerals in the locale set (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) via `intl`, never concatenated ASCII; mixed runs bidi-isolated. Take: RTL by geometry and locale numerals are non-negotiable on every surface, including the empty ones.

## Sibling skills

- **ui-catch-up-banner** — the empathy→fact→plan→choice missed-day re-spread surface; the *other* return-after-gap face, used **only when there is a backlog to offer help with**. If there's a plan, it's a catch-up banner; if there's nothing to catch up, it's a silent resume (this skill).
- **ui-daily-session-list** — the finite Far→Near→New Today list whose all-done / silent-resume states this skill frames; owns the loading/populated states and the honest budget-feedback line.
- **ui-cold-start-placement** — the first-day onboarding (coverage capture, per-juz Solid/Shaky/Rusty, "when memorized", bundled-core setup) the first-run invitation leads into.
- **ui-retention-heatmap** — the Progress surface and its own pre-data state, for the first-run face on Progress.
- **eng-add-localized-string** — the transcreated ARB pipeline (fa/ckb/ar) for every empty-state string, plurals, and locale numerals.
- **eng-create-riverpod-store** — the StreamProvider + single-write-path controller that produces the pre-built empty/all-done/resume read model this dumb View renders.
- **eng-add-feature-module** — where the feature/View that hosts the empty state lives.
- **eng-rtl-and-bidi-layout** — the FSI/PDI bidi-isolation and mirroring policy for any locale-numeral count in the copy.
- **domain-adab-and-religious-integrity** — the always-on conscience-check: the no-guilt / no-fear / no-"safe to drop" / servant-to-the-teacher floor every empty-state word must clear.
