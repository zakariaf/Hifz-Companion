// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart';

import '../database.dart';
// Prefixed: the Drift table class `ReviewLog` shares its name with the
// models value type; the annotation references the table, the mappers the model.
import '../tables/user/review_log.dart' as schema;
import 'mappers.dart';

part 'review_log_dao.g.dart';

/// **Append + read only** access to the `review_log` audit trail (05 §2; PRD
/// §10.3).
///
/// There is deliberately **no** `update`/`delete`/`replace`/`clear` method —
/// the append-only *sanad* property is enforced by the *absence* of any
/// mutation surface, reviewed in CI. The only sanctioned bulk touch is export /
/// one-tap erase (E17). No Drift symbol crosses the public surface.
@DriftAccessor(tables: [schema.ReviewLog])
class ReviewLogDao extends DatabaseAccessor<HifzDatabase>
    with _$ReviewLogDaoMixin {
  /// Creates the DAO over [db].
  ReviewLogDao(super.db);

  /// Appends one immutable audit row. Never updates or deletes one.
  Future<void> insert(ReviewLog log) =>
      into(reviewLog).insert(_toCompanion(log));

  /// The audit rows for one card, oldest first.
  Future<List<ReviewLog>> forCard(ProfileId profileId, int pageId) async {
    final query = select(reviewLog)
      ..where(
        (r) => r.profileId.equals(profileId.value) & r.pageId.equals(pageId),
      )
      ..orderBy([(r) => OrderingTerm.asc(r.reviewedAt)]);
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  /// All audit rows for a profile, oldest first.
  Future<List<ReviewLog>> forProfile(ProfileId profileId) async {
    final query = select(reviewLog)
      ..where((r) => r.profileId.equals(profileId.value))
      ..orderBy([(r) => OrderingTerm.asc(r.reviewedAt)]);
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  ReviewLog _toModel(ReviewLogRow row) {
    return ReviewLog(
      logId: LogId(row.logId),
      profileId: ProfileId(row.profileId),
      pageId: row.pageId,
      reviewedAtInstant: instantFromWire(row.reviewedAt),
      trackAtReview: enumFromWire(
        ReviewTrack.values,
        (t) => t.wireValue,
        row.trackAtReview,
        'ReviewTrack',
      ),
      grade: enumFromWire(
        ReviewGrade.values,
        (g) => g.wireValue,
        row.grade,
        'ReviewGrade',
      ),
      errorLineIndices: lineIndicesFromJson(row.errorLinesJson),
      elapsedDays: row.elapsedDays,
      predictedRetrievability: row.rPredicted,
      stabilityDaysBefore: row.sBefore,
      stabilityDaysAfter: row.sAfter,
      difficultyBefore: row.dBefore,
      difficultyAfter: row.dAfter,
      source: enumFromWire(
        GradeSource.values,
        (s) => s.wireValue,
        row.source,
        'GradeSource',
      ),
      teacherLabel: row.teacherLabel,
    );
  }

  ReviewLogCompanion _toCompanion(ReviewLog log) {
    return ReviewLogCompanion(
      logId: Value(log.logId.value),
      profileId: Value(log.profileId.value),
      pageId: Value(log.pageId),
      reviewedAt: Value(instantToWire(log.reviewedAtInstant)),
      trackAtReview: Value(log.trackAtReview.wireValue),
      grade: Value(log.grade.wireValue),
      errorLinesJson: Value(lineIndicesToJson(log.errorLineIndices)),
      elapsedDays: Value(log.elapsedDays),
      rPredicted: Value(log.predictedRetrievability),
      sBefore: Value(log.stabilityDaysBefore),
      sAfter: Value(log.stabilityDaysAfter),
      dBefore: Value(log.difficultyBefore),
      dAfter: Value(log.difficultyAfter),
      source: Value(log.source.wireValue),
      teacherLabel: Value(log.teacherLabel),
    );
  }
}
