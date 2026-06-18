// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:assets/assets.dart' show AssetDownloader;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single injectable seam to the optional-pack downloader — the one network
/// socket in the app (engineering 09 §2; Decision log #8).
///
/// Its default body **throws** so a forgotten wiring is a loud startup failure,
/// never a silent socket. The live `LiveAssetDownloader` is bound exactly once
/// in `main`'s `ProviderScope(overrides:)`; tests override it with the offline
/// `FakeAssetDownloader` (`package:assets/testing.dart`). A thin DI `Provider` —
/// no business logic, no retry policy, no live IO in the body.
///
/// Bundle-first (amended 2026-06-18): the core muṣḥaf is bundled, so this is
/// never on the critical path — it serves optional packs (reciter audio,
/// future alt-muṣḥaf) only.
final assetDownloaderProvider = Provider<AssetDownloader>(
  (ref) => throw StateError(
    'assetDownloaderProvider was read without an override. Wire '
    "LiveAssetDownloader in main()'s ProviderScope, or override it with "
    'FakeAssetDownloader in tests.',
  ),
);
