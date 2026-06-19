// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:assets/assets.dart' show LiveAssetDownloader;
import 'package:data/data.dart' show openLivePersistence;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'composition/active_profile_provider.dart';
import 'composition/asset_downloader_provider.dart';
import 'composition/persistence_provider.dart';

/// The composition root — the one place live services are constructed and bound
/// into the `ProviderScope` (04 §1.2). It opens the crash-safe Drift store once,
/// reads the device's existing profile (so a returning ḥāfiẓ lands on the shell
/// rather than onboarding), and wires the live downloader; the rest of the app
/// reaches each service only through its provider. Nothing here computes a
/// schedule or renders Quran text.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handle = await openLivePersistence();
  // Read once at the edge: the first existing profile becomes the active one;
  // a fresh install (no profile) resolves to null → the redirect guard routes
  // to onboarding before any Quran screen (PRD R1).
  final profiles = await handle.profiles.all();
  final initialProfileId = profiles.isEmpty ? null : profiles.first.profileId;
  runApp(
    ProviderScope(
      overrides: [
        persistenceProvider.overrideWithValue(handle),
        assetDownloaderProvider.overrideWithValue(const LiveAssetDownloader()),
        initialActiveProfileProvider.overrideWithValue(initialProfileId),
      ],
      child: const HifzApp(),
    ),
  );
}
