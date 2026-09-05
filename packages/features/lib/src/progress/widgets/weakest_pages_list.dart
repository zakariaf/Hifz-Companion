// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/state/mihrab_state_layer.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../progress_cell_data.dart' show bandLabel;
import '../progress_overview.dart';
import 'page_detail_sheet.dart';

/// The calm "where to look first" list (E15-T07): the few weakest (lowest-`R`)
/// memorized pages across the whole muṣḥaf, each a cream page-card row with a
/// quiet teal reading-start spine (the same feel as the Today page card) that
/// taps into the page-detail sheet. It **surfaces** the weak link rather than
/// smoothing it (the honest counterpart to the min-leaning juz roll-up), in an
/// informational register — no shame styling, no "you're behind".
class WeakestPagesList extends StatelessWidget {
  /// Creates the weakest-pages list for [overview].
  const WeakestPagesList({required this.overview, super.key});

  /// The whole-Quran overview to draw the weakest pages from.
  final ProgressOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        SizedBox(height: space.space3),
        for (final page in weakest) _WeakestPageRow(page: page),
      ],
    );
  }
}

/// One weakest-page row — a flat cream card with a teal start spine, the page/juz
/// headline over its calm band word, and a band-tinted zellige star tying it to
/// the tile-wall. The whole row is one ≥48dp tap into the page-detail sheet.
class _WeakestPageRow extends StatelessWidget {
  const _WeakestPageRow({required this.page});

  final PageHealth page;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;

    return MergeSemantics(
      child: Card(
        elevation: 0,
        margin: EdgeInsetsDirectional.only(bottom: space.space3),
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadiusDirectional.all(Radius.circular(space.space4)),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => PageDetailSheet.show(context, page),
          overlayColor: MihrabStateLayer.overlayColor(scheme.onSurface),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: space.space8),
            child: Padding(
              padding: EdgeInsetsDirectional.all(space.space4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizedPageJuz(
                            page: page.pageId,
                            juz: page.juz,
                            locale: locale,
                            l10n: l10n,
                          ),
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: space.space1),
                        Text(
                          bandLabel(l10n, page.band),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: space.space3),
                  Icon(
                    Icons.arrow_forward_ios, // auto-mirrors at the logical end
                    size: space.space4,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
