// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/spacing_tokens.dart';
import 'onboarding_glyphs.dart';

/// The first cold-start capture pass (E11-T05): a juz-level tap grid of 30 cells
/// in **muṣḥaf order** (juz ۱ at the start/right under RTL, juz ۳۰ at the end),
/// one tap = held / not-held. A held juz is membership in [heldJuz]; an un-held
/// juz is **absence** — drawn calm and un-emphasised, never alarm-red / "missing"
/// / "0%". Held vs un-held is carried by shape (a filled zellige star vs a dashed
/// ring) + glyph + label, never hue alone (SC 1.4.1). Each cell is a ≥48 dp
/// `toggled` Semantics node with a visible focus ring and a locale-numeral label.
///
/// The Mihrab surface (owner-directed design amendment, concept 01): a glazed
/// teal title band watermarked with faint eight-point stars over a terracotta
/// ground-line, held cells rendered as glazed teal zellige tiles and un-held
/// cells as bare limestone.
///
/// A dumb View: it takes [heldJuz] + [onToggle] and renders. It holds no local
/// capture state, opens no `db.transaction`/DAO, reads no clock, and draws no
/// muṣḥaf glyph — it captures juz-level self-report taps only (the seed is
/// E11-T09's single write path).
class CoverageCaptureGrid extends StatelessWidget {
  /// Creates the grid reflecting [heldJuz].
  const CoverageCaptureGrid({
    required this.heldJuz,
    required this.onToggle,
    super.key,
  });

  /// The currently-held juz (1–30); absence = `UNMEMORIZED`.
  final Set<int> heldJuz;

  /// Called with the tapped juz to toggle its membership.
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            space.space4,
            space.space4,
            space.space4,
            space.space2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CoverageTitleBanner(title: l10n.onboardingCoverageTitle),
              SizedBox(height: space.space2),
              Text(
                l10n.onboardingCoverageInstruction,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsetsDirectional.fromSTEB(
              space.space4,
              space.space2,
              space.space4,
              space.space4,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // 5 columns — square cells stay well over the 48 dp tap floor.
              crossAxisCount: 5,
              mainAxisSpacing: space.space2,
              crossAxisSpacing: space.space2,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              // index 0 = juz ۱ at the start (right) under RTL; index 29 = juz ۳۰.
              final juz = index + 1;
              final held = heldJuz.contains(juz);
              final numeral = formatLocaleNumber(locale, juz);
              return _JuzCell(
                numeral: numeral,
                held: held,
                label: l10n.onboardingCoverageCellLabel(
                  numeral,
                  held ? l10n.onboardingHeld : l10n.onboardingNotHeld,
                ),
                onTap: () => onToggle(juz),
              );
            },
          ),
        ),
        _CoverageLegend(
          heldLabel: l10n.onboardingHeld,
          notHeldLabel: l10n.onboardingNotHeld,
        ),
      ],
    );
  }
}

/// The glazed-teal title band: a leading zellige star, the [title] in the
/// on-primary ink, a faint eight-point-star watermark, and a terracotta
/// ground-line — the concept's miḥrāb band, in miniature. Non-interactive.
class _CoverageTitleBanner extends StatelessWidget {
  const _CoverageTitleBanner({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final mihrab = theme.extension<MihrabColors>()!;
    final radius = BorderRadius.circular(space.space3);
    return ClipRRect(
      borderRadius: radius,
      child: CustomPaint(
        painter: _BandPainter(
          band: scheme.primary,
          star: scheme.onPrimary.withValues(alpha: 0.1),
          terracotta: mihrab.semanticWarning,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            space.space4,
            space.space3,
            space.space4,
            space.space3 + space.space1,
          ),
          child: Row(
            children: [
              MihrabGlyph(
                kind: MihrabGlyphKind.filledStar,
                color: mihrab.accentGold,
                size: space.space5,
              ),
              SizedBox(width: space.space3),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JuzCell extends StatelessWidget {
  const _JuzCell({
    required this.numeral,
    required this.held,
    required this.label,
    required this.onTap,
  });

  final String numeral;
  final bool held;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final mihrab = theme.extension<MihrabColors>()!;
    final radius = BorderRadius.circular(space.space3);
    // One merged node carrying the composed "Juz N, held/not held" label + the
    // toggle state + the tap action; the inner glyph/numeral are excluded so the
    // screen reader voices the cell as a single control.
    return MergeSemantics(
      child: Semantics(
        button: true,
        toggled: held,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          focusColor: scheme.primary.withValues(alpha: 0.12),
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                // Held reads as a glazed teal zellige tile; un-held as bare
                // limestone — calm absence, never an alarm state.
                color: held ? scheme.primary : scheme.surfaceContainerHighest,
                border: Border.all(
                  color: held ? scheme.primary : scheme.outlineVariant,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: space.space1,
                children: [
                  Text(
                    numeral,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: held ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                  // Redundant non-colour encoding: a solid zellige star when
                  // held, a dashed ring when not — readable in grayscale / CVD.
                  MihrabGlyph(
                    kind: held
                        ? MihrabGlyphKind.filledStar
                        : MihrabGlyphKind.dashedRing,
                    color: held ? mihrab.accentGold : scheme.outline,
                    size: space.space5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The quiet held / not-held key beneath the grid — the same glyph language the
/// cells use, so the shape encoding is legible without relying on hue.
class _CoverageLegend extends StatelessWidget {
  const _CoverageLegend({required this.heldLabel, required this.notHeldLabel});

  final String heldLabel;
  final String notHeldLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final mihrab = theme.extension<MihrabColors>()!;
    // A visual key only — the cells carry their own state to the screen reader.
    return ExcludeSemantics(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          space.space4,
          space.space1,
          space.space4,
          space.space4,
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: space.space5,
          runSpacing: space.space2,
          children: [
            _LegendItem(
              kind: MihrabGlyphKind.filledStar,
              color: mihrab.accentGold,
              label: heldLabel,
            ),
            _LegendItem(
              kind: MihrabGlyphKind.dashedRing,
              color: scheme.outline,
              label: notHeldLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.kind,
    required this.color,
    required this.label,
  });

  final MihrabGlyphKind kind;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MihrabGlyph(kind: kind, color: color, size: space.space4),
        SizedBox(width: space.space2),
        Text(
          label,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Paints the glazed-teal band: a solid ground, a faint eight-point-star
/// watermark tiled on a straight grid, and a terracotta ground-line along the
/// lower edge — echoing [MihrabArchHeader] in a compact section band.
class _BandPainter extends CustomPainter {
  const _BandPainter({
    required this.band,
    required this.star,
    required this.terracotta,
  });

  final Color band;
  final Color star;
  final Color terracotta;

  static const double _cell = 40;
  static const double _starOuter = 10;
  static const double _starInnerRatio = 0.5;
  static const double _terracottaThickness = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = band);

    final starPaint = Paint()..color = star;
    for (var y = _cell / 2; y < size.height + _cell; y += _cell) {
      for (var x = _cell / 2; x < size.width + _cell; x += _cell) {
        canvas.drawPath(
          eightPointStarPath(
            Offset(x, y),
            _starOuter,
            _starOuter * _starInnerRatio,
          ),
          starPaint,
        );
      }
    }

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height - _terracottaThickness,
        size.width,
        _terracottaThickness,
      ),
      Paint()..color = terracotta,
    );
  }

  @override
  bool shouldRepaint(_BandPainter old) =>
      old.band != band || old.star != star || old.terracotta != terracotta;
}
