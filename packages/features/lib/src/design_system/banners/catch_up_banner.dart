// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../page_card/page_card.dart';
import '../page_card/page_card_view_data.dart';
import '../theme/mihrab_colors.dart';
import '../theme/spacing_tokens.dart';

/// The user-owned choices a [CatchUpBanner] offers (voice 11 §4) — hard news
/// ends in options the user owns, never a single mandated fix.
enum CatchUpChoice {
  /// Start the engine's re-spread plan.
  startPlan,

  /// Adjust the plan.
  adjust,

  /// Decide later — blameless.
  defer,
}

/// The engine's already-computed re-spread plan — display data only (the spread,
/// its order, and which items are mandatory are computed by E04, never here).
@immutable
class CatchUpPlan {
  /// Creates a plan over [items] (already ordered most-decayed/prayer-critical
  /// first); [missedDays]/[planDays] are carried for reference.
  const CatchUpPlan({
    required this.missedDays,
    required this.planDays,
    required this.items,
  });

  /// The number of days passed without revision (the honest fact).
  final int missedDays;

  /// The number of days the re-spread plan covers.
  final int planDays;

  /// The plan rows, in the order the engine set (FAR/manzil items mandatory —
  /// never elided to shorten the plan).
  final List<PageCardViewData> items;
}

/// The calm missed-day catch-up banner (voice 11 §4; PRD §7.9) — empathy →
/// honest fact → concrete path → the user's choice.
///
/// Domain-blind: it renders a pre-built [CatchUpPlan] (reusing the page card for
/// each row) and the already-localized [empathy]/[factLine]/[pathLine], and emits
/// a [CatchUpChoice] through [onChoice] — it computes no spread, reads no clock,
/// mutates nothing, opens no socket. A calm cream card (`surfaceContainer`)
/// carried by one warm terracotta accent (`semanticWarning`): a thick rule down
/// the trailing edge, a small mihrab-niche `!` badge leading the announcement,
/// and a terracotta-tinted headline — warm attention framing a way forward,
/// never a red overdue pile; any decay reads as receding green; never greets the
/// gap, never "you're behind", no streak/celebration.
class CatchUpBanner extends StatelessWidget {
  /// Creates the banner from a pre-built plan + localized copy + a choice sink.
  const CatchUpBanner({
    required this.plan,
    required this.empathy,
    required this.factLine,
    required this.pathLine,
    required this.startLabel,
    required this.adjustLabel,
    required this.deferLabel,
    required this.onChoice,
    super.key,
  });

  /// The engine's pre-built re-spread plan.
  final CatchUpPlan plan;

  /// The already-localized empathy line.
  final String empathy;

  /// The already-localized honest-fact line ("N days passed without revision").
  final String factLine;

  /// The already-localized path line ("a plan over M days that completes...").
  final String pathLine;

  /// The already-localized "start plan" choice label.
  final String startLabel;

  /// The already-localized "adjust" choice label.
  final String adjustLabel;

  /// The already-localized "defer" choice label.
  final String deferLabel;

  /// Emits the user's choice; the single output of the banner.
  final ValueChanged<CatchUpChoice> onChoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = theme.extension<MihrabColors>()!;
    final space = theme.extension<SpacingTokens>()!;
    final text = theme.textTheme;
    final warm = colors.semanticWarning;
    final minTouch = Size(space.space8, space.space8);

