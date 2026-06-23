// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/database.dart';
import 'package:data/src/persistence_exception.dart';
import 'package:data/src/reference/reference_data_builder.dart';
import 'package:data/src/reference/reference_db_builder.dart';
import 'package:data/src/reference/reference_metadata.dart';
import 'package:data/src/repositories/confusion_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

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
      ],
    );

Profile _profile() => Profile(
      profileId: const ProfileId('p'),
      displayName: 'p',
      role: ProfileRole.self,
      locale: ProfileLocale.fa,
      mushafId: 'hafs_madani_15',
      createdAtInstant: DateTime.utc(2026, 6),
      settings: const {},
    );

void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;
  late LiveConfusionRepository repo;
  const profileId = ProfileId('p');
  final today = CalendarDate.ymd(2026, 6, 17);

  setUp(() async {
    db = openTestDatabase();
    await loadCoreReference(db, _referenceSeed());
    await db.profileDao.upsert(_profile());
    repo = LiveConfusionRepository(db);
  });
  tearDown(() => db.close());

  Future<int> edgeCount() async => (await db
          .customSelect('SELECT COUNT(*) AS c FROM confusion_edge')
          .getSingle())
      .read<int>('c');

  Future<void> swap(String x, String y, {CalendarDate? on}) => repo.logSwap(
        profileId: profileId,
        ayahX: x,
        ayahY: y,
        today: on ?? today,
      );

  test(
      'first swap creates one edge at kInitialConfusionWeight, canonical, '
      'stamped with the injected today', () async {
    await swap('2:1', '2:2');
    expect(await edgeCount(), 1);
    final edge = await db.confusionEdgeDao
        .edgeFor(profileId: profileId, ayahOne: '2:1', ayahTwo: '2:2');
    expect(edge!.weight, kInitialConfusionWeight);
    expect(edge.ayahA, '2:1');
    expect(edge.ayahB, '2:2');
    expect(edge.lastConfusedAt, today);
  });

  test('repeat swaps strengthen the single row monotonically and bounded',
      () async {
    for (var i = 0; i < 20; i++) {
      await swap('2:1', '2:2');
    }
    expect(await edgeCount(), 1);
    final edge = await db.confusionEdgeDao
        .edgeFor(profileId: profileId, ayahOne: '2:1', ayahTwo: '2:2');
    // Monotonic, and bounded by the saturation ceiling.
    expect(edge!.weight, kMaxConfusionWeight);
  });

  test('the weight increment follows nextConfusionWeight exactly', () async {
    await swap('2:1', '2:2');
    await swap('2:1', '2:2');
    final edge = await db.confusionEdgeDao
        .edgeFor(profileId: profileId, ayahOne: '2:1', ayahTwo: '2:2');
    expect(edge!.weight, nextConfusionWeight(kInitialConfusionWeight));
  });

  test('canonical ordering: (X,Y) and (Y,X) strengthen the same single row',
      () async {
    await swap('2:1', '2:2');
    await swap('2:2', '2:1');
    expect(await edgeCount(), 1);
    final edge = await db.confusionEdgeDao
        .edgeFor(profileId: profileId, ayahOne: '2:1', ayahTwo: '2:2');
    expect(edge!.ayahA, '2:1');
    expect(edge.ayahB, '2:2');
    expect(edge.weight, nextConfusionWeight(kInitialConfusionWeight));
  });

  test('a failed persist commits nothing (create variant)', () async {
    // ayah 9:9 is not a seeded reference row → FK violation rolls the txn back.
    await expectLater(
      swap('2:1', '9:9'),
      throwsA(isA<ConfusionWriteException>()),
    );
    expect(await edgeCount(), 0);
  });

  test(
      'a failed persist leaves an existing edge byte-equal (strengthen '
      'variant)', () async {
    await swap('2:1', '2:2');
    final before = await db.confusionEdgeDao
        .edgeFor(profileId: profileId, ayahOne: '2:1', ayahTwo: '2:2');

    await expectLater(
      swap('2:1', '9:9'),
      throwsA(isA<ConfusionWriteException>()),
    );
    final after = await db.confusionEdgeDao
        .edgeFor(profileId: profileId, ayahOne: '2:1', ayahTwo: '2:2');
    expect(after, before);
    expect(await edgeCount(), 1);
  });

  test('last_confused_at tracks the injected today (no wall clock)', () async {
    await swap('2:1', '2:2');
    final laterDay = CalendarDate.ymd(2026, 6, 20);
    await swap('2:1', '2:2', on: laterDay);
    final edge = await db.confusionEdgeDao
        .edgeFor(profileId: profileId, ayahOne: '2:1', ayahTwo: '2:2');
    expect(edge!.lastConfusedAt, laterDay);
  });

  test('logSwap touches no FSRS card state', () async {
    await db.customStatement(
      'INSERT INTO card (profile_id, page_id, track, d, s, due_at, '
      'last_review_at, reps, lapses, weak_flag, signoffs, manual_lock, '
      "prayer_critical, enabled) VALUES ('p', 1, 'FAR', 6, 30, 20620, 20610, "
      '5, 1, 0, 2, 0, 1, 1)',
    );
    await swap('2:1', '2:2');
    final card = await db
        .customSelect("SELECT d, s, due_at FROM card WHERE page_id = 1")
        .getSingle();
    expect(card.read<double>('d'), 6);
    expect(card.read<double>('s'), 30);
    expect(card.read<int>('due_at'), 20620);
  });

  // Full strength regardless of source: logSwap has NO source/confidence
  // parameter that throttles the weight (compile-time guarantee) — a
  // self-reported swap and a teacher-flagged swap produce an identical weight
  // change. Source scales only the engine's stability move (E04), never here.
}
