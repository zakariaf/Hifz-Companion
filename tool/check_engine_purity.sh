#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# check_engine_purity.sh — the scheduling engine is pure Dart: no Flutter, no
# dart:io, no dart:ui, and no wall-clock read ("today" is always an injected
# CalendarDate). Bans the symbol-level DateTime.now()/.timestamp() reads the
# analyzer import-path ban cannot see (PRD §19.1).
#
# No arguments. Run from the repo root. Exits non-zero on the first violation.
set -euo pipefail

banned='package:flutter|dart:io|dart:ui|DateTime\.now\(|DateTime\.timestamp\('

hits="$(grep -rnE "$banned" packages/engine/lib packages/engine/test 2>/dev/null || true)"
if [ -n "$hits" ]; then
  echo "check_engine_purity: the engine must stay pure — no Flutter/dart:io/dart:ui/wall clock (PRD §19.1):" >&2
  echo "$hits" >&2
  exit 1
fi
