// SCAFFOLD — this file bundles the pieces of the Hifz Companion page card.
// It is NOT a standalone Dart file: it contains three widget blocks plus a golden-test
// stub. Copy each labelled block into the right file under packages/, then fill every
// // TODO. Opening this file on its own shows unresolved symbols — that is expected; the
// real symbols (engine value types, AppLocalizations, the design-system token layer)
// resolve only inside the pub workspace.
//
// Three pieces, in two layers:
//   1. DecayIndicator — shared ui/ leaf, DOMAIN-BLIND (takes a level enum + label text only).
//   2. TrackChip      — shared ui/ leaf, DOMAIN-BLIND (takes a track family + localized label).
//   3. PageCard       — features/ leaf, maps a domain ReviewItem -> the row slots + Semantics.
//
// Tokens are referenced BY NAME ONLY (color.* / type.* / space.* / touch.min). The design
// docs own the concrete values — never inline hex / pt / dp / ms here.
//
// Governing docs:
//   docs/design-system/07-components.md §2 (page card anatomy), §3 (track chip),
//     §4 (decay indicator), §6 (M3 state layers + focus ring)
//   docs/design-system/03-color-and-themes.md §5 (single-hue heatmap ramp),
//     §2 (green = reverent ground, never reward), §6 (no alarm-red for routine state)
//   docs/design-system/09-accessibility-and-inclusivity.md §4 (color-independence / SC 1.4.1),
//     §6 (>=48dp target), §7 (MergeSemantics, localized label)
//   eng-rtl-and-bidi-layout (locale numerals + FSI/PDI isolation of "Page N · Juz M")
//
// Non-negotiables this scaffold encodes:
//   - The row NEVER draws a Quran glyph (the muṣḥaf lives only in the reader — domain-mushaf-text-integrity).
//   - The row NEVER shows R / D / S or a percentage; only track + decay bands.
//   - The decay indicator has NO "safe to drop" / "mastered" state (domain-scheduling-engine-rules).
//   - Decay & track encode meaning with color AND glyph AND/OR text — never color alone.
//   - No streak / badge / score / confetti / celebratory tint anywhere on the card.
//   - Offline / no-AI: the row READS streamed state; it never fetches, records, infers, or recomputes due_at.

import 'package:flutter/material.dart';

// ============================================================================
// BLOCK 1 — packages/ui/lib/src/decay_indicator.dart  (shared ui/, DOMAIN-BLIND)
// The per-row honest-decay swatch. Encodes ONE fact THREE ways: a single-hue
// lightness-ramp color + a glyph + a text label (07 §4; 09 §4 / SC 1.4.1).
// Ranges ONLY solid -> needs-revision: there is NO "safe to drop" / "mastered" level.
// ============================================================================

/// The three calm decay bands shown on a page card. Derived from the engine's
/// retrievability `R` (min-leaning) by the feature layer — this widget never sees `R`,
/// and the raw number is NEVER rendered (07 §4).
enum DecayLevel { solid, holding, needsRevision }

/// Domain-blind decay swatch: color + glyph + label, ≤ space.4, never color alone.
/// The caller passes the already-localized [label] ("solid"/"holding"/"needs revision"
/// transcreated per locale — 11-voice-and-tone.md) so this leaf imports no l10n/domain.
class DecayIndicator extends StatelessWidget {
  const DecayIndicator({super.key, required this.level, required this.label});

  final DecayLevel level;
  final String label; // localized term-set string, supplied by the feature layer

  @override
  Widget build(BuildContext context) {
    // TODO: resolve each from the design-system token layer — NEVER inline a hex / pt.
    //   color: the single-hue lightness ramp (color.heatmap.strong -> mid -> color.heatmap.faded),
    //          re-toned per appearance, monotonic in luminance (03 §5). NEVER red/amber danger (03 §6).
    //   glyph: filled (solid) / half (holding) / hollow-receding (needsRevision) — the SHAPE channel (07 §4).
    final (Color swatch, IconData glyph) = switch (level) {
      DecayLevel.solid => (/* TODO color.heatmap.strong */ const Color(0x00000000), /* TODO filled */ Icons.circle),
      DecayLevel.holding => (/* TODO mid ramp step */ const Color(0x00000000), /* TODO half */ Icons.contrast),
      DecayLevel.needsRevision =>
        (/* TODO color.heatmap.faded */ const Color(0x00000000), /* TODO hollow */ Icons.circle_outlined),
    };

    // ExcludeSemantics: the swatch/glyph is decoration; the LABEL is what the screen
    // reader hears, and it is merged into the row's one phrase by PageCard (09 §7).
    return ExcludeSemantics(
      child: Icon(
        glyph,
        color: swatch,
        // TODO: size from space.4 ceiling — a quiet indicator, never a gauge (07 §4).
        size: /* TODO space.4 */ 16,
      ),
    );
    // The [label] is rendered in the row's supporting line / Semantics, NOT a separate
    // visual chip here — kept as a field so the feature can route it into both.
  }
}

