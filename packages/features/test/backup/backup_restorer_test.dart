// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E17-T06 — the shell restore orchestration: decode → cross-muṣḥaf refusal →
// dispatch each profile to replace/merge. The transactional DB write is tested in
// data/restore_repository_test; here a fake RestoreRepository records the calls.

import 'package:backup/backup.dart';
import 'package:data/data.dart' show RestoreRepository;
import 'package:features/features.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

class _FakeRestore implements RestoreRepository {
  final List<String> calls = <String>[];

  @override
  Future<void> replaceProfile({
    required Profile profile,
    required CycleConfig cycleConfig,
    required List<Card> cards,
    required List<LineBlock> lineBlocks,
    required List<ReviewLog> reviewLog,
    required List<ConfusionEdge> confusionEdges,
    required CalendarDate today,
  }) async =>
      calls.add('replace:${profile.profileId.value}:${cards.length}c'
          ':${reviewLog.length}r');

  @override
  Future<void> mergeProfile({
    required Profile profile,
    required CycleConfig cycleConfig,
    required List<Card> cards,
    required List<LineBlock> lineBlocks,
    required List<ReviewLog> reviewLog,
    required List<ConfusionEdge> confusionEdges,
    required CalendarDate today,
  }) async =>
      calls.add('merge:${profile.profileId.value}');
}

BackupSnapshot _snapshot({String? mushafId}) {
  const pid = ProfileId('p1');
  return BackupSnapshot(
    schemaVersion: 2,
    appVersion: '1.0.0',
    exportedAt: '2026-06-25',
    mushaf: MushafRef(
      id: mushafId ?? kKfgqpcHafsMadaniV2Edition.mushafId,
      riwayah: 'Ḥafṣ ʿan ʿĀṣim',
      name: 'Madani',
      checksumSha256: '',
    ),
    profiles: <ProfileExport>[
      ProfileExport(
        profile: Profile(
          profileId: pid,
          displayName: 'Aisha',
          role: ProfileRole.self,
          locale: ProfileLocale.fa,
          mushafId: kKfgqpcHafsMadaniV2Edition.mushafId,
          createdAtInstant: DateTime.utc(2026),
        ),
        cycleConfig: const CycleConfig(
          profileId: pid,
          cycleType: '7_manzil',
          nearWindowJuz: 3,
          farTargetPerDay: 4,
          cycleCeilingDays: 7,
          dailyBudgetMinutes: 45,
          termLabelSet: 'classical',
        ),
        cards: <Card>[
          Card(
            profileId: pid,
            pageId: 1,
            track: ReviewTrack.far,
            difficulty: 6,
            stabilityDays: 20,
            lastReviewedDay: CalendarDate.ymd(2026, 6, 20),
            dueAt: CalendarDate.ymd(2026, 7, 1),
          ),
        ],
        lineBlocks: const <LineBlock>[],
        reviewLog: <ReviewLog>[
          ReviewLog(
            logId: const LogId('log-1'),
            profileId: pid,
            pageId: 1,
            reviewedAtInstant: DateTime.utc(2026, 6, 20),
            trackAtReview: ReviewTrack.far,
            grade: ReviewGrade.good,
            elapsedDays: 5,
            source: GradeSource.self,
          ),
        ],
        confusionEdges: const <ConfusionEdge>[],
      ),
    ],
  );
}

void main() {
  final today = CalendarDate.ymd(2026, 6, 25);
  late _FakeRestore fake;
  late BackupRestorer restorer;

  setUp(() {
    fake = _FakeRestore();
    restorer = BackupRestorer(restore: fake, today: () => today);
  });

  test('replace dispatches every profile to replaceProfile with its rows', () async {
    final bytes = await HifzBackup.export(_snapshot());
    await restorer.restore(bytes, mode: RestoreMode.replace);
    expect(fake.calls, <String>['replace:p1:1c:1r']);
  });

  test('merge dispatches to mergeProfile', () async {
    final bytes = await HifzBackup.export(_snapshot());
    await restorer.restore(bytes, mode: RestoreMode.merge);
    expect(fake.calls, <String>['merge:p1']);
  });

  test('a cross-muṣḥaf backup is refused, never applied', () async {
    final bytes = await HifzBackup.export(_snapshot(mushafId: 'warsh_other'));
    await expectLater(
      restorer.restore(bytes, mode: RestoreMode.replace),
      throwsA(isA<CrossMushafRefused>()),
    );
    expect(fake.calls, isEmpty); // nothing written
  });

  test('a corrupted file surfaces the typed BackupException, nothing applied',
      () async {
    final bytes = await HifzBackup.export(_snapshot());
    bytes[bytes.length - 1] ^= 0x01; // flip a body byte
    await expectLater(
      restorer.restore(bytes, mode: RestoreMode.replace),
      throwsA(
        isA<BackupException>().having(
          (e) => e.error,
          'error',
          BackupError.integrityFailed,
        ),
      ),
    );
    expect(fake.calls, isEmpty);
  });
}
