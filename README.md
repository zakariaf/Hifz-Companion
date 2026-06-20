<!--
SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Hifz Companion

A fully offline Flutter app, built free as *ṣadaqah jāriyah*, that helps a
ḥāfiẓ never silently lose the Quran — no accounts, no telemetry, no microphone,
no ads.

## License

The app code is **GPL-3.0-or-later** with a GPLv3 §7 App Store additional
permission; see [`LICENSE`](LICENSE). The code-versus-assets split is recorded
in [`LICENSING.md`](LICENSING.md) — the GPL covers code only, never the muṣḥaf
bytes.

## Toolchain

The pinned build baseline is **Flutter 3.41.2 (stable)**. CI pins the same
version on every job (`subosito/flutter-action@v2`, `channel: stable`) — a
floating SDK would silently re-render the muṣḥaf goldens and break the
rebuild-the-bytes reproducibility claim.

## Accessibility

Hifz Companion targets **WCAG 2.2 Level AA** as its explicit conformance bar —
named as **WCAG 2.2 AA**, not 2.1. WCAG 2.2 is a strict, backwards-compatible
superset of 2.1, so naming the newer version claims more, not less, and carries
no regression. The bar is the same across all three languages (fa / ckb / ar).

Two of WCAG 2.2's new success criteria are satisfied **by construction**, not by
a feature we have to maintain:

- **3.3.7 Redundant Entry (Level A)** — there is no account, no login, and no
  data to re-enter; a profile is just a display name the user types, and
  switching profile is a tap.
- **3.3.8 Accessible Authentication (Minimum) (Level AA)** — there is no
  authentication step at all, so there is no cognitive-function test to fail.

Both hold identically in every locale: no language inherits a login, OTP, or
CAPTCHA barrier.

The bar is made measurable, not aspirational, by the release-blocking
accessibility checklist (A1–A9 — contrast, color-independence, 200% text resize,
muṣḥaf zoom-exclusion, touch targets, localized labels, RTL focus/reading order,
and a manual TalkBack/VoiceOver pass in fa/ckb/ar) in
[`docs/design-system/09-accessibility-and-inclusivity.md`](docs/design-system/09-accessibility-and-inclusivity.md),
and enforced in CI by the accessibility audit gate. It is part of the
release gates in [`docs/PRD.md`](docs/PRD.md) (§18, §20).

## Contributing

Contributions are welcome under the Developer Certificate of Origin (sign off
each commit with `git commit --signoff`); there is no CLA. See
[`CONTRIBUTING.md`](CONTRIBUTING.md).
