// SCAFFOLD — the Hifz Companion whole-Quran retention heat-map (the Progress surface).
// Copy this into packages/features/lib/src/progress/widgets/ (the View leaves) and the
// progress screen, then fill every // TODO. Opening this file on its own shows unresolved
// symbols — expected; the real symbols (engine value types, l10n, tokens, providers)
// resolve only inside the pub workspace.
//
// Governing docs:
//   docs/design-system/08-data-visualization.md
//     §1 (overview → zoom → details-on-demand), §2 (single-hue lightness ramp),
//     §3 (decay visible, never alarming red / no rainbow), §4 (VSUP uncertainty muting),
//     §5 (redundant colour+number+label), §6 (min-leaning juz roll-up + weakest-page badge),
//     §7 (muṣḥaf-order RTL faithful small multiples), §8 (never a streak/score/scoreboard)
//   docs/design-system/03-color-and-themes.md §5 (color.heatmap.* ramp — values owned there),
//     §2 (green = state not trophy), §6 (no alarm-red), §7 (3:1 anchor contrast audit)
//   docs/PRD.md §12.5 (Progress contract), §7.10/§7.12 (priors + invariants), §8.1 (sourceConfidence),
//     §10.2 (review_log), §13.2/§13.3 (RTL + locale numerals)
//
// Non-negotiables this scaffold encodes:
//   - OVERVIEW FIRST: the screen leads with the 604-page / 30-juz grid; exact numbers live BEHIND A TAP.
//   - SINGLE-HUE RAMP: color.heatmap.strong → faded, monotonic in luminance, by NAME. Never a hue axis,
//     never red→amber→green, never a rainbow/jet colormap. Decay end is a calm MUTED NEUTRAL, not red.
//   - VSUP MUTING: a cold-start / never-recited / self-rating-only page is GREYED; it saturates only as
//     confident (teacher) reviews accumulate. A single self-rating never reaches the top tier.
//   - REDUNDANT: every cell = ramp colour + a LOCALIZED number/range + a plain label (+ optional texture).
//     Colour is NEVER the sole channel (SC 1.4.1).
//   - MIN-LEANING juz roll-up: the tile leans to its WEAKEST page (never a mean); surface a weakest-page badge.
//   - The View is DUMB: it renders the engine's pre-built read model. It NEVER computes R / due / the juz
//     aggregate, NEVER calls the engine, NEVER reads DateTime.now() (the engine owns "today").
//   - NO glyphs, NO decoration in this layer. NO streak/score/scoreboard/confetti/green-flash/badge-on-ayah.
//   - Tokens (color.heatmap.* / space.* / touch.min) by NAME — never inline hex/dp/pt or restate the audit.
//   - RTL by construction: EdgeInsetsDirectional / AlignmentDirectional only — never left/right.
//   - Locale numerals via intl (Extended Arabic-Indic fa/ckb, Arabic-Indic ar); mixed runs bidi-isolated.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:l10n/l10n.dart';        // AppLocalizations — every label/range, transcreated per locale
// import 'package:engine/engine.dart';    // immutable read-model value types (see below)
// import 'package:design_system/design_system.dart'; // HeatmapTokens / SpacingTokens via ThemeExtension
// import 'progress_view_model.dart';       // retentionMapProvider — see eng-create-riverpod-store

// ============================================================================
// READ MODEL (engine-owned, immutable). The widget RENDERS these — it never derives them.
// R, sourceConfidence, the min-leaning juzBand, and "never safe to drop" come from the engine
// (domain-scheduling-engine-rules); this file only maps them to colour + number + label.
// ============================================================================

// enum HeatLevel { strong, good, fair, weak, faded }   // → color.heatmap.{strong,good,fair,weak,faded}
//
// class PageHealth {                 // one of the 604 pages
//   final int pageId;                // 1..604, muṣḥaf order
//   final int juz;                   // 1..30
//   final HeatLevel level;           // engine-classified band from card.R (NOT recomputed here)
//   final double? retrievability;    // 0..1 — shown as a localized % RANGE in the detail, never a bare crisp %
//   final bool everReviewed;         // false → cold-start prior → render MUTED (VSUP §4)
//   final double sourceConfidence;   // self ≈ 0.5, teacher = 1.0 (PRD §8.1) → drives muting
//   final CalendarDate? nextDue;     // from the engine; rendered in the chosen calendar + locale numerals
// }
//
// class JuzHealth {                  // a 30-block small multiple
//   final int juz;                   // 1..30
//   final HeatLevel rollUp;          // MIN-LEANING over its pages (PRD §10.3) — never a mean
//   final int? weakestPageId;        // surfaced as a badge + named in the detail
//   final List<PageHealth> pages;    // ~20 pages, muṣḥaf order
// }
//
// class RetentionMap { final List<JuzHealth> juz; }   // 30 juz, muṣḥaf order

