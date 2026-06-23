// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition;

import '../../design_system/theme/spacing_tokens.dart';

/// Opens the About/Credits surface for the active [edition] (E13-T07).
Future<void> showMushafAbout(
  BuildContext context, {
  required MushafEdition edition,
}) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => MushafAboutCredits(edition: edition),
    );

/// The About/Credits surface: it names the riwāyah and credits **Tanzil** (the
/// Uthmani text), **QUL** (the page layout), and **KFGQPC** (the per-page glyph
/// fonts), then states the byte-for-byte SHA-256 checksum guarantee and the
/// fully-offline / no-microphone covenant (C-048) in plain language.
///
/// It draws **zero** tafsīr / translation / commentary, and never presents the
/// muṣḥaf as "the Quran" absolutely (R2). Source URLs are shown as plain text
/// that clearly leaves the app; the surface itself opens no socket.
class MushafAboutCredits extends StatelessWidget {
  /// Creates the credits surface for [edition].
  const MushafAboutCredits({required this.edition, super.key});

  /// The active edition being credited.
  final MushafEdition edition;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final body = theme.textTheme.bodyMedium;
    final fine = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: space.space3,
          children: [
            Text(l10n.mushafAboutTitle, style: theme.textTheme.titleMedium),
            // The named riwāyah — never "the Quran" absolutely.
            Text(edition.displayName, style: theme.textTheme.titleSmall),
            const Divider(),
            Text(l10n.mushafAboutTanzil, style: body),
            Text(l10n.mushafAboutQul, style: body),
            Text(l10n.mushafAboutFonts, style: body),
            const Divider(),
            Text(l10n.mushafAboutChecksum, style: fine),
            Text(l10n.mushafAboutOffline, style: fine),
          ],
        ),
      ),
    );
  }
}
