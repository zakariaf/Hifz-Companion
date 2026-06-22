// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// The first cold-start capture pass (E11-T05): a juz-level tap grid of 30 cells
/// in **muṣḥaf order** (juz ۱ at the start/right under RTL, juz ۳۰ at the end),
/// one tap = held / not-held. A held juz is membership in [heldJuz]; an un-held
/// juz is **absence** — drawn calm and un-emphasised, never alarm-red / "missing"
/// / "0%". Held vs un-held is carried by shape + glyph + label, never hue alone
/// (SC 1.4.1). Each cell is a ≥48 dp `toggled` Semantics node with a visible
/// focus ring and a locale-numeral juz label.
///
/// A dumb View: it takes [heldJuz] + [onToggle] and renders. It holds no local
/// capture state, opens no `db.transaction`/DAO, reads no clock, and draws no
/// muṣḥaf glyph — it captures juz-level self-report taps only (the seed is
/// E11-T09's single write path).
class CoverageCaptureGrid extends StatelessWidget {
  /// Creates the grid reflecting [heldJuz].
  const CoverageCaptureGrid({
    required this.heldJuz,
    required this.onToggle,
    super.key,
  });

  /// The currently-held juz (1–30); absence = `UNMEMORIZED`.
  final Set<int> heldJuz;

  /// Called with the tapped juz to toggle its membership.
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            space.space4,
            space.space4,
            space.space4,
            space.space2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingCoverageTitle,
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: space.space1),
              Text(
                l10n.onboardingCoverageInstruction,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsetsDirectional.all(space.space4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // 5 columns — square cells stay well over the 48 dp tap floor.
              crossAxisCount: 5,
              mainAxisSpacing: space.space2,
              crossAxisSpacing: space.space2,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              // index 0 = juz ۱ at the start (right) under RTL; index 29 = juz ۳۰.
              final juz = index + 1;
              final held = heldJuz.contains(juz);
              final numeral = formatLocaleNumber(locale, juz);
              return _JuzCell(
                numeral: numeral,
                held: held,
                label: l10n.onboardingCoverageCellLabel(
                  numeral,
                  held ? l10n.onboardingHeld : l10n.onboardingNotHeld,
                ),
                onTap: () => onToggle(juz),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _JuzCell extends StatelessWidget {
  const _JuzCell({
    required this.numeral,
    required this.held,
    required this.label,
    required this.onTap,
  });

  final String numeral;
  final bool held;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final radius = BorderRadius.circular(space.space3);
    // One merged node carrying the composed "Juz N, held/not held" label + the
    // toggle state + the tap action; the inner glyph/numeral are excluded so the
    // screen reader voices the cell as a single control.
    return MergeSemantics(
      child: Semantics(
        button: true,
        toggled: held,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          focusColor: scheme.primary.withValues(alpha: 0.12),
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                color: held
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
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
                      color:
                          held ? scheme.onPrimaryContainer : scheme.onSurface,
                    ),
                  ),
                  // Redundant non-colour encoding: a present check when held, an
                  // empty ring when not — readable in grayscale / for CVD.
                  Icon(
                    held ? Icons.check_circle : Icons.circle_outlined,
                    color: held ? scheme.primary : scheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
