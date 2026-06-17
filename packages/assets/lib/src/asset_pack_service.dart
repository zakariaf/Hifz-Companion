// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The asset-pack boundary: verify-then-expose. Download the pinned core pack,
/// verify each file's SHA-256 fail-closed, then expose only the verified bytes.
/// The implementation is authored in E05; this is the shape only.
abstract interface class AssetPackService {
  /// Verifies and installs the pinned core asset pack (E05).
  Future<void> installCorePack();
}

/// The repository over [AssetPackService] that exposes only verified assets to
/// the rest of the app. Implemented in E05.
abstract interface class AssetRepository {
  /// Whether the verified core pack is present on this device.
  bool get isCorePackInstalled;
}
