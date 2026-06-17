// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';

/// Applies the fixed crash-safe connection pragmas on the raw `sqlite3` handle,
/// in order, **before** drift touches the database (05 §1, §3).
///
/// Pragmas are per-connection and not persisted in the file, so this runs on
/// **every** open — first launch, relaunch, and each test. `synchronous=FULL`
/// (never `NORMAL`) is the floor, not a tunable: a teacher sign-off — a *sanad*
/// act — must survive power loss, so the WAL is fsync'd on every commit.
void applyConnectionSetup(CommonDatabase database) {
  // The opt-in encryption key (`PRAGMA key`) and its `PRAGMA cipher;` liveness
  // guard are inserted ABOVE these pragmas when the cipher build is active
  // (§5 / E03-T10) — do not restructure this callback when adding them.
  database.execute('PRAGMA journal_mode = WAL;'); // crash-safe journal (§3)
  database.execute('PRAGMA synchronous = FULL;'); // durable across power loss
  database.execute('PRAGMA foreign_keys = ON;'); // SQLite leaves FKs OFF
  database.execute('PRAGMA busy_timeout = 5000;'); // wait, don't throw, on lock
}

/// The single live-store open path: a lazily-opened, background-isolate
/// `NativeDatabase` over `hifz.sqlite` in the app documents directory (05 §1).
///
/// This is the only place that opens the on-device store; tests open an
/// in-memory `NativeDatabase.memory()` instead (E03-T05). `path_provider` is
/// local file IO — never a network socket (C1).
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'hifz.sqlite'));
    return NativeDatabase.createInBackground(file, setup: applyConnectionSetup);
  });
}
