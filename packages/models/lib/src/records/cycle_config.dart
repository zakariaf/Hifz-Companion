// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import 'ids.dart';

/// One profile's revision-cycle configuration — the named preset and the
/// engine's per-day targets and ceiling (05 §2 `cycle_config`; PRD §10.2,
/// §7.6).
///
/// Exactly one row per profile. [cycleCeilingDays] is the load-bearing cycle
/// ceiling: the TRUST CLAMP never schedules a page past it, so a page is never
/// silently allowed to decay beyond its cycle. The named-preset closed set
/// (`'7_manzil'`, `'1_juz_day'`, …) is validated at the feature/engine layer,
/// not pinned here, since presets evolve (E03-T03 keeps `cycle_type` free TEXT).
@immutable
class CycleConfig {
  /// The owning profile — primary key and FK in one (`ON DELETE CASCADE`).
  final ProfileId profileId;

  /// The named cycle preset (e.g. `'7_manzil'`, `'1_juz_day'`, `'custom'`).
  final String cycleType;

  /// New lines introduced per day (sabaq intake; `≥ 0`, default 0).
  final int newLinesPerDay;

  /// The near-revision window width in juz (`≥ 0`).
  final int nearWindowJuz;

  /// The far-revision target pages per day (`≥ 0`).
  final int farTargetPerDay;

  /// The far-cycle ceiling in **days** — the maximum interval the TRUST CLAMP
  /// allows (`> 0`; PRD §7.6). Named for what it *is*, not its column
  /// (`far_cycle_days`).
  final int cycleCeilingDays;

  /// The daily revision time budget in **minutes** (`> 0`).
  final int dailyBudgetMinutes;

  /// Whether pure-cycle mode is on (the manzil cycle drives everything).
  final bool isPureCycleMode;

  /// The sabaq/sabqi/manzil terminology set the UI renders (a key into `l10n`).
  final String termLabelSet;

  /// An optional regional preset hint, or null.
  final String? regionPreset;

  /// Creates a profile's cycle configuration. [newLinesPerDay] defaults to 0;
  /// the other targets are required.
  const CycleConfig({
    required this.profileId,
    required this.cycleType,
    required this.nearWindowJuz,
    required this.farTargetPerDay,
    required this.cycleCeilingDays,
    required this.dailyBudgetMinutes,
    required this.termLabelSet,
    this.newLinesPerDay = 0,
    this.isPureCycleMode = false,
    this.regionPreset,
  });

  /// Returns a copy with the given fields replaced; every omitted field is
  /// preserved unchanged.
  CycleConfig copyWith({
    ProfileId? profileId,
    String? cycleType,
    int? newLinesPerDay,
    int? nearWindowJuz,
    int? farTargetPerDay,
    int? cycleCeilingDays,
    int? dailyBudgetMinutes,
    bool? isPureCycleMode,
    String? termLabelSet,
    String? regionPreset,
  }) {
    return CycleConfig(
      profileId: profileId ?? this.profileId,
      cycleType: cycleType ?? this.cycleType,
      newLinesPerDay: newLinesPerDay ?? this.newLinesPerDay,
      nearWindowJuz: nearWindowJuz ?? this.nearWindowJuz,
      farTargetPerDay: farTargetPerDay ?? this.farTargetPerDay,
      cycleCeilingDays: cycleCeilingDays ?? this.cycleCeilingDays,
      dailyBudgetMinutes: dailyBudgetMinutes ?? this.dailyBudgetMinutes,
      isPureCycleMode: isPureCycleMode ?? this.isPureCycleMode,
      termLabelSet: termLabelSet ?? this.termLabelSet,
      regionPreset: regionPreset ?? this.regionPreset,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CycleConfig &&
      other.profileId == profileId &&
      other.cycleType == cycleType &&
      other.newLinesPerDay == newLinesPerDay &&
      other.nearWindowJuz == nearWindowJuz &&
      other.farTargetPerDay == farTargetPerDay &&
      other.cycleCeilingDays == cycleCeilingDays &&
      other.dailyBudgetMinutes == dailyBudgetMinutes &&
      other.isPureCycleMode == isPureCycleMode &&
      other.termLabelSet == termLabelSet &&
      other.regionPreset == regionPreset;

  @override
  int get hashCode => Object.hash(
        profileId,
        cycleType,
        newLinesPerDay,
        nearWindowJuz,
        farTargetPerDay,
        cycleCeilingDays,
        dailyBudgetMinutes,
        isPureCycleMode,
        termLabelSet,
        regionPreset,
      );
}
