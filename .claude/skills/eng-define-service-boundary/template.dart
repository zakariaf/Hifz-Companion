// SCAFFOLD — copy each piece into its owning package, then fill the TODOs.
// `CalendarDate`, the `models`/`data`/`assets` packages, `AppDatabase`, and the app
// providers resolve only inside the real pub-workspace packages
// (docs/engineering/02-project-structure.md), so opening this file on its own shows
// unresolved-symbol errors. That is expected — it is a starting point, not a standalone file.
//
// A side-effect boundary (Hifz Companion). Five pieces, across the layer boundary:
//   1. The INTERFACE        — below the boundary (models/-level), framework-free.
//   2. The LIVE impl        — its layer-2 module (data/ for DB, assets/ for the downloader).
//   3. The Provider         — Riverpod IS the DI; a throwing placeholder until overridden.
//   4. The composition root — main() wires the live service exactly once in ProviderScope.
//   5. The deterministic fake — a plain class; tests/previews install it with overrideWith.
//
// The canonical boundary is the CLOCK ("today"): the engine and repositories read
// clock.today(), NEVER DateTime.now() (docs/engineering/04-flutter-and-state-patterns.md
// §1.2; docs/engineering/01-architecture-overview.md §5). Swap `Clock`/`today()` for your
// boundary's interface and operations (PersistenceHandle, NotificationScheduler,
// AssetDownloader, BackupIo) — the shape is identical.
//
// Governing docs:
//   docs/engineering/01-architecture-overview.md §2 (boundary = injected dependency, no singletons),
//                                                §3.1 (where the impl lives), §5 (today injected), §6 (one socket)
//   docs/engineering/04-flutter-and-state-patterns.md §1 (Riverpod is DI), §1.2 (composition root, throwing placeholder),
//                                                     §4 (single write path)
//   docs/engineering/11-testing-strategy.md §2 (fixed clock = deterministic), §6 (in-memory fakes), §7 (no-network gate)

// =====================================================================================
// 1. THE INTERFACE — lives BELOW the boundary (models/-level), framework-free.
//
// File: models/lib/src/services/clock.dart  (or alongside the value types it returns)
// Imports ONLY value types — a CalendarDate, a DTO. NEVER package:flutter, NEVER dart:io,
// so engine/ and the repositories can name it without importing a framework
// (docs/engineering/01-architecture-overview.md §3.1 — models imports dart:core/package:meta only).
// =====================================================================================

import 'package:hifz_models/hifz_models.dart'; // CalendarDate, DTOs — value types only

/// The single source of "today" for the whole app. Injected so the engine and
/// repositories stay pure and deterministic — they read [today], never DateTime.now()
/// (docs/engineering/04-flutter-and-state-patterns.md §1.2; ...overview §5).
abstract interface class Clock {
  /// The current calendar day, in the app's scheduling sense (a CalendarDate,
  /// NOT a DateTime instant — see domain-calendars-and-hifzdate for day semantics).
  CalendarDate today();
}

// TODO: for a different boundary, declare its interface here instead, e.g.:
//   abstract interface class NotificationScheduler {
//     Future<void> scheduleDailyReminder(CalendarDate day);  // LOCAL only — never push.
//     Future<void> cancelAll();
//   }
// Keep methods value-typed and framework-free; throwing IO operations return Futures
// and surface typed failures the feature layer maps to fa/ckb/ar copy (patterns §2).

// =====================================================================================
// 2. THE LIVE IMPLEMENTATION — lives in its LAYER-2 module.
//
// Clock/notifications: wired by the shell. Persistence: data/. Downloader: assets/
// (THE ONLY module that may import package:http / dart:io HttpClient — ...overview §6).
// This is the ONE place the real side effect happens.
// =====================================================================================

// File: app/lib/services/live_clock.dart  (boundary code — DateTime.now() is allowed HERE only)
class LiveClock implements Clock {
  const LiveClock();

  @override
  CalendarDate today() {
    // The ONLY sanctioned DateTime.now() in the app is inside a Live boundary.
    // Conversion to CalendarDate is owned by domain-calendars-and-hifzdate — do not
    // hand-roll day math here.
    return CalendarDate.fromDateTimeLocal(DateTime.now()); // TODO: real CalendarDate ctor
  }
}

// TODO: for the DB boundary, the "live impl" is the opened Drift handle itself,
// constructed in main() and supplied via overrideWithValue (see piece 4). For the
// downloader, LiveAssetDownloader lives in assets/ and is the only class importing http.

