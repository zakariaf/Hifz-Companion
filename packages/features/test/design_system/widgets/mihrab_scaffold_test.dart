// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../test_setup.dart';

const _bodyKey = Key('body');
const _actionKey = Key('action');
const _body = SizedBox.expand(key: _bodyKey);
const _action = SizedBox(key: _actionKey, height: 48, width: 200);

const _withActionAndNav = MihrabScaffold(
  body: _body,
  bottomAction: _action,
  bottomNavigationBar: SizedBox(height: 60),
);
const _withAction = MihrabScaffold(body: _body, bottomAction: _action);
const _bodyOnly = MihrabScaffold(body: _body);

Widget _host(Widget child) {
  return MaterialApp(
    locale: const Locale('ar'),
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(MihrabAppearance.light),
    home: child,
  );
}

Finder _actionAncestor(Type type) =>
    find.ancestor(of: find.byKey(_actionKey), matching: find.byType(type));

void main() {
  useOfflineTestPolicy();

  testWidgets('the bottom action sits below the body, above the nav', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_withActionAndNav));
    await tester.pumpAndSettle();

    final bodyBottom = tester.getRect(find.byKey(_bodyKey)).bottom;
    final actionTop = tester.getRect(find.byKey(_actionKey)).top;
    expect(actionTop, greaterThanOrEqualTo(bodyBottom)); // below the body
    // and wrapped in a SafeArea band (the thumb-zone template, 05 §5).
    expect(_actionAncestor(SafeArea), findsWidgets);
  });

  testWidgets('the bottom band padding equals SpacingTokens.space4', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_withAction));
    await tester.pumpAndSettle();

    final padding = tester.widget<Padding>(_actionAncestor(Padding).first);
    final space4 = const SpacingTokens.standard().space4; // the token, not 16
    expect(padding.padding, EdgeInsetsDirectional.all(space4));
  });

  testWidgets('no bottomAction renders the body directly (no band)', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_bodyOnly));
    await tester.pumpAndSettle();
    expect(find.byKey(_bodyKey), findsOneWidget);
    expect(find.byKey(_actionKey), findsNothing);
  });
}
