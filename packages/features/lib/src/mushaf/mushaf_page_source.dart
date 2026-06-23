// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show persistenceProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' as models;
import 'package:quran/quran.dart' show GlyphLine, ImmutableGlyphPage, LineType;

/// The verified per-page glyph layout for the muṣḥaf reader: it reads the
/// fixed reference `line` rows for [pageNumber] and assembles them into E05's
/// immutable [ImmutableGlyphPage] (the input to `MushafPageView`).
///
/// **Read-only and offline.** It opens no socket; it reads only the
/// checksum-verified reference structure E05 loaded into the local store (R1).
/// `Line.textGlyphRef` is carried **opaque** straight into the glyph layer —
/// never parsed, normalised, split, or logged as Arabic text. Bundle-first:
/// until the core reference pack is installed the reference is empty, so a page
/// assembles to zero lines (a blank page) — the render path is E05's and is
/// never relaxed here.
final mushafPageProvider =
    FutureProvider.autoDispose.family<ImmutableGlyphPage, int>(
  (ref, pageNumber) async {
    final reference = ref.watch(persistenceProvider).reference;
    final lines = await reference.linesForPage(pageNumber);
    return ImmutableGlyphPage(
      pageNumber: pageNumber,
      lines: [
        for (final line in lines)
          GlyphLine(
            pageNumber: pageNumber,
            lineNumber: line.lineNumber,
            type: _toRenderLineType(line.lineType),
            // Opaque pre-shaped glyph codes — drawn straight, never as text.
            glyphCodes: line.textGlyphRef,
          ),
      ],
    );
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
