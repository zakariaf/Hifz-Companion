// SCAFFOLD — copy each labelled block into the right file under the owning
// packages, then fill every // TODO. This is NOT a standalone Dart file:
// `models`/`engine`/`data` types, the `l10n` strings, and the Drift symbols
// resolve only inside the pub workspace, so opening this file on its own shows
// unresolved-symbol errors. That is expected — it is a starting point.
//
// Five pieces, across the data + features layers:
//   1. DI providers + the main()/ProviderScope composition root  (app/)
//   2. The single-write-path repository method                   (data/)
//   3. The family StreamProvider derived read model              (features/ or data/)
//   4. The AsyncNotifier feature controller (immutable UI state) (features/)
//   5. The dumb ConsumerWidget with the calm RetryView branch    (features/)
//
// THE ONE RULE: a mutation PERSISTS transactionally (in the repository, in one
// db.transaction) BEFORE any in-memory/stream state becomes observable. The
// controller's await returns only after commit; the Drift stream re-emitting is
// what updates the UI. Never republish before the commit. Never mutate persisted
// state in a widget/controller. Never read DateTime.now() — "today" is injected.
//
// Governing docs:
//   docs/engineering/04-flutter-and-state-patterns.md
//     §1 (Riverpod-only), §1.1 (ownership rules + 3 hard rules), §1.2 (composition
//     root + profile gate), §1.3 (end-to-end example), §3 (StreamProvider reads),
//     §4 (the single write path), §5 (family + autoDispose), §6 (no navigation in stores)
//   docs/engineering/01-architecture-overview.md §2 (layers/DI), §4 (UDF: persist→republish), §5 (engine: today injected)
//   docs/engineering/05-persistence-and-encryption.md §3 (one db.transaction, WAL, persist-before-publish), §2 (append-only review_log)

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// ===========================================================================
// BLOCK 1 — DI providers + composition root.
// DI providers live near their owner (data/, engine wiring in app/composition/).
// main() is the ONLY place live services are constructed (04 §1.2).
// ---------------------------------------------------------------------------
import 'dart:async';

import 'package:flutter/material.dart';                 // Directionality / Material 3 shell
import 'package:flutter_riverpod/flutter_riverpod.dart'; // MODERN api only — NEVER .../legacy.dart
// import 'package:hifz_models/hifz_models.dart';        // ProfileId, Card, Grade, CalendarDate, immutable UI-state
// import 'package:hifz_engine/hifz_engine.dart';        // Scheduler — pure, injected, imports no Riverpod/Flutter
// import 'package:hifz_data/hifz_data.dart';            // AppDatabase, CardRepository — the single write path

/// The pure engine, injected (it imports nothing from Riverpod/Flutter — 01 §5).
// final schedulerProvider = Provider<Scheduler>((ref) => const Scheduler());

/// "today" enters the shell ONLY here, as a CalendarDate — never DateTime.now() (04 §1.3).
/// Calendar semantics (Hijri/Jalālī/Gregorian) belong to domain-calendars-and-hifzdate.
// final clockProvider = Provider<Clock>((ref) => /* TODO: SystemClock() */);

/// Placeholder DB provider — OVERRIDDEN once in main(); reading it un-overridden
/// throws loudly at startup rather than returning silent null data (04 §1.2).
// final appDatabaseProvider = Provider<AppDatabase>(
//   (ref) => throw UnimplementedError('Override appDatabaseProvider in main().'),
// );

/// The repository is the data layer's single source of truth AND the single write
/// path. Features reach the engine/DB ONLY through it — never a DAO directly (04 §4).
// final cardRepositoryProvider = Provider<CardRepository>((ref) {
//   return CardRepository(
//     db: ref.watch(appDatabaseProvider),
//     scheduler: ref.watch(schedulerProvider),
//     clock: ref.watch(clockProvider),
//   );
// });

