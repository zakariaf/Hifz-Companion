#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# check_no_network.sh — networking is allowed ONLY in packages/assets (the single
# socket). Bans package:http, package:dio, and the dart:io network symbols
# (HttpClient / *Socket) everywhere else — the symbol-level half the analyzer
# import-path ban cannot reach (PRD C1, §17). Bare dart:io is NOT banned (non-UI
# code may read a File); only the network symbols are.
#
# No arguments. Run from the repo root. Exits non-zero on the first violation.
set -euo pipefail

banned='package:http/|package:dio/|HttpClient|Socket'

scan_dirs=()
for d in app/lib app/test packages/*/lib packages/*/test; do
  [ -d "$d" ] || continue
  case "$d" in packages/assets/*) continue ;; esac
  scan_dirs+=("$d")
done

# test_setup.dart is the sanctioned home of the throwing HttpOverrides offline
# guard (the override class names HttpClient by necessity); it is excluded the
# same way packages/assets/ is — it is the gate, not a violation of it.
hits="$(grep -rnE "$banned" "${scan_dirs[@]}" 2>/dev/null \
  | grep -v 'WebSocket' \
  | grep -v '/test_setup\.dart:' || true)"
if [ -n "$hits" ]; then
  echo "check_no_network: networking is allowed ONLY in packages/assets/ (PRD C1, §17):" >&2
  echo "$hits" >&2
  exit 1
fi
