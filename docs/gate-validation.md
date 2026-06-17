<!--
SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Gate-validation drill

A gate that passes because it checks nothing is worse than no gate — it grants
false confidence. So **every gate in this repository is proven to fail on a real
violation.** This is the mandated, documented validation procedure: **every
future change to a `tool/` gate, an `analysis_options.yaml` ban, or a CI job
MUST re-run this drill** (per `eng-add-ci-check` §1) and confirm each gate still
flips red on its seeded violation and green on revert.

The drill is run in a throwaway working copy or branch — **no seeded violation
is ever committed to the trunk that ships.**

## Seeded-violation matrix

For each ban: make the one-line edit, observe the local `tool/` script exit
non-zero with its named message, observe the matching CI job redden, then revert
and observe the script exit 0 and the jobs green.

| # | Seeded violation (one-line edit) | Local gate that flips | Named message cites | CI job |
|---|---|---|---|---|
| 1 | `import 'package:http/http.dart';` in `packages/engine/lib/` | `tool/check_no_network.sh` + `flutter analyze` (uri/undeclared-dep) | PRD C1, §17 | `restraint` + `fast` |
| 2 | `final t = DateTime.now();` in `packages/engine/lib/` | `tool/check_engine_purity.sh` | PRD §19.1 | `restraint` |
| 3 | `import 'package:flutter/widgets.dart';` in `packages/engine/lib/` | `tool/check_engine_purity.sh` + `flutter analyze` (engine declares no flutter) | PRD §19.1 | `restraint` + `fast` |
| 4 | a `QCF_…` font family / `package:quran/src/…` ref in `packages/features/lib/` | `tool/check_quran_isolation.sh` | PRD R1 | `restraint` |
| 5a | `crashlytics: ^1.0.0` in a `pubspec.yaml` | `tool/check_dep_allowlist.sh` (banned message) | PRD C1, §20 gate 6 | `restraint` |
| 5b | `some_undeclared_pkg: ^1.0.0` in a `pubspec.yaml` | `tool/check_dep_allowlist.sh` (allow-list message) | PRD §20 gate 6 | `restraint` |
| 6 | a `Text('literal')` in `app/lib/` or `packages/features/lib/` | `tool/check_l10n_complete.sh` | PRD §20 gate 5 | `restraint` + `fast` |
| 7 | delete a key from `app_ckb.arb` | `tool/check_l10n_complete.sh` | PRD §20 gate 5 | `restraint` + `fast` |
| 8 | a real `HttpClient()` / network call inside a placeholder test | the throwing `HttpOverrides` (E01-T06) → `StateError('Network access attempted in a test. Hifz is offline-only.')` | offline-only | `fast` / `journeys` |

> The matching CI job is named per the PRD §20 gate→job table at the top of
> `.github/workflows/ci.yml`. A violation whose local script reddens but whose
> CI job stays green is a wiring bug in the workflow — fix the wiring, not the
> drill.

## How to run one drill

```bash
# Example — violation #2 (a wall-clock read in the pure engine):
echo 'final _t = DateTime.now();' >> packages/engine/lib/src/engine_stub.dart
bash tool/check_engine_purity.sh        # → exits 1, names PRD §19.1
git checkout -- packages/engine/lib/src/engine_stub.dart
bash tool/check_engine_purity.sh        # → exits 0
```

## Fresh-clone DoD sweep ("a stranger from a cold clone")

From a pristine checkout with no `.dart_tool/` and no prior `pub get`:

```bash
git worktree add /tmp/hifz-pristine HEAD     # or: git clone <url> /tmp/hifz-pristine
cd /tmp/hifz-pristine

# Exactly one committed lock, no per-package lock, no dependency_overrides:
ls pubspec.lock && ! ls packages/*/pubspec.lock app/pubspec.lock 2>/dev/null
! grep -rl dependency_overrides --include=pubspec.yaml .

flutter pub get                              # resolves with the one lock, no clash

# Full suite:
for p in engine models profiles; do (cd packages/$p && dart test); done
for p in data quran l10n features assets; do flutter test packages/$p --exclude-tags golden; done
flutter test app --exclude-tags golden
flutter test packages/quran packages/features --tags golden   # dormant/green-on-empty
flutter test app/integration_test                              # the one launch journey

# Every gate, no arguments, must exit 0 on the clean tree:
for g in no_network engine_purity quran_isolation dep_allowlist l10n_complete; do
  bash tool/check_$g.sh
done
dart run tool/verify_asset_hashes.dart       # dormant/fail-closed on the empty manifest

# Build to the placeholder screen on a device (needs an emulator/simulator):
flutter build apk --debug                    # Android
flutter build ios --no-codesign --debug      # iOS (on macOS with Xcode)
```

CI runs the **same** files — there is no CI-only logic to drift.

## Structural audit (the E01 Definition of Done, re-verified as facts)

- `engine` depends on `models` + `meta` only; dependencies point downward
  (`features → engine/data/quran/l10n/profiles`); no leaf package imports
  `features`; `quran` has no local package dependency; only `assets` declares
  `http`/`crypto` (the network risk — `http` — is confined there; `crypto` also
  appears in the root build-tool dev-deps for offline asset hashing).
- `app/ios/Runner/Info.plist` carries no `NSMicrophoneUsageDescription`; neither
  platform requests a microphone permission (PRD C2, R5).
- The placeholder screen resolves its one string via `AppLocalizations`
  (`l10n.*`), never a hardcoded literal; `check_l10n_complete.sh` is green.
- Exactly one committed root `pubspec.lock`; no per-package lock.
- Every commit carries a DCO `Signed-off-by` trailer; every file carries a
  `GPL-3.0-or-later` SPDX header and `reuse lint` is green; the `LICENSE`'s
  GPLv3 §7 App Store additional permission is intact.
