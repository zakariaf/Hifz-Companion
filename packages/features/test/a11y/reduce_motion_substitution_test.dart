// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T05 (written first): reduce-motion honoring is the SC 2.3.3 carve-out.
// Under the OS Reduce Motion flag the substitution is an instant cut (no
// in-between frame); with motion allowed it is a calm cross-fade; it never
// introduces a slide/scale/celebratory fallback; and it reads the flag only
// through E06-T07's motionReduced (no second OS-flag read in the file).

import 'dart:io';

import 'package:engine/engine.dart' show CalendarDate, Card, ReviewTrack;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        ReduceMotionSwitcher,
        TodayScreen,
        TodaySession,
        mihrabThemeFor,
        pageJuzProvider,
        todaySessionProvider;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';

// Scope transition assertions to the substitution's own subtree, so framework
// route/Tooltip transitions elsewhere in the app are not mistaken for ours.
Finder _fadesInSwitcher() => find.descendant(
      of: find.byType(ReduceMotionSwitcher),
      matching: find.byType(FadeTransition),
    );

class _Swapper extends StatefulWidget {
  const _Swapper({required this.disableAnimations});

  final bool disableAnimations;

  @override
  State<_Swapper> createState() => _SwapperState();
}

class _SwapperState extends State<_Swapper> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations: widget.disableAnimations,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => setState(() => _i++),
              child: const Text('swap'),
            ),
            ReduceMotionSwitcher(
              child: SizedBox(
                key: ValueKey<String>('child-$_i'),
                width: 50,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _host({required bool disableAnimations}) => MaterialApp(
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: Scaffold(body: _Swapper(disableAnimations: disableAnimations)),
    );

void main() {
  useOfflineTestPolicy();

  testWidgets('reduce-motion: an instant cut, no in-between frame', (
    tester,
  ) async {
    await tester.pumpWidget(_host(disableAnimations: true));
    await tester.tap(find.text('swap'));
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byKey(const ValueKey<String>('child-0')), findsNothing);
    expect(find.byKey(const ValueKey<String>('child-1')), findsOneWidget);
    // The reduced path never builds a fade — the child passes straight through.
    expect(_fadesInSwitcher(), findsNothing);
  });

  testWidgets('motion allowed: a calm cross-fade renders an in-between frame', (
    tester,
  ) async {
    await tester.pumpWidget(_host(disableAnimations: false));
    await tester.tap(find.text('swap'));
    await tester.pump(); // start the transition
    await tester.pump(const Duration(milliseconds: 60)); // mid cross-fade

    expect(_fadesInSwitcher(), findsWidgets);
    await tester.pumpAndSettle();
  });

  testWidgets('no removed delight: only cut/cross-fade, never slide/scale', (
    tester,
  ) async {
    await tester.pumpWidget(_host(disableAnimations: false));
    await tester.tap(find.text('swap'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    Finder inSwitcher(Type t) => find.descendant(
          of: find.byType(ReduceMotionSwitcher),
          matching: find.byWidgetPredicate((w) => w.runtimeType == t),
        );
    expect(inSwitcher(SlideTransition), findsNothing);
    expect(inSwitcher(ScaleTransition), findsNothing);
    expect(inSwitcher(RotationTransition), findsNothing);
    // The calm cross-fade is the only transition the substitution adds.
    expect(_fadesInSwitcher(), findsWidgets);
    await tester.pumpAndSettle();
  });

  test('the substitution reads the flag only through motionReduced', () {
    for (final base in const [
      'lib/src/a11y/reduce_motion_substitution.dart',
      'packages/features/lib/src/a11y/reduce_motion_substitution.dart',
    ]) {
      final file = File(base);
      if (!file.existsSync()) continue;
      expect(
        file.readAsStringSync().contains('disableAnimations'),
        isFalse,
        reason: 'use motionReduced(context), not a second OS-flag read',
      );
      return;
    }
    fail('reduce_motion_substitution.dart not found');
  });

  testWidgets('Today content reveal collapses to a cut under the flag', (
    tester,
  ) async {
    final card = Card(
      profileId: const ProfileId('p1'),
      pageId: 3,
      track: ReviewTrack.far,
      difficulty: 5,
      stabilityDays: 30,
      lastReviewedDay: CalendarDate.ymd(2026, 5, 1),
      dueAt: CalendarDate.ymd(2026, 6, 19),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todaySessionProvider
              .overrideWith((ref) => Stream.value(TodaySession(far: [card]))),
          pageJuzProvider.overrideWith((ref) async => const <int, int>{}),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: const Scaffold(body: TodayScreen()),
            ),
          ),
        ),
      ),
    );
    await tester.pump(); // resolve the stream
    await tester.pump(const Duration(milliseconds: 1));

    expect(
      find.byKey(const ValueKey<String>('today.populated')),
      findsOneWidget,
    );
    // No fade is built on the reveal when motion is reduced.
    expect(_fadesInSwitcher(), findsNothing);
  });
}
