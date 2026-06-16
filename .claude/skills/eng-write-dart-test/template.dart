// SCAFFOLD — this file bundles one starting point per test tier of the Hifz
// Companion test pyramid. It is NOT a standalone Dart file: each labelled BLOCK
// belongs in a different file under the relevant package's `test/` (or the
// top-level `integration_test/`). Copy the block you need into the right file,
// then fill every // TODO. Opening this file on its own shows unresolved
// symbols — that is expected; the real symbols resolve only inside the package.
//
// Governing docs:
//   docs/engineering/11-testing-strategy.md
//     §1 (pyramid shape) · §2 (engine = package:test, injected today) ·
//     §3 (frozen golden vectors) · §4 (glados invariants INV-1..INV-6) ·
//     §5 (real-font muṣḥaf goldens) · §6 (widget / RTL / integration journeys) ·
//     §7 (throwing HttpOverrides offline guard) · §10 (coverage: assert, don't gate)
//   docs/engineering/03-coding-standards.md
//     §1.1 (full-word, unit-bearing names; CalendarDate vs DateTime) ·
//     §4 (cite every constant) · §5 (engine is total) · §11→ REUSE SPDX header
//
// Tier → tool → runner (do not invert the pyramid — 11 §1):
//   unit / property      → package:test (+ glados) → `dart test`   ← engine, DAOs (MASS lives here)
//   widget / golden      → flutter_test            → `flutter test` / `--tags golden`
//   integration journey  → integration_test        → `flutter test integration_test/` (emulator)

// ===========================================================================
// BLOCK A — packages/engine/test/<feature>_test.dart   (PURE UNIT — 11 §2)
// `package:test` ONLY: no flutter_test, no widget binding. `today` is a literal
// SerialDay; nothing reads DateTime.now() (11 §2; 03 §1.1.3). Run: `dart test`.
// ---------------------------------------------------------------------------

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:test/test.dart';
// import 'package:engine/engine.dart';

void main() {
  group('<feature> is a pure function of (card, review, today)', () {
    test('Again lapses: stabilityDays shrinks, difficulty rises, weakFlag set', () {
      // final engine = SchedulingEngine(EngineConfig.defaults());
      // TODO: construct `today` as a literal SerialDay — NEVER DateTime.now() (11 §2).
      // final before = Card.test(pageId: 1, difficulty: 5, stabilityDays: 30, lastReviewedDay: day(100));
      // final after = engine.onReview(
      //   before,
      //   const ReviewInput(grade: Grade.again, errorLines: [3], source: Source.self_),
      //   day(130),
      // );
      // expect(after.lapses, before.lapses + 1);
      // expect(after.stabilityDays, lessThan(before.stabilityDays));
      // expect(after.difficulty, greaterThan(before.difficulty));
      // expect(after.isWeak, isTrue);   // boolean reads as an assertion (03 §1.1.5)
    });
  });
}

// ===========================================================================
// BLOCK B — packages/engine/test/fsrs_vectors_test.dart   (FROZEN VECTORS — 11 §3)
// Pin the FSRS arithmetic to a committed table. Assert with closeTo(_, 1e-6),
// NEVER == on doubles. Regenerate ONLY via a reviewed `--update-vectors` run.
// Name the constants (DECAY/FACTOR) and cite them (03 §1.1.1, §4).
// `// dart format off` here is the ONE allowed case — alignment is the doc (03 §3).
// ---------------------------------------------------------------------------

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// import 'package:test/test.dart';
// import 'package:engine/engine.dart';

// The frozen oracle table — one row per branch + each cold-start seed (11 §3).
// dart format off
// const fsrsVectors = <FsrsVector>[
//   //         d_in, s_in, grade,       elapsed, d_out, s_out,  notes (cite the branch)
//   FsrsVector(5.0,  30.0, Grade.good,  30,      4.78,  72.41,  'on-time Good grows S ~2.4x'),
//   FsrsVector(5.0,  30.0, Grade.again, 30,      6.00,   6.12,  'lapse: post-lapse S, D +1'),
//   // TODO: cold-start seeds — Solid(D=3,S=60), Shaky(D=5,S=14), Rusty(D=7,S=4) (11 §3 table).
// ];
// dart format on

