// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../mushaf_providers.dart';

/// The two diagnostic overlay toggles (weak-line, mutashābihāt). Both default
/// **off** — a clean page first; diagnostics are opt-in, never forced on the
/// sacred surface. Flipping a toggle is display-only (E13-T02): it mutates no
/// card, writes no `review_log`, and shows no badge/count/celebration.
class ReaderOverlayToggles extends ConsumerWidget {
  /// Creates the toggles bound to the reader opened at [entryPage].
  const ReaderOverlayToggles({required this.entryPage, super.key});

  /// The reader-state store family key whose overlay bits these toggles flip.
  final int entryPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(mushafReaderStateProvider(entryPage));
    final notifier = ref.read(mushafReaderStateProvider(entryPage).notifier);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          isSelected: state.isWeakLineOverlayVisible,
          onPressed: notifier.toggleWeakLineOverlay,
          tooltip: l10n.mushafOverlayWeakLines,
          icon: const Icon(Icons.subject_outlined),
          selectedIcon: const Icon(Icons.subject),
        ),
        IconButton(
          isSelected: state.isMutashabihatOverlayVisible,
          onPressed: notifier.toggleMutashabihatOverlay,
          tooltip: l10n.mushafOverlayMutashabihat,
          icon: const Icon(Icons.compare_arrows_outlined),
          selectedIcon: const Icon(Icons.compare_arrows),
        ),
      ],
    );
  }
}
