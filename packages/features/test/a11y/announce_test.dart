// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Written first (E08-T02): the announce path is a side-effecting seam that must
// speak the right localized message in the right direction. A recording fake
// over the SemanticsService announce channel captures (message, textDirection);
// each of the three announce keys is asserted per locale to equal the ARB value
// and to carry TextDirection.rtl read from the ambient Directionality — never a
// hardcoded constant.

import 'package:features/features.dart' show announceState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '_a11y_test_bootstrap.dart';

void main() {
  useOfflineTestPolicy();
  TestWidgetsFlutterBinding.ensureInitialized();

  final captured = <({String message, TextDirection direction})>[];

  setUp(() {
    captured.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(
      SystemChannels.accessibility,
      (Object? message) async {
        final map = message! as Map<Object?, Object?>;
        if (map['type'] == 'announce') {
          final data = map['data']! as Map<Object?, Object?>;
          // TextDirection.rtl.index == 0, ltr == 1.
          final isRtl =
              (data['textDirection']! as int) == TextDirection.rtl.index;
          final direction = isRtl ? TextDirection.rtl : TextDirection.ltr;
          captured.add(
            (message: data['message']! as String, direction: direction),
          );
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(
      SystemChannels.accessibility,
      null,
    );
  });

  Future<void> pumpAndAnnounce(
    WidgetTester tester,
    Locale locale,
    String Function(AppLocalizations l10n) pick,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => announceState(
                context,
                pick(AppLocalizations.of(context)!),
              ),
              child: const Text('go'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
  }

  for (final locale in a11yLocales) {
    final code = locale.languageCode;

    testWidgets('page-graded announces the $code message in RTL', (t) async {
      await pumpAndAnnounce(t, locale, (l10n) => l10n.a11yAnnouncePageGraded);
      final l10n = await localizationsFor(locale);
      expect(captured, hasLength(1));
      expect(captured.single.message, l10n.a11yAnnouncePageGraded);
      expect(captured.single.direction, TextDirection.rtl);
    });

    testWidgets('catch-up-ready announces the $code message in RTL', (t) async {
      await pumpAndAnnounce(t, locale, (l10n) => l10n.a11yAnnounceCatchUpReady);
      final l10n = await localizationsFor(locale);
      expect(captured.single.message, l10n.a11yAnnounceCatchUpReady);
      expect(captured.single.direction, TextDirection.rtl);
    });

    testWidgets('sign-off-recorded announces the $code message in RTL', (
      t,
    ) async {
      await pumpAndAnnounce(
        t,
        locale,
        (l10n) => l10n.a11yAnnounceSignOffRecorded,
      );
      final l10n = await localizationsFor(locale);
      expect(captured.single.message, l10n.a11yAnnounceSignOffRecorded);
      expect(captured.single.direction, TextDirection.rtl);
    });
  }
}
