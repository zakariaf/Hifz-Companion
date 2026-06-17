// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

/// Installs a throwing [HttpOverrides] so any network access inside a test is a
/// loud, named failure — Hifz is offline-only. This is layer (a) of the
/// three-layer no-network gate (the static dep allow-list and banned-import
/// scope are the `tool/` gates). Call it from the first line of a test `main`
/// or a top-level `setUpAll`.
///
/// The single sanctioned opt-out is the future `assets` downloader test (E05),
/// which resets [HttpOverrides.global] to a mock client in its own `setUp`. No
/// other test resets the override.
///
/// This is the canonical copy at the workspace root; each Flutter package keeps
/// a byte-identical `test/test_setup.dart` so it can install the guard without a
/// cross-package import (no shared test package, no production dependency).
void useOfflineTestPolicy() => HttpOverrides.global = _ThrowingHttpOverrides();

class _ThrowingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => throw StateError(
        'Network access attempted in a test. Hifz is offline-only.',
      );
}
