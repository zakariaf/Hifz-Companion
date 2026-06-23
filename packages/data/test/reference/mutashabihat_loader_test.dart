// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/daos/reference_read_dao.dart';
import 'package:data/src/db/database.dart';
import 'package:data/src/reference/mutashabihat_loader.dart';
import 'package:data/src/reference/reference_data_builder.dart';
import 'package:data/src/reference/reference_db_builder.dart';
import 'package:data/src/reference/reference_metadata.dart';
import 'package:drift/drift.dart' show TableInfo;
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

/// A non-empty 64-hex stand-in for the pinned, already-verified SHA-256.
const _verifiedSha =
    '0000000000000000000000000000000000000000000000000000000000000000';

/// A tiny reference edition (surah 2, page 1, āyāt 2:1…2:4) so the
/// `mutashabih_member.ayah_id` foreign keys resolve. The mutashābihāt load runs
/// **after** the `ayah` rows exist, exactly as `_buildReferenceDb` orders it.
CoreReferenceData _referenceSeed() => const CoreReferenceData(
      mushafId: 'hafs_madani_15',
      riwayah: 'hafs_an_asim',
      name: 'Madani 15-line',
      fontFamily: 'v2',
      checksumSha256: _verifiedSha,
      pageCount: 1,
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
          ayahEnd: 4,
          lineCount: 15,
          qpcFontName: 'QPC_P001',
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
          pageId: 1,
          lineRefsJson: '["1:1"]',
          sajda: false,
        ),
        AyahRowData(
          ayahId: '2:4',
          surah: 2,
          ayah: 4,
          pageId: 1,
          lineRefsJson: '["1:1"]',
          sajda: false,
        ),
      ],
    );

/// A conforming two-group fixture over the seeded āyāt.
const _validDatasetJson = '''
{
  "groups": [
    {
      "groupId": "g1",
      "type": "near_identical",
      "noteKey": "mutashabih_note_g1",
      "members": [
        {"ayahId": "2:1", "indices": [0, 2]},
        {"ayahId": "2:2", "indices": [1]}
      ]
    },
    {
      "groupId": "g2",
      "type": "identical",
      "members": [
        {"ayahId": "2:3", "indices": []},
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
    dao = ReferenceReadDao(db);
  });
  tearDown(() => db.close());

  Future<int> count(TableInfo<dynamic, dynamic> table) async => (await db
          .customSelect(
            'SELECT COUNT(*) AS c FROM ${table.actualTableName}',
          )
          .getSingle())
      .read<int>('c');

  Future<bool> mutashabihTablesEmpty() async =>
      await count(db.mutashabihGroups) == 0 &&
      await count(db.mutashabihMembers) == 0;

  group('happy-path load', () {
    test('populates exactly the fixture groups and members', () async {
      await loadMutashabihatInto(
          db, parseMutashabihatDataset(_validDatasetJson));

      expect(await count(db.mutashabihGroups), 2);
      expect(await count(db.mutashabihMembers), 4);

      final g1 = await dao.mutashabihGroupById('g1');
      expect(g1, isNotNull);
      expect(g1!.type, MutashabihType.nearIdentical);
      expect(g1.noteKey, 'mutashabih_note_g1');

      final g2 = await dao.mutashabihGroupById('g2');
      expect(g2!.type, MutashabihType.identical);
      expect(g2.noteKey, isNull);

      final g1Members = await dao.mutashabihMembersForGroup('g1');
      expect(
        g1Members.map((m) => m.ayahId).toSet(),
        {'2:1', '2:2'},
      );
      final m21 = g1Members.firstWhere((m) => m.ayahId == '2:1');
      expect(m21.distinguishingWordIndexJson, '[0,2]');
    });
  });

  group('type-enum guard (reject thematic/non-conforming)', () {
    test('a thematic type is refused, naming the group, tables stay empty',
        () async {
      const thematic = '''
{"groups":[{"groupId":"gX","type":"thematic","members":[
  {"ayahId":"2:1"},{"ayahId":"2:2"}]}]}
''';
      expect(
        () => parseMutashabihatDataset(thematic),
        throwsA(
          isA<MutashabihatDatasetException>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('gX'), contains('thematic')),
          ),
        ),
      );
      expect(await mutashabihTablesEmpty(), isTrue);
    });
  });

  group('foreign-key validity', () {
    test('a member ayah not in the reference set fails and writes nothing',
        () async {
      const dangling = '''
{"groups":[{"groupId":"g1","type":"identical","members":[
  {"ayahId":"2:1"},{"ayahId":"9:9"}]}]}
