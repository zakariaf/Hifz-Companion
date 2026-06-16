// SCAFFOLD — this file bundles the pieces of a new Hifz Companion feature.
// It is NOT a standalone Dart file: it contains four feature-file blocks plus a
// router-entry block. Copy each labelled block into the right file under
// packages/features/lib/src/<feature>/, add the GoRoute to the shell router, then
// fill every // TODO. Opening this file on its own shows unresolved symbols —
// that is expected; the real symbols resolve only inside the pub workspace.
//
// Replace <feature> / <Feature> throughout (lower_snake_case file/dir, UpperCamel type).
//
// Governing docs:
//   docs/engineering/02-project-structure.md §3.4 (feature folder anatomy),
//     §3.1 (downward-only deps), §6 (l10n in the l10n package), §2 (app shell = composition root)
//   docs/engineering/04-flutter-and-state-patterns.md §1.1 (ownership rules), §1.3 (end-to-end grade),
//     §2 (compose; domain-blind ui/; tokens by name; no gamification), §3 (StreamProvider reads),
//     §4 (single write path), §5 (family + autoDispose), §6 (ShellRoute / RTL nav), §7 (testing)
//   docs/engineering/01-architecture-overview.md §2 (layer model), §4 (unidirectional flow), §6 (offline)
//
// Non-negotiables this scaffold encodes:
//   - The View is DUMB (reads one controller, renders); logic lives in the AsyncNotifier.
//   - The engine is NEVER reached from a widget; mutations go through a data repository (single write path).
//   - "today" is an injected CalendarDate (clockProvider), NEVER DateTime.now().
//   - Reads are StreamProviders over Drift; R / juz-health are computed on read, never stored.
//   - Tokens (color.* / type.* / space.* / motion.*) are referenced BY NAME — never inline hex/pt/ms.
//   - Strings come from AppLocalizations (ar template, fa/ckb). RTL by construction (logical start/end).
//   - No AI, no audio, no network, no gamification (streaks/badges/scores/confetti) anywhere here.

// ============================================================================
// BLOCK 1 — lib/src/<feature>/<feature>_providers.dart
// Providers SCOPED to this feature (never global; the only global composition is
// app/composition/providers.dart). family + autoDispose for per-profile/per-page state.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:data/data.dart';      // cardRepositoryProvider, repositories — the single write path
// import 'package:engine/engine.dart';  // immutable value types only (Card, Grade, ReviewItem, CalendarDate)
// import 'package:profiles/profiles.dart'; // ProfileId
// activeProfileProvider, clockProvider, cardRepositoryProvider come from the data/composition layer.

/// Reactive read model for this screen: a StreamProvider over a Drift query,
/// family-keyed by the active profile so a profile switch re-resolves it (§3, §5).
/// R / juz-health are COMPUTED here on read — never persisted as a column (§3).
final <feature>QueueProvider =
    StreamProvider.autoDispose.family<List</* TODO: ReviewItem */ Object>, /* ProfileId */ Object>(
  (ref, profile) {
    // final repo = ref.watch(cardRepositoryProvider);
    // final today = ref.watch(clockProvider).today(); // CalendarDate — NEVER DateTime.now() (§1.3)
    // return repo.watch<Feature>Session(profile, today); // engine.buildToday() over the streamed cards
    throw UnimplementedError('TODO: watch the Drift query for this screen (§3)');
  },
);

// ============================================================================
// BLOCK 2 — lib/src/<feature>/<feature>_view_model.dart
// The 1:1 ViewModel: an AsyncNotifier exposing immutable UI state + commands.
// Reads repositories, calls the engine — NEVER touches the DB or a DAO directly (§1.1).
// (Use a richer plain Notifier ONLY for onboarding / backup / mutashabihat drill — §1.4.)
// ============================================================================

// import 'package:engine/engine.dart';
// import '<feature>_providers.dart';

/// Immutable UI-state value the View renders. Immutable state only (§1.1 rule 3).
class <Feature>Session {
  const <Feature>Session({required this.items});
  final List</* TODO: ReviewItem */ Object> items;
}

class <Feature>Controller extends AsyncNotifier<<Feature>Session> {
  @override
  Future<<Feature>Session> build() async {
    // final profile = ref.watch(activeProfileProvider);
    // final items = await ref.watch(<feature>QueueProvider(profile).future);
    // return <Feature>Session(items: items);
    throw UnimplementedError('TODO: project the reactive read into UI state (§1.3)');
  }

