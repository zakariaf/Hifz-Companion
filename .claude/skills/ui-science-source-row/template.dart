// SCAFFOLD — this file bundles the pieces of the Hifz Companion science-screen source row.
// It is NOT a standalone Dart file: it contains two domain-blind leaf widgets, one
// feature-layer row, and a golden-test stub. Copy each labelled block into the right file
// under packages/, then fill every // TODO. Opening this file on its own shows unresolved
// symbols — that is expected; the real symbols (the registered ClaimRow value type,
// AppLocalizations, the design-system token layer, the url-launch service) resolve only
// inside the pub workspace.
//
// Three pieces, in two layers:
//   1. EvidenceGradeTag — shared ui/ leaf, DOMAIN-BLIND (takes a grade enum + localized label).
//   2. SourceCitation   — shared ui/ leaf, DOMAIN-BLIND (on-device author/year/venue text +
//                         optional external link), locale numerals + bidi isolation only.
//   3. ScienceSourceRow — features/ leaf, maps a registered claim -> the two-layer row + Semantics.
//
// Tokens are referenced BY NAME ONLY (color.* / type.* / type.numeral / space.* / touch.min).
// The design docs own the concrete values — never inline hex / pt / dp / ms here.
//
// Governing docs:
//   docs/science/11-the-in-app-science-screen.md
//     §1 (renders the register — a view, not an author), §3 (two-layer plain copy),
//     §4 (named/dated source + grade on the face; [TRAD] = collection+number),
//     §5 (grade = confidence language, NEVER a star/badge/%), §2 (bundled/offline; link
//     degrades gracefully), §7 (WCAG 2.2; grade never color-only; RTL + numerals + bidi),
//     §6 (calm, no engagement mechanics), §8 ([TRAD] = methodology, no ruling)
//   docs/design-system/10-privacy-and-trust-ux.md §3, §7 (link is the CHECK; external links
//     are bidi-isolated mixed Latin/RTL runs, >=48dp; verifiable, not rhetorical)
//   eng-rtl-and-bidi-layout (locale numerals via intl, FSI/PDI isolation of Latin author/venue/URL)
//
// Non-negotiables this scaffold encodes:
//   - The row AUTHORS NOTHING — it renders one verified CLAIMS.md entry (domain-claims-register-and-science-screen).
//   - The grade describes the EVIDENCE, never the user's Quran; NEVER a star rating / "proven" badge / %.
//   - The grade is conveyed by TEXT TAG + a non-color glyph — NEVER color alone (SC 1.4.1).
//   - A [TRAD] source shows collection + number + grading, framed as METHODOLOGY — NO fiqh ruling.
//   - The link CLEARLY leaves the app and is meaningless-but-harmless OFFLINE; NO in-app fetch, NO AI.
//   - Year/number in locale numerals; Latin author/venue/URL bidi-isolated (FSI/PDI).
//   - No "N of M read", no badge, no urgency, no decay-as-threat — calm explanation only.

import 'package:flutter/material.dart';

// ============================================================================
// BLOCK 1 — packages/ui/lib/src/evidence_grade_tag.dart  (shared ui/, DOMAIN-BLIND)
// The evidence-grade rendered as HONEST CONFIDENCE LANGUAGE + a non-color glyph.
// NEVER a star rating, "proven" badge, percentage, or color-only signal (11 §5, §7 / SC 1.4.1).
//
// NOTE: the grade -> lay confidence-phrase MAPPING and the standalone badge are owned by
// ui-certainty-label. This block is a thin presentation leaf the source row composes; if that
// sibling already ships a CertaintyLabel widget, render it here instead of duplicating the map.
// ============================================================================

/// The seven evidence grades from the science foundation's legend. The grade describes the
/// STRENGTH OF THE EVIDENCE behind a claim — kept strictly separate from any certainty about
/// the user's Quran (11 §5). Preference MA > RCT/EXP > CS > OBS > TEXT; TRAD names the source.
enum EvidenceGrade { ma, rct, exp, cs, obs, text, trad }

/// Domain-blind grade tag: a plain confidence LABEL + a non-color GLYPH + the short text tag.
/// The caller passes the already-localized [confidenceLabel] ("among the best-established
/// findings in memory science" / "a single controlled study" / "named traditional scholarship"
/// — transcreated per locale, domain-adab-and-religious-integrity) so this leaf imports no l10n.
class EvidenceGradeTag extends StatelessWidget {
  const EvidenceGradeTag({
    super.key,
    required this.grade,
    required this.confidenceLabel,
    required this.shortTag,
  });

