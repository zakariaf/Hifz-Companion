#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# check_quran_isolation.sh — KFGQPC glyph-font registration and glyph-code-string
# handling live ONLY in packages/quran. Bans cross-package quran/src imports
# everywhere outside quran, and the QPC glyph/font tokens (QCF_…, QCF2…)
# everywhere outside quran EXCEPT the bundled-core integrity manifest, so no
# feature can re-typeset or mishandle the sacred glyph layer (PRD R1).
#
# The one exemption (bundle-first, amended 2026-06-18): the SHA-256 integrity
# manifest in packages/assets must NAME the bundled font FILES (QCF_P###.ttf)
# for build-time/runtime verification. Naming an asset file for hashing is
# acquisition/integrity, not glyph handling — registration and glyph-code
# strings still live only in packages/quran (the rendering family is QPC_P###).
#
# No arguments. Run from the repo root. Exits non-zero on the first violation.
set -euo pipefail

# The font-file integrity manifest is the sole sanctioned place outside quran to
# name QCF_ font FILES (for SHA-256 bookkeeping — never glyph handling).
manifest_exempt='packages/assets/lib/src/pinned_manifest\.dart'

scan_dirs=(app/lib)
for d in packages/*/lib; do
  [ -d "$d" ] || continue
  case "$d" in packages/quran/*) continue ;; esac
  scan_dirs+=("$d")
done

# 1. Cross-package quran/src imports — banned everywhere outside quran, no
#    exemption (the manifest never imports the renderer's internals).
import_hits="$(grep -rnE 'package:quran/src/' "${scan_dirs[@]}" 2>/dev/null || true)"

# 2. QPC glyph/font tokens — banned everywhere outside quran except the manifest.
token_hits="$(grep -rnE 'QCF_|QCF2' "${scan_dirs[@]}" 2>/dev/null \
  | grep -vE "$manifest_exempt" || true)"

hits="$(printf '%s\n%s' "$import_hits" "$token_hits" | grep -vE '^$' || true)"
if [ -n "$hits" ]; then
  echo "check_quran_isolation: QPC glyph/font handling is confined to packages/quran/ (PRD R1):" >&2
  echo "$hits" >&2
  exit 1
fi
