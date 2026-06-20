// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Shared bootstrap for the E08 accessibility suites (T02/T06/T07/T08): the real
// bundled-font loader (never Ahem), the throwing-HttpOverrides offline guard,
// and a faithful pump of the shell chrome (MihrabScaffold + MihrabNavigationBar
// + the four inert placeholder cards) under a given locale. The chrome widgets
// are the labeled/merged a11y subject and all live in `features`; the go_router
// HomeShell that composes them lives in `app` and is widget-tested there, so the
// audit pumps the same widgets HomeShell does, without the router glue.

import 'dart:io';
import 'dart:typed_data';

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

export 'package:features/features.dart' show MihrabAppearance, mihrabThemeFor;

export '../test_setup.dart' show useOfflineTestPolicy;

/// The three RTL locales every a11y suite runs under, each in its own script.
const List<Locale> a11yLocales = [Locale('fa'), Locale('ckb'), Locale('ar')];

/// The stable accessibility identifiers of the four inert placeholder sections,
/// in their on-screen (logical) order.
const List<String> placeholderSectionIds = [
  'section.mushaf',
  'section.mutashabihat',
  'section.progress',
  'section.settings',
];

File _fontFile(String weight) {
  for (final base in const ['app/assets/fonts', '../../app/assets/fonts']) {
    final file = File('$base/Vazirmatn-$weight.ttf');
    if (file.existsSync()) return file;
  }
  throw StateError('Vazirmatn-$weight.ttf not found from ${Directory.current}');
}

/// Loads the real bundled Vazirmatn UI face and MaterialIcons so fa/ckb/ar shape
/// genuinely (Sorani extra letters, locale digit blocks) and nav glyphs draw as
/// real glyphs — never Ahem, which would defeat the script/order proofs. Call in
/// `setUpAll` for the golden/contrast/traversal suites.
Future<void> loadRealUiFonts() async {
  final loader = FontLoader('Vazirmatn');
  for (final weight in const ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = await _fontFile(weight).readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();

  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 6; i++) {
    final font = File(
      '${dir.path}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (font.existsSync()) {
      final bytes = await font.readAsBytes();
      await (FontLoader('MaterialIcons')
            ..addFont(Future.value(ByteData.sublistView(bytes))))
          .load();
      return;
    }
    dir = dir.parent;
  }
}

/// Loads [AppLocalizations] for [locale] outside a widget tree (for asserting an
/// audited label equals its ARB value rather than an English literal).
Future<AppLocalizations> localizationsFor(Locale locale) =>
    AppLocalizations.delegate.load(locale);

/// The shell chrome under audit: the five labeled nav destinations and the four
/// merged placeholder cards, themed for [appearance] and localized for [locale].
/// Mirrors what the go_router `HomeShell` composes.
Widget shellChrome({
  required Locale locale,
  MihrabAppearance appearance = MihrabAppearance.light,
  TextScaler? textScaler,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(appearance),
    // Apply the test text scale below MaterialApp's own MediaQuery, so the whole
    // app actually scales (wrapping the app from outside would be overridden).
    builder: textScaler == null
        ? null
        : (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child!,
            ),
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final titles = <String>[
          l10n.navMushaf,
          l10n.navMutashabihat,
          l10n.navProgress,
          l10n.navSettings,
        ];
        return MihrabScaffold(
          bottomNavigationBar: MihrabNavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
          body: ListView(
            children: [
              for (var i = 0; i < titles.length; i++)
                SectionPlaceholder(
                  title: titles[i],
                  identifier: placeholderSectionIds[i],
                ),
            ],
          ),
        );
      },
    ),
  );
}

/// Pumps [shellChrome] for [locale] and settles one frame. Enable semantics in
/// the test (`tester.ensureSemantics()`) before calling when auditing the tree.
Future<void> pumpShellUnderTest(
  WidgetTester tester, {
  required Locale locale,
  MihrabAppearance appearance = MihrabAppearance.light,
}) async {
  await tester.pumpWidget(shellChrome(locale: locale, appearance: appearance));
  await tester.pump(const Duration(milliseconds: 50));
}
