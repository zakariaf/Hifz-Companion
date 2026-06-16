# references — ui-certainty-label

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/science/11-the-in-app-science-screen.md` §5 (Grades become honest confidence language) — **The core rule of this badge.** "A grade describes the *strength of the evidence behind a claim*, kept strictly separate from any certainty about *your* Quran." Render confidence *words*, not certainty words ("among the best-established findings" for `[MA]`; "a single controlled study" for an experiment; "named traditional scholarship" for `[TRAD]`). Anti-patterns bound the styling: **never a star rating, a "proven" badge, or a confidence percentage**, and never imply a page is "safe to drop."

- `docs/science/CLAIMS.md` (Evidence grades legend + Scope & neutrality clause) — The seven grades and their meanings/order: `[MA]` meta-analysis · `[RCT]` randomized · `[EXP]` controlled experiment · `[CS]` classic foundational · `[OBS]` observational/field · `[TEXT]` textbook/expert review/algorithm docs · `[TRAD]` traditional Islamic source; preference among empirical `MA > RCT/EXP > CS > OBS > TEXT`. Two binding takeaways: the grade is "the strength of the evidence behind the claim, kept strictly separate from any certainty the app expresses about the user's own Quran," and every `[TRAD]` row is **scoped to methodology and issues no fiqh ruling**, naming an identifiable source (hadith with collection + number).

- `docs/design-system/11-voice-and-tone.md` §2 (The voice: four fixed attributes) — The **Honest** attribute ("Estimates are labelled; nothing is hidden; a page is never called 'safe to drop'") and **Calm** attribute ("no exclamation marks, no alarm styling … renders in `color.text.primary`/`secondary`, never a saturated warning fill") govern both the badge's wording and its neutral, non-traffic-light styling.

## Supporting

- `docs/science/11-the-in-app-science-screen.md` §4 (Every claim names and dates its source, with its grade visible) — "Grade legend, in plain words … never a marketing '★★★★★'." Religious claims are shown with collection, number, and grading, framed as methodology never a ruling. The badge sits beside the named, dated source — it is the grade made visible, not a substitute for the citation.

- `docs/science/11-the-in-app-science-screen.md` §3 (Plain, common words) — Plain headline first; technical terms only with a one-line gloss and only where informative. Justifies showing the lay phrase as primary and the literal grade name as at-most a glossed secondary — never the raw `[MA]`/`[TRAD]` bracket tag, never unglossed jargon. Also: "Localized, RTL-native … RTL string resources … bidi isolation for any Latin source names."

- `docs/science/11-the-in-app-science-screen.md` §7 (Accessible and RTL-native) — "**Grade never color-only** — conveyed by its text tag … never by color alone" (WCAG 2.2 SC 1.4.1); text ≥ 4.5:1 contrast across light/sepia/dark (SC 1.4.3); reflow without truncation (SC 1.4.4/1.4.10); semantic label in the active locale. This is the accessibility contract for the badge.

- `docs/science/11-the-in-app-science-screen.md` §2 (Ships fully offline) — Bundled, static, no network, no AI (PRD C1/C2). The grade and its rendered label travel in the verified core pack / app binary; the badge never fetches or generates wording at runtime.

- `docs/science/11-the-in-app-science-screen.md` §6 (Calm, without coercion) — Explanation, not persuasion: no streaks, urgency, hype, or guilt. The badge is reference, not a hook; a high grade is stated quietly, never sold as a guarantee.

- `docs/science/11-the-in-app-science-screen.md` §8 (Honest scope) — Methodology, not rulings; "needs scholarly review" shown plainly where sign-off is pending. A `[TRAD]` badge defers to the teacher and the *sanad* chain; it never makes the app a religious authority.

- `docs/design-system/11-voice-and-tone.md` §5 (Speak as a gentle teacher's aide) — The app "never issues a ruling, never declares a page 'safe to drop,' never speaks *on behalf of* the Quran." Binds the `[TRAD]` label and forbids any certainty-about-the-user framing on this badge.

- `docs/design-system/11-voice-and-tone.md` §8 (One voice across fa/ar/ckb — transcreation) — Label and legend are transcreated per locale against the voice charter, not literally translated; numerals in the locale set; Latin/numeric runs wrapped in bidi isolation (FSI/PDI). The per-locale register is deliberate, not a dictionary default.

## Sibling skills

- **domain-claims-register-and-science-screen** — registers/grades every claim and builds the science screen; this badge is one rendered piece of that screen, reading the grade it owns.
- **domain-adab-and-religious-integrity** — the always-on conscience check for the label's wording (no guilt/"proven"/"safe to drop"; `[TRAD]` issues no ruling; sect-neutral).
- **domain-grading-pipeline** — the recite-flow per-source confidence weights (teacher `1.0` vs self-rating `≈0.5`); an engine input signal, NOT this user-facing evidence badge.
- **domain-scheduling-engine-rules** — owns the heat-map's honest "weakening/strengthening/due" page-strength language; the only place a page's strength is shown to a ḥāfiẓ, and never via this label.
- **eng-create-riverpod-store** — the read model that exposes claim rows + grades to the screen.
- **eng-add-feature-module** — where the science screen/tab is mounted.
- **eng-write-dart-test** — the seven-grade mapping unit tests and the RTL / neutral-styling golden coverage.
