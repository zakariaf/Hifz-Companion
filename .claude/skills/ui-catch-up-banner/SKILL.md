---
name: ui-catch-up-banner
description: Build or modify the Hifz app's missed-day catch-up banner — the calm, supportive surface shown on Today after a gap that presents the engine's re-spread backlog plan ("you missed 3 days — here is a 5-day catch-up plan that still completes your cycle"), most-decayed and prayer-critical first, never a red overdue / shame pile. Use whenever building the catch-up / backlog / missed-day surface, the "catch-up ready" note, or any return-after-gap messaging on Today.
---

# ui-catch-up-banner

The missed-day catch-up banner: after a gap, the engine re-flows the backlog over several days — most-decayed and prayer-critical first — and this surface presents that plan to the ḥāfiẓ **calmly and supportively**. It leads with empathy, states the honest fact, offers the concrete re-spread plan, and leaves the choice with the user. It is the canonical instance of the empathy-then-path hard-news template. It is **never** a red overdue pile, a broken-streak state, a "you're behind" scold, or a "welcome back, you haven't opened the app in N days" greeting.

This banner is a *state* of the Today daily-session list, not a screen of its own. It composes the engine's already-computed re-spread plan; it never computes the catch-up math itself, and it never shames a gap into existence.

## When to use

Use when building or placing:
- the missed-day **catch-up banner** on Today (the gentle re-spread plan after a gap)
- the **"catch-up ready"** note framed as help (local notification body or the Today surface)
- any **return-after-gap** messaging on the Today screen
- the copy/visual treatment for "you missed N days — here is an M-day catch-up plan"

Do NOT use this skill for:
- the **catch-up re-spread algorithm itself** (the math that re-flows the backlog over several days, most-decayed/prayer-critical first, `loadBalance`, the hard-R floor, the cycle ceiling) → use **domain-scheduling-engine-rules**
- the Today list this banner sits inside (the finite Far→Near→New queue, its loading/populated/all-done states, the honest budget-feedback line) → use **ui-daily-session-list**
- the **page-card row** the re-spread plan is made of (track chip, decay indicator, page/juz headline) → use **ui-page-card**
- the **reveal-on-tap + grade band** the row taps into → use **ui-recite-grade-flow**
- the date math behind "you missed N days" (elapsed-day counts across DST/timezone, the injected "today") → use **domain-calendars-and-hifzdate**
- the local-notification scheduling of the "catch-up ready" note → use **eng-define-service-boundary**
- the controller / StreamProvider / single-write-path wiring behind this View → use **eng-create-riverpod-store** and **eng-add-feature-module**

The banner is the *gentle framing of a backlog*; the engine owns the *backlog math*. A catch-up surface that shows a red count of "overdue" pages, a broken streak, or a "you're behind" line is the wrong component.

## The canonical pattern

1. **Empathy first, then the honest fact, then a path, then the choice.** The banner follows the empathy-then-path hard-news template in exactly that order: (1) a calm, non-blaming acknowledgment, (2) the honest fact (N days missed), (3) the concrete re-spread plan (an M-day catch-up that still completes the cycle), (4) the user's choices. Missed-day catch-up is the canonical instance of this template. `docs/design-system/11-voice-and-tone.md` §4 (the empathy-then-path template; missed-day catch-up is the canonical instance — *"You missed 3 days — here is a 5-day catch-up plan that still completes your cycle"*) and §3 (the Missed-days/catch-up tone row: empathy first, then a concrete plan and choice).

2. **Re-spread, never dump — the plan comes pre-built from the engine.** The banner renders the engine's already-computed re-spread of the backlog over several days, most-decayed and prayer-critical first; it never dumps a red overdue pile and it never computes the spread itself. FAR/manzil due items are mandatory and are never silently dropped to make the plan look shorter. `docs/PRD.md` §7.9 (Missed-day catch-up — the engine re-flows the backlog over several days, most-decayed and prayer-critical first; *re-spread, never shame*; FAR/manzil mandatory) and §12.2 (Today shows a gentle catch-up banner with the re-spread plan, never a red shame-pile); the algorithm itself is **domain-scheduling-engine-rules**.

