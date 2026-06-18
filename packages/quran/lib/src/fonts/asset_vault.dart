// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:flutter/services.dart' show FontLoader;

/// The verified-bytes boundary the font registrar reads through. The concrete
/// implementation (wired at the app composition root, which has the `assets`
/// verifier) reads the **bundled** font asset and re-checks its SHA-256 against
/// [expectedSha256] before returning — **throwing** on any mismatch, missing,
/// or unreadable asset (engineering 09 §3, fail-closed). Declared here (not in
/// `assets`) so the dependency-free `quran` renderer owns its own seam.
abstract interface class AssetVault {
  /// Returns the verified bytes of page [page]'s bundled font, or **throws** if
  /// the bytes' SHA-256 does not equal [expectedSha256] (never returns
  /// unverified bytes).
  Future<Uint8List> readVerified({
    required int page,
    required String expectedSha256,
  });
}

/// The seam that registers a verified font's bytes with the engine — injected so
/// the fail-closed orchestration is testable without a real font file (a real
/// `FontLoader.load` needs valid font bytes; the 604-real-font registration is
/// exercised by the E05-T11 golden harness).
abstract interface class PageFontRegistrar {
  /// Registers [bytes] under font [family]. The KFGQPC bytes are loaded **as
  /// published** — never sub-set, re-hinted, re-compressed, or renamed.
  Future<void> register(String family, Uint8List bytes);
}

/// The production registrar: `FontLoader.addFont` + `load`, registering the
/// verified bytes with the Flutter engine unmodified.
class FontLoaderRegistrar implements PageFontRegistrar {
  /// Creates the production font registrar.
  const FontLoaderRegistrar();

  @override
  Future<void> register(String family, Uint8List bytes) {
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    return loader.load();
  }
}