    return Card(
      elevation: 0,
      color: scheme.surfaceContainer,
      // Clip so the thick terracotta trailing rule follows the rounded corners.
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.all(space.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // The mihrab-niche `!` badge leads the calm announcement; the
                // headline carries the warm terracotta tint (warm attention,
                // never red alarm), the fact/path read as one muted body.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _MihrabAlertBadge(),
                    SizedBox(width: space.space3),
                    Expanded(
                      child: MergeSemantics(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              empathy,
                              style: text.titleMedium?.copyWith(
                                color: warm,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: space.space2),
                            Text(factLine, style: text.bodyMedium),
                            SizedBox(height: space.space1),
                            Text(
                              pathLine,
                              style: text.bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: space.space3),
                for (final item in plan.items)
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: space.space2),
                    child: MihrabPageCard(data: item, onOpen: () {}),
                  ),
                SizedBox(height: space.space3),
                // The choices — user-owned, never a single mandate. The primary
                // path is a warm terracotta fill; adjust is a calm cream pill;
                // deferring is blameless and low-emphasis.
                Wrap(
                  spacing: space.space2,
                  runSpacing: space.space2,
                  children: [
                    FilledButton(
                      onPressed: () => onChoice(CatchUpChoice.startPlan),
                      style: FilledButton.styleFrom(
                        backgroundColor: warm,
                        foregroundColor: scheme.onPrimary,
                        // Bold cream on the warm fill: a clear primary path with
                        // ample contrast on the terracotta ground.
                        textStyle: text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(startLabel),
                    ),
                    OutlinedButton(
                      onPressed: () => onChoice(CatchUpChoice.adjust),
                      style: OutlinedButton.styleFrom(
                        minimumSize: minTouch,
                        backgroundColor: scheme.surface,
                        foregroundColor: scheme.onSurface,
                        side: BorderSide(color: scheme.outline),
                      ),
                      child: Text(adjustLabel),
                    ),
                    TextButton(
                      onPressed: () => onChoice(CatchUpChoice.defer),
                      // Deferring is blameless and low-emphasis: a calm muted
                      // label, never a bright competing call.
                      style: TextButton.styleFrom(
                        minimumSize: minTouch,
                        foregroundColor: scheme.onSurfaceVariant,
                      ),
                      child: Text(deferLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // The one warm accent: a thick terracotta rule down the trailing edge
          // — a mihrab-frame line, never a red-alarm fill (03 §6).
          PositionedDirectional(
            top: 0,
            bottom: 0,
            end: 0,
            width: space.space2,
            child: ColoredBox(color: warm),
          ),
        ],
      ),
    );
  }
}

/// A small mihrab-niche badge holding a calm `!` — warm terracotta attention on
/// a soft terracotta ground, the leading mark of the catch-up announcement.
///
/// Purely decorative: the missed-day meaning is carried by the headline text, so
/// it is excluded from the semantics tree.
class _MihrabAlertBadge extends StatelessWidget {
  const _MihrabAlertBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final warm = theme.extension<MihrabColors>()!.semanticWarning;
    return ExcludeSemantics(
      child: SizedBox(
        width: space.space7,
        height: space.space7 + space.space2,
        child: CustomPaint(
          painter: _NichePainter(
            stroke: warm,
            fill: warm.withValues(alpha: 0.12),
          ),
          child: Center(
            child: Icon(Icons.priority_high, size: space.space5, color: warm),
          ),
        ),
      ),
    );
  }
}

/// Draws a mihrab niche — vertical jambs rising into a rounded arch over a flat
/// sill — filled with a soft ground and outlined in the accent.
class _NichePainter extends CustomPainter {
  const _NichePainter({required this.stroke, required this.fill});

  final Color stroke;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 1.0; // keep the 1.5px stroke inside the box.
    final right = size.width - inset;
    final bottom = size.height - inset;
    final spring = size.height * 0.42; // where the jambs turn into the arch.
    final path = Path()
      ..moveTo(inset, bottom)
      ..lineTo(inset, spring)
      ..quadraticBezierTo(inset, inset, size.width / 2, inset)
      ..quadraticBezierTo(right, inset, right, spring)
      ..lineTo(right, bottom)
      ..close();
    canvas
      ..drawPath(path, Paint()..color = fill)
      ..drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_NichePainter oldDelegate) =>
      oldDelegate.stroke != stroke || oldDelegate.fill != fill;
}
