// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// The calm, non-celebratory step-progress indicator: one dot per step, filled
/// up to the current position. It carries no number, streak, or score (it is a
/// quiet wayfinding affordance, not a trophy) and reads start→end (right→left)
/// under the ambient RTL `Directionality`.
class OnboardingStepProgress extends StatelessWidget {
  /// Creates the indicator for [stepCount] steps with [currentIndex] reached.
  const OnboardingStepProgress({
    required this.stepCount,
    required this.currentIndex,
    super.key,
  });

  /// The total number of capture steps.
  final int stepCount;

  /// The zero-based index of the current step.
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return Semantics(
      // A wayfinding affordance only — excluded from the reading order so a
      // screen reader hears the step content, not a string of dots.
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: space.space1,
        children: [
          for (var i = 0; i < stepCount; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    i <= currentIndex ? scheme.primary : scheme.outlineVariant,
              ),
              child: SizedBox.square(dimension: space.space2),
            ),
        ],
      ),
    );
  }
}

/// The shared onboarding navigation bar: a Back affordance (hidden on the first
/// step) at the start and a Continue affordance at the end, both RTL by geometry
/// and ≥48 dp. It invites; it never commands. Navigation is delegated to the
/// step controller via [onBack] / [onContinue] — this bar writes nothing.
class OnboardingNavBar extends StatelessWidget {
  /// Creates the bar.
  const OnboardingNavBar({
    required this.onContinue,
    required this.onBack,
    super.key,
  });

  /// Called when Continue is tapped; `null` disables it (the step's
  /// precondition is not yet met — e.g. the muṣḥaf is not verified).
  final VoidCallback? onContinue;

  /// Called when Back is tapped; `null` hides Back (the first step).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return Padding(
      padding: EdgeInsetsDirectional.all(space.space4),
      child: Row(
        children: [
          if (onBack != null)
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.onboardingBack),
            ),
          const Spacer(),
          FilledButton(
            onPressed: onContinue,
            child: Text(l10n.onboardingContinue),
          ),
        ],
      ),
    );
  }
}
