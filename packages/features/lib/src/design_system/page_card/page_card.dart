// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../state/mihrab_state_layer.dart';
import '../theme/mihrab_colors.dart';
import '../theme/spacing_tokens.dart';
import 'decay_indicator.dart';
import 'page_card_view_data.dart';
import 'track_chip.dart';

/// One muṣḥaf page as a flat list row (design-system 07 §2) — the calm,
/// domain-blind Mihrab page card the Today list (E12) and the heat-map detail
/// (E15) compose.
///
/// Named `MihrabPageCard` to sit beside the other `Mihrab*` design-system widgets
/// (and to leave the E07 walking-skeleton `PageCard` — the engine-bound Today row
/// with an embedded grade band — untouched until E12 migrates it). It maps a
/// [PageCardViewData] to the four M3 list-item slots (leading = [TrackChip] +
/// [DecayIndicator]; headline = "Page N · Juz M" in locale numerals, bidi-
/// isolated; supporting = optional hint; trailing = a mirroring chevron / state
/// affordance), at elevation Level 0–1. The **whole row is one ≥48dp tap**
/// ([onOpen]); the chip/swatch are inner labels, not sub-targets. It reads
/// streamed display data only — it re-derives no schedule, never shows
/// `R`/D/S/a percentage/"safe to drop", and **draws no Quran glyph**.
class MihrabPageCard extends StatelessWidget {
  /// Creates the row for [data]; [onOpen] is the single row action.
  const MihrabPageCard({required this.data, required this.onOpen, super.key});

  /// The display-blind data to render.
  final PageCardViewData data;

  /// The one action for the whole row (E12 mounts the recite route here).
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<MihrabColors>()!;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;

    final isDue = data.state == CardState.dueToday ||
        data.state == CardState.pulledForward;
    final isWeak = data.state == CardState.weak;
    final isDone = data.state == CardState.done;

    // Emphasis is surface/border only (07 §2) — pulled-forward shares the due
    // path exactly (no "the algorithm chose this" — C-016).
    final surface =
        isDue ? scheme.surfaceContainerHigh : scheme.surfaceContainer;
    final borderSide = isWeak
        ? BorderSide(color: colors.semanticWarning) // quiet warning, not alarm
        : BorderSide(color: scheme.outlineVariant);
    final headlineColor = isDone ? scheme.onSurfaceVariant : scheme.onSurface;

    final headline = localizedPageJuz(
      page: data.page,
      juz: data.juz,
      locale: locale,
      l10n: l10n,
    );
    final hint = data.supportingHint;

    final leading = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TrackChip(family: data.track, label: data.trackLabel),
        SizedBox(width: space.space2),
        DecayIndicator(level: data.decay, label: data.decayLabel),
      ],
    );

    return MergeSemantics(
      child: MihrabFocusRing(
        child: Card(
          elevation: 0,
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.all(
              Radius.circular(space.space3),
            ),
            side: borderSide,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onOpen,
            overlayColor: MihrabStateLayer.overlayColor(scheme.onSurface),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: space.space8),
              child: Padding(
                padding: EdgeInsetsDirectional.all(space.space3),
                child: Row(
                  children: [
                    leading,
                    SizedBox(width: space.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headline,
                            style:
                                text.bodyLarge?.copyWith(color: headlineColor),
                          ),
                          if (hint != null) ...[
                            SizedBox(height: space.space1),
                            Text(
                              hint,
                              style: text.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: space.space2),
                    _Trailing(
                      state: data.state,
                      word: _stateWord(l10n, data.state),
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

  /// The calm state word spoken in the merged phrase, or null for the resting
  /// state. `dueToday` and `pulledForward` share one word (identical by design).
  static String? _stateWord(AppLocalizations l10n, CardState state) =>
      switch (state) {
        CardState.defaultState => null,
        CardState.weak => l10n.stateWeak,
        CardState.dueToday || CardState.pulledForward => l10n.stateDue,
        CardState.done => l10n.stateDone,
        CardState.locked => l10n.stateLocked,
      };
}

/// The trailing affordance: an auto-mirroring chevron (open), a check (done), or
/// a lock (teacher override). Carries the calm state [word] into the merged
/// phrase; never an alarm.
class _Trailing extends StatelessWidget {
  const _Trailing({required this.state, required this.word});

  final CardState state;
  final String? word;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final icon = switch (state) {
      CardState.locked => Icons.lock_outline,
      CardState.done => Icons.check_circle_outline,
      // Auto-mirrors to the logical end (left in RTL).
      _ => Icons.arrow_forward_ios,
    };
    final glyph =
        Icon(icon, color: scheme.onSurfaceVariant, size: space.space5);
    final stateWord = word;
    return stateWord == null
        ? glyph
        : Semantics(label: stateWord, child: glyph);
  }
}
