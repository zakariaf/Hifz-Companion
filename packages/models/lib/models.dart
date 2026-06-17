// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// Immutable domain value types for Hifz Companion (the bottom of the package
/// graph): the [CalendarDate] scheduling-day type, the closed-set enums, the
/// typed ids, the six persisted user records, and the read-only Quran reference
/// DTOs the `data` DAOs map rows to and from. Pure Dart — `dart:core` /
/// `package:meta` only, no Flutter, no I/O.
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
export 'src/records/review_outcome.dart' show ReviewOutcome;
export 'src/reference/ayah.dart' show Ayah;
export 'src/reference/line.dart' show Line;
export 'src/reference/mushaf.dart' show Mushaf;
export 'src/reference/mutashabih_group.dart' show MutashabihGroup;
export 'src/reference/mutashabih_member.dart' show MutashabihMember;
export 'src/reference/page.dart' show Page;
export 'src/reference/reference_enums.dart'
    show LineType, MutashabihType, Revelation;
export 'src/reference/surah.dart' show Surah;
