// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition;

import 'mushaf_about.dart';

/// The always-visible riwāyah/edition chrome label (R2): it names the muṣḥaf the
/// reader is showing — the active [MushafEdition.displayName] (e.g. "Ḥafṣ ʿan
/// ʿĀṣim — Madani muṣḥaf") — so the page is **never** presented as "the Quran"
/// absolutely, and a quiet "About this muṣḥaf" affordance opens the
/// Tanzil/QUL/KFGQPC attribution + checksum guarantee.
///
/// It is **chrome, not scripture**: ordinary shaped UI text on the `type.*`
/// ramp in the bundled UI font — never the QPC page font, never a `glyphCodes`
/// string, never a `fontFamilyFallback`. It lives outside the page's
/// `ColorFilter`/`Transform.scale` frame, so theme/zoom never recolour or scale
/// it with the glyph layer. Display-only: it swaps no edition (E16 owns that).
class RiwayahChromeLabel extends StatelessWidget {
  /// Creates the label for the active [edition].
  const RiwayahChromeLabel({required this.edition, super.key});

  /// The active edition whose `displayName`/`riwayah` is named.
  final MushafEdition edition;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            edition.displayName,
            style: theme.textTheme.titleSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () => showMushafAbout(context, edition: edition),
          tooltip: l10n.mushafAboutTitle,
          icon: const Icon(Icons.info_outline),
        ),
      ],
    );
  }
}
