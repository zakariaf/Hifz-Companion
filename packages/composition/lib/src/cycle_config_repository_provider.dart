// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show CycleConfigRepository;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'persistence_provider.dart';

/// The cycle-config read + write seam, derived from the persistence handle
/// (04 §3). The Settings term-set and cycle surfaces watch this rather than the
/// whole handle, so a test drives them with a fake [CycleConfigRepository]
/// (a controllable `watchByProfile` stream) without a real database.
final cycleConfigRepositoryProvider = Provider<CycleConfigRepository>(
  (ref) => ref.watch(persistenceProvider).cycleConfig,
);
