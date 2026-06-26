// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:l10n/l10n.dart';

import 'claim_row.dart';

/// Resolves a registered claim id to its transcreated, plain-language **headline**
/// (the face of the source row, in the ḥāfiẓ's frame). The wording lives in the
/// ARB bundle (fa/ckb/ar); this switch is the gen_l10n-friendly bridge from a
/// data-driven `C-NNN` id to its named getter.
///
/// An id with no headline is a release-blocking defect (a rendered claim with no
/// copy), so the default throws rather than rendering a blank — the no-orphan
/// test asserts every register id resolves here.
String scienceHeadline(AppLocalizations l10n, String claimId) =>
    switch (claimId) {
      'C-001' => l10n.scienceClaimC001Headline,
      'C-002' => l10n.scienceClaimC002Headline,
      'C-003' => l10n.scienceClaimC003Headline,
      'C-004' => l10n.scienceClaimC004Headline,
      'C-005' => l10n.scienceClaimC005Headline,
      'C-006' => l10n.scienceClaimC006Headline,
      'C-007' => l10n.scienceClaimC007Headline,
      'C-008' => l10n.scienceClaimC008Headline,
      'C-009' => l10n.scienceClaimC009Headline,
      'C-010' => l10n.scienceClaimC010Headline,
      'C-011' => l10n.scienceClaimC011Headline,
      'C-012' => l10n.scienceClaimC012Headline,
      'C-013' => l10n.scienceClaimC013Headline,
      'C-014' => l10n.scienceClaimC014Headline,
      'C-016' => l10n.scienceClaimC016Headline,
      'C-017' => l10n.scienceClaimC017Headline,
      'C-018' => l10n.scienceClaimC018Headline,
      'C-019' => l10n.scienceClaimC019Headline,
      'C-020' => l10n.scienceClaimC020Headline,
      'C-021' => l10n.scienceClaimC021Headline,
      'C-022' => l10n.scienceClaimC022Headline,
      'C-023' => l10n.scienceClaimC023Headline,
      'C-024' => l10n.scienceClaimC024Headline,
      'C-025' => l10n.scienceClaimC025Headline,
      'C-026' => l10n.scienceClaimC026Headline,
      'C-027' => l10n.scienceClaimC027Headline,
      'C-028' => l10n.scienceClaimC028Headline,
      'C-029' => l10n.scienceClaimC029Headline,
      'C-030' => l10n.scienceClaimC030Headline,
      'C-031' => l10n.scienceClaimC031Headline,
      'C-032' => l10n.scienceClaimC032Headline,
      'C-033' => l10n.scienceClaimC033Headline,
      'C-034' => l10n.scienceClaimC034Headline,
      'C-035' => l10n.scienceClaimC035Headline,
      'C-036' => l10n.scienceClaimC036Headline,
      'C-037' => l10n.scienceClaimC037Headline,
      'C-038' => l10n.scienceClaimC038Headline,
      'C-039' => l10n.scienceClaimC039Headline,
      'C-040' => l10n.scienceClaimC040Headline,
      'C-041' => l10n.scienceClaimC041Headline,
      'C-042' => l10n.scienceClaimC042Headline,
      'C-043' => l10n.scienceClaimC043Headline,
      'C-044' => l10n.scienceClaimC044Headline,
      'C-045' => l10n.scienceClaimC045Headline,
      'C-046' => l10n.scienceClaimC046Headline,
      'C-047' => l10n.scienceClaimC047Headline,
      'C-048' => l10n.scienceClaimC048Headline,
      _ => throw StateError('no science headline for claim "$claimId"'),
    };

/// Resolves a registered claim id to its optional honest **caveat** ("the app
/// uses X; the research shows X–Y" / "this guarantee is structural, not a
/// number"), or `null` when the row carries none. Surfaced in the evidence
/// expansion (science doc §4, §5).
String? scienceCaveat(AppLocalizations l10n, String claimId) =>
    switch (claimId) {
      'C-004' => l10n.scienceClaimC004Caveat,
      'C-010' => l10n.scienceClaimC010Caveat,
      'C-016' => l10n.scienceClaimC016Caveat,
      'C-017' => l10n.scienceClaimC017Caveat,
      'C-025' => l10n.scienceClaimC025Caveat,
      'C-047' => l10n.scienceClaimC047Caveat,
      _ => null,
    };

/// The localized theme-group header for a [ClaimGroup] (A–J).
String scienceGroupLabel(AppLocalizations l10n, ClaimGroup group) =>
    switch (group) {
      ClaimGroup.a => l10n.scienceGroupA,
      ClaimGroup.b => l10n.scienceGroupB,
      ClaimGroup.c => l10n.scienceGroupC,
      ClaimGroup.d => l10n.scienceGroupD,
      ClaimGroup.e => l10n.scienceGroupE,
      ClaimGroup.f => l10n.scienceGroupF,
      ClaimGroup.g => l10n.scienceGroupG,
      ClaimGroup.h => l10n.scienceGroupH,
      ClaimGroup.i => l10n.scienceGroupI,
      ClaimGroup.j => l10n.scienceGroupJ,
    };