// ============================================================================
// THE PROGRESS SCREEN — overview first. Leads with the heat-map, NOT a stats table (§1; PRD §12.5).
// The upcoming-load forecast / simple history sit BESIDE/BELOW the map as calm planning aids,
// never a performance dashboard. NO streak/score/scoreboard anywhere on this surface (§8).
// ============================================================================

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final l10n = AppLocalizations.of(context);          // no hardcoded labels; transcreated per locale (§3)
    final mapAsync = ref.watch(/* TODO */ Provider((_) => null)); // retentionMapProvider (streamed Drift read model)

    return Scaffold(
      appBar: AppBar(
        title: const Text(/* TODO: l10n.progressTitle */ 'Progress'),
        // NO streak counter, NO "best day", NO points in the app bar or anywhere near the map (§8).
      ),
      body: SafeArea(
        child: const CustomScrollView(
          slivers: [
            // SliverToBoxAdapter(child: RetentionHeatmap(map: map)),   // the overview — leads the screen
            // SliverToBoxAdapter(child: UpcomingLoadForecast(...)),    // calm planning aid (PRD §12.5)
            // SliverToBoxAdapter(child: ReviewHistoryList(...)),       // plain review_log history, not a dashboard
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// THE HEAT-MAP — 30 juz blocks in MUṢḤAF ORDER, faithful small multiples, RTL (§7).
// Spatial position IS Quran position. One juz block is learned once and read thirty times.
// Never reorder by weakness; never swap for a treemap/radial/bubble chart.
// ============================================================================

class RetentionHeatmap extends StatelessWidget {
  const RetentionHeatmap({super.key /* , required this.map */});
  // final RetentionMap map;

  @override
  Widget build(BuildContext context) {
    // final s = Theme.of(context).extension<SpacingTokens>()!; // space.* by name (05)

    // RTL is the geometry: the app-wide Directionality.rtl makes the grid flow start→end so juz 1 /
    // page 1 sits where the muṣḥaf begins (PRD §13.2). Use logical insets only.
    return Padding(
      padding: const EdgeInsetsDirectional.all(/* s.space4 */ 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // the grid is finite; the screen scrolls, not the grid
        // 30 juz blocks as faithful small multiples — consistent block size + gutter (§7).
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // TODO: pick the juz-block columns; pages tile inside each block
          // mainAxisSpacing / crossAxisSpacing: s.space2 — gutters, not hairlines, so juz read as units (§1)
        ),
        itemCount: 0, // TODO: map.juz.length (30)
        itemBuilder: (context, i) {
          // return JuzTile(juz: map.juz[i]);  // each block tiles its ~20 pages in muṣḥaf order
          return const SizedBox.shrink(); // TODO
        },
      ),
    );
  }
}

// ============================================================================
// JUZ TILE — a small multiple. Its colour is the MIN-LEANING roll-up (engine-owned, PRD §10.3),
// never a mean. If one page is decaying inside an otherwise-strong juz, a weakest-page BADGE makes
// the single weak link visible WITHOUT recolouring the whole juz misleadingly (§6).
// ============================================================================

class JuzTile extends StatelessWidget {
  const JuzTile({super.key /* , required this.juz */});
  // final JuzHealth juz;

  @override
  Widget build(BuildContext context) {
    // The tile colour uses the SAME single-hue ramp as a page cell, fed by juz.rollUp (min-leaning).
    // Tap → expand to this juz's ~20 page cells (overview → zoom, §1). touch.min = 48dp.
    return Stack(
      children: [
        // GridView of HeatCell over juz.pages, muṣḥaf order.
        // The weakest-page badge sits at the LOGICAL START under Directionality.rtl (§6, §7).
        const PositionedDirectional(
          start: 0, // logical start = right in RTL; never `left:`
          top: 0,
          // child: WeakestPageBadge(pageId: juz.weakestPageId),  // only when a weak link exists
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ============================================================================
// HEAT CELL — one of 604 pages. The atomic mark. Domain-blind on primitives so it stays a leaf:
// a single-hue ramp colour + a LOCALIZED number + a plain LABEL (+ optional decay texture).
// Colour is NEVER the sole channel (§5; SC 1.4.1). A prediction it is unsure about looks MUTED (§4).
// ============================================================================

class HeatCell extends StatelessWidget {
  const HeatCell({
    super.key,
    required this.rampColor, // resolved from color.heatmap.{strong..faded} by the caller — by NAME
    required this.label, // localized "strong" / "softening" / "ready for revision" — transcreated (§3, §5)
    required this.localizedValue, // localized % or range in locale numerals via intl (PRD §13.3) — NOT raw ASCII
    required this.muted, // VSUP: true when never-reviewed or low sourceConfidence → suppress toward grey (§4)
    this.showDecayTexture = false, // optional 3rd colour-independent channel for the decaying end (§5)
    this.onTap, // → opens the page detail sheet (details-on-demand, §1)
  });

  final Color rampColor;
  final String label;
  final String localizedValue;
  final bool muted;
  final bool showDecayTexture;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // VSUP muting: when `muted`, the value signal is SUPPRESSED toward the theme neutral so an
    // uncertain page literally looks less definite (§4). Resolve the muted blend at the token layer,
    // never invent a per-widget alpha. NEVER render a cold-start prior as a confident saturated green.
    final fill = muted
        ? rampColor // TODO: blend toward color.heatmap.faded / surface neutral via the token helper
        : rampColor;

    return Semantics(
      button: onTap != null,
      // label: "Page ۲۵۳, ready for revision" — number + label announced as WORDS in the active locale (§5).
      // value: localizedValue,   // screen reader hears the localized retrievability too
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: /* touch.min 48dp */ 48,
            minHeight: 48,
          ),
          decoration: BoxDecoration(
            color: fill, // single-hue ramp — color.heatmap.* by NAME; decay end is a MUTED NEUTRAL, never red
            // TODO: if (showDecayTexture) add a subtle pattern (3rd channel) for the decaying end (§5).
          ),
          alignment: Alignment.center,
          child: Text(
            localizedValue, // locale numerals via intl; the run is bidi-isolated (FSI/PDI) so it never reorders
            // style: type.caption.copyWith(...) — value carries meaning, colour only reinforces (§5)
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WEAKEST-PAGE BADGE — makes one rotting page visible inside an otherwise-strong juz without
// recolouring the whole tile misleadingly (§6). Calm, never an alarm-red exclamation.
// ============================================================================

class WeakestPageBadge extends StatelessWidget {
  const WeakestPageBadge({super.key /* , required this.pageId */});
  // final int pageId;

  @override
  Widget build(BuildContext context) {
    // A quiet glyph/dot — color from the heat ramp's weak step or a neutral, NEVER color.semantic.* red (§3, §6).
    return const SizedBox.shrink(); // TODO
  }
}

// ============================================================================
// PAGE DETAIL SHEET — details-on-demand behind a cell tap (§1). States the estimate AS an estimate,
// IN WORDS — never a false-precise crisp percentage (§4, §5). Shows next-due (chosen calendar + locale
// numerals) and a short review_log history (PRD §10.2). NO D/S/R numbers, NO "safe to drop" / "mastered".
// ============================================================================

class _DetailSheet extends StatelessWidget {
  const _DetailSheet(/* { required this.page } */);
  // final PageHealth page;

  @override
  Widget build(BuildContext context) {
    // final l10n = ...;
    // Headline: localized "Page ۲۵۳ · Juz ۱۳" (locale numerals, bidi-isolated — eng-rtl-and-bidi-layout).
    // Estimate stated in words:
    //   - never reviewed → l10n.estimatedNotYetRecited  ("estimated — not yet recited")
    //   - self-rating only → a retrievability RANGE + its basis ("from self-rating"), never a single crisp %
    //   - teacher-confirmed → the confident value/range
    // Next-due: rendered in the user's chosen calendar (Hijri / Jalālī / Gregorian) + locale numerals.
    // Short history from review_log; NO streak, NO score, NO "you can stop revising" (§8; PRD §7.12).
    return const SizedBox.shrink(); // TODO
  }
}

// ============================================================================
// TESTS (mirror under packages/features/test/progress/) — see eng-write-dart-test:
// - Golden the full grid, a MIN-LEANING juz tile (one weak page fails/badges the juz, not a mean),
//   a MUTED uncertain cell, and the detail sheet — in fa, ckb, AND ar on the REAL bundled fonts (never Ahem).
// - Assert the grid is laid out in muṣḥaf order, start→end under Directionality.rtl; juz 1 / page 1 at the start.
// - Grayscale + deuteranope check: magnitude order of the ramp still reads (lightness, not hue) (§2, §5).
// - Assert NO Quran glyph and NO raw R / D / S / crisp % renders anywhere; the detail states the estimate in words.
// - Assert NO streak/score/scoreboard widget exists on the surface; a missed-day map shows honest recession only (§8).
// - HttpOverrides offline guard: this surface touches no network and recomputes no schedule.
// ============================================================================
