// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show ReviewGrade, civilDayOf;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ReviewLog;

import '../../design_system/theme/spacing_tokens.dart';
import '../progress_cell_data.dart' show bandRange;
import '../progress_overview.dart';
import '../progress_providers.dart' show reviewLogForPageProvider;

/// The page-detail sheet behind a heat-map cell tap (E15-T06): retrievability as
/// a **range in words** with its basis (never a single false-precise percent,
/// never raw `R`/D/S), the next-due date via [CalendarPresenter], and a short
/// history from the append-only `review_log`. Read-only; renders no Quran glyph.
class PageDetailSheet extends ConsumerWidget {
  /// Creates the detail sheet for [page].
  const PageDetailSheet({required this.page, super.key});

  /// The page whose health this sheet explains.
  final PageHealth page;

  /// Shows the sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context, PageHealth page) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => PageDetailSheet(page: page),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final history = ref.watch(reviewLogForPageProvider(page.pageId));

    final dueAt = page.dueAt;
    final nextDue = dueAt == null
        ? l10n.progressNoNextDue
        : l10n.progressNextDue(
            isolatedDateLabel(
              CalendarPresenter(progressCalendarSystem, locale),
              dueAt,
            ),
          );

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
              localizedPageJuz(
                page: page.pageId,
                juz: page.juz,
                locale: locale,
                l10n: l10n,
              ),
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: space.space3),
            Text(_rangeText(l10n, locale), style: theme.textTheme.bodyMedium),
            SizedBox(height: space.space2),
            Text(
              nextDue,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: space.space4),
            Text(l10n.progressHistoryTitle, style: theme.textTheme.titleSmall),
            SizedBox(height: space.space1),
            history.maybeWhen(
              data: (rows) => _History(rows: rows),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /// Retrievability stated as a range in words with its basis — never raw `R`.
  String _rangeText(AppLocalizations l10n, Locale locale) {
    if (!page.everReviewed) return l10n.progressDetailRangeEstimated;
    final (low, high) = bandRange(page.band);
    final range = l10n.progressDetailRange(
      isolateLtr(localeDigits(low, locale)),
      isolateLtr(localeDigits(high, locale)),
    );
    return page.sourceConfidence >= 1.0
        ? l10n.progressDetailRangeTeacher(range)
        : l10n.progressDetailRangeSelf(range);
  }
}

/// The few most-recent review rows (newest first), or a calm "none yet" line.
class _History extends StatelessWidget {
  const _History({required this.rows});

  final List<ReviewLog> rows;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    if (rows.isEmpty) {
      return Text(
        l10n.progressNoHistory,
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }
    // Newest first, at most five — a glance at the recent sanad, not a ledger.
    final recent = rows.reversed.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in recent)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              l10n.progressHistoryRow(
                isolatedDateLabel(
                  CalendarPresenter(progressCalendarSystem, locale),
                  civilDayOf(row.reviewedAtInstant),
                ),
                _gradeLabel(l10n, row.grade),
              ),
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  String _gradeLabel(AppLocalizations l10n, ReviewGrade grade) => switch (grade) {
        ReviewGrade.again => l10n.gradeAgain,
        ReviewGrade.hard => l10n.gradeHard,
        ReviewGrade.good => l10n.gradeGood,
        ReviewGrade.easy => l10n.gradeEasy,
      };
}

/// The calendar the Progress dates render in. E16 (Settings) will inject the
/// user's chosen system; until then the surface defaults to Gregorian. Kept as a
/// single named constant so the eventual wiring is one change, not a scatter.
const CalendarSystem progressCalendarSystem = CalendarSystem.gregorian;
