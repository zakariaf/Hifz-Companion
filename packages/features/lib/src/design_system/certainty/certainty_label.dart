// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';
import 'certainty_strings.dart';
import 'evidence_grade.dart';

/// The pure mapping from an [EvidenceGrade] to its lay confidence-*about-the-
/// evidence* phrase (science 11 §5) — no `BuildContext`, no I/O, no model.
///
/// Total over the sealed enum via an exhaustive `switch` (no `default`, so a new
/// grade is a compile error, not a silent fallthrough). `[RCT]` and `[EXP]` share
/// one phrase. It describes the **evidence**, never the user's Quran — no arm
/// says "safe"/"mastered"/"proven", a percentage, or a star.
String certaintyLabel(EvidenceGrade grade, CertaintyStrings strings) =>
    switch (grade) {
      EvidenceGrade.ma => strings.ma,
      EvidenceGrade.rct => strings.rctExp,
      EvidenceGrade.exp => strings.rctExp,
      EvidenceGrade.cs => strings.cs,
      EvidenceGrade.obs => strings.obs,
      EvidenceGrade.text => strings.text,
      EvidenceGrade.trad => strings.trad,
    };

/// A calm, neutral evidence-certainty badge (science 11 §5; voice §2).
///
/// **One neutral container for every grade** — color is never picked by grade,
/// never a traffic-light / warning / success fill; strength is carried by the
/// text phrase only (WCAG 1.4.1). Non-interactive (a read-only label, no tap, no
/// focus ring). The grade is read out as text via the `semanticPrefix` + phrase,
/// never inferred from colour. No star, no "proven", no percentage, no
/// retention/Quran promise.
class CertaintyLabel extends StatelessWidget {
  /// Creates a badge for [grade] using the injected [strings].
  const CertaintyLabel({required this.grade, required this.strings, super.key});

  /// The evidence grade to render.
  final EvidenceGrade grade;

  /// The localized phrase set.
  final CertaintyStrings strings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    final phrase = certaintyLabel(grade, strings);
    // Composed from localized parts (not a literal) so the grade is spoken as
    // text; the prefix + phrase both come from AppLocalizations.
    final semanticLabel = strings.semanticPrefix + phrase;
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: space.space3,
          vertical: space.space2,
        ),
        // The SAME neutral surface for all seven grades — never colour-as-signal.
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHighest,
          shape: StadiumBorder(
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: ExcludeSemantics(
          child: Text(
            phrase,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

/// The always-reachable plain-words evidence-certainty legend (science 11 §3,
/// §5) — a calm row per distinct phrase, never a "★★★★★" rating.
///
/// `[RCT]`/`[EXP]` share a row (one phrase). `[TRAD]` reads as named scholarship,
/// not visually elevated above the empirical rows and issuing no ruling. Reflows
/// (never truncates) at 200% text scale.
class CertaintyLegend extends StatelessWidget {
  /// Creates the legend from the injected [strings] and [title].
  const CertaintyLegend({
    required this.strings,
    required this.title,
    super.key,
  });

  /// The localized phrase set.
  final CertaintyStrings strings;

  /// The localized legend title.
  final String title;

  /// The grades shown, one per distinct phrase (exp shares rct's row).
  static const List<EvidenceGrade> rows = [
    EvidenceGrade.ma,
    EvidenceGrade.rct,
    EvidenceGrade.cs,
    EvidenceGrade.obs,
    EvidenceGrade.text,
    EvidenceGrade.trad,
  ];

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: text.titleMedium),
        SizedBox(height: space.space3),
        for (final grade in rows)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: space.space2),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: CertaintyLabel(grade: grade, strings: strings),
            ),
          ),
      ],
    );
  }
}
