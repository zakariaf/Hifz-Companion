// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show CalendarDate;
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// A coarse "when memorized" band the user may pick instead of an exact date.
/// Each resolves to one representative [CalendarDate] against the injected
/// "today" via [memorizedDateForBand]; absence means no stale-time decay.
enum StaleBand {
  /// Within the current year.
  thisYear,

  /// Roughly one to two years ago.
  oneToTwoYears,

  /// Roughly three to five years ago.
  threeToFiveYears,

  /// More than five years ago.
  moreThanFiveYears,
}

/// Resolves a coarse [band] to a representative [CalendarDate] by counting back
/// whole days from the injected [today] — **`addDays` only**, never a `Duration`
/// or `DateTime.difference`, so the result is the byte-identical serial day in
/// every timezone and across any DST transition. Absent ⇒ no decay; the engine's
/// `coldStartCard(..., memorizedOn:)` ages stability from this day downward only.
CalendarDate memorizedDateForBand(StaleBand band, CalendarDate today) =>
    switch (band) {
      // Representative mid-band offsets in whole days (the engine's stale-time
      // decay is coarse — these only place the day in the right neighbourhood).
      StaleBand.thisYear => today.addDays(-180),
      StaleBand.oneToTwoYears => today.addDays(-548),
      StaleBand.threeToFiveYears => today.addDays(-1461),
      StaleBand.moreThanFiveYears => today.addDays(-2557),
    };

/// The optional "when memorized" sub-control (E11-T07), rendered beneath a juz's
/// confidence row. Skipping is a first-class path: with no value it shows a calm
/// optional invitation + the coarse bands; with a value it shows the date in the
/// user's calendar (via [CalendarPresenter]) and a clear affordance back to
/// skipped. It stores a [CalendarDate] only — never a raw `DateTime`/epochDay —
/// reads no clock (the injected [today] is passed in), seeds nothing, and draws
/// no muṣḥaf glyph.
class WhenMemorizedInput extends StatelessWidget {
  /// Creates the input for [juz].
  const WhenMemorizedInput({
    required this.juz,
    required this.value,
    required this.today,
    required this.calendarSystem,
    required this.onSet,
    required this.onClear,
    super.key,
  });

  /// The juz this control belongs to.
  final int juz;

  /// The currently captured date, or null (skipped — the normal path).
  final CalendarDate? value;

  /// The injected "today" used to resolve a coarse band.
  final CalendarDate today;

  /// The explicit calendar the stored date is displayed in (never inferred).
  final CalendarSystem calendarSystem;

  /// Called with the resolved date when a band is picked.
  final void Function(int juz, CalendarDate date) onSet;

  /// Called to return to the skipped (no-date) state.
  final void Function(int juz) onClear;

  static const _bands = StaleBand.values;

  String _bandLabel(AppLocalizations l10n, StaleBand band) => switch (band) {
        StaleBand.thisYear => l10n.staleBandThisYear,
        StaleBand.oneToTwoYears => l10n.staleBandOneToTwoYears,
        StaleBand.threeToFiveYears => l10n.staleBandThreeToFiveYears,
        StaleBand.moreThanFiveYears => l10n.staleBandMoreThanFiveYears,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final locale = Localizations.localeOf(context);

    if (value != null) {
      final label = isolatedDateLabel(
        CalendarPresenter(calendarSystem, locale),
        value!,
      );
      return Padding(
        padding: EdgeInsetsDirectional.only(top: space.space2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.whenMemorizedSetLabel(label),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () => onClear(juz),
              child: Text(l10n.whenMemorizedClear),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(top: space.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: space.space2,
        children: [
          Text(
            l10n.whenMemorizedOptionalLabel,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Wrap(
            spacing: space.space2,
            runSpacing: space.space2,
            children: [
              for (final band in _bands)
                ActionChip(
                  label: Text(_bandLabel(l10n, band)),
                  onPressed: () =>
                      onSet(juz, memorizedDateForBand(band, today)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
