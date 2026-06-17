// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// Test-facing doubles for the persistence boundary, kept out of the production
/// `data.dart` barrel so a release binary never pulls `NativeDatabase.memory()`.
///
/// A test or preview imports this explicitly:
/// `import 'package:data/testing.dart';`. The deterministic "today" double is
/// E02's `todayProvider` (a `Provider<CalendarDate>` overridden with a literal
/// day) — the persistence layer reads no clock, so there is no separate clock
/// double here.
library;

export 'src/testing/in_memory_persistence_handle.dart'
    show inMemoryPersistenceHandle;
export 'src/testing/in_memory_secret_key_store.dart'
    show InMemorySecretKeyStore;