  final EvidenceGrade grade;
  final String confidenceLabel; // localized confidence sentence, supplied by the feature layer
  final String shortTag; // localized short tag, e.g. "meta-analysis" / "traditional source"

  @override
  Widget build(BuildContext context) {
    // TODO: resolve the GLYPH (the color-independent channel) from the design-system layer.
    //   The glyph + the text carry the grade; color is at most reinforcement, NEVER the sole
    //   signal (11 §7 / SC 1.4.1). Do NOT map grade -> a hue ramp; do NOT render stars.
    final IconData glyph = switch (grade) {
      EvidenceGrade.ma => /* TODO strong-evidence glyph */ Icons.verified_outlined,
      EvidenceGrade.rct ||
      EvidenceGrade.exp =>
        /* TODO controlled-experiment glyph */ Icons.science_outlined,
      EvidenceGrade.cs => /* TODO classic-study glyph */ Icons.history_edu_outlined,
      EvidenceGrade.obs => /* TODO observational glyph */ Icons.insights_outlined,
      EvidenceGrade.text => /* TODO review/textbook glyph */ Icons.menu_book_outlined,
      EvidenceGrade.trad => /* TODO named-tradition glyph */ Icons.auto_stories_outlined,
    };

    // A label-only row: glyph + short tag. The full confidence sentence is rendered in the
    // "the evidence" expansion / Semantics by the feature layer (kept as a field so it routes
    // into both). This is NOT a star bar, badge, or percentage (11 §5 anti-patterns).
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(glyph, size: /* TODO from space.* scale */ 16),
          const SizedBox(width: /* TODO space.1 */ 4),
          Text(
            shortTag, // e.g. "meta-analysis" — the TEXT tag, never color alone
            style: /* TODO type.label token; NEVER Font.system(size:) */ null,
          ),
        ],
      ),
    );
    // [confidenceLabel] is surfaced in the expansion + merged Semantics by ScienceSourceRow.
  }
}

// ============================================================================
// BLOCK 2 — packages/ui/lib/src/source_citation.dart  (shared ui/, DOMAIN-BLIND)
// The named, dated source as READABLE ON-DEVICE TEXT (author/year/venue), plus an OPTIONAL
// external link that CLEARLY leaves the app and does nothing harmful offline (11 §2, §4;
// privacy-trust §3/§7). Year is locale numerals; Latin author/venue/URL is bidi-isolated.
// ============================================================================

/// Domain-blind citation block. The feature layer supplies the already-localized, already
/// bidi-isolated [citationText] (e.g. "Cepeda et al., 2006 — Psychological Bulletin") and an
/// OPTIONAL [externalUrl]. For a [TRAD] source the citationText carries the collection + number
/// + grading (e.g. "Ṣaḥīḥ al-Bukhārī 5032 — sound"); this leaf never formats domain text.
class SourceCitation extends StatelessWidget {
  const SourceCitation({
    super.key,
    required this.citationText,
    required this.externalLinkHint,
    this.externalUrl,
    this.onOpenExternal,
  });

  /// The full reference as on-device text. Already localized and bidi-isolated (FSI/PDI around
  /// the Latin author/venue run) by the feature layer (eng-rtl-and-bidi-layout). The year is
  /// rendered in locale numerals (intl NumberFormat + type.numeral) BEFORE it reaches here.
  final String citationText;

  /// Localized hint that the link leaves the app, e.g. "opens in your browser" (eng-add-localized-string).
  final String externalLinkHint;

  /// Optional convenience only — the citation is fully trustworthy WITHOUT it (11 §2).
  final String? externalUrl;

  /// Routed through the platform url-launch service by the feature layer. Opens the SYSTEM
  /// browser; the app performs NO in-app fetch of the source. Offline it is a no-op / disabled.
  final VoidCallback? onOpenExternal;

