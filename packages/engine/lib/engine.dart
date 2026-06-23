// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The pure-Dart Hifz scheduling engine: total functions over immutable value
/// types, with "today" always injected as a `CalendarDate` — no Flutter, no
/// I/O, no wall clock, no randomness.
///
/// The real FSRS-style D/S/R math — retrievability, interval, the review
/// update, the sabaq/sabqi/manzil tracks, cold start, the load balancer, and
/// the TRUST CLAMP — plus its frozen golden vectors and `glados` invariants are
/// authored across E04.
///
/// The engine's persisted I/O value types live in `models` and are re-exported
/// here so scheduling code imports them by their single canonical name: the
/// injected-`today` [CalendarDate] (the spec's `SerialDay`), the [Card] the
/// engine reads and returns, the [CardSeed] cold start produces, and the
/// [ReviewTrack]/[ReviewGrade]/[GradeSource] closed-set enums. The engine-only
/// *input* types it consumes but never persists — [ReviewInput] and
/// [JuzConfidence] — are defined in this package.
library;

export 'package:models/models.dart'
    show CalendarDate, Card, CardSeed, GradeSource, ReviewGrade, ReviewTrack;
export 'src/confusion_bump.dart' show applyConfusionBump;
export 'src/constants.dart'
    show
        kConfusionDifficultyBump,
        kCriticalTargetR,
        kDefaultWeights45,
        kFarMinS,
        kFarTargetR,
        kFsrsWeightCount,
        kGraduationSignoffs,
        kHardFloorR,
        kLapseDifficultyBump,
        kMaxInterval,
        kMinStability,
        kNearMinS,
        kNearTargetR,
        kNewTargetR,
        kSelfConfidence,
        kWeakLineFactor;
export 'src/build_today.dart'
    show
        BuildDay,
        ConfusionSiblings,
        RecentWindow,
        expandMutashabihat,
        retentionFloor;
export 'src/cold_start.dart' show ColdStart;
export 'src/curve.dart' show interval, kDecay, kFactor, retrievability;
export 'src/dates/civil_day_of.dart' show civilDayOf;
export 'src/day_math.dart'
    show catchUpWindow, dueWithCeiling, elapsedDays, nextDue;
export 'src/day_plan.dart' show DayPlan;
export 'src/engine_config.dart' show EngineConfig;
export 'src/grading/recitation_grading.dart' show RecitationGrading;
export 'src/juz_confidence.dart' show JuzConfidence;
export 'src/load_balance.dart' show LoadBalance, estMinutes;
export 'src/mutashabih_groups.dart' show MutashabihGroups, confusionSiblingsFor;
export 'src/phases.dart'
    show bandForStability, phaseOf, targetR, trackStrength, updateGraduation;
export 'src/review_input.dart' show ReviewInput;
export 'src/review_update.dart'
    show
        ReviewUpdate,
        initialDifficulty,
        nextDifficulty,
        postLapseStability,
        stabilityOnSuccess;
export 'src/scheduling_engine.dart' show SchedulingEngine;
export 'src/trust_clamp.dart' show TrustClamp, cycleCeilingDays;
