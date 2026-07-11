// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition;

import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/motion_tokens.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../../sabaq/sabaq_intake_controller.dart';
import '../../sabaq/sabaq_providers.dart';
import '../mushaf_providers.dart';
import 'jump_picker.dart';
import 'mushaf_pager.dart';
import 'reader_overlay_toggles.dart';
import 'reader_theme_control.dart';
import 'reader_zoom_control.dart';
import 'riwayah_chrome_label.dart';

/// The "no dashboard" reader surface (design-system 13 §3): the words of the
/// muṣḥaf dominate and the controls recede to a calm edge band over E13-T03's
/// pager. The immutable glyph page renders **inside** a decorative miḥrāb arch —
/// a limestone frame, a terracotta keyline, faint chevron jambs, and a muqarnas
/// leaf-trio at the crown — all drawn *around and behind* the page and **never**
/// over the glyph layer (PRD R1). The riwāyah/edition label is **always**
/// present above the arch (R2). The transient controls (theme, zoom, jump-to,
/// overlay toggles) auto-hide on a calm timer and a tap on the page, and return
/// on a tap, via a single `motion.durationShort` fade — never a celebration,
/// slide-up dashboard, glow, badge, counter, page-flip fanfare, or piety/wuḍūʾ
/// gate.
///
/// `StatefulWidget` only to own and dispose the auto-hide [Timer]; the
/// visibility is display-only UI state — it mutates no engine state.
class MushafChrome extends StatefulWidget {
  /// Creates the chrome over the reader opened at [page] for [edition].
  const MushafChrome({required this.edition, required this.page, super.key});

  /// The active edition the riwāyah label names.
  final MushafEdition edition;

  /// The reader's entry page (the reader-state store family key the pager and
  /// the controls bind to).
  final int page;

  @override
  State<MushafChrome> createState() => _MushafChromeState();
}

class _MushafChromeState extends State<MushafChrome> {
  bool _controlsVisible = true;
  Timer? _autoHide;

  @override
  void dispose() {
    _autoHide?.cancel();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleAutoHide();
  }

  void _scheduleAutoHide() {
    _autoHide?.cancel();
    final dwell = Theme.of(context).extension<MotionTokens>()!.dwellAutoHide;
    _autoHide = Timer(dwell, () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final motion = theme.extension<MotionTokens>()!;
    // Reduce-motion (or the platform animation toggle) snaps without a fade.
    final fade =
        MediaQuery.disableAnimationsOf(context) ? Duration.zero : motion.durationShort;

    return Column(
      children: [
        // Top: the always-present riwāyah/edition label + its hanging lamp (R2).
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: space.space4,
              vertical: space.space2,
            ),
            child: RiwayahChromeLabel(edition: widget.edition),
          ),
        ),
        // Middle: the arch-framed page — the base tap layer (a tap toggles the
        // controls). It carries the localized "page N" Semantics so the screen
        // reader names the current page (it can never read the glyph layer, R1).
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleControls,
            child: Consumer(
              builder: (context, ref, child) {
                final l10n = AppLocalizations.of(context);
                final locale = Localizations.localeOf(context);
                final pageNumber = ref.watch(
                  mushafReaderStateProvider(widget.page)
                      .select((state) => state.pageNumber),
                );
                return Semantics(
                  label: l10n.pageNumber(
                    isolateLtr(formatLocaleNumber(locale, pageNumber)),
                  ),
                  child: child,
                );
              },
              child: _ArchStage(page: widget.page),
            ),
          ),
        ),
        // Bottom: the transient controls, fading calmly in/out. When hidden they
        // ignore pointers so the page tap reaches the base layer above.
        SafeArea(
          top: false,
          child: AnimatedOpacity(
            key: const ValueKey<String>('reader.controls'),
            opacity: _controlsVisible ? 1 : 0,
            duration: fade,
            curve: motion.curveStandard,
            child: IgnorePointer(
              ignoring: !_controlsVisible,
              child: _ControlsBand(page: widget.page),
            ),
          ),
        ),
      ],
    );
  }
}

/// The decorative miḥrāb stage: the limestone arch frame drawn *behind* the
/// pager, with the pager inset into the arch opening so the frame band (keyline,
/// chevron jambs, leaf-trio crown) reads only in the margin — never over the
/// sacred glyphs.
class _ArchStage extends StatelessWidget {
  const _ArchStage({required this.page});

