// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// Compile-time coordinates of the public, open-source Quran-data release —
/// never resolved at runtime (engineering 09 §1).
///
/// **Bundle-first (amended 2026-06-18):** the core muṣḥaf (Tanzil text + the
/// 604 KFGQPC QCF V2 fonts + the QUL layout) is **bundled in the signed app
/// binary** and verified by a build-time SHA-256 manifest — it is **never
/// fetched at runtime**. These coordinates name the immutable GitHub Release the
/// bundled core was *built from* (its provenance) and the same release that
/// hosts **optional** packs (reciter audio, future alt-muṣḥaf), which are the
/// only assets the downloader (E05-T02) ever GETs. The pinned tag is an exact
/// tag, never `latest`: a 404 means "keep the verified local copy," never
/// "fetch something else."
class PackCoordinates {
  const PackCoordinates._();

  /// The public, open-source Quran-data repository (itself a form of *waqf*).
  static const String repo = 'hifz-companion/quran-assets';

  /// The **exact** pinned release tag — never `latest`, never a moving pointer.
  /// The bundled core was built from this release; optional packs are pinned to
  /// it (or their own exact tag) too.
  static const String pinnedTag = 'core-v1.0.0';

  /// Builds the immutable-Release asset URL for [fileName] at [pinnedTag]:
  /// `https://github.com/<repo>/releases/download/<tag>/<file>`.
  ///
  /// A pure function of the pinned tag — there is no code path that resolves the
  /// newest release. Used by the optional-pack downloader (E05-T02) only.
  static Uri assetUrl(String fileName) => Uri.parse(
        'https://github.com/$repo/releases/download/$pinnedTag/$fileName',
      );
}
