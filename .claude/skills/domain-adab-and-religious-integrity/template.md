# Adab & religious-integrity conscience review — <!-- TODO: name the change (copy / feature / mechanic / sacred surface) -->

> Copy this scaffold next to the change under review. It is the always-on conscience pass: the R1–R6 gate, the adab voice gate, the never-ship phrase list, and the per-locale + scholar-review record. Fill every `// TODO`. Cite the guardrail by its PRD/doc section; name the sibling skill that enforces the mechanism. If any gate fails, the change does not ship — the non-negotiables outrank the feature (`docs/PRD.md` §4).

**Surface(s) touched:** <!-- TODO: e.g. Today list item · daily notification · muṣḥaf overlay · onboarding riwāyah label -->
**Sibling skill that owns the mechanism (if any):** <!-- TODO: domain-mushaf-text-integrity | domain-asset-pack-integrity | domain-scheduling-engine-rules | domain-grading-pipeline | domain-mutashabihat-system | (UI-only — n/a) -->

---

## 1. The R1–R6 non-negotiable gate (`docs/PRD.md` §4 — release-blocking)

- [ ] **R1 — reverence toward the muṣḥaf.** No re-typeset/reflow/decoration of sacred text; markers are coordinate overlays on the immutable glyph layer; nothing celebratory sits on or near an āyah.
      → mechanism enforced by **domain-mushaf-text-integrity**; adab per `13-islamic-identity-and-adab.md` §1, §3.
      Notes: <!-- TODO: how this change touches the page, or "does not touch the muṣḥaf" -->
- [ ] **R2 — riwāyah named, neutrality kept.** Shows "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf" where the edition is named; ships **zero** tafsīr/translation/commentary; Quran text identical across fa/ckb/ar.
      → `13-islamic-identity-and-adab.md` §5.
      Notes: <!-- TODO -->
- [ ] **R3 / C6 — no gamification of worship.** No XP/points/badges-on-āyāt/leaderboards/ḥasanāt-counter/confetti; feedback is the calm heat-map + weakest-pages + a feasible plan; any continuity indicator is private, opt-in, non-punitive.
      → `13-islamic-identity-and-adab.md` §4.
      Notes: <!-- TODO -->
- [ ] **R5 — privacy as religious trust.** No microphone/recording/ASR/AI mistake-detection; no account/telemetry/per-user network; works offline in airplane mode.
      → network covenant via **domain-asset-pack-integrity**; `docs/PRD.md` R5, C2, §17.
      Notes: <!-- TODO -->
- [ ] **R6 — servant to the teacher.** Teacher sign-off overrides the machine; copy credits the teacher, never the app; no fiqh ruling; never speaks *for* the Quran/Allah; never says "safe to drop / mastered / done."
      → overrides via **domain-grading-pipeline**; invariant via **domain-scheduling-engine-rules**; `docs/PRD.md` R6, §7.12; `science/10-traditional-hifz-methodology.md` §6.
      Notes: <!-- TODO -->

## 2. The adab voice gate (`docs/design-system/11-voice-and-tone.md` §1–§2)

Score the user-facing string on the four fixed attributes; a string that is clear but harsh fails the adab gate **first**.

| Attribute | Pass? | The string, as written |
|---|---|---|
| **Reverent** (adab; honorifics + correct transliteration where a name/term appears) | <!-- TODO --> | <!-- TODO --> |
| **Calm** (no urgency the data doesn't warrant; no `!`, no alarm styling) | <!-- TODO --> | |
| **Plain & warm** (short, one idea, key fact first; a companion, not a clerk) | <!-- TODO --> | |
| **Honest** (estimates labelled; never "safe to drop"; limits stated) | <!-- TODO --> | |

Hard news? Apply the **empathy → fact → path → choice** template (`11-voice-and-tone.md` §4):
<!-- TODO: e.g. "You missed 3 days — here is a 5-day catch-up that still completes your cycle." -->

## 3. The never-ship phrase lint (`docs/design-system/11-voice-and-tone.md` §9 — release-blocking, every locale)

Confirm the string contains **none** of these (each traces to a cited harm, not a preference):

- [ ] No guilt/fear/loss framing — `// TODO` checked: not "You'll lose your hifz", "You're falling behind", "You haven't opened the app in N days", "Don't break your streak"
- [ ] No controlling mandate — not "you must / have to / should", "don't", or a scolding imperative (Arabic bare command → soften to a statement of readiness)
- [ ] No "safe to drop" / "mastered" / "done" / "finished with"
- [ ] No exclamation marks and no emoji in product copy
- [ ] No commercial-transaction word — not "upgrade", "premium", "unlock", paywall, urgency, or FOMO

## 4. Identity & sacred-surface restraint (`docs/design-system/13-islamic-identity-and-adab.md` §3, §7)

- [ ] No mascot, cartoon Quran, figurative imagery, neon/saturated color, or "Islamic-themed" clip-art
- [ ] If a sacred-text surface: it is "no dashboard" — no badge/counter/ring/glow/gilt border over the glyph layer; motion is sober (no flip sound, no haptic celebration)
- [ ] If a reverent opening framing is used: it is optional and dismissible, never mandatory or guilt-laden (`13-islamic-identity-and-adab.md` §2)

## 5. RTL + three-locale completeness (`docs/PRD.md` §13; `11-voice-and-tone.md` §8)

The string must exist for **all three** locales, transcreated (not literally translated) so the calm-reverent feeling survives the per-locale register.

```arb
// app_<locale>.arb — one entry per locale; key is shared, value is TRANSCREATED, not a literal mapping.
// fa (Persian) — respectful-warm šomā register; Extended Arabic-Indic numerals (۰۱۲…)
"<!-- TODO: keyName -->": "<!-- TODO: fa value -->",
"@<!-- TODO: keyName -->": { "description": "<!-- TODO: context + the FEELING to preserve, not just the words -->" }

// ckb (Kurdish Sorani) — register + religious vocabulary set by native reviewer; PLACEHOLDER until that review lands (PRD §13.4, §21)
// ar (Arabic) — number/gender-appropriate forms; imperatives softened to statements of readiness; Arabic-Indic numerals (٠١٢…)
```

- [ ] Key exists in `app_fa.arb`, `app_ckb.arb`, `app_ar.arb` — zero missing keys, zero hardcoded user-facing strings (`gen_l10n` coverage gate)
- [ ] Numerals render via `intl` `NumberFormat` in the locale set (never raw ASCII concatenated into the string); mixed Latin/numeric runs wrapped in bidi isolation (FSI/PDI)
- [ ] No sentence fragments glued together (RTL word order will not survive concatenation)

## 6. Scholar-review boundary & sign-off record (`docs/PRD.md` §13.4, §21; `13-islamic-identity-and-adab.md` §2, §6)

- [ ] Any etiquette/methodology wording is attributed, optional, sect-neutral, and flagged "needs scholarly review" — it never reads as a fiqh ruling
- [ ] Banned-phrase lint: **passes** in fa / ckb / ar
- [ ] Native-speaker register review: <!-- TODO: done / pending — which locales -->
- [ ] Scholar review of religious terminology / methodology-adjacent wording: <!-- TODO: done / pending (surface stays flagged until it lands) -->

---

**Verdict:** <!-- TODO: SHIP / HOLD — and the reason. If any gate above failed, HOLD. iḥsān is the standard, because the work is for Allah. -->
