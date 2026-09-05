// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/heatmap/heatmap_cell.dart';
import '../../design_system/heatmap/heatmap_cell_data.dart';
import '../../design_system/state/mihrab_state_layer.dart';
import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../../design_system/widgets/mihrab_card.dart';
import '../progress_cell_data.dart';
import '../progress_overview.dart';
import 'juz_pages_sheet.dart';
import 'progress_legend.dart';
import 'upcoming_load_forecast.dart';
import 'weakest_pages_list.dart';

/// The whole-Quran overview (plain redesign, 2026-09-05): the legend, a plain
/// grid of the 30 juz roll-up tiles (fill + number + state word, never colour
/// alone), the weakest pages to start from, the upcoming-load line, and the
/// entry to the mutashābihāt trainer. Reads the streamed model; recomputes
/// nothing; draws no Quran glyph.
class ProgressOverviewView extends StatelessWidget {
  /// Creates the overview for [overview].
  const ProgressOverviewView({required this.overview, super.key});

  /// The streamed whole-Quran read model.
  final ProgressOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        space.space4,
        0,
        space.space4,
        space.space7,
      ),
      children: [
        const ProgressLegend(),
        SizedBox(height: space.space3),
        DecoratedBox(
          decoration: ShapeDecoration(
            color: scheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(space.space4),
              side: BorderSide(color: scheme.outlineVariant),
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.all(space.space3),
            // The 30 juz roll-up tiles in muṣḥaf order; the grid lays out
            // start→end under the inherited RTL directionality.
            child: GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: space.space2,
              crossAxisSpacing: space.space2,
              children: [
                for (final summary in overview.juzSummaries)
                  _JuzTile(
                    data: juzCellData(l10n, locale, summary),
                    juz: summary.juz,
                    onTap: () => JuzPagesSheet.show(context, summary),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: space.space5),
        const UpcomingLoadForecast(),
        SizedBox(height: space.space5),
        WeakestPagesList(overview: overview),
        SizedBox(height: space.space3),
        MihrabCard(
          title: l10n.navMutashabihat,
          subtitle: l10n.headerSubtitleMutashabihat,
          leading: Icons.compare_arrows_outlined,
          onTap: () => context.push('/mutashabihat'),
        ),
      ],
    );
  }
}

/// One juz tile: the ramp fill, the juz number, and the state word inside a
/// plain rounded square — value + label redundant with the fill (08 §5). The
/// whole tile is one ≥48dp tap into the juz's page cells.
class _JuzTile extends StatelessWidget {
  const _JuzTile({required this.data, required this.juz, required this.onTap});

  final HeatmapCellData data;
  final int juz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = theme.extension<MihrabColors>()!;
    final space = theme.extension<SpacingTokens>()!;
    final fill = heatFillFor(colors, data);
    final onFill =
        heatFillIsDark(colors, data) ? scheme.onPrimary : scheme.onSurface;
    // Both parts are already-localized ARB values (juz label + band word).
    final spoken = '${data.localizedValue} · ${data.label}';
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: spoken,
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(space.space3),
            side: BorderSide(
              color: data.everReviewed ? fill : scheme.outlineVariant,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            overlayColor: MihrabStateLayer.overlayColor(onFill),
            child: ExcludeSemantics(
              child: Padding(
                padding: EdgeInsetsDirectional.all(space.space1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isolateLtr(localeDigits(juz, locale)),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: onFill,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      data.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style:
                          theme.textTheme.labelSmall?.copyWith(color: onFill),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
