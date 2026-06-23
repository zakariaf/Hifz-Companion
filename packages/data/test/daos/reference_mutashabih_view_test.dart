// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/daos/reference_read_dao.dart';
import 'package:data/src/db/database.dart';
import 'package:data/src/reference/mutashabihat_loader.dart';
import 'package:data/src/reference/reference_data_builder.dart';
import 'package:data/src/reference/reference_db_builder.dart';
import 'package:data/src/reference/reference_metadata.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

/// A reference edition with āyāt spread across TWO pages, so the assembled group
/// view carries real, distinct page numbers.
CoreReferenceData _referenceSeed() => const CoreReferenceData(
      mushafId: 'hafs_madani_15',
      riwayah: 'hafs_an_asim',
      name: 'Madani 15-line',
      fontFamily: 'v2',
      checksumSha256:
          '0000000000000000000000000000000000000000000000000000000000000000',
      pageCount: 2,
      lineCount: 15,
      surahs: [
        SurahRowData(
          surahId: 2,
          nameAr: 'البقرة',
          revelation: 'medinan',
          ayahCount: 286,
          bismillahPre: true,
        ),
      ],
      pages: [
        PageRowData(
          pageId: 1,
          juz: 1,
          hizb: 1,
          rub: 1,
          surahStart: 2,
          ayahStart: 1,
          surahEnd: 2,
          ayahEnd: 2,
          lineCount: 15,
          qpcFontName: 'QPC_P001',
        ),
        PageRowData(
          pageId: 2,
          juz: 1,
          hizb: 1,
          rub: 2,
          surahStart: 2,
          ayahStart: 3,
          surahEnd: 2,
          ayahEnd: 4,
          lineCount: 15,
          qpcFontName: 'QPC_P002',
        ),
      ],
      lines: [
        LineRowData(
          lineId: 1,
          pageId: 1,
          lineNo: 1,
          lineType: 'ayah',
          ayahRefsJson: '["2:1"]',
          textGlyphRef: 'g',
        ),
      ],
      ayat: [
        AyahRowData(
          ayahId: '2:1',
          surah: 2,
          ayah: 1,
          pageId: 1,
          lineRefsJson: '["1:1"]',
          sajda: false,
        ),
        AyahRowData(
          ayahId: '2:2',
          surah: 2,
          ayah: 2,
          pageId: 1,
          lineRefsJson: '["1:1"]',
          sajda: false,
        ),
        AyahRowData(
          ayahId: '2:3',
          surah: 2,
          ayah: 3,
          pageId: 2,
          lineRefsJson: '["1:1"]',
          sajda: false,
        ),
        AyahRowData(
          ayahId: '2:4',
          surah: 2,
          ayah: 4,
          pageId: 2,
          lineRefsJson: '["1:1"]',
          sajda: false,
        ),
      ],
    );

const _datasetJson = '''
{
  "groups": [
    {
      "groupId": "g1",
      "type": "near_identical",
      "noteKey": "note_g1",
      "members": [
        {"ayahId": "2:3", "indices": [1]},
        {"ayahId": "2:1", "indices": [0, 2]}
      ]
    },
    {
      "groupId": "g2",
      "type": "identical",
      "members": [
        {"ayahId": "2:2"},
        {"ayahId": "2:4"}
      ]
    }
  ]
}
''';

void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;
  late ReferenceReadDao dao;
  setUp(() async {
    db = openTestDatabase();
    await loadCoreReference(db, _referenceSeed());
    await loadMutashabihatInto(db, parseMutashabihatDataset(_datasetJson));
    dao = ReferenceReadDao(db);
  });
  tearDown(() => db.close());

  test('allMutashabihGroups returns every group ordered by id', () async {
    final groups = await dao.allMutashabihGroups();
    expect(groups.map((g) => g.groupId), ['g1', 'g2']);
    expect(groups.first.type, MutashabihType.nearIdentical);
    expect(groups.first.noteKey, 'note_g1');
  });

  test('mutashabihGroupView assembles members with pages + indices, in '
      'stable ayah order', () async {
    final view = await dao.mutashabihGroupView('g1');
    expect(view, isNotNull);
    expect(view!.type, MutashabihType.nearIdentical);
    expect(view.noteKey, 'note_g1');
    // Ordered by ayah_id ('2:1' before '2:3'), each carrying its real page.
    expect(view.members.map((m) => m.ayahId), ['2:1', '2:3']);
    expect(view.members[0].pageNumber, 1);
    expect(view.members[0].distinguishingWordIndices, [0, 2]);
    expect(view.members[1].pageNumber, 2);
    expect(view.members[1].distinguishingWordIndices, [1]);
  });

  test('a member with no indices yields an empty list (not null)', () async {
    final view = await dao.mutashabihGroupView('g2');
    expect(
      view!.members.every((m) => m.distinguishingWordIndices.isEmpty),
      isTrue,
    );
  });

  test('an unknown group view is null', () async {
    expect(await dao.mutashabihGroupView('nope'), isNull);
  });
}