/// The active-profile gate: switching it recomputes every family-keyed provider.
/// No global mutable "current user" anywhere (04 §1.2, §5).
// final activeProfileProvider =
//     NotifierProvider<ActiveProfileController, ProfileId>(ActiveProfileController.new);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final db = await openAppDatabase();   // TODO: Drift NativeDatabase, WAL — see 05 §1/§3

  runApp(
    ProviderScope(
      overrides: [
        // TODO: appDatabaseProvider.overrideWithValue(db),  // the ONLY live wiring
      ],
      child: const HifzApp(),
    ),
  );
}

/// Root shell: locale → Directionality (all three locales fa/ckb/ar are RTL by
/// construction — 04 §6). Strings come from the l10n package, never inline here.
class HifzApp extends ConsumerWidget {
  const HifzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // routerConfig: ref.watch(routerProvider),   // go_router; the redirect guard, not a store, navigates (04 §6)
      // supportedLocales: const [Locale('ar'), Locale('fa'), Locale('ckb')],  // RTL
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const Placeholder(), // TODO: replace with the routed shell
    );
  }
}

// ===========================================================================
// BLOCK 2 — The single-write-path repository method (data/ package).
// PERSIST transactionally FIRST, THEN let the stream republish. The append to
// the append-only review_log comes BEFORE the card upsert (04 §4; 05 §2/§3).
// This is the ONLY way a review reaches the database anywhere in the app.
// ---------------------------------------------------------------------------
//
// class CardRepository {
//   CardRepository({required this.db, required this.scheduler, required this.clock});
//   final AppDatabase db;
//   final Scheduler scheduler;
//   final Clock clock;
//
//   /// Single write path. Returns only AFTER the WAL commit — persist-before-publish.
//   Future<void> recordReview({
//     required ProfileId profile,
//     required int pageId,
//     required ReviewInput review,   // produced by domain-grading-pipeline (grade, errorLines, source, missedOrAlteredWord)
//   }) async {
//     final today = clock.today();                 // CalendarDate, injected — NEVER DateTime.now()
//     await db.transaction(() async {              // one review = one transaction (05 §3)
//       final card = await db.cardDao.byKey(profile, pageId);
//       final result = scheduler.onReview(card, review, today);  // PURE; trust clamp + sacred-text guard live here
//       await db.reviewLogDao.append(result.logRow); // 1. APPEND the append-only audit row FIRST (05 §2)
//       await db.cardDao.upsert(result.card);        // 2. THEN the new card state
//       // Every query inside the transaction is awaited (the 05 §3 await footgun).
//     });
//     // No manual republish: the Today queue is a StreamProvider over a Drift query (BLOCK 3),
//     // so committing the transaction is what makes the UI update. One source of truth.
//   }
//
//   // Derived read models are streams — never stored, separately-maintained state (04 §3):
//   // Stream<List<ReviewItem>> watchTodaySession(ProfileId p, CalendarDate today) => /* engine.buildToday over streamed cards */;
//   // Stream<List<JuzHealth>> watchJuzHealth(ProfileId p) => /* min-leaning aggregate; R computed on read, NEVER stored (04 §3) */;
// }

// ===========================================================================
// BLOCK 3 — The derived read model: a family StreamProvider over a Drift query.
// A committed review re-emits the stream → the queue/heat-map rebuild for free.
// Keyed by ProfileId (stable, equatable); autoDispose if it backs one screen (04 §3, §5).
// ---------------------------------------------------------------------------
//
// final todayQueueProvider =
//     StreamProvider.autoDispose.family<List<ReviewItem>, ProfileId>((ref, profile) {
//   final repo = ref.watch(cardRepositoryProvider);
//   final today = ref.watch(clockProvider).today();   // injected clock, not DateTime.now()
//   return repo.watchTodaySession(profile, today);     // Drift emits on any card change for this profile
// });
//
// final juzHealthProvider =
//     StreamProvider.family<List<JuzHealth>, ProfileId>((ref, profile) {
//   return ref.watch(cardRepositoryProvider).watchJuzHealth(profile); // R recomputed on read (PRD §10.3)
// });

