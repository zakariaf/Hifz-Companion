// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert' show utf8;
import 'dart:io' show Directory, File;
import 'dart:typed_data' show Uint8List;

import 'package:models/models.dart' show MushafEdition;
import 'package:sqlite3/common.dart' show CommonDatabase, OpenMode;
import 'package:sqlite3/sqlite3.dart' show sqlite3;

import '../app_meta_keys.dart';
import '../live_persistence_handle.dart';
import '../persistence_handle.dart';
import 'reference_data_builder.dart';
import 'reference_db_builder.dart';
import 'qul_layout_parser.dart';
import 'reference_metadata.dart';

/// Parses the three **already-verified** bundled core files into reference rows
/// and loads them through the single sanctioned writer ([loadCoreReference]) —
/// the production E05-T05 reference-data load over the bundled muṣḥaf.
///
/// The caller (the bundled-core installer at the composition root) has already
/// checked each byte buffer's SHA-256 against the binary-baked manifest; this
/// path therefore receives only verified bytes and passes the manifest's pinned
/// [checksumSha256] (non-empty) straight to [loadCoreReference], whose fail-closed
/// guard refuses an empty digest. The two QUL SQLite buffers are opened
/// read-only from a private temp file (sqlite3 needs a path; the bytes are never
/// mutated), parsed with the existing pure parsers, and the structural facts are
/// **inserted as given** — never recomputed, the glyph string stays opaque (R1).
///
/// Idempotent via [loadCoreReference] (a re-run for an already-loaded `mushafId`
/// is a no-op). It does **not** stamp readiness — the installer calls
/// [stampCoreVerified] last, after this returns, so no partially-trusted state
/// is observable.
Future<void> installVerifiedCoreReference(
  PersistenceHandle handle, {
  required MushafEdition edition,
  required Uint8List textXml,
  required Uint8List layoutDb,
  required Uint8List wordsDb,
  required String checksumSha256,
}) async {
  final db = (handle as LivePersistenceHandle).database;

  // sqlite3 opens a path, not a byte buffer; write the verified bytes to a
  // private temp file, open read-only, and delete after. dart:io File reads are
  // permitted (no socket); the bytes are copied verbatim, never altered.
  final tmp = await Directory.systemTemp.createTemp('hifz_core_ref');
  CommonDatabase? layoutConn;
  CommonDatabase? wordsConn;
  try {
    final layoutPath = '${tmp.path}/layout.db';
    final wordsPath = '${tmp.path}/words.db';
    File(layoutPath).writeAsBytesSync(layoutDb, flush: true);
    File(wordsPath).writeAsBytesSync(wordsDb, flush: true);
    layoutConn = sqlite3.open(layoutPath, mode: OpenMode.readOnly);
    wordsConn = sqlite3.open(wordsPath, mode: OpenMode.readOnly);

    final info = parseLayoutInfo(layoutConn);
    final layoutLines = parseLayoutLines(layoutConn);
    final words = parseGlyphWords(wordsConn);
    final meta = parseQuranMetadata(utf8.decode(textXml));
    final linesAndAyat = buildLinesAndAyat(
      layout: layoutLines,
      words: words,
      sajdaAyahKeys: meta.sajdaAyahKeys,
    );

    await loadCoreReference(
      db,
      CoreReferenceData(
        mushafId: edition.mushafId,
        riwayah: edition.riwayah,
        name: edition.displayName,
        // The page-glyph family scheme (QPC_P###), read from the QUL info row.
        fontFamily: info.fontName,
        checksumSha256: checksumSha256,
        // Counts come from the QUL info row, never the 604/15 literals.
        pageCount: info.pageCount,
        lineCount: info.lineCount,
        surahs: buildSurahRows(meta),
        pages: buildPageRows(layout: layoutLines, words: words, meta: meta),
        lines: linesAndAyat.lines,
        ayat: linesAndAyat.ayat,
      ),
    );
  } finally {
    layoutConn?.dispose();
    wordsConn?.dispose();
    try {
      tmp.deleteSync(recursive: true);
    } on Object {
      // Best-effort cleanup of the temp copy; never mask an install error.
    }
  }
}

/// Stamps `text_checksum_verified_at` — the final durable "the bundled muṣḥaf is
/// whole and ready" signal `coreVerifiedProvider` reads. Called **last** by the
/// installer, only after every file verified and the reference DB built. [value]
/// is the manifest's pinned text digest (a stable, clock-free marker; only its
/// presence is read).
Future<void> stampCoreVerified(PersistenceHandle handle, String value) =>
    (handle as LivePersistenceHandle)
        .database
        .appMetaDao
        .set(kAppMetaKeyTextChecksumVerifiedAt, value);
