// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show ConfusionRepository;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'persistence_provider.dart';

/// The swap-logging write seam, derived from the persistence handle (04 §3).
///
/// The mutashābihāt drill (E14-T08) and the daily recite flow (E12) reach this
/// rather than the whole handle, so a test drives the swap command with a fake
/// [ConfusionRepository] without a real database. A thin wire.
final confusionRepositoryProvider = Provider<ConfusionRepository>(
  (ref) => ref.watch(persistenceProvider).confusion,
);
