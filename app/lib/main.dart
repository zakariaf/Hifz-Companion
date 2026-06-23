// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:assets/assets.dart' show LiveAssetDownloader;
import 'package:composition/composition.dart';
import 'package:data/data.dart' show openLivePersistence;
import 'package:features/features.dart'
    show CoreSetupPhase, coreSetupActionProvider;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        // The live bundled-core install (E05's CoreReferenceInstaller): verify
        // every bundled byte against the binary-baked SHA-256 manifest, build
        // E03's read-only reference tables, register the 604 per-page KFGQPC
        // glyph fonts, then stamp `text_checksum_verified_at` LAST. Fail-closed —
        // any mismatch maps to integrityFailure and no Quran text is shown (R1).
        // `coreVerifiedProvider` is driven by the real stamp this writes (no
        // override), so the reader route opens only once the muṣḥaf is whole.
        coreSetupActionProvider.overrideWith(
          (ref) => () async {
            final ready =
                await installAndPrepareCore(ref.read(persistenceProvider));
            return ready
                ? CoreSetupPhase.ready
                : CoreSetupPhase.integrityFailure;
          },
        ),
      ],
      child: const HifzApp(),
    ),
  );
}
