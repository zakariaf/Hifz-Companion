// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';
import '../mushaf_providers.dart';
import 'reader_zoom_steps.dart';

/// The reader's zoom control — `−`/`+` around a discrete magnification readout
/// over the [kReaderZoomSteps] band (never a continuous "fit to width" slider).
/// The readout is the current step in the active locale's numeral block with the
/// locale percent sign (`۱۰۰٪`) — a plain magnification indicator, not a piety
/// metric. It writes only the E13-T02 reader-state `zoom`; the value flows into
/// E05's `Transform.scale` (RTL `topRight` origin) — the muṣḥaf's **own** uniform
/// scale, read from the store and **independent of `MediaQuery.textScalerOf`**
/// (the OS chrome text-scale), so a printed line break never moves at any zoom
/// step. Display-only: it mutates no card, writes no review, and never
/// font-swaps or re-flows.
class ReaderZoomControl extends ConsumerWidget {
  /// Creates the zoom control bound to the reader opened at [entryPage].
  const ReaderZoomControl({required this.entryPage, super.key});

  /// The reader-state store family key whose `zoom` this control steps.
  final int entryPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final locale = Localizations.localeOf(context);
    final zoom = ref.watch(
      mushafReaderStateProvider(entryPage).select((state) => state.zoom),
    );
    final notifier = ref.read(mushafReaderStateProvider(entryPage).notifier);
    // The step as a whole-number percentage in the locale numeral block; the
    // LTR-isolated digits carry the locale percent sign (٪ / U+066A).
    final readout = '${isolateLtr(localeDigits((zoom * 100).round(), locale))}٪';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          // A no-op at the band's minimum — disabled, never a silent no-op tap.
          onPressed: isMinZoom(zoom)
              ? null
              : () => notifier.setZoom(steppedZoom(zoom, zoomIn: false)),
          tooltip: l10n.mushafZoomOut,
          icon: const Icon(Icons.remove),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: space.space8),
          child: Text(
            readout,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        IconButton(
          onPressed: isMaxZoom(zoom)
              ? null
              : () => notifier.setZoom(steppedZoom(zoom, zoomIn: true)),
          tooltip: l10n.mushafZoomIn,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
