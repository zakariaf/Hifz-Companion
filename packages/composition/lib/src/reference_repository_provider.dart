// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show ReferenceRepository;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'persistence_provider.dart';

/// The read-only Quran-reference read seam, derived from the persistence handle
/// (04 §3).
///
/// The muṣḥaf reader and the mutashābihāt trainer watch this rather than the
/// whole handle, so a test drives a screen with a fake [ReferenceRepository]
/// (controllable group/page data) without a real database. A thin wire.
final referenceRepositoryProvider = Provider<ReferenceRepository>(
  (ref) => ref.watch(persistenceProvider).reference,
);
