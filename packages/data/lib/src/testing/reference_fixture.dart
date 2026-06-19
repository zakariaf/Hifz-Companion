// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import '../live_persistence_handle.dart';
import '../persistence_handle.dart';

/// Seeds a minimal read-only reference fixture into [handle] for tests/previews:
/// a muṣḥaf row plus the given pages, so a provisioned card's `page` foreign key
/// resolves and `pageIdsForJuz` returns real pages.
///
/// The real reference pack is built by the checksum-verified E11 core install;
/// this is the test-only stand-in that lets the E07 spine run end to end before
/// then. It writes with raw `INSERT` statements (never a reference DAO mutation —
/// R1), and lives in the `package:data/testing.dart` barrel, out of the
/// production `data.dart` barrel.
Future<void> seedReferenceFixture(
  PersistenceHandle handle, {
  required Map<int, List<int>> pagesByJuz,
  String mushafId = 'kfgqpc_hafs_madani_v2',
}) async {
  final db = (handle as LivePersistenceHandle).database;
  await db.customStatement(
    'INSERT OR IGNORE INTO mushaf (mushaf_id, riwayah, name, line_count, '
    'page_count, font_family, checksum_sha256) '
    "VALUES ('$mushafId', 'hafs_an_asim', 'Madani', 15, 604, 'QCF', 'fixture')",
  );
  // Pages reference a sūra (surah_start/surah_end); seed sūra 1 so the page FK
  // resolves (every fixture page is attributed to sūra 1).
  await db.customStatement(
    'INSERT OR IGNORE INTO surah (surah_id, name_ar, revelation, ayah_count, '
    "bismillah_pre) VALUES (1, 'الفاتحة', 'meccan', 7, 1)",
  );
  for (final entry in pagesByJuz.entries) {
    for (final pageId in entry.value) {
      // qpc_font_name is inert in the spine (no glyph is rendered); use a
      // neutral value so a QPC glyph token never leaks outside packages/quran
      // (check_quran_isolation / PRD R1).
      await db.customStatement(
        'INSERT OR IGNORE INTO page (page_id, juz, hizb, rub, surah_start, '
        'ayah_start, surah_end, ayah_end, line_count, qpc_font_name) '
        "VALUES ($pageId, ${entry.key}, 1, 1, 1, 1, 1, 7, 15, 'fixture')",
      );
    }
  }
}
