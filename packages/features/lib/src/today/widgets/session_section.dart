// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:engine/engine.dart' show Card, ReviewTrack;
import 'package:flutter/material.dart' hide Card;
import 'package:l10n/l10n.dart';

import '../../design_system/page_card/page_card.dart';
import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../../l10n/term_set.dart';
import 'page_card_data.dart';
import 'teacher_sourced_marker.dart';

/// One section of the daily-session list — a quiet localized term-set header in
/// `type.title` and its E10 page-card rows (07-components §1). The feature layer
/// maps each `Card` of this section's [track] into the domain-blind
/// [PageCardViewData]; the row is one ≥48dp tap into the recite route, with no
/// Quran glyph and no D/S/R on it. Returns a sliver group so the parent
/// `CustomScrollView` keeps the three sections in their fixed order. An empty
/// section is never rendered (the parent omits it) — there is no orphan header.
class SessionSection extends StatelessWidget {
  /// Creates the section for [track] over its already-ordered [pages].
  const SessionSection({
    required this.track,
    required this.pages,
    required this.juzOf,
    required this.onOpen,
    this.region = kDefaultTermSetRegion,
    super.key,
  });

  /// The phase this section renders (drives the header term + the chip family).
  final ReviewTrack track;

  /// The section's pages, in the engine's recitation order (never re-sorted).
  final List<Card> pages;

  /// Resolves the 1-based juz for a page id (reference metadata, injected).
  final int Function(int pageId) juzOf;

  /// Opens the recite route for the tapped page.
  final void Function(int pageId) onOpen;

  /// The active term-set region for the header + chip vocabulary.
  final String region;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final header = switch (track) {
      ReviewTrack.far => l10n.sectionFarManzil(region),
      ReviewTrack.near => l10n.sectionNearSabqi(region),
      ReviewTrack.newPage => l10n.sectionNewSabaq(region),
      ReviewTrack.unmemorized => l10n.sectionNewSabaq(region),
    };

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsetsDirectional.only(
            top: space.space6,
            start: space.space4,
            end: space.space4,
            bottom: space.space2,
          ),
          sliver: SliverToBoxAdapter(
            child: _SessionSectionBand(header: header),
          ),
        ),
        SliverList.separated(
          itemCount: pages.length,
          separatorBuilder: (_, __) => SizedBox(height: space.space2),
          itemBuilder: (context, index) {
            final card = pages[index];
            return Padding(
              key: ValueKey<int>(card.pageId),
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: space.space4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MihrabPageCard(
                    data: todayPageCardData(
                      card: card,
                      track: track,
                      juz: juzOf(card.pageId),
                      l10n: l10n,
                      region: region,
                    ),
                    onOpen: () => onOpen(card.pageId),
                  ),
                  // A teacher (talaqqī) sign-off is marked by shape + label,
                  // never color alone, so self/teacher are never conflated.
                  if (card.signoffs > 0) const TeacherSourcedMarker(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// The section's glazed-teal tile band (concept 02): the localized term-set
/// [header] in cream, right-aligned on a faint eight-point zellige star
/// watermark, with a gold khatam star on the trailing edge and a thin
/// terracotta rule at the foot. Purely decorative chrome around the heading —
/// it draws no Quran glyph and carries no state; the term text is the one
/// heading node the screen reader announces.
class _SessionSectionBand extends StatelessWidget {
  const _SessionSectionBand({required this.header});

  /// The already-localized section term (e.g. «منزل · دور»).
  final String header;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final mihrab = theme.extension<MihrabColors>()!;
    return Semantics(
      header: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(space.space3),
        child: CustomPaint(
          painter: _SectionBandPainter(
            ground: scheme.primary,
            star: scheme.onPrimary,
            rule: mihrab.semanticWarning,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: space.space4,
              vertical: space.space3,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    header,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: space.space3),
                SizedBox(
                  width: space.space5,
                  height: space.space5,
                  child: CustomPaint(
                    painter: _LeadingStarPainter(color: mihrab.accentGold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Builds an eight-point khatam-star outline centred on [center] with the given
/// [outerRadius] (the Mihrab ornament used across the tile band).
Path _khatamStarPath(Offset center, double outerRadius) {
  const points = 8;
  final innerRadius = outerRadius * 0.52;
  final path = Path();
  for (var i = 0; i < points * 2; i++) {
    final radius = i.isEven ? outerRadius : innerRadius;
    final angle = (i * math.pi / points) - math.pi / 2;
    final point = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
  }
  return path..close();
}

/// Paints the band background: the glazed-teal [ground], a faint tiled
/// eight-point [star] watermark (cream at low opacity), and a thin terracotta
/// [rule] along the lower edge.
class _SectionBandPainter extends CustomPainter {
  const _SectionBandPainter({
    required this.ground,
    required this.star,
    required this.rule,
  });

  final Color ground;
  final Color star;
  final Color rule;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = ground);

    // A staggered lattice of faint eight-point stars — a low-opacity cream
    // watermark, clipped by the parent to the band's rounded corners.
    final watermark = Paint()
      ..color = star.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeJoin = StrokeJoin.round;
    final outer = size.height * 0.36;
    final stepX = outer * 1.9;
    final stepY = outer * 1.7;
    final cols = (size.width / stepX).ceil() + 2;
    final rows = (size.height / stepY).ceil() + 2;
    for (var row = -1; row < rows; row++) {
      final cy = row * stepY;
      final indent = row.isEven ? 0.0 : stepX / 2;
      for (var col = -1; col < cols; col++) {
        canvas.drawPath(
          _khatamStarPath(Offset(col * stepX + indent, cy), outer),
          watermark,
        );
      }
    }

    final ruleHeight = size.height * 0.06;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - ruleHeight, size.width, ruleHeight),
      Paint()..color = rule,
    );
  }

  @override
  bool shouldRepaint(_SectionBandPainter oldDelegate) =>
      oldDelegate.ground != ground ||
      oldDelegate.star != star ||
      oldDelegate.rule != rule;
}

/// Paints the small solid gold khatam star on the band's trailing edge.
class _LeadingStarPainter extends CustomPainter {
  const _LeadingStarPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _khatamStarPath(size.center(Offset.zero), size.shortestSide / 2),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_LeadingStarPainter oldDelegate) =>
      oldDelegate.color != color;
}
