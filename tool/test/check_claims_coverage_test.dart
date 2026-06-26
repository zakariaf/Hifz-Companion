// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Unit suite for the grade-coverage / no-orphan-claim gate (E19-T02). Feeds
// deliberate doc↔register mismatches and asserts each is caught.

import 'package:test/test.dart';

import '../check_claims_coverage.dart';

const String _docTwoRows = '''
Intro prose may mention (C-016) inline — that is not a table row.

| ID | Claim | Value | Source(s) | Grade | App surface | Notes |
|---|---|---|---|---|---|---|
| C-001 | fades ([Murre, 2015](https://x)) | premise | ([Ebbinghaus](https://y)) | [EXP] / [CS] | Science | n |
| C-035 | keep reciting | decay axiom | (Bukhari) | [TRAD] | Science | hadith |
''';

String _register(String claimsJson) => "r'''\n$claimsJson\n'''";

void main() {
  group('extractRegisterJson', () {
    test('pulls the JSON out of the raw-string literal', () {
      final src = "const x = ${_register('{"v":1}')};";
      expect(extractRegisterJson(src).trim(), '{"v":1}');
    });
  });

  group('docGrades', () {
    test('reads only table rows and the Grade column, ignoring link brackets',
        () {
      final grades = docGrades(_docTwoRows);
      expect(grades.keys, containsAll(['C-001', 'C-035']));
      // [Murre, 2015] / [Ebbinghaus] markdown links must NOT leak in as grades.
      expect(grades['C-001'], {'exp', 'cs'});
      expect(grades['C-035'], {'trad'});
    });

    test('reduces "[TRAD-equivalent project rule]" to {trad}', () {
      const md = '| ID | C | V | S | Grade | A | N |\n'
          '| C-048 | offline | rule | (design) | [TRAD-equivalent project rule] | S | n |';
      expect(docGrades(md)['C-048'], {'trad'});
    });
  });

  group('checkClaimsCoverage', () {
    String matchingRegister() => _register('''
{"version":1,"claims":[
  {"id":"C-001","group":"A","grades":["EXP","CS"],"sources":[{"label":"a"}]},
  {"id":"C-035","group":"H","grades":["TRAD"],"sources":[{"label":"b"}]}
]}''');

    List<String> run(String registerLiteral) => checkClaimsCoverage(
          claimsMarkdown: _docTwoRows,
          registerJson: extractRegisterJson(registerLiteral),
        );

    test('a faithful projection has no violations', () {
      expect(run(matchingRegister()), isEmpty);
    });

    test('an orphan rendered claim (in register, not in doc) is caught', () {
      final reg = _register('''
{"version":1,"claims":[
  {"id":"C-001","group":"A","grades":["EXP","CS"],"sources":[{"label":"a"}]},
  {"id":"C-035","group":"H","grades":["TRAD"],"sources":[{"label":"b"}]},
  {"id":"C-999","group":"A","grades":["MA"],"sources":[{"label":"x"}]}
]}''');
      expect(run(reg), contains(contains('C-999')));
    });

    test('a dropped doc row (in doc, not in register) is caught', () {
      final reg = _register('''
{"version":1,"claims":[
  {"id":"C-001","group":"A","grades":["EXP","CS"],"sources":[{"label":"a"}]}
]}''');
      expect(run(reg), contains(contains('C-035')));
    });

    test('an invented grade is caught', () {
      final reg = _register('''
{"version":1,"claims":[
  {"id":"C-001","group":"A","grades":["EXP","CS","MA"],"sources":[{"label":"a"}]},
  {"id":"C-035","group":"H","grades":["TRAD"],"sources":[{"label":"b"}]}
]}''');
      expect(run(reg), contains(contains('absent from')));
    });

    test('a dropped grade is caught', () {
      final reg = _register('''
{"version":1,"claims":[
  {"id":"C-001","group":"A","grades":["EXP"],"sources":[{"label":"a"}]},
  {"id":"C-035","group":"H","grades":["TRAD"],"sources":[{"label":"b"}]}
]}''');
      expect(run(reg), contains(contains('drops')));
    });

    test('a claim with no source is caught', () {
      final reg = _register('''
{"version":1,"claims":[
  {"id":"C-001","group":"A","grades":["EXP","CS"],"sources":[]},
  {"id":"C-035","group":"H","grades":["TRAD"],"sources":[{"label":"b"}]}
]}''');
      expect(run(reg), contains(contains('no source')));
    });
  });
}
