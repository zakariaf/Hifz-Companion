<!--
SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
SPDX-License-Identifier: GPL-3.0-or-later
-->

# E08 accessibility audit harness

The PR-blocking accessibility gate (WCAG 2.2 AA — see the repo `README.md` and
[design-system 09 §10](../../../../docs/design-system/09-accessibility-and-inclusivity.md)).
It runs over the **real** E07 shell chrome (`MihrabNavigationBar` + the four
inert placeholder cards — the widgets `HomeShell` composes), never a toy widget.

| Suite | Lane | Asserts |
|---|---|---|
| `shell_tap_target_audit_test.dart` | fast | A6 — `androidTapTargetGuideline` (48dp) + `iOSTapTargetGuideline` (44pt) |
| `shell_label_audit_test.dart` | fast | A7 — `labeledTapTargetGuideline` + localized-label tree walk |
| `shell_contrast_audit_test.dart` | golden | A1 — `textContrastGuideline` per appearance + at 200% (real fonts) |
| `shell_traversal_rtl_test.dart` | fast | A8 — RTL focus/reading order = visual order (fa/ckb/ar, real fonts) |
| `redundant_encoding_audit_test.dart` | fast | A3/§4 — never-color-alone (`assertStateChipRedundancy`) |
| `gate_discriminates_test.dart` | fast | the matchers reject broken stubs / accept good ones (gate not vacuous) |

`accessibility_audit.dart` and `_a11y_test_bootstrap.dart` are shared helpers
(not `_test.dart`). A9 — the human TalkBack/VoiceOver pass — is **not** here:
it is [`docs/engineering/manual-a9-screenreader-procedure.md`](../../../../docs/engineering/manual-a9-screenreader-procedure.md),
executed by E20.

## How to prove this gate still checks something (E08-T10)

A gate that cannot go red asserts nothing. Re-validate it whenever a gate rule
changes by making each violation against the **real** shell, confirming the named
check goes red, then **reverting** (never commit a red test — that would break
the four-jobs-green DoD). The `gate_discriminates_test.dart` self-test keeps a
*green* proof that the matchers reject broken stubs; the table below is the
manual re-validation against the real `HomeShell`.

| # | Violation | One-line break | Goes red | Revert |
|---|---|---|---|---|
| A7 | **Unlabeled control** | drop `label:` from one `labeled(...)` nav destination in `MihrabNavigationBar._Tab` | `labeledTapTargetGuideline` + the label-presence walk | restore `label:` |
| A6 | **Sub-48dp target** | wrap one nav destination in `SizedBox(width: 40, height: 40)` | `androidTapTargetGuideline` (and `iOSTapTargetGuideline` at 44pt) | remove the `SizedBox` |
| A1 | **Below-floor contrast** | override one `color.text.*`/`color.bg.*` pair to a sub-4.5:1 combination in the contrast test's pumped theme (never a committed E06 token change) | `textContrastGuideline` (golden lane) | restore the theme |
| A3/§4 | **Color-only state** | strip the icon + label from one `StateChip` so only hue differs | `assertStateChipRedundancy` | restore the shape + label |

Last manually re-validated: **2026-06-20** (E08-T10) — each violation flipped its
check red against the real shell and reverted green.

## Epic DoD sweep (E08)

Each non-negotiable, with the concrete in-tree proof:

- **Text fidelity** — the E08-T04 scaling-exclusion seam asserts the muṣḥaf
  layout data is byte-identical under every `TextScaler`; no audit derives from a
  QPC glyph codepoint; the reader is fed the `PageReference`. (`packages/quran/test/mushaf_scaling_exclusion_seam_test.dart`)
- **Offline / no-AI / no-mic** — the throwing `HttpOverrides` is installed in
  every a11y test; no `http`/`dio`/`HttpClient`/`drift`/ASR/model import is
  reachable from `features/test/a11y`; E01's no-network + allow-list gates green.
- **RTL fa/ckb/ar labels** — every audited label resolves through
  `AppLocalizations`; the contrast/traversal suites load the real bundled UI
  fonts (never `Ahem`); the A8 traversal test is green in all three locales.
- **Reduce-motion** — `ReduceMotionSwitcher` collapses the Today reveal to an
  instant cut under the OS flag; no celebratory/flashing motion re-appears.
- **Never-color-alone** — every `StateChip` carries color + shape + label, and a
  color-only chip fails `assertStateChipRedundancy`.
- **No streak/score surface** — no streak/badge/confetti/celebration phrasing and
  no "safe to drop"/optional-page wording in any new a11y copy (the announce and
  state ARB keys are calm/adab, flagged PROVISIONAL).