''';
      await expectLater(
        () => loadMutashabihatInto(db, parseMutashabihatDataset(dangling)),
        throwsA(
          isA<MutashabihatDatasetException>().having(
            (e) => e.toString(),
            'message',
            contains('9:9'),
          ),
        ),
      );
      expect(await mutashabihTablesEmpty(), isTrue);
    });
  });

  group('word-index validity', () {
    test('a negative index is refused', () {
      const negative = '''
{"groups":[{"groupId":"g1","type":"identical","members":[
  {"ayahId":"2:1","indices":[-1]},{"ayahId":"2:2"}]}]}
''';
      expect(
        () => parseMutashabihatDataset(negative),
        throwsA(isA<MutashabihatDatasetException>()),
      );
    });

    test('a non-integer index is refused', () {
      const nonInt = '''
{"groups":[{"groupId":"g1","type":"identical","members":[
  {"ayahId":"2:1","indices":["x"]},{"ayahId":"2:2"}]}]}
''';
      expect(
        () => parseMutashabihatDataset(nonInt),
        throwsA(isA<MutashabihatDatasetException>()),
      );
    });

    test('a valid index list round-trips byte-equal', () async {
      await loadMutashabihatInto(
          db, parseMutashabihatDataset(_validDatasetJson));
      final members = await dao.mutashabihMembersForGroup('g1');
      final m21 = members.firstWhere((m) => m.ayahId == '2:1');
      expect(m21.distinguishingWordIndexJson, '[0,2]');
      final m22 = members.firstWhere((m) => m.ayahId == '2:2');
      expect(m22.distinguishingWordIndexJson, '[1]');
    });
  });

  group('singleton-group rejection (group-not-node)', () {
    test('a group with one member is refused', () {
      const singleton = '''
{"groups":[{"groupId":"lonely","type":"identical","members":[
  {"ayahId":"2:1"}]}]}
''';
      expect(
        () => parseMutashabihatDataset(singleton),
        throwsA(
          isA<MutashabihatDatasetException>().having(
            (e) => e.toString(),
            'message',
            contains('lonely'),
          ),
        ),
      );
    });
  });

  group('objective wording only — no tafsīr/text stored', () {
    test('a stray translation field is ignored and never persisted', () async {
      const withGloss = '''
{"groups":[{"groupId":"g1","type":"identical","note":"a gloss","members":[
  {"ayahId":"2:1","translation":"In the name...","indices":[0]},
  {"ayahId":"2:2"}]}]}
''';
      await loadMutashabihatInto(db, parseMutashabihatDataset(withGloss));
      // The member row carries only ayah_id + index json — there is no text
      // column to hold the ignored "translation" field.
      final members = await dao.mutashabihMembersForGroup('g1');
      expect(members, hasLength(2));
      expect(
        members
            .firstWhere((m) => m.ayahId == '2:1')
            .distinguishingWordIndexJson,
        '[0]',
      );
    });
  });

  group('read-only invariant / one-time population', () {
    // ReferenceReadDao is select-only by construction — it exposes
    // mutashabihGroupById / mutashabihMembersForGroup and NO insert/update/
    // delete (grep-verifiable). The only writer is loadMutashabihatInto, the
    // one-shot reference-build step; there is no runtime re-write path.
    test('re-loading the same dataset throws on the PK (no silent re-write)',
        () async {
      await loadMutashabihatInto(
          db, parseMutashabihatDataset(_validDatasetJson));
      await expectLater(
        () => loadMutashabihatInto(
          db,
          parseMutashabihatDataset(_validDatasetJson),
        ),
        throwsA(isA<MutashabihatDatasetException>()),
      );
    });
  });

  group('determinism', () {
    test('the same fixture yields byte-identical rows across two builds',
        () async {
      await loadMutashabihatInto(
          db, parseMutashabihatDataset(_validDatasetJson));
      final groupsA = await dao.mutashabihMembersForGroup('g1');

      final db2 = openTestDatabase();
      await loadCoreReference(db2, _referenceSeed());
      await loadMutashabihatInto(
        db2,
        parseMutashabihatDataset(_validDatasetJson),
      );
      final dao2 = ReferenceReadDao(db2);
      final groupsB = await dao2.mutashabihMembersForGroup('g1');
      await db2.close();

      expect(
        groupsA.map((m) => '${m.ayahId}:${m.distinguishingWordIndexJson}'),
        groupsB.map((m) => '${m.ayahId}:${m.distinguishingWordIndexJson}'),
      );
    });
  });
}
