---
name: ui-empty-state
description: Build or modify the Hifz app's empty / first-run / return-after-gap states — the welcoming first day, the calm all-done terminal surface, and the neutral silent welcome-back after a gap. Use whenever building an empty state, a first-run / zero-data screen, an "all caught up" / nothing-due surface, or any return-after-gap view, so the copy is calm and non-shaming with no "you haven't logged" / "you're behind" guilt and no cheerful "Welcome back!" greeting.
---

# ui-empty-state

The empty, first-run, and return-after-gap faces of the app: the **welcoming first day** before any review exists, the calm **all-done / nothing-due** terminal surface, and the **neutral silent welcome-back** when a ḥāfiẓ reopens the app after a gap. Each is a low-arousal, non-shaming surface that states the calm fact and a single gentle next step — never a guilt nag ("you haven't logged"), never a "you're behind" scold, never a cheerful "Welcome back! You haven't opened the app in N days," never a confetti celebration of "all done."

An empty state is a *state* of a screen, not a screen of its own; it composes the controller's already-computed "nothing here yet / nothing due today" read model. It never invents urgency where the data has none, and it never frames the absence of data as the user's failure.

## When to use

Use when building or placing:
- a **first-run / zero-data** surface (before any review exists — Today, Progress, Mutashābihāt, profiles all have a first-run face)
- the calm **all-done / nothing-due** terminal surface on Today (the finite list reached its end, the day is complete)
- the **neutral silent welcome-back** when the app is reopened after a gap *and there is nothing to catch up on*
- any **empty-list / no-content-yet** placeholder copy + a single gentle next step

Do NOT use this skill for:
- the **missed-day catch-up banner** — the empathy→fact→plan→choice re-spread surface shown after a gap *when there is a backlog to offer help with* → use **ui-catch-up-banner**
- the Today **daily-session list** itself (the finite Far→Near→New queue, its loading/populated states, the honest budget-feedback line) → use **ui-daily-session-list**
- the **first-day onboarding / cold-start placement** flow (coverage capture, per-juz Solid/Shaky/Rusty, "when memorized", bundled-core setup) → use **ui-cold-start-placement**
- the **whole-Quran retention heat-map** and its own pre-data state on Progress → use **ui-retention-heatmap**
- the actual **localized-string** authoring (ARB keys, transcreation, plurals) → use **eng-add-localized-string**
- the controller / StreamProvider / single-write-path wiring behind this View → use **eng-create-riverpod-store** and **eng-add-feature-module**

The empty state is the *calm face of absence*; the catch-up banner is the *calm face of a backlog*. If there is a re-spread plan to offer, it is a catch-up banner, not an empty state. An empty state that greets the gap, shows a streak, counts missed days, or celebrates completion is the wrong component.

## The canonical pattern

1. **Resume silently into the normal day — never greet the gap.** When the app is reopened after a gap and there is nothing to catch up on, it resumes into the ordinary Today screen with no special greeting; the welcome-back face is the *absence* of a reproach, not a cheerful banner. The "Welcome back! You haven't opened the app in N days" greeting is explicitly forbidden. `docs/design-system/11-voice-and-tone.md` §3 (the Resume-after-a-gap tone row: *resume silently into the normal day*; the example "Welcome back! You haven't opened the app in N days." is in the **Never** column) and §3 Anti-patterns (never greet a returning user with cheerful resumption that implies they lapsed). The empathy-then-path catch-up surface is the *other* sibling — **ui-catch-up-banner** — and applies only when a backlog exists.

2. **The all-done state is calm and informational — never a celebration.** When the finite, capped Today list reaches its end, the terminal surface is a quiet closing line (e.g. "Today's revision is complete") in `color.text.secondary` — informational, never a confetti / streak-increment / badge / exclamation-mark moment. `docs/design-system/07-components.md` §1 In practice (the *all-done* state is "a calm closing surface … informational, never a confetti/celebration moment, per Pillar 2") and §1 Anti-patterns (never celebrate the all-done state with confetti, a streak increment, a badge, or an exclamation mark). No celebratory motion exists in the app: acknowledge with copy + a `motion.duration.short` fade only, per `docs/design-system/06-motion-and-haptics.md`.

