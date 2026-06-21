// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Unit suite for the canonical-Sorani encoding lint (E09-T03; design 12 §7).
// Drives the pure scan over inline fixtures (no file I/O) and proves the
// committed app_ckb.arb is itself canonical. Plain `package:test`, offline.

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../check_ckb_canonical.dart';

void main() {
  // Canonical Sorani: U+06D5 (ە) AE, U+06A9 (ک) kaf.
  const canonical = 'پاشەکەوت'; // پ ا ش ە ک ە و ت
  const zwnj = '‌';
  const tehMarbuta = 'ة'; // ة
  const arabicKaf = 'ك'; // ك
  const hehHamza = 'ۀ'; // ۀ

  test('a clean canonical value has no violations', () {
    expect(scanValue('k', canonical), isEmpty);
  });

  test('a stray ZWNJ is flagged with key, offset, and reason', () {
    final v = scanValue('okExportLabel', 'پاش$zwnjەکەوت');
    expect(v, hasLength(1));
    expect(v.single.key, 'okExportLabel');
    expect(v.single.codePoint, 0x200C);
    expect(v.single.offset, 3);
    expect(v.single.reason, contains('ZWNJ'));
  });

  test('Teh-Marbuta standing for AE is flagged', () {
    final v = scanValue('k', 'پاش$tehMarbutaکەوت');
    expect(v.single.codePoint, 0x0629);
    expect(v.single.reason, contains('AE'));
  });

  test('Arabic kaf (U+0643) is flagged as non-canonical', () {
    final v = scanValue('k', 'پاشە$arabicKafەوت');
    expect(v.single.codePoint, 0x0643);
    expect(v.single.reason, contains('U+06A9'));
  });

  test('the heh-with-hamza AE hack (U+06C0) is flagged', () {
    expect(scanValue('k', 'پاش$hehHamzaکەوت').single.codePoint, 0x06C0);
  });

  test('@-metadata keys are skipped', () {
    final arb = <String, dynamic>{
      '@@locale': 'ckb',
      'k': canonical,
      '@k': {'description': 'contains $zwnj a ZWNJ but is metadata'},
    };
    expect(scanArb(arb), isEmpty);
  });

  test('the committed app_ckb.arb is canonical (zero violations)', () {
    final file = File('packages/l10n/lib/src/arb/app_ckb.arb');
    final arb = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    expect(
      scanArb(arb),
      isEmpty,
      reason: 'the shipped Sorani ARB must be canonically encoded',
    );
  });
}
