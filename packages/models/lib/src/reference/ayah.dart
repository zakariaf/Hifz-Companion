// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

/// One āyah's immutable position descriptor (05 §2 `ayah`; PRD §10.1).
///
/// Read-only reference structure. Holds the āyah's location only — its `'s:a'`
/// id, sūrah/āyah numbers, the page it falls on, the lines it occupies, and
/// whether it is a sajda āyah; it stores **no** Quran text (R1).
@immutable
class Ayah {
  /// The `'surah:ayah'` id (e.g. `'2:255'`).
  final String ayahId;

  /// The sūrah number (FK into `surah`).
  final int surah;

  /// The āyah number within its sūrah.
  final int ayah;

  /// The page this āyah falls on (FK into `page`).
  final int pageNumber;

  /// The raw `line_refs_json` payload — which lines this āyah occupies.
  final String lineRefsJson;

  /// Whether this is a sajda (prostration) āyah.
  final bool sajda;

  /// Creates an āyah position descriptor.
  const Ayah({
    required this.ayahId,
    required this.surah,
    required this.ayah,
    required this.pageNumber,
    required this.lineRefsJson,
    required this.sajda,
  });

  /// Returns a copy with the given fields replaced; omitted fields preserved.
  Ayah copyWith({
    String? ayahId,
    int? surah,
    int? ayah,
    int? pageNumber,
    String? lineRefsJson,
    bool? sajda,
  }) {
    return Ayah(
      ayahId: ayahId ?? this.ayahId,
      surah: surah ?? this.surah,
      ayah: ayah ?? this.ayah,
      pageNumber: pageNumber ?? this.pageNumber,
      lineRefsJson: lineRefsJson ?? this.lineRefsJson,
      sajda: sajda ?? this.sajda,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Ayah &&
      other.ayahId == ayahId &&
      other.surah == surah &&
      other.ayah == ayah &&
      other.pageNumber == pageNumber &&
      other.lineRefsJson == lineRefsJson &&
      other.sajda == sajda;

  @override
  int get hashCode =>
      Object.hash(ayahId, surah, ayah, pageNumber, lineRefsJson, sajda);
}
