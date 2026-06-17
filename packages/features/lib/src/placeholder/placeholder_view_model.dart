// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The immutable read-model for the placeholder feature.
@immutable
class PlaceholderState {
  /// Creates the placeholder state.
  const PlaceholderState({this.ready = false});

  /// Whether the placeholder feature has been marked ready.
  final bool ready;
}

/// The 1:1 ViewModel for the placeholder feature: a Riverpod [Notifier] that
/// exposes immutable read-only state and one no-op command. The real feature
/// ViewModels are authored in the feature epics.
class PlaceholderViewModel extends Notifier<PlaceholderState> {
  @override
  PlaceholderState build() => const PlaceholderState();

  /// Marks the placeholder feature ready — a no-op command demonstrating the
  /// View→ViewModel wiring.
  void markReady() => state = const PlaceholderState(ready: true);
}
