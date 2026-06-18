// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  const page = ImmutableGlyphPage(
    pageNumber: 7,
    lines: [
      GlyphLine(
        pageNumber: 7,
        lineNumber: 1,
        type: LineType.ayah,
        glyphCodes: 'A',
      ),
      GlyphLine(
        pageNumber: 7,
        lineNumber: 2,
        type: LineType.ayah,
        glyphCodes: 'BC',
      ),
    ],
  );

  testWidgets(
      'every muṣḥaf line carries fontFamilyFallback: const [] '
      '(no fallback ever re-shapes the sacred path)', (tester) async {
    await tester.pumpWidget(const MushafPageView(glyphPage: page));

    final texts = tester.widgetList<Text>(find.byType(Text)).toList();
    expect(texts, hasLength(2));
    for (final text in texts) {
      expect(text.style!.fontFamilyFallback, isEmpty);
      expect(text.style!.fontFamily, 'QPC_P007');
      expect(text.textDirection, TextDirection.rtl);
      expect(text.softWrap, isFalse);
      expect(text.maxLines, 1);
    }
  });

  testWidgets(
      'draws one line per GlyphLine, in order, with the raw glyph codes',
      (tester) async {
    await tester.pumpWidget(const MushafPageView(glyphPage: page));
    final texts = tester.widgetList<Text>(find.byType(Text)).toList();
    expect(texts.map((t) => t.data), ['A', 'BC']);
  });

  testWidgets('renders under an RTL Directionality', (tester) async {
    await tester.pumpWidget(const MushafPageView(glyphPage: page));
    final dir = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.byType(Text).first,
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(dir.textDirection, TextDirection.rtl);
  });
}
