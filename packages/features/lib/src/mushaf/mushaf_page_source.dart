// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show persistenceProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' as models;
import 'package:quran/quran.dart' show LineType, MushafLineRef;

/// The verified per-page line refs for the muṣḥaf reader: it reads the fixed
/// reference `line` rows for [pageNumber] and projects them into wall-safe
/// [MushafLineRef]s (line number + type + opaque `textGlyphRef`). The assembly
/// into the immutable glyph layer happens **inside the `quran` package**
/// (`MushafReaderPage`), so the feature layer never names the glyph surface —
/// the "two pipelines, one rule" wall stays intact (design-system 04 §1).
///
/// **Read-only and offline.** It opens no socket; it reads only the
/// checksum-verified reference structure E05 loaded into the local store (R1).
/// `textGlyphRef` is carried **opaque** — never parsed or logged as Arabic text.
/// Bundle-first: until the core reference pack is installed the reference is
/// empty, so a page projects to zero lines (a blank page) today.
final mushafPageProvider =
    FutureProvider.autoDispose.family<List<MushafLineRef>, int>(
  (ref, pageNumber) async {
    final reference = ref.watch(persistenceProvider).reference;
    final lines = await reference.linesForPage(pageNumber);
    return [
      for (final line in lines)
        MushafLineRef(
          lineNumber: line.lineNumber,
          lineType: _toRenderLineType(line.lineType),
          // Opaque pre-shaped glyph codes — drawn straight, never as text.
          textGlyphRef: line.textGlyphRef,
        ),
    ];
  },
);

/// Maps the persisted reference `LineType` to E05's render `LineType` (placement
/// only — never the glyphs). Exhaustive: the reference set is `ayah`,
/// `surahHeader`, `basmala`.
LineType _toRenderLineType(models.LineType type) => switch (type) {
      models.LineType.ayah => LineType.ayah,
      models.LineType.surahHeader => LineType.surahName,
      models.LineType.basmala => LineType.basmala,
    };
