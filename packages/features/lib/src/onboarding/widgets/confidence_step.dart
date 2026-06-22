// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show JuzConfidence;
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// The per-juz confidence rater (E11-T06): for each **held** juz (in muṣḥaf
/// order), one mutually-exclusive Solid / Shaky / Rusty self-report pick. The
/// labels are honest self-description, never praise, a score, an exclamation, or
/// any seeded `D`/`S`/`R` — the engine owns the `_coldStartSeed` table; this View
/// only captures the chosen [JuzConfidence] and hands it on unchanged. Rusty is
/// calm (the same M3 selected tone), never alarm-red; each option carries colour
/// **and** a text label (never colour alone).
///
/// A dumb View: it takes the ordered held juz + the current [confidence] map +
/// [onPick] and renders. It reads no clock, seeds nothing, and persists nothing
/// (the seed is E11-T09's single write path). The optional "when memorized"
/// sub-control (E11-T07) renders beneath each row.
class ConfidenceStep extends StatelessWidget {
  /// Creates the rater for the [heldJuz].
  const ConfidenceStep({
    required this.heldJuz,
    required this.confidence,
    required this.onPick,
    super.key,
  });

  /// The held juz to rate (rendered in ascending muṣḥaf order).
  final Set<int> heldJuz;

  /// The current per-juz confidence selections.
  final Map<int, JuzConfidence> confidence;

  /// Called when a juz's confidence is picked.
  final void Function(int juz, JuzConfidence confidence) onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final locale = Localizations.localeOf(context);
    final ordered = heldJuz.toList()..sort();

    return ListView.separated(
      padding: EdgeInsetsDirectional.all(space.space4),
      // +2: a leading title and a trailing calm bias note (C-009).
      itemCount: ordered.length + 2,
      separatorBuilder: (context, _) => SizedBox(height: space.space4),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            l10n.onboardingConfidenceTitle,
            style: theme.textTheme.titleLarge,
          );
        }
        if (index == ordered.length + 1) {
          return Text(
            l10n.confidenceBiasNote,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          );
        }
        final juz = ordered[index - 1];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: space.space2,
          children: [
            Text(
              l10n.juzLabel(formatLocaleNumber(locale, juz)),
              style: theme.textTheme.titleMedium,
            ),
            SegmentedButton<JuzConfidence>(
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              segments: <ButtonSegment<JuzConfidence>>[
                ButtonSegment(
                  value: JuzConfidence.solid,
                  label: Text(
                    l10n.confidenceSolid,
                    semanticsLabel: l10n.confidenceSolidSemantics,
                  ),
                ),
                ButtonSegment(
                  value: JuzConfidence.shaky,
                  label: Text(
                    l10n.confidenceShaky,
                    semanticsLabel: l10n.confidenceShakySemantics,
                  ),
                ),
                ButtonSegment(
                  value: JuzConfidence.rusty,
                  label: Text(
                    l10n.confidenceRusty,
                    semanticsLabel: l10n.confidenceRustySemantics,
                  ),
                ),
              ],
              selected: <JuzConfidence>{
                if (confidence[juz] != null) confidence[juz]!,
              },
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) onPick(juz, selection.first);
              },
            ),
          ],
        );
      },
    );
  }
}
