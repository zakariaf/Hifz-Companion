// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import '../reference/pages.dart';
import 'profiles.dart';

/// The `review_log` user table — the **append-only** revision audit trail (05
/// §2; PRD §10.3).
///
/// `INSERT` only: no DAO exposes an `UPDATE`/`DELETE` (E03-T06), and this table
/// invites none — no mutable-status or `is_deleted` column. `reviewed_at` is a
/// UTC ISO-8601 instant (TEXT); `elapsed_days` is a `CalendarDate`-serial delta
/// (INTEGER). `error_lines_json` holds stumble line indices only, never Quran
/// text (R1). `STRICT`. Index `review_log_by_card (profile_id, page_id,
/// reviewed_at)`.
@DataClassName('ReviewLogRow')
@TableIndex(
  name: 'review_log_by_card',
  columns: {#profileId, #pageId, #reviewedAt},
)
class ReviewLog extends Table {
  @override
  String get tableName => 'review_log';

  /// The log-row UUID (PK).
  TextColumn get logId => text()();

  /// The owning profile (FK, `ON DELETE CASCADE`).
  TextColumn get profileId =>
      text().references(Profiles, #profileId, onDelete: KeyAction.cascade)();

  /// The muṣḥaf page reviewed (FK into `page`, no cascade).
  IntColumn get pageId => integer().references(Pages, #pageId)();

  /// The event wall-clock moment — UTC ISO-8601 TEXT, never a scheduling day.
  TextColumn get reviewedAt => text()();

  /// The track at the moment of review.
  TextColumn get trackAtReview => text()();

  /// The four-level grade assigned.
  TextColumn get grade => text()();

  /// Stumble line indices (small structural list), or null — never text.
  TextColumn get errorLinesJson => text().nullable()();

  /// The `CalendarDate`-serial day delta fed to the curve.
  IntColumn get elapsedDays => integer()();

  /// Predicted retrievability `R` (audit double), or null.
  RealColumn get rPredicted => real().nullable()();

  /// Stability `S` before (audit double), or null.
  RealColumn get sBefore => real().nullable()();

  /// Stability `S` after (audit double), or null.
  RealColumn get sAfter => real().nullable()();

  /// Difficulty `D` before (audit double), or null.
  RealColumn get dBefore => real().nullable()();

  /// Difficulty `D` after (audit double), or null.
  RealColumn get dAfter => real().nullable()();

  /// `self` (reveal-on-tap) or `teacher` (talaqqī sign-off).
  TextColumn get source => text()();

  /// Optional local *sanad* audit hint naming the signing teacher, or null.
  TextColumn get teacherLabel => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {logId};

  @override
  List<String> get customConstraints => const [
        "CHECK (track_at_review IN ('NEW', 'NEAR', 'FAR', 'UNMEMORIZED'))",
        "CHECK (grade IN ('again', 'hard', 'good', 'easy'))",
        "CHECK (source IN ('self', 'teacher'))",
      ];

  @override
  bool get isStrict => true;
}
