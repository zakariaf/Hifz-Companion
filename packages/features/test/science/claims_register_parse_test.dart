// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/src/design_system/certainty/evidence_grade.dart';
import 'package:features/src/science/claim_row.dart';
import 'package:features/src/science/claims_register.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  group('parseClaimsRegister — the bundled register', () {
    test('parses every row with a non-empty grade and source list', () {
      final rows = claimsRegister;
      expect(rows, isNotEmpty);
      for (final row in rows) {
        expect(row.id, startsWith('C-'), reason: '${row.id} id shape');
        expect(row.grades, isNotEmpty, reason: '${row.id} has a grade');
        expect(row.sources, isNotEmpty, reason: '${row.id} has a source');
        for (final s in row.sources) {
          expect(s.label, isNotEmpty, reason: '${row.id} source label');
        }
      }
    });

    test('every claim id is unique', () {
      final ids = claimsRegister.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('the parser accepts every grade tag in the legend', () {
      // "covering every grade": the parser maps each of the seven legend tags.
      for (final grade in EvidenceGrade.values) {
        final tag = grade.name.toUpperCase();
        final json = '{"version":1,"claims":[{"id":"C-900","group":"A",'
            '"grades":["$tag"],"sources":[{"label":"x"}]}]}';
        expect(parseClaimsRegister(json).single.grades, [grade],
            reason: 'grade tag "$tag" parses to $grade',);
      }
    });

    test('the register spans the empirical + traditional grades it uses', () {
      final used = {
        for (final row in claimsRegister) ...row.grades,
      };
      // The legend lists [RCT] but no Hifz claim rests on a randomized trial;
      // the register spans the other six grades.
      expect(
        used,
        containsAll(const [
          EvidenceGrade.ma,
          EvidenceGrade.exp,
          EvidenceGrade.cs,
          EvidenceGrade.obs,
          EvidenceGrade.text,
          EvidenceGrade.trad,
        ]),
      );
      expect(EvidenceGrade.values, containsAll(used),
          reason: 'every used grade is a valid legend grade',);
    });

    test('a [TRAD] row carries its collection + number as on-device text', () {
      final decay = claimsRegister.firstWhere((r) => r.id == 'C-035');
      expect(decay.grades, contains(EvidenceGrade.trad));
      expect(decay.needsScholarlyReview, isTrue);
      expect(
        decay.sources.first.label,
        contains('5032'),
        reason: 'hadith cited by collection + number',
      );
      expect(decay.sources.first.label, contains('Bukhārī'));
    });

    test('C-048 TRAD-equivalent project rule loads as a trad row, no URL', () {
      final offline = claimsRegister.firstWhere((r) => r.id == 'C-048');
      expect(offline.grades, [EvidenceGrade.trad]);
      expect(offline.sources.single.url, isNull,
          reason: 'a project-rule source has no external link',);
    });

    test('groups resolve and are queryable in A–J order', () {
      expect(claimGroupsInRegister, isNotEmpty);
      // Grouping is total: every row belongs to a queried group.
      final grouped = {
        for (final g in claimGroupsInRegister) ...claimsForGroup(g).map((r) => r.id),
      };
      expect(grouped.length, claimsRegister.length);
    });
  });

  group('parseClaimsRegister — register-integrity defects throw loudly', () {
    test('unknown grade tag throws EvidenceGradeFormatException', () {
      const bad = '{"version":1,"claims":[{"id":"C-900","group":"A",'
          '"grades":["WAT"],"sources":[{"label":"x"}]}]}';
      expect(
        () => parseClaimsRegister(bad),
        throwsA(isA<EvidenceGradeFormatException>()),
      );
    });

    test('empty grade list throws', () {
      const bad = '{"version":1,"claims":[{"id":"C-900","group":"A",'
          '"grades":[],"sources":[{"label":"x"}]}]}';
      expect(() => parseClaimsRegister(bad),
          throwsA(isA<ClaimRegisterFormatException>()),);
    });

    test('empty source list throws', () {
      const bad = '{"version":1,"claims":[{"id":"C-900","group":"A",'
          '"grades":["MA"],"sources":[]}]}';
      expect(() => parseClaimsRegister(bad),
          throwsA(isA<ClaimRegisterFormatException>()),);
    });

    test('missing id throws', () {
      const bad = '{"version":1,"claims":[{"group":"A",'
          '"grades":["MA"],"sources":[{"label":"x"}]}]}';
      expect(() => parseClaimsRegister(bad),
          throwsA(isA<ClaimRegisterFormatException>()),);
    });

    test('unknown group throws', () {
      const bad = '{"version":1,"claims":[{"id":"C-900","group":"Z",'
          '"grades":["MA"],"sources":[{"label":"x"}]}]}';
      expect(() => parseClaimsRegister(bad),
          throwsA(isA<ClaimRegisterFormatException>()),);
    });

    test('duplicate id throws', () {
      const bad = '{"version":1,"claims":['
          '{"id":"C-900","group":"A","grades":["MA"],"sources":[{"label":"x"}]},'
          '{"id":"C-900","group":"B","grades":["CS"],"sources":[{"label":"y"}]}]}';
      expect(() => parseClaimsRegister(bad),
          throwsA(isA<ClaimRegisterFormatException>()),);
    });

    test('non-JSON throws', () {
      expect(() => parseClaimsRegister('not json'),
          throwsA(isA<ClaimRegisterFormatException>()),);
    });
  });
}
