// template.dart — ui-certainty-label
//
// Copy-paste scaffold for the evidence-certainty badge that translates a
// CLAIMS.md evidence grade into a calm, neutral lay confidence label on the
// "The science we follow" screen. Fill every // TODO.
//
// Governing docs (see references.md):
//   docs/science/11-the-in-app-science-screen.md §5 (confidence-of-evidence,
//     not certainty-about-the-user; never a star rating / "proven" / %),
//     §2 (offline/static/bundled), §3 (plain words, RTL), §4 (legend),
//     §7 (never color-only, >= 4.5:1)
//   docs/science/CLAIMS.md (the seven grades; [TRAD] issues no fiqh ruling)
//   docs/design-system/11-voice-and-tone.md §2 (Honest/Calm: neutral fill,
//     no warning colour), §8 (transcreation + bidi isolation)
//
// Rules baked into this scaffold:
//   - The badge takes a sealed EvidenceGrade enum, NEVER the raw "[MA]" tag.
//   - certaintyLabel() describes the STRENGTH OF THE EVIDENCE only — never the
//     user's Quran, never a retention %, never "safe".
//   - One neutral container for ALL grades (no traffic-light colour);
//     strength is carried by the text phrase, never colour alone.
//   - Label + legend are localized (ARB / gen_l10n), transcreated per fa/ckb/ar.

import 'package:flutter/material.dart';
// TODO: import the generated localizations: e.g.
// import 'package:hifz_l10n/hifz_l10n.dart'; // AppLocalizations
// TODO: import the design-system tokens (color.surface / color.text.secondary):
// import 'package:hifz_design_system/hifz_design_system.dart'; // HifzColors

/// The seven CLAIMS.md evidence grades, in best -> weakest order among the
/// empirical grades. Parsed ONCE from the bundled CLAIMS register; the UI never
/// handles the raw "[MA]"/"[TRAD]" bracket tag.
///
/// `MA > RCT/EXP > CS > OBS > TEXT`; `[TRAD]` names a traditional source and
/// issues no fiqh ruling. See `docs/science/CLAIMS.md` (Evidence grades legend).
enum EvidenceGrade {
  /// [MA] meta-analysis / systematic review.
  ma,

  /// [RCT] randomized experiment.
  rct,

  /// [EXP] controlled cognitive experiment.
  exp,

  /// [CS] classic foundational study.
  cs,

  /// [OBS] observational / applied / field study.
  obs,

  /// [TEXT] textbook / expert review / algorithm documentation.
  text,

  /// [TRAD] traditional / scholarly Islamic source (methodology, never a ruling).
  trad;

  /// Parses the register's bracket tag (e.g. `[MA]`, `MA`) into an enum.
  ///
  /// An unknown grade is a release-blocking DATA defect in the bundled register
  /// — there is no UI fallback to render. See `docs/science/CLAIMS.md`.
  static EvidenceGrade parse(String tag) {
    final key = tag.replaceAll(RegExp(r'[\[\]\s]'), '').toLowerCase();
    return EvidenceGrade.values.firstWhere(
      (g) => g.name == key,
      // TODO: throw a typed register-integrity error here (do NOT silently
      // default to a grade); this should fail CI / the science-screen build.
      orElse: () => throw StateError('Unregistered CLAIMS grade: "$tag"'),
    );
  }
}

/// Maps a grade to its plain lay phrase about the STRENGTH OF THE EVIDENCE.
///
/// PURE: no BuildContext, no I/O, no model. The phrase describes the evidence,
/// kept strictly separate from any certainty about the user's own Quran
/// (`docs/science/11-the-in-app-science-screen.md` §5).
///
/// Pass the localized strings in from the call site so this stays pure and
/// testable across fa/ckb/ar.
String certaintyLabel(EvidenceGrade grade, _CertaintyStrings s) {
  // TODO: confirm each phrase against §5 / the legend and transcreate per
  // locale (NOT a literal translation). Describe the EVIDENCE, never the user.
  return switch (grade) {
    EvidenceGrade.ma => s.bestEstablished, // "among the best-established findings"
    EvidenceGrade.rct => s.controlledStudy, // "a controlled study"
    EvidenceGrade.exp => s.controlledStudy, // "a controlled study"
    EvidenceGrade.cs => s.classicStudy, // "a classic foundational study"
    EvidenceGrade.obs => s.fieldStudy, // "an observational / field study"
    EvidenceGrade.text => s.expertReview, // "an expert review / algorithm docs"
    EvidenceGrade.trad => s.namedScholarship, // "named traditional scholarship"
  };
}

