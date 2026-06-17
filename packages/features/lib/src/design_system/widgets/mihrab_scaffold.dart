// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';

/// The Mihrab bottom-action screen template (design-system 05 §5): calm
/// full-bleed [body] content scrolls in the upper/middle area; an optional
/// primary [bottomAction] sits in a thumb-reach band above the nav, padded by
/// `space.4` inside a `SafeArea` that clears the home indicator; the
/// [bottomNavigationBar] (a `MihrabNavigationBar`) sits below.
///
/// A dumb View on `surface` (by role, no colour literal): it owns no selection
/// or route state, and ships no FAB, badge, or celebratory surface — there is
/// no reward affordance to reach for.
class MihrabScaffold extends StatelessWidget {
  /// Creates the scaffold around [body], optional [bottomAction], and optional
  /// [bottomNavigationBar].
  const MihrabScaffold({
    required this.body,
    this.bottomAction,
    this.bottomNavigationBar,
    super.key,
  });

  /// The full-bleed scrolling content slot.
  final Widget body;

  /// The optional primary action, placed in the one-handed thumb band.
  final Widget? bottomAction;

  /// The optional bottom navigation (a `MihrabNavigationBar`).
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final action = bottomAction;
    return Scaffold(
      bottomNavigationBar: bottomNavigationBar,
      body: action == null
          ? body
          : Column(
              children: [
                Expanded(child: body),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsetsDirectional.all(space.space4),
                    child: action,
                  ),
                ),
              ],
            ),
    );
  }
}
