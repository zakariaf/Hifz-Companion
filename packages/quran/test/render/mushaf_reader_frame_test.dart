// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  const page = ImmutableGlyphPage(
    pageNumber: 1,
    lines: [
      GlyphLine(
        pageNumber: 1,
        lineNumber: 1,
        type: LineType.ayah,
        glyphCodes: 'AB',
      ),
      GlyphLine(
        pageNumber: 1,
        lineNumber: 2,
        type: LineType.ayah,
        glyphCodes: 'CD',
      ),
    ],
  );
  const identityFilter = ColorFilter.mode(Color(0x00000000), BlendMode.dst);

  Widget framed(double zoom) => Directionality(
        textDirection: TextDirection.rtl,
        child: MushafReaderFrame(
          glyphPage: page,
          zoom: zoom,
          colorFilter: identityFilter,
        ),
      );

  List<String?> glyphTree(WidgetTester tester) =>
      tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();

  testWidgets('zoom scales without reflowing — the glyph tree is identical',
      (tester) async {
    await tester.pumpWidget(framed(1));
    final atOne = glyphTree(tester);

    await tester.pumpWidget(framed(2.5));
    final atTwoAndAHalf = glyphTree(tester);

    expect(atOne, ['AB', 'CD']);
    expect(atTwoAndAHalf, atOne, reason: 'zoom must not re-flow the page');

    // The scale is applied as a single uniform Transform.scale.
    final transform = tester.widget<Transform>(find.byType(Transform).first);
    expect(transform.alignment, Alignment.topRight);
  });

  testWidgets('zoom is independent of OS text-scale (never reflows on it)',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: framed(1),
      ),
    );
    // The muṣḥaf tree is the same as at default text-scale: the frame never
    // reads MediaQuery.textScalerOf, so the page does not reflow with it.
    expect(glyphTree(tester), ['AB', 'CD']);
  });

  testWidgets('sepia/dark is one ColorFilter over the layer, never a font swap',
      (tester) async {
    await tester.pumpWidget(framed(1));
    expect(find.byType(ColorFiltered), findsOneWidget);
    // The glyph lines still use their dedicated QPC family — no per-theme font.
    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.style!.fontFamily, 'QPC_P001');
      expect(text.style!.fontFamilyFallback, isEmpty);
    }
  });
}
