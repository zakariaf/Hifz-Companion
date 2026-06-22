// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import '../../design_system/pickers/cycle_preset_picker.dart' show CyclePreset;

/// The named preset → far-cycle-length (days) mapping — the cycle ceiling the
/// trust clamp reads (`EngineConfig.farCycleDays`). This is the picker's entire
/// scheduling effect: 7-Manzil weekly khatm → 7, 1 juz/day → 30, ½ juz/day → 60,
/// 2 juz/day → 15. [CyclePreset.custom] returns `null` — a custom cycle carries
/// its own `farCycleDays`. There is **no `target_R`** anywhere: a named cycle,
/// never a retention dial (PRD §15.1; engine §6).
int? farCycleDaysFor(CyclePreset preset) => switch (preset) {
      CyclePreset.weeklyKhatm => 7,
      CyclePreset.oneJuzPerDay => 30,
      CyclePreset.halfJuzPerDay => 60,
      CyclePreset.twoJuzPerDay => 15,
      CyclePreset.custom => null,
    };
