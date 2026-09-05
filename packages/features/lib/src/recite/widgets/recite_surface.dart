// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';
import '../reader_surface.dart';
import '../recite_providers.dart';

// Deterministic ragged widths for the masked "hidden text" bars — a fixed cycle
// (never randomness), so the reveal surface reads as lines of covered script and
// the goldens stay stable.
const List<double> _maskWidthFactors = <double>[
  0.94,
  0.80,
  0.88,
  0.62,
  0.90,
  0.72,
  0.84,
  0.66,
];

/// The reveal-on-tap surface (07-components §5; PRD R1, §8.1): the page is
/// masked first so the ḥāfiẓ recites from memory; one tap on **Show page**
/// reveals the whole page after the attempt (never a teleprompter — the mask
/// never scrolls ahead of the reciter); tapping a revealed line marks a
/// stumble. The immutable glyph layer is composed from the injected
/// [ReciteReaderSurface] — this widget masks and overlays it, never re-typesets
/// it. Each line's hit-area is grown to the ≥48 dp touch floor; a stumble draws
/// a calm coordinate overlay on top of the line (never a re-layout), and the
/// muṣḥaf is never mirrored.
///
/// Plain redesign (2026-09-05): the whole-page reveal replaced the line-by-line
/// default (15 taps a page); [ReciteController.revealNextLine] remains for the
/// line-by-line option.
class ReciteSurface extends ConsumerWidget {
  /// Creates the surface for [pageId].
  const ReciteSurface({required this.pageId, super.key});

  /// The muṣḥaf page being recited.
  final int pageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final space = theme.extension<SpacingTokens>()!;
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

    Widget revealedLine(int i) {
      final lineNo = i + 1;
      final marked = state.stumbleLines.contains(lineNo);
      return Semantics(
        toggled: marked,
        label: l10n.reciteStumbleLineLabel(localeDigits(lineNo, locale)),
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
                // start-edge rule + tint (never red, never a re-layout).
                color: marked ? scheme.primaryContainer : null,
                borderRadius: BorderRadius.circular(space.space1),
                border: marked
                    ? BorderDirectional(
                        start: BorderSide(
                          color: scheme.primary,
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

    final list = ListView.separated(
      padding: EdgeInsetsDirectional.symmetric(vertical: space.space3),
      itemCount: lineCount,
      separatorBuilder: (_, __) => SizedBox(height: space.space1),
      itemBuilder: (context, i) => i < state.revealedLineCount
          ? revealedLine(i)
          : SizedBox(height: space.space8, child: maskBar(i)),
    );

    final footer = state.hasRevealed
        ? Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: space.space4,
              vertical: space.space3,
            ),
            child: Text(
              state.stumbleLines.isEmpty
                  ? l10n.sessionStumbleHint
                  : toLocaleNumerals(
                      l10n.sessionStumbleCount(state.stumbleLines.length),
                      locale,
                    ),
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          )
        : null;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: space.space4),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: scheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(space.space4),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: space.space3,
                    ),
                    child: list,
                  ),
                  if (!state.hasRevealed)
                    // The one-tap reveal, after the recall attempt. The
                    // button is the live control; the masked bars behind it
                    // are decoration.
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: EdgeInsetsDirectional.all(space.space5),
                          decoration: ShapeDecoration(
                            color: scheme.surfaceContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(space.space4),
                              side: BorderSide(color: scheme.outlineVariant),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: space.space3,
                            children: <Widget>[
                              Text(
                                l10n.sessionReciteFirst,
                                textAlign: TextAlign.center,
                                style: text.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              Semantics(
                                label: l10n.reciteRevealHint,
                                child: FilledButton(
                                  key: const ValueKey<String>(
                                    'recite.revealNext',
                                  ),
                                  onPressed: () {
                                    controller.revealAll();
                                    HapticFeedback.selectionClick();
                                  },
                                  child: Text(l10n.sessionShowPage),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (footer != null) ...[
              Divider(height: 1, color: scheme.outlineVariant),
              footer,
            ],
          ],
        ),
      ),
    );
  }
}