3. **Calm visual register — decay recedes, it never alarms.** Render the banner on a calm surface container (a low-elevation `surfaceContainer`/`Card`, Level 0–1), copy in `type.body` with the plan's day-counts and page-counts in the **locale numeral set**, never a saturated warning fill, never red. Where the plan references decaying pages, decay reads as the heat-map's green *receding to a muted neutral* (`color.heatmap.weak`/`faded`), never an alarming red scoreboard — copy and color tell the same calm story. `docs/design-system/11-voice-and-tone.md` §4 In practice (catch-up banners use `type.body` on a calm surface container, plan numerals in the locale set; the visual register matches the verbal one — decay green receding, never an alarming red scoreboard); `docs/design-system/08-data-visualization.md` §3 (decay is `color.heatmap.weak`→`faded`, never alarming red; never frame decay as loss).

4. **Voice: reverent, calm, plain-and-warm, honest — never command, never blame.** Every string passes the four fixed voice attributes; the banner is autonomy-supportive — it suggests and informs, never commands. No mandate words ("you must / have to / should / don't"), no guilt/fear/loss framing, no "you're behind" / "N days lost" / "you let this slip." `docs/design-system/11-voice-and-tone.md` §2 (the four voice attributes), §6 (phrase as invitation and information, never command — banned mandate words), §3 Anti-patterns (no red "overdue" pile / broken-streak; tone never drifts into pressuring) and §9 (the never-ship banned-phrase lint: guilt/fear/loss, "you're behind," "N days lost," controlling mandates — release-blocking).

5. **Never greet the gap; resume into the normal day.** The banner appears *only because there is a re-spread plan to offer help with* — it is never a "Welcome back! You haven't opened the app in N days" greeting, never a broken-streak state, and the app otherwise resumes silently into the normal Today screen. The fact "N days missed" is stated only as the lead-in to the help, never as a standalone reproach. `docs/design-system/11-voice-and-tone.md` §3 (Resume-after-a-gap row: resume silently into the normal day; the "Welcome back… N days" greeting is forbidden) and §3 Anti-patterns (never greet a returning user with cheerful resumption that implies they lapsed).

6. **The choice is the user's — offer options, never one mandate.** The banner ends in real, user-owned choices (e.g. start the catch-up plan, adjust its length/budget, or defer) — never a single mandated fix and never a hidden silent drop of pages. This is the restoration-of-freedom repair; it is the same autonomy-support lever the budget-feedback line uses on this surface. `docs/design-system/11-voice-and-tone.md` §4 In practice (hard news ends in options the user owns; restoration-of-freedom framing) and §6 In practice (provision of choice over a single mandate); `docs/PRD.md` §7.9 / §12.2 (the engine never silently lets pages rot).

7. **No celebration on accepting or completing the plan — informational only.** Starting the catch-up plan, and later clearing it, fires no confetti, no fanfare, no "well done," no streak repair animation — celebratory motion does not exist in this app. A grade landing inside the catch-up flow registers with `motion.duration.short` + `motion.curve.standard` and a quiet state change, acknowledged by copy alone. `docs/design-system/06-motion-and-haptics.md` §2 (no celebratory motion anywhere — no confetti/fanfare/reward tier; milestones acknowledged by copy + a `motion.duration.short` fade) and §1 (the short/medium ladder, standard easing for routine UI).

8. **Haptics stay in the tiny, meaning-bearing vocabulary — no "success" pulse.** The banner uses only the three permitted pulses where an action commits: `haptic.confirm` (`lightImpact`) when the user starts/accepts the plan; never a "success/reward" haptic on resolving a backlog, never a `haptic.warning`-style buzz fired to nag a missed day. Every haptic accompanies an on-screen change and obeys the OS system-haptics setting. `docs/design-system/06-motion-and-haptics.md` §4 (the three-pulse vocabulary; `haptic.confirm` on commit; no success/reward haptic; never use a haptic to manufacture guilt for a missed day) and §4 In practice (opt-out; always paired with a visual change).

