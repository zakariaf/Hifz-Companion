// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E14-T11: every Mutashābihāt trainer string is transcreated (not fallback) into
// fa AND ckb, and every value passes the adab conscience-check banned-phrase
// scan in all three locales. Deterministic — reads the bundled ARB only.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String locale) => jsonDecode(
      File('packages/l10n/lib/src/arb/app_$locale.arb').readAsStringSync(),
    ) as Map<String, dynamic>;

// The trainer's user-facing keys (E14-T07/T08/T10) that T11 transcreates.
const _trainerKeys = <String>[
  'navMutashabihat',
  'mutashabihatTrainerIntro',
  'mutashabihatDrillReveal',
  'mutashabihatDrillProgress',
  'mutashabihatDrillNext',
  'mutashabihatDrillComplete',
  'mutashabihTypeIdentical',
  'mutashabihTypeNearIdentical',
  'mutashabihTypeStructural',
  'ayahRefLabel',
  'mutashabihatHotspotSemantic',
  'commonBack',
];

// Adab / voice never-ship tokens that must not appear in any trainer string.
const _bannedSubstrings = <String>[
  'cured',
  'resolved',
  'mastered',
  'safe to drop',
  'safe to stop',
  'streak',
  'score',
  'badge',
  'leaderboard',
  '!',
];

void main() {
  final ar = _arb('ar');
  final fa = _arb('fa');
  final ckb = _arb('ckb');

  String value(Map<String, dynamic> arb, String key) {
    expect(arb[key], isA<String>(), reason: 'missing "$key"');
    final v = (arb[key] as String).trim();
    expect(v, isNotEmpty, reason: '"$key" is empty');
    return v;
  }

  test('every trainer key is present and non-empty in ar, fa, and ckb', () {
    for (final key in _trainerKeys) {
      value(ar, key);
      value(fa, key);
      value(ckb, key);
    }
  });

  test('fa and ckb are transcreated, not a silent ar fallback', () {
    for (final key in _trainerKeys) {
      expect(fa[key], isNot(ar[key]), reason: 'fa "$key" not transcreated');
      expect(ckb[key], isNot(ar[key]), reason: 'ckb "$key" not transcreated');
    }
  });

  test('no trainer string carries a banned adab/voice token (ar, fa, ckb)', () {
    for (final arb in [ar, fa, ckb]) {
      for (final key in _trainerKeys) {
        final lower = value(arb, key).toLowerCase();
        for (final banned in _bannedSubstrings) {
          expect(
            lower.contains(banned),
            isFalse,
            reason: '"$key" has "$banned"',
          );
        }
      }
    }
  });

  test('the trainer surfaces no on-screen number (no ASCII digit literal)', () {
    final digits = RegExp(r'[0-9]');
    for (final arb in [ar, fa, ckb]) {
      for (final key in _trainerKeys) {
        expect(
          digits.hasMatch(value(arb, key)),
          isFalse,
          reason: '"$key" bakes an ASCII digit',
        );
      }
    }
  });
}
