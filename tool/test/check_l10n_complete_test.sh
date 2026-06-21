#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Red-first meta-test for the localization completeness gate (E09-T02). Each
# layer (key coverage, hardcoded strings, physical sides, ASCII digits, adab) is
# proven to FLIP non-zero against a seeded violation and back to 0 on revert —
# eng-add-ci-check §1: "a gate that passes because it checks nothing is the bug."
# Probes are a throwaway feature file + reversible ARB mutations restored from a
# backup on exit (trap), so a crash never leaves the tree dirty.
set -uo pipefail # not -e: the bad-fixture runs deliberately exit non-zero.

cd "$(dirname "$0")/../.."
fail=0
probe="packages/features/lib/src/__l10n_gate_probe__.dart"
arb="packages/l10n/lib/src/arb/app_ckb.arb"
arb_bak="$(mktemp)"
cp "$arb" "$arb_bak"

cleanup() {
  rm -f "$probe"
  cp "$arb_bak" "$arb" && rm -f "$arb_bak"
}
trap cleanup EXIT

# Run the gate; expect a non-zero exit whose output matches $2. $1 is the label.
expect_fail() {
  local desc="$1" pattern="$2" out
  if out="$(bash tool/check_l10n_complete.sh 2>&1)"; then
    echo "FAIL: gate passed despite $desc" >&2
    fail=1
  elif echo "$out" | grep -qE "$pattern"; then
    echo "ok: gate rejects $desc"
  else
    echo "FAIL: gate rejected $desc but message missing /$pattern/" >&2
    echo "$out" >&2
    fail=1
  fi
}

expect_pass() {
  if bash tool/check_l10n_complete.sh >/dev/null 2>&1; then
    echo "ok: $1"
  else
    echo "FAIL: $1" >&2
    fail=1
  fi
}

# 0. Baseline — the real, clean tree passes.
expect_pass "clean tree passes"

# B. Hardcoded user-facing string literal (Text / tooltip / semanticsLabel).
printf "%s\n" "import 'package:flutter/material.dart';" \
  "Widget a() => const Text('Today');" >"$probe"
expect_fail "a hardcoded Text literal" "hardcoded UI string"
printf "%s\n" "import 'package:flutter/material.dart';" \
  "Widget b() => IconButton(tooltip: 'help', onPressed: null, icon: null);" >"$probe"
expect_fail "a hardcoded tooltip literal" "hardcoded UI string"
rm -f "$probe"
expect_pass "clean again after removing the probe"

# C. Physical-side layout (RTL-breaking).
printf "%s\n" "import 'package:flutter/material.dart';" \
  "final p = const EdgeInsets.only(left: 16);" >"$probe"
expect_fail "EdgeInsets.only(left:)" "physical-side layout"
printf "%s\n" "const a = Alignment.centerLeft;" >"$probe"
expect_fail "Alignment.centerLeft" "physical-side layout"
rm -f "$probe"

# D. ASCII-digit interpolation into a user-facing string.
printf "%s\n" "import 'package:flutter/material.dart';" \
  "Widget c(int n) => Text('Page ' + n.toString());" >"$probe"
expect_fail "a .toString() splice into Text" "raw number splice"
rm -f "$probe"
# D via an ARB value carrying a raw \$-splice.
perl -pe 's/("navToday":\s*")/${1}\$count /' "$arb_bak" >"$arb"
expect_fail "a \$-splice in an ARB value" "raw number splice"
cp "$arb_bak" "$arb"

# A. Key coverage — a key present in ar but missing its ckb value.
grep -v '"navToday":' "$arb_bak" >"$arb"
expect_fail "a missing ckb translation value" "gate 5"
cp "$arb_bak" "$arb"

# E. Banned-phrase (adab) — an exclamation mark in a shipped value.
perl -pe 's/("navToday":\s*"[^"]*)"/${1}!"/' "$arb_bak" >"$arb"
expect_fail "an exclamation mark in shipped copy" "never-ship copy"
cp "$arb_bak" "$arb"

# Final: the restored tree passes again.
expect_pass "restored tree passes"

exit "$fail"
