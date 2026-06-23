// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../mushaf_providers.dart';
import '../reader_theme.dart';

/// The reader's light/sepia/dark theme control — a single-choice
/// `SegmentedButton<ReaderTheme>` over exactly the three [ReaderTheme] values
/// (the design system's *Night* appearance is out of this control's contract).
/// The selected state is the segment **check icon + the localized text label**,
/// never colour alone (WCAG 2.2 SC 1.4.1).
///
/// It writes only the E13-T02 reader-state `theme`; the value selects E05's
/// single `ColorFilter` over the whole rendered layer — **no per-theme font
/// swap, no "dark font"** (one font per page). A display transform: it mutates
/// no card, writes no review, makes no sleep claim, and adds no "recommended"
/// framing or celebration on the change.
class ReaderThemeControl extends ConsumerWidget {
  /// Creates the theme control bound to the reader opened at [entryPage].
  const ReaderThemeControl({required this.entryPage, super.key});

  /// The reader-state store family key whose `theme` this control selects.
  final int entryPage;

  String _label(AppLocalizations l10n, ReaderTheme theme) => switch (theme) {
        ReaderTheme.light => l10n.mushafThemeLight,
        ReaderTheme.sepia => l10n.mushafThemeSepia,
        ReaderTheme.dark => l10n.mushafThemeDark,
      };

  IconData _icon(ReaderTheme theme) => switch (theme) {
        ReaderTheme.light => Icons.light_mode_outlined,
        ReaderTheme.sepia => Icons.wb_sunny_outlined,
        ReaderTheme.dark => Icons.dark_mode_outlined,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = ref.watch(
      mushafReaderStateProvider(entryPage).select((state) => state.theme),
    );
    final notifier = ref.read(mushafReaderStateProvider(entryPage).notifier);
    return SegmentedButton<ReaderTheme>(
      segments: [
        for (final value in ReaderTheme.values)
          ButtonSegment<ReaderTheme>(
            value: value,
            // Shape (icon + selected check) AND text — never colour alone.
            icon: Icon(_icon(value)),
            label: Text(_label(l10n, value)),
          ),
      ],
      selected: {theme},
      onSelectionChanged: (selection) => notifier.setTheme(selection.first),
    );
  }
}