9. **RTL by geometry; locale numerals; bidi-isolated mixed runs.** The banner lays out start→end via `EdgeInsetsDirectional`/`AlignmentDirectional` (never `left`/`right`); the one template serves fa/ckb/ar and ckb's longer transcreated copy reflows within the same insets. Day-counts/page-counts render in the locale set (Extended Arabic-Indic ۰۱۲۳ for fa/ckb, Arabic-Indic ٠١٢٣ for ar) via `intl` `NumberFormat`, never concatenated ASCII; mixed Latin/numeral runs ("Juz 7", a page number) sit inside bidi isolation (FSI/PDI) so a count never breaks the RTL line. `docs/design-system/11-voice-and-tone.md` §8 In practice (locale numerals via `intl`, never concatenated; mixed runs wrapped in FSI/PDI; fragments never glued) and §2 (numerals always in the locale set, `type.numeral`); detailed bidi policy in **eng-rtl-and-bidi-layout**.

10. **One voice across three languages — transcreated, not translated; scholar-reviewed terms.** The banner's strings are transcreated against the one voice charter, not literally mapped; the Arabic imperative is softened into a statement of readiness, the Persian register is warm-respectful, and any sabaq/manzil/cycle terminology the plan names uses the **localized term-sets** (ckb pending native + scholar review). `docs/design-system/11-voice-and-tone.md` §8 (transcreation, not literal translation; per-locale register; softened Arabic imperatives) and §9 (per-locale native + scholar review is a release-blocking gate); `docs/PRD.md` §13.4 (regional term-sets; ckb needs review); methodology/term wording cleared by **domain-adab-and-religious-integrity**.

## Do / Don't

| Do | Don't |
|---|---|
| Order the copy empathy → honest fact → concrete plan → choice | Open with fault ("you're behind", "you let this slip"), or state "N days missed" as a standalone reproach |
| Render the engine's pre-built re-spread of the backlog (most-decayed / prayer-critical first) | Compute the catch-up spread in the widget, or dump a single red overdue pile |
| Show it on a calm `surfaceContainer`/`Card` (Level 0–1), copy in `type.body` | Use a saturated/red warning fill, an alarm styling, or a countdown |
| Encode any referenced decay as green receding to muted neutral (`color.heatmap.weak`/`faded`) | Render decay as a red scoreboard, or frame it as loss ("you're losing your Quran") |
| Keep FAR/manzil due items in the plan (mandatory) | Silently drop manzil pages to make the plan look shorter |
| Phrase as invitation + information; end in user-owned choices | Ship "you must / have to / should / don't" or a single mandated fix |
| Resume silently into the normal day when there's nothing to offer | Greet with "Welcome back! You haven't opened the app in N days" or a broken-streak state |
| Fire `haptic.confirm` on starting the plan, paired with a visual change | Fire a "success/reward" haptic on clearing a backlog, or a buzz to nag a missed day |
| Acknowledge accepting/completing with copy + a `motion.duration.short` fade | Fire confetti / fanfare / a streak-repair animation |
| Reference tokens by name: `type.body`, `type.numeral`, `color.text.secondary`, `space.*`, `motion.duration.short`, `motion.curve.standard`, `haptic.confirm` | Hardcode hex / 16dp / 220ms / a red color / a raw `HapticFeedback` call at the call site |
| Lay out with `EdgeInsetsDirectional`/`AlignmentDirectional`; counts in locale numerals, mixed runs bidi-isolated | Write `EdgeInsets.only(left:)`, concatenate ASCII digits, or bolt on an "RTL mode" |
| Transcreate per locale (softened Arabic imperative, warm-respectful Persian); use localized term-sets | Literally translate the strings, or hardcode English / a generic "overdue" label |

## Checklist

Before this surface is done:

