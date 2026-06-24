<!--
SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Core muṣḥaf assets (not committed)

This directory holds the bundled-core muṣḥaf assets at build time, but they are
**deliberately not committed** to this repository:

- `quran-data.xml` — Tanzil Uthmani metadata (CC BY 3.0, verbatim + attribution)
- `qpc-v2-15-lines.db` — QUL page layout (QUL terms)
- `qpc-v2.db` — QUL word-by-word glyph codes (QUL terms)
- `fonts/QCF_P001.ttf … QCF_P604.ttf` — the 604 KFGQPC QPC V2 per-page glyph
  fonts (KFGQPC terms; redistribution unverified)

These are sacred third-party files under their own upstream licenses and are
**never relicensed here** (see `LICENSING.md`). They live in the separate
Quran-data repository and are obtained at run time via the **one-time asset-pack
download** (CLAUDE.md §8; `domain-asset-pack-integrity`), then SHA-256-verified
against the pinned manifest before the reader will render. Only this `README.md`
and `fonts/.gitkeep` are tracked, so a fresh checkout still resolves the pubspec
asset directory declarations.

To build/run locally before the downloader is wired, place the verified asset
files in this directory (and the fonts under `fonts/`). The `.gitignore` keeps
the real `*.xml` / `*.db` / `*.ttf` files untracked.
