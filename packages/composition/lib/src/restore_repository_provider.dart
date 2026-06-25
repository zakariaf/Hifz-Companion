// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show RestoreRepository;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'persistence_provider.dart';

/// The backup-restore write path (E17-T06), read off the active
/// [PersistenceHandle] — the data-internal transactional replace/merge the
/// restore controller drives. A thin seam, like the other repository providers.
final restoreRepositoryProvider = Provider<RestoreRepository>(
  (ref) => ref.watch(persistenceProvider).restore,
);
