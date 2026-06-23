// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart' show MushafEdition;
import 'package:sqlite3/common.dart' show SqliteException;

import '../db/database.dart';
import 'reference_data_builder.dart';
import 'reference_metadata.dart';

/// The fully-parsed, ready-to-load reference data for one muṣḥaf edition — the
/// plain value bundle the QUL/Tanzil parse produces (E05-T05 parts 1+2) and the
/// **single one-shot build path** ([loadCoreReference]) inserts into E03's
/// read-only tables.
///
/// `pageCount`/`lineCount` are **read from the QUL `info` row**, never the
/// literals 604/15 — the muṣḥaf is swappable (CLAIMS C-031 reads the count, it
/// does not assume it).
class CoreReferenceData {
  /// Bundles the parsed rows for one edition.
  const CoreReferenceData({
    required this.mushafId,
    required this.riwayah,
    required this.name,
    required this.fontFamily,
    required this.checksumSha256,
    required this.pageCount,
    required this.lineCount,
    required this.surahs,
    required this.pages,
    required this.lines,
    required this.ayat,
  });

  /// The stable edition id (the `mushaf` PK; equals `MushafEdition.mushafId`).
  final String mushafId;

  /// The named riwāyah (e.g. `hafs_an_asim`) — stated explicitly (R2).
  final String riwayah;

  /// The display name of the edition.
  final String name;

  /// The page-glyph font family, read from the QUL `info` row.
  final String fontFamily;

  /// The pinned SHA-256 already verified against the asset manifest (E05-T03);
  /// empty means the input was never verified and the load is refused.
  final String checksumSha256;

  /// Pages in the edition, **read from the QUL `info` row** (≠ a literal).
  final int pageCount;

  /// Lines per page, **read from the QUL `info` row** (≠ a literal).
  final int lineCount;

  /// The 114 sūra rows (from Tanzil metadata).
  final List<SurahRowData> surahs;

  /// The per-page descriptor rows (from QUL layout + Tanzil divisions).
  final List<PageRowData> pages;

  /// The per-line glyph/structure rows (from QUL layout + word glyph DB).
  final List<LineRowData> lines;

  /// The per-āyah position rows (from QUL layout + word glyph DB).
  final List<AyahRowData> ayat;
}

/// A failure of the reference load, confined to the `/data` boundary — typed,
/// never swallowed, never carrying file or glyph contents.
sealed class ReferenceLoadError implements Exception {
  /// Const base constructor for the sealed hierarchy.
  const ReferenceLoadError();

  /// The input was not checksum-verified — fail closed, write nothing.
  const factory ReferenceLoadError.unverifiedInput() = _UnverifiedInput;

  /// The QUL/Tanzil bytes could not be parsed into reference rows.
  const factory ReferenceLoadError.malformedLayout(String detail) =
      _MalformedLayout;

  /// A count read from the data disagreed with the data's own declaration
  /// (e.g. the `info` page count ≠ the number of page rows) — a torn dataset.
  const factory ReferenceLoadError.structuralMismatch({
    required String of,
    required int expected,
    required int actual,
  }) = _StructuralMismatch;

  /// A row violated a table `CHECK`/FK — the whole load rolled back.
  const factory ReferenceLoadError.constraintViolation({
    required String table,
    required String detail,
  }) = _ConstraintViolation;
}

class _UnverifiedInput extends ReferenceLoadError {
  const _UnverifiedInput();
  @override
  String toString() => 'ReferenceLoadError.unverifiedInput: the core pack was '
      'not checksum-verified; refusing to load unverified Quran data.';
}

class _MalformedLayout extends ReferenceLoadError {
  const _MalformedLayout(this.detail);
  final String detail;
  @override
  String toString() => 'ReferenceLoadError.malformedLayout: $detail';
}

class _StructuralMismatch extends ReferenceLoadError {
  const _StructuralMismatch({
    required this.of,
    required this.expected,
    required this.actual,
  });
  final String of;
  final int expected;
  final int actual;
  @override
  String toString() => 'ReferenceLoadError.structuralMismatch: $of expected '
      '$expected, got $actual.';
}

class _ConstraintViolation extends ReferenceLoadError {
  const _ConstraintViolation({required this.table, required this.detail});
  final String table;
  final String detail;
  @override
  String toString() =>
      'ReferenceLoadError.constraintViolation on "$table": $detail';
}

