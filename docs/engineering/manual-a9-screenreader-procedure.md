<!--
SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
SPDX-License-Identifier: GPL-3.0-or-later
-->

# A9 — Manual TalkBack + VoiceOver in-language procedure

| | |
|---|---|
| **Gate** | A9 (design-system 09 §10) — release-blocking, **human, on real devices, not automatable** |
| **Conformance bar** | WCAG 2.2 AA ([design-system 09 §1](../design-system/09-accessibility-and-inclusivity.md)) |
| **Authored** | 2026-06-20, against `epic/E08-accessibility-foundation` (E08-T09) |
| **Owner / executor** | **E20 release readiness** runs this on real devices before each release |
| **Automated complements** | A1/A6/A7 (E08-T07 `meetsGuideline`) and A8 (E08-T08 per-locale RTL traversal) must be **green before** this pass begins; this pass verifies the RTL/multilingual 20% they cannot — spoken intelligibility, announcement direction, real-device operability |

This is the human pass that catches what the automated gates structurally cannot.
It is executed **six times**: fa, ckb, ar — each on **TalkBack (Android)** and
**VoiceOver (iOS)**. It is **never** run English-only with an "fa/ckb/ar inherit
it" assumption (the design-system 09 §10 anti-pattern).

## Revision history

| Date | App commit | Device models · OS | Operator | Result |
|---|---|---|---|---|
| _(filled per run by E20)_ | | | | |

## Preconditions (confirm before starting)

- [ ] The automated accessibility gates are **green** on the build under test:
      A1 (`textContrastGuideline`), A6 (`androidTapTargetGuideline` /
      `iOSTapTargetGuideline`), A7 (`labeledTapTargetGuideline`) from **E08-T07**,
      and the per-locale RTL traversal test from **E08-T08**.
- [ ] **Real devices** — at least one physical Android (TalkBack) and one
      physical iOS (VoiceOver). Simulators are **not** sufficient (gestures,
      focus, and announcement timing differ on real hardware).
- [ ] **Airplane mode is ON** for the post-onboarding journeys (J2–J4): the
      offline guarantee (PRD C1, §17) is itself under test — the reader must
      operate the whole daily flow with the radio off.
- [ ] The build's UI **language is set to the locale under test** (fa, then ckb,
      then ar). Run the whole procedure **three times per platform**, once per
      language.

## Journeys

The four sections mirror the `integration_test` journey spine step-for-step, so
the human pass and the automated journeys never diverge.

<!-- journey-id: j1ColdStart -->
### J1 — Cold start (onboarding)

Reader navigates: pick UI language → confirm muṣḥaf / riwāyah → core-pack
download step → coverage (which juz held) taps → per-juz Solid/Shaky/Rusty
rating → cycle preset.

- [ ] Every control is **announced with a localized label** — no English, no
      unlabeled icon.
- [ ] **No microphone prompt** appears anywhere on the path (PRD C2, R5).
- [ ] Reading order is **right-to-left, top-to-bottom**.
- [ ] The **riwāyah name** ("Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf") is spoken.

<!-- journey-id: j2FirstDay -->
### J2 — First day (Today)

Reader reaches the Today list.

- [ ] Each **page-card is read as ONE merged phrase** ("Juz ۷ · page ۱۳۴ · weak"),
      not three fragments.
- [ ] The **track chip and decay state are spoken as words** (never colour
      alone — the never-color-alone label is what the reader voices).
- [ ] Section headers (Far / Near / New) are announced **as headers**.
- [ ] Numerals are spoken in the **locale digit set** (۴۵۶ in fa/ckb, ٤٥٦ in ar).

<!-- journey-id: j3Review -->
### J3 — Review (recite → grade → optional sign-off)

Reader opens the recite flow, reveals the page, grades.

- [ ] The **muṣḥaf is announced by reference** (surah · ayah range · juz), **never
      glyph codepoints** (a regression here is a sacred-text / R1 failure).
- [ ] The grade band (Again / Hard / Good / Easy) is operable, each button
      **labeled with its traditional verb**.
- [ ] "**page graded**" / "**sign-off recorded**" are **announced in reading
      order (RTL)**.
- [ ] The recite confirmation is **calm — no celebratory announcement** (PRD R3,
      C6).

<!-- journey-id: j4Catchup -->
### J4 — Missed-day catch-up

With a gap already present (operator returns after a gap), reader reaches Today.

- [ ] "**catch-up plan ready**" is **announced in RTL**.
- [ ] The banner is spoken as a **calm, supportive** plan — **never** a "you are
      behind" / overdue / shame phrasing (PRD R3).
- [ ] The re-spread list is fully **traversable and labeled**.

## Intelligibility (A9 proper — recorded per locale)

For each step, the operator records not only "labeled" but **"intelligible in
this language's voice"** (Flutter's own testable bar):

- [ ] Numerals are **voiced naturally** (۴۵۶ in fa/ckb, ٤٥٦ in ar).
- [ ] Each run is spoken in the **right pronunciation voice** — Persian / Sorani
      / Arabic (`TextSpan.locale` is set).
- [ ] Announcements are heard **in reading order**, not reversed.

## Pass / fail record

Fill on each run. **Any single fail blocks the release.**

| Check | fa · TalkBack | fa · VoiceOver | ckb · TalkBack | ckb · VoiceOver | ar · TalkBack | ar · VoiceOver |
|---|---|---|---|---|---|---|
| J1 localized labels | | | | | | |
| J1 no microphone prompt | | | | | | |
| J1 RTL reading order | | | | | | |
| J2 page-card one merged phrase | | | | | | |
| J2 track/decay spoken as words | | | | | | |
| J2 locale numerals | | | | | | |
| J3 muṣḥaf announced by reference | | | | | | |
| J3 grade verbs labeled | | | | | | |
| J3 "page graded" announced RTL, calm | | | | | | |
| J4 "catch-up plan ready" announced, calm | | | | | | |
| J4 re-spread list labeled | | | | | | |
| Intelligibility (numerals / voice / order) | | | | | | |

_Footer (per run):_ **Date · device models · OS versions · app commit · operator.**

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
