// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show activeProfileProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ConfusionEdge;

import '../../design_system/banners/empty_state.dart';
import '../discrimination_drill_route.dart';
import '../mutashabihat_providers.dart';

/// The personal confusion-hotspots body (E14-T10): a calm, read-only list of the
/// active profile's own most-confused pairs — "you keep swapping these two" —
/// each row tapping into the pair's whole-group discrimination drill.
///
/// Actionable information, never a scoreboard: no `weight`/score/streak/badge,
/// no "cured"/"safe to drop". It reads the pre-ranked E14-T06 read model and
/// renders it as given — no sort, no query, no mutation, no `DateTime.now()`,
/// no Quran glyph (pages are named by āyah identity only).
class ConfusionHotspotsView extends ConsumerWidget {
  /// Creates the hotspots body.
  const ConfusionHotspotsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(activeProfileProvider);
    if (profile == null) return _empty(l10n);
    final hotspots = ref.watch(confusionHotspotsProvider(profile));
    return hotspots.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: FilledButton(
          onPressed: () => ref.invalidate(confusionHotspotsProvider(profile)),
          child: Text(l10n.commonRetry),
        ),
      ),
      data: (rows) => rows.isEmpty
          ? _empty(l10n)
          : ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, index) =>
                  _ConfusionHotspotRow(edge: rows[index]),
            ),
    );
  }

  // The empty list is the GOOD state (nothing is being swapped) — a calm,
  // welcoming aid-to-revision line, never "you haven't logged" / a 0-score.
  Widget _empty(AppLocalizations l10n) => EmptyState(
        model: EmptyStateModel(
          kind: EmptyStateKind.firstRun,
          body: l10n.mutashabihatTrainerIntro,
        ),
      );
}

/// One confusion pair, named by its two āyah identities in locale numerals; the
/// whole row taps into the pair's whole-group drill (group-not-node). A flat,
/// label-only tile — no Quran glyph, no track chip, no decay gauge, no number.
class _ConfusionHotspotRow extends ConsumerWidget {
  const _ConfusionHotspotRow({required this.edge});

  final ConfusionEdge edge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final first = _ayahRef(l10n, locale, edge.ayahA);
    final second = _ayahRef(l10n, locale, edge.ayahB);
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: l10n.mutashabihatHotspotSemantic(first, second),
        child: ListTile(
          leading: const ExcludeSemantics(
            child: Icon(Icons.compare_arrows_outlined),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [Text(first), Text(second)],
          ),
          trailing: const Icon(Icons.chevron_left), // mirrors under RTL
          onTap: () => _openDrill(context, ref),
        ),
      ),
    );
  }

  Future<void> _openDrill(BuildContext context, WidgetRef ref) async {
    // Resolve the pair to its drillable group; bundle-first there is none yet,
    // so the row stays informational (never navigates to a guessed group).
    final groupId = await ref.read(hotspotGroupIdProvider(edge.ayahA).future);
    if (groupId != null && context.mounted) {
      context.go(mutashabihatDrillLocation(groupId));
    }
  }

  /// Formats an `'s:a'` āyah id as "Surah S · Ayah A" in locale numerals,
  /// bidi-isolated — never raw ints, never reconstructed text.
  String _ayahRef(AppLocalizations l10n, Locale locale, String ayahId) {
    final parts = ayahId.split(':');
    final surah = int.tryParse(parts.first) ?? 0;
    final ayah = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return l10n.ayahRefLabel(
      isolateLtr(localeDigits(surah, locale)),
      isolateLtr(localeDigits(ayah, locale)),
    );
  }
}
