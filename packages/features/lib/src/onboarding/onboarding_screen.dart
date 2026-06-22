// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart' show kDefaultCalendarSystem;

import '../design_system/theme/spacing_tokens.dart';
import 'onboarding_providers.dart';
import 'onboarding_view_model.dart';
import 'widgets/confidence_step.dart';
import 'widgets/core_setup_step.dart';
import 'widgets/coverage_capture_grid.dart';
import 'widgets/language_step.dart';
import 'widgets/onboarding_chrome.dart';
import 'widgets/riwayah_step.dart';
import 'widgets/welcome_step.dart';

/// The dumb onboarding host (E11-T01). It reads the one resume-safe capture
/// controller (keyed by the active profile — `null` on a fresh device) and shows
/// the current step's View plus the shared chrome (step-progress + back/next).
///
/// It holds only show/hide + which-step routing — no repository/engine call, no
/// business `try/catch`, no clock read, no persisted write. Inter-step movement
/// is internal (the body swaps on cursor change); the screen does not push a
/// `GoRoute`, and the controller never navigates (the E07 redirect guard routes
/// a seeded device away from `/onboarding`).
///
/// Each sibling task (E11-T02…T08) replaces its step's placeholder host with the
/// real step View; the placement commit + first-day handoff is E11-T09.
class OnboardingScreen extends ConsumerWidget {
  /// Creates the onboarding host.
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final profileScope = ref.watch(activeProfileProvider);
    final provider = onboardingControllerProvider(profileScope);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return Scaffold(
      // The language pick applies live as a display transform: re-localize the
      // whole onboarding subtree (chrome + step) to the captured locale. All
      // three locales are RTL, so direction is unchanged; `null` inherits.
      body: Localizations.override(
        context: context,
        locale: state.locale,
        child: Semantics(
          identifier: 'screen.onboarding',
          explicitChildNodes: true,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.all(space.space4),
                  child: OnboardingStepProgress(
                    stepCount: OnboardingStep.values.length,
                    currentIndex: state.cursor.index,
                  ),
                ),
                Expanded(child: _stepView(state, controller)),
                // The welcome landing carries its own Continue CTA; every other
                // step uses the shared back/next chrome.
                if (state.cursor != OnboardingStep.welcomePrivacy)
                  OnboardingNavBar(
                    onBack: controller.back,
                    onContinue: controller.canAdvance ? controller.next : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Routes the cursor to its step View. Steps not yet built (E11-T02…T08) show
  /// a keyed placeholder host the sibling task replaces; the coverage and
  /// confidence passes already compose their leaf widgets.
  Widget _stepView(OnboardingState state, OnboardingController controller) =>
      switch (state.cursor) {
        OnboardingStep.welcomePrivacy =>
          WelcomeStep(onContinue: controller.next),
        OnboardingStep.language => LanguageStep(
            selected: state.locale,
            onSelected: controller.setLocale,
          ),
        OnboardingStep.riwayahConfirm => RiwayahStep(
            selected: state.mushafEditionId,
            onSelected: controller.confirmMushaf,
          ),
        OnboardingStep.coreSetup => CoreSetupStep(
            phase: state.coreSetupPhase,
            onRun: controller.runCoreSetup,
          ),
        OnboardingStep.coverage => CoverageCaptureGrid(
            heldJuz: state.coverage,
            onToggle: controller.toggleJuz,
          ),
        OnboardingStep.confidence => ConfidenceStep(
            heldJuz: state.coverage,
            confidence: state.confidence,
            onPick: controller.setJuzConfidence,
            memorizedOn: state.memorizedOn,
            today: controller.today,
            calendarSystem: kDefaultCalendarSystem,
            onSetMemorized: controller.setMemorizedOn,
            onClearMemorized: controller.clearMemorizedOn,
          ),
        OnboardingStep.cyclePreset =>
          const _StepHost(OnboardingStep.cyclePreset),
        OnboardingStep.done => const _StepHost(OnboardingStep.done),
      };
}

/// A keyed, contentless placeholder for a step whose View is built by a sibling
/// task (E11-T02…T09). It renders no user-facing literal.
class _StepHost extends StatelessWidget {
  const _StepHost(this.step);

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) =>
      SizedBox.expand(key: ValueKey<String>('onboarding.step.${step.name}'));
}
