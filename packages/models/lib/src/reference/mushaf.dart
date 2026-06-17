// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

/// An immutable descriptor of one muṣḥaf edition — the swappable, riwāyah-named
/// unit a profile renders (05 §2 `mushaf`; PRD R2, §11.3).
///
/// Read-only reference data: filled from the bundled, checksum-verified asset
/// pack (E05), never written at runtime. [pageCount] and [lineCount] are
/// **fields**, never hardcoded 604/15, so a different edition (e.g. a 13-line
/// muṣḥaf, or Warsh) is representable. [riwayah] names the reading explicitly —
/// the app never calls a muṣḥaf "the Quran" in the absolute.
@immutable
class Mushaf {
  /// The stable id of this edition (e.g. `'hafs_madani_15'`).
  final String mushafId;

  /// The named riwāyah (e.g. `'hafs_an_asim'`) — stated explicitly, never
  /// implied (R2).
  final String riwayah;

  /// The human display name of the edition (e.g. `'Madani 15-line'`).
  final String name;

  /// The number of lines per page in this edition (a field, never hardcoded).
  final int lineCount;

  /// The number of pages in this edition (a field, never hardcoded).
  final int pageCount;

  /// The page-glyph font family this edition renders with (§08).
  final String fontFamily;

  /// The pinned SHA-256 of this edition's assets, verified against the manifest
  /// (E05); the integrity governance lives there, this carries the value.
  final String checksumSha256;

  /// Creates a muṣḥaf descriptor.
  const Mushaf({
    required this.mushafId,
    required this.riwayah,
    required this.name,
    required this.lineCount,
    required this.pageCount,
    required this.fontFamily,
    required this.checksumSha256,
  });

  /// Returns a copy with the given fields replaced; omitted fields preserved.
  Mushaf copyWith({
    String? mushafId,
    String? riwayah,
    String? name,
    int? lineCount,
    int? pageCount,
    String? fontFamily,
    String? checksumSha256,
  }) {
    return Mushaf(
      mushafId: mushafId ?? this.mushafId,
      riwayah: riwayah ?? this.riwayah,
      name: name ?? this.name,
      lineCount: lineCount ?? this.lineCount,
      pageCount: pageCount ?? this.pageCount,
      fontFamily: fontFamily ?? this.fontFamily,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Mushaf &&
      other.mushafId == mushafId &&
      other.riwayah == riwayah &&
      other.name == name &&
      other.lineCount == lineCount &&
      other.pageCount == pageCount &&
      other.fontFamily == fontFamily &&
      other.checksumSha256 == checksumSha256;

  @override
  int get hashCode => Object.hash(
        mushafId,
        riwayah,
        name,
        lineCount,
        pageCount,
        fontFamily,
        checksumSha256,
      );
}
