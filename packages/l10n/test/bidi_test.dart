// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E09-T05 — the emitted control characters ARE the contract: a wrong or missing
// isolate silently reorders a line and scrambles screen-reader order. Pinned by
// exact codepoint, written test-first.

import 'package:flutter/foundation.dart' show Unicode;
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

const int _fsi = 0x2068; // First-Strong Isolate
const int _lri = 0x2066; // Left-to-Right Isolate
const int _rli = 0x2067; // Right-to-Left Isolate
const int _pdi = 0x2069; // Pop Directional Isolate

void main() {
  useOfflineTestPolicy();

  int first(String s) => s.runes.first;
  int last(String s) => s.runes.last;
  String inner(String s) => String.fromCharCodes(
        s.runes.skip(1).toList()..removeLast(),
      );

  test('isolate emits FSI … PDI', () {
    final out = isolate('abc');
    expect(out, '${Unicode.FSI}abc${Unicode.PDI}');
    expect(first(out), _fsi);
    expect(last(out), _pdi);
  });

  test('isolateLtr emits LRI … PDI', () {
    final out = isolateLtr('abc');
    expect(first(out), _lri);
    expect(last(out), _pdi);
    expect(inner(out), 'abc');
  });

  test('isolateRtl emits RLI … PDI', () {
    final out = isolateRtl('abc');
    expect(first(out), _rli);
    expect(last(out), _pdi);
    expect(inner(out), 'abc');
  });

  test('no legacy embedding/override (U+202A–U+202E) ever leaks', () {
    for (final out in <String>[
      isolate('مرحبا 5'),
      isolateLtr('5'),
      isolateRtl('مرحبا'),
    ]) {
      for (final rune in out.runes) {
        expect(
          rune < 0x202A || rune > 0x202E,
          isTrue,
          reason: 'legacy control U+${rune.toRadixString(16)} leaked',
        );
      }
    }
  });

  test('the inner run is preserved byte-for-byte', () {
    for (final run in const <String>['مرحبا', '456', '۴۵۶', 'مرحبا ۴۵۶ x']) {
      expect(inner(isolate(run)), run);
      expect(inner(isolateLtr(run)), run);
      expect(inner(isolateRtl(run)), run);
    }
  });

  test('empty input yields initiator + PDI with nothing between', () {
    expect(isolate(''), '${Unicode.FSI}${Unicode.PDI}');
    expect(isolateLtr(''), '${Unicode.LRI}${Unicode.PDI}');
    expect(isolateRtl(''), '${Unicode.RLI}${Unicode.PDI}');
  });

  test('isolateLtr and isolateRtl differ only in the initiator', () {
    const run = 'مرحبا ۴۵';
    final ltr = isolateLtr(run);
    final rtl = isolateRtl(run);
    expect(inner(ltr), inner(rtl));
    expect(last(ltr), last(rtl)); // both close with PDI
    // The direction is a one-character choice: LRI (U+2066) vs RLI (U+2067).
    expect(first(ltr), isNot(first(rtl)));
    expect(first(ltr), _lri);
    expect(first(rtl), _rli);
  });

  test('isolateAuto picks the isolate from the run content', () {
    expect(first(isolateAuto('مرحبا')), _rli); // has RTL → RLI
    expect(first(isolateAuto('456')), _lri); // no RTL → LRI
  });

  test('composes with the locale-numeral path without mangling digits', () {
    // The real T06 call site: format a number to fa digits, then isolate LTR.
    final run = formatLocaleNumber(const Locale('fa'), 7);
    final isolated = isolateLtr(run);
    expect(isolated.contains('۷'), isTrue); // Extended Arabic-Indic seven
    expect(first(isolated), _lri);
    expect(last(isolated), _pdi);
  });
}
