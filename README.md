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

## Contributing

Contributions are welcome under the Developer Certificate of Origin (sign off
each commit with `git commit --signoff`); there is no CLA. See
[`CONTRIBUTING.md`](CONTRIBUTING.md).
