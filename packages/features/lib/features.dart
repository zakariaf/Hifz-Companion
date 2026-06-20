// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The Hifz Companion feature screens (one library per screen): Today, Muṣḥaf,
/// Mutashābihāt, Progress, Onboarding, Settings.
///
/// Each screen is a dumb View with a 1:1 ViewModel and feature-scoped Riverpod
/// providers (never global). The four non-Today tabs ship as inert calm
/// placeholders in the E07 walking skeleton; the real screens are authored in
/// the feature epics.
library;

export 'src/a11y/a11y.dart';
export 'src/design_system/design_system.dart';
export 'src/mushaf/mushaf_screen.dart';
export 'src/mutashabihat/mutashabihat_screen.dart';
export 'src/onboarding/cold_start_seeder.dart';
export 'src/onboarding/onboarding_providers.dart';
export 'src/onboarding/onboarding_screen.dart';
export 'src/onboarding/onboarding_view_model.dart';
export 'src/placeholder/placeholder_screen.dart';
export 'src/progress/progress_screen.dart';
export 'src/settings/settings_screen.dart';
export 'src/shell/section_placeholder.dart';
export 'src/today/review_recorder.dart';
export 'src/today/today_providers.dart';
export 'src/today/today_screen.dart';
export 'src/today/widgets/page_card.dart';
