// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens a citation's external source URL in the **system browser**, leaving the
/// app (E19; science doc §2, §4; `ui-science-source-row`).
///
/// A side-effect boundary (`eng-define-service-boundary`): the live impl
/// (`url_launcher`, in `app`) is wired in `main`; tests inject a recording fake.
/// The URL is an **optional convenience** — the full citation is on-device text,
/// so the app makes **no in-app fetch** and the link simply does nothing when it
/// cannot be opened (e.g. offline). This boundary never opens a socket itself.
abstract interface class SourceLinkLauncher {
  /// Opens [url] in the system browser, leaving the app. Returns whether a
  /// browser was launched; a malformed or unopenable URL (offline) is a calm
  /// no-op that returns `false` — never an in-app fetch, never a thrown error
  /// the user sees.
  Future<bool> open(String url);
}

/// The external-source-link seam — wired in `main` (`url_launcher`), faked in
/// tests; throws until overridden so a stray read never silently no-ops.
final sourceLinkLauncherProvider = Provider<SourceLinkLauncher>(
  (ref) => throw UnimplementedError(
    'sourceLinkLauncherProvider is wired only in main (url_launcher).',
  ),
);
