// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'integrity/sha256_of_file.dart';
import 'pinned_manifest.dart';

/// Reads a **bundled** core asset by file name (e.g. via `rootBundle`). Injected
/// so the install sequence is testable offline with no asset bundle.
abstract interface class BundledAssetSource {
  /// Loads the bytes of the bundled asset [assetName], or throws if absent.
  Future<Uint8List> load(String assetName);
}

/// Builds E03's read-only reference tables from the verified bundled bytes — the
/// E05-T05 / single-write-path seam, injected so this sequence owns only the
/// ordering, not the DDL.
abstract interface class ReferenceDbBuilder {
  /// Builds the reference DB from `fileName → verified bytes`.
  Future<void> build(Map<String, Uint8List> verifiedBundledBytes);
}

/// Stamps `text_checksum_verified_at` through E03's `app_meta` write path — the
/// final durable signal that the muṣḥaf is whole and ready. Injected (the
/// instant/clock is E03's, never `DateTime.now()` here).
abstract interface class CoreVerifiedStamp {
  /// Records that the core pack verified and built successfully.
  Future<void> markVerified();
}

/// The result of the first-launch core setup — a **sealed** type so no
/// partially-trusted state is observable.
sealed class CoreSetupResult {
  /// Const base constructor for the sealed hierarchy.
  const CoreSetupResult();

  /// The whole core verified, built, and stamped.
  const factory CoreSetupResult.ready() = CoreReady;

  /// A bundled file failed (mismatch/missing) — refuse to render; nothing built
  /// or stamped.
  const factory CoreSetupResult.integrityFailure(String fileName) =
      CoreIntegrityFailure;
}

/// The core verified, built, and stamped — the muṣḥaf is ready.
final class CoreReady extends CoreSetupResult {
  /// Creates a ready result.
  const CoreReady();
}

/// A bundled file failed verification — the app refuses to render Quran text.
final class CoreIntegrityFailure extends CoreSetupResult {
  /// Creates an integrity-failure result for [fileName].
  const CoreIntegrityFailure(this.fileName);

  /// The bundled file that failed (mismatch or missing).
  final String fileName;
}

/// Sequences the first-launch **bundled-core** setup (engineering 09 §2,
/// amended 2026-06-18 — the core is bundled, so there is **no download/promote**):
/// load each bundled file → verify its SHA-256 against the binary-baked manifest
/// → build the reference DB → **stamp last**.
///
/// The ordering is the invariant: no partially-trusted state is ever observable.
/// A mismatch (or missing file) **short-circuits** immediately — nothing is
/// built, nothing is stamped — so the next launch sees an un-stamped (un-ready)
/// install and re-runs. The stamp is the final durable "ready" signal. All
/// collaborators are injected; this sequence opens no socket and reads no clock.
class CoreReferenceInstaller {
  /// Creates the installer over its injected collaborators.
  const CoreReferenceInstaller({
    required this.source,
    required this.manifest,
    required this.referenceDbBuilder,
    required this.stamp,
  });

  /// The bundled-asset byte source.
  final BundledAssetSource source;

  /// The binary-baked pinned manifest (the expected digests).
  final CorePackManifest manifest;

  /// The reference-DB build seam (E05-T05).
  final ReferenceDbBuilder referenceDbBuilder;

  /// The `text_checksum_verified_at` stamp seam (E03).
  final CoreVerifiedStamp stamp;

  /// Runs the sequence and returns its total result.
  Future<CoreSetupResult> installCorePack() async {
    final verified = <String, Uint8List>{};
    for (final entry in manifest.files) {
      final Uint8List bytes;
      try {
        bytes = await source.load(entry.name);
      } on Object {
        // A missing/unreadable bundled file is an integrity failure
        // (fail-closed), not an uncaught throw.
        return CoreSetupResult.integrityFailure(entry.name);
      }
      if (!digestMatches(sha256OfBytes(bytes), entry.sha256)) {
        // Short-circuit: build nothing, stamp nothing.
        return CoreSetupResult.integrityFailure(entry.name);
      }
      verified[entry.name] = bytes;
    }
    // Only now, with EVERY file verified, build the DB — then stamp LAST.
    await referenceDbBuilder.build(verified);
    await stamp.markVerified();
    return const CoreSetupResult.ready();
  }
}
