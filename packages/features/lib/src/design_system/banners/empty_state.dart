// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';

/// Which calm empty state to render (ui-empty-state).
enum EmptyStateKind {
  /// First run / zero-data — a calm fact + one gentle invitation.
  firstRun,

  /// All-done / nothing-due — one calm closing line, never a celebration.
  allDone,

  /// Resume after a gap — renders NOTHING (the absence of a reproach); never a
  /// "Welcome back … N days" greeting.
  silentResume,
}

/// The display model for an [EmptyState] — already-localized strings only.
@immutable
class EmptyStateModel {
  /// Creates a model of [kind]; [body]/[actionLabel]/[onAction] apply per kind.
  const EmptyStateModel({
    required this.kind,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  /// The variant to render.
  final EmptyStateKind kind;

  /// The calm fact / closing line (null for [EmptyStateKind.silentResume]).
  final String? body;

  /// The one gentle next-step label (firstRun only).
  final String? actionLabel;

  /// The one gentle next-step callback (firstRun only).
  final VoidCallback? onAction;
}

/// The calm empty-state family (ui-empty-state) — first-run welcome, all-done
/// close, and silent welcome-back.
///
/// Plainly neutral by construction: no red, no mascot, no confetti/streak/badge/
/// exclamation, no "you're behind", and — for [EmptyStateKind.silentResume] — no
/// greeting at all (it renders nothing; the host resumes into the ordinary day).
/// The empathy-then-path register is reserved for the catch-up banner, not
/// manufactured here.
class EmptyState extends StatelessWidget {
  /// Creates an empty state from [model].
  const EmptyState({required this.model, super.key});

  /// The display model.
  final EmptyStateModel model;

  @override
  Widget build(BuildContext context) {
    // Silent welcome-back is the absence of a reproach — nothing is shown.
    if (model.kind == EmptyStateKind.silentResume) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    final actionLabel = model.actionLabel;
    final onAction = model.onAction;

    return Padding(
      padding: EdgeInsetsDirectional.all(space.space6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            model.body ?? '',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (model.kind == EmptyStateKind.firstRun &&
              actionLabel != null &&
              onAction != null) ...[
            SizedBox(height: space.space4),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }
}
