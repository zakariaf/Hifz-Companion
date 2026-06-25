// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['crypto'])
library;

// E17-T05 — the §6 encryption envelope, test-first: an Argon2id→ChaCha20-Poly1305
// round-trip across emoji / CJK / combining-mark passphrases, the single
// indistinguishable wrongPasswordOrDamaged on a bad key, integrity catching a
// corrupted ciphertext before any decrypt, and the Argon2 param clamp. Tagged
// `crypto` (real 64 MiB Argon2id is deliberately slow; timezone-independent, so
// the date-matrix skips it).

import 'package:backup/backup.dart';
import 'package:backup/src/envelope.dart';
import 'package:models/models.dart';
import 'package:test/test.dart';

BackupSnapshot _snapshot() {
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
          displayName: 'علي',
          role: ProfileRole.self,
          locale: ProfileLocale.ar,
          mushafId: 'm',
          createdAtInstant: DateTime.utc(2026),
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
        lineBlocks: const <LineBlock>[],
        reviewLog: <ReviewLog>[
          ReviewLog(
            logId: const LogId('log-1'),
            profileId: pid,
            pageId: 42,
            reviewedAtInstant: DateTime.utc(2026, 6, 20, 6, 15),
            trackAtReview: ReviewTrack.far,
            grade: ReviewGrade.good,
            elapsedDays: 11,
            source: GradeSource.teacher,
            teacherLabel: 'Ustadh',
          ),
        ],
        confusionEdges: const <ConfusionEdge>[],
      ),
    ],
  );
}

void main() {
  group('encrypted round-trip (§6) — passphrase scripts', () {
    for (final pp in <String>['hunter2', '🔑🗝️🤲', '密码パスワード', 'ákalimaّ']) {
      test('round-trips under passphrase "${pp.runes.length} runes"', () async {
        final snap = _snapshot();
        final file = await HifzBackup.export(snap, passphrase: pp);
        expect(file[8], 0x02); // mode = encrypted
        final restored = await HifzBackup.import(file, passphrase: pp);
        expect(restored.profiles.single.cards, equals(snap.profiles.single.cards));
        expect(
          restored.profiles.single.reviewLog,
          equals(snap.profiles.single.reviewLog),
        );
        expect(restored.profiles.single.profile, snap.profiles.single.profile);
      });
    }

    test('plaintext default stays mode 0x01; each encrypted export differs', () async {
      final snap = _snapshot();
      expect((await HifzBackup.export(snap))[8], 0x01);
      // Fresh salt + nonce per export ⇒ two ciphertexts differ, both decrypt.
      final a = await HifzBackup.export(snap, passphrase: 'pw');
      final b = await HifzBackup.export(snap, passphrase: 'pw');
      expect(a, isNot(equals(b)));
    });
  });

  group('the indistinguishable failure (§6)', () {
    Future<BackupError> errorOf(Future<void> Function() op) async {
      try {
        await op();
      } on BackupException catch (e) {
        return e.error;
      }
      throw StateError('expected a BackupException');
    }

    test('a wrong passphrase ⇒ wrongPasswordOrDamaged', () async {
      final file = await HifzBackup.export(_snapshot(), passphrase: 'right');
      expect(
        await errorOf(() => HifzBackup.import(file, passphrase: 'wrong')),
        BackupError.wrongPasswordOrDamaged,
      );
    });

    test('an encrypted file imported with no passphrase ⇒ wrongPasswordOrDamaged',
        () async {
      final file = await HifzBackup.export(_snapshot(), passphrase: 'pw');
      expect(
        await errorOf(() => HifzBackup.import(file)),
        BackupError.wrongPasswordOrDamaged,
      );
    });

    test('a corrupted ciphertext ⇒ integrityFailed (SHA before AEAD)', () async {
      final file = await HifzBackup.export(_snapshot(), passphrase: 'pw');
      file[file.length - 1] = file[file.length - 1] ^ 0x01; // flip a tag byte
      expect(
        await errorOf(() => HifzBackup.import(file, passphrase: 'pw')),
        BackupError.integrityFailed,
      );
    });
  });

  group('Argon2 param clamp (§6) — the KDF only sees in-range params', () {
    test('memory clamps to [19456, 1048576]', () {
      expect(clampArgon2Memory(1), kArgon2MemoryMin);
      expect(clampArgon2Memory(1 << 30), kArgon2MemoryMax); // a hostile huge value
      expect(clampArgon2Memory(65536), 65536); // in range, unchanged
    });

    test('iterations clamp to [1, 16]', () {
      expect(clampArgon2Iterations(0), kArgon2IterationsMin);
      expect(clampArgon2Iterations(1000000), kArgon2IterationsMax);
      expect(clampArgon2Iterations(3), 3);
    });

    test('parallelism clamps to [1, 16] (a hostile lane count is bounded)', () {
      expect(clampArgon2Parallelism(0), kArgon2ParallelismMin);
      expect(clampArgon2Parallelism(255), kArgon2ParallelismMax);
      expect(clampArgon2Parallelism(1), 1);
    });
  });
}
