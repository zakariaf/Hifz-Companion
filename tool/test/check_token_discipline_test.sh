#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Red-first meta-test for the token-discipline gate (E06-T11): a widget with one
# of each banned pattern is REJECTED (all five rules reported), a clean widget
# PASSES. Without this the grep could silently rot to matching nothing.
set -uo pipefail # not -e: the bad-fixture run deliberately exits non-zero.

cd "$(dirname "$0")/../.."
tmp="$(mktemp -d)"
fail=0

cat >"$tmp/bad.dart" <<'DART'
import 'package:flutter/material.dart';
Widget bad() => Container(
      color: const Color(0xFF112233),
      foregroundDecoration: const BoxDecoration(color: Colors.red),
      padding: const EdgeInsets.all(13),
      margin: const EdgeInsets.only(left: 8),
      transform: null,
      child: const Text('x', style: TextStyle(letterSpacing: 2)),
      duration: const Duration(milliseconds: 99),
    );
DART

out="$(dart run tool/check_token_discipline.dart "$tmp" 2>&1)"
if [ $? -eq 0 ]; then
  echo "FAIL: gate did not reject the bad widget" >&2
  fail=1
else
  echo "ok: gate rejects the bad widget"
fi
for rule in 'raw hex' 'Colors.\*' 'off-scale dp' 'physical-side' 'Duration/Curve' 'letterSpacing'; do
  if echo "$out" | grep -qE "$rule"; then
    echo "ok: reported '$rule'"
  else
    echo "FAIL: did not report '$rule'" >&2
    fail=1
  fi
done

cat >"$tmp/good.dart" <<'DART'
import 'package:flutter/material.dart';
Widget good(BuildContext context) {
  final space = Theme.of(context).extension<SpacingTokens>()!;
  return Padding(
    padding: EdgeInsetsDirectional.all(space.space4),
    child: ColoredBox(color: Theme.of(context).colorScheme.surface),
  );
}
DART
rm -f "$tmp/bad.dart"
if dart run tool/check_token_discipline.dart "$tmp" >/dev/null 2>&1; then
  echo "ok: gate passes a token-only widget"
else
  echo "FAIL: gate flagged a clean widget" >&2
  fail=1
fi

rm -rf "$tmp"
exit "$fail"
