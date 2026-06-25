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
        SettingsScreen,
        TodayScreen,
        kMutashabihatDrillPathPrefix,
        kProfilesPath,
        kRecitePathPrefix,
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
/// Route table: one top-level `/onboarding` outside the shell, then one
/// `ShellRoute` hosting the five tabs in RTL order — `/today`, `/mushaf` (the
/// reader, with optional range-validated `page`/`juz`/`hizb`/`surah` query
/// deep-links), `/mutashabihat`, `/progress`, `/settings`. `initialLocation` is
/// `/today`.
///
/// Redirect guard (R1 in code): the shell needs a profile, so a fresh device is
/// routed to `/onboarding` first; a Quran-rendering route (`/mushaf…`) resolves
/// only once [appReadyProvider] is true (the core pack is verified **and** a
/// profile exists), otherwise it falls back to the calm `/today` home. The
/// `refreshListenable` re-runs the guard when the active profile or the
/// verified-core state changes, so an in-flight location (a notification or
/// deep-link tap) re-resolves after the gate flips — it can never bypass it.
///
/// Destination builders are minimal keyed stubs in this task; E07-T04 supplies
/// the real `HomeShell` chrome and the inert placeholder/Today screens.
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
      // The Muṣḥaf tab now *is* the glyph-rendering reader (E13), so the whole
      // `/mushaf` subtree is gated on the verified core — not just a nested
      // reader path. The mutashābihāt discrimination drill (E14) also composes
      // the immutable glyph page, so its subtree is gated identically. The
      // reader renders only behind this gate (R1).
      final isQuranReader = location.startsWith('/mushaf') ||
          location.startsWith(kMutashabihatDrillPathPrefix);

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
        // RTL order: Today · Muṣḥaf · Mutashābihāt · Progress · Settings
        // (rightmost = home Today under the app-wide RTL Directionality).
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
            // The recite/grade route, opened from a Today page-card tap
            // (E12-T07). It masks the (E13) reader surface; a malformed id
            // fails closed to a calm not-found, never an exception.
            path: '$kRecitePathPrefix/:pageId',
            builder: (context, state) {
              final pageId = int.tryParse(state.pathParameters['pageId']!);
              if (pageId == null) return const _RouteStub('not-found-stub');
              return ReciteGradeScreen(pageId: pageId);
            },
          ),
          GoRoute(
            path: '/mutashabihat',
            builder: (context, state) => const MutashabihatTrainerScreen(),
          ),
          GoRoute(
            // The discrimination-drill route, opened from a trainer group tap
            // (E14-T08). It composes the immutable glyph page (gated on the
            // verified core above); a missing group id fails closed to a calm
            // not-found, never an exception.
            path: '$kMutashabihatDrillPathPrefix/:groupId',
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
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: kProfilesPath,
            builder: (context, state) => const ProfilesScreen(),
          ),
        ],
      ),
    ],
  );
});

/// A minimal keyed destination sentinel for the E07-T03 route table — the
/// redirect-guard test finds it by key/text. Replaced by real screens in
/// E07-T04 / E07-T07.
class _RouteStub extends StatelessWidget {
  const _RouteStub(this.id);

  final String id;

  @override
  Widget build(BuildContext context) => Center(
        key: ValueKey<String>(id),
        child: Text(id),
      );
}
