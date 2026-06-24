// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/heatmap/heatmap_cell.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../progress_cell_data.dart';
import '../progress_overview.dart';
import 'juz_pages_sheet.dart';
import 'upcoming_load_forecast.dart';
import 'weakest_pages_list.dart';

/// The populated Progress surface (E15-T03/T04/T05): the heat-map leads with the
/// 30 juz roll-up tiles in muṣḥaf order under the app-wide `Directionality.rtl`
/// (start→end small multiples), each a min-leaning [HeatmapCell] that zooms into
/// its pages on tap. Below sit the calm upcoming-load forecast and the
/// weakest-pages "where to look first" list. Overview-first; never a scoreboard.
class ProgressOverviewView extends StatelessWidget {
  /// Creates the overview for [overview].
  const ProgressOverviewView({required this.overview, super.key});

  /// The streamed whole-Quran read model.
  final ProgressOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;

    return ListView(
      padding: EdgeInsetsDirectional.all(space.space4),
      children: [
        const UpcomingLoadForecast(),
        SizedBox(height: space.space4),
        // The 30 juz roll-up tiles in muṣḥaf order; the Wrap lays out start→end
        // under the inherited RTL directionality.
        Wrap(
          spacing: space.space3,
          runSpacing: space.space3,
          children: [
            for (final summary in overview.juzSummaries)
              HeatmapCell(
                data: juzCellData(l10n, locale, summary),
                onTap: () => JuzPagesSheet.show(context, summary),
              ),
          ],
        ),
        SizedBox(height: space.space5),
        WeakestPagesList(overview: overview),
      ],
    );
  }
}
