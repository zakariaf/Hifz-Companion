// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The one network module for Hifz Companion: the offline asset-pack downloader
/// and the fail-closed SHA-256 verifier — the single network socket in the app.
///
/// It does one HTTPS GET to a pinned GitHub Release tag (no auth, no cookies, no
/// identifiers) for **optional** packs, verifies each file against the pinned
/// manifest, and refuses any mismatch. (Bundle-first, amended 2026-06-18: the
/// core muṣḥaf is bundled in the binary, never fetched.) This barrel exposes the
/// download **boundary** (`AssetDownloader`, its typed exception, `CancelToken`)
/// and the live impl for composition-root wiring; the network *socket* itself
/// stays quarantined inside this package — the app constructs `LiveAssetDownloader`
/// but never imports a networking package. The deterministic fake lives in
/// `package:assets/testing.dart`.
library;

export 'src/asset_downloader.dart';
export 'src/asset_integrity_error.dart';
export 'src/asset_pack_service.dart';
export 'src/cancel_token.dart' show CancelToken;
export 'src/integrity/sha256_of_file.dart'
    show digestMatches, sha256OfBytes, sha256OfFile;
export 'src/integrity/verify_and_promote.dart'
    show Promoted, Refused, VerifyOutcome, verifyAndPromote;
export 'src/live_asset_downloader.dart' show LiveAssetDownloader;
export 'src/pack_coordinates.dart' show PackCoordinates;
export 'src/pinned_manifest.dart'
    show CorePackManifest, EmbeddedManifest, ManifestEntry, buildCoreManifest;
