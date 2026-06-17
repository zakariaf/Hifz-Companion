#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# check_quran_isolation.sh — KFGQPC glyph-font registration and glyph-code-string
# handling live ONLY in packages/quran. Bans cross-package quran/src imports and
# the QPC font-family tokens (QCF_…, QCF2…) anywhere else, so no feature can
# re-typeset or mishandle the sacred glyph layer (PRD R1).
#
# No arguments. Run from the repo root. Exits non-zero on the first violation.
set -euo pipefail

banned='package:quran/src/|QCF_|QCF2'

scan_dirs=(app/lib)
for d in packages/*/lib; do
  [ -d "$d" ] || continue
  case "$d" in packages/quran/*) continue ;; esac
  scan_dirs+=("$d")
done

hits="$(grep -rnE "$banned" "${scan_dirs[@]}" 2>/dev/null || true)"
if [ -n "$hits" ]; then
  echo "check_quran_isolation: QPC glyph/font handling is confined to packages/quran/ (PRD R1):" >&2
  echo "$hits" >&2
  exit 1
fi
