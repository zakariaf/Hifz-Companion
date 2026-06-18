// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The build-time checksum gate's pure core (engineering 08 §6; PRD §11.3 step
// 1, §20.1). Bundle-first (amended 2026-06-18): it verifies the BUNDLED core
// assets against the binary-baked manifest and against the authoritative Tanzil
// hash. Pure Dart — `crypto` + `dart:typed_data` only; NO flutter, NO
// flutter_test, NO FontLoader, NO rendering (pixels are E05-T11). Total and
// report-collecting: it accumulates EVERY drift so one run reports all, but a
// non-empty result is a hard failure.

import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// The expected digests for the core edition (from the binary-baked manifest /
/// the `MushafEdition` triple). Decoupled from `models`/Flutter so this gate
/// runs as a plain `dart run` script.
class ExpectedManifest {
  /// Creates the expected-digest set.
  const ExpectedManifest({
    required this.pageCount,
    required this.textSha256,
    required this.layoutSha256,
    required this.fontSha256,
  });

  /// The edition's page count (the font loop bound; asserted == [canonicalPageCount]).
  final int pageCount;

  /// Expected SHA-256 of the text asset (lower-case hex).
  final String textSha256;

  /// Expected SHA-256 of the layout asset (lower-case hex).
  final String layoutSha256;

  /// Page → expected font SHA-256 (lower-case hex).
  final Map<int, String> fontSha256;
}

/// The actual bundled/released artifacts on disk in CI, behind a thin read-side
/// so the test drives it with an in-memory fake (no real assets, no network).
abstract interface class ReleaseManifest {
  /// The text asset bytes.
  Uint8List get textBytes;

  /// The layout asset bytes.
  Uint8List get layoutBytes;

  /// The font bytes for [page].
  Uint8List fontBytes(int page);

  /// Whether a font asset exists for [page].
  bool hasFont(int page);

  /// The number of font assets present.
  int get fontCount;
}

/// One way the bundled assets can drift from the pinned manifest — `sealed`, so
/// a new failure mode forces every reporter to handle it.
sealed class IntegrityFailure {
  /// Const base constructor.
  const IntegrityFailure();
}

/// The pinned text digest does not equal the authoritative Tanzil hash.
final class TextDrift extends IntegrityFailure {
  /// Creates a text-drift failure.
  const TextDrift();
}

/// The actual text bytes do not hash to the pinned text digest.
final class TextMismatch extends IntegrityFailure {
  /// Creates a text-mismatch failure.
  const TextMismatch();
}

/// The actual layout bytes do not hash to the pinned layout digest.
final class LayoutMismatch extends IntegrityFailure {
  /// Creates a layout-mismatch failure.
  const LayoutMismatch();
}

/// A page font is absent from the release.
final class FontMissing extends IntegrityFailure {
  /// Creates a font-missing failure for [page].
  const FontMissing(this.page);

  /// The 1-based page whose font is missing.
  final int page;

  @override
  bool operator ==(Object other) => other is FontMissing && other.page == page;

  @override
  int get hashCode => page.hashCode;
}

/// A page font's bytes do not hash to its pinned digest.
final class FontMismatch extends IntegrityFailure {
  /// Creates a font-mismatch failure for [page].
  const FontMismatch(this.page);

  /// The 1-based page whose font mismatched.
  final int page;

  @override
  bool operator ==(Object other) => other is FontMismatch && other.page == page;

  @override
  int get hashCode => page.hashCode;
}

/// The release's font count does not match the expected page count.
final class FontCountWrong extends IntegrityFailure {
  /// Creates a font-count failure.
  const FontCountWrong(this.expected, this.actual);

  /// The expected font count (`pageCount`).
  final int expected;

  /// The actual font count in the release.
  final int actual;

  @override
  bool operator ==(Object other) =>
      other is FontCountWrong &&
      other.expected == expected &&
      other.actual == actual;

  @override
  int get hashCode => Object.hash(expected, actual);
}

/// The edition's page count is not the canonical count (C-031: 604).
final class PageCountWrong extends IntegrityFailure {
  /// Creates a page-count failure.
  const PageCountWrong(this.expected, this.actual);

  /// The canonical page count (604).
  final int expected;

  /// The edition's actual page count.
  final int actual;

  @override
  bool operator ==(Object other) =>
      other is PageCountWrong &&
      other.expected == expected &&
      other.actual == actual;

  @override
  int get hashCode => Object.hash(expected, actual);
}

/// Verifies the bundled/released artifacts in [release] against the pinned
/// [expected] digests and the [authoritativeTextSha256] (the byte-exact Tanzil
/// Uthmani hash). Total and **report-collecting**: returns EVERY drift, so one
/// CI run lists all drifted files rather than only the first. An **empty** list
/// means pass; a non-empty list is a hard build failure.
///
/// The font loop is driven by `expected.pageCount` (the manifest's parameter),
/// and `pageCount == canonicalPageCount` is asserted separately — a hardcoded
/// `604` bound would hide a wrong-edition swap.
List<IntegrityFailure> verifyAssetIntegrity({
  required ExpectedManifest expected,
  required ReleaseManifest release,
  required String authoritativeTextSha256,
  int canonicalPageCount = 604,
}) {
  final failures = <IntegrityFailure>[];

  if (expected.pageCount != canonicalPageCount) {
    failures.add(PageCountWrong(canonicalPageCount, expected.pageCount));
  }

  // The pinned text must equal the authoritative Tanzil hash, and the actual
  // text bytes must equal the pinned digest.
  if (expected.textSha256 != authoritativeTextSha256) {
    failures.add(const TextDrift());
  }
  if (_hex(release.textBytes) != expected.textSha256) {
    failures.add(const TextMismatch());
  }
  if (_hex(release.layoutBytes) != expected.layoutSha256) {
    failures.add(const LayoutMismatch());
  }

  if (release.fontCount != expected.pageCount) {
    failures.add(FontCountWrong(expected.pageCount, release.fontCount));
  }

  for (var page = 1; page <= expected.pageCount; page++) {
    if (!release.hasFont(page)) {
      failures.add(FontMissing(page));
      continue;
    }
    if (_hex(release.fontBytes(page)) != expected.fontSha256[page]) {
      failures.add(FontMismatch(page));
    }
  }

  return failures;
}

String _hex(Uint8List bytes) => sha256.convert(bytes).toString();
