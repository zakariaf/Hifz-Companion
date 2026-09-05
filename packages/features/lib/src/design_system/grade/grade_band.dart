// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../l10n/term_set.dart' show kDefaultTermSetRegion;
import '../state/mihrab_state_layer.dart';
import '../theme/mihrab_colors.dart';
import '../theme/spacing_tokens.dart';
import 'grade_choice.dart';

/// The four-level self-grade band (design-system 07 §5) — a row of large
/// thumb-zone `FilledButton`s for Again / Hard / Good / Easy, the calm sibling of
/// the page card.
///
/// Domain-blind: it renders the four canonical interaction states from
/// `MihrabStateLayer` and emits the chosen [GradeChoice] through a single
/// [onGrade]; it persists nothing, recomputes no schedule, applies **no**
/// sacred-text guard or cap (that is E12), and **never celebrates** a grade.
/// When [enabled] is false it is the calm *disabled-until-revealed* state —
/// dimmed and *waiting, not error*, with a quiet "reveal to grade" hint.
class GradeBand extends StatelessWidget {
  /// Creates the band; [enabled] false is the waiting (pre-reveal) state.
  const GradeBand({required this.enabled, required this.onGrade, super.key});

  /// Whether the band accepts a grade (false = disabled-until-revealed).
  final bool enabled;

  /// Emits the chosen grade; the single output of the band.
  final ValueChanged<GradeChoice> onGrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final colors = theme.extension<MihrabColors>()!;
    final text = theme.textTheme;

    // Each tile is a calm limestone mihrab-tile (a `surfaceContainer` fill), the
    // short grade name atop the region-aware term-set descriptor (E09), keyed by
    // a thin bottom glaze-strip from the Mihrab earthen/heat-map palette — a
    // quiet zellige accent, redundant with the text (never colour alone) and
    // never a severity/traffic-light or reward tier. The spoken phrase is the
    // verdict + calm consequence. Logical order [again, hard, good, easy] reads
    // right-to-left under RTL as a result of the row geometry.
    const region = kDefaultTermSetRegion;
    final grades = <(GradeChoice, String, String, String, Color)>[
      (
        GradeChoice.again,
        l10n.gradeAgain,
        l10n.gradeAgainVerb(region),
        l10n.gradeAgainSemantics,
        colors.semanticWarning,
      ),
      (
        GradeChoice.hard,
        l10n.gradeHard,
        l10n.gradeHardVerb(region),
        l10n.gradeHardSemantics,
        scheme.onSurfaceVariant,
      ),
      (
        GradeChoice.good,
        l10n.gradeGood,
        l10n.gradeGoodVerb(region),
        l10n.gradeGoodSemantics,
        colors.heatmapGood,
      ),
      (
        GradeChoice.easy,
        l10n.gradeEasy,
        l10n.gradeEasyVerb(region),
        l10n.gradeEasySemantics,
        colors.heatmapStrong,
      ),
    ];

    // A restrained limestone tile: the M3 `surfaceContainer` fill (not the primary
    // fill), a hairline outline, no elevation, ≥56dp tall (05 §5), padding removed
    // so the bottom glaze-strip runs full-bleed to the clipped corners.
    final tileStyle = FilledButton.styleFrom(
      minimumSize: Size(space.space8, space.space8 + space.space2),
      backgroundColor: scheme.surfaceContainer,
      foregroundColor: scheme.onSurface,
      padding: EdgeInsets.zero,
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(space.space4),
      ),
    ).copyWith(overlayColor: MihrabStateLayer.overlayColor(scheme.onSurface));

    Widget tile((GradeChoice, String, String, String, Color) grade) {
      final (choice, name, verb, semantics, accent) = grade;
      // Disabled reads as *waiting, not error*: the whole tile — strip included —
      // is dimmed, never recoloured to an alarm hue (07 §6).
      final stripColor = enabled
          ? accent
          : accent.withValues(alpha: MihrabStateLayer.disabledOpacity);
      return MihrabFocusRing(
        child: FilledButton(
          onPressed: enabled ? () => onGrade(choice) : null,
          clipBehavior: Clip.antiAlias,
          style: tileStyle,
          // The spoken phrase is verdict + consequence; the visible name/verb is
          // excluded from semantics to avoid a duplicate read.
          child: Semantics(
            label: semantics,
            child: ExcludeSemantics(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: space.space2,
                      vertical: space.space3,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: text.titleMedium,
                        ),
                        SizedBox(height: space.space1),
                        Text(
                          verb,
                          textAlign: TextAlign.center,
                          style: text.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(height: space.space1, color: stripColor),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // `IntrinsicHeight` gives the row a bounded cross-axis extent so the
        // four tiles stretch to one shared height (their bottom glaze-strips
        // align), without the unbounded-height a bare stretched Row would hit.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < grades.length; i++) ...[
                if (i > 0) SizedBox(width: space.space2),
                Expanded(child: tile(grades[i])),
              ],
            ],
          ),
        ),
        if (!enabled) ...[
          SizedBox(height: space.space2),
          Text(
            l10n.gradeBandWaitingHint,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