// void main() {
//   test('vendored FSRS arithmetic reproduces every frozen vector', () {
//     final engine = SchedulingEngine(EngineConfig.defaults());
//     for (final v in fsrsVectors) {
//       final out = engine.onReview(
//         Card.test(pageId: 1, difficulty: v.dIn, stabilityDays: v.sIn, lastReviewedDay: day(0)),
//         ReviewInput(grade: v.grade, errorLines: const [], source: Source.teacher),
//         day(v.elapsed),
//       );
//       expect(out.difficulty, closeTo(v.dOut, 1e-6), reason: v.notes);     // tolerance, not ==
//       expect(out.stabilityDays, closeTo(v.sOut, 1e-6), reason: v.notes);
//     }
//   });
// }

// ===========================================================================
// BLOCK C — packages/engine/test/invariants_test.dart   (glados PROPERTIES — 11 §4)
// Encode each PRD §7.12 invariant (INV-1..INV-6) as a property over generated
// (Card, grade-sequence, today) histories; rely on shrinking, not a fixed seed.
// ---------------------------------------------------------------------------

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// import 'package:glados/glados.dart';
// import 'package:engine/engine.dart';

// extension AnySchedule on Any {
//   /// A card + a random graded-review sequence + an injected today.
//   Generator<ScheduleCase> get scheduleCase => combine3(
//         any.cardSeed,                                          // page 1..604, D∈[1,10], S>0, track
//         any.listWithLengthInRange(0, 200, any.gradedReview),  // Again/Hard/Good/Easy + error lines
//         any.serialDayInRange(0, 3650),                        // today within ~10 years
//         ScheduleCase.new,
//       );
// }

// void main() {
//   final engine = SchedulingEngine(EngineConfig.defaults());
//
//   // INV-1 — the trust clamp: dueAt is NEVER later than the cycle ceiling (PRD §7.6).
//   Glados<ScheduleCase>(any.scheduleCase).test('dueAt ≤ cycle ceiling, always', (c) {
//     final card = replay(engine, c);
//     if (card.track == Track.unmemorized) return;            // ceiling applies to memorized cards
//     final ceiling = cycleCeiling(card, c.config, c.today);
//     expect(card.dueAt.value, lessThanOrEqualTo(ceiling.value));
//   });
//
//   // TODO: INV-2 manzil/FAR due items always appear in buildToday(...).
//   // TODO: INV-3 Again ⇒ stabilityDays' ≤ stabilityDays ∧ track' ≤ track.
//   // TODO: INV-4 two buildToday runs fingerprint-equal (fuzz OFF).
//   // TODO: INV-5 a teacher `Again` overrides a prior self `Good` for that page.
//   // TODO: INV-6 every memorized card has a FINITE dueAt — engine never returns "drop"/null.
// }

// ===========================================================================
// BLOCK D — packages/quran/test/golden/page_render_golden_test.dart  (FIDELITY — 11 §5)
// Load the REAL bundled KFGQPC + UI fonts via FontLoader — NEVER Ahem. Pin DPR,
// surface size, theme; disable animations; @Tags(['golden']) → pinned CI job (11 §8).
// A dropped/shifted diacritic must move pixels and fail the build (03 §8.1).
// ---------------------------------------------------------------------------

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// @Tags(['golden'])
// library;
//
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_test/flutter_test.dart';
//
// Future<void> _loadRealFonts() async {
//   // The ACTUAL bundled fonts (KFGQPC page fonts + fa/ckb/ar UI fonts) — never Ahem,
//   // which renders every glyph as a solid square and would defeat the fidelity test (11 §5).
//   for (final family in kBundledFontFamilies) {
//     final loader = FontLoader(family)..addFont(rootBundle.load(fontAssetPath(family)));
//     await loader.load();
//   }
// }
//
// void main() {
//   setUpAll(_loadRealFonts);
//
//   testWidgets('muṣḥaf page renders pixel-identical to the reference', (tester) async {
//     tester.view.devicePixelRatio = 2.0;                  // fixed DPR — no host variation
//     tester.view.physicalSize = const Size(828, 1792);    // fixed surface
//     await tester.pumpWidget(const MushafPageHarness(pageId: 1)); // no animations
//     await expectLater(
//       find.byType(MushafPage),
//       matchesGoldenFile('goldens/mushaf/page_001.png'),  // regenerate with --update-goldens LOCALLY
//     );
//   });
// }

