// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';
import 'package:test/test.dart';

void main() {
  group('Mushaf is not hardcoded to one edition', () {
    test('pageCount / lineCount are settable fields, not 604/15 constants', () {
      const madani = Mushaf(
        mushafId: 'hafs_madani_15',
        riwayah: 'hafs_an_asim',
        name: 'Madani 15-line',
        lineCount: 15,
        pageCount: 604,
        fontFamily: 'QCF_P001',
        checksumSha256: 'abc123',
      );
      const altEdition = Mushaf(
        mushafId: 'warsh_13',
        riwayah: 'warsh_an_nafi',
        name: 'Warsh 13-line',
        lineCount: 13,
        pageCount: 500,
        fontFamily: 'QCF_W001',
        checksumSha256: 'def456',
      );
      expect(madani.lineCount, 15);
      expect(madani.pageCount, 604);
      expect(altEdition.lineCount, 13);
      expect(altEdition.pageCount, 500);
      expect(madani.riwayah, 'hafs_an_asim');
      expect(madani.copyWith(), madani);
      expect(madani == altEdition, isFalse);
    });
  });

  group('Line.textGlyphRef is opaque — equality is byte-for-byte, not text',
      () {
    test('arbitrary glyph bytes are preserved verbatim', () {
      const ref = ' ﭐ';
      const line = Line(
        lineId: 1,
        pageNumber: 1,
        lineNumber: 1,
        lineType: LineType.ayah,
        ayahRefsJson: '[1]',
        textGlyphRef: ref,
      );
      // Equality is the opaque reference itself — never normalized/lower-cased.
      expect(line.textGlyphRef, ref);
      expect(line.copyWith(), line);
    });
  });

  group('reference DTO copyWith / value equality', () {
    test('Page round-trips through copyWith and equals a twin', () {
      const page = Page(
        pageNumber: 42,
        juz: 3,
        hizb: 5,
        rub: 18,
        surahStart: 3,
        ayahStart: 15,
        surahEnd: 3,
        ayahEnd: 32,
        lineCount: 15,
        qpcFontName: 'QCF_P042',
      );
      expect(page.copyWith(), page);
      expect(page.copyWith(juz: 4).juz, 4);
      expect(page.copyWith(juz: 4).pageNumber, page.pageNumber);
    });

    test('Surah / Ayah / MutashabihGroup / MutashabihMember equality', () {
      const surah = Surah(
        surahNumber: 1,
        nameAr: 'الفاتحة',
        revelation: Revelation.meccan,
        ayahCount: 7,
        bismillahPre: true,
      );
      const ayah = Ayah(
        ayahId: '2:255',
        surah: 2,
        ayah: 255,
        pageNumber: 42,
        lineRefsJson: '[3,4]',
        sajda: false,
      );
      const group = MutashabihGroup(
        groupId: 'g1',
        type: MutashabihType.nearIdentical,
        noteKey: 'note.g1',
      );
      const member = MutashabihMember(
        groupId: 'g1',
        ayahId: '2:255',
        distinguishingWordIndexJson: '[2]',
      );
      expect(surah.copyWith(), surah);
      expect(ayah.copyWith(), ayah);
      expect(group.copyWith(), group);
      expect(member.copyWith(), member);
      expect(surah.hashCode, surah.copyWith().hashCode);
    });
  });

  group('reference enum wire tokens (05 §2)', () {
    test('Revelation == revelation IN (meccan, medinan)', () {
      expect(
        Revelation.values.map((e) => e.wireValue).toSet(),
        {'meccan', 'medinan'},
      );
    });
    test('LineType == line_type IN (ayah, surah_header, basmala)', () {
      expect(
        LineType.values.map((e) => e.wireValue).toSet(),
        {'ayah', 'surah_header', 'basmala'},
      );
    });
    test('MutashabihType == type IN (identical, near_identical, structural)',
        () {
      expect(
        MutashabihType.values.map((e) => e.wireValue).toSet(),
        {'identical', 'near_identical', 'structural'},
      );
    });
  });
}
