// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cold_start_seeder.dart';
import 'onboarding_view_model.dart';

/// The cold-start seed orchestration, wired from the composition seams (the
/// reference read + the cold-start write path + the pure engine).
final coldStartSeederProvider = Provider<ColdStartSeeder>((ref) {
  final persistence = ref.watch(persistenceProvider);
  return ColdStartSeeder(
    reference: persistence.reference,
    coldStart: persistence.coldStart,
    engine: ref.watch(engineProvider),
  );
});

/// The cold-start sub-step controller (1:1 with the onboarding View).
final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);
