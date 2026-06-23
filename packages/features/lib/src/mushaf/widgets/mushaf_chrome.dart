// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition;

import '../../design_system/theme/motion_tokens.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../mushaf_providers.dart';
import 'jump_picker.dart';
import 'mushaf_pager.dart';
import 'reader_overlay_toggles.dart';
import 'reader_theme_control.dart';
import 'reader_zoom_control.dart';
import 'riwayah_chrome_label.dart';

/// The "no dashboard" reader surface (design-system 13 §3): the words of the
/// muṣḥaf dominate and the controls recede to thin edge bands over E13-T03's
/// pager. The riwāyah/edition label is **always** present (R2 — the named
/// edition is on screen at every moment); the transient controls (theme, zoom,
/// jump-to, overlay toggles) auto-hide on a calm timer and a tap on the page,
/// and return on a tap, via a single `motion.durationShort` fade — never a
/// celebration, slide-up dashboard, glow, badge, counter, page-flip fanfare, or
/// piety/wuḍūʾ gate. It draws **nothing** decorative over the glyph layer.
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

    return Stack(
      children: [
        // The page is the base, fill layer — a tap on it toggles the controls.
        // It carries the localized "page N" Semantics so the screen reader names
        // the current page (it can never read the glyph layer itself, R1).
        Positioned.fill(
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
              child: MushafPager(entryPage: widget.page),
            ),
          ),
        ),
        // Top edge band: the always-present riwāyah/edition label (R2). It may
        // dim with the controls but never disappears — outside the fade below.
        PositionedDirectional(
          top: 0,
          start: 0,
          end: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsetsDirectional.all(space.space2),
              child: Align(
                alignment: AlignmentDirectional.center,
                child: RiwayahChromeLabel(edition: widget.edition),
              ),
            ),
          ),
        ),
        // Bottom edge band: the transient controls, fading calmly in/out. When
        // hidden they ignore pointers so the page tap reaches the base layer.
        PositionedDirectional(
          bottom: 0,
          start: 0,
          end: 0,
          child: SafeArea(
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
        ),
      ],
    );
  }
}

/// The thin bottom band of transient reader controls (theme · zoom · overlays ·
/// jump-to). No panel over the page interior — an edge band only.
class _ControlsBand extends StatelessWidget {
  const _ControlsBand({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Padding(
      padding: EdgeInsetsDirectional.all(space.space2),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: space.space2,
        runSpacing: space.space2,
        children: [
          ReaderThemeControl(entryPage: page),
          ReaderZoomControl(entryPage: page),
          ReaderOverlayToggles(entryPage: page),
          IconButton(
            onPressed: () => showMushafJumpPicker(context, entryPage: page),
            tooltip: l10n.mushafJumpTitle,
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
    );
  }
}
