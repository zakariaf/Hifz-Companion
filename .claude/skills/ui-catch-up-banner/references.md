# references — ui-catch-up-banner

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/design-system/11-voice-and-tone.md` §4 (Lead with empathy when the news is hard) — **The empathy-then-path template** that governs every hard-news string, in order: (1) calm non-blaming acknowledgment, (2) the honest fact, (3) a concrete path, (4) the user's choices. **Missed-day catch-up is the named canonical instance:** *"You missed 3 days — here is a 5-day catch-up plan that still completes your cycle"* — re-spread, never a dump. The visual register must match the verbal one (decay green receding, never a red scoreboard); catch-up banners use `type.body` on a calm surface container with plan numerals in the locale set. Hard news ends in options the user owns (restoration-of-freedom), never one mandated fix, never loss imagery ("you'll lose your hifz").

- `docs/PRD.md` §7.9 (Load balancing & graceful catch-up) — **Missed-day catch-up is a headline feature, not an edge case.** After a gap the engine does **not** dump a red overdue pile; it re-flows the backlog over several days, **most-decayed and prayer-critical first**, and tells the user plainly. **Re-spread, never shame.** FAR/manzil due items are mandatory and never silently dropped; pages may only slip while predicted R stays above a hard floor. The banner *renders* this plan; it never computes it.

- `docs/PRD.md` §12.2 (Today — the core screen) — After a missed gap, Today shows a **gentle catch-up banner with the re-spread plan, never a red shame-pile**; the same surface never silently lets pages rot, and honest budget feedback offers raise budget / lengthen cycle / pause new sabaq as the user's choices.

## Supporting

- `docs/design-system/11-voice-and-tone.md` §3 (Tone-by-context matrix) — The **Missed days / catch-up** row: tone = *empathy first, then a concrete plan and choice* — "You missed 3 days. Here is a 5-day catch-up that still completes your cycle." Never "You're behind", "N days lost", or a red overdue pile. The **Resume-after-a-gap** row: resume silently into the normal day; the "Welcome back! You haven't opened the app in N days" greeting is forbidden. Anti-patterns: never a broken-streak state, never cheerful resumption that implies the user lapsed.

- `docs/design-system/11-voice-and-tone.md` §2 (The four voice attributes) — Every string is **reverent, calm, plain-and-warm, honest**; calm = no urgency the data doesn't warrant, no exclamation marks, no alarm styling, no saturated warning fill; honest = nothing is ever "safe to drop"/"mastered". Numerals always render in the locale set (`type.numeral`), never raw ASCII concatenated into a string.

- `docs/design-system/11-voice-and-tone.md` §6 (Invitation and information, never command) — The mandate words **"you must / have to / should / don't"** and scolding imperatives are banned from product copy (they provoke reactance). Use statements of readiness and provision of choice; append restoration-of-freedom where a setting affects the schedule.

- `docs/design-system/11-voice-and-tone.md` §9 (Tone is a per-locale QA gate) — The **never-ship banned-phrase lint** (release-blocking, run on every locale) blocks guilt/fear/loss framing ("You'll lose your hifz", "You're falling behind", "You haven't opened the app in N days", "Don't break your streak"), controlling mandates, "safe to drop"/"mastered", and exclamation marks/emoji. Plus per-locale native + scholar review.

- `docs/design-system/11-voice-and-tone.md` §8 (One voice across fa/ar/ckb — transcreation) — Transcreate, don't literally translate; **soften the Arabic imperative into a statement of readiness**, set Persian to warm-respectful, treat ckb register + religious vocabulary as native-reviewer-set placeholders. Mechanics that protect tone: locale numerals via `intl`, mixed Latin/numeral runs wrapped in bidi isolation (FSI/PDI), sentence fragments never glued.

- `docs/design-system/08-data-visualization.md` §3 (Decay is made visible, never alarming) — Any decay the plan references is encoded as the green ramp **receding to a desaturated muted neutral** (`color.heatmap.weak` → `color.heatmap.faded`), **never an alarming red scoreboard**; never frame decay as loss ("you are losing your Quran") to wring out short-term effort.

- `docs/design-system/06-motion-and-haptics.md` §2 (Motion never celebrates) — **No celebratory motion anywhere**: no confetti/fanfare/reward tier on accepting or completing a catch-up plan; milestones are acknowledged by copy + a `motion.duration.short` fade, factual not fanfare.

- `docs/design-system/06-motion-and-haptics.md` §1 (Calm, informative motion) — Routine UI uses the **short/medium duration ladder with standard easing** (`motion.duration.short` = 150ms, `motion.curve.standard`); no spring/overshoot; every animation resolves to a `motion.*` token, never a hardcoded `Duration`/`Curve`.

- `docs/design-system/06-motion-and-haptics.md` §4 (The tiny, light, meaning-bearing haptic vocabulary) — Exactly three pulses; use **`haptic.confirm` (`lightImpact`) when an action commits** (starting/accepting the plan), always paired with an on-screen change and OS-gated. **No "success/reward" haptic**, and never use a haptic to manufacture urgency or guilt for a missed day.

- `docs/design-system/07-components.md` §1 (The daily-session list) — The catch-up banner is the list's **`catch-up` state**: after missed days, a gentle banner offering the re-spread plan, **never a red overdue pile**; the list otherwise renders on calm `surfaceContainer*` surfaces. Anti-pattern: "Render a red shame-pile after missed days instead of the calm catch-up plan."

- `docs/PRD.md` §14 (Notifications, local only) — The **optional "catch-up ready" note** after missed days is framed as **help, not blame**, fully optional and easily silenced, with no nagging escalation; local notifications only (no push, no server).

- `docs/design-system/10-privacy-and-trust-ux.md` §(post-gap note) — After missed days, the "catch-up ready" note is framed as help, not blame — the trust-UX restatement of the same rule.

## Sibling skills

- **ui-daily-session-list** — the Today list this banner is a *state* of (its loading/populated/all-done states, its localized Far→Near→New sections, and the honest budget-feedback line that shares this banner's autonomy-support).
- **domain-scheduling-engine-rules** — the catch-up **re-spread algorithm** that produces the plan (most-decayed/prayer-critical first, FAR/manzil mandatory, the hard-R floor, the cycle ceiling). This skill renders the plan; that skill computes it.
- **ui-page-card** — the page-card rows the re-spread plan is made of (track chip, decay indicator, localized page/juz headline).
- **ui-recite-grade-flow** — the reveal-on-tap + four-level grade band + teacher sign-off the rows tap into.
- **domain-calendars-and-hifzdate** — the elapsed-day "N days missed" count (DST/timezone-safe) and the injected "today"; never `DateTime.now()`.
- **eng-define-service-boundary** — the local-notification "catch-up ready" note and the injected clock as Riverpod-overridden dependencies.
- **eng-create-riverpod-store** — the StreamProvider read model + single-write-path controller that hands this View its pre-built `CatchUpPlan`.
- **eng-add-feature-module** — where the Today feature/View (and this banner) live.
- **eng-rtl-and-bidi-layout** — the FSI/PDI bidi-isolation and directional mirroring for the locale-numeral counts.
- **domain-adab-and-religious-integrity** — the always-on conscience-check on every word, decay framing, term-set, and the "safe to drop" / guilt prohibitions.