// ============================================================================
// BLOCK 2 — packages/ui/lib/src/track_chip.dart  (shared ui/, DOMAIN-BLIND)
// The non-interactive label that names the tradition (sabaq / sabqi / manzil).
// Pairs a tradition-tied color FAMILY with a localized term-set LABEL — never color
// alone, never alarm-red, never a count/XP/streak/badge (07 §3; 03 §2/§6; 09 §4).
// ============================================================================

/// The lifecycle phase a card is in. Three phases of one page card, NOT three algorithms.
enum TrackFamily { far, near, neww } // far=manzil, near=sabqi, neww=sabaq

/// Domain-blind track label. The feature layer maps the engine's track to a [family]
/// and supplies the already-localized regional term-set [label] (المراجعة البعيدة /
/// مرور دور / مەنزڵ — switchable per region, 07 §3). ckb's longer terms WRAP, not truncate.
class TrackChip extends StatelessWidget {
  const TrackChip({super.key, required this.family, required this.label});

  final TrackFamily family;
  final String label; // localized term-set string; NEVER a baked-in English glyph

  @override
  Widget build(BuildContext context) {
    // TODO: resolve the tradition-tied color family from tokens (values owned by 03):
    //   far  -> color.accent.green family (the MAINTENANCE core — green is calm, not danger)
    //   near -> a secondary neutral-tinted family
    //   neww -> a tertiary neutral-tinted family
    // NEVER an alarm-red for any track (07 §3 anti-patterns; 03 §6).
    final Color family_ = switch (family) {
      TrackFamily.far => /* TODO color.accent.green family */ const Color(0x00000000),
      TrackFamily.near => /* TODO secondary neutral-tinted */ const Color(0x00000000),
      TrackFamily.neww => /* TODO tertiary neutral-tinted */ const Color(0x00000000),
    };

    // A label-only Chip (non-interactive: no onPressed, no onDeleted, no selected state).
    // The COLOR + the TEXT together carry the track (color-independence, 09 §4 / SC 1.4.1).
    // Part of the row's merged Semantics — NOT a separately focusable node (07 §3).
    return ExcludeSemantics(
      child: Chip(
        // TODO: avatar/label spacing = space.1; padding stays within the row's vertical rhythm (07 §3).
        label: Text(
          label,
          // TODO: type.label token; let ckb wrap rather than truncate (no ellipsis on sacred-adjacent terms).
          style: /* TODO type.label */ null,
        ),
        // TODO: backgroundColor / side derived from `family_` via the token layer; flat, no elevation.
        side: BorderSide(color: family_),
      ),
    );
  }
}

// ============================================================================
// BLOCK 3 — packages/features/lib/src/today/widgets/page_card.dart  (features/, domain-aware)
// Maps a domain ReviewItem -> the M3 list-item slots, and merges the whole row into one
// localized Semantics phrase. The row is ONE >=48dp tap into the recite flow (07 §2; 09 §6).
// ============================================================================

// import 'package:engine/engine.dart';  // ReviewItem, TrackKind, etc. — value types only (this is why the widget is in the feature)
// import 'package:l10n/l10n.dart';       // AppLocalizations — every string from here (no hardcoded literal)
// import 'package:ui/ui.dart';           // DecayIndicator, TrackChip (the domain-blind leaves above)

/// One muṣḥaf page as a row. Flat ListTile at elevation Level 0–1; leading = chip + decay
/// indicator (LABELS, not separate tap targets); headline = "Page N · Juz M" in locale
/// numerals; supporting = optional next-due / weak hint; trailing = chevron into recite.
class PageCard extends StatelessWidget {
  const PageCard({super.key, required this.item, required this.onOpen});

