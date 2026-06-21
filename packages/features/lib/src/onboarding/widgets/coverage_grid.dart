// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// The juz-level coverage grid: 30 cells in muṣḥaf order (juz 1 at the
/// start/right under RTL), one tap = held / not-held. Held is shown by a filled
/// check **and** the surface tint — never colour alone (SC 1.4.1). An un-held
/// cell is calm and un-emphasised, never alarm-red / "missing" / "0%". A
/// domain-blind View: it takes [heldJuz] + [onToggle] and renders.
class CoverageGrid extends StatelessWidget {
  /// Creates the coverage grid reflecting [heldJuz].
  const CoverageGrid({
    required this.heldJuz,
    required this.onToggle,
    super.key,
  });

  /// The currently-held juz (1–30).
  final Set<int> heldJuz;

  /// Called with the tapped juz index to toggle its membership.
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final numerals =
        numberFormatFor(Localizations.localeOf(context).languageCode);
    return GridView.builder(
      padding: EdgeInsetsDirectional.all(space.space4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: space.space2,
        crossAxisSpacing: space.space2,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juz = index + 1;
        final held = heldJuz.contains(juz);
        final numeral = numerals.format(juz);
        return _JuzCell(
          numeral: numeral,
          held: held,
          stateLabel: held ? l10n.onboardingHeld : l10n.onboardingNotHeld,
          onTap: () => onToggle(juz),
        );
      },
    );
  }
}

class _JuzCell extends StatelessWidget {
  const _JuzCell({
    required this.numeral,
    required this.held,
    required this.stateLabel,
    required this.onTap,
  });

  final String numeral;
  final bool held;
  final String stateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final radius = BorderRadius.circular(space.space3);
    return Semantics(
      button: true,
      selected: held,
      label: '$numeral — $stateLabel',
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color:
                held ? scheme.primaryContainer : scheme.surfaceContainerHighest,
            border: Border.all(
              color: held ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: space.space1,
            children: [
              Text(
                numeral,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: held ? scheme.onPrimaryContainer : scheme.onSurface,
                ),
              ),
              Icon(
                held ? Icons.check_circle : Icons.circle_outlined,
                color: held ? scheme.primary : scheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