  @override
  Widget build(BuildContext context) {
    // The reference text always shows — it carries full trust with NO connection (11 §2, §4).
    final Widget reference = Text(
      citationText,
      // TODO: type.caption / type.body token; color.text.secondary for the reference line.
      style: /* TODO type.caption + color.text.secondary */ null,
      // Reflow, never truncate, at large text sizes (11 §7, WCAG 1.4.4/1.4.10).
      softWrap: true,
    );

    // No URL (or offline): the citation stands alone — it never DEPENDS on the network (11 §2).
    if (externalUrl == null) return reference;

    // With a URL: mark it visibly as LEAVING THE APP — a non-color "opens externally" glyph at
    // the logical END + the localized hint — and wrap it in a >=48dp tap target (privacy §7).
    return Semantics(
      link: true,
      // The screen reader hears the reference + that it opens externally, in the active locale.
      label: '$citationText, $externalLinkHint',
      child: InkWell(
        onTap: onOpenExternal, // null offline -> disabled; opens system browser online
        child: Padding(
          // TODO: padding so the row clears touch.min (>=48dp) — the link is a real tap target.
          padding: /* TODO EdgeInsetsDirectional from space.* + touch.min */ EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: ExcludeSemantics(child: reference)),
              const SizedBox(width: /* TODO space.1 */ 4),
              // The "leaves the app" glyph sits at the logical END (left in RTL). Use the
              // auto-mirroring directional treatment so it points/places correctly under RTL.
              ExcludeSemantics(
                child: Icon(
                  // TODO: an "opens externally / new window" glyph — the color-independent
                  //       signal that this LEAVES the app (privacy §3/§7). Pair with the hint text.
                  Icons.open_in_new,
                  size: /* TODO from space.* scale */ 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BLOCK 3 — packages/features/lib/src/science/widgets/science_source_row.dart  (features/, domain-aware)
// Maps ONE registered claim -> the two-layer source row (plain headline on the face; named
// source + grade + caveat in the "the evidence" expansion) and merges it into ONE localized
// Semantics phrase. The row AUTHORS NOTHING — it renders a CLAIMS.md entry (11 §1).
// ============================================================================

// import 'package:engine/engine.dart' show ClaimRow;  // the registered claim value type (read-only)
// import 'package:l10n/l10n.dart';                     // AppLocalizations — every string from here
// import 'package:ui/ui.dart';                         // EvidenceGradeTag, SourceCitation (the leaves above)
// import 'package:url_service/url_service.dart';       // injected launcher boundary (eng-define-service-boundary)

/// One verified claim as a source row on "The science we follow". Two layers: a plain headline
/// in the user's frame (type.body) on the face; the named source + confidence-grade + any caveat
/// in an optional "the evidence" expansion. Calm, offline, no engagement mechanics (11 §3, §5, §6).
class ScienceSourceRow extends StatelessWidget {
  const ScienceSourceRow({super.key, required this.claim, this.onOpenSource});

  /// A row from the bundled CLAIMS.md register — the ONLY author of the claim. This widget reads
  /// claim.headline, claim.citationText, claim.grade, claim.caveat, claim.url; it INVENTS nothing
  /// and never re-grades or re-derives anything (11 §1; domain-claims-register-and-science-screen).
  final Object /* TODO: ClaimRow */ claim;

  /// Routes the optional external URL through the injected url-launch service. Opens the SYSTEM
  /// browser; offline this is null (the link disables, the citation still reads). NO in-app fetch.
  final VoidCallback? onOpenSource;

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context);

    // TODO: map the registered claim -> presentation. The feature layer owns these maps and is
    // where the domain types are allowed (the ui/ leaves stay domain-blind):
    //   - headline:   claim.headline -> a PLAIN sentence in the user's frame (murājaʿa/pages/juz),
    //                 type.body, transcreated per locale (domain-adab-and-religious-integrity). NOT jargon.
    //   - grade:      claim.grade -> EvidenceGrade + a localized CONFIDENCE label + a short text tag
    //                 ("meta-analysis" / "traditional source"). NEVER a star/badge/% (11 §5).
    //   - citation:   claim.citationText -> author/year/venue as on-device text; the YEAR rendered
    //                 in LOCALE NUMERALS (intl + type.numeral) and the Latin run BIDI-ISOLATED (FSI/PDI)
    //                 — via eng-rtl-and-bidi-layout. For [TRAD]: collection + number + grading.
    //   - url:        claim.url -> optional; passed to SourceCitation only as a CONVENIENCE (11 §2).
    //   - caveat:     claim.caveat -> the honest "app uses X; research shows X–Y" line, if any (11 §4).
    //   - tradScope:  if claim.grade == trad -> framed as METHODOLOGY, sect-neutral, NO ruling;
    //                 show "needs scholarly review" plainly where sign-off is pending (11 §8).
    const String headline = ''; // TODO l10n plain headline (user's frame)
    const EvidenceGrade grade = EvidenceGrade.ma; // TODO from claim.grade
    const String confidenceLabel = ''; // TODO l10n confidence sentence for `grade`
    const String shortTag = ''; // TODO l10n short tag, e.g. "meta-analysis"
    const String citationText = ''; // TODO author/year/venue (year=locale numerals, Latin bidi-isolated)
    const String externalLinkHint = ''; // TODO l10n "opens in your browser"
    final String? url = null; // TODO claim.url (optional)
    final String? caveat = null; // TODO claim.caveat or null

    // MergeSemantics: the whole row is read as ONE localized phrase — e.g.
    // "Spaced revision slows forgetting. Cepeda et al. 2006, meta-analysis, opens in your browser."
    // — in the active locale, each run locale/bidi-tagged (11 §7). Decoration is excluded above.
    return MergeSemantics(
      child: ExpansionTile(
        // The FACE: a plain headline only — common words, active voice, the user's frame (11 §3).
        title: Text(headline /* TODO style: type.body */),
        // No leading/trailing badge, no "1 of N" counter, no celebratory affordance (11 §6).
        // The "the evidence" expansion: named source + confidence grade + optional caveat.
        children: [
          Padding(
            // TODO: EdgeInsetsDirectional from space.* — logical start/end, never hardcoded L/R.
            padding: /* TODO EdgeInsetsDirectional.fromSTEB(space.4, ...) */ EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The named, dated source as on-device text + the optional external link.
                SourceCitation(
                  citationText: citationText,
                  externalLinkHint: externalLinkHint,
                  externalUrl: url,
                  onOpenExternal: onOpenSource, // null offline; opens system browser online
                ),
                const SizedBox(height: /* TODO space.2 */ 8),
                // The grade as CONFIDENCE LANGUAGE + glyph + text tag — never color alone.
                EvidenceGradeTag(
                  grade: grade,
                  confidenceLabel: confidenceLabel,
                  shortTag: shortTag,
                ),
                // The full confidence sentence in plain words (11 §5) — describes the EVIDENCE,
                // never the user's Quran; no retention promise, no "safe to drop".
                const SizedBox(height: /* TODO space.1 */ 4),
                Text(confidenceLabel /* TODO style: type.caption, color.text.secondary */),
                // The honest simplification caveat, when the app simplifies (11 §4).
                if (caveat != null) ...[
                  const SizedBox(height: /* TODO space.1 */ 4),
                  Text(caveat /* TODO style: type.caption, color.text.secondary */),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TESTS (mirror the source tree under packages/features/test/ and packages/ui/test/)
// Goldens load the REAL bundled UI fonts (never Ahem) so Persian/Sorani/Arabic digits and
// letters are actually exercised; runner pinned for stability (eng-write-dart-test).
// ============================================================================

// import 'dart:io';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   // RTL + grade matrix: render the row for an [MA] claim and a [TRAD] (hadith) claim across fa/ckb/ar.
//   for (final locale in const [Locale('ar'), Locale('fa'), Locale('ckb')]) {
//     for (final grade in const [EvidenceGrade.ma, EvidenceGrade.trad]) {
//       testWidgets('science source row · $locale · $grade golden', (tester) async {
//         // TODO: pump ScienceSourceRow inside a MaterialApp with supportedLocales [ar, fa, ckb] +
//         //   GlobalWidgetsLocalizations (RTL derived from the locale, NEVER hardcoded Directionality).
//         //   Use the real bundled UI font family. Assert the YEAR shows in locale numerals and the
//         //   Latin author/venue run does NOT reorder (bidi isolation). Then:
//         //   await expectLater(find.byType(ScienceSourceRow),
//         //     matchesGoldenFile('goldens/science_source_row_${locale}_$grade.png'));
//       });
//     }
//   }
//
//   testWidgets('grade survives without color (grayscale / deuteranope)', (tester) async {
//     // TODO: assert the EvidenceGradeTag glyph + the short text tag + the confidence sentence
//     //       still convey the grade under a grayscale / deuteranope simulation — color is never
//     //       the sole channel (11 §7 / SC 1.4.1). NO stars, NO "proven" badge, NO percentage rendered.
//   });
//
//   testWidgets('tapping the source triggers NO in-app network call (offline guard)', (tester) async {
//     // TODO: wrap in HttpOverrides.runZoned with an override that FAILS any socket; tap the link
//     //       and assert the app makes no in-app fetch (it routes to the SYSTEM browser only), and
//     //       that the citation text still renders fully when externalUrl/onOpenExternal are null (11 §2).
//   });
//
//   testWidgets('row never grades the user / never promises a percentage', (tester) async {
//     // TODO: assert no rendered text grades the user's Quran, no retention-% string appears, and no
//     //       "safe to drop" / "mastered" / "proven" copy is present — the honesty contract (11 §5, §8).
//   });
//
//   testWidgets('[TRAD] row shows collection + number, issues no ruling', (tester) async {
//     // TODO: for a [TRAD] claim, assert the citation carries the collection + number + grading and
//     //       that the copy frames it as methodology (no fiqh verdict; "needs scholarly review" where
//     //       pending) — domain-adab-and-religious-integrity (11 §4, §8).
//   });
// }
