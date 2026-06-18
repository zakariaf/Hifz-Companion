// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// Deterministic, offline test doubles for the `assets` boundary.
///
/// A non-`dev` library so widget/integration tests in other packages can
/// install [FakeAssetDownloader] via `overrideWith` and stay offline by
/// construction — it serves bytes from an in-memory map and imports no
/// networking package.
library;

export 'src/testing/fake_asset_downloader.dart' show FakeAssetDownloader;
