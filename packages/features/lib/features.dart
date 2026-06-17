// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The Hifz Companion feature screens (one library per screen): Today, Muṣḥaf,
/// Mutashābihāt, Progress, Onboarding, Settings.
///
/// Each screen is a dumb View with a 1:1 ViewModel and feature-scoped Riverpod
/// providers (never global). The real screens are authored in the feature
/// epics; this barrel currently exports one compile-proving placeholder feature.
library;

export 'src/design_system/design_system.dart';
export 'src/placeholder/placeholder_screen.dart';
