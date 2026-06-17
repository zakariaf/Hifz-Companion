#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# check_l10n_complete.sh — (a) zero missing ARB keys across ar/fa/ckb (the three
# locale key sets must be identical), and (b) no hardcoded user-facing
# Text('literal') in app/lib or packages/features/lib (every string resolves
# through l10n.*). PRD §20 gate 5. Pure shell — no ARB-parser dependency.
#
# No arguments. Run from the repo root. Exits non-zero on the first violation.
set -euo pipefail

arb_dir=packages/l10n/lib/src/arb
status=0

# Top-level (2-space-indented) message keys, excluding @-metadata keys and their
# nested fields.
keys_of() {
  grep -E '^  "[^@"][^"]*"[[:space:]]*:' "$1" |
    sed -E 's/^  "([^"]+)".*/\1/' | sort -u || true
}

ar_keys="$(keys_of "$arb_dir/app_ar.arb")"
fa_keys="$(keys_of "$arb_dir/app_fa.arb")"
ckb_keys="$(keys_of "$arb_dir/app_ckb.arb")"

# (a) Every locale key set must be a superset of every other (i.e. identical).
check_superset() {
  local from_name="$1" from_keys="$2" to_name="$3" to_keys="$4" diff
  diff="$(comm -23 <(printf '%s\n' "$from_keys") <(printf '%s\n' "$to_keys"))"
  if [ -n "$diff" ]; then
    echo "check_l10n_complete: ARB key(s) in $from_name missing from $to_name (PRD §20 gate 5):" >&2
    echo "$diff" >&2
    status=1
  fi
}
check_superset ar "$ar_keys" fa "$fa_keys"
check_superset ar "$ar_keys" ckb "$ckb_keys"
check_superset fa "$fa_keys" ar "$ar_keys"
check_superset ckb "$ckb_keys" ar "$ar_keys"

# (b) No hardcoded user-facing string literal in a Text(...) constructor.
hardcoded="$(grep -rnE "Text\([[:space:]]*['\"]" app/lib packages/features/lib 2>/dev/null || true)"
if [ -n "$hardcoded" ]; then
  echo "check_l10n_complete: hardcoded UI string(s) — resolve via l10n.* (PRD §20 gate 5):" >&2
  echo "$hardcoded" >&2
  status=1
fi

exit "$status"
