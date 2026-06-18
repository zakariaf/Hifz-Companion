// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import '../render/glyph_line.dart' show qpcFontFamily;
import 'asset_vault.dart';

/// Registers every per-page KFGQPC glyph font with the engine — but **only**
/// after each font's bytes pass their hash (engineering 08 §2; PRD §11.1.1).
///
/// For each page `1..pageCount` it reads the bytes through
/// [AssetVault.readVerified] (which **throws** on a hash mismatch / missing
/// font), then registers them under `qpcFontFamily(page)` via [registrar]
/// (default [FontLoaderRegistrar]). An unverified font is **never** registered:
/// the throw from `readVerified` propagates, registration stops, and the page is
/// left with no `QPC_P###` family — which downstream (T07) is a refusal to
/// render, never a fallback font.
///
/// Bundle-first (amended 2026-06-18): the fonts are **bundled** assets, so the
/// vault reads them from the asset bundle (not a downloaded pack); [fontSha256]
/// and [pageCount] are plain values from the `MushafEdition` triple, so the
/// dependency-free `quran` package needs no `models`/`assets` import.
Future<void> registerVerifiedPageFonts({
  required int pageCount,
  required Map<int, String> fontSha256,
  required AssetVault vault,
  PageFontRegistrar registrar = const FontLoaderRegistrar(),
}) async {
  for (var page = 1; page <= pageCount; page++) {
    final expected = fontSha256[page];
    if (expected == null) {
      throw StateError('No pinned SHA-256 for page $page font.');
    }
    // Verify-before-register: readVerified throws on mismatch, so a tampered
    // font never reaches the registrar.
    final bytes =
        await vault.readVerified(page: page, expectedSha256: expected);
    await registrar.register(qpcFontFamily(page), bytes);
  }
}
