// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';
import '../progress_providers.dart' show upcomingLoadProvider;

/// The calm upcoming-load forecast (E15-T08): how many pages fall due over the
/// coming days, framed as a planning aid the user reads to pace revision. Never
/// a performance dashboard, a deadline pile, or an "overdue" pile — the count
/// routes through the `pagesDue` ICU plural in the loss-prevention register.
class UpcomingLoadForecast extends ConsumerWidget {
  /// Creates the forecast line.
  const UpcomingLoadForecast({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final load = ref.watch(upcomingLoadProvider);

    return load.maybeWhen(
      data: (count) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsetsDirectional.all(space.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.progressForecastTitle, style: theme.textTheme.titleSmall),
              SizedBox(height: space.space1),
              Text(
                localizedPagesDue(count: count, locale: locale, l10n: l10n),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
