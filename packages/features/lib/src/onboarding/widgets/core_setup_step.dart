// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';
import '../onboarding_view_model.dart' show CoreSetupPhase;

/// The one-time core-preparation step (E11-T04). The default muṣḥaf is bundled
/// in the binary, so this **verifies** the bundled bytes, builds the reference
/// DB, and stamps the text checksum — it is not a network download. It paints
/// E05's install as three calm states and is the fail-closed gate: the cursor
/// cannot reach coverage until [CoreSetupPhase.ready], so no muṣḥaf glyph
/// renders from unverified bytes.
///
/// A dumb View: it triggers the injected [onRun] once on entry (and on Retry),
/// renders the phase, and surfaces only a non-blaming Retry on failure — never a
/// skip or a "continue anyway". Advancing is the shared chrome's Continue, which
/// the cursor guard enables only when ready.
class CoreSetupStep extends StatefulWidget {
  /// Creates the step for the current [phase]; [onRun] runs the preparation.
  const CoreSetupStep({required this.phase, required this.onRun, super.key});

  /// The current core-preparation phase (from the onboarding state).
  final CoreSetupPhase phase;

  /// Runs (or re-runs) the core preparation.
  final Future<void> Function() onRun;

  @override
  State<CoreSetupStep> createState() => _CoreSetupStepState();
}

class _CoreSetupStepState extends State<CoreSetupStep> {
  @override
  void initState() {
    super.initState();
    // Start once on entry — never from build (which re-fires on rebuild). If the
    // user returns to a step already prepared, do not re-run.
    if (widget.phase == CoreSetupPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onRun();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final text = theme.textTheme;

    final (String title, String body, bool busy, bool failed) =
        switch (widget.phase) {
      CoreSetupPhase.idle || CoreSetupPhase.preparing => (
          l10n.onboardingCorePreparingTitle,
          l10n.onboardingCorePreparingBody,
          true,
          false
        ),
      CoreSetupPhase.ready => (
          l10n.onboardingCoreReadyTitle,
          l10n.onboardingCoreReadyBody,
          false,
          false,
        ),
      CoreSetupPhase.integrityFailure => (
          l10n.onboardingCoreIntegrityFailureTitle,
          l10n.onboardingCoreIntegrityFailureBody,
          false,
          true,
        ),
    };

    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy) ...[
              const CircularProgressIndicator(),
              SizedBox(height: space.space4),
            ],
            Semantics(
              liveRegion: true,
              child: Text(
                title,
                style: text.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: space.space2),
            Text(
              body,
              style: text.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (failed) ...[
              SizedBox(height: space.space4),
              FilledButton(
                onPressed: widget.onRun,
                child: Text(l10n.onboardingRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
