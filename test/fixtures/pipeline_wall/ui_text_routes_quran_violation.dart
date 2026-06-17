// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// DELIBERATE NEGATIVE FIXTURE — do **not** "fix" this file.
///
/// It performs the exact act the pipeline wall forbids (design-system 04 §1;
/// PRD R1): routing a muṣḥaf QPC glyph family through a UI `TextStyle`, and
/// touching the per-page `FontLoader`/`loadFontFromList` glyph-registration
/// path. It lives under `test/fixtures/` (never `lib/`) so it never ships, and
/// is excluded from analysis (it references the not-yet-built E05 glyph surface
/// on purpose). `tool/check_pipeline_wall.sh` must REJECT it;
/// `tool/test/check_pipeline_wall_test.sh` proves the rejection.
library;

import 'package:flutter/material.dart';

TextStyle quranInUiPipelineViolation() {
  final loader = FontLoader('mushaf')..loadFontFromList(_dummy());
  loader.load();
  final page = GlyphPage(glyphCodes: const <int>[]); // QPC_P0 glyph surface
  return TextStyle(fontFamily: qpcFontFamily(page.pageNumber));
}