- [ ] Copy order is **empathy → honest fact → concrete plan → choice** (the empathy-then-path template); it never opens with fault and never states "N days missed" as a standalone reproach.
- [ ] The banner renders the **engine's pre-built re-spread** (most-decayed / prayer-critical first), never a red overdue pile; the widget never computes the spread (the math is **domain-scheduling-engine-rules**).
- [ ] **FAR/manzil due items stay in the plan** (mandatory); nothing is silently dropped or labelled "safe to drop" to shorten it.
- [ ] Visual register is calm: a `surfaceContainer`/`Card` at Level 0–1, copy in `type.body`, **no red / no saturated warning fill / no alarm styling**; any referenced decay reads as green receding to muted neutral (`color.heatmap.weak`/`faded`).
- [ ] Voice passes the four attributes (reverent, calm, plain-and-warm, honest); **no mandate words** ("you must / have to / should / don't") and **no guilt/fear/loss** ("you're behind", "N days lost", "you're losing your hifz") — verified against the never-ship banned-phrase lint.
- [ ] It **never greets the gap** ("Welcome back! You haven't opened the app in N days") and never shows a broken-streak state; when there's no plan to offer, the app resumes silently into the normal Today screen.
- [ ] The banner ends in **real user-owned choices** (start the plan / adjust length or budget / defer), never a single mandated fix and never a silent drop of pages.
- [ ] **No celebration**: starting or completing the plan fires no confetti/fanfare/streak-repair; acknowledgment is copy + a `motion.duration.short` + `motion.curve.standard` fade; reduce-motion is honoured.
- [ ] Haptics use only the permitted vocabulary: `haptic.confirm` on commit, paired with a visual change, OS-gated; **no success/reward haptic** and **no nag buzz** for a missed day.
- [ ] Layout is **RTL by geometry** (`EdgeInsetsDirectional`/`AlignmentDirectional`, no `left`/`right`); day-/page-counts render in the **locale numeral set** via `intl` (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar), mixed Latin/numeral runs **bidi-isolated** (FSI/PDI); the one template serves fa/ckb/ar and ckb reflows within the same insets.
- [ ] Strings are **transcreated** per locale (softened Arabic imperative, warm-respectful Persian), use **localized term-sets** (ckb pending native + scholar review), and carry no hardcoded English / generic "overdue" label.
- [ ] The View is **dumb**: it renders the controller's pre-built catch-up plan and the injected "today"; it never reads `DateTime.now()`, never calls the engine, and any "start the plan" mutation flows through the single write path.
- [ ] Widget + golden tests cover the three locales (fa/ckb/ar) with real fonts, the empty (no-banner / silent-resume) case, and the populated re-spread plan; offline by construction (no network in this surface).

This banner is the gentlest moment in the app's hardest conversation: a ḥāfiẓ returning after a gap already carries spiritual weight, so any wording, decay framing, or term-set here that touches reverence, sect-neutrality, guilt, or "safe to drop" must be cleared against **domain-adab-and-religious-integrity** before it ships, and the religious terminology against the per-locale scholar review.

## Files

- `template.dart` — copy-paste scaffold: a dumb `CatchUpBanner` View that takes a pre-built `CatchUpPlan` from the controller, renders the empathy→fact→plan→choice copy on a calm `surfaceContainer`/`Card`, the re-spread plan rows, the user-owned choice actions, `haptic.confirm` on accept, all RTL via `EdgeInsetsDirectional` with locale numerals and bidi-isolated mixed runs, tokens by name, no celebration. Fill the `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **ui-daily-session-list** (the Today list this banner is a state of, and its honest budget-feedback sibling), **domain-scheduling-engine-rules** (the re-spread algorithm that produces the catch-up plan — most-decayed/prayer-critical first, FAR mandatory), **ui-page-card** (the page-card rows the plan is made of), **ui-recite-grade-flow** (the reveal-on-tap + grade band the rows tap into), **domain-calendars-and-hifzdate** (the elapsed-day "N days missed" count and the injected "today"), **eng-define-service-boundary** (the local-notification "catch-up ready" note and the injected clock), **eng-create-riverpod-store** (the StreamProvider + single-write-path controller behind it), **eng-add-feature-module** (where the Today feature/View lives), **eng-rtl-and-bidi-layout** (the bidi-isolation + mirroring for the locale-numeral counts), **domain-adab-and-religious-integrity** (the conscience-check on every word, decay framing, and term-set).
