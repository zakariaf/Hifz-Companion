// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show CycleConfig;

import 'active_profile_provider.dart';
import 'cycle_config_repository_provider.dart';

/// The active profile's cycle configuration, streamed reactively (null until a
/// profile exists and its config is seeded). It re-emits after every committed
/// cycle/term-set write. Keyed implicitly by [activeProfileProvider]: a halaqa
/// switch re-subscribes it to the new student's config.
final activeCycleConfigProvider = StreamProvider<CycleConfig?>((ref) {
  final id = ref.watch(activeProfileProvider);
  if (id == null) return Stream<CycleConfig?>.value(null);
  return ref.watch(cycleConfigRepositoryProvider).watchByProfile(id);
});

/// The active profile's term-set region key — the ICU `select` branch the
/// sabaq/sabqi/manzil labels resolve under — falling back to the general
/// `'other'` set until a region is chosen.
///
/// A pure display selector: it swaps only the surface vocabulary, never the
/// engine's grade/track signal. Read cross-feature (Today, the recite flow) so
/// it lives in the composition layer.
final termSetRegionProvider = Provider<String>((ref) {
  final config = ref.watch(activeCycleConfigProvider).asData?.value;
  // Mirrors features/l10n/term_set.dart's kDefaultTermSetRegion (a leaf the
  // composition layer cannot import).
  return config?.regionPreset ?? 'other';
});
