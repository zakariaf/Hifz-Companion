// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:crypto/crypto.dart';

/// One pinned asset: its repo-relative [path] and its [expectedSha256].
class Sha256Entry {
  /// Creates a pinned-asset entry.
  const Sha256Entry({required this.path, required this.expectedSha256});

  /// The repo-relative path of the asset to re-hash.
  final String path;

  /// The asset's expected SHA-256, lower-case hex, from the pinned manifest.
  final String expectedSha256;
}

/// The pinned, binary-baked asset manifest: the per-file SHA-256 set plus the
/// authoritative Tanzil Uthmani text hash. Never a sidecar `.sha256`.
class Sha256Manifest {
  /// Creates a pinned manifest.
  const Sha256Manifest({required this.files, required this.textSha256});

  /// Every pinned asset's expected SHA-256.
  final List<Sha256Entry> files;

  /// The authoritative Tanzil Uthmani text SHA-256 (the byte-exact muṣḥaf text).
  final String textSha256;
}

/// The pinned manifest. DORMANT in E01: an empty file set and a documented
/// placeholder Tanzil hash, so the verifier runs zero iterations and exits 0 —
/// fail-closed, never auto-blessed. E05 replaces this with the real frozen
/// hashes baked into the binary (the 604 KFGQPC fonts, the Tanzil text, the
/// layout and mutashābihāt datasets).
const Sha256Manifest pinnedManifest = Sha256Manifest(
  files: <Sha256Entry>[],
  textSha256: '', // E05: the authoritative Tanzil Uthmani SHA-256.
);

/// A failure surfaced by the asset-integrity verifier.
sealed class AssetIntegrityFailure {
  /// Const base constructor for the sealed hierarchy.
  const AssetIntegrityFailure();
}

/// A pinned asset's recomputed SHA-256 did not match the manifest.
final class ChecksumMismatch extends AssetIntegrityFailure {
  /// Creates a checksum-mismatch failure for [path].
  const ChecksumMismatch({
    required this.path,
    required this.expectedSha256,
    required this.actualSha256,
  });

  /// The asset whose hash did not match.
  final String path;

  /// The hash the manifest pinned.
  final String expectedSha256;

  /// The hash recomputed from the file on disk.
  final String actualSha256;
}

/// A pinned asset could not be read from disk.
final class ManifestUnreadable extends AssetIntegrityFailure {
  /// Creates an unreadable-asset failure for [path].
  const ManifestUnreadable({required this.path});

  /// The asset that could not be read.
  final String path;
}

/// Re-hashes every pinned asset against the binary-baked [pinnedManifest] with
/// SHA-256 (FIPS 180-4) and exits non-zero, fail-closed, on any mismatch or
/// unreadable file. Dormant on the empty E01 manifest (zero files → exits 0).
///
/// It only verifies — it never writes or blesses the manifest — and it is
/// byte-blind: it hashes bytes and never interprets them.
Future<void> main() async {
  final failures = <AssetIntegrityFailure>[];

  for (final entry in pinnedManifest.files) {
    final file = File(entry.path);
    final String actualSha256;
    try {
      // Stream the file through the digest rather than loading it whole — the
      // muṣḥaf assets E05 pins include large glyph fonts.
      final digest = await sha256.bind(file.openRead()).first;
      actualSha256 = digest.toString();
    } on FileSystemException {
      failures.add(ManifestUnreadable(path: entry.path));
      continue;
    }
    if (actualSha256 != entry.expectedSha256) {
      failures.add(
        ChecksumMismatch(
          path: entry.path,
          expectedSha256: entry.expectedSha256,
          actualSha256: actualSha256,
        ),
      );
    }
  }

  // The manifest-vs-Tanzil text-hash drift check activates once E05 supplies the
  // real authoritative hash; on the empty E01 manifest there is nothing to drift.

  for (final failure in failures) {
    switch (failure) {
      case ChecksumMismatch(
          :final path,
          :final expectedSha256,
          :final actualSha256,
        ):
        stderr.writeln(
          '::error::asset integrity: $path expected $expectedSha256 '
          'got $actualSha256',
        );
      case ManifestUnreadable(:final path):
        stderr.writeln('::error::asset integrity: $path is unreadable');
    }
  }

  if (failures.isNotEmpty) {
    exitCode = 1;
  }
}
