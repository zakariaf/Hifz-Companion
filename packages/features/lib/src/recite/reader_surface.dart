// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/theme/spacing_tokens.dart';

/// The seam onto the immutable muṣḥaf page the recite flow masks and overlays
/// (PRD R1). E13 (muṣḥaf-reader) supplies the real implementation — the KFGQPC
/// per-page glyph widget and its fixed per-line geometry — composed here and
/// never re-typeset. Until the ~40–55 MB bundled assets land, the recite route
/// runs against [StubReciteReaderSurface]; the recite flow's reveal/stumble/
/// grade behaviour is built and tested against the seam, and the real-font
/// glyph-fidelity goldens are deferred to E13.
abstract interface class ReciteReaderSurface {
  /// The number of lines on [pageId] (the Madani muṣḥaf is 15 per page).
  int lineCount(int pageId);

  /// Builds the immutable glyph for one 0-based [lineIndex] of [pageId]. The
  /// recite flow composes this and masks/overlays it — it never reflows it.
  Widget buildLine(BuildContext context, int pageId, int lineIndex);
}

/// The pre-asset stub: a fixed 15-line page whose lines are calm placeholder
/// boxes (no glyph, no text). It lets the recite flow's masking, reveal-on-tap,
/// stumble-overlay, and grade-band wiring be built and tested before E13's real
/// glyph widget exists. The masked-vs-revealed glyph-fidelity golden is the only
/// thing that waits for the real KFGQPC font.
class StubReciteReaderSurface implements ReciteReaderSurface {
  /// Creates the stub.
  const StubReciteReaderSurface();

  @override
  int lineCount(int pageId) => 15;

  @override
  Widget buildLine(BuildContext context, int pageId, int lineIndex) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Container(
      height: space.space5,
      margin: EdgeInsetsDirectional.symmetric(horizontal: space.space6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(space.space1),
      ),
    );
  }
}

/// The injected reader surface (PRD R1). Defaults to the stub so the recite route
/// runs offline today; the app root overrides it with E13's real KFGQPC-backed
/// surface when the bundled assets land.
final reciteReaderSurfaceProvider = Provider<ReciteReaderSurface>(
  (ref) => const StubReciteReaderSurface(),
);
