// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show SourceLinkLauncher;
import 'package:url_launcher/url_launcher.dart';

/// The live [SourceLinkLauncher] (E19; Decision log #15) — opens a citation's
/// source URL in the system browser via `url_launcher`, leaving the app.
///
/// The full citation is on-device text, so this is an optional convenience: a
/// malformed URL or a failed launch (e.g. offline) is a calm `false`, never an
/// in-app fetch and never an error the ḥāfiẓ sees. `url_launcher` hands the URL
/// to the OS over a platform channel — it opens no Dart socket.
class UrlLauncherSourceLink implements SourceLinkLauncher {
  /// Creates the live launcher.
  const UrlLauncherSourceLink();

  @override
  Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      return false; // offline / no handler — degrade harmlessly
    }
  }
}
