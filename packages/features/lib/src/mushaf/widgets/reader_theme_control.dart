// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../mushaf_providers.dart';
import '../reader_theme.dart';

/// The reader's light/sepia/dark theme control — three tappable paper-preview
/// **dots**, one per [ReaderTheme] value (the design system's *Night* appearance
/// is out of this control's contract). Each dot previews that appearance's paper
/// (limestone / warm sepia / dim night); the selected dot is marked by a teal
/// ring **and** a check glyph **and** its heavier localized label — never colour
/// alone (WCAG 2.2 SC 1.4.1) — so both sighted and screen-reader users can tell
/// which surface is active.
///
/// It writes only the E13-T02 reader-state `theme`; the value selects E05's
/// single `ColorFilter` over the whole rendered layer — **no per-theme font
/// swap, no "dark font"** (one font per page). A display transform: it mutates
/// no card, writes no review, makes no sleep claim, and adds no "recommended"
/// framing or celebration on the change.
class ReaderThemeControl extends ConsumerWidget {
  /// Creates the theme control bound to the reader opened at [entryPage].
  const ReaderThemeControl({required this.entryPage, super.key});

  /// The reader-state store family key whose `theme` this control selects.
  final int entryPage;

  String _label(AppLocalizations l10n, ReaderTheme theme) => switch (theme) {
        ReaderTheme.light => l10n.mushafThemeLight,
        ReaderTheme.sepia => l10n.mushafThemeSepia,
        ReaderTheme.dark => l10n.mushafThemeDark,
      };

  // The paper each appearance would render on — a faithful preview, read from
  // the scheme / Mihrab tokens (never a raw hex).
  Color _paper(ColorScheme scheme, MihrabColors mihrab, ReaderTheme theme) =>
      switch (theme) {
        ReaderTheme.light => scheme.surface,
        ReaderTheme.sepia => mihrab.readerSurfaceSepia,
        ReaderTheme.dark => scheme.inverseSurface,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = ref.watch(
      mushafReaderStateProvider(entryPage).select((state) => state.theme),
    );
    final notifier = ref.read(mushafReaderStateProvider(entryPage).notifier);
    final scheme = Theme.of(context).colorScheme;
    final mihrab = Theme.of(context).extension<MihrabColors>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in ReaderTheme.values)
          _ThemeSwatch(
            label: _label(l10n, value),
            paper: _paper(scheme, mihrab, value),
            // Shape (ring + check) AND text — never colour alone.
            selected: value == theme,
            onTap: () => notifier.setTheme(value),
          ),
      ],
    );
  }
}

/// One theme option: a paper-preview dot over its localized name, the whole
/// column a single ≥48dp labelled tap target (the nav-bar semantics idiom — one
/// merged button node, the visual excluded so it is not read twice).
class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.label,
    required this.paper,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color paper;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final mihrab = theme.extension<MihrabColors>()!;
    // The check glyph reads on whichever paper the dot previews.
    final onPaper = ThemeData.estimateBrightnessForColor(paper) == Brightness.dark
        ? scheme.surface
        : scheme.onSurface;
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ExcludeSemantics(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minWidth: space.space8, minHeight: space.space8),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: space.space1,
                  vertical: space.space1,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: space.space6,
                      height: space.space6,
                      alignment: AlignmentDirectional.center,
                      decoration: ShapeDecoration(
                        color: paper,
                        shape: CircleBorder(
                          side: BorderSide(
                            color:
                                selected ? scheme.primary : scheme.outlineVariant,
                          ),
                        ),
                      ),
                      child: selected
                          ? Icon(Icons.check, size: space.space4, color: onPaper)
                          : null,
                    ),
                    SizedBox(height: space.space1),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: selected ? scheme.primary : mihrab.textTertiary,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
