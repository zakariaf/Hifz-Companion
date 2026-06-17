// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import 'ids.dart';

/// A sub-page range of lines that a profile repeatedly stumbles on, created
/// **lazily** only for a page that keeps lapsing (05 §2 `line_block`; PRD
/// §10.2).
///
/// It narrows revision to the troublesome lines of a page rather than the whole
/// page. It stores only line **numbers** ([lineStart]/[lineEnd], 1–15) and a
/// stumble [errorCount] — never any Quran text (R1); the lines themselves are
/// rendered from the immutable glyph layer (`quran` package).
@immutable
class LineBlock {
  /// This block's UUID primary key (`line_block.block_id`).
  final BlockId blockId;

  /// The owning profile (FK, `ON DELETE CASCADE`).
  final ProfileId profileId;

  /// The muṣḥaf page this block is on (1–604; FK into the read-only `page`
  /// table, no cascade).
  final int pageId;

  /// The first line of the range (1–15; schema `CHECK (line_start BETWEEN 1 AND
  /// 15)`, E03-T03).
  final int lineStart;

  /// The last line of the range (`lineStart ≤ lineEnd ≤ 15`; schema `CHECK
  /// (line_end BETWEEN line_start AND 15)`, E03-T03).
  final int lineEnd;

  /// How many times this range has been stumbled on (`≥ 0`, default 0).
  final int errorCount;

  /// Creates a line block. [errorCount] defaults to 0.
  const LineBlock({
    required this.blockId,
    required this.profileId,
    required this.pageId,
    required this.lineStart,
    required this.lineEnd,
    this.errorCount = 0,
  });

  /// Returns a copy with the given fields replaced; every omitted field is
  /// preserved unchanged.
  LineBlock copyWith({
    BlockId? blockId,
    ProfileId? profileId,
    int? pageId,
    int? lineStart,
    int? lineEnd,
    int? errorCount,
  }) {
    return LineBlock(
      blockId: blockId ?? this.blockId,
      profileId: profileId ?? this.profileId,
      pageId: pageId ?? this.pageId,
      lineStart: lineStart ?? this.lineStart,
      lineEnd: lineEnd ?? this.lineEnd,
      errorCount: errorCount ?? this.errorCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LineBlock &&
      other.blockId == blockId &&
      other.profileId == profileId &&
      other.pageId == pageId &&
      other.lineStart == lineStart &&
      other.lineEnd == lineEnd &&
      other.errorCount == errorCount;

  @override
  int get hashCode => Object.hash(
        blockId,
        profileId,
        pageId,
        lineStart,
        lineEnd,
        errorCount,
      );
}