// ===========================================================================
// BLOCK E — packages/features/test/golden/today_rtl_golden_test.dart  (RTL/LAYOUT — 11 §6)
// Pump each key screen under Directionality.rtl for ar/fa/ckb with locale numerals
// + calendar. Layout goldens MAY use the font-independent strategy (forbidden for
// fidelity goldens, Block D). All three locales are RTL by construction.
// ---------------------------------------------------------------------------

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// @Tags(['golden'])
// library;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   for (final locale in const [Locale('ar'), Locale('fa'), Locale('ckb')]) {
//     testWidgets('Today renders RTL for ${locale.languageCode}', (tester) async {
//       await tester.pumpWidget(
//         Directionality(
//           textDirection: TextDirection.rtl,              // asserted by construction (11 §6)
//           child: const TodayHarness(/* TODO: locale, fixed `today`, in-memory fakes */),
//         ),
//       );
//       // TODO: assert numerals/calendar are the locale's (e.g. ٠١٢ / ۰۱۲), not ASCII digits.
//       await expectLater(
//         find.byType(TodayScreen),
//         matchesGoldenFile('goldens/rtl/today_${locale.languageCode}.png'),
//       );
//     });
//   }
// }

// ===========================================================================
// BLOCK F — packages/features/test/<screen>_widget_test.dart   (WIDGET — 11 §6)
// Headless. IN-MEMORY fakes via Riverpod overrides — NEVER a real DB/assets (11 §6).
// Inject a fixed `today`. The sacred-text guard holds: a dropped word ≠ "Good" (03 §8.1).
// ---------------------------------------------------------------------------

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// void main() {
//   testWidgets('reveal-on-tap → grade appends a review and updates the card', (tester) async {
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           // TODO: override the store/asset providers with IN-MEMORY fakes (11 §6).
//           // TODO: override the date provider with a FIXED `today` (no DateTime.now()).
//         ],
//         child: const ReciteHarness(/* TODO: a seeded due page */),
//       ),
//     );
//     // await tester.tap(find.byKey(const Key('reveal')));
//     // await tester.pump();                                // explicit pump — NOT pumpAndSettle on
//     //                                                     // an indefinite indicator (11 §6 pitfalls)
//     // await tester.tap(find.byKey(const Key('grade.good')));
//     // await tester.pump();
//     // expect(find.byType(TodayScreen), findsOneWidget);   // returned to the day, no celebration
//     // TODO: assert a review_log row was appended; assert NO streak/score/confetti widget exists.
//   });
// }

// ===========================================================================
// BLOCK G — integration_test/journey_cold_start_test.dart   (JOURNEY — 11 §6)
// REAL Drift/SQLite + assets + render on an emulator. ONE of the FOUR PRD flows
// only (J1 cold start / J2 review / J3 teacher sign-off / J4 catch-up). No fifth
// journey without a decision-log amendment (11 §6). Net stays blocked (Block H).
// ---------------------------------------------------------------------------

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
//
// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//
//   testWidgets('J1: cold start seeds cards and generates the first day', (tester) async {
//     await tester.pumpWidget(const HifzApp(networkClient: BlockedClient())); // §7 — no real net
//     // await onboardPartialHafiz(tester, juz: const [1, 30], confidence: Confidence.solid);
//     // expect(find.byType(TodayScreen), findsOneWidget);
//     // expect(find.byType(RevisionItem), findsWidgets);   // a finite, capped day exists (no overdue dump)
//     // TODO: assert cold-start seeds match the §3 table; assert no shame copy on a missed gap (J4).
//   });
// }

// ===========================================================================
// BLOCK H — test/test_setup.dart   (OFFLINE GUARD — 11 §7)
// Install a THROWING HttpOverrides so any stray network call is a LOUD failure,
// not a silent 400. Call useOfflineTestPolicy() from the shared test bootstrap.
// Only the asset-downloader test opts out (resets HttpOverrides.global in setUp).
// ---------------------------------------------------------------------------

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

class _ThrowingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      throw StateError('Network access attempted in a test. Hifz is offline-only (PRD C1).');
}

/// Installs the offline test policy: every network attempt throws loudly (11 §7).
/// The single asset-downloader test resets `HttpOverrides.global` to a mock in its own setUp.
void useOfflineTestPolicy() => HttpOverrides.global = _ThrowingHttpOverrides();
