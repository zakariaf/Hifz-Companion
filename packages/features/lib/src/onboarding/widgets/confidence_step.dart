// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show CalendarDate, JuzConfidence;
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/spacing_tokens.dart';
import 'onboarding_glyphs.dart';
import 'when_memorized_input.dart';

/// The per-juz confidence rater (E11-T06): for each **held** juz (in muṣḥaf
/// order), one mutually-exclusive Solid / Shaky / Rusty self-report pick. The
/// labels are honest self-description, never praise, a score, an exclamation, or
/// any seeded `D`/`S`/`R` — the engine owns the `_coldStartSeed` table; this View
/// only captures the chosen [JuzConfidence] and hands it on unchanged.
///
/// The three picks read as miḥrāb pill-tiles carrying a zellige-star glyph
/// (solid → filled, shaky → hollow, rusty → dashed) **and** a text label — the
/// state is never hue alone (SC 1.4.1). A chosen pick fills with the one calm
/// glazed-teal selected tone (Rusty is never alarm-red); the warm-clay hint sits
/// only in Rusty's resting glyph.
///
/// A dumb View: it takes the ordered held juz + the current [confidence] map +
/// [onPick] and renders. It reads no clock, seeds nothing, and persists nothing
/// (the seed is E11-T09's single write path). The optional "when memorized"
/// sub-control (E11-T07) renders beneath each row, and a calm bias note (C-009)
/// closes the step.
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

/// The step title with a quiet leading zellige star.
class _ConfidenceTitle extends StatelessWidget {
  const _ConfidenceTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final mihrab = theme.extension<MihrabColors>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(top: space.space1),
          child: MihrabGlyph(
            kind: MihrabGlyphKind.filledStar,
            color: mihrab.accentGold,
            size: space.space4,
          ),
        ),
        SizedBox(width: space.space2),
        Expanded(
          child: Text(title, style: theme.textTheme.titleLarge),
        ),
      ],
    );
  }
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
    final mihrab = theme.extension<MihrabColors>()!;
    final space = theme.extension<SpacingTokens>()!;
    return Row(
      spacing: space.space2,
      children: [
        Expanded(
          child: _ConfidencePill(
            value: JuzConfidence.solid,
            kind: MihrabGlyphKind.filledStar,
            label: l10n.confidenceSolid,
            semanticsLabel: l10n.confidenceSolidSemantics,
            restingGlyph: mihrab.accentGold,
            selected: selected == JuzConfidence.solid,
            onPick: onPick,
          ),
        ),
        Expanded(
          child: _ConfidencePill(
            value: JuzConfidence.shaky,
            kind: MihrabGlyphKind.outlineStar,
            label: l10n.confidenceShaky,
            semanticsLabel: l10n.confidenceShakySemantics,
            restingGlyph: theme.colorScheme.primary,
            selected: selected == JuzConfidence.shaky,
            onPick: onPick,
          ),
        ),
        Expanded(
          child: _ConfidencePill(
            value: JuzConfidence.rusty,
            kind: MihrabGlyphKind.dashedStar,
            label: l10n.confidenceRusty,
            semanticsLabel: l10n.confidenceRustySemantics,
            // A warm-clay resting hint — never an alarm; the chosen tone is the
            // same calm teal as the others.
            restingGlyph: mihrab.semanticWarning,
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
    required this.kind,
    required this.label,
    required this.semanticsLabel,
    required this.restingGlyph,
    required this.selected,
    required this.onPick,
  });

  final JuzConfidence value;
  final MihrabGlyphKind kind;
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
              constraints: BoxConstraints(minHeight: space.space8 + space.space2),
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
                    MihrabGlyph(
                      kind: kind,
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
