// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'progress_overview.dart';
import 'progress_providers.dart' show progressHeatmapProvider;

/// The 1:1 Progress view-model (04 §1.3): a dumb `AsyncNotifier` that publishes
/// one immutable [ProgressOverview] the View renders. It holds no per-screen
/// state, owns no mutation, never navigates, and never reads `DateTime.now()` —
/// "today" enters only through the injected clock inside the read model it
/// watches. `build()` gates on the active profile and delegates to the pre-built
/// [progressHeatmapProvider]; the committed-write re-emit is the only refresh.
class ProgressController extends AsyncNotifier<ProgressOverview> {
  @override
  Future<ProgressOverview> build() async {
    ref.watch(activeProfileProvider);
    return ref.watch(progressHeatmapProvider.future);
  }
}

/// The app-scope Progress controller the [ProgressScreen] watches.
final progressControllerProvider =
    AsyncNotifierProvider<ProgressController, ProgressOverview>(
  ProgressController.new,
);
