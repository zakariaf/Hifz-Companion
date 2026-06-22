// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:l10n/l10n.dart';

/// The localized evidence-certainty phrases, injected into the pure
/// `certaintyLabel` mapping so it stays free of `BuildContext`/I/O and is
/// testable across fa/ckb/ar with plain fixtures.
///
/// `[RCT]` and `[EXP]` deliberately share one phrase ("a single controlled
/// study", science 11 §5). [semanticPrefix] is read before the phrase so the
/// grade is conveyed as text, never colour.
@immutable
class CertaintyStrings {
  /// Creates the phrase set (all already localized).
  const CertaintyStrings({
    required this.ma,
    required this.rctExp,
    required this.cs,
    required this.obs,
    required this.text,
    required this.trad,
    required this.semanticPrefix,
  });

  /// Builds the set from [AppLocalizations] at the call site.
  factory CertaintyStrings.of(AppLocalizations l10n) => CertaintyStrings(
        ma: l10n.certaintyMaPhrase,
        rctExp: l10n.certaintyRctExpPhrase,
        cs: l10n.certaintyCsPhrase,
        obs: l10n.certaintyObsPhrase,
        text: l10n.certaintyTextPhrase,
        trad: l10n.certaintyTradPhrase,
        semanticPrefix: l10n.certaintyEvidencePrefix,
      );

  /// "among the best-established findings in memory science" ([MA]).
  final String ma;

  /// "a single controlled study" (shared by [RCT] and [EXP]).
  final String rctExp;

  /// "a classic foundational study" ([CS]).
  final String cs;

  /// "an observational / field study" ([OBS]).
  final String obs;

  /// "an expert review / algorithm documentation" ([TEXT]).
  final String text;

  /// "traditional scholarship, named below" ([TRAD]).
  final String trad;

  /// The screen-reader prefix read before the phrase ("strength of evidence:").
  final String semanticPrefix;
}