// =====================================================================================
// 3. THE PROVIDER — Riverpod IS the dependency injection (no get_it, no 2nd container).
//
// File: app/lib/providers.dart
// A Provider is a THIN WIRE: it constructs/returns the service, no business logic
// (docs/engineering/04-flutter-and-state-patterns.md §1, Pitfalls).
// =====================================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The injected clock. Defaulted to the live impl because it opens no IO at construction.
/// Consumers read it with ref.watch(clockProvider); nothing reaches "today" via a global.
final clockProvider = Provider<Clock>((ref) => const LiveClock());

/// A boundary that opens real IO (the Drift handle) is a THROWING PLACEHOLDER until the
/// composition root overrides it — a forgotten wiring is a loud startup failure, not
/// silent null data (docs/engineering/04-flutter-and-state-patterns.md §1.2).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('appDatabaseProvider must be overridden in main()'); // TODO: real type
});

// Repositories consume the boundaries; they are the single write path (piece beyond this file).
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepository(
    db: ref.watch(appDatabaseProvider),
    scheduler: ref.watch(schedulerProvider), // the engine — pure, takes NO boundary
    clock: ref.watch(clockProvider), // "today" enters here, as a CalendarDate
  );
});

// =====================================================================================
// 4. THE COMPOSITION ROOT — wire the live service EXACTLY ONCE.
//
// File: app/lib/main.dart
// The ONLY place a live DB/downloader/notifier is constructed
// (docs/engineering/04-flutter-and-state-patterns.md §1.2). No global singletons.
// =====================================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await openAppDatabase(); // Drift NativeDatabase, WAL — the live persistence boundary

  runApp(
    ProviderScope(
      overrides: [
        // Supply the live IO boundary here; the throwing placeholder is now satisfied.
        appDatabaseProvider.overrideWithValue(db),
        // clockProvider needs no override — its .live default opens no IO.
        // TODO: override the live notification scheduler / downloader the same way.
      ],
      child: const HifzApp(),
    ),
  );
}

// =====================================================================================
// 5. THE DETERMINISTIC FAKE — a plain class; tests/previews install it with overrideWith.
//
// File: test/fakes/fixed_clock.dart  (and the test bootstrap)
// No mock framework, no codegen. Every test/preview injects a FIXED clock so dates never
// drift with the host (docs/engineering/11-testing-strategy.md §2, §6).
// =====================================================================================

/// A clock pinned to a literal day — the canonical deterministic double.
class FixedClock implements Clock {
  const FixedClock(this._today);
  final CalendarDate _today;

  @override
  CalendarDate today() => _today;
}

// In a test, swap the boundary with overrideWith — no widget tree needed for a controller:
//
//   final container = ProviderContainer.test(overrides: [
//     clockProvider.overrideWithValue(FixedClock(CalendarDate(2026, 6, 16))),
//     appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())), // in-memory Drift
//     cardRepositoryProvider.overrideWithValue(FakeCardRepository()),              // fake the REPO, not the Notifier
//   ]);
//
// And the no-network gate: install a THROWING HttpOverrides so any stray call from a
// boundary fails loudly (docs/engineering/11-testing-strategy.md §7).
//
//   class _ThrowingHttpOverrides extends HttpOverrides {
//     @override
//     HttpClient createHttpClient(SecurityContext? c) =>
//         throw StateError('Network access attempted in a test. Hifz is offline-only.');
//   }
//   void useOfflineTestPolicy() => HttpOverrides.global = _ThrowingHttpOverrides();
//   // Only the assets/ downloader test resets HttpOverrides.global to a mock in its own setUp.

// =====================================================================================
// REMEMBER:
//   - The engine takes NO boundary — `today`/`card`/`grade`/config are plain parameters
//     (domain-scheduling-engine-rules). The boundary stops at the engine's door.
//   - A mutating boundary (persistence, backup) is consumed through the SINGLE WRITE PATH:
//     one Drift transaction, persist BEFORE republish, review_log append-only (patterns §4).
//   - IO failure surfaces as a CALM retry at the feature layer in fa/ckb/ar (RTL), never a
//     guilt/shame message (PRD R3; patterns §1.3). The boundary itself carries no copy.
//   - Networking lives in assets/ ONLY; notifications are LOCAL only, never push (...overview §6).
// =====================================================================================
