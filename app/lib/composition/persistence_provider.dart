// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show PersistenceHandle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single injectable seam to the local store (04 §1.2; 05 §1).
///
/// Its default body **throws** so a forgotten wiring is a loud startup failure,
/// not silent null data. The live handle is bound exactly once in `main`'s
/// `ProviderScope(overrides:)` via `openLivePersistence()`; tests override it
/// with the in-memory double (`package:data/testing.dart`). A thin DI
/// `Provider` — no business logic, no live IO in the body.
final persistenceProvider = Provider<PersistenceHandle>(
  (ref) => throw StateError(
    'persistenceProvider was read without an override. Wire the live handle in '
    "main()'s ProviderScope, or override it with inMemoryPersistenceHandle() in "
    'tests.',
  ),
);