/// Localized phrase bundle for the badge + legend. Back this with gen_l10n
/// (ARB) and transcreate per fa/ckb/ar — see voice-and-tone §8.
class _CertaintyStrings {
  const _CertaintyStrings({
    required this.bestEstablished,
    required this.controlledStudy,
    required this.classicStudy,
    required this.fieldStudy,
    required this.expertReview,
    required this.namedScholarship,
    required this.semanticPrefix, // e.g. "Evidence: " for screen readers
  });

  final String bestEstablished;
  final String controlledStudy;
  final String classicStudy;
  final String fieldStudy;
  final String expertReview;
  final String namedScholarship;
  final String semanticPrefix;

  // TODO: build from AppLocalizations.of(context) at the call site, e.g.
  // factory _CertaintyStrings.of(AppLocalizations l10n) => _CertaintyStrings(
  //   bestEstablished: l10n.certaintyBestEstablished, ...);
}

/// The certainty badge: ONE neutral container for every grade.
///
/// Neutral styling is mandatory — a weaker grade is NOT red and a stronger
/// grade is NOT green (`docs/design-system/11-voice-and-tone.md` §2 "Honest";
/// `docs/science/11-the-in-app-science-screen.md` §7 "never color-only").
/// No star rating, no "proven", no percentage (§5 anti-patterns).
class CertaintyLabel extends StatelessWidget {
  const CertaintyLabel({
    super.key,
    required this.grade,
    required this.strings,
  });

  final EvidenceGrade grade;
  final _CertaintyStrings strings;

  @override
  Widget build(BuildContext context) {
    final phrase = certaintyLabel(grade, strings);

    // TODO: read the calm neutral tokens from the design system — DO NOT
    // hard-code hex and DO NOT pick colour by grade.
    //   final surface = HifzColors.of(context).surface;        // color.surface
    //   final onSurface = HifzColors.of(context).textSecondary; // color.text.secondary
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;
    final onSurface = Theme.of(context).colorScheme.onSurfaceVariant;

    return Directionality(
      // The whole science screen is RTL-native for fa/ckb/ar; inherit it from
      // the active locale rather than forcing a direction here.
      textDirection: Directionality.of(context),
      child: Semantics(
        // Strength is read out as text, never inferred from colour.
        label: '${strings.semanticPrefix}$phrase',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: surface, // SAME neutral fill for all seven grades.
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            // Plain phrase is the primary text. If you also show the literal
            // grade name ("meta-analysis"), it is a glossed SECONDARY detail —
            // never the raw "[MA]" tag, never unglossed jargon (§3).
            phrase,
            // TODO: use the type token, e.g. style: HifzType.caption(context).
            style: TextStyle(color: onSurface), // ensure >= 4.5:1 (WCAG 1.4.3)
          ),
        ),
      ),
    );
  }
}

/// The always-reachable, plain-words grade legend.
///
/// Explains the grades calmly ("a meta-analysis pools many studies; an
/// experiment is a single controlled test; a traditional source is named
/// scholarship") — never a marketing "★★★★★" key
/// (`docs/science/11-the-in-app-science-screen.md` §4).
class CertaintyLegend extends StatelessWidget {
  const CertaintyLegend({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: render one calm row per grade — a CertaintyLabel beside its
    // localized plain-words explanation — sourced from ARB, transcreated per
    // fa/ckb/ar, with any Latin source name bidi-isolated (FSI/PDI).
    return const Placeholder();
  }
}
