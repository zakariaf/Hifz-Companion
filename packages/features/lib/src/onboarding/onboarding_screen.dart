// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../design_system/theme/spacing_tokens.dart';
import 'onboarding_providers.dart';
import 'onboarding_view_model.dart';
import 'widgets/coverage_grid.dart';
import 'widgets/juz_confidence_rater.dart';

/// The minimal cold-start sub-step: coverage capture, then per-held-juz
/// Solid/Shaky/Rusty. On commit, the controller seeds the profile through the
/// single write path and flips the active profile — the router's redirect guard
/// then leaves onboarding for Today (this View navigates nothing). The full
/// onboarding (welcome, core download, "when memorized", cycle preset, budget)
/// is E11.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the cold-start sub-step.
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  // Which pass is on screen — view-local transient UI, not engine/profile state.
  bool _ratingConfidence = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final seeding = state.status == OnboardingStatus.seeding;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _ratingConfidence
              ? l10n.onboardingConfidenceTitle
              : l10n.onboardingCoverageTitle,
        ),
      ),
      body: Semantics(
        identifier: 'screen.onboarding',
        explicitChildNodes: true,
        child: SafeArea(
          child: Column(
            children: [
              if (!_ratingConfidence)
                Padding(
                  padding: EdgeInsetsDirectional.all(space.space4),
                  child: Text(
                    l10n.onboardingCoverageInstruction,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              Expanded(
                child: _ratingConfidence
                    ? JuzConfidenceRater(
                        heldJuz: state.heldJuz,
                        confidence: state.confidence,
                        onPick: controller.setConfidence,
                      )
                    : CoverageGrid(
                        heldJuz: state.heldJuz,
                        onToggle: controller.toggleJuz,
                      ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.all(space.space4),
                child: _ratingConfidence
                    ? FilledButton(
                        onPressed: state.isReadyToSeed && !seeding
                            ? controller.commitPlacement
                            : null,
                        child: Text(
                          state.status == OnboardingStatus.failed
                              ? l10n.onboardingRetry
                              : l10n.onboardingDone,
                        ),
                      )
                    : FilledButton(
                        onPressed: state.heldJuz.isEmpty
                            ? null
                            : () => setState(() => _ratingConfidence = true),
                        child: Text(l10n.onboardingContinue),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
