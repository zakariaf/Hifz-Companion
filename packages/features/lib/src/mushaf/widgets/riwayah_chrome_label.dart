// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition;

import '../../design_system/theme/mihrab_colors.dart';
import 'mushaf_about.dart';

/// The always-visible riwāyah/edition chrome label (R2): it names the muṣḥaf the
/// reader is showing — the active [MushafEdition.displayName] (e.g. "Ḥafṣ ʿan
/// ʿĀṣim — Madani muṣḥaf") — so the page is **never** presented as "the Quran"
/// absolutely, and a quiet "About this muṣḥaf" affordance opens the
/// Tanzil/QUL/KFGQPC attribution + checksum guarantee.
///
/// In the Mihrab reader that affordance is drawn as a small gold **hanging lamp**
/// (a qandīl) suspended from the label on a thin gold cord — the lamp *is* the
/// info/About button, echoing the muqarnas trio that crowns the arch below it.
///
/// It is **chrome, not scripture**: ordinary shaped UI text on the `type.*`
/// ramp in the bundled UI font — never the QPC page font, never a `glyphCodes`
/// string, never a `fontFamilyFallback`. It lives outside the page's
/// `ColorFilter`/`Transform.scale` frame, so theme/zoom never recolour or scale
/// it with the glyph layer. Display-only: it swaps no edition (E16 owns that).
class RiwayahChromeLabel extends StatelessWidget {
  /// Creates the label for the active [edition].
  const RiwayahChromeLabel({required this.edition, super.key});

  /// The active edition whose `displayName`/`riwayah` is named.
  final MushafEdition edition;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mihrab = theme.extension<MihrabColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          // The displayName is a mixed Latin/Arabic run — FSI/PDI-isolate it
          // so it reads correctly inside the RTL chrome (engineering 12 §4).
          isolate(edition.displayName),
          style: theme.textTheme.titleSmall
              ?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        _HangingLamp(
          onPressed: () => showMushafAbout(context, edition: edition),
          tooltip: l10n.mushafAboutTitle,
          gold: mihrab.accentGold,
        ),
      ],
    );
  }
}

/// The gold hanging lamp that opens the About/attribution sheet. An [IconButton]
/// so it carries the ≥48dp touch floor, the tooltip label, and the button
/// semantics for free; the qandīl silhouette is a coordinate painter, drawn only
/// in the chrome band and never over the glyph layer.
class _HangingLamp extends StatelessWidget {
  const _HangingLamp({
    required this.onPressed,
    required this.tooltip,
    required this.gold,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final Color gold;

  // The lamp motif box (component geometry, not a design token).
  static const double _lampWidth = 30;
  static const double _lampHeight = 34;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: SizedBox(
        width: _lampWidth,
        height: _lampHeight,
        child: CustomPaint(painter: _HangingLampPainter(gold: gold)),
      ),
    );
  }
}

/// Paints the suspended qandīl: a thin gold cord dropping from the label to a
/// small mount, a softly-glowing gold lamp body, and a finial bead.
class _HangingLampPainter extends CustomPainter {
  const _HangingLampPainter({required this.gold});

  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final mountY = size.height * 0.30;
    final bulbTop = size.height * 0.42;
    final bulbBottom = size.height * 0.90;
    final bulbHalf = size.width * 0.26;

    // The soft gold halo behind the lamp.
    canvas.drawCircle(
      Offset(cx, (bulbTop + bulbBottom) / 2),
      bulbHalf * 1.6,
      Paint()
        ..color = gold.withValues(alpha: 0.26)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // The thin cord from the label down to the mount, and the mount bead.
    final line = Paint()
      ..color = gold
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, 0), Offset(cx, mountY), line);
    final solid = Paint()..color = gold;
    canvas.drawCircle(Offset(cx, mountY), 2.2, solid);

    // The rounded lamp body and its finial bead.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - bulbHalf, bulbTop, cx + bulbHalf, bulbBottom),
        Radius.circular(bulbHalf * 0.7),
      ),
      solid,
    );
    canvas.drawCircle(Offset(cx, bulbBottom + 1.6), 1.6, solid);
  }

  @override
  bool shouldRepaint(_HangingLampPainter old) => old.gold != gold;
}
