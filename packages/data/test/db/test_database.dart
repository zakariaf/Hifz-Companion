// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ffi';
import 'dart:io';

import 'package:data/src/db/database.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart';

bool _sqlite3Configured = false;

/// On Linux CI runners only the versioned `libsqlite3.so.0` may be present
/// (the unversioned `.so` ships with `-dev`). Try the unversioned name first
/// (matching `package:sqlite3`'s default), then fall back to the versioned one,
/// so the `data` suite runs without `sqlite3_flutter_libs` (off the allow-list)
/// and without a CI apt step. macOS/Windows use the package default. Test-only.
void _configureSqlite3() {
  if (_sqlite3Configured) return;
  _sqlite3Configured = true;
  if (!Platform.isLinux) return;
  open.overrideFor(OperatingSystem.linux, () {
    try {
      return DynamicLibrary.open('libsqlite3.so');
    } on Object {
      return DynamicLibrary.open('libsqlite3.so.0');
    }
  });
}

/// Opens a fresh in-memory [HifzDatabase] for a test — no file, no network.
///
/// The crash-safe file-backed connection and its `setup`/`beforeOpen` pragmas
/// are E03-T04; here the schema/DAO tests run against an isolated
/// `NativeDatabase.memory()`. Until T04 wires the FK pragma into the
/// connection, a test that exercises foreign keys turns them on itself with
/// `PRAGMA foreign_keys = ON;`.
HifzDatabase openTestDatabase() {
  _configureSqlite3();
  return HifzDatabase(NativeDatabase.memory());
}
