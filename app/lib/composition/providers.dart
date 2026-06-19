// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The composition-root DI provider set — one import point for the live service
/// bindings wired in `main`'s `ProviderScope` (04 §1.2).
///
/// Each provider is a thin wire holding no business logic: the injected "today"
/// clock, the Drift persistence handle (throwing placeholder until overridden),
/// the optional-pack downloader (throwing placeholder), the pure engine, the
/// active-profile gate, and the app-ready gate. The IO-opening placeholders are
/// satisfied only by `main`'s overrides; the rest resolve live.
library;

export 'active_profile_provider.dart';
export 'app_ready_provider.dart';
export 'asset_downloader_provider.dart';
export 'engine_provider.dart';
export 'persistence_provider.dart';
export 'today_provider.dart';
