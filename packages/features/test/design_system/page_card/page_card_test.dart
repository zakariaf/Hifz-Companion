// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T03 — the page card row: locale-numeral bidi-isolated headline, ONE
// labelled >=48dp tap, one merged localized phrase, six-state emphasis (never
// the page art), and the load-bearing honesty guards — no R/D/S/percentage/
// "safe to drop", no gamification, pulled-forward indistinguishable from due.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

PageCardViewData _data({
  CardState state = CardState.defaultState,
  int page = 253,
  int juz = 13,
  String? hint,
}) =>
    PageCardViewData(
      page: page,
      juz: juz,
      track: TrackFamily.far,
      trackLabel: 'TRACKWORD',
      decay: DecayLevel.needsRevision,
      decayLabel: 'DECAYWORD',
      state: state,
      supportingHint: hint,
    );

Widget _host(
  PageCardViewData data, {
  VoidCallback? onOpen,
  Locale locale = const Locale('ar'),
  MihrabAppearance appearance = MihrabAppearance.light,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(appearance),
    home: Scaffold(
      body: MihrabPageCard(data: data, onOpen: onOpen ?? () {}),
    ),
  );
}

Card _card(WidgetTester tester) => tester.widget<Card>(find.byType(Card));

void main() {
  useOfflineTestPolicy();

  setUpAll(loadMihrabUiFonts);

  group('headline — locale numerals, bidi-isolated, never ASCII', () {
    for (final (locale, page, juz) in const [
      (Locale('fa'), '۲۵۳', '۱۳'),
      (Locale('ckb'), '۲۵۳', '۱۳'),
      (Locale('ar'), '٢٥٣', '١٣'),
    ]) {
      testWidgets('${locale.languageCode}: digits + isolation', (tester) async {
        await tester.pumpWidget(_host(_data(), locale: locale));
        final headline = tester.widget<Text>(find.textContaining(page));
        final value = headline.data!;
        expect(value.contains(page), isTrue);
        expect(value.contains(juz), isTrue);
        expect(value.contains('253'), isFalse, reason: 'no ASCII splice');
        // page precedes juz and each numeric run is LRI…PDI isolated.
        expect(value.indexOf(page), lessThan(value.indexOf(juz)));
        expect(value.runes.where((r) => r == 0x2066).length, 2);
      });
    }
  });

  testWidgets('one labelled >=48dp tap fires onOpen once', (tester) async {
    var taps = 0;
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(_data(), onOpen: () => taps++));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MihrabPageCard));
    expect(taps, 1);
    await meetsLibraryGuidelines(tester); // tap target + labeled + contrast
    handle.dispose();
  });

  testWidgets('one merged phrase carries page, juz, track, decay, and state',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(_data(state: CardState.weak)));
    await tester.pump();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    // MergeSemantics collapses the row into ONE node carrying every part in
    // order: track, decay, "Page N · Juz M", state.
    final phrase = RegExp(
      'TRACKWORD[\\s\\S]*DECAYWORD[\\s\\S]*٢٥٣[\\s\\S]*١٣[\\s\\S]*${l10n.stateWeak}',
    );
    expect(
      find.bySemanticsLabel(phrase),
      findsWidgets,
      reason: 'one merged phrase carries page, juz, track, decay, and state',
    );
    handle.dispose();
  });

  group('six-state emphasis — border/surface only, never the page art', () {
    testWidgets('weak shows a quiet warning outline, not alarm-red',
        (tester) async {
      await tester.pumpWidget(_host(_data(state: CardState.weak)));
      final colors = Theme.of(tester.element(find.byType(Card)))
          .extension<MihrabColors>()!;
      final side = (_card(tester).shape! as RoundedRectangleBorder).side;
      expect(side.color, colors.semanticWarning);
    });

    testWidgets(
        'pulled-forward is identical to due (no "algorithm chose this")',
        (tester) async {
      await tester.pumpWidget(_host(_data(state: CardState.dueToday)));
      final dueColor = _card(tester).color;
      final dueTexts = find.byType(Text).evaluate().length;

      await tester.pumpWidget(_host(_data(state: CardState.pulledForward)));
      expect(_card(tester).color, dueColor);
      expect(find.byType(Text).evaluate().length, dueTexts);
    });

    testWidgets('done is a dimmed, checked status row', (tester) async {
      await tester.pumpWidget(_host(_data(state: CardState.done)));
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      final scheme = Theme.of(tester.element(find.byType(Card))).colorScheme;
      final headline = tester.widget<Text>(find.textContaining('٢٥٣'));
      expect(headline.style?.color, scheme.onSurfaceVariant);
    });

    testWidgets('locked shows the lock affordance (a human override)',
        (tester) async {
      await tester.pumpWidget(_host(_data(state: CardState.locked)));
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('the focus ring is wired (SC 2.4.7)', (tester) async {
      await tester.pumpWidget(_host(_data()));
      expect(find.byType(MihrabFocusRing), findsOneWidget);
    });
  });

  testWidgets('negative honesty guard — no R/percentage/safe-to-drop, no badge',
      (tester) async {
    final forbidden = RegExp(
      r'\d+\s*%|safe to drop|mastered|\bR\s*[:=]',
      caseSensitive: false,
    );
    for (final state in CardState.values) {
      await tester.pumpWidget(_host(_data(state: state)));
      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        final value = text.data ?? '';
        expect(
          forbidden.hasMatch(value),
          isFalse,
          reason: '"$value" leaks a number/"safe to drop" in $state',
        );
      }
      // No gamification glyphs (badge/trophy/streak/celebration).
      for (final icon in const [
        Icons.star,
        Icons.emoji_events,
        Icons.local_fire_department,
      ]) {
        expect(
          find.byIcon(icon),
          findsNothing,
          reason: 'no gamification in $state',
        );
      }
    }
  });
}
