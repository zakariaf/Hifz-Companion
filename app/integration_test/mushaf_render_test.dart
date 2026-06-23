// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Proves the bundled-core render path end-to-end on a real engine: the verified
// install registers the 604 KFGQPC fonts and builds the reference DB from the
// bundled QUL/Tanzil assets, and the muṣḥaf page then renders real opaque glyph
// lines (no longer the bundle-first blank). Runs on a device/simulator:
//   flutter test integration_test/mushaf_render_test.dart -d <device>

import 'package:composition/composition.dart' show installAndPrepareCore;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:models/models.dart' as models;
import 'package:quran/quran.dart' show LineType, MushafLineRef, MushafReaderPage;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'verified bundled core installs and page 1 renders real glyph lines',
    (tester) async {
      final handle = inMemoryPersistenceHandle();
      addTearDown(handle.close);

      // The real first-launch sequence: verify + register every bundled font,
      // verify the data files, build the reference DB, stamp ready.
      final ready = await installAndPrepareCore(handle);
      expect(
        ready,
        isTrue,
        reason: 'every bundled byte must verify and every font register',
      );

      // The reference DB now projects real lines for page 1 (Al-Fātiḥa).
      final lines = await handle.reference.linesForPage(1);
      expect(lines, isNotEmpty);
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
      final firstGlyphLine =
          refs.firstWhere((r) => r.textGlyphRef.isNotEmpty).textGlyphRef;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
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
      );
      await tester.pump();

      // No longer blank: the opaque QPC glyph string reaches a Text widget drawn
      // in the page's dedicated KFGQPC family.
      expect(find.text(firstGlyphLine), findsWidgets);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
