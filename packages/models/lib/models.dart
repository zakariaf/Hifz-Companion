// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// Immutable domain value types for Hifz Companion (the bottom of the package
/// graph): the [CalendarDate] scheduling-day type, the closed-set enums, the
/// typed ids, and the six persisted user records the `data` DAOs map rows to
/// and from. Pure Dart — `dart:core` / `package:meta` only, no Flutter, no I/O.
library;

export 'src/dates/calendar_date.dart' show CalendarDate;
export 'src/records/card.dart' show Card;
export 'src/records/confusion_edge.dart' show ConfusionEdge;
export 'src/records/cycle_config.dart' show CycleConfig;
export 'src/records/enums.dart'
    show GradeSource, ProfileLocale, ProfileRole, ReviewGrade, ReviewTrack;
export 'src/records/ids.dart' show BlockId, LogId, ProfileId;
export 'src/records/line_block.dart' show LineBlock;
export 'src/records/profile.dart' show Profile;
export 'src/records/review_log.dart' show ReviewLog;
