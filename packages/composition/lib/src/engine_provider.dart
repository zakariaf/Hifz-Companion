// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show EngineConfig, SchedulingEngine;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The pure scheduling engine as an injected DI dependency (04 §1.1; decision
/// log #4).
///
/// The engine imports no Riverpod and no Flutter — it is reached only as a
/// `Provider<SchedulingEngine>` the repository and the Today queue read. The
/// spine constructs it with the default config; the per-profile cycle ceiling
/// (`cycle_config`) refines it in E12. A thin wire — it opens no IO, holds no
/// state, and needs no override (no `DateTime.now()`, no randomness inside).
final engineProvider = Provider<SchedulingEngine>(
  (ref) => SchedulingEngine(EngineConfig.defaults()),
);
