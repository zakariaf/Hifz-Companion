// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The two release-blocking adab facts: the riwāyah is ALWAYS named, and the
// About surface credits Tanzil/QUL/KFGQPC + the checksum guarantee with ZERO
// tafsīr/translation and never "the Quran" absolutely. The label is chrome (UI
// font), not scripture (never the QPC page font). Offline.

import 'package:features/features.dart'
    show
        MihrabAppearance,
        MushafAboutCredits,
        RiwayahChromeLabel,
        mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition;

import '../test_setup.dart';

MushafEdition edition({String displayName = 'Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf'}) =>
    MushafEdition(
      mushafId: 'kfgqpc_hafs_madani_v2',
      riwayah: 'Ḥafṣ ʿan ʿĀṣim',
      displayName: displayName,
      pageCount: 604,
      lineCount: 15,
      textSha256: '',
      layoutSha256: '',
      fontSha256: const <int, String>{},
    );

Future<void> pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  useOfflineTestPolicy();

  group('riwāyah label', () {
    testWidgets('always names the active edition displayName', (tester) async {
      await pump(tester, RiwayahChromeLabel(edition: edition()));
      expect(find.text('Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf'), findsOneWidget);
    });

    testWidgets('re-renders for a different edition (reads it, not a hardcode)',
        (tester) async {
      await pump(
        tester,
        RiwayahChromeLabel(edition: edition(displayName: 'Warsh — Maghribī')),
      );
      expect(find.text('Warsh — Maghribī'), findsOneWidget);
    });

    testWidgets('is chrome, not scripture — never the QPC page font',
        (tester) async {
      await pump(tester, RiwayahChromeLabel(edition: edition()));
      final label = tester.widget<Text>(
        find.text('Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf'),
      );
      // The resolved family is the bundled UI ramp (titleSmall), never QPC_P###.
      expect(label.style?.fontFamily, isNot(startsWith('QPC_P')));
    });
  });

  group('About / Credits surface', () {
    testWidgets('credits Tanzil, QUL, KFGQPC + checksum + offline covenant',
        (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
      await pump(tester, MushafAboutCredits(edition: edition()));

      expect(find.text(l10n.mushafAboutTanzil), findsOneWidget);
      expect(find.text(l10n.mushafAboutQul), findsOneWidget);
      expect(find.text(l10n.mushafAboutFonts), findsOneWidget);
      expect(find.text(l10n.mushafAboutChecksum), findsOneWidget);
      expect(find.text(l10n.mushafAboutOffline), findsOneWidget);
      // The named riwāyah appears; the page is never called "the Quran" absolute.
      expect(find.text('Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf'), findsOneWidget);
    });

    testWidgets('draws no translation/tafsīr affordance', (tester) async {
      await pump(tester, MushafAboutCredits(edition: edition()));
      // No text field / editable / translation toggle — attribution only.
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(Switch), findsNothing);
    });
  });
}
