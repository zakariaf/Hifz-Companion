// SCAFFOLD — copy the relevant piece into the right package, then fill the TODOs.
// `SerialDay`, `Card`, `Grade`, `SchedulingEngine`, the Drift tables, the Quran glyph
// renderer, and the design tokens resolve only inside the real Hifz packages
// (engine/, data/, the Quran-rendering package, design_system/). Opening this file on
// its own shows unresolved-symbol errors — that is expected; it is a starting point.
//
// domain-mutashabihat-system — canonical scaffold.
//
// Five pieces, across three layers:
//   1. Value types            — pure-Dart engine layer (no Flutter, no I/O).
//   2. expandMutashabihat(...) — engine: co-schedule siblings into one session.
//   3. Confusion-aware D bump  — engine: a swap raises D on EVERY group member.
//   4. logConfusion(...)       — data layer: write a confusion_edge (pure bookkeeping).
//   5. Trainer screen + anchor — Flutter/Riverpod, RTL, overlay over the glyph page.
//
// Tokens/engine rules are referenced BY NAME ONLY. The owning docs hold concrete
// values — never inline hex / pt / ms / weights here.
//
// Governing docs:
//   docs/science/05-interference-and-mutashabihat.md §3 (objective dataset), §4 (whole-group),
//     §5 (contrast not spacing), §6 (anchor overlay), §7 (no AI), §8 (teacher + honesty)
//   docs/engineering/06-scheduling-engine.md §4 ((11−D) channel; swap at full strength),
//     §7 (expandMutashabihat in buildToday), §8 (determinism)
//   docs/PRD.md §9, §10.1/§10.2 (schema), §11.2/R1 (overlay, never re-typeset)

// ===========================================================================
// 1. ENGINE LAYER — pure-Dart value types (engine/). NO Flutter, NO I/O, NO clock.
// ===========================================================================

/// Objective-wording scope only — §3 (R4). Never thematic/interpretive.
enum MutashabihType { identical, nearIdentical, structural }

/// Bundled, scholar-reviewed, read-only. Mirrors mutashabih_group (PRD §10.1).
class MutashabihGroup {
  const MutashabihGroup({required this.groupId, required this.type, required this.members});
  final int groupId;
  final MutashabihType type;
  final List<MutashabihMember> members; // the full group — drills exercise ALL of these (§4)
}

/// Mirrors mutashabih_member (PRD §10.1). The anchor lives here, as indices only.
class MutashabihMember {
  const MutashabihMember({
    required this.groupId,
    required this.ayahId,
    required this.pageId,
    required this.distinguishingWordIndexJson, // §6 — drives the anchor OVERLAY, never re-typeset
  });
  final int groupId;
  final String ayahId; // "surah:ayah"
  final int pageId;    // the scheduling key — maps the group member back to a Card
  final List<int> distinguishingWordIndexJson;
}

/// Personal confusion log — mirrors confusion_edge (PRD §10.2). Pure bookkeeping, no ML (§7).
class ConfusionEdge {
  const ConfusionEdge({
    required this.ayahA,
    required this.ayahB,
    required this.weight,        // grows/decays from the user's OWN logged swaps only
    required this.lastConfusedAt,
  });
  final String ayahA;
  final String ayahB;
  final double weight;
  final SerialDay lastConfusedAt; // TODO: SerialDay from docs/engineering/07-dates-...
}

// ===========================================================================
// 2. ENGINE — discrimination interleaving (the exception to the spacing rule).
//    Called from buildToday (06-scheduling-engine.md §7). The ONE place the engine
//    ADDS a not-yet-due card: additive contrast, never a dropped review.
// ===========================================================================

/// Pull every due card's mutashābihāt sibling(s) into the SAME plan, back-to-back.
/// Siblings are JUXTAPOSED, never spaced across days (§5; engine §7).
List<Card> expandMutashabihat(
  List<Card> sessionCards,
  // TODO: inject the bundled group index keyed by pageId (read-only, checksummed).
  Map<int, MutashabihGroup> groupsByPage,
) {
  final result = <Card>[...sessionCards];
  final present = sessionCards.map((c) => c.pageId).toSet();

  for (final card in sessionCards) {
    final group = groupsByPage[card.pageId];
    if (group == null) continue;
    for (final sibling in group.members) {
      if (present.add(sibling.pageId)) {
        // TODO: resolve the sibling's Card and insert it ADJACENT to `card`
        //       (back-to-back contrast), even if it is not individually due.
        // result.insert(result.indexOf(card) + 1, cardFor(sibling.pageId));
      }
    }
  }
  return result; // ordering: keep each group's members contiguous before loadBalance.
}

// ===========================================================================
// 3. ENGINE — confusion-aware grading: a swap bumps D on EVERY group member (§4, engine §4).
//    Higher D → shorter interval via the (11−D) factor in stabilityOnSuccess. No
//    bespoke frequency override. Clamp D to [1,10].
// ===========================================================================

