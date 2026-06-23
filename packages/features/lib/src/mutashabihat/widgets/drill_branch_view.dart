// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MutashabihMemberView;
import 'package:quran/quran.dart'
    show
        MushafOverlayPainter,
        MushafReaderPage,
        OverlayKind,
        OverlayMarker,
        OverlayStyle;

import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/motion_tokens.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../discrimination_drill_view_model.dart' show BranchPhase;
import '../mutashabihat_providers.dart';

/// One drill branch: the member's immutable muṣḥaf page, occluded until a reveal
/// tap, then (after a second tap) the distinguishing-word anchor (E14-T08).
///
/// Phase order is mandatory (science 05 §6): `hidden` (recite from memory) →
/// `revealed` (the page is shown) → `anchored` (the overlay is added). The page
/// is drawn glyph-only by E05's [MushafReaderPage] — never re-typeset, reshaped,
/// or reflowed; only the reveal cover's opacity animates. The anchor is wired as
/// a coordinate [MushafOverlayPainter] seam (the index→`WordRef` math is
/// E14-T09); bundle-first it resolves to no words and draws nothing.
class DrillBranchView extends ConsumerWidget {
  /// Creates a branch view for [member] in [phase].
  const DrillBranchView({
    required this.member,
    required this.phase,
    required this.onReveal,
    required this.onShowAnchor,
    super.key,
  });

  /// The group member this branch draws.
  final MutashabihMemberView member;

  /// The branch's current recall phase.
  final BranchPhase phase;

  /// Called when the reveal cover is tapped (`hidden → revealed`).
  final VoidCallback onReveal;

  /// Called when the revealed page is tapped (`revealed → anchored`).
  final VoidCallback onShowAnchor;

  /// An identity colour filter — the drill applies no theme tint to the page.
  static const ColorFilter _identity = ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final motion = Theme.of(context).extension<MotionTokens>()!;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final lines = ref.watch(drillPageLinesProvider(member.pageNumber));
    final revealed = phase != BranchPhase.hidden;
    final anchored = phase == BranchPhase.anchored;

    final page = lines.maybeWhen(
      data: (refs) => MushafReaderPage(
        pageNumber: member.pageNumber,
        lines: refs,
        zoom: 1,
        colorFilter: _identity,
        overlay: anchored ? _anchorOverlay(context, ref) : null,
      ),
      // Bundle-first / while the offline reference resolves: a calm blank, never
      // a spinner over the sacred surface.
      orElse: () => const SizedBox.expand(),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Tapping the revealed (pre-anchor) page adds the anchor. Opaque so the
        // whole page area accepts the tap even before glyphs give it size.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: phase == BranchPhase.revealed ? onShowAnchor : null,
          child: page,
        ),
        IgnorePointer(
          ignoring: revealed,
          child: AnimatedOpacity(
            opacity: revealed ? 0 : 1,
            duration: reduceMotion ? Duration.zero : motion.durationShort,
            curve: motion.curveStandard,
            child: _RevealCover(
              label: l10n.mutashabihatDrillReveal,
              onReveal: onReveal,
            ),
          ),
        ),
      ],
    );
  }

  MushafOverlayPainter? _anchorOverlay(BuildContext context, WidgetRef ref) {
    final words = ref.watch(drillAnchorWordsProvider)(member);
    if (words.isEmpty) return null; // E14-T09 supplies the real WordRefs
    final theme = Theme.of(context);
    final colors = theme.extension<MihrabColors>()!;
    final space = theme.extension<SpacingTokens>()!;
    return MushafOverlayPainter(
      markers: [
        OverlayMarker(kind: OverlayKind.mutashabihAnchor, words: words),
      ],
      geometry: ref.watch(drillPageGeometryProvider(member.pageNumber)),
      style: OverlayStyle(
        // A calm low-alpha gold over the divergence — never a red shame mark.
        fillColors: {
          OverlayKind.mutashabihAnchor:
              colors.accentGold.withValues(alpha: 0.18),
        },
        cornerRadius: space.space1,
      ),
    );
  }
}

/// The calm reveal cover — a tappable surface inviting the ḥāfiẓ to recite the
/// continuation from memory before revealing the page (retrieval practice).
class _RevealCover extends StatelessWidget {
  const _RevealCover({required this.label, required this.onReveal});

  final String label;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        child: InkWell(
          onTap: onReveal,
          child: Center(
            child: Padding(
              padding: EdgeInsetsDirectional.all(space.space6),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
