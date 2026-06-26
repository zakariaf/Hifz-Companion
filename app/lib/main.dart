// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:assets/assets.dart' show LiveAssetDownloader;
import 'package:composition/composition.dart';
import 'package:data/data.dart'
    show kAppMetaKeyTextChecksumVerifiedAt, openLivePersistence;
import 'package:features/features.dart'
    show
        CoreSetupPhase,
        RealReciteReaderSurface,
        coreSetupActionProvider,
        reciteReaderSurfaceProvider;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'backup/backup_io_impls.dart';
import 'reminders/notification_scheduler_impl.dart';
import 'science/url_launcher_source_link.dart';

/// The composition root — the one place live services are constructed and bound
/// into the `ProviderScope` (04 §1.2). It opens the crash-safe Drift store once,
/// reads the device's existing profile (so a returning ḥāfiẓ lands on the shell
/// rather than onboarding), and wires the live downloader; the rest of the app
/// reaches each service only through its provider. Nothing here computes a
/// schedule or renders Quran text.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handle = await openLivePersistence();
  // Font registration is in-memory (per process). A returning ḥāfiẓ whose core
  // was verified on a prior launch skips onboarding, so the 604 per-page KFGQPC
  // fonts must be re-registered here at startup — otherwise the reader falls back
  // to the UI font and draws the raw glyph codepoints. The reference data and the
  // verified stamp persist; only the font registration is volatile. First-run
  // users register during onboarding's install (CoreReferenceInstaller).
  final coreVerified =
      await handle.meta.read(kAppMetaKeyTextChecksumVerifiedAt) != null;
  if (coreVerified) {
    await registerBundledCoreFonts();
  }
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
        // The recite flow's reveal-on-tap surface now renders the real KFGQPC
        // glyphs (the verified bundled core), not the pre-asset placeholder.
        reciteReaderSurfaceProvider
            .overrideWithValue(const RealReciteReaderSurface()),
        // Backup file-move (E17 §9) — the OS share sheet, file picker, and the
        // local-store erase, the shell's only plugins, behind composition
        // service boundaries (the pure layers + CI stay plugin-free).
        backupShareServiceProvider.overrideWithValue(const ShareBackupService()),
        backupFilePickerProvider.overrideWithValue(const FilePickerBackup()),
        localStoreEraserProvider.overrideWithValue(LocalStoreEraserImpl(handle)),
        // Local daily reminder (E18 §14) — the one calm notification, app-edge
        // only behind the composition NotificationScheduler boundary. No push,
        // no server, no network; the OS fires it. `timezone` + `flutter_timezone`
        // feed `zonedSchedule` a DST-correct local fire time (Decision log #14).
        notificationSchedulerProvider
            .overrideWithValue(LiveNotificationScheduler()),
        // Science-screen external source link (E19 §2/§4; Decision log #15) —
        // opens a citation URL in the system browser, app-edge only behind the
        // composition SourceLinkLauncher boundary. The citation is full on-device
        // text; the URL is an optional convenience that leaves the app. No in-app
        // fetch, no network.
        sourceLinkLauncherProvider
            .overrideWithValue(const UrlLauncherSourceLink()),
      ],
      child: const HifzApp(),
    ),
  );
}
