// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The welcome + privacy step (E11-T02): a dumb View stating the ṣadaqah intent,
// the C-048 privacy covenant (no account / no mic / on-device / offline), and
// the C-046 servant-to-the-teacher framing. It opens no socket, reads no clock,
// renders no muṣḥaf glyph, names no edition, and advances only via onContinue.

import 'package:features/features.dart';
import 'package:features/src/onboarding/widgets/welcome_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  Future<AppLocalizations> pump(
    WidgetTester tester,
    Locale locale, {
    VoidCallback? onContinue,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(body: WelcomeStep(onContinue: onContinue ?? () {})),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.delegate.load(locale);
  }

  for (final tag in const ['ar', 'fa', 'ckb']) {
    testWidgets('renders intent, privacy covenant, and servant line ($tag)',
        (t) async {
      final l10n = await pump(t, Locale(tag));
      expect(find.text(l10n.onboardingWelcomeIntent), findsOneWidget);
      expect(find.text(l10n.onboardingWelcomePrivacyNoAccount), findsOneWidget);
      expect(find.text(l10n.onboardingWelcomePrivacyNoMic), findsOneWidget);
      expect(find.text(l10n.onboardingWelcomePrivacyOnDevice), findsOneWidget);
      final offline = find.text(l10n.onboardingWelcomePrivacyOfflineAfter);
      expect(offline, findsOneWidget);
      expect(find.text(l10n.onboardingWelcomeServant), findsOneWidget);
    });
  }

  testWidgets('no exclamation, no transactional token in any rendered string',
      (t) async {
    await pump(t, const Locale('ar'));
    final texts =
        t.widgetList<Text>(find.byType(Text)).map((w) => w.data ?? '');
    expect(texts, isNotEmpty);
    const banned = ['premium', 'upgrade', 'unlock', 'trial', 'subscribe'];
    for (final s in texts) {
      expect(s.contains('!'), isFalse, reason: 'no exclamation in: $s');
      for (final word in banned) {
        expect(s.toLowerCase().contains(word), isFalse, reason: 'in: $s');
      }
    }
  });

  testWidgets('Continue invokes onContinue exactly once', (t) async {
    var taps = 0;
    final l10n = await pump(t, const Locale('ar'), onContinue: () => taps++);
    await t.tap(find.widgetWithText(FilledButton, l10n.onboardingContinue));
    await t.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('each block is a labelled Semantics node; Continue is a button',
      (t) async {
    final l10n = await pump(t, const Locale('ar'));
    final noMic = find.bySemanticsLabel(l10n.onboardingWelcomePrivacyNoMic);
    final servant = find.bySemanticsLabel(l10n.onboardingWelcomeServant);
    expect(noMic, findsOneWidget);
    expect(servant, findsOneWidget);
    final button = t.widget<FilledButton>(
      find.widgetWithText(FilledButton, l10n.onboardingContinue),
    );
    expect(button.onPressed, isNotNull);
  });
}
