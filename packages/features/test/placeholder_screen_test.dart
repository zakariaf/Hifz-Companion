// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

void main() {
  testWidgets('placeholder screen builds RTL and resolves its string from l10n',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PlaceholderScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(PlaceholderScreen));
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
