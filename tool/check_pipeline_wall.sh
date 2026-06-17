#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# check_pipeline_wall.sh — the UI type system (type.*/TextTheme over Vazirmatn/
# Estedad) shares no TextStyle, metric, or shaper with the muṣḥaf glyph pipeline
# (design-system 04 §1; PRD R1). Bans any reference to the quran glyph surface
# from UI-type code — the static half of the "two pipelines, one rule" guarantee,
# complementing check_quran_isolation.sh from the other side of the wall.
#
# Scans packages/features/lib/src + app/lib by default; pass directories to
# override (the meta-test points it at the deliberate-violation fixture). Exits
# non-zero on the first hit. Symbol/import topology only — locale/madhhab-blind.
set -euo pipefail

banned='qpcFontFamily|GlyphPage|glyphCodes|QPC_P[0-9]|loadFontFromList|FontLoader'

dirs=("$@")
if [ ${#dirs[@]} -eq 0 ]; then
  dirs=(packages/features/lib/src app/lib)
fi

# Filter full-line comments so a doc comment that *names* a banned symbol is not
# a false hit; a real use is never a full-line comment.
hits="$(grep -rnE "$banned" "${dirs[@]}" 2>/dev/null \
  | grep -vE '^[^:]+:[0-9]+:[[:space:]]*(//|/\*|\*)' || true)"
if [ -n "$hits" ]; then
  echo "check_pipeline_wall: UI type code references the muṣḥaf glyph pipeline — the wall is breached (PRD R1; design-system 04 §1):" >&2
  echo "$hits" >&2
  exit 1
fi
