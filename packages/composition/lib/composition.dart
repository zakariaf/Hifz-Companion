// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The composition-root DI provider seams — one import point for both the app
/// shell (which overrides the live implementations in `main`) and the feature
/// ViewModels (which read them) (04 §1.2).
///
/// Each provider is a thin wire holding no business logic: the injected "today"
/// clock, the Drift persistence handle (throwing placeholder until overridden),
/// the optional-pack downloader (throwing placeholder), the encryption key store
/// (throwing placeholder), the pure engine, the active-profile gate, and the
/// app-ready gate. The IO-opening placeholders are satisfied only by `main`'s
/// overrides; the rest resolve live.
library;

export 'src/active_profile_provider.dart';
export 'src/app_ready_provider.dart';
export 'src/asset_downloader_provider.dart';
export 'src/engine_provider.dart';
export 'src/persistence_provider.dart';
export 'src/secret_key_store_provider.dart';
export 'src/today_provider.dart';
