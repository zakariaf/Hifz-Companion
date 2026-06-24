// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';
import '../progress_cell_data.dart' show bandLabel;
import '../progress_overview.dart';
import 'page_detail_sheet.dart';

/// The calm "where to look first" list (E15-T07): the few weakest (lowest-`R`)
/// memorized pages across the whole muṣḥaf, each tapping into the page-detail
/// sheet. It **surfaces** the weak link rather than smoothing it (the honest
/// counterpart to the min-leaning juz roll-up), in an informational register —
/// no shame styling, no "you're behind".
class WeakestPagesList extends StatelessWidget {
  /// Creates the weakest-pages list for [overview].
  const WeakestPagesList({required this.overview, super.key});

  /// The whole-Quran overview to draw the weakest pages from.
  final ProgressOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;

    final memorized = [
      for (final juz in overview.juzSummaries)
        for (final page in juz.pages)
          if (page.memorized) page,
    ]..sort((a, b) => a.retrievability.compareTo(b.retrievability));
    if (memorized.isEmpty) return const SizedBox.shrink();
    final weakest = memorized.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.progressWeakestTitle, style: theme.textTheme.titleSmall),
        SizedBox(height: space.space1),
        for (final page in weakest)
          ListTile(
            contentPadding: EdgeInsetsDirectional.symmetric(
              horizontal: space.space2,
            ),
            title: Text(
              localizedPageJuz(
                page: page.pageId,
                juz: page.juz,
                locale: locale,
                l10n: l10n,
              ),
            ),
            subtitle: Text(bandLabel(l10n, page.band)),
            onTap: () => PageDetailSheet.show(context, page),
          ),
      ],
    );
  }
}
