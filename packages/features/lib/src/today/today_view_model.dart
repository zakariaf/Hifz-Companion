// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'today_providers.dart' show todaySessionProvider;
import 'today_session.dart';

/// The 1:1 Today view-model (04 §1.3). A dumb `AsyncNotifier` that publishes one
/// immutable [TodaySession] the View renders; it holds no per-screen state, owns
/// no grade/mutation command (the single write path is E12-T06/T07), never
/// navigates, and never reads `DateTime.now()` — "today" enters only through the
/// injected `todayProvider` inside the read model it watches.
///
/// `build()` gates on the active profile and delegates to the pre-built
/// [todaySessionProvider] read model; it never calls an engine schedule method,
/// never sorts/caps/load-balances, and exposes no mutation command. `loading`
/// and `error` ride this notifier's `AsyncValue`; the committed-write re-emit is
/// the only refresh mechanism (no manual republish).
class TodayController extends AsyncNotifier<TodaySession> {
  @override
  Future<TodaySession> build() async {
    // Watch the active profile so the controller re-runs when it changes; the
    // profile gate and the engine's pre-built day live in the read model.
    ref.watch(activeProfileProvider);
    return ref.watch(todaySessionProvider.future);
  }
}