3. **First-run states orient and invite — they never shame an absence.** A first-run / zero-data surface states the calm fact (nothing here yet) and offers one gentle next step (e.g. "Mark which juz you hold to begin" → cold-start, or "Your revision will appear here once you begin"), framed as invitation and information, never as a deficiency. `docs/design-system/11-voice-and-tone.md` §6 (phrase as invitation and information, never command — *statements of readiness over orders*) and §2 (the four fixed voice attributes: reverent, calm, plain-and-warm, honest). The next step *into* onboarding/cold-start is owned by **ui-cold-start-placement**; this surface only frames the calm invitation to it.

4. **Voice: reverent, calm, plain-and-warm, honest — no guilt / fear / loss, no command.** Every string passes the four fixed voice attributes and is autonomy-supportive. No mandate words ("you must / have to / should / don't"), no guilt/fear/loss framing ("you haven't logged", "you're behind", "you're falling behind", "you haven't opened the app in N days", "don't break your streak"), no "safe to drop" / "mastered" / "done with". `docs/design-system/11-voice-and-tone.md` §2 (the four voice attributes), §6 (banned mandate words), §3 Anti-patterns and §9 (the **never-ship banned-phrase lint** — guilt/fear/loss, "you're behind", "you haven't opened the app in N days", "don't break your streak", controlling mandates, "safe to drop"/"mastered"/"done", exclamation marks and emoji in product copy — release-blocking).

5. **Lead with empathy if the absence touches hard news; otherwise stay plainly neutral.** A pure empty state (first run, nothing-yet) is a calm neutral statement; it does *not* manufacture the empathy-then-path template, because there is no hard news. The empathy-then-path template (acknowledge → fact → path → choice) belongs to the *backlog* surface, not to a neutral resume or first run. `docs/design-system/11-voice-and-tone.md` §4 (the empathy-then-path template governs **hard-news** strings — decay, backlog, lapse, budget) and §3 (the tone-by-context matrix — only the hard-news rows lead with empathy; readiness/resume rows are calm-neutral). Choosing the wrong register (manufacturing concern where there is none) is itself a tone failure.

6. **No transactional or pressuring framing — worship is served, never managed.** An empty state never becomes an engagement prompt: no "come back tomorrow", no streak-at-risk, no manufactured urgency, no "upgrade / premium / unlock", no FOMO. The app is free as ṣadaqah jāriyah; an empty Today is simply an empty Today. `docs/design-system/11-voice-and-tone.md` §7 (no transactional or pressuring framing — no manufactured urgency, scarcity, FOMO, streak-pressure, or commercial-transaction language) and §7 Anti-patterns (never frame revision as a debt to the app, never measure the user against an engagement target).

7. **Calm visual register — a quiet surface, never an alarm, never a hero illustration that performs.** Render on a low-elevation surface (`surface` / a Level 0–1 `surfaceContainer`), copy in `type.body`/`type.caption` with secondary text color, plenty of breathing room on the `space.*` grid; no saturated warning fill, no red, no decorative mascot or celebratory art. `docs/design-system/07-components.md` (Global intent — Pillar 2 *calm, not cute*: no component is a gamification surface; cards/surfaces sit flat at Level 0–1) and the §1 *all-done* surface (calm, `color.text.secondary`). Tokens are referenced by name only; concrete values live in `03-color-and-themes.md` / `04-typography.md` / `05-layout-spacing-touch.md`.

8. **No celebration choreography, no reward haptic.** Reaching an empty/all-done state fires no confetti, no fanfare, no "well done", no streak-repair animation, no success haptic. If a single gentle action exists (e.g. "begin"), a commit fires only `haptic.confirm` (`lightImpact`) paired with the on-screen change, OS-gated — never a reward pulse for "finishing". `docs/design-system/06-motion-and-haptics.md` §2 (no celebratory motion anywhere — milestones acknowledged by copy + a `motion.duration.short` fade) and §4 (the small meaning-bearing haptic vocabulary; `haptic.confirm` on commit; **no success/reward haptic**, never a haptic to manufacture guilt).

