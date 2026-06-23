// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../reader_surface.dart';
import '../recite_providers.dart';

/// The reveal-on-tap surface (07-components §5; PRD R1, §8.1): the page is masked
/// first so the ḥāfiẓ recites from memory; tapping the next line reveals it (never
/// a teleprompter); tapping a revealed line marks a stumble. The immutable glyph
/// layer is composed from the injected [ReciteReaderSurface] — this widget masks
/// and overlays it, never re-typesets it. Each line's hit-area is grown to the
/// ≥48 dp touch floor; a stumble draws a calm coordinate overlay on top of the
/// line (never a re-layout), and the muṣḥaf is never mirrored.
class ReciteSurface extends ConsumerWidget {
  /// Creates the surface for [pageId].
  const ReciteSurface({required this.pageId, super.key});

  /// The muṣḥaf page being recited.
  final int pageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final colors = theme.extension<MihrabColors>()!;
    final reader = ref.watch(reciteReaderSurfaceProvider);
    final state = ref.watch(reciteControllerProvider(pageId));
    final controller = ref.read(reciteControllerProvider(pageId).notifier);
    final lineCount = reader.lineCount(pageId);

    Widget maskBox() => DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(space.space1),
          ),
        );

    return ListView.separated(
      padding: EdgeInsetsDirectional.symmetric(vertical: space.space4),
      itemCount: lineCount,
      separatorBuilder: (_, __) => SizedBox(height: space.space2),
      itemBuilder: (context, i) {
        final lineNo = i + 1;
        if (i < state.revealedLineCount) {
          final marked = state.stumbleLines.contains(lineNo);
          return Semantics(
            toggled: marked,
            label: l10n.reciteStumbleLineLabel(
              localeDigits(lineNo, Localizations.localeOf(context)),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                controller.toggleStumbleLine(lineNo);
                HapticFeedback.selectionClick();
              },
              child: SizedBox(
                height: space.space8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    // A calm coordinate overlay on the marked line — a quiet
                    // start-edge rule (never red, never a re-layout).
                    border: marked
                        ? BorderDirectional(
                            start: BorderSide(
                              color: colors.accentGold,
                              width: space.space1,
                            ),
                          )
                        : null,
                  ),
                  child: Center(child: reader.buildLine(context, pageId, i)),
                ),
              ),
            ),
          );
        }
        if (i == state.revealedLineCount) {
          // The next line to reveal — tapping the mask reveals it (post-attempt).
          return Semantics(
            button: true,
            label: l10n.reciteRevealHint,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                controller.revealNextLine();
                HapticFeedback.selectionClick();
              },
              child: SizedBox(height: space.space8, child: maskBox()),
            ),
          );
        }
        return SizedBox(height: space.space8, child: maskBox());
      },
    );
  }
}
