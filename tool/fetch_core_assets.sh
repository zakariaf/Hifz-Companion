#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# fetch_core_assets.sh — the reproducible build-time sourcing of the bundled
# core muṣḥaf (engineering 09 §4; PRD §11.1). Downloads the co-versioned asset
# set into a local, git-ignored working dir, renames the per-page fonts to the
# manifest convention, then runs the manifest generator to pin every SHA-256.
#
# This is a BUILD/AUDIT-time script — NOT a runtime path. The app is offline;
# the core is bundled. Whether the fetched bytes are then committed to the repo
# or fetched-and-verified at build time is an OPEN decision (E05-T05/T10).
#
# Sources (verified reachable 2026-06-18):
#   - Tanzil Uthmani text  — tanzil.net download API (CC BY 3.0, verbatim + attribution)
#   - QPC V2 per-page fonts — QUL/Tarteel CDN, 604 unmodified TTFs (KFGQPC terms)
#   - QPC V2 layout — PARTIAL from the public quran.com API (api.quran.com): per
#     word, the code_v2 glyph code + line_number + position + page_number (+
#     text_uthmani / sajdah). VERIFIED LIMITATION (2026-06-18): this is the
#     AYAH-WORD layer ONLY — it does NOT include the muṣḥaf's decorative
#     sūra-header and standalone-basmala lines (e.g. page 1 ayah words start at
#     line 2, page 2 at line 3; lines 1-2 are header/basmala and are absent).
#     The `line` reference table needs those line types explicitly, so the
#     COMPLETE layout requires QUL's sign-in-gated mushaf-layout export
#     (qul.tarteel.ai/resources/mushaf-layout). Inferring decorative lines from
#     gaps would be GUESSING the muṣḥaf structure (R1 forbids it) — use the QUL
#     export. The public API still serves the ayah-word glyph layer + text.
#
# Usage:  bash tool/fetch_core_assets.sh
set -euo pipefail

DEST="${1:-assets-src/core}"
FONT_BASE="https://static-cdn.tarteel.ai/qul/fonts/quran_fonts/v2/ttf"
FONT_VER="v=3.1"
TANZIL_URL="https://tanzil.net/pub/download/index.php?quranType=uthmani&outputType=txt&agree=true"
PAGE_COUNT="${PAGE_COUNT:-604}"

mkdir -p "$DEST"

echo "→ Tanzil Uthmani text → $DEST/quran-uthmani.txt"
curl -fsSL --max-time 60 "$TANZIL_URL" -o "$DEST/quran-uthmani.txt"
# NOTE: the bundled text format ('quran-uthmani.db' in the manifest) is
# normalized from this verbatim text by E05-T05's reference-data load.

echo "→ QPC V2 per-page TTFs (1..$PAGE_COUNT) → $DEST/QCF_P###.ttf"
for n in $(seq 1 "$PAGE_COUNT"); do
  out="$(printf '%s/QCF_P%03d.ttf' "$DEST" "$n")"
  # QUL ships them as p{n}.ttf; rename to the manifest convention. The font file
  # is copied UNMODIFIED (KFGQPC terms: free redistribution, no modification) —
  # only the on-disk file name changes, never the font's internal family.
  curl -fsSL --max-time 60 "$FONT_BASE/p${n}.ttf?$FONT_VER" -o "$out"
done

echo "→ QPC V2 layout (glyph codes + line/position) from the public quran.com API"
mkdir -p "$DEST/layout"
API="https://api.quran.com/api/v4/verses/by_page"
QUERY="words=true&word_fields=code_v2,line_number,position,page_number&fields=text_uthmani,sajdah_number&per_page=300"
for n in $(seq 1 "$PAGE_COUNT"); do
  out="$(printf '%s/layout/page-%03d.json' "$DEST" "$n")"
  curl -fsSL --max-time 60 "$API/${n}?$QUERY" -o "$out"
done
# E05-T05 normalizes these per-page responses into the bundled layout-qul.* and
# the reference tables (page/line/word + glyph codes), keyed by verse + position.

echo "→ Pinning hashes into the binary-baked manifest"
dart run tool/gen_core_manifest.dart --assets-dir "$DEST" --page-count "$PAGE_COUNT"

echo "→ Authoritative Tanzil Uthmani SHA-256 (the E05-T10 anchor):"
if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "$DEST/quran-uthmani.txt" | awk '{print "    "$1}'
else
  sha256sum "$DEST/quran-uthmani.txt" | awk '{print "    "$1}'
fi

echo "Done. Next: wire the pinned manifest + the Tanzil anchor into E05-T10's"
echo "real gate, build E05-T05's loader against the layout schema, and seed the"
echo "E05-T11 goldens from SCHOLAR-APPROVED reference images (PRD §20.8 / E20)."
