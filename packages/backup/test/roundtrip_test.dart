// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E17-T04 — the assembled plaintext façade + §5 integrity, test-first: a full
// export → import round-trip, the §3 header offsets on a real file, byte-flip
// integrity rejection, and truncation. Run under ≥2 TZ by the CI date-matrix
// (the floating "YYYY-MM-DD" / UTC contract makes every assertion here a
// timezone-invariance check — a TZ-dependent codec would fail the round-trip or
// the offset bytes under some zone).

import 'dart:convert';
import 'dart:typed_data';

import 'package:backup/backup.dart';
import 'package:backup/src/integrity.dart';
import 'package:backup/src/payload.dart';
import 'package:models/models.dart';
import 'package:test/test.dart';

BackupSnapshot _sampleSnapshot() {
  const pid = ProfileId('p1');
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
        profile: Profile(
          profileId: pid,
          displayName: 'علي',
          role: ProfileRole.student,
          locale: ProfileLocale.fa,
          mushafId: 'kfgqpc_hafs_madani_v2',
          createdAtInstant: DateTime.utc(2026, 1, 15, 9, 30),
          settings: const <String, Object?>{'appearance': 'dark'},
        ),
        cycleConfig: const CycleConfig(
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
        ),
        cards: <Card>[
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
        ],
        lineBlocks: <LineBlock>[
          const LineBlock(
            blockId: BlockId('b1'),
            profileId: pid,
            pageId: 10,
            lineStart: 3,
            lineEnd: 5,
            errorCount: 2,
          ),
        ],
        reviewLog: <ReviewLog>[
          ReviewLog(
            logId: const LogId('log-1'),
            profileId: pid,
            pageId: 42,
            reviewedAtInstant: DateTime.utc(2026, 6, 20, 6, 15),
            trackAtReview: ReviewTrack.far,
            grade: ReviewGrade.good,
            errorLineIndices: const <int>[3, 7],
            elapsedDays: 11,
            source: GradeSource.teacher,
            teacherLabel: 'Ustadh',
          ),
        ],
        confusionEdges: <ConfusionEdge>[
          ConfusionEdge(
            profileId: pid,
            ayahA: '2:1',
            ayahB: '2:5',
            weight: 3.5,
            lastConfusedAt: CalendarDate.ymd(2026, 6, 15),
          ),
        ],
      ),
    ],
  );
}

// A fixed, minimal snapshot (one profile, no rows) whose exact bytes are the
// committed golden — the v1 format baseline a future app version must still read.
BackupSnapshot _minimalSnapshot() {
  const pid = ProfileId('p1');
  return BackupSnapshot(
    schemaVersion: kCurrentSchemaVersion,
    appVersion: '1.0.0',
    exportedAt: '2026-06-25',
    mushaf: const MushafRef(id: 'm', riwayah: 'r', name: 'n', checksumSha256: 'c'),
    profiles: <ProfileExport>[
      ProfileExport(
        profile: Profile(
          profileId: pid,
          displayName: 'a',
          role: ProfileRole.self,
          locale: ProfileLocale.ar,
          mushafId: 'm',
          createdAtInstant: DateTime.utc(2026), // 2026-01-01T00:00:00Z
        ),
        cycleConfig: const CycleConfig(
          profileId: pid,
          cycleType: '7_manzil',
          nearWindowJuz: 3,
          farTargetPerDay: 20,
          cycleCeilingDays: 7,
          dailyBudgetMinutes: 30,
          termLabelSet: 'classical',
        ),
        cards: const <Card>[],
        lineBlocks: const <LineBlock>[],
        reviewLog: const <ReviewLog>[],
        confusionEdges: const <ConfusionEdge>[],
      ),
    ],
  );
}

