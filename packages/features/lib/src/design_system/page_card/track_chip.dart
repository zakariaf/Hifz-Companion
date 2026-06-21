// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';
import 'page_card_view_data.dart';

/// A non-interactive label-only chip that names a page's lifecycle track
/// (design-system 07 §3): color **and** text, never color alone, never
/// alarm-red, never a count/badge.
///
/// The tradition-tied color family resolves from `ColorScheme` roles by name —
/// `far` (manzil) → the calm green *maintenance* family (`primaryContainer`),
/// `near` (sabqi) → `secondaryContainer`, `neww` (sabaq) → `tertiaryContainer`;
/// none is a danger/warning role. [label] is the already-localized regional
/// term-set string (ckb's longer terms **wrap**, never ellipsis). The chip is
/// not a separate tap/focus node — it is part of the row's merged phrase.
class TrackChip extends StatelessWidget {
  /// Creates a chip for [family] showing [label].
  const TrackChip({required this.family, required this.label, super.key});

  /// The lifecycle track family (selects the color family).
  final TrackFamily family;

  /// The already-localized regional term-set label.
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    final (background, foreground) = switch (family) {
      TrackFamily.far => (scheme.primaryContainer, scheme.onPrimaryContainer),
      TrackFamily.near => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      TrackFamily.neww => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
    };
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: space.space2,
        vertical: space.space1,
      ),
      decoration:
          ShapeDecoration(color: background, shape: const StadiumBorder()),
      // No ellipsis: a longer ckb term-set string wraps rather than truncating
      // sacred-adjacent vocabulary (07 §3).
      child: Text(label, style: text.labelMedium?.copyWith(color: foreground)),
    );
  }
}
