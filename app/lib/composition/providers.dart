// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The single composition root: the one place where real implementations are
/// bound into the app's `ProviderScope`.
///
/// Empty until E07. At that point this file declares the `List<Override>` that
/// `main`'s `ProviderScope(overrides: ...)` receives, binding the Drift database
/// handle, the asset loader, and the injected "today" clock. Nothing is wired
/// yet — and no implementation is computed anywhere in `app/lib/`.
library;

// E07 binds the real implementations here, for example:
//   final compositionOverrides = <Override>[
//     databaseProvider.overrideWithValue(database),
//     clockProvider.overrideWithValue(systemClock),
//   ];
