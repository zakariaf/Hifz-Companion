// template.dart — ui-mutashabihat-drill
//
// Copy-paste scaffold for the Hifz app's mutashābihāt discrimination-drill UI.
// Fully offline · no AI · no microphone · RTL (fa/ckb/ar) · Material 3 · Riverpod.
//
// This screen OWNS the drill choreography and the hotspots presentation only.
// It READS group/hotspot read models from `domain-mutashabihat-system` and
// RENDERS each member through `ui-mushaf-page-view`. It never edits, reshapes,
// reflows, or re-typesets the sacred text, and never computes "similar verses"
// itself — the diverging-word index arrives in the data.
//
// Non-negotiables enforced below (do not relax):
//   * Whole group, never one sibling alone        (science §4; PRD §9.2.1)
//   * Juxtaposition, not spacing                   (science §5)
//   * Anchor = coordinate overlay on glyph layer   (science §6; PRD §11.2, R1)
//   * Reveal-on-tap, then highlight                 (07-components §5)
//   * No gamification, no "cured"/"safe to drop"    (science §8; PRD R3, C6)
//   * No AI/ML/audio; objective dataset only        (PRD C2, R4)
//   * Teacher outranks the machine                  (PRD R6, §8.2)
//
// Tokens are referenced BY NAME only; resolve them through the theme/token layer,
// never hardcode hex / durations / dp here.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:ui_mushaf_page_view/ui_mushaf_page_view.dart'; // MushafPageView + overlay markers
// import '../mushaf/widgets/mushaf_page_view.dart';
// import 'mutashabihat_view_model.dart'; // the 1:1 ViewModel for this feature View
// import 'mutashabihat_providers.dart';  // scoped Riverpod providers (read models)

// ---------------------------------------------------------------------------
// Read models (shape only — owned by domain-mutashabihat-system; do NOT define
// the real types here, import them from the engine/data layer).
// ---------------------------------------------------------------------------

/// One confusable group as the trainer consumes it: the WHOLE group, with each
/// member's distinguishing-word indices already resolved. The View must never
/// slice a single member out of this list. (science §4, §7; PRD §9.1, §10.1)
class MutashabihGroupView {
  const MutashabihGroupView({
    required this.groupId,
    required this.type, // identical | near_identical | structural (PRD §10.1)
    required this.members,
  });

  final String groupId;
  final String type;

  /// Always >= 2 members — a drill exercises the contrasting pair or full group.
  final List<MutashabihMemberView> members;
}

/// One sibling: enough to render its immutable page and anchor the diverging
/// word(s). `distinguishingWordIndices` feeds a COORDINATE overlay — never a
/// text edit. (science §6; PRD §9.2.3, §11.2)
class MutashabihMemberView {
  const MutashabihMemberView({
    required this.pageId,
    required this.ayahId,
    required this.distinguishingWordIndices,
  });

  final int pageId;
  final String ayahId; // "s:a"
  final List<int> distinguishingWordIndices;
}

/// One confusion hotspot row — the user's OWN logged swap, read-only here.
/// Sourced from `confusion_edge`; weight grows/decays from the user's history,
/// pure bookkeeping, no ML. (PRD §9.1, §10.2; science §7)
class ConfusionHotspotView {
  const ConfusionHotspotView({
    required this.groupId,
    required this.ayahA,
    required this.ayahB,
    required this.weight,
    required this.localizedPair, // already transcreated "Page ۲۵۳ ⇄ Page ۲۸۰"
  });

  final String groupId;
  final String ayahA;
  final String ayahB;
  final double weight;
  final String localizedPair;
}

// ---------------------------------------------------------------------------
// Trainer screen: the standalone Mutashābihāt tab. (PRD §9.3, §12.4)
// A dumb View — all state via the ViewModel/providers; no DateTime.now() here.
// ---------------------------------------------------------------------------

class MutashabihatTrainerScreen extends ConsumerWidget {
  const MutashabihatTrainerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // RTL by geometry — fa/ckb/ar are first-class, not a bolted-on mode.
    // (07-components §1; PRD §13.4)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // TODO: term-set title (transcreated; never hardcoded English).
        // appBar: AppBar(title: Text(l10n.mutashabihatTitle)),
        body: const _TrainerBody(),
      ),
    );
  }
}

class _TrainerBody extends ConsumerWidget {
  const _TrainerBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: read the calm hotspots + browsable groups from the feature providers.
    // final hotspots = ref.watch(confusionHotspotsProvider);
    // final groups = ref.watch(mutashabihGroupsProvider);

