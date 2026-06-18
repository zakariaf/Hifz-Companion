// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';
import 'package:test/test.dart';

void main() {
  MushafEdition edition({
    String mushafId = 'm',
    int pageCount = 3,
    int lineCount = 15,
    Map<int, String>? fontSha256,
  }) {
    return MushafEdition(
      mushafId: mushafId,
      riwayah: 'Ḥafṣ ʿan ʿĀṣim',
      displayName: 'display',
      pageCount: pageCount,
      lineCount: lineCount,
      textSha256: 'text',
      layoutSha256: 'layout',
      fontSha256: fontSha256 ?? {1: 'a', 2: 'b', 3: 'c'},
    );
  }

  group('MushafEdition triple shape & immutability', () {
    test('round-trips its fields', () {
      final m = edition();
      expect(m.mushafId, 'm');
      expect(m.riwayah, 'Ḥafṣ ʿan ʿĀṣim');
      expect(m.displayName, 'display');
      expect(m.pageCount, 3);
      expect(m.lineCount, 15);
      expect(m.textSha256, 'text');
      expect(m.layoutSha256, 'layout');
      expect(m.fontSha256, {1: 'a', 2: 'b', 3: 'c'});
    });

    test('copyWith produces an independent value, omitted fields preserved',
        () {
      final m = edition();
      final n = m.copyWith(displayName: 'other', textSha256: 'text2');
      expect(n.displayName, 'other');
      expect(n.textSha256, 'text2');
      // Untouched fields preserved.
      expect(n.mushafId, m.mushafId);
      expect(n.fontSha256, m.fontSha256);
      // The original is unchanged.
      expect(m.displayName, 'display');
      expect(m.textSha256, 'text');
    });

    test('fontSha256 cannot be mutated through the exposed map', () {
      final m = edition();
      expect(() => m.fontSha256[4] = 'x', throwsUnsupportedError);
      expect(() => m.fontSha256.remove(1), throwsUnsupportedError);
    });

    test('mutating the constructor argument afterwards does not leak in', () {
      final source = {1: 'a', 2: 'b', 3: 'c'};
      final m = edition(fontSha256: source);
      source[1] = 'TAMPERED';
      expect(m.fontSha256[1], 'a');
    });

    test('two equal editions compare equal and share a hashCode', () {
      final a = edition();
      final b = edition();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('editions differing only in a font digest are not equal', () {
      final a = edition();
      final b = edition(fontSha256: {1: 'a', 2: 'b', 3: 'DIFFERENT'});
      expect(a, isNot(equals(b)));
    });
  });

  group('MushafEdition parameterised counts (R2 swappability)', () {
    test('a non-15-line, non-604 edition is accepted and read back', () {
      final m = edition(
        pageCount: 548,
        lineCount: 16,
        fontSha256: {for (var p = 1; p <= 548; p++) p: 'h$p'},
      );
      expect(m.pageCount, 548);
      expect(m.lineCount, 16);
      expect(m.fontSha256.length, 548);
    });
  });

  group('default bundled edition seed', () {
    test('names the KFGQPC Madani 15-line Ḥafṣ edition', () {
      final m = kKfgqpcHafsMadaniV2Edition;
      expect(m.mushafId, 'kfgqpc_hafs_madani_v2');
      expect(m.riwayah, 'Ḥafṣ ʿan ʿĀṣim');
      expect(m.displayName, 'Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf');
      expect(m.pageCount, 604);
      expect(m.lineCount, 15);
    });

    test('fontSha256 is keyed exactly 1..604 with no gaps', () {
      final keys = kKfgqpcHafsMadaniV2Edition.fontSha256.keys.toList()..sort();
      expect(keys.first, 1);
      expect(keys.last, 604);
      expect(keys.length, 604);
    });
  });
}