9. **RTL by geometry; locale numerals; bidi-isolated mixed runs; one accessible announcement.** Lay out start→end via `EdgeInsetsDirectional`/`AlignmentDirectional` (never `left`/`right`); the one template serves fa/ckb/ar and ckb's longer transcreated copy reflows within the same insets. Any count (a day-count, "Juz 7") renders in the **locale numeral set** via `intl` `NumberFormat` — Extended Arabic-Indic (۰۱۲۳) for fa/ckb, Arabic-Indic (٠١٢٣) for ar — never concatenated ASCII; mixed Latin/numeral runs sit inside bidi isolation (FSI/PDI). The surface exposes a single calm `Semantics` announcement of the state and its one next step. `docs/design-system/11-voice-and-tone.md` §8 In practice (locale numerals via `intl`, never concatenated; mixed runs wrapped in FSI/PDI; fragments never glued) and §2 (numerals in the locale set, `type.numeral`); detailed bidi/mirroring policy in **eng-rtl-and-bidi-layout**; screen-reader semantics in `docs/design-system/07-components.md` (per-locale `Semantics`) and **ui-daily-session-list**.

10. **One voice across three languages — transcreated, not translated; scholar-reviewed terms.** The empty-state strings are transcreated against the one voice charter, not literally mapped: the Arabic imperative is softened into a statement of readiness, the Persian register is warm-respectful, and any sabaq/sabqi/manzil/cycle terminology named uses the **localized term-sets** (ckb pending native + scholar review). `docs/design-system/11-voice-and-tone.md` §8 (transcreation, not literal translation; per-locale register; softened Arabic imperatives) and §9 (per-locale native + scholar review is a release-blocking gate); `docs/PRD.md` §13.4 (regional term-sets; ckb needs review); §12.2 (Today is a finite, capped list with a calm all-done state, and resumes calmly after a gap). Religious/term wording is cleared by **domain-adab-and-religious-integrity**.

## Do / Don't

| Do | Don't |
|---|---|
| Resume silently into the normal day after a gap when there's nothing to catch up | Greet with "Welcome back! You haven't opened the app in N days" or any cheerful resumption |
| Make the all-done state a calm closing line in `color.text.secondary` | Celebrate all-done with confetti / a streak increment / a badge / an exclamation mark |
| State the calm fact + one gentle next step on first-run | Shame the absence ("you haven't logged", "nothing here — get started!") |
| Keep a pure empty state plainly neutral (no manufactured concern) | Force the empathy-then-path / hard-news register where there is no hard news |
| Phrase as invitation + information; statements of readiness | Ship "you must / have to / should / don't" or any mandate |
| Render on a flat `surface` / Level 0–1 `surfaceContainer`, copy `type.body`/`type.caption`, secondary color | Use a saturated/red warning fill, alarm styling, or a performing mascot/hero illustration |
| Acknowledge any commit with copy + a `motion.duration.short` fade | Fire confetti / fanfare / a streak-repair animation on "all done" |
| Fire only `haptic.confirm` on a gentle commit, paired with a visual change, OS-gated | Fire a "success/reward" haptic for finishing, or a nag buzz on a gap |
| Keep it free-as-ṣadaqah and pressure-free | Add "come back tomorrow", streak-at-risk, FOMO, "upgrade / premium / unlock" |
| Reference tokens by name: `type.body`, `type.caption`, `color.text.secondary`, `space.*`, `motion.duration.short`, `haptic.confirm` | Hardcode hex / 16dp / 220ms / a red color / a raw `HapticFeedback` call at the call site |
| Lay out with `EdgeInsetsDirectional`/`AlignmentDirectional`; counts in locale numerals; mixed runs bidi-isolated | Write `EdgeInsets.only(left:)`, concatenate ASCII digits, or bolt on an "RTL mode" |
| Transcreate per locale (softened Arabic imperative, warm-respectful Persian); use localized term-sets | Literally translate the strings, or hardcode English |

## Checklist

Before this surface is done:

