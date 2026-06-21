// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Unit suite for the banned-phrase (adab) lint (E09-T02; design 11 §9; PRD §20
// gate 5). One case per never-ship class asserts a crafted offending value is
// flagged with the right rule + locale, a clean value passes, and an empty ARB
// exits with no violations. Plain `package:test` — no widget binding, offline.

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../check_adab_lint.dart';

void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('adab_lint_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  /// Writes an `app_<locale>.arb` with [values] and returns its path.
  String writeArb(String locale, Map<String, String> values) {
    final file = File('${tmp.path}/app_$locale.arb');
    file.writeAsStringSync(
      jsonEncode(<String, dynamic>{
        '@@locale': locale,
        ...values,
      }),
    );
    return file.path;
  }

  List<AdabViolation> lint(String path) => lintRoots(<String>[path]);

  test('exclamation mark is flagged', () {
    final v = lint(writeArb('ar', {'k': 'أحسنت!'}));
    expect(v, hasLength(1));
    expect(v.single.rule, AdabRule.exclamationOrEmoji);
    expect(v.single.key, 'k');
    expect(v.single.locale, 'ar');
  });

  test('emoji is flagged', () {
    final v = lint(writeArb('fa', {'k': 'آفرین ✨'}));
    expect(v.map((e) => e.rule), contains(AdabRule.exclamationOrEmoji));
  });

  test('em-dash and locale digits are NOT flagged as emoji', () {
    // Guards the emoji ranges against the em-dash (U+2014) in mushafRiwayahLabel
    // and the Arabic/Persian digit blocks.
    final v = lint(writeArb('ar', {'k': 'حفص — ٣٤ ۵۶'}));
    expect(v, isEmpty);
  });

  test('English mandate "you must" is flagged', () {
    final v = lint(writeArb('ar', {'k': 'you must revise'}));
    expect(v.single.rule, AdabRule.mandate);
  });

  test('Persian mandate باید is flagged in fa, not in ar', () {
    expect(
      lint(writeArb('fa', {'k': 'باید مرور کنید'})).single.rule,
      AdabRule.mandate,
    );
    // Same string under the ar locale: the fa-scoped pattern must not fire.
    expect(lint(writeArb('ar', {'k': 'باید مرور کنید'})), isEmpty);
  });

  test('ckb mandate دەبێت is flagged in ckb', () {
    final v = lint(writeArb('ckb', {'k': 'دەبێت بیخوێنیتەوە'}));
    expect(v.single.rule, AdabRule.mandate);
  });

  test('guilt/streak framing is flagged', () {
    expect(
      lint(writeArb('ar', {'k': 'keep your streak'})).single.rule,
      AdabRule.guiltFearLossStreak,
    );
  });

  test('forbidden verdict "safe to drop" is flagged', () {
    expect(
      lint(writeArb('ar', {'k': 'this page is safe to drop'})).single.rule,
      AdabRule.forbiddenVerdict,
    );
  });

  test('commercial word "upgrade" is flagged', () {
    expect(
      lint(writeArb('ar', {'k': 'upgrade to premium'})).map((e) => e.rule),
      everyElement(AdabRule.commercial),
    );
  });

  test('a clean, calm value passes', () {
    final v = lint(
      writeArb('fa', {
        'k1': 'صفحهٔ مرور شما آماده است',
        'k2': 'این بخش در حال آماده‌سازی است.',
      }),
    );
    expect(v, isEmpty);
  });

  test('@-metadata keys are ignored (only user values are scanned)', () {
    // A banned word in an @description must not trip the lint — it is not copy.
    final file = File('${tmp.path}/app_ar.arb');
    file.writeAsStringSync(
      jsonEncode(<String, dynamic>{
        '@@locale': 'ar',
        'k': 'مرحبا',
        '@k': {'description': 'shown when you must upgrade to premium streak'},
      }),
    );
    expect(lint(file.path), isEmpty);
  });

  test('an empty ARB produces no violations', () {
    expect(lint(writeArb('ar', const {})), isEmpty);
  });
}
