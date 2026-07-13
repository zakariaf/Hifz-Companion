// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// A calm Settings group: a limestone *niche card* whose header pairs a quiet
/// localized [title] with a small teal zellige star, over its [children] rows,
/// on the `space.*` grid with logical insets so it mirrors for fa/ckb/ar
/// unchanged (design-system 05 §section spacing; 07 §6 grouping; concept 07).
///
/// Domain-blind: it shows only the pre-localized [title] and whatever rows the
/// caller supplies — it formats no number, reads no provider, and persists
/// nothing. Each child manages its own logical horizontal inset; the card only
/// frames and titles them.
class SettingsSection extends StatelessWidget {
  /// Creates a settings group titled [title] containing [children].
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  /// The pre-localized group header.
  final String title;

  /// The group's rows (pickers, navigation rows, or a placeholder line).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    return Card(
      // The niche card floats on the limestone ground with a quiet gap between
      // sections; the cream surface + soft border come from the card theme.
      margin: EdgeInsetsDirectional.only(
        start: space.space4,
        end: space.space4,
        top: space.space3,
        bottom: space.space1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: space.space4,
              end: space.space4,
              top: space.space4,
              bottom: space.space2,
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: space.space2),
                // A quiet mihrab zellige star — decorative ornament, not a
                // reward or rating glyph (adab); excluded from the a11y tree.
                ExcludeSemantics(
                  child: _ZelligeStar(
                    color: scheme.primary,
                    size: space.space5,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          SizedBox(height: space.space4),
        ],
      ),
    );
  }
}

/// A small eight-point zellige star (rub-el-hizb-family) drawn as a filled
/// polygon — the calm mihrab-architecture section marker (concept 07). Purely
/// decorative; its [color] is a named role passed by the caller.
class _ZelligeStar extends StatelessWidget {
  const _ZelligeStar({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _ZelligeStarPainter(color)),
      );
}

class _ZelligeStarPainter extends CustomPainter {
  const _ZelligeStarPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final center = size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    final inner = outer * 0.42;
    const points = 8;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / points;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ZelligeStarPainter oldDelegate) =>
      oldDelegate.color != color;
}
