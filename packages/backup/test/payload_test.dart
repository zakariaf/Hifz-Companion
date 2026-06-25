// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E17-T03 — the truth-only versioned JSON payload codec (domain-backup-format
// §4), test-first: a lossless round-trip over every entity, canonical sorted-key
// determinism, the floating-date / UTC-instant contract, newerFormat refusal, and
// malformedPayload on a missing field or invalid enum.

import 'dart:convert';

import 'package:backup/backup.dart';
import 'package:backup/src/payload.dart';
import 'package:models/models.dart';
import 'package:test/test.dart';

BackupSnapshot _sampleSnapshot() {
  const pid = ProfileId('p1');
  final profile = Profile(
    profileId: pid,
    displayName: 'علي',
    role: ProfileRole.student,
    locale: ProfileLocale.fa,
    mushafId: 'kfgqpc_hafs_madani_v2',
    createdAtInstant: DateTime.utc(2026, 1, 15, 9, 30),
    settings: const <String, Object?>{
      'appearance': 'dark',
      'calendarSystem': 'hijri',
    },
  );
  // Every defaulted field carries a NON-default value so a dropped field cannot
  // hide behind its default; nullable fields are exercised by the minimal rows.
  const cycle = CycleConfig(
    profileId: pid,
    cycleType: '1_juz_day',
    newLinesPerDay: 2,
    nearWindowJuz: 3,
    farTargetPerDay: 21,
    cycleCeilingDays: 30,
    dailyBudgetMinutes: 30,
    isPureCycleMode: true,
    termLabelSet: 'classical',
    regionPreset: 'gulf',
  );
  final cards = <Card>[
    Card(
      profileId: pid,
      pageId: 42,
      track: ReviewTrack.far,
      difficulty: 5.2,
      stabilityDays: 12.5,
      lastReviewedDay: CalendarDate.ymd(2026, 6, 20),
      dueAt: CalendarDate.ymd(2026, 7, 1),
      reps: 3,
      lapses: 1,
      isWeak: true,
      signoffs: 2,
      hasManualLock: true,
      isPrayerCritical: true,
      isEnabled: false,
    ),
    // An unmemorized card — dueAt/lastReviewedDay omitted, so they default to
    // null (the codec must encode and restore those nulls).
    const Card(
      profileId: pid,
      pageId: 7,
      track: ReviewTrack.unmemorized,
      difficulty: 0,
      stabilityDays: 0,
    ),
  ];
  final lineBlocks = <LineBlock>[
    const LineBlock(
      blockId: BlockId('b1'),
      profileId: pid,
      pageId: 10,
      lineStart: 3,
      lineEnd: 5,
      errorCount: 2,
    ),
  ];
  final reviewLog = <ReviewLog>[
    ReviewLog(
      logId: const LogId('log-1'),
      profileId: pid,
      pageId: 42,
      reviewedAtInstant: DateTime.utc(2026, 6, 20, 6, 15),
      trackAtReview: ReviewTrack.far,
      grade: ReviewGrade.good,
      errorLineIndices: const <int>[3, 7],
      elapsedDays: 11,
      predictedRetrievability: 0.91,
      stabilityDaysBefore: 10,
      stabilityDaysAfter: 12.5,
      difficultyBefore: 5,
      difficultyAfter: 5.2,
      source: GradeSource.teacher,
      teacherLabel: 'Ustadh',
    ),
    // A minimal self-graded row — every optional field absent.
    ReviewLog(
      logId: const LogId('log-2'),
      profileId: pid,
      pageId: 7,
      reviewedAtInstant: DateTime.utc(2026, 6, 21, 5),
      trackAtReview: ReviewTrack.newPage,
      grade: ReviewGrade.again,
      elapsedDays: 0,
      source: GradeSource.self,
    ),
  ];
  final confusionEdges = <ConfusionEdge>[
    ConfusionEdge(
      profileId: pid,
      ayahA: '2:1',
      ayahB: '2:5',
      weight: 3.5,
      lastConfusedAt: CalendarDate.ymd(2026, 6, 15),
    ),
    // Minimal — lastConfusedAt defaults to null (the codec must restore that).
    const ConfusionEdge(
      profileId: pid,
      ayahA: '3:1',
      ayahB: '3:2',
      weight: 1.5,
    ),
  ];
  return BackupSnapshot(
    schemaVersion: kCurrentSchemaVersion,
    appVersion: '1.0.0',
    exportedAt: '2026-06-25',
    mushaf: const MushafRef(
      id: 'kfgqpc_hafs_madani_v2',
      riwayah: 'Ḥafṣ ʿan ʿĀṣim',
      name: 'Madani muṣḥaf',
      checksumSha256: 'abc123',
    ),
    profiles: <ProfileExport>[
      ProfileExport(
        profile: profile,
        cycleConfig: cycle,
        cards: cards,
        lineBlocks: lineBlocks,
        reviewLog: reviewLog,
        confusionEdges: confusionEdges,
      ),
    ],
  );
}

