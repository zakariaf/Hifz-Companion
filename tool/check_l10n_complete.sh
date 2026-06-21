#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# check_l10n_complete.sh — the structural (non-golden) half of the localization
# & RTL completeness gate (PRD §20 gate 5; engineering 12 §8). Layered, mostly
# grep-based, always-on. Layers:
#   A  key coverage      — every ar/fa/ckb key set is identical (a missing
#                          translation value codegen would silently fall back on).
#                          The COMPILE half (a referenced-but-undefined l10n.*
#                          getter fails `analyze --fatal-infos`) rides E09-T01's
#                          `nullable-getter: false`; this is the cheap pre-codegen
#                          guard.
#   B  hardcoded strings — no string literal in Text(…)/tooltip:/semanticsLabel:/
#                          label: across app/lib + features/lib (every user-facing
#                          string resolves through l10n.*).
#   C  physical sides    — no EdgeInsets.only(left:/right:), physical Alignment
#                          corner, or Positioned(left:/right:) — only *Directional
#                          / start / end pass (all three locales are RTL).
#   D  ASCII digits      — no raw $int / .toString() splice into Text(…) or an ARB
#                          value; counts go through numberFormatFor(locale) (T06).
#   E  banned-phrase adab — tool/check_adab_lint.dart over every ARB value.
# Scope is chrome only: app/lib + packages/features/lib. NEVER packages/quran
# (the immutable glyph layer) or packages/engine (locale-free). The canonical-ckb
# encoding lint (ZWNJ/Teh-Marbuta) is a SEPARATE gate (E09-T03), not here.
#
# No arguments. Run from the repo root. Exits non-zero if any layer finds a
# violation; prints a named ::error:: per layer citing the rule.
set -euo pipefail

arb_dir=packages/l10n/lib/src/arb
roots=(app/lib packages/features/lib)
status=0

# A grep line that is a full-line comment ("// /// /* *") — a doc comment that
# *names* a banned token is not a violation.
comment='^[^:]+:[0-9]+:[[:space:]]*(//|/\*|\*)'

# ── Layer A — key coverage (pre-codegen superset; compile half is `analyze`). ──
keys_of() {
  grep -E '^  "[^@"][^"]*"[[:space:]]*:' "$1" |
    sed -E 's/^  "([^"]+)".*/\1/' | sort -u || true
}
ar_keys="$(keys_of "$arb_dir/app_ar.arb")"
fa_keys="$(keys_of "$arb_dir/app_fa.arb")"
ckb_keys="$(keys_of "$arb_dir/app_ckb.arb")"

check_superset() {
  local from_name="$1" from_keys="$2" to_name="$3" to_keys="$4" diff
  diff="$(comm -23 <(printf '%s\n' "$from_keys") <(printf '%s\n' "$to_keys"))"
  if [ -n "$diff" ]; then
    echo "::error::check_l10n_complete: ARB key(s) in $from_name missing from $to_name (PRD §20 gate 5):" >&2
    echo "$diff" >&2
    status=1
  fi
}
check_superset ar "$ar_keys" fa "$fa_keys"
check_superset ar "$ar_keys" ckb "$ckb_keys"
check_superset fa "$fa_keys" ar "$ar_keys"
check_superset ckb "$ckb_keys" ar "$ar_keys"

# ── Layer B — hardcoded user-facing string literal. ──
# A literal first character after Text(/tooltip:/semanticsLabel:/label: is the
# violation; `Text(l10n.x)` / `label: l10n.x` (no quote) passes.
hardcoded="$(grep -rnE "(Text\(|tooltip:|semanticsLabel:|label:)[[:space:]]*['\"]" "${roots[@]}" 2>/dev/null |
  grep -vE "$comment" | grep -v '/generated/' || true)"
if [ -n "$hardcoded" ]; then
  echo "::error::check_l10n_complete: hardcoded UI string — resolve via l10n.* (PRD §20 gate 5; engineering 12 §1):" >&2
  echo "$hardcoded" >&2
  status=1
fi

# ── Layer C — physical-side layout (RTL-breaking). ──
physical="$(grep -rnE "EdgeInsets\.only\([[:space:]]*(left|right):|Alignment\.(center|top|bottom)(Left|Right)|Positioned\([[:space:]]*(left|right):" "${roots[@]}" 2>/dev/null |
  grep -vE "$comment" | grep -v '/generated/' || true)"
if [ -n "$physical" ]; then
  echo "::error::check_l10n_complete: physical-side layout — use EdgeInsetsDirectional/AlignmentDirectional/start/end (engineering 12 §2; PRD §13.2):" >&2
  echo "$physical" >&2
  status=1
fi

# ── Layer D — ASCII-digit interpolation into a user-facing string. ──
# Dart: a $identifier or .toString() inside a Text(…); ARB: a $-splice in a value.
# An ICU {placeholder} (no $) and a pre-formatted isolate(…) run pass.
ascii_dart="$(grep -rnE "Text\([^)]*(\\\$[A-Za-z_{]|[A-Za-z_]\.toString\(\))" "${roots[@]}" 2>/dev/null |
  grep -vE "$comment" | grep -v '/generated/' || true)"
ascii_arb="$(grep -rnE "\\\$\{?[A-Za-z_]" "$arb_dir"/*.arb 2>/dev/null || true)"
if [ -n "$ascii_dart$ascii_arb" ]; then
  echo "::error::check_l10n_complete: raw number splice — format via numberFormatFor(locale) then an ICU placeholder (PRD §13.3; engineering 12 §5):" >&2
  [ -n "$ascii_dart" ] && echo "$ascii_dart" >&2
  [ -n "$ascii_arb" ] && echo "$ascii_arb" >&2
  status=1
fi

# ── Layer E — banned-phrase (adab) lint over every ARB value. ──
if ! dart run tool/check_adab_lint.dart; then
  status=1
fi

# ── Layer F — canonical-Sorani encoding lint over app_ckb.arb (E09-T03). ──
if ! dart run tool/check_ckb_canonical.dart; then
  status=1
fi

exit "$status"