/// Loads the verified [data] into E03's read-only `mushaf`/`surah`/`page`/
/// `line`/`ayah` reference tables in **one** `db.transaction` — the only
/// sanctioned writer of those tables (05 §2: "never written at runtime; no DAO
/// exposes a mutation"; this one-shot install path is the lone exception, the
/// same shape `review_log`'s append-only rule allows for backup/restore).
///
/// Fail-closed: an unverified input ([CoreReferenceData.checksumSha256] empty)
/// throws [ReferenceLoadError.unverifiedInput] and writes nothing. The load is
/// atomic — a single `CHECK`/FK violation throws
/// [ReferenceLoadError.constraintViolation] and rolls the **whole** load back,
/// so no half-built reference DB is ever observable. Idempotent: a re-run for an
/// already-loaded `mushaf_id` is a no-op (never a duplicate or partial
/// overwrite). It does **not** stamp `text_checksum_verified_at` (E05-T04 owns
/// that, after this returns) and does not touch the schema (E03 owns the DDL).
///
/// The structural facts are **inserted as given** — read from the QUL dataset,
/// never recomputed here (08 §3); `text_glyph_ref` stays opaque (R1).
Future<void> loadCoreReference(HifzDatabase db, CoreReferenceData data) async {
  if (data.checksumSha256.isEmpty) {
    throw const ReferenceLoadError.unverifiedInput();
  }
  if (data.pages.length != data.pageCount) {
    throw ReferenceLoadError.structuralMismatch(
      of: 'page rows',
      expected: data.pageCount,
      actual: data.pages.length,
    );
  }

  try {
    await db.transaction(() async {
      final already = await (db.select(db.mushafs)
            ..where((m) => m.mushafId.equals(data.mushafId)))
          .get();
      if (already.isNotEmpty) return; // idempotent: already loaded, no-op.

      await db.into(db.mushafs).insert(
            MushafsCompanion.insert(
              mushafId: data.mushafId,
              riwayah: data.riwayah,
              name: data.name,
              lineCount: data.lineCount,
              pageCount: data.pageCount,
              fontFamily: data.fontFamily,
              checksumSha256: data.checksumSha256,
            ),
          );

      // Insertion order respects the FK graph: surah → page → line/ayah. Each
      // bulk insert is a batch, all inside the single ambient transaction.
      await db.batch((b) {
        b.insertAll(db.surahs, [
          for (final s in data.surahs)
            SurahsCompanion.insert(
              surahId: Value(s.surahId),
              nameAr: s.nameAr,
              revelation: s.revelation,
              ayahCount: s.ayahCount,
              bismillahPre: s.bismillahPre,
            ),
        ]);
      });
      await db.batch((b) {
        b.insertAll(db.pages, [
          for (final p in data.pages)
            PagesCompanion.insert(
              pageId: Value(p.pageId),
              juz: p.juz,
              hizb: p.hizb,
              rub: p.rub,
              surahStart: p.surahStart,
              ayahStart: p.ayahStart,
              surahEnd: p.surahEnd,
              ayahEnd: p.ayahEnd,
              lineCount: p.lineCount,
              qpcFontName: p.qpcFontName,
            ),
        ]);
      });
      await db.batch((b) {
        b.insertAll(db.lines, [
          for (final l in data.lines)
            LinesCompanion.insert(
              lineId: Value(l.lineId),
              pageId: l.pageId,
              lineNo: l.lineNo,
              lineType: l.lineType,
              ayahRefsJson: l.ayahRefsJson,
              textGlyphRef: l.textGlyphRef,
            ),
        ]);
        b.insertAll(db.ayat, [
          for (final a in data.ayat)
            AyatCompanion.insert(
              ayahId: a.ayahId,
              surah: a.surah,
              ayah: a.ayah,
              pageId: a.pageId,
              lineRefsJson: a.lineRefsJson,
              sajda: a.sajda,
            ),
        ]);
      });
    });
  } on SqliteException catch (e) {
    // A CHECK/FK violation rolled the transaction back; surface it typed. The
    // message names the offending constraint; no glyph/text content is logged.
    throw ReferenceLoadError.constraintViolation(
      table: 'reference',
      detail: e.message,
    );
  }
}

/// Registers ONLY the bundled muṣḥaf **edition metadata** row (riwāyah / name /
/// counts) so a profile's `mushaf_id` foreign key resolves before the full
/// checksum-verified reference install (E05) lands. It writes **no** Quran text,
/// glyph, page, line, or āyah — those stay gated behind the verified-text stamp
/// (R1). This is the dev/bootstrap slice the composition root uses in a **debug**
/// build where the bundled asset pack is not present, so the app is runnable on
/// a simulator; a release build never calls it and stays fully fail-closed.
/// Idempotent (insert-or-ignore). Lives in the single sanctioned reference-write
/// path so the read-only gate stays intact — it is reached only through the thin
/// [registerBundledEdition] wrapper, never as an exported write surface.
Future<void> registerBundledEditionMetadata(
  HifzDatabase db,
  MushafEdition edition,
) async {
  await db.into(db.mushafs).insert(
        MushafsCompanion.insert(
          mushafId: edition.mushafId,
          riwayah: edition.riwayah,
          name: edition.displayName,
          lineCount: edition.lineCount,
          pageCount: edition.pageCount,
          fontFamily: 'QCF',
          checksumSha256: 'dev-unverified',
        ),
        mode: InsertMode.insertOrIgnore,
      );
}
