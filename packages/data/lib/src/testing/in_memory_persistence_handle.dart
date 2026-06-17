// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/native.dart';

import '../db/connection.dart';
import '../db/database.dart';
import '../live_persistence_handle.dart';
import '../persistence_handle.dart';

/// A deterministic in-memory [PersistenceHandle] for tests and previews — a
/// real Drift store on `NativeDatabase.memory()` with the v1 schema, no file,
/// no migration of an on-disk DB, and **no socket** (05 §1; eng-define-service-
/// boundary).
///
/// It applies the same crash-safe `applyConnectionSetup` as the live store
/// (foreign keys ON, so it behaves identically for SQL semantics), and is
/// installed in tests with
/// `persistenceProvider.overrideWithValue(inMemoryPersistenceHandle())`. No mock
/// framework — this is the genuine SQLite stack.
PersistenceHandle inMemoryPersistenceHandle() => LivePersistenceHandle(
      HifzDatabase(NativeDatabase.memory(setup: applyConnectionSetup)),
    );
