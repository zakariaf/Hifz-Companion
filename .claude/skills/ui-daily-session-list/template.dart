// SCAFFOLD — the Hifz Companion "Today / revise today" surface.
// Copy this into packages/features/lib/src/today/ (the View) and fill every // TODO.
// Opening this file on its own shows unresolved symbols — expected; the real symbols
// (engine value types, l10n, tokens, providers) resolve only inside the pub workspace.
//
// Governing docs:
//   docs/design-system/07-components.md §1 (daily-session list: finite/capped, Far→Near→New,
//     four states, localized term-sets, one Semantics container), §2 (page-card row: one ≥48dp
//     tap, no glyphs, no D/S/R / "safe to drop")
//   docs/design-system/05-layout-spacing-touch.md §1 (space.* scale), §3 (RTL = EdgeInsetsDirectional,
//     leading start / chevron end), §4 (48dp targets, one tap per row), §5 (Today template: tap low in
//     the thumb zone, settings/destructive top)
//   docs/PRD.md §12.2 (the Today contract), §7.9 (engine owns load-balance + catch-up re-spread)
//
// Non-negotiables this scaffold encodes:
//   - FINITE & CAPPED to the daily time budget; the list ENDS. No infinite scroll, no feed,
//     no count-up of completed items.
//   - Grouped Far (manzil) → Near (sabqi) → New (sabaq), recited OLD before NEW. Never reordered.
//   - The View is DUMB: it renders the engine/controller's pre-built day. It NEVER sorts/caps/
//     load-balances, NEVER calls the engine, NEVER reads DateTime.now() (clockProvider owns "today").
//   - A row is ONE muṣḥaf page = ONE ≥48dp tap into recite. The chip + decay indicator are LABELS,
//     not separate tap targets. NO Quran glyphs in a row. NO D/S/R, no %, no "safe to drop".
//   - Tokens (color.* / type.* / space.* / touch.min) referenced BY NAME — never inline hex/dp/pt.
//   - RTL by construction: EdgeInsetsDirectional / AlignmentDirectional only — never left/right.
//   - Section labels + decay/all-done/budget copy come from AppLocalizations (ar template, fa/ckb)
//     as localized term-sets — never hardcoded English.
//   - NO gamification anywhere: no streaks/badges/scores/XP/completion-%/confetti. all-done is calm.
//     catch-up is a gentle re-spread banner, NEVER a red shame-pile.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:l10n/l10n.dart';        // AppLocalizations — every string, incl. term-sets (§1)
// import 'package:engine/engine.dart';    // immutable value types: ReviewItem, Track, DecayBand
// import 'today_view_model.dart';          // todayControllerProvider — see eng-create-riverpod-store
// import 'package:design_system/design_system.dart'; // SpacingTokens / type / color via ThemeExtension
// import 'widgets/page_card_row.dart';     // the row internals — built by ui-page-card-and-decay

// ============================================================================
// The dumb Today View. Reads ONE controller and renders the pre-built day.
// Logic (capping, ordering, load-balance, catch-up math) lives in the engine +
// controller, NEVER here (§1; PRD §7.9).
// ============================================================================

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final l10n = AppLocalizations.of(context); // no hardcoded UI literals; term-sets live here (§1)
    final dayAsync = ref.watch(/* TODO */ Provider((_) => null)); // todayControllerProvider

    // RTL is the geometry, not a mode: the app-wide Directionality mirrors layout; use logical
    // start/end only. Tokens by name. No gamification anywhere on this surface.
    return Scaffold(
      // Settings shortcut / destructive actions sit in the HARD-to-reach top corner (§5).
      appBar: AppBar(
        title: const Text(/* TODO: l10n.todayReviseTitle — "Revise today" */ 'Revise today'),
        // actions: [ IconButton(onPressed: ..., icon: settings) ],  // top corner only
      ),
      body: SafeArea(
        // dayAsync.when(loading / error / data) — calm in every branch (§1).
        child: const _PopulatedList(/* TODO: pass the grouped, capped day */),
      ),
    );
  }
}

