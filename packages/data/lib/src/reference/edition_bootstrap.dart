// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart' show MushafEdition;

import '../live_persistence_handle.dart';
import '../persistence_handle.dart';
import 'reference_db_builder.dart' show registerBundledEditionMetadata;

/// Registers the bundled muṣḥaf [edition]'s **metadata row** (riwāyah / name /
/// counts) so a profile's `mushaf_id` foreign key resolves before the full
/// checksum-verified reference install (E05) lands — the dev/bootstrap slice the
/// composition root uses in a **debug** build where the bundled asset pack is
/// absent, so the app is runnable on a simulator. It writes **no** Quran text,
/// glyph, page, line, or āyah (R1); a release build never calls it.
///
/// A thin wrapper over the single sanctioned reference writer
/// ([registerBundledEditionMetadata], internal to [reference_db_builder]) — this
/// file performs no reference write itself, so the read-only gate stays intact
/// and the build path is never exported.
Future<void> registerBundledEdition(
  PersistenceHandle handle,
  MushafEdition edition,
) =>
    registerBundledEditionMetadata(
      (handle as LivePersistenceHandle).database,
      edition,
    );
