// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart';

import '../database.dart';
import '../tables/reference/ayat.dart';
import '../tables/reference/lines.dart';
import '../tables/reference/mushafs.dart';
import '../tables/reference/mutashabih_groups.dart';
import '../tables/reference/mutashabih_members.dart';
import '../tables/reference/pages.dart';
import '../tables/reference/surahs.dart';
import 'mappers.dart';

part 'reference_read_dao.g.dart';

/// **Select-only** access to the read-only Quran reference tables, mapping rows
/// to the `models` reference DTOs (05 §2; R1).
///
/// There is deliberately **no** insert/update/delete method — the muṣḥaf is
/// unwritable at runtime by construction; the checksum-verified asset loader
/// (E05) is the only writer. `Line.textGlyphRef` is carried **opaque** — never
/// string-processed or logged as text (domain-mushaf-text-integrity).
@DriftAccessor(
  tables: [
    Pages,
    Lines,
    Ayat,
    Surahs,
    Mushafs,
    MutashabihGroups,
    MutashabihMembers,
  ],
)
class ReferenceReadDao extends DatabaseAccessor<HifzDatabase>
    with _$ReferenceReadDaoMixin {
  /// Creates the DAO over [db].
  ReferenceReadDao(super.db);

  /// The muṣḥaf page ids in [juz] (1–30), ascending — the fixed juz→page span
  /// the cold-start seeder expands a held juz into (C-031). Empty until the core
  /// reference pack is loaded (E11).
  Future<List<int>> pageIdsForJuz(int juz) async {
    final query = select(pages)
      ..where((p) => p.juz.equals(juz))
      ..orderBy([(p) => OrderingTerm.asc(p.pageId)]);
    final rows = await query.get();
    return [for (final row in rows) row.pageId];
  }

  /// The lowest `page_id` in [juz] (the page that juz starts on), or null if the
  /// reference is not loaded — **read** from the `page` table, never computed
  /// (engineering 08 §3; a wrong start page is a sacred off-by-one).
  Future<int?> firstPageInJuz(int juz) =>
      _firstPageWhere(pages.juz.equals(juz));

  /// The lowest `page_id` in [hizb] (the page that ḥizb starts on), or null —
  /// read from the `page` table, never computed.
  Future<int?> firstPageInHizb(int hizb) =>
      _firstPageWhere(pages.hizb.equals(hizb));

  /// The lowest `page_id` whose `surah_start` is [surah] (the page that sūrah's
  /// first āyah falls on), or null — read from the `page` table, never computed.
  Future<int?> firstPageOfSurah(int surah) =>
      _firstPageWhere(pages.surahStart.equals(surah));

  Future<int?> _firstPageWhere(Expression<bool> filter) async {
    final query = selectOnly(pages)
      ..addColumns([pages.pageId.min()])
      ..where(filter);
    return query.getSingle().then((row) => row.read(pages.pageId.min()));
  }

  /// The page descriptor for [pageNumber], or null.
  Future<Page?> pageByNumber(int pageNumber) async {
    final query = select(pages)..where((p) => p.pageId.equals(pageNumber));
    final row = await query.getSingleOrNull();
    return row == null ? null : _pageToModel(row);
  }

  /// The sūrah metadata for [surahNumber], or null.
  Future<Surah?> surahById(int surahNumber) async {
    final query = select(surahs)..where((s) => s.surahId.equals(surahNumber));
    final row = await query.getSingleOrNull();
    return row == null ? null : _surahToModel(row);
  }

  /// The muṣḥaf descriptor for [mushafId], or null.
  Future<Mushaf?> mushafById(String mushafId) async {
    final query = select(mushafs)..where((m) => m.mushafId.equals(mushafId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _mushafToModel(row);
  }

  /// The lines on [pageNumber], in line order.
  Future<List<Line>> linesForPage(int pageNumber) async {
    final query = select(lines)
      ..where((l) => l.pageId.equals(pageNumber))
      ..orderBy([(l) => OrderingTerm.asc(l.lineNo)]);
    final rows = await query.get();
    return rows.map(_lineToModel).toList();
  }

  /// The āyāt on [pageNumber].
  Future<List<Ayah>> ayatForPage(int pageNumber) async {
    final query = select(ayat)..where((a) => a.pageId.equals(pageNumber));
    final rows = await query.get();
    return rows.map(_ayahToModel).toList();
  }

  /// The mutashābihāt group [groupId], or null.
  Future<MutashabihGroup?> mutashabihGroupById(String groupId) async {
    final query = select(mutashabihGroups)
      ..where((g) => g.groupId.equals(groupId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _groupToModel(row);
  }

  /// The members of mutashābihāt group [groupId].
  Future<List<MutashabihMember>> mutashabihMembersForGroup(
    String groupId,
  ) async {
    final query = select(mutashabihMembers)
      ..where((m) => m.groupId.equals(groupId));
    final rows = await query.get();
    return rows.map(_memberToModel).toList();
  }

  Page _pageToModel(PageRow row) => Page(
        pageNumber: row.pageId,
        juz: row.juz,
        hizb: row.hizb,
        rub: row.rub,
        surahStart: row.surahStart,
        ayahStart: row.ayahStart,
        surahEnd: row.surahEnd,
        ayahEnd: row.ayahEnd,
        lineCount: row.lineCount,
        qpcFontName: row.qpcFontName,
      );

  Line _lineToModel(LineRow row) => Line(
        lineId: row.lineId,
        pageNumber: row.pageId,
        lineNumber: row.lineNo,
        lineType: enumFromWire(
          LineType.values,
          (t) => t.wireValue,
          row.lineType,
          'LineType',
        ),
        ayahRefsJson: row.ayahRefsJson,
        textGlyphRef: row.textGlyphRef, // opaque — never parsed as text (R1)
      );

  Ayah _ayahToModel(AyahRow row) => Ayah(
        ayahId: row.ayahId,
        surah: row.surah,
        ayah: row.ayah,
        pageNumber: row.pageId,
        lineRefsJson: row.lineRefsJson,
        sajda: row.sajda,
      );

  Surah _surahToModel(SurahRow row) => Surah(
        surahNumber: row.surahId,
        nameAr: row.nameAr,
        revelation: enumFromWire(
          Revelation.values,
          (r) => r.wireValue,
          row.revelation,
          'Revelation',
        ),
        ayahCount: row.ayahCount,
        bismillahPre: row.bismillahPre,
      );

  Mushaf _mushafToModel(MushafRow row) => Mushaf(
        mushafId: row.mushafId,
        riwayah: row.riwayah,
        name: row.name,
        lineCount: row.lineCount,
        pageCount: row.pageCount,
        fontFamily: row.fontFamily,
        checksumSha256: row.checksumSha256,
      );

  MutashabihGroup _groupToModel(MutashabihGroupRow row) => MutashabihGroup(
        groupId: row.groupId,
        type: enumFromWire(
          MutashabihType.values,
          (t) => t.wireValue,
          row.type,
          'MutashabihType',
        ),
        noteKey: row.noteKey,
      );

  MutashabihMember _memberToModel(MutashabihMemberRow row) => MutashabihMember(
        groupId: row.groupId,
        ayahId: row.ayahId,
        distinguishingWordIndexJson: row.distinguishingWordIndexJson,
      );
}
