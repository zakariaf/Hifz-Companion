// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show ProfileId;

import 'onboarding_view_model.dart';

/// The resume-safe onboarding capture controller, keyed by the active
/// [ProfileId] (`null` on a fresh device's first onboarding) and `autoDispose`d
/// so abandoning the flow discards the captured state (clean restart).
///
/// It is **not** an app-scope singleton: re-running placement for a second
/// profile (teacher mode, E16) is isolated under that profile's id.
final onboardingControllerProvider = NotifierProvider.autoDispose
    .family<OnboardingController, OnboardingState, ProfileId?>(
  OnboardingController.new,
);
