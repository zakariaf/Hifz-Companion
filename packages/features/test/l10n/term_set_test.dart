// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E09-T09 — the presentation-layer term-set resolver maps the engine enums to
// the active term-set's localized words; switching region changes only the
// surface word (far-revision manzil vs dhor), never the engine signal.

import 'package:engine/engine.dart' show ReviewGrade, ReviewTrack;
import 'package:features/features.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  Future<AppLocalizations> load(String code) =>
      AppLocalizations.delegate.load(Locale(code));

  test('gradeVerb maps each ReviewGrade to the ar term-set verb', () async {
    final l10n = await load('ar');
    const r = kDefaultTermSetRegion;
    expect(gradeVerb(l10n, ReviewGrade.again, r), 'احتجت مساعدة');
    expect(gradeVerb(l10n, ReviewGrade.hard, r), 'أخطاء يسيرة');
    expect(gradeVerb(l10n, ReviewGrade.good, r), 'تلاوة سليمة');
    expect(gradeVerb(l10n, ReviewGrade.easy, r), 'بيُسر');
  });

  test('gradeVerb transcreates per locale (fa/ckb differ from ar)', () async {
    final arL = await load('ar');
    final faL = await load('fa');
    final ckbL = await load('ckb');
    for (final grade in ReviewGrade.values) {
      final a = gradeVerb(arL, grade, kDefaultTermSetRegion);
      final f = gradeVerb(faL, grade, kDefaultTermSetRegion);
      final c = gradeVerb(ckbL, grade, kDefaultTermSetRegion);
      expect(f, isNot(a), reason: 'fa $grade should not fall back to ar');
      expect(c, isNot(a), reason: 'ckb $grade should not fall back to ar');
    }
  });

  test('trackLabel: switching region changes the far-revision word', () async {
    final l10n = await load('ar');
    // The track (far) is identical; only the region key changes the word.
    expect(trackLabel(l10n, ReviewTrack.far, 'levant'), 'منزل');
    expect(trackLabel(l10n, ReviewTrack.far, 'subcontinent'), 'دور');
    // A non-region-varying track falls through to `other` for any region.
    expect(
      trackLabel(l10n, ReviewTrack.newPage, 'levant'),
      trackLabel(l10n, ReviewTrack.newPage, kDefaultTermSetRegion),
    );
  });

  test('unmemorized shares the New-lesson label', () async {
    final l10n = await load('ar');
    expect(
      trackLabel(l10n, ReviewTrack.unmemorized, kDefaultTermSetRegion),
      trackLabel(l10n, ReviewTrack.newPage, kDefaultTermSetRegion),
    );
  });
}