  final int page;

  // The curved cap height as a fraction of the arch's short side.
  static const double _capFraction = 0.26;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final mihrab = theme.extension<MihrabColors>()!;
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: space.space3,
        vertical: space.space2,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cap =
              math.min(constraints.maxWidth, constraints.maxHeight) *
                  _capFraction;
          final frame = space.space5;
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _MihrabReaderFramePainter(
                  cap: cap,
                  frame: frame,
                  fill: scheme.surface,
                  band: scheme.surfaceContainer,
                  outline: scheme.outlineVariant,
                  keyline: mihrab.semanticWarning,
                  chevron: mihrab.accentGold.withValues(alpha: 0.35),
                  leaf: scheme.primary,
                  dot: mihrab.accentGold,
                  shadow: scheme.shadow,
                ),
              ),
              // Inset the page into the arch opening: below the crown + motif,
              // inside the jambs, above the base. The page contains-fits this box
              // (a uniform scale, never a re-flow of the immutable layout).
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  frame + space.space3,
                  cap + space.space4,
                  frame + space.space3,
                  frame + space.space4,
                ),
                child: MushafPager(entryPage: page),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Paints the miḥrāb frame: a soft ground shadow, the limestone band, the paper
/// opening, the outer edge, a terracotta keyline, faint chevron jambs, and the
/// muqarnas leaf-trio at the crown. All coordinate ornament in the margin — it
/// draws **nothing** over the glyph layer that renders on top.
class _MihrabReaderFramePainter extends CustomPainter {
  const _MihrabReaderFramePainter({
    required this.cap,
    required this.frame,
    required this.fill,
    required this.band,
    required this.outline,
    required this.keyline,
    required this.chevron,
    required this.leaf,
    required this.dot,
    required this.shadow,
  });

  final double cap;
  final double frame;
  final Color fill;
  final Color band;
  final Color outline;
  final Color keyline;
  final Color chevron;
  final Color leaf;
  final Color dot;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final outer = _arch(Rect.fromLTWH(0, 0, w, h), cap);
    final inner =
        _arch(Rect.fromLTRB(frame, frame, w - frame, h - frame), cap - frame);

