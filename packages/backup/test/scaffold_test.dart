// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E17-T01 — the `backup/` package scaffold: the public value-model + enum
// surface compiles and is shaped per domain-backup-format §1/§3/§4. The codec
// itself (container/payload/integrity/envelope) lands test-first in E17-T02..T05.

import 'package:backup/backup.dart';
import 'package:test/test.dart';

void main() {
  group('backup scaffold (E17-T01)', () {
    test('BackupMode has exactly the two container modes (§2/§3)', () {
      expect(BackupMode.values, hasLength(2));
      expect(
        BackupMode.values,
        containsAll(<BackupMode>[
          BackupMode.plaintextJson,
          BackupMode.encryptedJson,
        ]),
      );
    });

    test('BackupError enumerates the six normative parse-order failures (§3)', () {
      expect(
        BackupError.values.map((e) => e.name),
        containsAll(<String>[
          'notAHifzBackup',
          'newerFormat',
          'unknownMode',
          'integrityFailed',
          'wrongPasswordOrDamaged',
          'malformedPayload',
        ]),
      );
    });

    test('BackupException carries one typed error and names it (§1)', () {
      const e = BackupException(BackupError.integrityFailed);
      expect(e.error, BackupError.integrityFailed);
      expect(e.toString(), 'BackupException(integrityFailed)');
    });

    test('BackupSnapshot holds the version stamp, muṣḥaf ref, and profiles', () {
      const snap = BackupSnapshot(
        schemaVersion: 2,
        appVersion: '0.0.0',
        exportedAt: '2026-06-25',
        mushaf: MushafRef(
          id: 'kfgqpc_hafs_madani_v2',
          riwayah: 'Ḥafṣ ʿan ʿĀṣim',
          name: 'Madani muṣḥaf',
          checksumSha256: '',
        ),
        profiles: <ProfileExport>[],
      );
      expect(snap.schemaVersion, 2);
      expect(snap.exportedAt, '2026-06-25');
      expect(snap.mushaf.id, 'kfgqpc_hafs_madani_v2');
      expect(snap.mushaf.riwayah, 'Ḥafṣ ʿan ʿĀṣim');
      expect(snap.profiles, isEmpty);
    });
  });
}