// ============================================================================
// LOADING — a brief surfaceContainerLow skeleton while the engine builds the day.
// No spinner theatre (§1 In practice).
// ============================================================================

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    // final cs = Theme.of(context).colorScheme; // color.surfaceContainerLow by name (03)
    // A few quiet placeholder rows — calm, no shimmer fanfare.
    return const SizedBox.shrink(); // TODO: skeleton on surfaceContainerLow
  }
}

// ============================================================================
// POPULATED — the grouped, capped list. Sections render as slivers in the FIXED
// order Far (manzil) → Near (sabqi) → New (sabaq), recited OLD before NEW (§1).
// The list is FINITE and ends — no infinite ListView.builder over a paged feed.
// ============================================================================

class _PopulatedList extends StatelessWidget {
  const _PopulatedList(/* TODO: required this.day */);
  // final TodayDay day; // already grouped + capped by the engine/controller

  @override
  Widget build(BuildContext context) {
    // final s = Theme.of(context).extension<SpacingTokens>()!; // space.* by name (05 §1)

    // The honest budget-feedback line sits above the list when scope can't fit the budget:
    // it says so and offers raise budget / lengthen cycle / pause new sabaq — never silently
    // lets pages rot, never drops a FAR/manzil item (PRD §12.2, §7.9).
    // The catch-up banner replaces the budget line after a missed gap (gentle re-spread, §1).

    return CustomScrollView(
      slivers: [
        // if (day.isCatchUp) const SliverToBoxAdapter(child: _CatchUpBanner()),
        // else if (day.budgetOverflow) const SliverToBoxAdapter(child: _BudgetFeedbackLine()),

        // FAR (manzil) → NEAR (sabqi) → NEW (sabaq). One sliver per non-empty section.
        // ..._sectionSlivers(day.far,  Section.far),   // header term-set: المراجعة البعيدة / مەنزڵ دوور
        // ..._sectionSlivers(day.near, Section.near),  // header term-set: المراجعة القريبة
        // ..._sectionSlivers(day.newSabaq, Section.newSabaq), // header term-set: السبق / الحفظ الجديد

        // if (day.isComplete) const SliverFillRemaining(child: _AllDoneSurface(), hasScrollBody: false),
      ],
    );
  }
}

// A section = a quiet localized header (type.title) + its page-card rows.
// Header separated by space.6; rows space.2 apart (§1 In practice).
List<Widget> _sectionSlivers(/* List<ReviewItem> items, Section section */) {
  // final l10n = ...; final term = l10n.sectionLabel(section); // localized TERM-SET, never English (§1; PRD §13.4)
  return const [
    // SliverPadding(
    //   padding: EdgeInsetsDirectional.only(top: s.space6, start: s.space4, end: s.space4),
    //   sliver: SliverToBoxAdapter(child: Text(term, style: type.title)),  // RTL: start = right
    // ),
    // SliverList.separated(
    //   itemCount: items.length,
    //   separatorBuilder: (_, __) => SizedBox(height: s.space2),
    //   itemBuilder: (_, i) => PageCardRow(item: items[i]),  // ui-page-card-and-decay builds the row
    // ),
  ]; // TODO
}

// ============================================================================
// PAGE-CARD ROW (placement only — internals are built by ui-page-card-and-decay).
// One muṣḥaf page = ONE ≥48dp tap into the recite flow. Leading (start): track chip
// + decay indicator (LABELS, not tap targets). Headline: localized "Page ۲۵۳ · Juz ۱۳"
// (locale numerals, bidi-isolated). Optional supporting line. Trailing (end): chevron.
// NO Quran glyphs. NO D/S/R / % / "safe to drop" (§2).
// ============================================================================

class PageCardRow extends StatelessWidget {
  const PageCardRow({super.key /* , required this.item */});
  // final ReviewItem item; // a domain type — so this widget stays in the feature (not shared ui/)

