// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Captures a real on-device screenshot of the rendered muṣḥaf page (the verified
// bundled core, real KFGQPC fonts). Run with the screenshot driver:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/mushaf_screenshot_test.dart -d <device>

import 'package:composition/composition.dart' show installAndPrepareCore;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:models/models.dart' as models;
import 'package:quran/quran.dart' show LineType, MushafLineRef, MushafReaderPage;

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captures the rendered muṣḥaf page 1', (tester) async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);

    final ready = await installAndPrepareCore(handle);
    expect(ready, isTrue);

    final lines = await handle.reference.linesForPage(1);
    final refs = <MushafLineRef>[
      for (final l in lines)
        MushafLineRef(
          lineNumber: l.lineNumber,
          lineType: switch (l.lineType) {
            models.LineType.ayah => LineType.ayah,
            models.LineType.surahHeader => LineType.surahName,
            models.LineType.basmala => LineType.basmala,
          },
          textGlyphRef: l.textGlyphRef,
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFFBF7EE),
          // Full-bleed bounded area (like the reader viewport) so the frame's
          // page-filling FittedBox scales the page to fill it, not natural size.
          body: SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: MushafReaderPage(
                pageNumber: 1,
                lines: refs,
                zoom: 1,
                colorFilter:
                    const ColorFilter.mode(Color(0x00000000), BlendMode.dst),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    await binding.takeScreenshot('mushaf_page1');
  });
}
