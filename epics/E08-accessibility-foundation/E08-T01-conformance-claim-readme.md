<!-- REUSE-IgnoreStart (planning doc quotes SPDX tags as examples; suppress in-file tag parsing — actual coverage is in .reuse/dep5) -->
# E08-T01 — WCAG 2.2 AA conformance claim + the two by-construction criteria recorded in the README

| | |
|---|---|
| **Epic** | [E08 — Accessibility Foundation](EPIC.md) |
| **Size** | S (≈half a day) |
| **Depends on** | E01 |
| **Skills** | eng-write-to-coding-standards |

## Goal

The repo's `README.md` (the stub established in E01-T01) gains a short, honest **Accessibility** section that states **WCAG 2.2 Level AA** as the explicit, measurable conformance bar — claimed as "2.2 AA," never "accessible" unqualified — and records that two of WCAG 2.2's nine new success criteria, **3.3.7 Redundant Entry** and **3.3.8 Accessible Authentication (Minimum)**, are satisfied **by construction** because the app has no account, no login, and no data re-entry. The section names the standard, points readers at the live audit (the §10 release-blocking checklist A1–A9, wired by the rest of this epic) so the claim is auditable rather than aspirational, and adds no number that would need a CLAIMS row. This is the **documentation half** of the accessibility contract — prose and provenance only; no Dart, no widget, no test code lands here, and the measurable gates that make the claim true ship in E08-T07/T08/T10.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/design-system/09-accessibility-and-inclusivity.md` §1 | The exact, load-bearing statement: Mihrab targets **WCAG 2.2 Level AA**, "documented as the explicit conformance bar," claimed **2.2 not 2.1** because 2.2 is a strict backwards-compatible superset (the claim is honest and regression-free). The anti-pattern this task forecloses verbatim: *"Claim 'accessible' without naming the standard and level — the claim is 'WCAG 2.2 AA,' auditable against this file's checklist."* The README is named in §1 ("In practice") as where the claim is **stated**, with §3–§8 making it measurable and §10 gating it. |
| `docs/design-system/09-accessibility-and-inclusivity.md` §2 | The two by-construction wins, with their exact levels and reason: **3.3.7 Redundant Entry (A)** and **3.3.8 Accessible Authentication (Minimum) (AA)** are satisfied *by construction* — the app has **no account, no login, no authentication, no data re-entry**; a profile is just a display name the user types, a profile switch is a tap (never a credential), and this holds identically in fa/ckb/ar (no locale inherits a login/OTP/CAPTCHA barrier). The framing rule: state it plainly "so reviewers see the floor we start from rather than re-deriving it." |
| `docs/design-system/09-accessibility-and-inclusivity.md` §9, §10 | §9 — offline / no-account / no-microphone / no-motion are accessibility wins to **bank and state**, not problems to solve (the README's no-mic/no-account promise from E01-T01 already carries the no-mic half; this task adds the *named conformance* layer). §10 — the release-blocking checklist **A1–A9** is what makes "2.2 AA" measurable; the README sentence must point at that checklist as the live audit, not restate its rows. The README claim **does not gate the build by itself** — A1–A9 do (E08-T07/T08/T09/T10). |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §7, §8 | §7 — the four gated obligations (localized semantic labels; honored `MediaQuery.textScaler`; ≥4.5:1 contrast + never-color-alone; ≥48 dp targets) the claim is backed by. §8 — the layered localization & accessibility gate table whose `SemanticsTester` + manual TalkBack/VoiceOver row this epic owns; cited only so the README points at *where* "2.2 AA" is enforced, not to re-document it here. |
| `docs/PRD.md` §17, C1/C2 | **No account, no login, no PII** (§17, C1) — the architectural root of the 3.3.7/3.3.8 by-construction claim; **no microphone / no audio** (§17, C2) — the banked no-voice-input win the README already states. The Accessibility section is added beside the existing E01-T01 promise prose; it neither weakens nor restates the offline/no-mic/no-account lines, it *names the standard* they help satisfy. |
| `docs/PRD.md` §18 | The PRD's plain-language accessibility requirements (RTL + large text, Quran zoom, contrast, never-color-alone, semantic labels, large targets) this epic makes precise; the README sentence is the public statement that PRD §18 is met to a **named, citable bar**, not a list of features. |
| Skill `eng-write-to-coding-standards` (§4) | This is a **documentation** change, so the code-level rules are mostly N/A; what governs is §4's prose discipline carried to README text — an honest claim that names its standard (no superlative, no marketing), no number that would need a CLAIMS row, and the REUSE SPDX provenance convention preserved on the edited file. The README is developer-facing English (E01-T01 §8), **not** an ARB user-facing string — so this task touches no `l10n` file. |
| CLAIMS register | **None apply.** "WCAG 2.2 AA" is a named external engineering/accessibility *standard* the app conforms to, not a user-facing factual claim about hifz, memory, or methodology shown on a screen — so it creates and cites **no** `docs/science/CLAIMS.md` row (same treatment as the E01-T01 README promise). No on-screen number, scheduling rule, science copy, notification, or methodology claim is introduced. |
| Siblings: E08-T02 … E08-T10 | This task ships the **claim**; the siblings ship the **proof** it points at. **T02** (semantics conventions), **T03/T04** (text-scale + muṣḥaf exclusion seam), **T05** (reduce-motion), **T06** (never-color-alone) implement the criteria; **T07** wires the PR-blocking `meetsGuideline` audit (A1/A6/A7); **T08** the per-locale RTL traversal test (A8); **T09** records the A9 manual TalkBack/VoiceOver procedure; **T10** proves the gate fails on a deliberate violation. The README section's "live audit" pointer is the human-readable index of T07–T10's machinery. This task **depends only on E01** (the README must already exist) and **precedes** none of them mechanically, but is the contract they make true. |

## Implementation notes

This task writes **prose and a documentation pointer** into an existing Markdown file — there is **no correctness-critical Dart**, so the test-first discipline does not apply; verification is a presence/wording check plus `reuse lint` staying green (see Tests). Touch only `README.md`; create no `.dart`, no `l10n` ARB key, no CI workflow.

1. **File**: edit the repo-root `README.md` established by **E01-T01** (the stub with the one-sentence promise + "License"/"Contributing" sections). Add **one** new `## Accessibility` section; do not rewrite or "improve" the E01-T01 promise paragraph, the License section, or the Contributing section (surgical change — every edited line traces to this task).