  final Object /* TODO: ReviewItem */ item;
  final VoidCallback onOpen; // opens the recite/grade flow (ui-recite-grade-flow)

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context);

    // TODO: map the domain item -> presentation. The feature layer owns these maps:
    //   - TrackFamily + localized track label (regional term-set).
    //   - DecayLevel (derived from R, min-leaning — R is COMPUTED ON READ, never shown).
    //   - headline: "Page N · Juz M" with numerals in the locale set (Extended Arabic-Indic
    //     fa/ckb, Arabic-Indic ar) and the mixed run bidi-ISOLATED (FSI/PDI) — via eng-rtl-and-bidi-layout.
    //     NEVER splice raw ASCII digits; NEVER let the run reorder ("30 of 7").
    //   - supporting: optional "next: in N days" / "weak line N" (type.caption, color.text.secondary).
    //   - state: default / weak / due-today / pulled-forward / done / locked — drives ONLY
    //     border/surface emphasis + the indicator, NEVER the page art (07 §2).
    const TrackFamily trackFamily = TrackFamily.far; // TODO from item.track
    const String trackLabel = ''; // TODO l10n regional term-set
    const DecayLevel decayLevel = DecayLevel.solid; // TODO from item.retrievability (min-leaning)
    const String decayLabel = ''; // TODO l10n "solid"/"holding"/"needs revision"
    const String headline = ''; // TODO l10n.pageJuz(page, juz) -> locale numerals, bidi-isolated
    final String? supporting = null; // TODO optional next-due / weak hint, or null

    // MergeSemantics: the whole row is read as ONE localized phrase — e.g.
    // "Page ۲۵۳, Juz ۱۳, far-revision, needs revision" — in the active locale, with the
    // correct TextDirection (09 §7). The leading glyphs are announced as WORDS, not decoration.
    return MergeSemantics(
      child: Card(
        // TODO: elevation = Level 0–1 token; flat surface; NO decorative shadow, NO brand tint (07 §2).
        elevation: /* TODO elevation.level0..1 */ 0,
        child: ListTile(
          // Whole row is one >=48dp / 44pt tap into recite (touch.min, 09 §6). One action per row.
          onTap: onOpen,
          // Leading slot (row START / right in RTL): chip + decay indicator, space.2 apart.
          // Both are LABELS inside the row — NOT separate tappable controls (07 §2).
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TrackChip(family: trackFamily, label: trackLabel),
              SizedBox(width: /* TODO space.2 */ 8),
              DecayIndicator(level: decayLevel, label: decayLabel),
            ],
          ),
          // Headline: "Page N · Juz M" in locale numerals, bidi-isolated, type.body.
          title: Text(headline /* TODO style: type.body */),
          // Supporting: optional next-due / weak hint, type.caption + color.text.secondary.
          subtitle: supporting == null
              ? null
              : Text(supporting /* TODO style: type.caption, color.text.secondary */),
          // Trailing (row END / left in RTL): chevron into recite. Use the auto-mirroring
          // directional icon so it points correctly under RTL (eng-rtl-and-bidi-layout).
          trailing: const Icon(Icons.chevron_right), // TODO auto-mirroring directional chevron
          // State emphasis (weak outline = quiet color.semantic.warning, NEVER alarm-red;
          // pulled-forward looks identical to any due item; done = checked/dimmed/removable;
          // locked = a small lock affordance for a teacher's manual_lock) is applied here via
          // M3 STATE LAYERS over the role color + a visible focus ring (color.outline) — 07 §6.
        ),
      ),
    );
  }
}

// ============================================================================
// TESTS (mirror the source tree under packages/features/test/ and packages/ui/test/)
// Goldens load the REAL bundled UI fonts (never Ahem) so Persian digits and Sorani
// letters are actually exercised; runner pinned for stability (eng-write-dart-test).
// ============================================================================

// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   // RTL + state matrix: render PageCard in each state across fa / ckb / ar.
//   for (final locale in const [Locale('ar'), Locale('fa'), Locale('ckb')]) {
//     for (final state in /* TODO: default, weak, dueToday, pulledForward, done, locked */ const []) {
//       testWidgets('page card · $locale · $state golden', (tester) async {
//         // TODO: pump PageCard inside a MaterialApp with supportedLocales [ar, fa, ckb] +
//         //   GlobalWidgetsLocalizations (RTL derived from the locale, NEVER hardcoded Directionality).
//         //   Use the real bundled UI font family. Then:
//         //   await expectLater(find.byType(PageCard), matchesGoldenFile('goldens/page_card_${locale}_$state.png'));
//       });
//     }
//   }
//
//   testWidgets('whole row is one labelled >=48dp tap target', (tester) async {
//     // TODO: await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
//     //       await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
//     // and assert the chip / decay indicator are NOT separate tappable nodes (one onTap per row).
//   });
//
//   testWidgets('decay band readable without color (grayscale / deuteranope)', (tester) async {
//     // TODO: assert the DecayIndicator glyph + the localized label survive a grayscale /
//     //       deuteranope simulation — color is never the sole channel (09 §4 / SC 1.4.1).
//   });
//
//   testWidgets('row never exposes R / a percentage / "safe to drop"', (tester) async {
//     // TODO: assert no rendered text matches an R/percentage pattern and no "safe to drop"/
//     //       "mastered" string appears — the honesty contract (07 §2/§4; domain-scheduling-engine-rules).
//   });
// }
