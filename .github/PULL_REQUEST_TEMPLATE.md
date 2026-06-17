<!--
SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
SPDX-License-Identifier: GPL-3.0-or-later
-->

**Every PR**
- [ ] Description states intent, approach, and anything not inferable from the diff ([Bacchelli & Bird](https://dl.acm.org/doi/10.5555/2486788.2486882): understanding is the bottleneck)
- [ ] ≤ ~400 changed LOC; author self-annotated non-obvious hunks before review ([SmartBear/Cisco](https://static0.smartbear.co/support/media/resources/cc/book/code-review-cisco-case-study.pdf))
- [ ] `dart format`, `dart analyze --fatal-infos`, `dart fix --dry-run` clean; tests green
- [ ] No new dependency; any `pubspec.lock` change explained (no analytics/ads/backend/crash SDK — Decision log: *no networking*)
- [ ] New/changed public APIs have `///` docs; every comment touched by this change is still true ([Wen et al. 2019](https://dl.acm.org/doi/10.1109/ICPC.2019.00019))

**Sacred text & rendering** (touches `quran/`, asset packs)
- [ ] Quran bytes unchanged; pinned SHA-256 still matches; no runtime line-breaking; markers stay coordinate overlays, never re-typeset text (PRD R1, [08](08-quran-data-and-immutable-rendering.md))

**Scheduling correctness** (touches `engine/`)
- [ ] `engine/` still imports no Flutter/Riverpod/Drift/`dart:io`; "today" still injected
- [ ] Trust clamp holds (`dueAt ≤ cycle ceiling`); manzil never silently dropped; nothing implies a page is "safe to drop" (PRD §7.6, §7.12)
- [ ] New behavior covered by golden/property tests; sacred-text guard (dropped word ≠ "Good") intact ([06](06-scheduling-engine.md), [11](11-testing-strategy.md))

**Dates & calendars** (touches date math)
- [ ] No `DateTime` below the boundary; all scheduling math is `CalendarDate` integer-day arithmetic ([07](07-dates-calendars-and-correctness.md))

**Persistence & privacy**
- [ ] Every mutation flows through the single write path; persisted transactionally before state republishes ([05](05-persistence-and-encryption.md))
- [ ] No bare `catch`, no swallowed write errors, no `!`/`late` shortcuts on engine/persistence values (§5)
- [ ] No `print`/`debugPrint`/logging of user data; no networking outside the downloader (§5, §7.2)

**Localization & RTL** (touches user-facing strings)
- [ ] No hardcoded user-facing strings; new keys in all three ARB locales; numerals/calendar per locale ([12](12-localization-rtl-accessibility-impl.md))

**Trust-critical modules** (`engine/`, `data/`, `quran/`, downloader)
- [ ] Full checklist applied to 100% of changed lines; AI reviewer's written findings attached ([McIntosh et al. 2014](https://dl.acm.org/doi/10.1145/2597073.2597076): participation, not rubber-stamps)
