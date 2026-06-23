// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/daos/confusion_edge_dao.dart';
import 'package:data/src/db/database.dart';
import 'package:data/src/reference/reference_data_builder.dart';
import 'package:data/src/reference/reference_db_builder.dart';
import 'package:data/src/reference/reference_metadata.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

/// A reference seed (mushaf + āyāt 2:1…2:4) so the `confusion_edge` ayah FKs
/// resolve under `foreign_keys = ON`.
CoreReferenceData _referenceSeed() => const CoreReferenceData(
      mushafId: 'hafs_madani_15',
      riwayah: 'hafs_an_asim',
      name: 'Madani 15-line',
      fontFamily: 'v2',
      checksumSha256:
          '0000000000000000000000000000000000000000000000000000000000000000',
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

Profile _profile(String id) => Profile(
      profileId: ProfileId(id),
      displayName: id,
      role: ProfileRole.self,
      locale: ProfileLocale.fa,
      mushafId: 'hafs_madani_15',
      createdAtInstant: DateTime.utc(2026, 6),
      settings: const {},
    );

void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;
  late ConfusionEdgeDao dao;
  const profileA = ProfileId('A');
  const profileB = ProfileId('B');

  setUp(() async {
    db = openTestDatabase();
    await loadCoreReference(db, _referenceSeed());
    await db.profileDao.upsert(_profile('A'));
    await db.profileDao.upsert(_profile('B'));
    dao = db.confusionEdgeDao;
  });
  tearDown(() => db.close());

  Future<int> edgeCount() async => (await db
          .customSelect('SELECT COUNT(*) AS c FROM confusion_edge')
          .getSingle())
      .read<int>('c');

  test('round-trip identity: upsert then edgeFor returns a value-equal edge',
      () async {
    final edge = ConfusionEdge.between(
      profileA,
      '2:1',
      '2:2',
      weight: 3,
      lastConfusedAt: CalendarDate.ymd(2026, 6, 17),
    );
    await dao.upsert(edge);
    final read =
        await dao.edgeFor(profileId: profileA, ayahOne: '2:1', ayahTwo: '2:2');
    expect(read, edge);
    expect(read!.weight, isA<double>());
    expect(read.lastConfusedAt, CalendarDate.ymd(2026, 6, 17));
  });

  test(
      'canonical ordering: (A,B) and (B,A) land on one row; reversed insert '
      'is rejected by the CHECK', () async {
    await dao.upsert(ConfusionEdge.between(profileA, '2:1', '2:2', weight: 1));
    await dao.upsert(ConfusionEdge.between(profileA, '2:2', '2:1', weight: 2));
    expect(await edgeCount(), 1);
    final row =
        await dao.edgeFor(profileId: profileA, ayahOne: '2:2', ayahTwo: '2:1');
    expect(row!.ayahA, '2:1');
    expect(row.ayahB, '2:2');

    // A direct reversed-order insert (ayah_a > ayah_b) trips the CHECK.
    await expectLater(
      db.customStatement(
        "INSERT INTO confusion_edge (profile_id, ayah_a, ayah_b, weight) "
        "VALUES ('A', '2:3', '2:2', 1)",
      ),
      throwsA(anything),
    );
  });

  test('upsert strengthens the single row, never duplicates', () async {
    await dao.upsert(ConfusionEdge.between(profileA, '2:1', '2:2', weight: 1));
    await dao.upsert(ConfusionEdge.between(profileA, '2:1', '2:2', weight: 5));
    expect(await edgeCount(), 1);
    final row =
        await dao.edgeFor(profileId: profileA, ayahOne: '2:1', ayahTwo: '2:2');
    expect(row!.weight, 5);
  });

  test('watchEdgesForProfile ranks weight DESC and scopes per profile',
      () async {
    await dao.upsert(ConfusionEdge.between(profileA, '2:1', '2:2', weight: 1));
    await dao.upsert(ConfusionEdge.between(profileA, '2:3', '2:4', weight: 9));
    await dao.upsert(ConfusionEdge.between(profileB, '2:1', '2:2', weight: 4));

    final aEdges = await dao.watchEdgesForProfile(profileA).first;
    expect(aEdges.map((e) => e.weight), [9, 1]); // ranked DESC
    expect(aEdges.every((e) => e.profileId == profileA), isTrue);

    final bEdges = await dao.watchEdgesForProfile(profileB).first;
    expect(bEdges, hasLength(1)); // no leakage from A
    expect(bEdges.single.weight, 4);
  });

  test('FK enforced: an edge to an unseeded ayah is rejected', () async {
    await expectLater(
      dao.upsert(ConfusionEdge.between(profileA, '2:1', '9:9', weight: 1)),
      throwsA(anything),
    );
  });

  test('ON DELETE CASCADE: deleting a profile removes its edges', () async {
    await dao.upsert(ConfusionEdge.between(profileA, '2:1', '2:2', weight: 1));
    await dao.upsert(ConfusionEdge.between(profileB, '2:1', '2:2', weight: 1));
    expect(await edgeCount(), 2);

    await db.customStatement("DELETE FROM profile WHERE profile_id = 'A'");
    expect(await edgeCount(), 1);
    final remaining = await dao.forProfile(profileB);
    expect(remaining, hasLength(1));
  });

  // Append-grow-only: ConfusionEdgeDao exposes upsert / edgeFor / forProfile /
  // watchEdgesForProfile and NO delete/clear/update method (grep-verifiable).
}