    // A soft ground shadow lifts the niche off the surface.
    canvas.drawShadow(outer, shadow, 3, true);
    // The limestone frame band, then the paper opening over it.
    canvas.drawPath(outer, Paint()..color = band);
    canvas.drawPath(inner, Paint()..color = fill);
    // The outer edge.
    canvas.drawPath(
      outer,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
    // A quiet terracotta keyline just inside the outer edge.
    canvas.drawPath(
      _arch(
        Rect.fromLTRB(
          frame * 0.45,
          frame * 0.45,
          w - frame * 0.45,
          h - frame * 0.45,
        ),
        cap - frame * 0.45,
      ),
      Paint()
        ..color = keyline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
    _chevronJambs(canvas, w, h);
    _leafTrio(canvas, Offset(w / 2, cap * 0.66), cap * 0.16);
  }

  // A gently-pointed arch over [r]: vertical jambs up to the shoulder, then a
  // cubic sweep to a softly-pointed apex at the top centre.
  Path _arch(Rect r, double c) {
    final cx = r.center.dx;
    final shoulderY = r.top + c;
    return Path()
      ..moveTo(r.left, r.bottom)
      ..lineTo(r.left, shoulderY)
      ..cubicTo(r.left, r.top + c * 0.4, cx - c * 0.28, r.top, cx, r.top)
      ..cubicTo(cx + c * 0.28, r.top, r.right, r.top + c * 0.4, r.right, shoulderY)
      ..lineTo(r.right, r.bottom)
      ..close();
  }

  // A faint column of up-chevrons running down each jamb band.
  void _chevronJambs(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = chevron
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cw = frame * 0.18;
    final ch = frame * 0.28;
    final step = frame * 0.9;
    final top = cap + frame;
    final bottom = h - frame * 1.4;
    for (final bandX in [frame * 0.62, w - frame * 0.62]) {
      for (var y = top; y <= bottom; y += step) {
        canvas.drawPath(
          Path()
            ..moveTo(bandX - cw, y + ch)
            ..lineTo(bandX, y)
            ..lineTo(bandX + cw, y + ch),
          paint,
        );
      }
    }
  }

  // The stylized muqarnas leaf-trio — three teal petals over two, crowned by a
  // gold point — echoing the screen-header and arcade motifs.
  void _leafTrio(Canvas canvas, Offset center, double s) {
    Path petal(double dx, double dy) {
      final px = center.dx + dx;
      final py = center.dy + dy;
      final hw = s * 0.62;
      final hh = s * 0.7;
      return Path()
        ..moveTo(px - hw, py)
        ..quadraticBezierTo(px, py - hh, px + hw, py)
        ..quadraticBezierTo(px, py + hh * 0.55, px - hw, py)
        ..close();
    }

    final top = Paint()..color = leaf.withValues(alpha: 0.95);
    final lower = Paint()..color = leaf.withValues(alpha: 0.8);
    for (final dx in [-s * 1.25, 0.0, s * 1.25]) {
      canvas.drawPath(petal(dx, s * 0.3), top);
    }
    for (final dx in [-s * 0.62, s * 0.62]) {
      canvas.drawPath(petal(dx, s * 1.0), lower);
    }
    canvas.drawCircle(
      Offset(center.dx, center.dy - s * 0.35),
      s * 0.22,
      Paint()..color = dot,
    );
  }

  @override
  bool shouldRepaint(_MihrabReaderFramePainter old) =>
      old.cap != cap ||
      old.frame != frame ||
      old.fill != fill ||
      old.band != band ||
      old.outline != outline ||
      old.keyline != keyline ||
      old.chevron != chevron ||
      old.leaf != leaf ||
      old.dot != dot ||
      old.shadow != shadow;
}

/// The transient controls, gathered into one limestone pill: the jump-to button,
/// the theme dots, the zoom group, and the diagnostic overlay toggles. No panel
/// over the page interior — an edge band only.
/// The "I've memorized this page" reader control — page-granular sabaq intake
/// (E21-T07; PRD §12.3). It records the **current** page as newly memorized so it
/// enters the revision schedule, then confirms calmly. Always available (recording
/// what you memorized is user-initiated — never gated on the sabaq *pace*, which
/// only governs the Today prompt). It mutates no glyph and re-typesets nothing —
/// the write is the intake controller's single write path. No gamification of
/// any kind; an already-in-revision page is a calm note, never a failure.
class _MemorizedPageControl extends ConsumerWidget {
  const _MemorizedPageControl({required this.entryPage});

  final int entryPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    // The *current* page (the pager may have moved from the entry page).
    final pageNumber = ref.watch(
      mushafReaderStateProvider(entryPage).select((s) => s.pageNumber),
    );
    return OutlinedButton.icon(
      onPressed: () => _mark(context, ref, pageNumber),
      icon: const Icon(Icons.bookmark_add_outlined),
      label: Text(l10n.mushafMemorizedThisPage),
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary),
        shape: const StadiumBorder(),
      ),
    );
  }

  Future<void> _mark(BuildContext context, WidgetRef ref, int page) async {
    // Capture context-derived objects before the async gap.
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result =
        await ref.read(sabaqIntakeControllerProvider).startMemorizing(page);
    final note = switch (result) {
      SabaqIntakeResult.started => l10n.sabaqStartedNote,
      SabaqIntakeResult.alreadyStarted => l10n.sabaqAlreadyInRevision,
      SabaqIntakeResult.failed => l10n.sabaqIntakeFailedNote,
      SabaqIntakeResult.noProfile => null,
    };
    if (note != null) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(note)));
    }
  }
}

class _ControlsBand extends StatelessWidget {
  const _ControlsBand({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    return Padding(
      padding: EdgeInsetsDirectional.all(space.space3),
      child: Align(
        alignment: AlignmentDirectional.center,
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: space.space3,
            vertical: space.space2,
          ),
          decoration: ShapeDecoration(
            color: scheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(space.space5),
              side: BorderSide(color: scheme.outlineVariant),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: space.space2,
            runSpacing: space.space1,
            children: [
              OutlinedButton.icon(
                onPressed: () => showMushafJumpPicker(context, entryPage: page),
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(l10n.mushafJumpTitle),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.primary,
                  side: BorderSide(color: scheme.primary),
                  shape: const StadiumBorder(),
                ),
              ),
              _MemorizedPageControl(entryPage: page),
              ReaderThemeControl(entryPage: page),
              ReaderZoomControl(entryPage: page),
              ReaderOverlayToggles(entryPage: page),
            ],
          ),
        ),
      ),
    );
  }
}
