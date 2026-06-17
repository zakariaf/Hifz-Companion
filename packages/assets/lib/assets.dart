// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The one network module for Hifz Companion: the offline asset-pack downloader
/// and the fail-closed SHA-256 verifier — the single network socket in the app.
///
/// It does one HTTPS GET to a pinned GitHub Release tag (no auth, no cookies, no
/// identifiers), verifies each file against the pinned manifest, and refuses any
/// mismatch. The downloader, verifier, and pinned manifest bodies are authored
/// in E05; this barrel exposes the boundary shape and the fail-closed error
/// type — it never re-exports the internal downloader.
library;

export 'src/asset_integrity_error.dart';
export 'src/asset_pack_service.dart';
