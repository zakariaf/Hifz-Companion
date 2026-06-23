// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:assets/assets.dart' show LiveAssetDownloader;
import 'package:composition/composition.dart';
import 'package:data/data.dart'
    show openLivePersistence, registerBundledEdition;
import 'package:features/features.dart'
    show CoreSetupPhase, coreSetupActionProvider;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show kKfgqpcHafsMadaniV2Edition;

import 'app.dart';

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
        // The live bundled-core install (E05's CoreReferenceInstaller) is wired
        // here once the real KFGQPC asset pack lands; until then a RELEASE build
        // correctly fail-closes — the muṣḥaf cannot be verified, so onboarding's
        // core-setup refuses and no Quran text is shown (R1).
        //
        // For DEBUG/dev only, so the app is runnable on a simulator without the
        // ~40-55 MB assets: treat the (content-less, bundle-first) core as ready
        // — onboarding completes and the reader opens to its blank page. This is
        // safe by construction: with no bundled text/fonts there is no Quran to
        // render unverified. It never affects a release build.
        if (kDebugMode) ...[
          coreSetupActionProvider.overrideWith(
            (ref) => () async {
              // Register only the bundled edition's metadata row so onboarding's
              // placement commit (profile.mushaf_id FK) resolves; no Quran text
              // or glyph is written. Then report ready.
              await registerBundledEdition(
                ref.read(persistenceProvider),
                kKfgqpcHafsMadaniV2Edition,
              );
              return CoreSetupPhase.ready;
            },
          ),
          coreVerifiedProvider.overrideWith((ref) async => true),
        ],
      ],
      child: const HifzApp(),
    ),
  );
}
