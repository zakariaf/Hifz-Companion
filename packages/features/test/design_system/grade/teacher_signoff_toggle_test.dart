// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T05 — the teacher sign-off toggle: a labelled Switch, OFF by default,
// autonomy-supportive copy ("for your teacher to confirm"), emits only a bool.

import 'dart:io';

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

Widget _host({required bool teacherPresent, ValueChanged<bool>? onChanged}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    // Force the Material Switch via the theme platform so the test is stable
    // (Switch.adaptive would render a CupertinoSwitch on the macOS test host).
    theme: mihrabThemeFor(MihrabAppearance.light)
        .copyWith(platform: TargetPlatform.android),
    home: Scaffold(
      body: TeacherSignoffToggle(
        teacherPresent: teacherPresent,
        onChanged: onChanged ?? (_) {},
      ),
    ),
  );
}

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('off by default; flipping fires onChanged(true) once',
      (tester) async {
    final fired = <bool>[];
    await tester.pumpWidget(
      _host(teacherPresent: false, onChanged: fired.add),
    );
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    await tester.tap(find.byType(Switch));
    expect(fired, [true]);
  });

  testWidgets('label + autonomy-supportive supporting copy', (tester) async {
    await tester.pumpWidget(_host(teacherPresent: false));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.teacherSignoffLabel), findsOneWidget);
    expect(find.text(l10n.teacherSignoffSupporting), findsOneWidget);
  });

  testWidgets('the row is a >=48dp labelled target', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(teacherPresent: false));
    await tester.pumpAndSettle();
    await meetsLibraryGuidelines(tester);
    handle.dispose();
  });

  test('the leaf imports no engine/persistence/quran symbol', () {
    for (final base in const [
      'packages/features/lib/src/design_system/grade',
      '../../packages/features/lib/src/design_system/grade',
    ]) {
      final file = File('$base/teacher_signoff_toggle.dart');
      if (!file.existsSync()) continue;
      final src = file.readAsStringSync();
      for (final banned in const [
        'package:engine',
        'package:data',
        'package:drift',
        'package:quran',
      ]) {
        expect(
          src.contains(banned),
          isFalse,
          reason: 'must not reference $banned',
        );
      }
      return;
    }
    fail('teacher_signoff_toggle.dart not found from ${Directory.current}');
  });
}
