---
name: ui-certainty-label
description: Build or modify the Hifz app's evidence-certainty badge — the calm lay label that translates a CLAIMS evidence grade ([MA]/[RCT]/[EXP]/[CS]/[OBS]/[TEXT]/[TRAD]) into plain confidence-about-the-evidence words for the science screen. Use whenever rendering an evidence-certainty label/badge, mapping a CLAIMS grade to a lay confidence phrase, or showing the grade legend — never when surfacing the engine's per-source confidence weights or a page's retention state.
---

# ui-certainty-label

A small, calm, neutral badge that translates one `CLAIMS.md` evidence grade (`[MA]`, `[RCT]`, `[EXP]`, `[CS]`, `[OBS]`, `[TEXT]`, `[TRAD]`) into a plain lay label describing **how strong the evidence behind a claim is** — never the raw grade tag, never a star rating, never a colour-only signal, and never a promise about the user's own Quran. It is the visible end of the science foundation's "translate grades into honest confidence language" rule, rendered on the "The science we follow" screen beside each claim's named, dated source.

This badge is a *renderer*, not an author. It carries no fact of its own: it formats a grade that already came from the bundled, offline `CLAIMS.md` register. A badge that invents a grade, shows `[TRAD]` raw, colours strength like a traffic light, or implies "this page is safe" is the wrong component.

## When to use

Use when building or placing:
- the evidence-certainty label/badge shown next to a claim's source on the science screen
- the mapping from a `CLAIMS.md` grade enum to its lay confidence phrase (the "translate grades into honest confidence language" step)
- the always-reachable grade legend that explains the grades in plain words
- any read-only certainty/strength affordance derived from a registered grade

Do NOT use this skill for:
- registering/grading a claim, or building the science screen as a whole → use **domain-claims-register-and-science-screen**
- the recite/grade flow's per-source confidence weights (teacher `1.0` vs self-rating `≈0.5`) — that is an *engine input signal*, not a user-facing evidence label → use **domain-grading-pipeline**
- any copy/adab review of the label's wording (no guilt, no "proven," no "safe to drop") → use **domain-adab-and-religious-integrity**
- the Riverpod read model that exposes claim rows to the screen → use **eng-create-riverpod-store**
- where the science tab/screen itself is mounted → use **eng-add-feature-module**

The badge is the *certainty-of-evidence* affordance. Confidence about *the user's Quran*, retention percentages, and "safe to drop" states are never expressed here — they are forbidden everywhere (`docs/science/11-the-in-app-science-screen.md` §5).

## The canonical pattern

1. **Grade is a sealed enum, not a string.** Model the seven grades as a `sealed`/`enum EvidenceGrade { ma, rct, exp, cs, obs, text, trad }` in the read model, parsed once from the bundled `CLAIMS.md` data. The badge takes the enum, never the raw `[MA]`-style tag text. The seven grades and their best→weakest order (`MA > RCT/EXP > CS > OBS > TEXT`, with `[TRAD]` naming the source) are fixed by `docs/science/CLAIMS.md` (Evidence grades legend) and `docs/science/11-the-in-app-science-screen.md` §5; an unknown grade is a release-blocking data defect, not a fallback to render.

2. **Map grade → lay confidence phrase, describing the evidence only.** A pure `String certaintyLabel(EvidenceGrade)` (no I/O, no `BuildContext`) returns localized confidence-about-the-evidence wording: `[MA]` → "among the best-established findings"; `[EXP]`/`[RCT]` → "a controlled study"; `[CS]` → "a classic foundational study"; `[OBS]` → "an observational / field study"; `[TEXT]` → "an expert review / algorithm documentation"; `[TRAD]` → "named traditional scholarship." The phrases describe the *strength of the evidence*, kept strictly separate from any certainty about the user's Quran. `docs/science/11-the-in-app-science-screen.md` §5 ("Confidence words, not certainty words"; "Grade describes the strength of the evidence behind a claim, kept separate from the certainty the app expresses") and the legend in `docs/science/CLAIMS.md`.

