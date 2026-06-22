// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';
import '../onboarding_view_model.dart' show PlacementStatus;

/// The terminal placement step (E11-T09): a calm informational summary that
/// runs the placement commit on entry and, on success, lets the router resolve
/// the first generated day (the active profile flips after the durable commit).
///
/// The summary renders the conservative-bias promise (C-009 — "we'll revise
/// everything you hold once, then adjust as you recite"); it is **not** a
/// celebration — no streak/badge/confetti/completion-% and no "you're N% ready".
/// On failure it offers a calm Retry; it never half-advances.
class PlacementSummaryStep extends StatefulWidget {
  /// Creates the summary for the current [status]; [onCommit] runs/retries the
  /// commit.
  const PlacementSummaryStep({
    required this.status,
    required this.onCommit,
    super.key,
  });

  /// The current placement status.
  final PlacementStatus status;

  /// Runs (or retries) the placement commit.
  final Future<void> Function() onCommit;

  @override
  State<PlacementSummaryStep> createState() => _PlacementSummaryStepState();
}

class _PlacementSummaryStepState extends State<PlacementSummaryStep> {
  @override
  void initState() {
    super.initState();
    // Commit once on entry (never from build). If the user returns after a
    // failure, the explicit Retry re-runs it.
    if (widget.status == PlacementStatus.capturing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onCommit();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final failed = widget.status == PlacementStatus.failed;

    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.onboardingPlacementSummary,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: space.space4),
            if (failed) ...[
              Text(
                l10n.onboardingPlacementError,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: space.space4),
              FilledButton(
                onPressed: widget.onCommit,
                child: Text(l10n.onboardingRetry),
              ),
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
