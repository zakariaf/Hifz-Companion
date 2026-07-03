// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async' show unawaited;

import 'package:composition/composition.dart' show sourceLinkLauncherProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../design_system/certainty/certainty_label.dart';
import '../design_system/certainty/certainty_strings.dart';
import '../design_system/theme/spacing_tokens.dart';
import '../design_system/widgets/mihrab_arch_header.dart';
import '../design_system/widgets/mihrab_note_card.dart';
import 'science_copy.dart';
import 'science_providers.dart';
import 'widgets/science_source_row.dart';

/// "The science we follow" — the offline, read-only projection of the CLAIMS
/// register (science doc §1–§8). It renders the bundled register grouped A–J as
/// calm cards, opens calmly with the no-promise honesty intro, and ends with the
/// always-reachable plain-words grade legend. It is reference, opened when
/// wanted: no streak, badge, progress bar, "N of M read", or celebration.
///
/// A dumb View: it reads [scienceGroupsProvider] (the static read model) and
/// authors no fact. A source link is opened through the injected
/// [sourceLinkLauncherProvider] (system browser); the app makes no in-app fetch.
class ScienceScreen extends ConsumerWidget {
  /// Creates the science screen.
  const ScienceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final sections = ref.watch(scienceGroupsProvider);
    final strings = CertaintyStrings.of(l10n);

    void openSource(String url) =>
        unawaited(ref.read(sourceLinkLauncherProvider).open(url));

    return Semantics(
      key: const ValueKey<String>('screen.science'),
      identifier: 'screen.science',
      container: true,
      label: l10n.scienceTitle,
      explicitChildNodes: true,
      child: Column(
        children: [
          // A pushed screen carries its own miḥrāb niche (no shared header
          // outside the tab shell). Decorative chrome only.
          MihrabArchHeader(title: l10n.scienceTitle),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: EdgeInsetsDirectional.only(bottom: space.space8),
                children: [
                  SizedBox(height: space.space4),
                  // The no-promise / honesty framing, up front and calm, in a
                  // calm-keyline note (science §5/§6).
                  Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: space.space4,
                    ),
                    child: MihrabNoteCard(text: l10n.scienceIntro),
                  ),
                  SizedBox(height: space.space2),
                  for (final section in sections) ...[
                    _GroupHeader(
                      label: scienceGroupLabel(l10n, section.group),
                    ),
                    for (final claim in section.claims)
                      ScienceSourceRow(claim: claim, onOpenSource: openSource),
                  ],
                  SizedBox(height: space.space6),
                  // The grade legend in plain words — always reachable (§4).
                  Padding(
                    padding: EdgeInsetsDirectional.all(space.space4),
                    child: CertaintyLegend(
                      strings: strings,
                      title: l10n.certaintyLegendTitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A calm theme-group header (one of CLAIMS groups A–J).
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        space.space4,
        space.space5,
        space.space4,
        space.space2,
      ),
      child: Text(
        label,
        style: theme.textTheme.titleMedium
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}