3. **`[TRAD]` issues no ruling and is shown as named scholarship.** A `[TRAD]` badge reads as "traditional scholarship, named below," paired on the card with the source by name/number (e.g. *Ṣaḥīḥ al-Bukhārī 5032*) — never as a fiqh verdict, never ranked above the empirical grades as if more *authoritative*. `docs/science/CLAIMS.md` (Scope & neutrality clause: `[TRAD]` rows are scoped to methodology and issue no fiqh ruling) and `docs/science/11-the-in-app-science-screen.md` §4 / §8.

4. **Never the raw grade tag as primary text; never jargon-only.** The badge surfaces the plain phrase first; the literal grade name (e.g. "meta-analysis") is the at-most secondary, glossed detail — the raw `[MA]`/`[TRAD]` bracket tags from the register are an authoring convention and never appear in the UI. `docs/science/11-the-in-app-science-screen.md` §3 (plain common words; jargon only with a one-line gloss) and §5.

5. **Neutral styling — never a traffic light, never colour-alone.** The badge uses one calm neutral container (read `color.surface`/`color.text.secondary` family from `docs/design-system/03-color-and-themes.md`; the badge owns no token) for *all* grades — a weaker grade is not red, a stronger grade is not green. Strength is conveyed by the **text phrase** (and an optional shape/icon), never by colour. Text meets ≥ 4.5:1 contrast across light/sepia/dark. `docs/design-system/11-voice-and-tone.md` §2 ("Honest" attribute; renders in `color.text.primary`/`secondary`, never a saturated warning fill) and `docs/science/11-the-in-app-science-screen.md` §7 ("Grade never color-only" — WCAG 2.2 SC 1.4.1; ≥ 4.5:1 per SC 1.4.3).

6. **Calm, honest wording — no star rating, no "proven," no promise.** The phrase is a quiet statement, never "★★★★★," never "scientifically proven," never a confidence percentage about retention, never urgency or hype. A high grade is never rendered as a guarantee. `docs/science/11-the-in-app-science-screen.md` §5 (Anti-patterns: never a star rating, "proven" badge, or confidence percentage) and §6 (calm, no persuasion machinery); voice "Honest" + "Calm" attributes in `docs/design-system/11-voice-and-tone.md` §2.

7. **A plain-words legend, always reachable.** Pair the badges with one calm legend that explains the grades in plain language ("a meta-analysis pools many studies; an experiment is a single controlled test; a traditional source is named scholarship") — never a marketing "★★★★★" key. The legend is the same translated copy, not English-first. `docs/science/11-the-in-app-science-screen.md` §4 ("Grade legend, in plain words").

8. **Offline, static, bundled.** The grade and its label ship inside the verified core pack / app binary; the badge makes no network call and runs no model to "explain" a grade. `docs/science/11-the-in-app-science-screen.md` §2 (bundled, static, no network, no AI — PRD C1/C2).

9. **RTL-native in fa/ckb/ar, transcreated.** The label and legend are ARB-sourced (`gen_l10n`) strings, transcreated per locale (not literally translated), rendered under `Directionality` with the active locale; any Latin source name shown alongside is bidi-isolated (FSI/PDI) so it never breaks the right-to-left line. `docs/design-system/11-voice-and-tone.md` §8 (transcreation, per-locale register; bidi isolation of Latin/numeric runs) and `docs/science/11-the-in-app-science-screen.md` §3 ("Localized, RTL-native").

## Do / Don't