    return CustomScrollView(
      slivers: const [
        // Calm, actionable hotspots — NOT a scoreboard. (science §8; 07 §8)
        SliverToBoxAdapter(child: _ConfusionHotspotsView(hotspots: [])),
        // Browse groups → tap one to run its discrimination drill.
        // SliverList.builder( ... -> open DiscriminationDrillView(group) )
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Confusion hotspots — "you keep swapping these two". Calm information, every
// row taps into its drill. No points/badges/streaks/leaderboard/guilt grid,
// and NEVER a "cured" / "safe to drop" label. (PRD §9.3; science §8)
// ---------------------------------------------------------------------------

class _ConfusionHotspotsView extends StatelessWidget {
  const _ConfusionHotspotsView({required this.hotspots});

  final List<ConfusionHotspotView> hotspots;

  @override
  Widget build(BuildContext context) {
    if (hotspots.isEmpty) {
      // Calm empty state — informational, never a celebration or a nag.
      // TODO: term-set copy, e.g. "No confusions logged yet."
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final h in hotspots)
          ListTile(
            // TODO: leading neutral marker — NEVER an alarm red / danger glyph.
            //   Color from `color.text.secondary` family, not a scoreboard hue.
            title: Text(
              h.localizedPair, // already locale-numeral + bidi-isolated
              // TODO: style: Theme type token `type.body`.
            ),
            // TODO: subtitle = calm "you keep swapping these two" term-set string
            //   in `type.caption` / `color.text.secondary`. Honest framing:
            //   drills REDUCE swaps — never "cured" / "resolved" / "safe to drop".
            // TODO: trailing chevron mirrors automatically in RTL.
            onTap: () {
              // TODO: open the WHOLE group's drill (never a single sibling).
              // Navigator.of(context).push(... DiscriminationDrillView(group: ...))
            },
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Discrimination drill — the operational form of discriminative contrast.
// Presents the WHOLE group BACK-TO-BACK (member A → member B → …) with no
// spacing/interstitial between siblings. Each branch: hidden → reveal-on-tap
// → THEN anchor highlight. (science §4, §5, §6; PRD §9.2.1)
// ---------------------------------------------------------------------------

class DiscriminationDrillView extends ConsumerStatefulWidget {
  const DiscriminationDrillView({super.key, required this.group});

  /// Always the full group. There is no single-sibling entry point — passing a
  /// one-member group is a bug (would invite retrieval-induced forgetting).
  final MutashabihGroupView group;

  @override
  ConsumerState<DiscriminationDrillView> createState() =>
      _DiscriminationDrillViewState();
}

class _DiscriminationDrillViewState
    extends ConsumerState<DiscriminationDrillView> {
  int _index = 0; // which sibling is in front
  bool _revealed = false; // reveal-on-tap gate (retrieval practice)

  @override
  void initState() {
    super.initState();
    assert(
      widget.group.members.length >= 2,
      'A drill must exercise the whole group (>=2 members), never one sibling '
      'alone — science §4 retrieval-induced forgetting.',
    );
  }

  void _reveal() => setState(() => _revealed = true);

  void _next() {
    // Advance to the next sibling immediately — temporal juxtaposition, no
    // spacing/interstitial inserted between branches. (science §5)
    setState(() {
      _index = (_index + 1) % widget.group.members.length;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.group.members[_index];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // TODO: term-set title naming the contrast, never hardcoded English.
        body: SafeArea(
          child: Column(
            children: [
              // The immutable page for THIS sibling — rendered ONLY through
              // ui-mushaf-page-view (its dedicated KFGQPC glyph font). Hidden
              // until the ḥāfiẓ has recited from memory and tapped to reveal.
              Expanded(
                child: GestureDetector(
                  onTap: _revealed ? null : _reveal,
                  child: _MemberPage(member: member, revealed: _revealed),
                ),
              ),

              // Controls sit low in the thumb zone, large, `space.2` apart.
              // (07-components §5; 05-layout-spacing-touch)
              _DrillControls(
                revealed: _revealed,
                onReveal: _reveal,
                onNext: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders one sibling's immutable page and, ONLY AFTER reveal, the
/// distinguishing-word highlight as a COORDINATE overlay. Never edits text.
class _MemberPage extends StatelessWidget {
  const _MemberPage({required this.member, required this.revealed});

  final MutashabihMemberView member;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    // TODO: build the immutable glyph page via ui-mushaf-page-view, e.g.:
    //
    //   return MushafPageView(
    //     pageId: member.pageId,
    //     masked: !revealed,                 // hidden until recall attempt
    //     overlays: revealed
    //         ? [
    //             // Anchor hint = highlight RECTANGLES over the glyph layer,
    //             // computed from member.distinguishingWordIndices + the
    //             // bundled word geometry. NEVER re-typeset. (science §6; §11.2)
    //             MushafAnchorOverlay(
    //               wordIndices: member.distinguishingWordIndices,
    //               // color via `color.semantic.*` token, not a hardcoded hue
    //             ),
    //           ]
    //         : const [],
    //   );
    //
    // Reveal uses `motion.duration.short` + standard easing — no bounce, no
    // success choreography; OS Reduce-Motion respected at the token layer.
    return const Placeholder(); // TODO: replace with MushafPageView
  }
}

/// Low, large, calm controls. No celebratory haptics/animation. The effortful
/// feel of contrast is a desirable difficulty — framed, never gamified. (§5, §8)
class _DrillControls extends StatelessWidget {
  const _DrillControls({
    required this.revealed,
    required this.onReveal,
    required this.onNext,
  });

  final bool revealed;
  final VoidCallback onReveal;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // TODO: `space.4` outer padding via the spacing token layer.
      padding: const EdgeInsetsDirectional.all(16),
      child: Row(
        children: [
          // Before reveal: "I have recited" → reveal. After: "Next sibling".
          // (Disabled-until-revealed mirrors the recite flow's grade-band gate.)
          Expanded(
            child: FilledButton(
              onPressed: revealed ? onNext : onReveal,
              // TODO: term-set label, transcreated; wraps, never truncates.
              child: const Text('TODO: reveal / next (term-set)'),
            ),
          ),
        ],
      ),
    );
  }
}
