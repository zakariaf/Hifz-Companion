// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E09-T09 — the swappable term-sets are ICU select-over-region entries whose
// region branches must agree across locales and always carry an `other`
// fallback (a missing branch crashes at runtime). Provisional ckb flagging and
// canonical encoding are asserted too. Parses the committed ARBs; offline.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

const _termSetKeys = <String>[
  'trackNewSabaq',
  'trackNearSabqi',
  'trackFarManzil',
  'trackRevisionGeneral',
  'gradeAgainVerb',
  'gradeHardVerb',
  'gradeGoodVerb',
  'gradeEasyVerb',
  'cycleWeeklyKhatm',
  'cycleOneJuzPerDay',
  'cycleHalfJuzPerDay',
  'cycleTwoJuzPerDay',
  'cycleCustom',
  'cyclePureMode',
];

/// The top-level branch labels of an ICU `select` message (brace-depth aware).
Set<String> selectBranches(String message) {
  final selector = RegExp(r'\{\s*\w+\s*,\s*select\s*,').firstMatch(message);
  if (selector == null) return const <String>{};
  final branches = <String>{};
  final label = RegExp(r'^\s*(\w+)\s*\{');
  var depth = 1;
  var i = selector.end;
  while (i < message.length && depth > 0) {
    final char = message[i];
    if (char == '}') {
      depth--;
      i++;
      continue;
    }
    if (char == '{') {
      depth++;
      i++;
      continue;
    }
    if (depth == 1) {
      final match = label.firstMatch(message.substring(i));
      if (match != null) {
        branches.add(match.group(1)!);
        i += match.end - 1;
        continue;
      }
    }
    i++;
  }
  return branches;
}

Map<String, dynamic> _arb(String locale) => jsonDecode(
      File('packages/l10n/lib/src/arb/app_$locale.arb').readAsStringSync(),
    ) as Map<String, dynamic>;

void main() {
  useOfflineTestPolicy();

  final ar = _arb('ar');
  final fa = _arb('fa');
  final ckb = _arb('ckb');

  test('every term-set key is a select with an `other` branch in all 3 locales',
      () {
    for (final key in _termSetKeys) {
      for (final entry in <(String, Map<String, dynamic>)>[
        ('ar', ar),
        ('fa', fa),
        ('ckb', ckb),
      ]) {
        final branches = selectBranches(entry.$2[key] as String);
        expect(
          branches,
          isNotEmpty,
          reason: '$key [${entry.$1}] is not a select',
        );
        expect(
          branches,
          contains('other'),
          reason: '$key [${entry.$1}] missing the `other` fallback',
        );
      }
    }
  });

  test('region branches agree across locales (no locale omits a branch)', () {
    for (final key in _termSetKeys) {
      final arBranches = selectBranches(ar[key] as String);
      expect(selectBranches(fa[key] as String), arBranches, reason: 'fa: $key');
      expect(
        selectBranches(ckb[key] as String),
        arBranches,
        reason: 'ckb: $key',
      );
    }
    // trackFarManzil is the region-varying one (manzil vs dhor).
    expect(
      selectBranches(ar['trackFarManzil'] as String),
      <String>{'levant', 'subcontinent', 'other'},
    );
  });

  test('every term-set @description flags NEEDS scholar review', () {
    for (final key in _termSetKeys) {
      final meta = ar['@$key'] as Map<String, dynamic>;
      expect(
        meta['description'] as String,
        contains('NEEDS scholar review'),
        reason: key,
      );
    }
  });

  test('ckb term-set values are canonically encoded (no ZWNJ / Teh-Marbuta)',
      () {
    const zwnj = 0x200C;
    const tehMarbuta = 0x0629;
    for (final key in _termSetKeys) {
      final value = ckb[key] as String;
      expect(value.runes.contains(zwnj), isFalse, reason: 'ZWNJ in ckb $key');
      expect(
        value.runes.contains(tehMarbuta),
        isFalse,
        reason: 'Teh-Marbuta in ckb $key',
      );
    }
  });
}
