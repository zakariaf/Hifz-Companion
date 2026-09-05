// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart'
    show
        DiscriminationDrillScreen,
        MushafReaderScreen,
        MutashabihatTrainerScreen,
        OnboardingScreen,
        ProfilesScreen,
        ProgressScreen,
        ReciteGradeScreen,
        ScienceScreen,
        SessionScreen,
        SettingsFocus,
        SettingsScreen,
        TodayScreen,
        kMutashabihatDrillPathPrefix,
        kRecitePathPrefix,
        kSessionPath,
        kSessionStartQuery,
        mushafReaderRouteFromUri;
import 'package:composition/composition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shell/home_shell.dart';

/// The app router as a DI `Provider<GoRouter>` (04 §6) — app-scope, never
/// `autoDispose`d. It reads the readiness gates and enforces the redirect guard;
/// it observes no connectivity, fetches no route, and opens no socket.
///
/// Route table (plain redesign, 2026-09-05): one top-level `/onboarding`
/// outside the shell; one `ShellRoute` hosting the three tabs in RTL order —
/// `/today`, `/mushaf` (the reader, with optional range-validated
/// `page`/`juz`/`hizb`/`surah` query deep-links), `/progress`; and full-screen
/// top-level routes that cover the tab bar — the revision `/session`, the
/// single-page `/recite/:pageId`, `/mutashabihat` (+ its drill), and `/settings`
/// (+ profiles, science). `initialLocation` is `/today`.
///
/// Redirect guard (R1 in code): the shell needs a profile, so a fresh device is
/// routed to `/onboarding` first; a Quran-rendering route (`/mushaf…`, the
/// drill, the session, the recite page) resolves only once [appReadyProvider]
/// is true (the core pack is verified **and** a profile exists), otherwise it
/// falls back to the calm `/today` home. The `refreshListenable` re-runs the
/// guard when the active profile or the verified-core state changes, so an
/// in-flight location (a notification or deep-link tap) re-resolves after the
/// gate flips — it can never bypass it.
final routerProvider = Provider<GoRouter>((ref) {
  // Bump on any readiness change so go_router re-runs the guard (no polling).
  final refresh = ValueNotifier<int>(0);
  ref
    ..onDispose(refresh.dispose)
    ..listen(activeProfileProvider, (_, __) => refresh.value++)
    ..listen(coreVerifiedProvider, (_, __) => refresh.value++);

  return GoRouter(
    initialLocation: '/today',
    refreshListenable: refresh,
    redirect: (context, state) {
      // ref.read (not watch): the guard is consulted per navigation, refreshed
      // by the listenable above — never a build dependency (no rebuild storm).
      final hasProfile = ref.read(activeProfileProvider) != null;
      final appReady = ref.read(appReadyProvider); // profile AND core-verified
      final location = state.matchedLocation;
      final onOnboarding = location.startsWith('/onboarding');
      // Every route that composes the immutable glyph page is gated on the
      // verified core: the reader subtree, the mutashābihāt drill, the revision
      // session, and the single-page recite route (R1).
      final isQuranReader = location.startsWith('/mushaf') ||
          location.startsWith(kMutashabihatDrillPathPrefix) ||
          location.startsWith(kSessionPath) ||
          location.startsWith(kRecitePathPrefix);

      // The shell needs a profile; a fresh device sets one up first (PRD R1).
      if (!hasProfile) return onOnboarding ? null : '/onboarding';
      // A set-up device must not sit on onboarding.
      if (onOnboarding) return '/today';
      // Quran text renders only after the core pack is verified (R1).
      if (isQuranReader && !appReady) return '/today';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        // RTL order: Today · Muṣḥaf · Progress (rightmost = home Today under
        // the app-wide RTL Directionality).
        routes: <RouteBase>[
          GoRoute(
            path: '/today',
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: '/mushaf',
            builder: (context, state) {
              // Optional, range-validated query deep-links (page/juz/ḥizb/sūrah):
              // an unparseable or out-of-range value is dropped to a safe
              // default page, never thrown and never landed on a wrong sacred
              // boundary (E13-T01; the juz/ḥizb/sūrah → page resolution is T04).
              final route = mushafReaderRouteFromUri(state.uri);
              return MushafReaderScreen(
                initialPage: route.page,
                initialJuz: route.juz,
                initialHizb: route.hizb,
                initialSurah: route.surah,
              );
            },
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
        ],
      ),
      GoRoute(
        // The continuous revision session (plain redesign): the day's pages in
        // recitation order, optionally started from `?start=<pageId>` (a Today
        // row tap). Full-screen — it covers the tab bar.
        path: kSessionPath,
        builder: (context, state) => SessionScreen(
          startPageId:
              int.tryParse(state.uri.queryParameters[kSessionStartQuery] ?? ''),
        ),
      ),
      GoRoute(
        // The single-page recite/grade route (E12-T07), kept for deep links;
        // a malformed id fails closed to a calm not-found, never an exception.
        path: '$kRecitePathPrefix/:pageId',
        builder: (context, state) {
          final pageId = int.tryParse(state.pathParameters['pageId']!);
          if (pageId == null) return const _RouteStub('not-found-stub');
          return ReciteGradeScreen(pageId: pageId);
        },
      ),
      GoRoute(
        // The mutashābihāt trainer, reached from Progress (no longer a tab).
        path: '/mutashabihat',
        builder: (context, state) => const MutashabihatTrainerScreen(),
        routes: <RouteBase>[
          GoRoute(
            // The discrimination-drill route, opened from a trainer group tap
            // (E14-T08). It composes the immutable glyph page (gated on the
            // verified core above); a missing group id fails closed to a calm
            // not-found, never an exception.
            path: 'drill/:groupId',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId'];
              if (groupId == null || groupId.isEmpty) {
                return const _RouteStub('not-found-stub');
              }
              // A malformed percent-encoding in a deep link fails closed to a
              // calm not-found, never an uncaught ArgumentError (Gemini E14 #2).
              try {
                return DiscriminationDrillScreen(
                  groupId: Uri.decodeComponent(groupId),
                );
              } on ArgumentError {
                return const _RouteStub('not-found-stub');
              }
            },
          ),
        ],
      ),
      GoRoute(
        // Settings sits behind the gear on each tab — a pushed full-screen
        // route with its own app bar. Today's budget-feedback / catch-up
        // choices deep-link here with `?focus=cycle` so the ḥāfiẓ lands on the
        // cycle & budget controls, not the top of the list (E12-T04).
        path: '/settings',
        builder: (context, state) => SettingsScreen(
          focus: SettingsFocus.fromQuery(state.uri.queryParameters['focus']),
        ),
        routes: <RouteBase>[
          GoRoute(
            path: 'profiles', // = kProfilesPath under /settings
            builder: (context, state) => const ProfilesScreen(),
          ),
          GoRoute(
            // "The science we follow" — reached from Settings/About. Not a
            // Quran route, so it is ungated (renders from the bundled register).
            path: 'science', // = kSciencePath under /settings
            builder: (context, state) => const ScienceScreen(),
          ),
        ],
      ),
    ],
  );
});

/// A minimal keyed destination sentinel — the redirect-guard test finds it by
/// key/text when a deep link carries a malformed id.
class _RouteStub extends StatelessWidget {
  const _RouteStub(this.id);

  final String id;

  @override
  Widget build(BuildContext context) => Center(
        key: ValueKey<String>(id),
        child: Text(id),
      );
}