/// Apply a logged wrong-branch swap to all members of the confused group.
/// Returns the updated cards; the magnitude of any later S move is source-scaled
/// elsewhere (kSelfConfidence), but the D bump itself is full-strength (engine §4).
List<Card> applyConfusionBump(
  MutashabihGroup group,
  Map<int, Card> cardsByPage,
) {
  // TODO: pull kConfusionDifficultyBump from the engine constants (alongside
  //       kWeakLineFactor / kLapseDifficultyBump) — never inline a literal.
  const double kConfusionDifficultyBump = 1.0; // PLACEHOLDER — move to engine constants.
  final updated = <Card>[];
  for (final member in group.members) {
    final card = cardsByPage[member.pageId];
    if (card == null) continue;
    final bumpedD = (card.d + kConfusionDifficultyBump).clamp(1.0, 10.0);
    updated.add(card.copyWith(d: bumpedD)); // (11−D) shortens the next interval automatically
  }
  return updated; // EVERY member moves — the unpracticed twin is never left behind (§4).
}

// ===========================================================================
// 4. DATA LAYER — log a swap into confusion_edge. Pure bookkeeping, no inference (§7).
//    The swap is applied at FULL STRENGTH regardless of source (self or teacher);
//    only the stability move is confidence-scaled (engine §4).
// ===========================================================================

// TODO: this belongs in the data/ layer (Drift). The engine never touches I/O.
//
// Future<void> logConfusion(String ayahA, String ayahB, SerialDay today, Source source) async {
//   // Upsert confusion_edge: increment weight from the user's history; set last_confused_at.
//   // NO model, NO heuristic similarity — only the user's own logged swap (C2, §7).
//   // Then fetch the affected MutashabihGroup and call applyConfusionBump(...) on its cards,
//   // persisting in ONE transaction (eng-drift-persistence).
// }

// ===========================================================================
// 5. FLUTTER LAYER — the Mutashābihāt trainer + anchor overlay (RTL fa/ckb/ar).
//    Riverpod + Material 3. The drill ALWAYS shows the contrasting pair/group (§4),
//    back-to-back (§5). The anchor is an OVERLAY on the immutable glyph page (§6, R1).
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Read-only provider over the bundled dataset + the user's confusion_edge graph.
/// TODO: back it with the data layer; no network, dataset is bundled offline forever.
final mutashabihGroupsProvider =
    Provider<List<MutashabihGroup>>((ref) => throw UnimplementedError('TODO'));

/// Standalone trainer screen (PRD §9.3 / §12.4): browse groups, run discrimination
/// drills on demand, view personal confusion hotspots.
class MutashabihatTrainerScreen extends ConsumerWidget {
  const MutashabihatTrainerScreen({super.key, required this.group});
  final MutashabihGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // RTL-native: fa/ckb/ar are first-class, not a bolted-on mode.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // TODO: AppBar title from l10n (fa/ckb/ar). No streaks/badges/score widgets — §8.
        body: Column(
          children: [
            // The contrast drill: ALWAYS the full group, NEVER one sibling alone (§4).
            // Branch A then branch B, attention on the distinguishing word (§5, §6).
            for (final member in group.members)
              _DrillBranch(member: member),
            // Honest, calm copy: drilling REDUCES swaps; never "cured"/"safe to drop" (§8).
            // TODO: l10n string — "tamrīn-e tashīṣ" style framing of desirable difficulty (§5).
          ],
        ),
      ),
    );
  }
}

class _DrillBranch extends StatelessWidget {
  const _DrillBranch({required this.member});
  final MutashabihMember member;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The immutable glyph page — rendered, NEVER re-typeset (domain-quran-rendering, R1).
        // TODO: QuranPage(pageId: member.pageId) from the rendering package.
        const Placeholder(),
        // The anchor: a highlight rectangle drawn OVER the glyph layer from the bundled
        // word geometry at distinguishingWordIndexJson — never by editing text (§6, PRD §11.2).
        AnchorOverlay(
          pageId: member.pageId,
          wordIndices: member.distinguishingWordIndexJson,
        ),
      ],
    );
  }
}

/// Highlight overlay for the distinguishing word(s). Pure coordinate paint over the
/// glyph layer; it computes nothing about the text and reconstructs nothing (§6, R1).
class AnchorOverlay extends StatelessWidget {
  const AnchorOverlay({super.key, required this.pageId, required this.wordIndices});
  final int pageId;
  final List<int> wordIndices;

  @override
  Widget build(BuildContext context) {
    // TODO: look up word-glyph bounding boxes from the bundled word geometry
    //       (domain-quran-rendering), then paint a highlight rect per index.
    //       Use the design token for the anchor highlight color (e.g. color.anchor.*) —
    //       never an inline hex. The overlay is toggleable (PRD §12.3).
    return CustomPaint(
      painter: _AnchorPainter(/* TODO: rects, anchorColorToken */),
    );
  }
}

class _AnchorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: draw highlight rectangles only. No glyph drawing here — text is owned by
    //       the renderer and is immutable.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===========================================================================
// DETERMINISTIC PREVIEW — engine is pure; inject a fixed `today`, no clock/RNG (§8).
// The trainer renders under each RTL locale: fa, ckb, ar (no truncation of the phrase).
// ===========================================================================

// @widgetbook.UseCase(name: 'Trainer · fa', type: MutashabihatTrainerScreen)
// Widget previewFa(BuildContext _) => const Localizations(
//       locale: Locale('fa'),
//       child: MutashabihatTrainerScreen(group: _previewGroup),
//       // ... ckb, ar variants
//     );
//
// const _previewGroup = MutashabihGroup(
//   groupId: 1, type: MutashabihType.nearIdentical,
//   members: [/* TODO: two members differing by one word — the canonical contrast pair */],
// );
