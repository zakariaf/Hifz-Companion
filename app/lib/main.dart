// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:assets/assets.dart' show LiveAssetDownloader;
import 'package:data/data.dart' show openLivePersistence;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'composition/asset_downloader_provider.dart';
import 'composition/persistence_provider.dart';

/// The composition root — the one place a live persistence handle is
/// constructed. It opens the crash-safe Drift store once and binds it into the
/// `ProviderScope`; the rest of the app reaches it only through
/// `persistenceProvider`. E07 adds the remaining bindings (the injected clock,
/// the asset loader, the controllers that drive the single write path).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handle = await openLivePersistence();
  runApp(
    ProviderScope(
      overrides: [
        persistenceProvider.overrideWithValue(handle),
        assetDownloaderProvider.overrideWithValue(const LiveAssetDownloader()),
      ],
      child: const HifzApp(),
    ),
  );
}
