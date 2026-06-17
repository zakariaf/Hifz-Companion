<!--
SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Licensing

The app's GPL covers **code only** — it never covers the muṣḥaf bytes. The
Quran text, the page glyph fonts, and the mutashābihāt dataset live in the
separate Quran-data repository under their own source licenses and are never
relicensed here.

| Component | Repo | License | Notes |
|---|---|---|---|
| App code | this repo | **GPL-3.0-or-later** + §7 App Store exception | copyleft = *waqf* in law |
| Quran text | data repo | Tanzil verbatim + attribution | never relicensed ([asset packs & offline integrity](docs/engineering/09-asset-packs-and-offline-integrity.md)) |
| Page glyph fonts | data repo | KFGQPC font terms (verify redistribution) | NonFreeAssets risk if restrictive ([asset packs & offline integrity](docs/engineering/09-asset-packs-and-offline-integrity.md)) |
| Mutashābihāt dataset | data repo | CC-BY (scholar-reviewed) | open so it can be audited/corrected ([asset packs & offline integrity](docs/engineering/09-asset-packs-and-offline-integrity.md)) |

The repository is [REUSE](https://reuse.software/) 3.x compliant: every file
carries an `SPDX-License-Identifier` and `SPDX-FileCopyrightText`, full license
texts live in `LICENSES/`, and `reuse lint` runs in CI. See [`LICENSE`](LICENSE)
for the GPL-3.0 text and the verbatim GPLv3 §7 App Store additional permission.
