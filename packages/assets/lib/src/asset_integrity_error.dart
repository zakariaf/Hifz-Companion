// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// The fail-closed error type for the asset-integrity boundary: an unverified or
/// unavailable pack is refused, never silently accepted (PRD §19.3).
///
/// It is `sealed`, so every consumer's `switch` over it is exhaustive — a new
/// failure mode cannot be added without every handler being updated.
@immutable
sealed class AssetIntegrityError {
  /// Const base constructor for the sealed hierarchy.
  const AssetIntegrityError();
}

/// A downloaded file's SHA-256 did not match the pinned manifest; the pack is
/// rejected (re-fetched once, then refused).
final class ChecksumMismatch extends AssetIntegrityError {
  /// Creates a checksum-mismatch error.
  const ChecksumMismatch();
}

/// A pinned pack could not be retrieved from the public release.
final class PackUnavailable extends AssetIntegrityError {
  /// Creates a pack-unavailable error.
  const PackUnavailable();
}
