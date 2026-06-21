// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show JuzConfidence;
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// For each held juz, one mutually-exclusive Solid / Shaky / Rusty self-report
/// pick (an M3 `SegmentedButton`). Honest self-report register — never praise or
/// a score. A domain-blind View: it takes the ordered held juz + the current
/// [confidence] map + [onPick] and renders.
class JuzConfidenceRater extends StatelessWidget {
  /// Creates the rater for the held juz.
  const JuzConfidenceRater({
    required this.heldJuz,
    required this.confidence,
    required this.onPick,
    super.key,
  });

  /// The held juz to rate.
  final Set<int> heldJuz;

  /// The current per-juz confidence selections.
  final Map<int, JuzConfidence> confidence;

  /// Called when a juz's confidence is picked.
  final void Function(int juz, JuzConfidence confidence) onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final numerals =
        numberFormatFor(Localizations.localeOf(context).languageCode);
    final ordered = heldJuz.toList()..sort();
    return ListView.separated(
      padding: EdgeInsetsDirectional.all(space.space4),
      itemCount: ordered.length,
      separatorBuilder: (context, _) => SizedBox(height: space.space4),
      itemBuilder: (context, index) {
        final juz = ordered[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: space.space2,
          children: [
            Text(
              numerals.format(juz),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SegmentedButton<JuzConfidence>(
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              segments: <ButtonSegment<JuzConfidence>>[
                ButtonSegment(
                  value: JuzConfidence.solid,
                  label: Text(l10n.confidenceSolid),
                ),
                ButtonSegment(
                  value: JuzConfidence.shaky,
                  label: Text(l10n.confidenceShaky),
                ),
                ButtonSegment(
                  value: JuzConfidence.rusty,
                  label: Text(l10n.confidenceRusty),
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
