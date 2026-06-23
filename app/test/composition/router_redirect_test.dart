// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The redirect guard is R1 in code: a fresh device cannot reach the shell
// (→ onboarding), and the Muṣḥaf reader (the whole `/mushaf` subtree now renders
// glyphs, E13) resolves only once the core pack is verified AND a profile
// exists. The gate inputs are faked via overrideWith — no live DB, no asset IO.
// Run under the throwing HttpOverrides.

import 'package:app/composition/router.dart';
import 'package:composition/composition.dart';
import 'package:data/testing.dart';
import 'package:features/features.dart'
    show
        MihrabAppearance,
        MushafReaderScreen,
        OnboardingScreen,
        TodayScreen,
        mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  // Pump the real router under a container with the given gate overrides; the
  // app's locale delegates + theme are supplied so the real tab screens build.
  Future<(GoRouter, ProviderContainer)> pumpRouter(
    WidgetTester tester, {
    ProfileId? profile,
    bool verified = false,
  }) async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    final container = ProviderContainer(
      overrides: [
        persistenceProvider.overrideWithValue(handle),
        coreVerifiedProvider.overrideWith((ref) async => verified),
        if (profile != null)
          initialActiveProfileProvider.overrideWithValue(profile),
      ],
    );
    addTearDown(container.dispose);
    await container.read(coreVerifiedProvider.future);

    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (router, container);
  }

  String location(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.toString();

  group('the shell needs a profile (onboarding gate)', () {
    testWidgets('a fresh device (no profile) lands on onboarding', (t) async {
      final (router, _) = await pumpRouter(t);
      expect(location(router), '/onboarding');
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('a fresh device cannot reach the Quran reader (R1)', (t) async {
      final (router, _) = await pumpRouter(t);
      router.go('/mushaf?page=5');
      await t.pumpAndSettle();
      expect(location(router), '/onboarding');
      expect(find.byType(MushafReaderScreen), findsNothing);
    });
  });

  group('a profiled device reaches the shell; the reader stays gated', () {
    testWidgets('Today is reachable on a profile alone', (t) async {
      final (router, _) = await pumpRouter(t, profile: const ProfileId('p1'));
      expect(location(router), '/today');
      expect(find.byType(TodayScreen), findsOneWidget);
    });

    testWidgets(
        'the Muṣḥaf reader is gated on the verified core (→ /today)',
        (t) async {
      // The Muṣḥaf tab now renders glyphs, so a profiled-but-unverified device
      // is sent back to the calm /today home — never the muṣḥaf (R1).
      final (router, _) = await pumpRouter(t, profile: const ProfileId('p1'));
      router.go('/mushaf');
      await t.pumpAndSettle();
      expect(location(router), '/today');
      expect(find.byType(MushafReaderScreen), findsNothing);
    });

    testWidgets('an unverified core keeps a deep link out of reach (→ /today)',
        (t) async {
      final (router, _) = await pumpRouter(t, profile: const ProfileId('p1'));
      router.go('/mushaf?page=5');
      await t.pumpAndSettle();
      expect(location(router), '/today');
      expect(find.byType(MushafReaderScreen), findsNothing);
    });
  });

  group('a verified, profiled device (appReady) renders the reader route', () {
    testWidgets('the Muṣḥaf reader resolves only once appReady is true',
        (t) async {
      final (router, _) = await pumpRouter(
        t,
        profile: const ProfileId('p1'),
        verified: true,
      );
      router.go('/mushaf');
      await t.pumpAndSettle();
      expect(location(router), '/mushaf');
      expect(find.byType(MushafReaderScreen), findsOneWidget);
    });

    testWidgets('a ready device on /onboarding is moved to /today', (t) async {
      final (router, _) = await pumpRouter(
        t,
        profile: const ProfileId('p1'),
        verified: true,
      );
      router.go('/onboarding');
      await t.pumpAndSettle();
      expect(location(router), '/today');
    });
  });

  group('typed deep-link query param', () {
    testWidgets('a page deep link opens the reader', (t) async {
      final (router, _) = await pumpRouter(
        t,
        profile: const ProfileId('p1'),
        verified: true,
      );
      router.go('/mushaf?page=12');
      await t.pumpAndSettle();
      expect(location(router), '/mushaf?page=12');
      expect(find.byType(MushafReaderScreen), findsOneWidget);
    });

    testWidgets('an unparseable page param fails closed, never throws',
        (t) async {
      // A bad query param is dropped to the safe default page — the reader still
      // opens (no not-found, no exception in the render tree).
      final (router, _) = await pumpRouter(
        t,
        profile: const ProfileId('p1'),
        verified: true,
      );
      router.go('/mushaf?page=x');
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(MushafReaderScreen), findsOneWidget);
    });
  });

  testWidgets('the guard refreshes when a profile is set mid-session',
      (t) async {
    // Start fresh (no profile, core verified) → onboarding.
    final (router, container) = await pumpRouter(t, verified: true);
    expect(location(router), '/onboarding');

    // Seeding a profile (the cold-start path) flips the gate; the
    // refreshListenable re-runs the guard and moves to the shell.
    container
        .read(activeProfileProvider.notifier)
        .select(const ProfileId('p1'));
    await t.pumpAndSettle();
    expect(location(router), '/today');
  });
}
