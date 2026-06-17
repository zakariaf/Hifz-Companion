// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// Triggers the one-time core-pack download, verifies each file's SHA-256,
/// builds the local database, then routes to onboarding.
///
/// Stub: not yet implemented and not yet invoked. It exists so E05/E07 have a
/// named home for the first-run bootstrap; it imports nothing from `assets` or
/// `data` it cannot resolve.
Future<void> runFirstRunBootstrap() async {
  // Intentionally empty until E05/E07 wire the asset download, SHA-256
  // verification, and database build behind it.
}