| Do | Don't |
|---|---|
| Take a sealed `EvidenceGrade` enum parsed from the bundled `CLAIMS.md` | Pass the raw `[MA]`/`[TRAD]` bracket tag text into the badge, or render it as the label |
| Map grade → a lay phrase about the **strength of the evidence** | Word the badge as confidence about the user's Quran, retention, or a page being "safe" |
| Render `[TRAD]` as "named traditional scholarship," paired with the source by name/number | Render `[TRAD]` as a fiqh ruling, or rank it above empirical grades as more authoritative |
| Use one neutral `color.surface`/`color.text.secondary` container for every grade | Colour the badge like a traffic light (red weak / green strong) or encode strength in colour alone |
| Convey strength by the text phrase (+ optional shape/icon); meet ≥ 4.5:1 contrast | Use a ★ star rating, a "proven" badge, or a confidence percentage |
| Put the plain phrase first; the literal grade name is at-most a glossed detail | Surface "meta-analysis"/"effect size"/jargon as the unglossed primary text |
| Pair badges with one calm, plain-words, translated legend | Ship a "★★★★★" marketing legend, or an English-first legend merely translated |
| Source label + legend from ARB, transcreate per fa/ckb/ar, bidi-isolate Latin names | Hard-code the English phrase, or let a literal translation drift the tone |
| Keep the mapping a pure function (no `BuildContext`, no I/O), rendered offline | Fetch the grade or its explanation from a server, or generate the wording with a model |

## Checklist

Before this control is done:

- [ ] Badge takes a sealed `EvidenceGrade` enum (`ma`/`rct`/`exp`/`cs`/`obs`/`text`/`trad`) parsed from the bundled `CLAIMS.md` data — never the raw `[…]` tag text.
- [ ] `certaintyLabel(EvidenceGrade)` is a pure function (no `BuildContext`, no I/O) returning a localized phrase that describes the **strength of the evidence**, never the user's own retention/Quran.
- [ ] `[MA]`→"best-established", `[RCT]`/`[EXP]`→"a controlled study", `[CS]`→"classic foundational study", `[OBS]`→"observational/field study", `[TEXT]`→"expert review / algorithm documentation", `[TRAD]`→"named traditional scholarship" (wording confirmed against §5 / the legend).
- [ ] `[TRAD]` reads as named scholarship paired with source-by-name/number, issues no fiqh ruling, and is not styled as more authoritative than empirical grades.
- [ ] Plain phrase is the primary text; the literal grade name is at most a glossed secondary; no raw bracket tag and no jargon appears unglossed.
- [ ] One neutral container for all grades (no traffic-light colour); strength is in the text/shape, never colour alone; text ≥ 4.5:1 across light/sepia/dark (WCAG 1.4.1/1.4.3).
- [ ] No star rating, no "proven," no confidence percentage, no urgency/hype; a high grade is never rendered as a guarantee.
- [ ] A calm, plain-words, translated grade legend is always reachable from the badges.
- [ ] Label + legend are ARB-sourced, transcreated (not literally translated) for fa/ckb/ar, rendered under `Directionality`; any Latin source name is bidi-isolated (FSI/PDI).
- [ ] Fully offline: grade and wording come from the bundled core pack/binary; no network call and no model is used to render or explain the badge.
- [ ] Widget + golden tests cover all seven grades and the three RTL locales; a goldens-match for the neutral (non-traffic-light) styling (see **eng-write-dart-test**).

This badge expresses certainty *about the evidence*, never about the user's Quran. If any surface ever needs to express a page's strength to a ḥāfiẓ, that is the heat-map's honest "weakening/strengthening/due" language — never "safe to drop," never "mastered" — and it is governed by **domain-adab-and-religious-integrity** and **domain-scheduling-engine-rules**, not by this label.

## Files

- `template.dart` — copy-paste starting point: the `EvidenceGrade` enum, the pure `certaintyLabel` mapping, a neutral `CertaintyLabel` Material 3 badge widget (Directionality/RTL, tokens by name), and the legend scaffold. Fill the `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-claims-register-and-science-screen** (the register this badge renders and the screen it lives on), **domain-adab-and-religious-integrity** (the always-on copy/adab conscience check for the wording), **domain-grading-pipeline** (the engine's per-source confidence weights, which this badge is NOT), **eng-create-riverpod-store** (the read model exposing claim rows + grades), **eng-add-feature-module** (where the science screen mounts), **eng-write-dart-test** (the seven-grade + RTL golden coverage).
