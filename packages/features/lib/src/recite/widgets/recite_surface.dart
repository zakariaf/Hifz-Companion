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

// Deterministic ragged widths for the masked "hidden text" bars — a fixed cycle
// (never randomness), so the reveal surface reads as lines of covered script and
// the goldens stay stable.
const List<double> _maskWidthFactors = <double>[
  0.94, 0.80, 0.88, 0.62, 0.90, 0.72, 0.84, 0.66,
];

/// The reveal-on-tap surface (07-components §5; PRD R1, §8.1): the page is masked
/// first so the ḥāfiẓ recites from memory; tapping the next line reveals it (never
/// a teleprompter); tapping a revealed line marks a stumble. The immutable glyph
/// layer is composed from the injected [ReciteReaderSurface] — this widget masks
/// and overlays it, never re-typesets it. Each line's hit-area is grown to the
/// ≥48 dp touch floor; a stumble draws a calm coordinate overlay on top of the
/// line (never a re-layout), and the muṣḥaf is never mirrored.
///
/// The masked lines sit in a warm limestone card; while nothing is revealed a
/// calm central "reveal on tap" affordance (a teal-ringed touch glyph) floats
/// over them as guidance — decorative and non-interactive (the live control is
/// the masked line itself), so it neither steals the tap nor double-reads.
class ReciteSurface extends ConsumerWidget {
  /// Creates the surface for [pageId].
  const ReciteSurface({required this.pageId, super.key});

  /// The muṣḥaf page being recited.
  final int pageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final space = theme.extension<SpacingTokens>()!;
    final colors = theme.extension<MihrabColors>()!;
    final reader = ref.watch(reciteReaderSurfaceProvider);
    final state = ref.watch(reciteControllerProvider(pageId));
    final controller = ref.read(reciteControllerProvider(pageId).notifier);
    final lineCount = reader.lineCount(pageId);

    // A masked line: a calm start-aligned rounded bar (a fraction of the width),
    // vertically centred in the ≥48 dp row — reads as a covered line of script.
    Widget maskBar(int index) => FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: _maskWidthFactors[index % _maskWidthFactors.length],
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(space.space1),
            ),
            child: SizedBox(height: space.space4),
          ),
        );

    final list = ListView.separated(
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
              key: const ValueKey<String>('recite.revealNext'),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                controller.revealNextLine();
                HapticFeedback.selectionClick();
              },
              child: SizedBox(height: space.space8, child: maskBar(i)),
            ),
          );
        }
        return SizedBox(height: space.space8, child: maskBar(i));
      },
    );

    return Padding(
      padding: EdgeInsetsDirectional.all(space.space4),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: scheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(space.space5),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: space.space4),
              child: list,
            ),
            if (state.revealedLineCount == 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsetsDirectional.all(space.space3),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: scheme.primary),
                            ),
                            child: Icon(
                              Icons.touch_app_outlined,
                              size: space.space6,
                              color: scheme.primary,
                            ),
                          ),
                          SizedBox(height: space.space3),
                          Text(
                            l10n.reciteRevealHint,
                            textAlign: TextAlign.center,
                            style: text.titleMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
