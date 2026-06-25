// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E17-T07 — the export assembly. The exporter reads each profile's rows through
// the data seams, builds a BackupSnapshot, and serializes it; here fakes feed the
// rows and we round-trip the bytes back through HifzBackup.import (the DB reads
// themselves are covered in data/backup_read_repository_test).

import 'package:backup/backup.dart';
import 'package:data/data.dart'
    show BackupReadRepository, ProfileExportRows, ProfileRepository;
import 'package:features/features.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

class _FakeProfiles implements ProfileRepository {
  _FakeProfiles(this._profiles);
  final List<Profile> _profiles;
  @override
  Future<List<Profile>> all() async => _profiles;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeBackupRead implements BackupReadRepository {
  _FakeBackupRead(this._rows);
  final Map<String, ProfileExportRows> _rows;
  @override
  Future<ProfileExportRows?> readProfileForExport(ProfileId profileId) async =>
      _rows[profileId.value];
}

void main() {
  const pid = ProfileId('p1');
  final profile = Profile(
    profileId: pid,
    displayName: 'Aisha',
    role: ProfileRole.self,
    locale: ProfileLocale.fa,
    mushafId: kKfgqpcHafsMadaniV2Edition.mushafId,
    createdAtInstant: DateTime.utc(2026),
  );
  final ProfileExportRows rows = (
    profile: profile,
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
  );

  test('assembles every profile and round-trips through HifzBackup.import', () async {
    final exporter = BackupExporter(
      profiles: _FakeProfiles(<Profile>[profile]),
      backupRead: _FakeBackupRead(<String, ProfileExportRows>{'p1': rows}),
      today: () => CalendarDate.ymd(2026, 6, 25),
    );

    final snapshot = await HifzBackup.import(await exporter.exportAll());
    final got = snapshot.profiles.single;
    expect(got.profile.profileId.value, 'p1');
    expect(got.cards, hasLength(1));
    expect(got.reviewLog.single.logId.value, 'log-1');
    expect(snapshot.mushaf.id, kKfgqpcHafsMadaniV2Edition.mushafId);
    expect(snapshot.exportedAt, '2026-06-25');
    expect(snapshot.schemaVersion, kCurrentSchemaVersion);
    expect(snapshot.appVersion, kBackupAppVersion);
  });

  test('an encrypted export round-trips with the passphrase', () async {
    final exporter = BackupExporter(
      profiles: _FakeProfiles(<Profile>[profile]),
      backupRead: _FakeBackupRead(<String, ProfileExportRows>{'p1': rows}),
      today: () => CalendarDate.ymd(2026, 6, 25),
    );
    final bytes = await exporter.exportAll(passphrase: 'secret');
    expect(bytes[8], 0x02); // mode = encrypted
    final snapshot = await HifzBackup.import(bytes, passphrase: 'secret');
    expect(snapshot.profiles.single.cards, hasLength(1));
  });
}