  @override
  Widget build(BuildContext context) {
    // The WHOLE row is the single hit target into recite — the chip/indicator inside do not
    // intercept taps (one row, one action; §2; 05 §4). touch.min = 48dp.
    return Semantics(
      button: true,
      // label: "Page 253, Juz 13, far-revision, weak" — leading glyphs announced as WORDS (§2).
      child: InkWell(
        onTap: () {
          // Open the recite/grade flow for this page — ui-recite-grade-flow owns that surface.
          // The grade it returns is persisted through the controller's SINGLE WRITE PATH,
          // never written from this widget (eng-create-riverpod-store).
        },
        child: const ListTile(
          // leading: PageCardLeading(track: item.track, decay: item.decayBand), // chip + decay, start (right)
          // title:   Text(localizedPageJuz(item), style: type.body),            // locale numerals, bidi-isolated
          // subtitle: item.weakHint != null ? Text(item.weakHint!, style: type.caption /* color.text.secondary */) : null,
          // trailing: Icon(Icons.chevron_left), // chevron at END (left) — mirrors automatically in RTL
        ),
      ),
    );
  }
}

// ============================================================================
// ALL-DONE — a calm terminal surface. Informational, in color.text.secondary.
// NEVER confetti / streak / badge / exclamation mark (§1 Anti-patterns; PRD R3, C6).
// ============================================================================

class _AllDoneSurface extends StatelessWidget {
  const _AllDoneSurface();

  @override
  Widget build(BuildContext context) {
    // final l10n = ...; // l10n.todayComplete — "Today's revision is complete." (transcreated, not translated)
    return const Center(
      child: Text(
        /* TODO: l10n.todayComplete */ "Today's revision is complete.",
        // style: type.body.copyWith(color: color.text.secondary), // quiet, no celebration
      ),
    ); // TODO
  }
}

// ============================================================================
// CATCH-UP BANNER — after a missed gap. A GENTLE banner offering the engine's
// re-spread plan ("You missed 3 days — here is a 5-day catch-up plan…").
// NEVER a red overdue / shame-pile (§1; PRD §12.2, §7.9). The re-spread MATH is
// the engine's — domain-scheduling-engine-rules; this only DISPLAYS it.
// ============================================================================

class _CatchUpBanner extends StatelessWidget {
  const _CatchUpBanner();

  @override
  Widget build(BuildContext context) {
    // Calm surface color (NOT semantic.warning/error red). Padding s.space4, EdgeInsetsDirectional.
    return const SizedBox.shrink(); // TODO: l10n.catchUpPlan(missedDays, planDays) + accept affordance
  }
}

// ============================================================================
// HONEST BUDGET-FEEDBACK LINE — when the chosen scope can't fit the time budget.
// Says so plainly and offers raise budget / lengthen cycle / pause new sabaq.
// NEVER silently lets pages rot; NEVER drops a FAR/manzil due item (PRD §12.2, §7.9).
// Autonomy-supportive copy (offers options, never commands) — domain-adab-and-religious-integrity.
// ============================================================================

class _BudgetFeedbackLine extends StatelessWidget {
  const _BudgetFeedbackLine();

  @override
  Widget build(BuildContext context) {
    // One calm informational line + the three options as quiet actions. No alarm styling.
    return const SizedBox.shrink(); // TODO: l10n.budgetOverflow + [raiseBudget | lengthenCycle | pauseSabaq]
  }
}

// ============================================================================
// TESTS (mirror under packages/features/test/today/) — see eng-write-dart-test:
// - Widget tests for ALL FOUR states (loading / populated / all-done / catch-up) + the budget line,
//   in fa, ckb, AND ar, with the REAL fonts (RTL golden).
// - Assert section order is ALWAYS Far → Near → New; assert NO Quran glyph and NO D/S/R/% renders.
// - Assert each row is one ≥48dp tap; the chip/indicator do not intercept taps.
// - HttpOverrides offline guard: this surface touches no network.
// ============================================================================
