// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/heatmap/heatmap_cell.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../progress_cell_data.dart';
import '../progress_overview.dart';
import 'page_detail_sheet.dart';

/// The zoom step of the overview→zoom→details grammar (08-data-visualization §1):
/// tapping a juz roll-up tile opens this sheet of its ~20 page cells in muṣḥaf
/// order (small multiples), each a tappable [HeatmapCell] that drills into the
/// page-detail sheet. Renders no Quran glyph; recomputes nothing.
class JuzPagesSheet extends StatelessWidget {
  /// Creates the sheet for [summary].
  const JuzPagesSheet({required this.summary, super.key});

  /// The juz whose pages this sheet shows.
  final JuzSummary summary;

  /// Shows the sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context, JuzSummary summary) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => JuzPagesSheet(summary: summary),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          space.space5,
          space.space2,
          space.space5,
          space.space5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.juzLabel(isolateLtr(localeDigits(summary.juz, locale))),
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: space.space3),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: space.space3,
                  runSpacing: space.space3,
                  children: [
                    for (final page in summary.pages)
                      HeatmapCell(
                        data: pageCellData(l10n, locale, page),
                        onTap: () => PageDetailSheet.show(context, page),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
