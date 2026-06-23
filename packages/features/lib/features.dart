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
export 'src/l10n/term_set.dart';
export 'src/mushaf/mushaf_page_source.dart';
export 'src/mushaf/mushaf_providers.dart';
export 'src/mushaf/overlay_markers.dart';
export 'src/mushaf/overlay_providers.dart';
export 'src/mushaf/mushaf_reader_state.dart';
export 'src/mushaf/mushaf_route.dart';
export 'src/mushaf/mushaf_screen.dart';
export 'src/mushaf/mushaf_view_model.dart';
export 'src/mushaf/reader_color_filter.dart';
export 'src/mushaf/reader_theme.dart';
export 'src/mushaf/widgets/jump_picker.dart';
export 'src/mushaf/widgets/mushaf_pager.dart';
export 'src/mushaf/widgets/reader_theme_control.dart';
export 'src/mushaf/widgets/reader_zoom_control.dart';
export 'src/mushaf/widgets/reader_zoom_steps.dart';
export 'src/mutashabihat/mutashabihat_screen.dart';
export 'src/onboarding/cold_start_seeder.dart';
export 'src/onboarding/onboarding_providers.dart';
export 'src/onboarding/onboarding_screen.dart';
export 'src/onboarding/onboarding_view_model.dart';
export 'src/placeholder/placeholder_screen.dart';
export 'src/progress/progress_screen.dart';
export 'src/recite/reader_surface.dart';
export 'src/recite/recite_grade_screen.dart';
export 'src/recite/recite_providers.dart';
export 'src/recite/recite_route.dart';
export 'src/recite/recite_view_model.dart';
export 'src/recite/widgets/grade_band.dart';
export 'src/recite/widgets/recite_surface.dart';
export 'src/settings/settings_screen.dart';
export 'src/shell/section_placeholder.dart';
export 'src/today/review_recorder.dart';
export 'src/today/today_providers.dart';
export 'src/today/today_screen.dart';
export 'src/today/today_session.dart';
export 'src/today/today_view_model.dart';
export 'src/today/widgets/budget_feedback_line.dart';
export 'src/today/widgets/daily_session_list.dart';
export 'src/today/widgets/page_card.dart';
export 'src/today/widgets/session_section.dart';
export 'src/today/widgets/today_all_done.dart';
export 'src/today/widgets/today_catch_up_banner.dart';
export 'src/today/widgets/today_silent_resume.dart';
export 'src/today/widgets/teacher_sourced_marker.dart';
