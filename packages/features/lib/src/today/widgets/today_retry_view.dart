// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// The Today `error` state: a calm retry surface (04 §1.3) — a single labelled
/// action, never a spinner-of-shame and never a guilt/fear message. The label
/// and tap come from the View; this leaf only lays them out at the ≥48 dp touch
/// floor with logical insets.
class TodayRetryView extends StatelessWidget {
  /// Creates the retry surface with a localized [message] and [onRetry].
  const TodayRetryView({required this.message, required this.onRetry, super.key});

  /// The localized, calm retry label.
  final String message;

  /// Invoked when the user asks to retry (the View invalidates the controller).
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.space4),
        child: FilledButton(onPressed: onRetry, child: Text(message)),
      ),
    );
  }
}
