// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../l10n/term_set.dart' show kDefaultTermSetRegion;
import '../state/mihrab_state_layer.dart';
import '../theme/spacing_tokens.dart';
import '../widgets/mihrab_buttons.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;

    // The visible verbs come from the existing region-aware term-set selects
    // (E09): "needed help" / "minor mistakes" / "recited clean" / "effortless"
    // at the default region. The spoken phrase adds the calm consequence.
    const region = kDefaultTermSetRegion;
    final grades = <(GradeChoice, String, String)>[
      (GradeChoice.again, l10n.gradeAgainVerb(region), l10n.gradeAgainSemantics),
      (GradeChoice.hard, l10n.gradeHardVerb(region), l10n.gradeHardSemantics),
      (GradeChoice.good, l10n.gradeGoodVerb(region), l10n.gradeGoodSemantics),
      (GradeChoice.easy, l10n.gradeEasyVerb(region), l10n.gradeEasySemantics),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logical order [again, hard, good, easy] reads right-to-left under RTL
        // as a result of the geometry; Wrap lets it reflow (not clip) at 200%.
        Wrap(
          spacing: space.space2,
          runSpacing: space.space2,
          children: [
            for (final (choice, verb, semantics) in grades)
              MihrabFocusRing(
                child: FilledButton(
                  onPressed: enabled ? () => onGrade(choice) : null,
                  style: mihrabTallFilledButtonStyle().copyWith(
                    overlayColor:
                        MihrabStateLayer.overlayColor(scheme.onPrimary),
                  ),
                  // The spoken phrase is verdict + consequence; the visible verb
                  // is excluded from semantics to avoid a duplicate read.
                  child: Semantics(
                    label: semantics,
                    child: ExcludeSemantics(
                      child: Text(verb, textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ),
          ],
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
