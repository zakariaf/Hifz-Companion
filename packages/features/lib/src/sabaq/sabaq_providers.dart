// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sabaq_intake_controller.dart';

/// The single "start memorizing this page" command, wired from the composition
/// seams (the persistence handle's sabaq-intake write path + the pure engine).
/// App-scope (no `autoDispose`): it holds no per-screen state — it is a thin
/// orchestrator the reader/Today intake surfaces call (E21-T06/T07). It opens no
/// IO itself; the live handle/engine arrive through the overridden seams.
final sabaqIntakeControllerProvider = Provider<SabaqIntakeController>((ref) {
  final persistence = ref.watch(persistenceProvider);
  return SabaqIntakeController(
    intake: persistence.sabaqIntake,
    engine: ref.watch(engineProvider),
    readActiveProfileId: () => ref.read(activeProfileProvider),
    readToday: () => ref.read(todayProvider),
  );
});
