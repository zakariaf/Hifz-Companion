// SCAFFOLD — this file bundles the pieces of a new Hifz Companion package.
// It is NOT a standalone Dart file: it contains a pubspec.yaml block (as a
// comment), a public-barrel block, a private-source block, and a test block.
// Copy each labelled block into the right file under packages/<name>/, then
// fill every // TODO. Opening this file on its own shows unresolved symbols —
// that is expected; the real symbols resolve only inside the pub workspace.
//
// Governing docs:
//   docs/engineering/02-project-structure.md §1.1 (pub workspace member),
//     §3.1 (dependency matrix), §3.2/§3.3 (package tree + exemplar manifests),
//     §4 (lib/ vs lib/src/ boundary; no junk-drawer folders), §5 (boundary gates),
//     §6 (l10n lives in the l10n package)
//   docs/engineering/01-architecture-overview.md §2 (layer model), §3.1/§3.3
//     (allowed-imports; engine is a package), §5 (pure engine), §6 (offline)
//   docs/engineering/13-oss-repo-and-release.md §2 (REUSE SPDX header), §5 (F-Droid dep gate)
//
// Dependency matrix (copy the row for YOUR package — do not widen it):
//   engine    → meta (+ models)   · Flutter? NO  · dart test (pure)
//   data      → drift, sqlite3, path, engine, profiles
//   assets    → http, crypto, path           ← the ONLY networking package
//   quran     → flutter                       ← NO local package dep; real-font goldens
//   profiles  → meta
//   l10n      → flutter, intl
//   features  → engine, data, quran, l10n, profiles, flutter_riverpod, go_router

// ===========================================================================
// BLOCK A — packages/<name>/pubspec.yaml   (PURE package, e.g. like `engine`)
// Copy into packages/<name>/pubspec.yaml. The empty-but-`meta` dependency
// list IS the entire purity audit (02 §3.3). Deliberately NO flutter, NO
// dart:io, NO clock — tool/check_engine_purity.sh greps this tree.
// ---------------------------------------------------------------------------
//   name: <name>                          # TODO: lower_snake_case noun (02 §4)
//   description: Pure-Dart <name> — no Flutter, no I/O, "today" injected.
//   publish_to: none
//   resolution: workspace                 # member of the root workspace (02 §1.1)
//   environment:
//     sdk: ^3.6.0                          # workspaces require ^3.6.0; baseline Dart 3.10
//   dependencies:
//     meta: ^1.15.0                        # @immutable annotations ONLY
//     # TODO: add `models: { path: ../models }` if you consume the value types;
//     #       add NOTHING that pulls flutter / dart:io / a clock.
//   dev_dependencies:
//     test: ^1.25.0                        # plain `dart test` — NOT flutter_test
//     glados: ^1.1.0                        # property tests for the engine invariants
//   # ALSO remember to add `- packages/<name>` to the root pubspec.yaml `workspace:` list.

// ===========================================================================
// BLOCK B — packages/<name>/pubspec.yaml   (FLUTTER package, e.g. a feature/UI)
// Copy into packages/<name>/pubspec.yaml when the package genuinely needs Flutter.
// Keep deps audit-minimal and pointing DOWNWARD (02 §3.1). NO http/dio outside
// `assets`; NO google_fonts; NO provider/get_it/Bloc (Riverpod only).
// ---------------------------------------------------------------------------
//   name: <name>
//   description: <one line — what this package owns>
//   publish_to: none
//   resolution: workspace
//   environment:
//     sdk: ^3.6.0
//     flutter: ">=3.38.0"
//   dependencies:
//     flutter: { sdk: flutter }
//     flutter_riverpod: ^3.0.0             # state management (no provider/get_it/Bloc)
//     # TODO: declare ONLY the downward local edges this package uses, e.g.:
//     #   engine:   { path: ../engine }
//     #   data:     { path: ../data }
//     #   quran:    { path: ../quran }
//     #   l10n:     { path: ../l10n }
//     #   profiles: { path: ../profiles }
//     # Deliberately NO http/dio (only `assets` fetches), NO drift (touch the DB
//     # only through data's repositories), NO google_fonts, NO `package:features`
//     # if this IS a leaf package (leaves never import features).
//   dev_dependencies:
//     flutter_test: { sdk: flutter }
//   # ALSO add `- packages/<name>` to the root pubspec.yaml `workspace:` list.

// ===========================================================================
// BLOCK C — packages/<name>/lib/<name>.dart   (the PUBLIC barrel)
// Copy into packages/<name>/lib/<name>.dart. Export ONLY the stable API; every
// implementation file stays under lib/src/ and is package-private (02 §4).
// ---------------------------------------------------------------------------

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// <name> — public API barrel.
///
/// Exports ONLY the stable surface other packages consume. Never re-export a
/// `lib/src/` internal that callers should not depend on (13 §2; 02 §4).
library;

// TODO: export only the public types/functions, e.g.:
// export 'src/<name>_service.dart' show <PublicType>;

// ===========================================================================
// BLOCK D — packages/<name>/lib/src/<name>_service.dart   (a PRIVATE unit)
// Copy into packages/<name>/lib/src/. No junk-drawer folders (no utils/,
// helpers/, common/, core/) — a helper lives on its type or is a named service
// (02 §4). If this is the `engine` package: pure functions, "today" is an
// injected CalendarDate, NEVER DateTime.now() (01 §5).
// ---------------------------------------------------------------------------

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';
// TODO (Flutter package only): import 'package:flutter/widgets.dart';
//   then wrap any user-facing screen content in a `Directionality` driven by
//   the locale — fa/ckb/ar are all RTL by construction (02 §2).

/// <PublicType> — TODO: one-sentence purpose. `public` is the API contract and
/// requires this doc comment (coding standards).
@immutable
class PublicType {
  // TODO: immutable value type — final fields only, const constructor where it
  //       can be const. An immutable Card/output is the precondition for the
  //       engine's golden tests (01 §4); a mutable value is a silent test killer.
  const PublicType();

  // PURE-ENGINE REMINDER (delete if not the engine package):
  //   - "today" is the LAST argument, a CalendarDate, never read internally.
  //   - no dart:io, no package:flutter, no DateTime.now()/.timestamp().
  //   - same inputs -> same output, every time (PRD §7.12).
}

// ===========================================================================
// BLOCK E — packages/<name>/test/<name>_service_test.dart   (the test)
// Pure package: copy as-is and run `dart test` (no widget binding — 01 §5).
// Flutter package: switch the import to `flutter_test` and use `flutter test`;
// `quran` goldens must load the REAL KFGQPC fonts, never Ahem (02 §3.2).
// Install a throwing HttpOverrides so any stray network call fails LOUD (01 §6).
// ---------------------------------------------------------------------------

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// TODO (pure package):    import 'package:test/test.dart';
// TODO (Flutter package): import 'package:flutter_test/flutter_test.dart';
// import 'package:<name>/<name>.dart';

// void main() {
//   // TODO: golden vector — pins (inputs) -> expected output deterministically.
//   // TODO (engine): add a `glados` property test for a §7.12 invariant,
//   //   e.g. due_at <= cycle ceiling for all generated inputs.
// }
