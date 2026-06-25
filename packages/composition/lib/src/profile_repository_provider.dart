// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show ProfileRepository;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'persistence_provider.dart';

/// The profile read + write seam, derived from the persistence handle (04 §3).
///
/// The Settings preference surface and the active-profile switcher watch this
/// rather than the whole handle, so a test drives them with a fake
/// [ProfileRepository] (a controllable `watchById` stream) without a real
/// database. A thin wire.
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ref.watch(persistenceProvider).profiles,
);
