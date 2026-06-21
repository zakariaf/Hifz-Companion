// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Test-first suite for the Arabic six-category plural-completeness check
// (E09-T07; engineering 12 §6). The deliberate-incomplete-plural case is the
// core: a plural missing few/many must be reported. Plain `package:test`,
// offline, in-memory fixtures.

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../check_arb_plurals.dart';

// A complete six-category Arabic plural (the engineering 12 §1/§6 shape).
const _complete = '{count, plural, '
    'zero{لا صفحات} one{صفحة واحدة} two{صفحتان} '
    'few{{count} صفحات} many{{count} صفحة} other{{count} صفحة}}';

List<PluralCompletenessViolation> lint(Map<String, String> values) =>
    lintArbPlurals(<String, dynamic>{'@@locale': 'ar', ...values}, 'ar');

void main() {
  test('an incomplete plural (missing few/many) is reported', () {
    final v = lint({
      'pagesDue': '{count, plural, zero{لا} one{واحد} two{اثنان} other{كثير}}',
    });
    expect(v, hasLength(1));
    expect(v.single.offendingKey, 'pagesDue');
    expect(v.single.missingCategories, <String>{'few', 'many'});
  });

  test('a complete six-category plural passes', () {
    expect(lint({'pagesDue': _complete}), isEmpty);
  });

  test('each single missing category is caught precisely', () {
    for (final omit in requiredArabicCategories) {
      final body = requiredArabicCategories
          .where((c) => c != omit)
          .map((c) => '$c{x}')
          .join(' ');
      final v = lint({'k': '{count, plural, $body}'});
      expect(v.single.missingCategories, <String>{omit}, reason: 'omit $omit');
    }
  });

  test('non-plural values are ignored (plain string and a select)', () {
    final v = lint({
      'title': 'الأجزاء التي تحفظها',
      'trackFar': '{region, select, levant{منزل} other{منزل}}',
    });
    expect(v, isEmpty);
  });

  test('=N exact forms do not substitute a category', () {
    final v = lint({'k': '{count, plural, =0{صفر} one{واحد} other{كثير}}'});
    // =0 is additive, not a `zero` category; two/few/many/zero still missing.
    expect(v.single.missingCategories, <String>{'zero', 'two', 'few', 'many'});
  });

  test('a nested {count} placeholder is not parsed as a category', () {
    // few{{count} صفحات} must not register an empty/`count` label — _complete
    // has nested placeholders in few/many/other and still passes.
    expect(lint({'pagesDue': _complete}), isEmpty);
  });

  test('an ARB with no plural message exits clean', () {
    expect(lint({'a': 'نص', 'b': 'نص آخر'}), isEmpty);
  });

  test('the committed app_ar.arb has only complete Arabic plurals', () {
    final file = File('packages/l10n/lib/src/arb/app_ar.arb');
    final arb = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    expect(lintArbPlurals(arb, 'ar'), isEmpty);
  });
}