- [ ] After a gap with **nothing to catch up**, the app **resumes silently** into the normal day — no "Welcome back! You haven't opened the app in N days", no broken-streak state, no cheerful resumption. (If a backlog exists, it is **ui-catch-up-banner**, not this.)
- [ ] The **all-done / nothing-due** terminal surface is a calm closing line in `color.text.secondary` — **no confetti / streak increment / badge / exclamation mark**.
- [ ] **First-run / zero-data** surfaces state the calm fact + **one gentle next step** (invitation, not command), and never shame the absence.
- [ ] A **pure empty state stays plainly neutral**; the empathy-then-path / hard-news register is NOT manufactured where there is no hard news (that template belongs to the backlog surface).
- [ ] Voice passes the four attributes (reverent, calm, plain-and-warm, honest); **no mandate words** and **no guilt/fear/loss** ("you haven't logged", "you're behind", "you haven't opened the app in N days", "don't break your streak") — verified against the never-ship banned-phrase lint; **no exclamation marks / emoji** in product copy.
- [ ] **No transactional / pressuring framing**: no "come back tomorrow", streak-at-risk, FOMO, urgency, or "upgrade / premium / unlock".
- [ ] Visual register is calm: a flat `surface` / Level 0–1 `surfaceContainer`, copy in `type.body`/`type.caption` with secondary color, generous `space.*` whitespace; **no red / no saturated warning fill / no performing mascot or hero illustration**.
- [ ] **No celebration**: reaching empty/all-done fires no confetti/fanfare/streak-repair; any acknowledgment is copy + a `motion.duration.short` + `motion.curve.standard` fade; reduce-motion honoured.
- [ ] Haptics use only the permitted vocabulary: `haptic.confirm` on a gentle commit, paired with a visual change, OS-gated; **no success/reward haptic** and **no nag buzz** on a gap.
- [ ] Layout is **RTL by geometry** (`EdgeInsetsDirectional`/`AlignmentDirectional`, no `left`/`right`); any counts render in the **locale numeral set** via `intl` (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar), mixed Latin/numeral runs **bidi-isolated** (FSI/PDI); the one template serves fa/ckb/ar and ckb reflows within the same insets.
- [ ] One calm `Semantics` announcement states the empty/all-done state and its single next step in the user's locale.
- [ ] Strings are **transcreated** per locale (softened Arabic imperative, warm-respectful Persian), use **localized term-sets** (ckb pending native + scholar review), and carry no hardcoded English.
- [ ] The View is **dumb**: it renders the controller's pre-built "empty / all-done / resume" read model and the injected "today"; it never reads `DateTime.now()`, never calls the engine, and any gentle "begin" mutation flows through the single write path.
- [ ] Widget + golden tests cover the three locales (fa/ckb/ar) with real fonts, the first-run / zero-data case, the all-done case, and the silent-resume case; offline by construction (no network in this surface).

An empty state is the app's quietest moment, but for a ḥāfiẓ it is rarely neutral — a blank Today after a gap can read as failure if the copy lets it. Any wording here that touches reverence, sect-neutrality, guilt, or "safe to drop" must be cleared against **domain-adab-and-religious-integrity** before it ships, and the religious terminology against the per-locale scholar review.

## Files

- `template.dart` — copy-paste scaffold: a dumb `EmptyState` View that takes a pre-built `EmptyStateModel` from the controller (first-run / all-done / silent-resume variants), renders the calm fact + one gentle next step on a flat `surfaceContainer`, `haptic.confirm` on the single gentle commit, all RTL via `EdgeInsetsDirectional` with locale numerals and bidi-isolated mixed runs, a single `Semantics` announcement, tokens by name, no celebration, no greeting. Fill the `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **ui-catch-up-banner** (the empathy→fact→plan→choice backlog surface — the *other* return-after-gap face, used only when there is something to catch up on), **ui-daily-session-list** (the Today list this all-done / silent-resume state is a state of, and its loading/populated/budget-feedback siblings), **ui-cold-start-placement** (the first-day onboarding the first-run invitation leads into — coverage capture, per-juz confidence, bundled-core setup), **ui-retention-heatmap** (the Progress surface's own pre-data state), **eng-add-localized-string** (the transcreated ARB strings for fa/ckb/ar), **eng-create-riverpod-store** (the StreamProvider + single-write-path controller behind this View), **eng-add-feature-module** (where the feature/View lives), **eng-rtl-and-bidi-layout** (the bidi-isolation + mirroring for any locale-numeral counts), **domain-adab-and-religious-integrity** (the conscience-check on every word and the no-guilt / no-"safe to drop" floor).
