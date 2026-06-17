// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:data/src/db/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;
  setUp(() async {
    db = openTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = OFF;');
    await _seedReference(db);
  });
  tearDown(() async => db.close());

  test('reference reads map rows to the models reference DTOs', () async {
    expect(
      await db.referenceReadDao.surahById(2),
      const Surah(
        surahNumber: 2,
        nameAr: 'البقرة',
        revelation: Revelation.medinan,
        ayahCount: 286,
        bismillahPre: true,
      ),
    );
    final page = await db.referenceReadDao.pageByNumber(1);
    if (page == null) fail('page not found');
    expect(page.juz, 1);
    expect(page.qpcFontName, 'QCF_P001');
    expect(
      await db.referenceReadDao.mushafById('m1'),
      const Mushaf(
        mushafId: 'm1',
        riwayah: 'hafs_an_asim',
        name: 'Madani',
        lineCount: 15,
        pageCount: 604,
        fontFamily: 'QCF',
        checksumSha256: 'abc',
      ),
    );
    final group = await db.referenceReadDao.mutashabihGroupById('g1');
    expect(group?.type, MutashabihType.nearIdentical);
    final members = await db.referenceReadDao.mutashabihMembersForGroup('g1');
    expect(members.map((m) => m.ayahId).toSet(), {'2:1', '2:2'});
  });

  test('Line.textGlyphRef is preserved verbatim (opaque, not normalized)',
      () async {
    const glyphBytes = ' ﭐﭑ '; // arbitrary glyph codes, never parsed as text
    await db.customStatement(
      "INSERT INTO line (line_id, page_id, line_no, line_type, ayah_refs_json, "
      "text_glyph_ref) VALUES (1, 1, 1, 'ayah', '[1]', '$glyphBytes')",
    );
    final line = (await db.referenceReadDao.linesForPage(1)).single;
    expect(line.textGlyphRef, glyphBytes);
    expect(line.lineType, LineType.ayah);
  });

  test('ReferenceReadDao declares no insert/update/delete (read-only, R1)', () {
    final dao = [
      File('lib/src/db/daos/reference_read_dao.dart'),
      File('packages/data/lib/src/db/daos/reference_read_dao.dart'),
    ].firstWhere(
      (f) => f.existsSync(),
      orElse: () => fail('reference_read_dao.dart not found from '
          '${Directory.current.path}'),
    );
    final source = dao.readAsStringSync();
    for (final forbidden in const ['into(', 'update(', 'delete(']) {
      expect(
        source.contains(forbidden),
        isFalse,
        reason: 'ReferenceReadDao must expose no "$forbidden" — reference '
            'tables are read-only by construction (R1)',
      );
    }
  });
}

Future<void> _seedReference(HifzDatabase db) async {
  await db.customStatement(
    "INSERT INTO mushaf (mushaf_id, riwayah, name, line_count, page_count, "
    "font_family, checksum_sha256) "
    "VALUES ('m1', 'hafs_an_asim', 'Madani', 15, 604, 'QCF', 'abc')",
  );
  await db.customStatement(
    "INSERT INTO surah (surah_id, name_ar, revelation, ayah_count, "
    "bismillah_pre) VALUES (2, 'البقرة', 'medinan', 286, 1)",
  );
  await db.customStatement(
    'INSERT INTO page (page_id, juz, hizb, rub, surah_start, ayah_start, '
    "surah_end, ayah_end, line_count, qpc_font_name) "
    "VALUES (1, 1, 1, 1, 2, 1, 2, 5, 15, 'QCF_P001')",
  );
  await db.customStatement(
    "INSERT INTO ayah (ayah_id, surah, ayah, page_id, line_refs_json, sajda) "
    "VALUES ('2:1', 2, 1, 1, '[1]', 0)",
  );
  await db.customStatement(
    "INSERT INTO ayah (ayah_id, surah, ayah, page_id, line_refs_json, sajda) "
    "VALUES ('2:2', 2, 2, 1, '[2]', 0)",
  );
  await db.customStatement(
    "INSERT INTO mutashabih_group (group_id, type) "
    "VALUES ('g1', 'near_identical')",
  );
  await db.customStatement(
    "INSERT INTO mutashabih_member (group_id, ayah_id) VALUES ('g1', '2:1')",
  );
  await db.customStatement(
    "INSERT INTO mutashabih_member (group_id, ayah_id) VALUES ('g1', '2:2')",
  );
}
