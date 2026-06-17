// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../test_setup.dart';

// The skeleton surfaces (E06-T08/T09) screenshot in all four appearances × all
// three RTL locales on the REAL bundled Vazirmatn face (never Ahem), so a
// physical-side leak, a clipped Sorani letter, or an appearance-recolour
// regression changes pixels and fails CI. Pinned Linux golden lane only.

const _locales = [Locale('fa'), Locale('ckb'), Locale('ar')];

File _fontFile(String weight) {
  // flutter test's CWD is the repo root or the package dir depending on the
  // invocation; try both anchors for the bundled face.
  for (final base in const ['app/assets/fonts', '../../app/assets/fonts']) {
    final file = File('$base/Vazirmatn-$weight.ttf');
    if (file.existsSync()) return file;
  }
  throw StateError('Vazirmatn-$weight.ttf not found from ${Directory.current}');
}

Future<void> _loadVazirmatn() async {
  final loader = FontLoader('Vazirmatn');
  for (final weight in const ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = await _fontFile(weight).readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

// MaterialIcons must be loaded too (flutter_test does not auto-bundle it) so the
// nav/affordance icons draw as real glyphs, not tofu. Found relative to the
// running Dart SDK inside the Flutter cache (works locally and on CI).
Future<void> _loadMaterialIcons() async {
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

Widget _gallery(MihrabAppearance appearance, Locale locale) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(appearance),
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return MihrabScaffold(
          bottomNavigationBar: MihrabNavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
          body: ListView(
            padding: const EdgeInsetsDirectional.all(16),
            children: [
              MihrabCard(
                title: l10n.navToday,
                subtitle: l10n.navProgress,
                leading: Icons.menu_book_outlined,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {},
                child: Text(l10n.navMushaf),
              ),
              const SizedBox(height: 16),
              AppearanceSwitcher(
                selected: AppearanceSetting.followSystem,
                onChanged: (_) {},
              ),
            ],
          ),
        );
      },
    ),
  );
}

void main() {
  useOfflineTestPolicy();

  setUpAll(() async {
    await _loadVazirmatn();
    await _loadMaterialIcons();
  });

  for (final appearance in MihrabAppearance.values) {
    for (final locale in _locales) {
      final name = 'gallery__${appearance.name}__${locale.languageCode}';
      testWidgets(name, (tester) async {
        tester.view.devicePixelRatio = 2.0;
        tester.view.physicalSize = const Size(780, 1688); // compact phone @2x
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_gallery(appearance, locale));
        await tester.pump(const Duration(milliseconds: 50));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('$name.png'),
        );
      });
    }
  }
}