void main() {
  group('golden — the plaintext v1 format is byte-stable', () {
    // The exact bytes of export(_minimalSnapshot()), base64. An accidental format
    // change fails this; an intentional one regenerates the constant.
    const goldenBase64 =
        'SElGWkJLHwEBAAACNQAAAFu3G8Z2JTMf5GzS7XkhWyA+EuQ8mX6qegFOZzCDcWQVeyJhcHBWZXJzaW9uIjoiMS4wLjAiLCJleHBvcnRlZEF0IjoiMjAyNi0wNi0yNSIsIm11c2hhZiI6eyJjaGVja3N1bVNoYTI1NiI6ImMiLCJpZCI6Im0iLCJuYW1lIjoibiIsInJpd2F5YWgiOiJyIn0sInByb2ZpbGVzIjpbeyJjYXJkcyI6W10sImNvbmZ1c2lvbkVkZ2VzIjpbXSwiY3ljbGVDb25maWciOnsiY3ljbGVUeXBlIjoiN19tYW56aWwiLCJkYWlseUJ1ZGdldE1pbnV0ZXMiOjMwLCJmYXJDeWNsZURheXMiOjcsImZhclRhcmdldFBlckRheSI6MjAsIm5lYXJXaW5kb3dKdXoiOjMsIm5ld0xpbmVzUGVyRGF5IjowLCJwdXJlQ3ljbGVNb2RlIjpmYWxzZSwicmVnaW9uUHJlc2V0IjpudWxsLCJ0ZXJtTGFiZWxTZXQiOiJjbGFzc2ljYWwifSwibGluZUJsb2NrcyI6W10sInByb2ZpbGUiOnsiY3JlYXRlZEF0IjoiMjAyNi0wMS0wMVQwMDowMDowMC4wMDBaIiwiZGlzcGxheU5hbWUiOiJhIiwibG9jYWxlIjoiYXIiLCJtdXNoYWZJZCI6Im0iLCJyb2xlIjoic2VsZiIsInNldHRpbmdzSnNvbiI6bnVsbH0sInByb2ZpbGVJZCI6InAxIiwicmV2aWV3TG9nIjpbXX1dLCJzY2hlbWFWZXJzaW9uIjoyfQ==';

    test('export(minimal) matches the committed golden', () async {
      final actual = base64Encode(await HifzBackup.export(_minimalSnapshot()));
      expect(actual, goldenBase64);
    });
  });

  group('plaintext façade round-trip (§1/§3/§4/§5)', () {
    test('export → import restores every entity', () async {
      final snap = _sampleSnapshot();
      final restored = await HifzBackup.import(await HifzBackup.export(snap));
      final got = restored.profiles.single;
      final orig = snap.profiles.single;
      expect(got.profile, orig.profile);
      expect(got.cycleConfig, orig.cycleConfig);
      expect(got.cards, equals(orig.cards));
      expect(got.lineBlocks, equals(orig.lineBlocks));
      expect(got.reviewLog, equals(orig.reviewLog));
      expect(got.confusionEdges, equals(orig.confusionEdges));
      expect(restored.schemaVersion, kCurrentSchemaVersion);
      expect(restored.mushaf.checksumSha256, 'abc123');
    });

    test('the same snapshot exports to identical bytes (deterministic)', () async {
      final snap = _sampleSnapshot();
      expect(await HifzBackup.export(snap), equals(await HifzBackup.export(snap)));
    });
  });

  group('the §3 header on a real plaintext file', () {
    test('magic / separator / format / plaintext-mode / length / digest / body',
        () async {
      final snap = _sampleSnapshot();
      final file = await HifzBackup.export(snap);
      final body = Uint8List.fromList(encodeCanonicalJson(snapshotToJson(snap)));

      expect(file.sublist(0, 6), equals(<int>[0x48, 0x49, 0x46, 0x5A, 0x42, 0x4B]));
      expect(file[6], 0x1F);
      expect(file[7], 0x01); // format version
      expect(file[8], 0x01); // mode = plaintext
      expect(file.sublist(13, 16), equals(<int>[0, 0, 0])); // reserved

      final declaredLen = ByteData.sublistView(file).getUint32(9); // big-endian
      expect(declaredLen, body.length);
      expect(file.sublist(16, 48), equals(bodyDigest(body))); // §5 digest
      expect(file.sublist(48), equals(body)); // the canonical JSON body
    });
  });

  group('integrity (§5) — fail-closed before decode', () {
    test('a single flipped body byte ⇒ integrityFailed', () async {
      final file = await HifzBackup.export(_sampleSnapshot());
      file[48] = file[48] ^ 0x01; // flip one bit of the first body byte
      expect(
        HifzBackup.import(file),
        throwsA(
          isA<BackupException>().having(
            (e) => e.error,
            'error',
            BackupError.integrityFailed,
          ),
        ),
      );
    });

    test('a flipped digest byte ⇒ integrityFailed', () async {
      final file = await HifzBackup.export(_sampleSnapshot());
      file[16] = file[16] ^ 0x01; // corrupt the stored digest
      expect(
        HifzBackup.import(file),
        throwsA(
          isA<BackupException>().having(
            (e) => e.error,
            'error',
            BackupError.integrityFailed,
          ),
        ),
      );
    });
  });

  group('truncation', () {
    Future<BackupError> errorOf(Uint8List file) async {
      try {
        await HifzBackup.import(file);
      } on BackupException catch (e) {
        return e.error;
      }
      throw StateError('expected a BackupException');
    }

    test('below the 49-byte minimum ⇒ notAHifzBackup', () async {
      final file = await HifzBackup.export(_sampleSnapshot());
      expect(await errorOf(Uint8List.sublistView(file, 0, 40)), BackupError.notAHifzBackup);
    });

    test('a clipped tail (declared length no longer matches) ⇒ notAHifzBackup', () async {
      final file = await HifzBackup.export(_sampleSnapshot());
      final clipped = Uint8List.sublistView(file, 0, file.length - 1);
      expect(await errorOf(clipped), BackupError.notAHifzBackup);
    });
  });
}
