// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data' show Uint8List;

import 'package:assets/assets.dart'
    show
        BundledAssetSource,
        CoreReady,
        CoreReferenceInstaller,
        CoreVerifiedStamp,
        EmbeddedManifest,
        ReferenceDbBuilder,
        digestMatches,
        sha256OfBytes;
import 'package:data/data.dart'
    show PersistenceHandle, installVerifiedCoreReference, stampCoreVerified;
import 'package:flutter/services.dart' show rootBundle;
import 'package:models/models.dart' show kKfgqpcHafsMadaniV2Edition;
import 'package:quran/quran.dart' show AssetVault, registerVerifiedPageFonts;

/// The bundled-core asset directory (declared in `app/pubspec.yaml`). The
/// installer reads each file through `rootBundle`; the app opens no socket.
const String _coreAssetDir = 'assets/quran';

/// Reads a bundled data file by its manifest name (Tanzil XML / QUL DBs).
class _RootBundleAssetSource implements BundledAssetSource {
  const _RootBundleAssetSource();

  @override
  Future<Uint8List> load(String assetName) async {
    final data = await rootBundle.load('$_coreAssetDir/$assetName');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}

/// Reads a bundled per-page glyph font and re-checks its SHA-256 against the
/// pinned digest before returning — throws (fail-closed) on any mismatch, so an
/// unverified font is never registered. The font FILE name comes from the
/// integrity manifest (the sanctioned place to spell it); this layer never
/// names the glyph/font tokens itself.
class _RootBundleFontVault implements AssetVault {
  const _RootBundleFontVault();

  @override
  Future<Uint8List> readVerified({
    required int page,
    required String expectedSha256,
  }) async {
    final fileName = EmbeddedManifest.fontFileName(page);
    final data = await rootBundle.load('$_coreAssetDir/fonts/$fileName');
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    if (!digestMatches(sha256OfBytes(bytes), expectedSha256)) {
      throw StateError('Bundled glyph font for page $page failed verification.');
    }
    return bytes;
  }
}

/// Builds E03's read-only reference tables from the verified bundled bytes,
/// through the single sanctioned data write path.
class _LiveReferenceDbBuilder implements ReferenceDbBuilder {
  const _LiveReferenceDbBuilder(this._handle, this._checksumSha256);

  final PersistenceHandle _handle;
  final String _checksumSha256;

  @override
  Future<void> build(Map<String, Uint8List> verifiedBundledBytes) =>
      installVerifiedCoreReference(
        _handle,
        edition: kKfgqpcHafsMadaniV2Edition,
        textXml: verifiedBundledBytes[EmbeddedManifest.textFileName]!,
        layoutDb: verifiedBundledBytes[EmbeddedManifest.layoutFileName]!,
        wordsDb: verifiedBundledBytes[EmbeddedManifest.wordsFileName]!,
        checksumSha256: _checksumSha256,
      );
}

/// Stamps `text_checksum_verified_at` through E03's app_meta write path.
class _LiveCoreVerifiedStamp implements CoreVerifiedStamp {
  const _LiveCoreVerifiedStamp(this._handle, this._value);

  final PersistenceHandle _handle;
  final String _value;

  @override
  Future<void> markVerified() => stampCoreVerified(_handle, _value);
}

/// Runs the first-launch bundled-core preparation and returns whether the muṣḥaf
/// is ready to render — the live adapter the composition root binds into
/// `coreSetupActionProvider` (E05/E11).
///
/// Order is the invariant (no partially-trusted state observable):
/// 1. verify + register every per-page glyph font (each checked against its pin
///    BEFORE registration); a failure refuses to render — return `false`;
/// 2. verify the three data files, build the reference DB, then **stamp last**.
///
/// All bytes are read from the bundle (`rootBundle`) and verified against the
/// binary-baked manifest; nothing is fetched. Idempotent — a re-run after a
/// successful install is a no-op (the reference load and stamp both short-circuit
/// when already present). `false` ⇒ the caller maps to an integrity failure.
Future<bool> installAndPrepareCore(PersistenceHandle handle) async {
  try {
    await registerVerifiedPageFonts(
      pageCount: kKfgqpcHafsMadaniV2Edition.pageCount,
      fontSha256: EmbeddedManifest.pageFontSha256,
      vault: const _RootBundleFontVault(),
    );
  } on Object {
    // A missing/mismatched/unloadable font is an integrity failure, not a throw.
    return false;
  }

  final textChecksum = EmbeddedManifest.core.files
      .firstWhere((e) => e.name == EmbeddedManifest.textFileName)
      .sha256;
  final installer = CoreReferenceInstaller(
    source: const _RootBundleAssetSource(),
    manifest: EmbeddedManifest.core,
    referenceDbBuilder: _LiveReferenceDbBuilder(handle, textChecksum),
    stamp: _LiveCoreVerifiedStamp(handle, textChecksum),
  );
  final result = await installer.installCorePack();
  return result is CoreReady;
}
