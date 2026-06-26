#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# check_dep_allowlist.sh — every external dependency declared in the workspace
# manifests must be on the sanctioned allow-list (a new dependency is a
# decision-log event, never a quiet add), and no analytics/ads/backend/crash SDK
# or google_fonts may appear (the F-Droid entry ticket — all UI fonts are
# bundled). PRD C1, §20 gate 6.
#
# No arguments. Run from the repo root. Exits non-zero on the first violation.
set -euo pipefail

# Sanctioned external + SDK dependencies and the local workspace packages.
allowed=(
  # external runtime + tooling
  meta drift sqlite3 path path_provider http crypto intl flutter_riverpod
  go_router test glados flutter_lints
  # opt-in at-rest encryption key store (Decision log #3) — Keychain/KeyStore,
  # local only, off by default.
  flutter_secure_storage
  # optional .hifzbackup encryption envelope (Decision log #12; E17 §6) —
  # pure-Dart Argon2id→ChaCha20-Poly1305 in backup/, key independent of the
  # device DB key, off by default; SHA-256 integrity stays `crypto`.
  cryptography
  # backup file-move (Decision log #13; E17 §9) — OS share sheet + file picker,
  # in the app shell only, behind a service boundary; offline, no network.
  share_plus file_picker
  # local daily reminder (Decision log #14; E18 §14; doc 07 §6) — the one calm
  # notification in the app shell only, behind the composition NotificationScheduler
  # boundary; no push, no server, no network. `timezone` + `flutter_timezone` feed
  # `zonedSchedule` a DST-correct local fire time, taken only at this edge (never
  # the engine/CalendarDate core); alarms are inexact (no exact-alarm permission).
  flutter_local_notifications timezone flutter_timezone
  # science-screen external source link (Decision log #15; E19) — opens a citation
  # URL in the OS browser, app shell only, behind the SourceLinkLauncher boundary;
  # offline, no in-app fetch, no network (platform channel, never a Dart socket).
  url_launcher
  # drift code generation (Decision log #3: Drift over SQLite) — build-time only,
  # never shipped in the binary; generates database.g.dart + migration steps.
  drift_dev build_runner
  # display-only calendar conversion (E02 §4): pure-Dart, offline, BSD-licensed.
  # Banned in engine/ by the banned-import gate; calendars are a display concern.
  shamsi_date hijri
  # flutter SDK dependencies
  flutter flutter_localizations flutter_test integration_test
  # local workspace packages (path deps)
  models engine backup profiles data quran l10n composition features assets
)
banned_regex='firebase_|crashlytics|sentry|google_analytics|facebook_|appsflyer|amplitude|mixpanel|google_fonts'

is_allowed() {
  local name="$1"
  for a in "${allowed[@]}"; do [ "$a" = "$name" ] && return 0; done
  return 1
}

manifests=(pubspec.yaml app/pubspec.yaml)
for m in packages/*/pubspec.yaml; do manifests+=("$m"); done

status=0
for m in "${manifests[@]}"; do
  [ -f "$m" ] || continue
  # Extract declared dependency names under dependencies:/dev_dependencies: only
  # (comments and the workspace: list are ignored), so a "NO google_fonts"
  # comment never trips the banned check.
  names="$(awk '
    /^dependencies:/      { indep = 1; next }
    /^dev_dependencies:/  { indep = 1; next }
    /^[A-Za-z]/           { indep = 0 }
    indep && /^  [A-Za-z0-9_]+:/ { n = $1; sub(/:.*/, "", n); print n }
  ' "$m")"
  for n in $names; do
    if echo "$n" | grep -qE "$banned_regex"; then
      echo "check_dep_allowlist: banned dependency '$n' in $m — tracking/ads/crash SDKs and google_fonts are forbidden (PRD C1, §20 gate 6)." >&2
      status=1
    elif ! is_allowed "$n"; then
      echo "check_dep_allowlist: dependency '$n' in $m is not on the allow-list — a new dependency is a decision-log event (PRD §20 gate 6)." >&2
      status=1
    fi
  done
done
exit "$status"
