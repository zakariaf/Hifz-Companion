// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import 'enums.dart';
import 'ids.dart';

/// One immutable entry in the append-only revision audit trail (05 §2
/// `review_log`; PRD §10.2, §10.3).
///
/// Every graded revision appends exactly one [ReviewLog] row; it is **never**
/// updated or deleted by normal flows — it is the trustworthy *sanad* record of
/// what was revised, how it was graded, and (for a teacher sign-off) by whom.
/// The append-only property is enforced by the absence of any update/delete on
/// the DAO (E03-T06), and this value type offers no mutation path beyond
/// [copyWith] for construction. It carries the engine's before/after D/S as
/// audit doubles; it stores stumble **line indices**, never reconstructed
/// Quran text (R1).
@immutable
class ReviewLog {
  /// This row's UUID primary key (`review_log.log_id`).
  final LogId logId;

  /// The owning profile (FK, `ON DELETE CASCADE`).
  final ProfileId profileId;

  /// The muṣḥaf page reviewed (1–604; FK into the read-only `page` table).
  final int pageId;

  /// The wall-clock moment the review happened, stored **UTC** (the event time).
  ///
  /// A true instant, never a scheduling day — the scheduling delta is
  /// [elapsedDays]. By contract this is a UTC `DateTime`.
  final DateTime reviewedAtInstant;

  /// The track the card was on at the moment of review.
  final ReviewTrack trackAtReview;

  /// The four-level grade assigned (self-rating or teacher verdict).
  final ReviewGrade grade;

  /// The decoded stumble-line indices (the `error_lines_json` payload), or null.
  ///
  /// **Line indices only** — the highest-value signal — never Quran text (R1).
  final List<int>? errorLineIndices;

  /// The [CalendarDate]-serial day delta fed to the forgetting curve.
  ///
  /// An `int` (a count of days), not a `Duration` and not an instant.
  final int elapsedDays;

  /// The retrievability `R` the engine predicted before this review, or null.
  final double? predictedRetrievability;

  /// The FSRS stability `S` (days) before this review, or null (audit double).
  final double? stabilityDaysBefore;

  /// The FSRS stability `S` (days) after this review, or null (audit double).
  final double? stabilityDaysAfter;

  /// The FSRS difficulty `D` before this review, or null (audit double).
  final double? difficultyBefore;

  /// The FSRS difficulty `D` after this review, or null (audit double).
  final double? difficultyAfter;

  /// Whether this grade came from the ḥāfiẓ (self) or a teacher (talaqqī).
  final GradeSource source;

  /// An optional local *sanad* audit hint naming the signing teacher, or null.
  final String? teacherLabel;

  /// Creates an audit-trail row. There is no mutation path beyond [copyWith];
  /// the row is immutable once appended.
  const ReviewLog({
    required this.logId,
    required this.profileId,
    required this.pageId,
    required this.reviewedAtInstant,
    required this.trackAtReview,
    required this.grade,
    required this.elapsedDays,
    required this.source,
    this.errorLineIndices,
    this.predictedRetrievability,
    this.stabilityDaysBefore,
    this.stabilityDaysAfter,
    this.difficultyBefore,
    this.difficultyAfter,
    this.teacherLabel,
  });

  /// Returns a copy with the given fields replaced; every omitted field is
  /// preserved unchanged. Used for construction only — never to rewrite an
  /// appended row in place.
  ReviewLog copyWith({
    LogId? logId,
    ProfileId? profileId,
    int? pageId,
    DateTime? reviewedAtInstant,
    ReviewTrack? trackAtReview,
    ReviewGrade? grade,
    List<int>? errorLineIndices,
    int? elapsedDays,
    double? predictedRetrievability,
    double? stabilityDaysBefore,
    double? stabilityDaysAfter,
    double? difficultyBefore,
    double? difficultyAfter,
    GradeSource? source,
    String? teacherLabel,
  }) {
    return ReviewLog(
      logId: logId ?? this.logId,
      profileId: profileId ?? this.profileId,
      pageId: pageId ?? this.pageId,
      reviewedAtInstant: reviewedAtInstant ?? this.reviewedAtInstant,
      trackAtReview: trackAtReview ?? this.trackAtReview,
      grade: grade ?? this.grade,
      errorLineIndices: errorLineIndices ?? this.errorLineIndices,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      predictedRetrievability:
          predictedRetrievability ?? this.predictedRetrievability,
      stabilityDaysBefore: stabilityDaysBefore ?? this.stabilityDaysBefore,
      stabilityDaysAfter: stabilityDaysAfter ?? this.stabilityDaysAfter,
      difficultyBefore: difficultyBefore ?? this.difficultyBefore,
      difficultyAfter: difficultyAfter ?? this.difficultyAfter,
      source: source ?? this.source,
      teacherLabel: teacherLabel ?? this.teacherLabel,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReviewLog &&
      other.logId == logId &&
      other.profileId == profileId &&
      other.pageId == pageId &&
      other.reviewedAtInstant == reviewedAtInstant &&
      other.trackAtReview == trackAtReview &&
      other.grade == grade &&
      _intListEquals(other.errorLineIndices, errorLineIndices) &&
      other.elapsedDays == elapsedDays &&
      other.predictedRetrievability == predictedRetrievability &&
      other.stabilityDaysBefore == stabilityDaysBefore &&
      other.stabilityDaysAfter == stabilityDaysAfter &&
      other.difficultyBefore == difficultyBefore &&
      other.difficultyAfter == difficultyAfter &&
      other.source == source &&
      other.teacherLabel == teacherLabel;

  @override
  int get hashCode {
    final lines = errorLineIndices;
    return Object.hash(
      logId,
      profileId,
      pageId,
      reviewedAtInstant,
      trackAtReview,
      grade,
      lines == null ? null : Object.hashAll(lines),
      elapsedDays,
      predictedRetrievability,
      stabilityDaysBefore,
      stabilityDaysAfter,
      difficultyBefore,
      difficultyAfter,
      source,
      teacherLabel,
    );
  }
}

/// Value equality for the nullable stumble-line-index lists (no
/// `package:collection` dependency at Layer 0).
bool _intListEquals(List<int>? a, List<int>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
