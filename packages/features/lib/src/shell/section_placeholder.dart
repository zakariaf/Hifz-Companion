// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../a11y/semantics.dart';
import '../design_system/theme/spacing_tokens.dart';

/// A calm, inert section placeholder for the E07 walking skeleton: a localized
/// [title] and one reverent "being prepared" line, composed from Mihrab tokens
/// with logical insets.
///
/// Inert by construction — no interactive element, no on-screen number, no Quran
/// glyph; the real screen replaces it in its feature epic (Muṣḥaf → E13, Today →
/// E07-T07/T08, …). [identifier] is the stable accessibility id the spine
/// journey (E07-T10) addresses.
class SectionPlaceholder extends StatelessWidget {
  /// Creates an inert placeholder titled [title] with a11y id [identifier].
  const SectionPlaceholder({
    required this.title,
    required this.identifier,
    super.key,
  });

  /// The localized section name shown as the placeholder heading.
  final String title;

  /// The stable accessibility identifier for this section's root.
  final String identifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Semantics(
      key: ValueKey<String>(identifier),
      identifier: identifier,
      container: true,
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.space5),
        // Title + "being prepared" line read as ONE localized phrase, not two
        // fragments (E08-T02; design-system 09 §7).
        child: mergedItem(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: space.space2,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                l10n.sectionInPreparation,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
