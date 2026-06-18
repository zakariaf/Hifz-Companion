// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:collection';

import 'package:meta/meta.dart';

/// The immutable, co-versioned **muṣḥaf triple** — the integrity-bearing
/// description of one muṣḥaf edition as three separately-licensed layers bound
/// by a single [mushafId]: the Tanzil text ([textSha256]), the QUL page layout
/// ([layoutSha256]), and the 604 per-page KFGQPC glyph fonts ([fontSha256]).
///
/// This is what makes the muṣḥaf **swappable by construction** (PRD R2): one
/// [mushafId] binds exactly one `{text, layout, fonts}`, and [pageCount] /
/// [lineCount] are **fields**, never hardcoded `604`/`15`, so a different
/// edition (a 13-line muṣḥaf, or Warsh) is representable without touching render
/// or layout code. The three SHA-256 digests exist so a single wrong byte is
/// unrepresentable downstream (PRD R1, existential): the core muṣḥaf is bundled
/// in the signed binary and these digests gate it at build time and at first
/// load (E05; engineering 08 §1, 09 §3).
///
/// Distinct from the read-only `Mushaf` reference-table row (a lighter DTO with
/// a single `checksumSha256`): both describe the same physical edition and must
/// agree on [mushafId]. The localized *presentation* of [displayName] /
/// [riwayah] is reader chrome (E05-T09 / `l10n`); the values here are domain
/// data, not localized copy — and the page is never called "the Quran"
/// absolutely (R2).
@immutable
class MushafEdition {
  /// The stable id binding this triple (e.g. `'kfgqpc_hafs_madani_v2'`).
  final String mushafId;

  /// The named riwāyah, stated explicitly (e.g. `'Ḥafṣ ʿan ʿĀṣim'`) — never
  /// implied, never "the Quran" in the absolute (R2).
  final String riwayah;

  /// The human display name (e.g. `'Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf'`); shown as
  /// reader/About chrome, never as "the Quran" absolutely.
  final String displayName;

  /// The number of pages in this edition — a field, never a hardcoded `604`.
  final int pageCount;

  /// The number of lines per page — a field, never a hardcoded `15`.
  final int lineCount;

  /// The SHA-256 of the Tanzil Uthmani text asset (lower-case hex).
  final String textSha256;

  /// The SHA-256 of the QUL page-layout asset (lower-case hex).
  final String layoutSha256;

  /// Page (`1..pageCount`) → that page's glyph-font-file SHA-256 (lower-case
  /// hex). Exposed read-only: the backing map cannot be mutated after
  /// construction.
  final Map<int, String> fontSha256;

  /// Creates a muṣḥaf triple. [fontSha256] is copied into an unmodifiable view,
  /// so the constructed edition is immutable even if the caller mutates its
  /// argument afterwards.
  MushafEdition({
    required this.mushafId,
    required this.riwayah,
    required this.displayName,
    required this.pageCount,
    required this.lineCount,
    required this.textSha256,
    required this.layoutSha256,
    required Map<int, String> fontSha256,
  }) : fontSha256 = UnmodifiableMapView(Map<int, String>.of(fontSha256));

  /// Returns a copy with the given fields replaced; omitted fields preserved.
  MushafEdition copyWith({
    String? mushafId,
    String? riwayah,
    String? displayName,
    int? pageCount,
    int? lineCount,
    String? textSha256,
    String? layoutSha256,
    Map<int, String>? fontSha256,
  }) {
    return MushafEdition(
      mushafId: mushafId ?? this.mushafId,
      riwayah: riwayah ?? this.riwayah,
      displayName: displayName ?? this.displayName,
      pageCount: pageCount ?? this.pageCount,
      lineCount: lineCount ?? this.lineCount,
      textSha256: textSha256 ?? this.textSha256,
      layoutSha256: layoutSha256 ?? this.layoutSha256,
      fontSha256: fontSha256 ?? this.fontSha256,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MushafEdition &&
      other.mushafId == mushafId &&
      other.riwayah == riwayah &&
      other.displayName == displayName &&
      other.pageCount == pageCount &&
      other.lineCount == lineCount &&
      other.textSha256 == textSha256 &&
      other.layoutSha256 == layoutSha256 &&
      _fontSha256Equals(other.fontSha256, fontSha256);

  @override
  int get hashCode => Object.hash(
        mushafId,
        riwayah,
        displayName,
        pageCount,
        lineCount,
        textSha256,
        layoutSha256,
        Object.hashAllUnordered(
          fontSha256.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );

  static bool _fontSha256Equals(Map<int, String> a, Map<int, String> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}

/// The default bundled edition: KFGQPC **Madani 15-line, Ḥafṣ ʿan ʿĀṣim, QCF
/// V2** (PRD §11.1, scope lock). [MushafEdition.pageCount] `604` and
/// [MushafEdition.lineCount] `15` are seeded here as ordinary arguments, never
/// hardcoded in render/layout code (R2 swappability).
///
/// The SHA-256 digests are empty placeholders here: the core muṣḥaf is bundled
/// and its real per-file hashes are pinned by E05-T10's build-time pipeline
/// against the bundled assets. An empty digest never matches real bytes, so an
/// unpinned edition fails verification **closed** (refuses to render) until
/// pinned — the safe default.
final MushafEdition kKfgqpcHafsMadaniV2Edition = MushafEdition(
  mushafId: 'kfgqpc_hafs_madani_v2',
  riwayah: 'Ḥafṣ ʿan ʿĀṣim',
  displayName: 'Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf',
  pageCount: 604,
  lineCount: 15,
  textSha256: '', // TODO(E05-T10): pin from the bundled Tanzil asset.
  layoutSha256: '', // TODO(E05-T10): pin from the bundled QUL layout asset.
  fontSha256: <int, String>{
    // TODO(E05-T10): pin each page font's SHA-256 from the bundled asset.
    for (var page = 1; page <= 604; page++) page: '',
  },
);
