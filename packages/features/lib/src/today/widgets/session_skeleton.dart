// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// The Today `loading` state: a brief, calm `surfaceContainerLow` skeleton with
/// a few placeholder row shapes (07-components §1). It is **not** a spinner of
/// shame, carries no progress percentage, and runs no shimmer animation (so it
/// is reduce-motion-safe by construction and never an indefinite indicator —
/// tests pump explicit durations, never `pumpAndSettle`).
class SessionSkeleton extends StatelessWidget {
  /// Creates the loading skeleton.
  const SessionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final fill = Theme.of(context).colorScheme.surfaceContainerLow;
    return Semantics(
      // The skeleton is decorative — a screen reader hears the calm container,
      // not a row of placeholder noise.
      excludeSemantics: true,
      child: ListView(
        padding: EdgeInsetsDirectional.all(space.space4),
        children: <Widget>[
          for (var i = 0; i < 4; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: space.space2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(space.space2),
                ),
                child: SizedBox(height: space.space8 + space.space4),
              ),
            ),
        ],
      ),
    );
  }
}
