// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E09-T03 — the vendored ckb Material delegate proves itself: a Material surface
// under `ckb` resolves the framework chrome to Sorani (باشە / هەڵوەشاندنەوە), not
// a default-language fallback, and the locale resolves to RTL. Rendered on the
// REAL bundled UI font (Vazirmatn), never Ahem, so a missing Sorani delegate
// could not hide behind square glyphs.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

const Locale _ckb = Locale.fromSubtags(languageCode: 'ckb');
const List<Locale> _supported = <Locale>[Locale('ar'), Locale('fa'), _ckb];

File _vazirmatn() {
  for (final base in const ['app/assets/fonts', '../../app/assets/fonts']) {
    final file = File('$base/Vazirmatn-Regular.ttf');
    if (file.existsSync()) return file;
  }
  throw StateError('Vazirmatn-Regular.ttf not found from ${Directory.current}');
}

Future<void> _loadRealUiFont() async {
  final bytes = await _vazirmatn().readAsBytes();
  await (FontLoader('Vazirmatn')
        ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes))))
      .load();
}

Widget _app({required WidgetBuilder home}) => MaterialApp(
      locale: _ckb,
      supportedLocales: _supported,
      localizationsDelegates: hifzLocalizationsDelegates,
      theme: ThemeData(fontFamily: 'Vazirmatn'),
      home: Builder(builder: home),
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(_loadRealUiFont);

  testWidgets('ckb resolves the vendored Sorani Material localizations', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(home: (context) => const Scaffold(body: SizedBox.shrink())),
    );
    await tester.pumpAndSettle(); // the ckb delegate loads asynchronously

    final context = tester.element(find.byType(Scaffold));
    final ml = MaterialLocalizations.of(context);
    expect(ml, isA<CkbMaterialLocalizations>());
    expect(ml.okButtonLabel, 'باشە');
    expect(ml.cancelButtonLabel, 'هەڵوەشاندنەوە');
    // RTL is a consequence of the locale (via the ckb widgets delegate),
    // asserted — not the test's premise.
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('a Material dialog under ckb shows باشە, never a default OK', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        home: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) {
                  final ml = MaterialLocalizations.of(dialogContext);
                  return AlertDialog(
                    content: const Text('x'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {},
                        child: Text(ml.cancelButtonLabel),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(ml.okButtonLabel),
                      ),
                    ],
                  );
                },
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('باشە'), findsOneWidget);
    expect(find.text('هەڵوەشاندنەوە'), findsOneWidget);
    expect(find.text('OK'), findsNothing);
  });

  test(
      'no Global delegate claims ckb, so the custom ckb delegates are not '
      'shadowed (the order is safe; locks against a future Flutter change)',
      () {
    // Flutter ships NO ckb framework localization, so EVERY Global delegate —
    // Material, Widgets, AND Cupertino — returns isSupported(ckb) == false in the
    // pinned Flutter. The custom ckb delegates are therefore reached and used
    // regardless of registration order; they are not dead code (the dialog test
    // above proves ckb renders Sorani Material + RTL via them). This refutes a
    // "GlobalWidgets shadows the custom delegates" concern, and would fail loudly
    // — prompting a reorder (prepend) — if a future Flutter made a Global claim ckb.
    expect(GlobalMaterialLocalizations.delegate.isSupported(_ckb), isFalse);
    expect(GlobalWidgetsLocalizations.delegate.isSupported(_ckb), isFalse);
    expect(GlobalCupertinoLocalizations.delegate.isSupported(_ckb), isFalse);
    expect(CkbMaterialLocalizations.delegate.isSupported(_ckb), isTrue);
  });
}
