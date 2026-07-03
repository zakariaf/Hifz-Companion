// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/certainty/certainty_label.dart';
import '../../design_system/certainty/certainty_strings.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../claim_row.dart';
import '../science_copy.dart';

/// One registered claim as a calm source card on "The science we follow" — a
/// limestone tile with a glazed-teal keyline along its logical start edge.
///
/// It shows, in the ḥāfiẓ's frame: the plain headline; the grade as honest
/// confidence words (the E10 [CertaintyLabel], never a star/percentage/colour);
/// the named, dated source(s); the honest caveat; and the "needs scholarly
/// review" note for a pending `[TRAD]` row (science doc §3–§5, §8). It authors
/// nothing — every word is the registered `C-NNN` row or its transcreated copy
/// (science doc §1).
///
/// Calm and offline: no streak, badge, count, or celebration. A source URL is an
/// optional convenience routed through [onOpenSource]; the citation is full
/// on-device text, so the card reads identically with no connection.
class ScienceSourceRow extends StatelessWidget {
  /// Creates a source row for [claim]. [onOpenSource] opens a citation URL in the
  /// system browser (the injected `SourceLinkLauncher` at the screen layer).
  const ScienceSourceRow({
    super.key,
    required this.claim,
    required this.onOpenSource,
    this.initiallyExpanded = false,
  });

  /// The registered claim this row renders — the only author of the claim.
  final ClaimRow claim;

  /// Opens a citation's external URL (system browser); never an in-app fetch.
  final void Function(String url) onOpenSource;

  /// Retained for drop-in API compatibility (the card now shows the evidence
  /// inline, so there is no collapsed state to expand); accepted and ignored.
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final strings = CertaintyStrings.of(l10n);

    final headline = scienceHeadline(l10n, claim.id);
    final caveat = scienceCaveat(l10n, claim.id);

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: space.space4,
        vertical: space.space2,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(space.space5)),
        child: ColoredBox(
          color: scheme.surfaceContainer,
          child: Stack(
            children: [
              // The content sizes the card; its start inset clears the keyline.
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  space.space5,
                  space.space4,
                  space.space4,
                  space.space4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The FACE: a plain headline — common words, the user's frame.
                    Text(headline, style: theme.textTheme.titleMedium),
                    SizedBox(height: space.space3),
                    // The grade(s) as honest confidence language + a non-colour
                    // glyph — never a star, percentage, or colour-only signal.
                    Wrap(
                      spacing: space.space2,
                      runSpacing: space.space2,
                      children: [
                        for (final grade in claim.grades)
                          CertaintyLabel(grade: grade, strings: strings),
                      ],
                    ),
                    SizedBox(height: space.space3),
                    // The named, dated source(s) — full on-device text; a tap is
                    // only an optional convenience that leaves the app.
                    for (final source in claim.sources)
                      _SourceLine(
                        citation:
                            isolate(toLocaleNumerals(source.label, locale)),
                        url: source.url,
                        opensInBrowser: l10n.scienceOpensInBrowser,
                        minTarget: space.space8,
                        gap: space.space2,
                        onOpen: onOpenSource,
                      ),
                    if (claim.needsScholarlyReview)
                      _NeedsReviewNote(
                        label: l10n.scienceNeedsReview,
                        gap: space.space2,
                      ),
                    if (caveat != null) ...[
                      SizedBox(height: space.space2),
                      Text(
                        caveat,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              // The teal tile keyline along the logical start (right under RTL).
              PositionedDirectional(
                top: 0,
                bottom: 0,
                start: 0,
                width: space.space1,
                child: ColoredBox(color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One source citation line: the named, dated reference as on-device text, with
/// an optional tap that **leaves the app** for the system browser. Offline / no
/// URL, it is plain text — the citation never depends on the network (science
/// doc §2, §4). The whole line is a ≥48dp link target announced as one phrase.
class _SourceLine extends StatelessWidget {
  const _SourceLine({
    required this.citation,
    required this.url,
    required this.opensInBrowser,
    required this.minTarget,
    required this.gap,
    required this.onOpen,
  });

  final String citation;
  final String? url;
  final String opensInBrowser;
  final double minTarget;
  final double gap;
  final void Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = Text(
      citation,
      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
    );

    if (url == null) {
      // No link: the reference stands alone — trustworthy with no connection.
      return Padding(
        padding: EdgeInsetsDirectional.only(bottom: gap),
        child: text,
      );
    }

    // With a URL: the whole line is one ≥48dp link that visibly leaves the app
    // (the external glyph at the logical end + the "opens in your browser" hint),
    // merged into one screen-reader node — the citation read naturally, the glyph
    // carrying the localized "opens in your browser" label, the link trait added.
    return MergeSemantics(
      child: Semantics(
        link: true,
        child: InkWell(
          onTap: () => onOpen(url!),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minTarget),
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: gap),
              child: Row(
                children: [
                  Expanded(child: text),
                  SizedBox(width: gap),
                  Icon(
                    Icons.open_in_new,
                    size: theme.textTheme.bodyMedium?.fontSize,
                    color: scheme.onSurfaceVariant,
                    semanticLabel: opensInBrowser,
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

/// The calm "needs scholarly review" note for a `[TRAD]`/methodology row whose
/// named-scholar sign-off is pending (science doc §8; PRD §21). Methodology
/// only — it issues no fiqh ruling, and is neutral, never a warning colour.
class _NeedsReviewNote extends StatelessWidget {
  const _NeedsReviewNote({required this.label, required this.gap});

  final String label;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.school_outlined,
          size: theme.textTheme.bodySmall?.fontSize,
          color: scheme.onSurfaceVariant,
        ),
        SizedBox(width: gap),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
