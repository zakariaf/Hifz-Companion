// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../design_system/theme/mihrab_colors.dart';
import '../design_system/theme/spacing_tokens.dart';
import 'semantics.dart';

/// The app's state chips, each carrying its meaning in **three** channels so a
/// state is never conveyed by hue alone (WCAG SC 1.4.1, Level A; design-system
/// 09 §4): a design-system color token, a non-color shape (a distinct icon), and
/// a localized label.
///
/// `track` expands to the three classical term-set values (sabaq/sabqi/manzil);
/// the three share a calm color and are told apart by **shape + label**, never
/// color — exactly the point of the convention. `decay` is a calm green-receding-
/// to-neutral state, never an alarm-red scoreboard.
///
/// **Inheritance contract:** every state chip in this app carries color + shape +
/// label/number; a color-only state is an SC 1.4.1 failure caught by
/// `assertStateChipRedundancy` (the E08-T06 widget-audit). E15's heat-map cells
/// and E12's recite/grade cards must call that audit in their own tests. The
/// heat-map's own cells and the page-card's own track/decay encodings are not
/// built here.
enum ChipState {
  /// New lesson (sabaq) — the classical term-set value.
  trackSabaq,

  /// Recent revision (sabqi).
  trackSabqi,

  /// Consolidated revision (manzil).
  trackManzil,

  /// The page is due for revision.
  due,

  /// The page is weak and needs strengthening.
  weak,

  /// A teacher (talaqqī) sign-off is recorded.
  signOff,

  /// The page's retention is softening (calm decay — never alarm).
  decay,
}

/// The (icon, label, surface) channels for [state] — a distinct non-color shape
/// per state, the localized term, and a named design-system color token.
({IconData icon, String label, Color surface}) _channelsFor(
  ChipState state,
  AppLocalizations l10n,
  ThemeData theme,
) {
  final colors = theme.extension<MihrabColors>()!;
  return switch (state) {
    // The three tracks share the calm chip surface — shape + label tell them
    // apart, never color (the convention's whole point).
    ChipState.trackSabaq => (
        icon: Icons.looks_one_outlined,
        label: l10n.trackNewLabel,
        surface: colors.trackChipSurface,
      ),
    ChipState.trackSabqi => (
        icon: Icons.looks_two_outlined,
        label: l10n.trackNearLabel,
        surface: colors.trackChipSurface,
      ),
    ChipState.trackManzil => (
        icon: Icons.looks_3_outlined,
        label: l10n.trackFarLabel,
        surface: colors.trackChipSurface,
      ),
    ChipState.due => (
        icon: Icons.schedule,
        label: l10n.stateDue,
        surface: theme.colorScheme.secondaryContainer,
      ),
    ChipState.weak => (
        icon: Icons.eco_outlined,
        label: l10n.stateWeak,
        surface: colors.decayCalm,
      ),
    ChipState.signOff => (
        icon: Icons.verified_outlined,
        label: l10n.stateSignedOff,
        surface: colors.accentGold,
      ),
    // Calm decay: a muted neutral, the same "needs revision" register as the
    // page-card indicator — never red, never "safe to drop".
    ChipState.decay => (
        icon: Icons.trending_down,
        label: l10n.decayNeedsRevision,
        surface: colors.heatmapWeak,
      ),
  };
}

/// A calm state chip carrying [state] in color + shape + label at once
/// (design-system 09 §4). The icon + label merge into one localized spoken
/// phrase (E08-T02), so the non-color channel reaches the screen reader. The
/// shape glyph is a fixed-convention state mark — never a mirrored directional
/// arrow — and layout uses logical insets.
class StateChip extends StatelessWidget {
  /// Creates the chip for [state].
  const StateChip({required this.state, super.key});

  /// The state this chip conveys.
  final ChipState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final channels = _channelsFor(state, l10n, theme);
    return mergedItem(
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: space.space2,
          vertical: space.space1,
        ),
        decoration: BoxDecoration(
          color: channels.surface,
          borderRadius: BorderRadius.circular(space.space2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: space.space1,
          children: [
            Icon(channels.icon, size: theme.textTheme.labelMedium?.fontSize),
            Text(channels.label, style: theme.textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
