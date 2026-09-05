// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition;

import '../../design_system/theme/motion_tokens.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../../today/today_providers.dart' show pageJuzProvider;
import '../mushaf_providers.dart';
import 'jump_picker.dart';
import 'mushaf_about.dart';
import 'mushaf_pager.dart';
import 'reader_theme_control.dart';
import 'reader_zoom_control.dart';

/// The chrome around the immutable muṣḥaf page (plain redesign, 2026-09-05):
/// a thin top bar (the juz on the start edge; jump-to, reading controls and
/// the About/credits entry as icon buttons), the full-bleed page, and a small
/// page-number pill at the foot — the shape every muṣḥaf app shares. The
/// riwāyah is named in the About sheet and in Settings › Muṣḥaf (stated
/// explicitly in-app, R2), not printed over every page. The reading controls
/// (zoom, theme) are a transient band toggled by a page tap or the tune
/// button, auto-hiding after a calm dwell.
///
/// The chrome never touches the glyph layer: no frame, no overlay, no decoration
/// on or over an āyah (R1).
class MushafChrome extends StatefulWidget {
  /// Creates the chrome over the reader opened at [page] for [edition].
  const MushafChrome({required this.edition, required this.page, super.key});

  /// The active edition the About sheet names.
  final MushafEdition edition;

  /// The reader's entry page (the reader-state store family key the pager and
  /// the controls bind to).
  final int page;

  @override
  State<MushafChrome> createState() => _MushafChromeState();
}

class _MushafChromeState extends State<MushafChrome> {
  bool _controlsVisible = false;
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final motion = theme.extension<MotionTokens>()!;
    // Reduce-motion (or the platform animation toggle) snaps without a fade.
    final fade = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : motion.durationShort;

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: space.space2),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.only(start: space.space3),
                  child: _JuzLabel(page: widget.page),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      showMushafJumpPicker(context, entryPage: widget.page),
                  tooltip: l10n.mushafJumpTitle,
                  icon: const Icon(Icons.menu_book_outlined),
                ),
                IconButton(
                  onPressed: _toggleControls,
                  tooltip: l10n.mushafZoomIn,
                  isSelected: _controlsVisible,
                  icon: const Icon(Icons.tune),
                ),
                IconButton(
                  onPressed: () =>
                      showMushafAbout(context, edition: widget.edition),
                  tooltip: l10n.mushafAboutTitle,
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
          ),
        ),
        // The page — the base tap layer (a tap toggles the controls). It
        // carries the localized "page N" Semantics so the screen reader names
        // the current page (it can never read the glyph layer, R1).
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleControls,
            child: Consumer(
              builder: (context, ref, child) {
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
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: space.space2,
                ),
                child: MushafPager(entryPage: widget.page),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Column(
            children: [
              // The transient reading controls, fading calmly in/out. Hidden,
              // they ignore pointers so a page tap reaches the base layer.
              AnimatedOpacity(
                key: const ValueKey<String>('reader.controls'),
                opacity: _controlsVisible ? 1 : 0,
                duration: fade,
                curve: motion.curveStandard,
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: _controlsVisible
                      ? _ControlsBand(page: widget.page)
                      : const SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  vertical: space.space2,
                ),
                child: _PagePill(page: widget.page),
              ),
            ],
          ),
        ),
      ],
    )._on(scheme.surface);
  }
}

extension on Widget {
  /// Paints the reader ground behind the chrome (the page slot paints its own
  /// reader-theme paper over it).
  Widget _on(Color color) => ColoredBox(color: color, child: this);
}

/// The juz of the page being read, on the start edge of the top bar.
class _JuzLabel extends ConsumerWidget {
  const _JuzLabel({required this.page});

  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final pageNumber = ref.watch(
      mushafReaderStateProvider(page).select((state) => state.pageNumber),
    );
    final juz = ref.watch(pageJuzProvider).asData?.value[pageNumber];
    if (juz == null) return const SizedBox.shrink();
    return Text(
      l10n.juzLabel(isolateLtr(localeDigits(juz, locale))),
      style: theme.textTheme.labelLarge
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

/// The page-number pill at the foot: the current page in locale numerals.
class _PagePill extends ConsumerWidget {
  const _PagePill({required this.page});

  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final pageNumber = ref.watch(
      mushafReaderStateProvider(page).select((state) => state.pageNumber),
    );
    return ExcludeSemantics(
      // The page Semantics label on the stage already names the page.
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: scheme.surfaceContainer,
          shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: space.space4,
            vertical: space.space1,
          ),
          child: Text(
            isolateLtr(localeDigits(pageNumber, locale)),
            style: theme.textTheme.labelLarge
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _ControlsBand extends StatelessWidget {
  const _ControlsBand({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: space.space4),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: scheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(space.space4),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: space.space3,
            vertical: space.space2,
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: space.space3,
            runSpacing: space.space1,
            children: [
              ReaderZoomControl(entryPage: page),
              ReaderThemeControl(entryPage: page),
            ],
          ),
        ),
      ),
    );
  }
}
