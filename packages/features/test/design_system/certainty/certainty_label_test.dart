// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T06 — the correctness-critical pure mapping: certaintyLabel over all seven
// grades (rct/exp share a phrase), EvidenceGrade.parse round-trips + throws on an
// unknown tag, and no real phrase leaks a star/percentage/ASCII digit.

import 'package:features/features.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/offline_test_bootstrap.dart';

const _fixture = CertaintyStrings(
  ma: 'ma-phrase',
  rctExp: 'rctexp-phrase',
  cs: 'cs-phrase',
  obs: 'obs-phrase',
  text: 'text-phrase',
  trad: 'trad-phrase',
  semanticPrefix: 'evidence: ',
);

void main() {
  useOfflineTestPolicy();

  group('certaintyLabel — pure mapping over all seven grades', () {
    test('each grade returns its phrase; rct and exp share one', () {
      expect(certaintyLabel(EvidenceGrade.ma, _fixture), 'ma-phrase');
      expect(certaintyLabel(EvidenceGrade.rct, _fixture), 'rctexp-phrase');
      expect(certaintyLabel(EvidenceGrade.exp, _fixture), 'rctexp-phrase');
      expect(certaintyLabel(EvidenceGrade.cs, _fixture), 'cs-phrase');
      expect(certaintyLabel(EvidenceGrade.obs, _fixture), 'obs-phrase');
      expect(certaintyLabel(EvidenceGrade.text, _fixture), 'text-phrase');
      expect(certaintyLabel(EvidenceGrade.trad, _fixture), 'trad-phrase');
    });

    test('it is total — a value exists for every grade', () {
      for (final grade in EvidenceGrade.values) {
        expect(certaintyLabel(grade, _fixture), isNotEmpty);
      }
    });
  });

  group('EvidenceGrade.parse', () {
    test('round-trips every tag form to the right grade', () {
      expect(EvidenceGrade.parse('[MA]'), EvidenceGrade.ma);
      expect(EvidenceGrade.parse('MA'), EvidenceGrade.ma);
      expect(EvidenceGrade.parse(' ma '), EvidenceGrade.ma);
      expect(EvidenceGrade.parse('[TRAD]'), EvidenceGrade.trad);
    });

    test('an unknown or empty tag throws the typed register-integrity error',
        () {
      expect(
        () => EvidenceGrade.parse('[XYZ]'),
        throwsA(isA<EvidenceGradeFormatException>()),
      );
      expect(
        () => EvidenceGrade.parse(''),
        throwsA(isA<EvidenceGradeFormatException>()),
      );
    });

    test('trad is last and not ranked above the empirical grades', () {
      expect(EvidenceGrade.values.last, EvidenceGrade.trad);
      expect(EvidenceGrade.values.first, EvidenceGrade.ma);
    });
  });

  test('no real phrase leaks a star, percentage, or ASCII digit', () async {
    for (final locale in const [Locale('ar'), Locale('fa'), Locale('ckb')]) {
      final l10n = await AppLocalizations.delegate.load(locale);
      final strings = CertaintyStrings.of(l10n);
      for (final grade in EvidenceGrade.values) {
        final phrase = certaintyLabel(grade, strings);
        expect(phrase.contains('★'), isFalse, reason: 'no star rating');
        expect(
          phrase.contains('%'),
          isFalse,
          reason: 'no confidence percentage',
        );
        expect(RegExp(r'[0-9]').hasMatch(phrase), isFalse, reason: 'no digit');
      }
    }
  });
}
