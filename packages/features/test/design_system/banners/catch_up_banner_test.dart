// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T08 — the catch-up banner: empathy → fact → path → rows → choices, the
// mandatory FAR row never dropped, locale-numeral counts, no red shame-pile, no
// streak/celebration, and emits a choice only (computes/mutates nothing).

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

/// A copy-invariant guard (voice 11 §9): no exclamation, no emoji, and none of
/// the optional [alsoBanned] substrings appears in any rendered Text.
void assertNoBannedPhrase(
  WidgetTester tester, {
  List<String> alsoBanned = const [],
}) {
  final emoji =
      RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true);
  for (final t in tester.widgetList<Text>(find.byType(Text))) {
    final s = t.data ?? '';
    expect(s.contains('!'), isFalse, reason: 'no exclamation: "$s"');
    expect(emoji.hasMatch(s), isFalse, reason: 'no emoji: "$s"');
    for (final banned in alsoBanned) {
      expect(s.contains(banned), isFalse, reason: 'banned "$banned" in "$s"');
    }
  }
}

CatchUpPlan plan() => const CatchUpPlan(
      missedDays: 3,
      planDays: 5,
      items: [
        PageCardViewData(
          page: 253,
          juz: 13,
          track: TrackFamily.far,
          trackLabel: 'TRACK_FAR',
          decay: DecayLevel.needsRevision,
          decayLabel: 'DECAY_FAR',
          state: CardState.dueToday,
        ),
        PageCardViewData(
          page: 254,
          juz: 13,
          track: TrackFamily.near,
          trackLabel: 'TRACK_NEAR',
          decay: DecayLevel.holding,
          decayLabel: 'DECAY_NEAR',
          state: CardState.dueToday,
        ),
      ],
    );

Widget _host({ValueChanged<CatchUpChoice>? onChoice}) {
  final p = plan();
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(MihrabAppearance.light),
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        final locale = Localizations.localeOf(context);
        return Scaffold(
          body: SingleChildScrollView(
            child: CatchUpBanner(
              plan: p,
              empathy: l10n.catchUpEmpathy,
              factLine: toLocaleNumerals(
                l10n.catchUpMissedDays(p.missedDays),
                locale,
              ),
              pathLine: toLocaleNumerals(
                l10n.catchUpPlanLine(p.planDays),
                locale,
              ),
              startLabel: l10n.catchUpStartPlan,
              adjustLabel: l10n.catchUpAdjust,
              deferLabel: l10n.catchUpDefer,
              onChoice: onChoice ?? (_) {},
            ),
          ),
        );
      },
    ),
  );
}

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('renders empathy/fact/path with locale-numeral counts',
      (tester) async {
    await tester.pumpWidget(_host());
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.catchUpEmpathy), findsOneWidget);
    // 3 missed days, a 5-day plan — Arabic-Indic, never ASCII.
    expect(find.textContaining('٣'), findsWidgets);
    expect(find.textContaining('٥'), findsWidgets);
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(RegExp(r'[0-9]').hasMatch(t.data ?? ''), isFalse);
    }
  });

  testWidgets('the mandatory FAR row is rendered (never dropped)',
      (tester) async {
    await tester.pumpWidget(_host());
    expect(find.text('TRACK_FAR'), findsOneWidget);
    expect(find.byType(MihrabPageCard), findsNWidgets(2));
  });

  testWidgets(
      'tapping a choice fires onChoice; widget computes/mutates nothing',
      (tester) async {
    final chosen = <CatchUpChoice>[];
    await tester.pumpWidget(_host(onChoice: chosen.add));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.tap(find.text(l10n.catchUpStartPlan));
    expect(chosen, [CatchUpChoice.startPlan]);
  });

  testWidgets('no red shame-pile, no retention %, no banned phrase',
      (tester) async {
    await tester.pumpWidget(_host());
    final scheme =
        Theme.of(tester.element(find.byType(CatchUpBanner))).colorScheme;
    for (final card in tester.widgetList<Card>(find.byType(Card))) {
      expect(card.color, isNot(scheme.error), reason: 'no red alarm fill');
    }
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(RegExp(r'\d+\s*%').hasMatch(t.data ?? ''), isFalse);
    }
    assertNoBannedPhrase(tester);
  });

  testWidgets('no celebration on accepting the plan', (tester) async {
    await tester.pumpWidget(_host());
    for (final icon in const [
      Icons.star,
      Icons.celebration,
      Icons.auto_awesome,
      Icons.local_fire_department,
    ]) {
      expect(find.byIcon(icon), findsNothing);
    }
  });

  testWidgets('>=48dp labelled choices (meetsLibraryGuidelines)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    await meetsLibraryGuidelines(tester);
    handle.dispose();
  });
}
