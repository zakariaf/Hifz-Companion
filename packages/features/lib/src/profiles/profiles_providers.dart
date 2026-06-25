// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart'
    show persistenceProvider, profileRepositoryProvider, todayProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show Profile;

import 'profiles_controller.dart';

/// The device's profile set, streamed reactively — re-emits after every
/// committed create / rename / delete, so the switcher and manage list rebuild
/// without a second cache.
final profilesListProvider = StreamProvider<List<Profile>>(
  (ref) => ref.watch(profileRepositoryProvider).watchAll(),
);

/// The single write path for profile create / rename / delete (no PII beyond the
/// typed display name).
final profilesControllerProvider = Provider<ProfilesController>((ref) {
  return ProfilesController(
    profiles: ref.watch(profileRepositoryProvider),
    coldStart: ref.watch(persistenceProvider).coldStart,
    today: () => ref.read(todayProvider),
  );
});