2. **The conformance sentence** (the load-bearing line). State, in plain developer-facing English: *Hifz Companion targets **WCAG 2.2 Level AA** as its explicit conformance bar* — and immediately make the claim honest by naming **2.2 specifically, not 2.1** (2.2 is a strict, backwards-compatible superset, so the claim carries no regression), exactly the design-system 09 §1 framing. Use the words "WCAG 2.2 AA"; **never** write "fully accessible," "100% accessible," or "accessible" unqualified — naming the standard *is* the honesty.

3. **The two by-construction criteria.** Record, as a short list or sentence, that **3.3.7 Redundant Entry (Level A)** and **3.3.8 Accessible Authentication (Minimum) (Level AA)** are satisfied **by construction**: the app has **no account, no login, no authentication, and no data re-entry** — a profile is a display name; a profile switch is a tap, never a credential — so there is no cognitive-function test to fail and nothing to re-enter, in any locale (fa/ckb/ar). Keep the levels (A / AA) correct, per design-system 09 §2; an inflated level is a dishonest claim.

4. **The live-audit pointer** (so the claim is auditable, not aspirational). One sentence that the bar is **made measurable** by the release-blocking accessibility checklist (design-system 09 §10, A1–A9: contrast, color-independence, 200% text resize, muṣḥaf zoom-exclusion, touch targets, localized labels, RTL focus/reading order, and the manual TalkBack/VoiceOver pass in fa/ckb/ar) and **enforced** in CI by the accessibility audit gate (this epic's E08-T07/T08, the localization & accessibility gate of engineering 12 §8). Link to `docs/design-system/09-accessibility-and-inclusivity.md` and `docs/PRD.md` §18/§20 so a reader can verify; do **not** copy the A1–A9 rows into the README (avoid the drift of a duplicated checklist).

5. **Tone and provenance.** Calm, factual, no superlative, no marketing, no badge image — consistent with the E01-T01 README style and the adab discipline (built free, seeking the pleasure of Allah). Preserve the file's existing REUSE SPDX header (`SPDX-FileCopyrightText` / `SPDX-License-Identifier: GPL-3.0-or-later`); do not introduce a number that would need a CLAIMS row.

6. **Pitfalls to avoid.** (a) Writing "accessible" / "fully accessible" unqualified — the whole task is to make the claim *named and honest*. (b) Inventing a level (claiming 3.3.8 at AAA, or claiming AAA conformance) — only WCAG 2.2 **AA** is the bar, with 3.3.7 at A and 3.3.8 at AA. (c) Pasting the A1–A9 table into the README so it can drift out of sync with design-system 09 §10 — link, don't duplicate. (d) Adding the claim as an **ARB string / in-app screen** — that is the "The science we follow"-adjacent surface owned elsewhere; this is *developer-facing README documentation*, no `l10n` key. (e) Implying the README sentence itself gates the build — the **gates** that make it true ship in E08-T07/T08/T10; the README *records and points at* them. (f) Rewriting adjacent E01-T01 prose, badges, or the License/Contributing sections. (g) Claiming 2.1 (a regression) or "WCAG-compliant" (unversioned, unleveled, dishonest).

## Acceptance criteria

- [ ] `README.md` contains a single new `## Accessibility` section; the E01-T01 promise paragraph, License section, and Contributing section are unchanged (diff touches only the added section + any necessary blank-line separators).
- [ ] The section states **WCAG 2.2 Level AA** as the explicit conformance bar and names **2.2, not 2.1** (the backwards-compatible-superset honesty), using the literal phrase "WCAG 2.2 AA" (or "WCAG 2.2 Level AA").
- [ ] The word "accessible" never appears **unqualified** (no "fully accessible" / "100% accessible" / bare "accessible" as the claim); every accessibility claim names the standard and level.
- [ ] The section records **3.3.7 Redundant Entry (A)** and **3.3.8 Accessible Authentication (Minimum) (AA)** as satisfied **by construction**, with the correct levels, and states the reason: **no account, no login, no authentication, no data re-entry** (a profile is a display name; a switch is a tap, not a credential), holding in all three locales.
- [ ] The section points at the **live audit** — the release-blocking checklist (design-system 09 §10, A1–A9) and the CI accessibility gate (this epic's harness) — via working relative links to `docs/design-system/09-accessibility-and-inclusivity.md` and `docs/PRD.md` (§18/§20); it does **not** duplicate the A1–A9 rows inline.
- [ ] No number, percentage, or superlative that would need a CLAIMS row is introduced; the prose is plainly factual and reverent, matching the E01-T01 README tone.
- [ ] The file still carries its REUSE SPDX header; `reuse lint` exits **0** on the repository after the edit.
- [ ] No `.dart`, no `l10n` ARB key, no CI workflow, and no in-app screen is added by this task.

## Tests

This task ships **no Dart**, so there are **no unit / widget / golden / integration tests** — by construction the deliverable is README prose, and verification is tool-driven and manual (mirroring E01-T01):

- **`reuse lint` (the machine gate).** Run `reuse lint`; the edited `README.md` must remain covered by its SPDX header and the run must exit **0** — no file unaccounted-for, no bad license. This keeps the trust-pack provenance gate green across the edit.
- **Claim-presence + honesty check (manual, recorded).** Confirm the `## Accessibility` section names **WCAG 2.2 AA** (2.2, not 2.1), records **3.3.7 (A)** and **3.3.8 (AA)** as by-construction with the no-account reason, and points at the §10 checklist + CI gate. A grep for the unqualified word "accessible" used *as the claim* (e.g. `grep -niE 'fully accessible|100% accessible|is accessible\b' README.md`) must return **nothing** — the dishonest-claim anti-pattern is mechanically absent.
- **Link-resolution check (manual).** The relative links to `docs/design-system/09-accessibility-and-inclusivity.md` and `docs/PRD.md` resolve from the repo root.
- **Surgical-diff check (manual).** Confirm the diff adds only the new section and leaves the E01-T01 promise, License, and Contributing prose byte-unchanged.
- **Offline / no-network guard:** N/A by construction — no code, no dependency, no network path is introduced; nothing here can reach a socket (the throwing-`HttpOverrides` test bootstrap is E01-T06; this task adds no runtime surface to guard).

## Definition of Done

- [ ] All acceptance criteria met; `reuse lint` green locally on the committed tree; the claim-presence, honesty-grep, link-resolution, and surgical-diff checks pass and are self-annotated in the PR body.
- [ ] **Honest accessibility claim (this epic's subject):** the conformance claim is **WCAG 2.2 AA**, named and leveled — never "accessible" unqualified — and is recorded as the explicit, measurable bar that the §10 A1–A9 gates (E08-T07/T08/T09/T10) make true; the README points at that audit rather than asserting accessibility without proof (design-system 09 §1, §10).
- [ ] **Offline / no-network (non-negotiable):** N/A by construction — this task adds no code, no dependency, and no network path; it cannot weaken the offline guarantee, and the README's no-telemetry/offline promise (PRD C1, §17) is left intact beside the new section.
- [ ] **No AI / no microphone (non-negotiable):** N/A by construction — no code; the README already states the no-microphone / no-AI promise (PRD C2, §17), and §9's "no-mic = a banked accessibility win" framing is implicitly served by the new section without re-opening it.
- [ ] **Quran text fidelity (non-negotiable):** N/A — no muṣḥaf bytes, no glyph font, no layout data is touched; the conformance section makes no claim that would invite OS-scaling or re-typesetting the sacred text (the muṣḥaf scaling-exclusion seam is E08-T04).
- [ ] **RTL + fa/ckb/ar strings:** N/A — the README is developer-facing English documentation (E01-T01 §8), not user-facing app copy; **no ARB key, no in-app string** is introduced; the by-construction claim is explicitly stated to hold identically in fa/ckb/ar (no locale inherits a login/OTP barrier).
- [ ] **Accessibility:** N/A as a UI surface — this task adds no widget to label, scale, or audit; it is the *documentation half* of the contract whose UI surfaces are E08-T02…T08.
- [ ] **Sect-neutral adab:** the new section carries no madhhab/sect framing, no fiqh ruling, no gamification, no guilt/loss copy, and no superlative; the prose is calm, factual, and reverent (built free, seeking the pleasure of Allah) — consistent with `domain-adab-and-religious-integrity`.
- [ ] **Deterministic tests:** N/A — no tests authored; the verification (`reuse lint`, presence/honesty grep, link and diff checks) is itself deterministic and re-runnable by any reviewer.
- [ ] PR is one concern (the README conformance section), ≤~400 changed LOC (a few lines), intent described, the honesty-grep and surgical-diff self-annotated; the PR-template Localization & RTL / Every-PR rows applied (most N/A-by-construction and marked so).

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