  /// A command the View binds to an event handler. The mutation goes through the
  /// data repository's named method — the SINGLE WRITE PATH (persist-then-republish, §1.1/§4).
  /// No DB call, no DAO, no engine call, no optimistic republish, no setState here.
  Future<void> submit(/* TODO: int pageId, Grade grade, List<int> errorLines, ReviewSource source */) async {
    // final profile = ref.read(activeProfileProvider);
    // await ref.read(cardRepositoryProvider).recordReview(
    //   profile: profile, pageId: pageId, grade: grade, errorLines: errorLines, source: source,
    // ); // see domain-grading-pipeline — this commits the WAL transaction, then the stream re-emits
    // Stream invalidation refreshes build(); no manual cache poke.
    throw UnimplementedError('TODO: call the data repository method (domain-grading-pipeline)');
  }
}

final <feature>ControllerProvider =
    AsyncNotifierProvider<<Feature>Controller, <Feature>Session>(<Feature>Controller.new);

// ============================================================================
// BLOCK 3 — lib/src/<feature>/<feature>_screen.dart
// The navigable entry View: a DUMB ConsumerWidget. Reads ONE controller and renders.
// Allowed here: show/hide if-statements, layout, simple routing. NOTHING else (§1.3, §2).
// ============================================================================

import 'package:flutter/material.dart';
// import 'package:l10n/l10n.dart';        // AppLocalizations — every string comes from here (§6)
// import '<feature>_view_model.dart';
// import 'widgets/<feature>_item_row.dart';

class <Feature>Screen extends ConsumerWidget {
  const <Feature>Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final l10n = AppLocalizations.of(context); // no hardcoded UI literals (§6)
    final session = ref.watch(<feature>ControllerProvider);

    // RTL by construction: the app-wide Directionality mirrors layout; use logical
    // start/end only, never hard-coded left/right. Tokens by name (color.* / type.* /
    // space.*) — never inline hex/pt/ms (§2). No gamification anywhere (§2 Pitfalls).
    return session.when(
      // Calm loading — never a spinner-of-shame; calm copy (§1.3).
      loading: () => const Center(child: /* TODO: CalmLoadingView() */ CircularProgressIndicator()),
      // Calm retry — never a guilt/fear message (§1.3).
      error: (e, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(<feature>ControllerProvider),
          child: const Text(/* TODO: l10n.retry */ 'retry'),
        ),
      ),
      data: (s) => ListView.builder(
        itemCount: s.items.length,
        itemBuilder: (context, i) {
          // TODO: return <Feature>ItemRow(
          //   item: s.items[i],
          //   onSubmit: (...) => ref.read(<feature>ControllerProvider.notifier).submit(...),
          // );
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ============================================================================
// BLOCK 4 — lib/src/<feature>/widgets/<feature>_item_row.dart
// A leaf View, one primary type per file. Domain-aware widgets stay in the feature;
// promote to shared ui/ ONLY if reused by >=2 features AND domain-blind (no Card/Grade,
// no provider reads — everything via the constructor) (§2).
// ============================================================================

// import 'package:flutter/material.dart';
// import 'package:engine/engine.dart'; // ReviewItem (a domain type — so this widget stays in the feature)

class <Feature>ItemRow extends StatelessWidget {
  const <Feature>ItemRow({super.key, required this.item, required this.onSubmit});
  final Object /* TODO: ReviewItem */ item;
  final void Function(/* TODO: Grade grade, List<int> errorLines */) onSubmit;

  @override
  Widget build(BuildContext context) {
    // Reveal-on-tap / grade buttons go here. Tokens by name; logical start/end for RTL.
    // No streak/badge/score/confetti — calm, reverent surfaces only (§2 Pitfalls).
    return const SizedBox.shrink(); // TODO
  }
}

// ============================================================================
// BLOCK 5 — add to app/composition/router.dart (NOT a feature file)
// Register the screen as a GoRoute under the single ShellRoute that hosts the
// persistent RTL bottom nav. RTL order (rightmost = home):
//   Today · Muṣḥaf · Mutashābihāt · Progress · Settings (§6).
// The bottom nav and directional icons mirror automatically under Directionality.
// The redirect guard already blocks Quran screens until the core pack is verified
// and a profile exists — a new route inherits it; do NOT bypass with Navigator.push (§6).
// ============================================================================

// Inside ShellRoute(routes: [ ... ]) in app/composition/router.dart:
//
//   GoRoute(
//     path: '/<feature>',
//     builder: (_, __) => const <Feature>Screen(),
//     // For a deep-linkable param, type it: page/:pageId → int.parse(s.pathParameters['pageId']!)
//   ),
//
// And add the destination to the bottom-nav bar in HomeShell, in the RTL order above.

// ============================================================================
// TESTS (mirror the source tree under packages/features/test/)
// - ViewModel: ProviderContainer.test() + overrideWith faking the repository
//   (NOT the Notifier) — verify wiring + UI-state mapping, not FSRS math (§7).
// - View: widget + golden tests with the REAL fonts and a pinned runner (02 §3.1, §7).
// ============================================================================