void main() {
  group('round-trip (§4) — every entity survives losslessly', () {
    test('snapshot → canonical JSON → snapshot preserves all rows', () {
      final snap = _sampleSnapshot();
      final reimported = snapshotFromJson(
        decodeJsonObject(encodeCanonicalJson(snapshotToJson(snap))),
      );
      final got = reimported.profiles.single;
      final orig = snap.profiles.single;

      expect(got.profile, orig.profile); // Profile ==
      expect(got.cycleConfig, orig.cycleConfig);
      expect(got.cards, equals(orig.cards)); // deep list eq via Card ==
      expect(got.lineBlocks, equals(orig.lineBlocks));
      expect(got.reviewLog, equals(orig.reviewLog));
      expect(got.confusionEdges, equals(orig.confusionEdges));
      expect(reimported.mushaf.checksumSha256, snap.mushaf.checksumSha256);
      expect(reimported.schemaVersion, kCurrentSchemaVersion);
      expect(reimported.exportedAt, '2026-06-25');
    });

    test('re-encoding the re-imported snapshot is byte-identical', () {
      final snap = _sampleSnapshot();
      final once = encodeCanonicalJson(snapshotToJson(snap));
      final twice = encodeCanonicalJson(
        snapshotToJson(snapshotFromJson(decodeJsonObject(once))),
      );
      expect(twice, equals(once));
    });
  });

  group('canonical encoding (§4) — deterministic sorted keys', () {
    test('top-level and nested map keys are sorted', () {
      final bytes = encodeCanonicalJson(<String, Object?>{
        'b': 1,
        'a': 2,
        'z': <String, Object?>{'y': 1, 'x': 2},
      });
      expect(utf8.decode(bytes), '{"a":2,"b":1,"z":{"x":2,"y":1}}');
    });
  });

  group('encoding contract (§4) — floating days vs UTC instants', () {
    test('dueAt / lastConfusedAt are floating "YYYY-MM-DD"; reviewedAt is UTC',
        () {
      final j = snapshotToJson(_sampleSnapshot());
      final p = (j['profiles']! as List).single as Map<String, Object?>;
      final card0 = (p['cards']! as List).first as Map<String, Object?>;
      final edge0 =
          (p['confusionEdges']! as List).first as Map<String, Object?>;
      final log0 = (p['reviewLog']! as List).first as Map<String, Object?>;

      expect(card0['dueAt'], '2026-07-01'); // floating
      expect(edge0['lastConfusedAt'], '2026-06-15'); // floating (CalendarDate)
      expect((log0['reviewedAt']! as String), endsWith('Z')); // UTC instant
      expect(log0['reviewedAt'], '2026-06-20T06:15:00.000Z');
    });

    test('an unmemorized card encodes dueAt as null', () {
      final j = snapshotToJson(_sampleSnapshot());
      final p = (j['profiles']! as List).single as Map<String, Object?>;
      final unmem = (p['cards']! as List).last as Map<String, Object?>;
      expect(unmem['dueAt'], isNull);
      expect(unmem['lastReviewAt'], isNull);
    });
  });

  group('forward-compat (§4)', () {
    test('schemaVersion > current ⇒ newerFormat', () {
      final j = snapshotToJson(_sampleSnapshot())..['schemaVersion'] = 99;
      expect(
        () => snapshotFromJson(j),
        throwsA(
          isA<BackupException>().having(
            (e) => e.error,
            'error',
            BackupError.newerFormat,
          ),
        ),
      );
    });
  });

  group('validation (§4) ⇒ malformedPayload', () {
    BackupError errorOf(Map<String, Object?> j) {
      try {
        snapshotFromJson(j);
      } on BackupException catch (e) {
        return e.error;
      }
      fail('expected a BackupException');
    }

    test('a missing required field ⇒ malformedPayload', () {
      final j = snapshotToJson(_sampleSnapshot())..remove('appVersion');
      expect(errorOf(j), BackupError.malformedPayload);
    });

    test('an invalid enum wire value ⇒ malformedPayload', () {
      final j = snapshotToJson(_sampleSnapshot());
      final p = (j['profiles']! as List).single as Map<String, Object?>;
      (p['profile']! as Map<String, Object?>)['role'] = 'bogus-role';
      expect(errorOf(j), BackupError.malformedPayload);
    });
  });
}
