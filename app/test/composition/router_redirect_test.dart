// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The redirect guard is R1 in code: a fresh device cannot reach the shell
// (→ onboarding), and no Quran-rendering route resolves until the core pack is
// verified AND a profile exists. The gate inputs are faked via overrideWith —
// no live DB, no asset IO, no real screens. Run under the throwing HttpOverrides.

import 'package:app/composition/active_profile_provider.dart';
import 'package:app/composition/app_ready_provider.dart';
import 'package:app/composition/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  // Pump HifzApp's router under a container with the given gate overrides, and
  // return the container so a test can mutate the active profile mid-session.
  Future<(GoRouter, ProviderContainer)> pumpRouter(
    WidgetTester tester, {
    ProfileId? profile,
    bool verified = false,
  }) async {
    final container = ProviderContainer(
      overrides: [
        coreVerifiedProvider.overrideWith((ref) async => verified),
        if (profile != null)
          initialActiveProfileProvider.overrideWithValue(profile),
      ],
    );
    addTearDown(container.dispose);
    // Settle coreVerified so appReady reads its resolved value.
    await container.read(coreVerifiedProvider.future);

    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
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
      expect(find.byKey(const ValueKey('onboarding-stub')), findsOneWidget);
    });

    testWidgets('a fresh device cannot reach a Quran route (R1)', (t) async {
      final (router, _) = await pumpRouter(t);
      router.go('/mushaf/page/5');
      await t.pumpAndSettle();
      expect(location(router), '/onboarding');
      expect(find.byKey(const ValueKey('mushaf-page-stub')), findsNothing);
    });
  });

  group('a profiled device reaches the shell; Quran stays gated on verified',
      () {
    testWidgets('Today is reachable on profile alone (it renders no glyphs)',
        (t) async {
      final (router, _) = await pumpRouter(t, profile: const ProfileId('p1'));
      expect(location(router), '/today');
      expect(find.byKey(const ValueKey('today-stub')), findsOneWidget);
    });

    testWidgets('an unverified core keeps /mushaf out of reach (→ /today)',
        (t) async {
      final (router, _) = await pumpRouter(t, profile: const ProfileId('p1'));
      router.go('/mushaf');
      await t.pumpAndSettle();
      expect(location(router), '/today');
      expect(find.byKey(const ValueKey('mushaf-stub')), findsNothing);
    });
  });

  group('a verified, profiled device (appReady) renders Quran routes', () {
    testWidgets('a Quran deep link resolves only once appReady is true',
        (t) async {
      final (router, _) = await pumpRouter(
        t,
        profile: const ProfileId('p1'),
        verified: true,
      );
      router.go('/mushaf/page/3');
      await t.pumpAndSettle();
      expect(location(router), '/mushaf/page/3');
      expect(find.text('page-3'), findsOneWidget);
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

  group('typed deep-link param', () {
    testWidgets('page/:pageId is parsed to an int and passed typed', (t) async {
      final (router, _) = await pumpRouter(
        t,
        profile: const ProfileId('p1'),
        verified: true,
      );
      router.go('/mushaf/page/12');
      await t.pumpAndSettle();
      expect(find.text('page-12'), findsOneWidget);
    });

    testWidgets('a non-int pageId fails closed (not-found), never throws',
        (t) async {
      final (router, _) = await pumpRouter(
        t,
        profile: const ProfileId('p1'),
        verified: true,
      );
      router.go('/mushaf/page/x');
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byKey(const ValueKey('not-found-stub')), findsOneWidget);
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
