#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Meta-test for the pipeline-wall gate (E06-T05): it REJECTS the deliberate-
# violation fixture, PASSES the clean production tree, and catches each banned
# glyph symbol independently (so dropping any one regex alternative is caught).
# A guard with no failing case proves nothing — this is the load-bearing test.
set -uo pipefail # not -e: several steps deliberately expect a non-zero exit.

cd "$(dirname "$0")/../.."
fail=0

if bash tool/check_pipeline_wall.sh test/fixtures/pipeline_wall >/dev/null 2>&1; then
  echo "FAIL: gate did NOT reject the deliberate-violation fixture" >&2
  fail=1
else
  echo "ok: gate rejects the deliberate-violation fixture"
fi

if bash tool/check_pipeline_wall.sh >/dev/null 2>&1; then
  echo "ok: gate passes the clean production tree"
else
  echo "FAIL: gate flagged the clean production tree" >&2
  fail=1
fi

tmp="$(mktemp -d)"
for sym in 'qpcFontFamily(1)' 'GlyphPage()' 'glyphCodes' 'QPC_P0' 'loadFontFromList' 'FontLoader('; do
  printf 'final probe = %s;\n' "$sym" >"$tmp/probe.dart"
  if bash tool/check_pipeline_wall.sh "$tmp" >/dev/null 2>&1; then
    echo "FAIL: gate missed banned symbol '$sym'" >&2
    fail=1
  else
    echo "ok: gate catches '$sym'"
  fi
done
rm -rf "$tmp"

exit "$fail"
