// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show CalendarDate, JuzConfidence;
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';
import 'when_memorized_input.dart';

/// The per-juz confidence rater (E11-T06): for each **held** juz (in muṣḥaf
/// order), one mutually-exclusive Solid / Shaky / Rusty self-report pick. The
/// labels are honest self-description, never praise, a score, an exclamation, or
/// any seeded `D`/`S`/`R` — the engine owns the `_coldStartSeed` table; this View
/// only captures the chosen [JuzConfidence] and hands it on unchanged.
///
/// The three picks read as plain pill-tiles carrying a circle glyph (filled /
/// half / empty) beside the word — shape and word carry the level, never a
/// traffic-light hue; the chosen pill fills with the one accent.
class ConfidenceStep extends StatelessWidget {
  /// Creates the rater for the [heldJuz].
  const ConfidenceStep({
    required this.heldJuz,
    required this.confidence,
    required this.onPick,
    required this.memorizedOn,
    required this.today,
    required this.calendarSystem,
    required this.onSetMemorized,
    required this.onClearMemorized,
    super.key,
  });

  /// The held juz to rate (rendered in ascending muṣḥaf order).
  final Set<int> heldJuz;

  /// The current per-juz confidence selections.
  final Map<int, JuzConfidence> confidence;

  /// Called when a juz's confidence is picked.
  final void Function(int juz, JuzConfidence confidence) onPick;

  /// The optional per-juz "when memorized" dates (E11-T07).
  final Map<int, CalendarDate> memorizedOn;

  /// The injected "today" used to resolve a coarse "when memorized" band.
  final CalendarDate today;

  /// The explicit calendar the stored "when memorized" date is displayed in.
  final CalendarSystem calendarSystem;

  /// Called with the resolved "when memorized" date for a juz.
  final void Function(int juz, CalendarDate date) onSetMemorized;

  /// Called to clear a juz's "when memorized" date back to skipped.
  final void Function(int juz) onClearMemorized;

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
          return _ConfidenceTitle(title: l10n.onboardingConfidenceTitle);
        }
        if (index == ordered.length + 1) {
          return _BiasNote(text: l10n.confidenceBiasNote);
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
            _ConfidencePills(
              selected: confidence[juz],
              onPick: (value) => onPick(juz, value),
            ),
            // The optional "when memorized" date sits beneath the rater (E11-T07).
            WhenMemorizedInput(
              juz: juz,
              value: memorizedOn[juz],
              today: today,
              calendarSystem: calendarSystem,
              onSet: onSetMemorized,
              onClear: onClearMemorized,
            ),
          ],
        );
      },
    );
  }
}

/// The step title.
class _ConfidenceTitle extends StatelessWidget {
  const _ConfidenceTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) =>
      Text(title, style: Theme.of(context).textTheme.titleLarge);
}

/// The three mutually-exclusive confidence pills for one juz.
class _ConfidencePills extends StatelessWidget {
  const _ConfidencePills({required this.selected, required this.onPick});

  final JuzConfidence? selected;
  final ValueChanged<JuzConfidence> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    // Shape carries the level (a filled, a half, an empty circle); colour is
    // the same calm neutral for every resting pill — never a traffic light.
    final resting = theme.colorScheme.onSurfaceVariant;
    return Row(
      spacing: space.space2,
      children: [
        Expanded(
          child: _ConfidencePill(
            value: JuzConfidence.solid,
            icon: Icons.circle,
            label: l10n.confidenceSolid,
            semanticsLabel: l10n.confidenceSolidSemantics,
            restingGlyph: resting,
            selected: selected == JuzConfidence.solid,
            onPick: onPick,
          ),
        ),
        Expanded(
          child: _ConfidencePill(
            value: JuzConfidence.shaky,
            icon: Icons.contrast,
            label: l10n.confidenceShaky,
            semanticsLabel: l10n.confidenceShakySemantics,
            restingGlyph: resting,
            selected: selected == JuzConfidence.shaky,
            onPick: onPick,
          ),
        ),
        Expanded(
          child: _ConfidencePill(
            value: JuzConfidence.rusty,
            icon: Icons.circle_outlined,
            label: l10n.confidenceRusty,
            semanticsLabel: l10n.confidenceRustySemantics,
            restingGlyph: resting,
            selected: selected == JuzConfidence.rusty,
            onPick: onPick,
          ),
        ),
      ],
    );
  }
}

class _ConfidencePill extends StatelessWidget {
  const _ConfidencePill({
    required this.value,
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.restingGlyph,
    required this.selected,
    required this.onPick,
  });

  final JuzConfidence value;
  final IconData icon;
  final String label;
  final String semanticsLabel;
  final Color restingGlyph;
  final bool selected;
  final ValueChanged<JuzConfidence> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final radius = BorderRadius.circular(space.space3);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: semanticsLabel,
      child: InkWell(
        onTap: () => onPick(value),
        borderRadius: radius,
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              color: selected ? scheme.primary : scheme.surface,
              border: Border.all(
                color: selected ? scheme.primary : scheme.outlineVariant,
              ),
            ),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: space.space8 + space.space2),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  vertical: space.space2,
                  horizontal: space.space2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: space.space1,
                  children: [
                    Icon(
                      icon,
                      color: selected ? scheme.onPrimary : restingGlyph,
                      size: space.space5,
                    ),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The trailing calm bias note (C-009): a plain-spoken reassurance that nothing
/// is judged yet, fronted by a quiet shield — never a number, score, or warning.
class _BiasNote extends StatelessWidget {
  const _BiasNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: space.space2,
          children: [
            Icon(
              Icons.shield_outlined,
              size: space.space5,
              color: scheme.onSurfaceVariant,
            ),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
