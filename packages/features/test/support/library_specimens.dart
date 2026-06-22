// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T10 — the one registry the library-wide accessibility / honesty gate sweeps.
// Adding a component here automatically extends the gate; a shipped component with
// no entry is a deliberate test failure. Each specimen is a representative state
// of a component, built from display data + l10n only (no engine/store/clock).

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

const _region = kDefaultTermSetRegion;

PageCardViewData _pageCardData(AppLocalizations l10n) => PageCardViewData(
      page: 253,
      juz: 13,
      track: TrackFamily.far,
      trackLabel: l10n.trackFarLabel,
      decay: DecayLevel.needsRevision,
      decayLabel: l10n.decayNeedsRevision,
      state: CardState.weak,
      supportingHint: l10n.decayNeedsRevision,
    );

/// Every shipped E10 component, one representative specimen each — the registry
/// the aggregate a11y / honesty gate iterates.
List<ComponentSpecimen> librarySpecimens() => [
      ComponentSpecimen(
        name: 'page_card',
        build: (context) => MihrabPageCard(
          data: _pageCardData(AppLocalizations.of(context)),
          onOpen: () {},
        ),
      ),
      ComponentSpecimen(
        name: 'heatmap_cell',
        build: (context) {
          final l10n = AppLocalizations.of(context);
          final locale = Localizations.localeOf(context);
          return HeatmapCell(
            data: HeatmapCellData(
              level: HeatLevel.weak,
              localizedValue: formatLocaleNumber(locale, 85),
              label: l10n.decayNeedsRevision,
              everReviewed: true,
              sourceConfidence: 1,
              isJuzRollUp: true,
              weakestPageId: 253,
            ),
            onTap: () {},
          );
        },
      ),
      ComponentSpecimen(
        name: 'grade_band',
        build: (context) => GradeBand(enabled: true, onGrade: (_) {}),
      ),
      ComponentSpecimen(
        name: 'teacher_signoff_toggle',
        build: (context) =>
            TeacherSignoffToggle(teacherPresent: false, onChanged: (_) {}),
      ),
      ComponentSpecimen(
        name: 'certainty_label',
        build: (context) => CertaintyLabel(
          grade: EvidenceGrade.trad,
          strings: CertaintyStrings.of(AppLocalizations.of(context)),
        ),
      ),
      ComponentSpecimen(
        name: 'cycle_preset_picker',
        build: (context) {
          final l10n = AppLocalizations.of(context);
          return CyclePresetPicker(
            presets: [
              SettingsOption(
                value: CyclePreset.weeklyKhatm,
                label: l10n.cycleWeeklyKhatm(_region),
              ),
              SettingsOption(
                value: CyclePreset.oneJuzPerDay,
                label: l10n.cycleOneJuzPerDay(_region),
              ),
              SettingsOption(
                value: CyclePreset.custom,
                label: l10n.cycleCustom(_region),
                disclosure: true,
              ),
            ],
            selected: CyclePreset.weeklyKhatm,
            onPresetSelected: (_) {},
            pureCycleEnabled: false,
            onPureCycleChanged: (_) {},
            pureCycleLabel: l10n.cyclePureMode(_region),
            pureCycleSubtitle: l10n.cyclePureModeSubtitle,
          );
        },
      ),
      ComponentSpecimen(
        name: 'settings_picker',
        build: (context) => SettingsPicker<String>(
          selected: 'hafs',
          onSelected: (_) {},
          options: [
            SettingsOption(
              value: 'hafs',
              label: AppLocalizations.of(context).mushafRiwayahLabel,
            ),
          ],
        ),
      ),
      ComponentSpecimen(
        name: 'catch_up_banner',
        build: (context) {
          final l10n = AppLocalizations.of(context);
          final locale = Localizations.localeOf(context);
          return CatchUpBanner(
            plan: CatchUpPlan(
              missedDays: 3,
              planDays: 5,
              items: [_pageCardData(l10n)],
            ),
            empathy: l10n.catchUpEmpathy,
            factLine: toLocaleNumerals(l10n.catchUpMissedDays(3), locale),
            pathLine: toLocaleNumerals(l10n.catchUpPlanLine(5), locale),
            startLabel: l10n.catchUpStartPlan,
            adjustLabel: l10n.catchUpAdjust,
            deferLabel: l10n.catchUpDefer,
            onChoice: (_) {},
          );
        },
      ),
      ComponentSpecimen(
        name: 'empty_state',
        build: (context) => EmptyState(
          model: EmptyStateModel(
            kind: EmptyStateKind.allDone,
            body: AppLocalizations.of(context).emptyAllDone,
          ),
        ),
      ),
      ComponentSpecimen(
        name: 'reminder_row',
        build: (context) => ReminderRow(
          state: const ReminderRowState(enabled: true),
          callbacks: ReminderRowCallbacks(
            onEnabledChanged: (_) {},
            onTimeChanged: (_) {},
            onCatchUpNoteChanged: (_) {},
          ),
        ),
      ),
      ComponentSpecimen(
        name: 'destructive_confirm',
        build: (context) {
          final l10n = AppLocalizations.of(context);
          return DestructiveConfirmSheet(
            action: DestructiveAction.eraseAll,
            strings: DestructiveConfirmStrings(
              consequence: l10n.destructiveEraseAllConsequence,
              confirmLabel: l10n.destructiveEraseAllConfirm,
              cancelLabel: l10n.destructiveKeepData,
              secondConsequence: l10n.destructiveEraseAllSecondConsequence,
              secondConfirmLabel: l10n.destructiveEraseAllSecondConfirm,
            ),
            onConfirmed: () {},
            onCancelled: () {},
          );
        },
      ),
    ];

/// The component names every gate run expects to find registered — a missing
/// entry fails the build (so a new component cannot ship un-gated).
const List<String> expectedLibraryComponents = [
  'page_card',
  'heatmap_cell',
  'grade_band',
  'teacher_signoff_toggle',
  'certainty_label',
  'cycle_preset_picker',
  'settings_picker',
  'catch_up_banner',
  'empty_state',
  'reminder_row',
  'destructive_confirm',
];