// ===========================================================================
// BLOCK 4 — The AsyncNotifier feature controller (features/ package).
// Exposes ONE immutable UI-state value; commands route every write through the
// repository. NO interval math, NO clock read, NO DAO, NO navigation here (04 §1.1).
// ---------------------------------------------------------------------------
//
// /// Immutable UI-state value (copyWith / freezed). A mutable value handed to a
// /// widget is a silent golden-test killer (01 §4).
// @immutable
// class TodaySession {
//   const TodaySession({required this.queue});
//   final List<ReviewItem> queue;   // Far → Near → New, recitation order (PRD §12.2)
// }
//
// class TodayController extends AsyncNotifier<TodaySession> {
//   @override
//   Future<TodaySession> build() async {
//     final profile = ref.watch(activeProfileProvider);            // recomputes on profile switch (04 §5)
//     final queue = await ref.watch(todayQueueProvider(profile).future); // rebuilds when a review commits (04 §3)
//     return TodaySession(queue: queue);
//   }
//
//   /// A command the View binds to the grade buttons. Routes the write through the
//   /// repository (single write path) and PROPAGATES failure — no try? swallow (04 §1.3).
//   Future<void> grade(int pageId, ReviewInput review) async {
//     final profile = ref.read(activeProfileProvider);
//     await ref.read(cardRepositoryProvider).recordReview(
//       profile: profile, pageId: pageId, review: review,
//     );
//     // Stream invalidation refreshes build(); no setState, no manual cache poke,
//     // no debounced "save later" — a review is a durable sanad act (04 §4).
//   }
// }
//
// final todayControllerProvider =
//     AsyncNotifierProvider<TodayController, TodaySession>(TodayController.new);

// ===========================================================================
// BLOCK 5 — The dumb ConsumerWidget: reads ONE controller, renders, surfaces a
// CALM retry on error — never a guilt/fear message (04 §1.3, PRD R3). RTL via
// the app-wide Directionality; strings from the l10n package, not inline.
// ---------------------------------------------------------------------------
//
// class TodayScreen extends ConsumerWidget {
//   const TodayScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final session = ref.watch(todayControllerProvider);
//     return session.when(
//       loading: () => const CalmLoadingView(),         // calm copy, never a spinner-of-shame
//       error: (e, _) => RetryView(                      // calm retry, NOT a guilt message
//         onRetry: () => ref.invalidate(todayControllerProvider),
//       ),
//       data: (s) => ReviseList(
//         items: s.queue,
//         // The View contains no business logic; it forwards the command upward.
//         onGrade: (pageId, review) =>
//             ref.read(todayControllerProvider.notifier).grade(pageId, review),
//       ),
//     );
//   }
// }

// ===========================================================================
// REMINDERS (delete once satisfied):
//   - Modern providers only: Notifier/AsyncNotifier, Future/StreamProvider.
//     NEVER import 'package:flutter_riverpod/legacy.dart' (StateProvider /
//     StateNotifierProvider / ChangeNotifierProvider) — it is a CI-failing grep (04 §1.5).
//   - No get_it, no Bloc, no provider. Riverpod is the single state + DI mechanism (01 §2).
//   - Persist BEFORE republish: the repository commits in one db.transaction, then the
//     Drift stream re-emits. Never the reverse, never optimistic UI (04 §4; 05 §3).
//   - No DateTime.now()/Calendar.current/TimeZone.current in shell logic; "today" is the
//     injected CalendarDate clock and is passed DOWN to the engine (04 §1.3; 01 §5).
//   - family keys are stable + equatable (ProfileId/pageId), never a mutable Card; autoDispose
//     screen-scoped providers, but NEVER the app-scope database/engine singletons (04 §5).
//   - Stores publish state; the go_router redirect guard (not a controller) navigates (04 §6).
//   - The store holds value types only — no hard-coded strings (use the l10n package: ar
//     template, fa/ckb), no streaks/badges/scores/confetti (PRD R3/C6), no Quran/factual claim.
