// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T05 — the grade band: four thumb-zone FilledButtons (Again/Hard/Good/Easy)
// in the four canonical states, verdict+consequence semantics, disabled-as-
// waiting (not error), and NO celebration on any grade.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

const _region = kDefaultTermSetRegion;

Widget _host({
  required bool enabled,
  ValueChanged<GradeChoice>? onGrade,
  MihrabAppearance appearance = MihrabAppearance.light,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(appearance),
    home: Scaffold(
      body: GradeBand(enabled: enabled, onGrade: onGrade ?? (_) {}),
    ),
  );
}

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('four verbs in order; each enabled tap fires its GradeChoice',
      (tester) async {
    final fired = <GradeChoice>[];
    await tester.pumpWidget(_host(enabled: true, onGrade: fired.add));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));

    for (final (choice, verb) in [
      (GradeChoice.again, l10n.gradeAgainVerb(_region)),
      (GradeChoice.hard, l10n.gradeHardVerb(_region)),
      (GradeChoice.good, l10n.gradeGoodVerb(_region)),
      (GradeChoice.easy, l10n.gradeEasyVerb(_region)),
    ]) {
      expect(find.text(verb), findsOneWidget, reason: 'verb $verb present');
      await tester.tap(find.text(verb));
      expect(fired.last, choice);
    }
    expect(find.byType(FilledButton), findsNWidgets(4));
  });

  testWidgets('disabled is waiting, not error — no tap fires, hint shown',
      (tester) async {
    final fired = <GradeChoice>[];
    await tester.pumpWidget(_host(enabled: false, onGrade: fired.add));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));

    await tester.tap(
      find.text(l10n.gradeGoodVerb(_region)),
      warnIfMissed: false,
    );
    expect(fired, isEmpty);
    expect(find.text(l10n.gradeBandWaitingHint), findsOneWidget);
  });

  testWidgets('pressed resolves to the M3 state layer over the role on-color',
      (tester) async {
    await tester.pumpWidget(_host(enabled: true));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    final scheme = Theme.of(tester.element(find.byType(GradeBand))).colorScheme;
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, l10n.gradeAgainVerb(_region)),
    );
    final overlay = button.style!.overlayColor!.resolve({WidgetState.pressed})!;
    expect(overlay.a, closeTo(0.10, 1e-6));
    expect(overlay.r, scheme.onPrimary.r);
  });

  testWidgets('focus ring is wired per button (SC 2.4.7)', (tester) async {
    await tester.pumpWidget(_host(enabled: true));
    expect(find.byType(MihrabFocusRing), findsNWidgets(4));
  });

  testWidgets('each button speaks verdict + consequence; Again stays calm',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(enabled: true));
    await tester.pump();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    for (final semantics in [
      l10n.gradeAgainSemantics,
      l10n.gradeHardSemantics,
      l10n.gradeGoodSemantics,
      l10n.gradeEasySemantics,
    ]) {
      expect(find.bySemanticsLabel(semantics), findsWidgets);
    }
    // C-003: the Again consequence is calm — never "failed"/"lost".
    expect(
      RegExp('fail|lost|wrong', caseSensitive: false)
          .hasMatch(l10n.gradeAgainSemantics),
      isFalse,
    );
    handle.dispose();
  });

  testWidgets('>=48dp labelled targets', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(enabled: true));
    await tester.pumpAndSettle();
    await meetsLibraryGuidelines(tester);
    handle.dispose();
  });

  testWidgets('no celebration on Good/Easy — no streak/trophy/sparkle glyph',
      (tester) async {
    final fired = <GradeChoice>[];
    await tester.pumpWidget(_host(enabled: true, onGrade: fired.add));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.tap(find.text(l10n.gradeEasyVerb(_region)));
    await tester.pump();
    expect(fired, [GradeChoice.easy]);
    for (final icon in const [
      Icons.star,
      Icons.emoji_events,
      Icons.celebration,
      Icons.auto_awesome,
    ]) {
      expect(find.byIcon(icon), findsNothing);
    }
  });
}
