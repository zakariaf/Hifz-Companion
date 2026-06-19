// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show CardRepository;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'persistence_provider.dart';

/// The card read seam, derived from the persistence handle (04 §3).
///
/// The Today queue `StreamProvider` watches this rather than the whole handle,
/// so a test drives the queue with a fake [CardRepository] (a controllable
/// `watchForProfile` stream) without a real database. A thin wire.
final cardRepositoryProvider = Provider<CardRepository>(
  (ref) => ref.watch(persistenceProvider).cards,
);
