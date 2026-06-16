// Cold-start placement flow — copy-paste scaffold.
//
// Onboarding step (PRD §7.10, §12.1): mark which juz are held, rate each held
// juz Solid/Shaky/Rusty, optionally say WHEN it was memorized → seed conservative
// priors via the engine and converge on real grades. Sub-20-min, make-or-break.
//
// This file is a CAPTURE surface, not a scheduler. It gathers
// (held juz set, JuzConfidence per juz, optional CalendarDate per juz) and routes
// each held page through the engine's `coldStartCard` seeder. It NEVER invents
// (D, S), NEVER shows D/S/R or a "readiness %", and NEVER shames an un-held juz.
//
// Governing docs:
//   PRD §7.10 (the 5-step cold-start contract) + §12.1 (onboarding sequence)
//   docs/design-system/07-components.md §6 (SegmentedButton / state layers / focus ring),
//     §8 (the muṣḥaf-ordered, redundantly-encoded coverage grid), §1 (finite-capped)
//   docs/design-system/11-voice-and-tone.md §2/§4/§5/§6/§8 (honest, never-blame,
//     never-speak-for-the-Quran, invitation-not-command, transcreation)
//   docs/engineering/06-scheduling-engine.md §5 (coldStartCard + _coldStartSeed table)
//
// Replace every `// TODO` and wire to your real engine / store / l10n.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: import 'package:engine/engine.dart'      // JuzConfidence, coldStartCard, Card
// TODO: import 'package:l10n/l10n.dart'          // AppLocalizations (ar template, fa/ckb)
// TODO: import '../onboarding_providers.dart'    // clock + store/repo providers (DI)

// ---------------------------------------------------------------------------
// 1. Captured placement state (immutable). The flow's whole job is to fill this.
//    `JuzConfidence` is OWNED BY THE ENGINE — do not redeclare a UI copy of it.
// ---------------------------------------------------------------------------

@immutable
class PlacementDraft {
  const PlacementDraft({
    this.held = const {},
    this.confidence = const {},
    this.memorizedOn = const {},
  });

  /// Juz numbers (1..30) the user marks as held. Anything not here stays UNMEMORIZED.
  final Set<int> held;

  /// Per-held-juz confidence → seeds (D, S) via the engine (PRD §7.10 step 2).
  // TODO: value type is the engine's `JuzConfidence` enum (solid/shaky/rusty).
  final Map<int, Object /* JuzConfidence */ > confidence;

  /// Optional "when memorized" per juz — a CalendarDate, NEVER a raw DateTime
  /// (PRD §7.10 step 3; domain-calendars-and-hifzdate). Absent = skipped, no nag.
  final Map<int, Object /* CalendarDate */ > memorizedOn;

  bool get canCommit =>
      held.isNotEmpty && held.every(confidence.containsKey); // every held juz rated

  PlacementDraft copyWith({
    Set<int>? held,
    Map<int, Object>? confidence,
    Map<int, Object>? memorizedOn,
  }) =>
      PlacementDraft(
        held: held ?? this.held,
        confidence: confidence ?? this.confidence,
        memorizedOn: memorizedOn ?? this.memorizedOn,
      );
}

// ---------------------------------------------------------------------------
// 2. Onboarding controller (Riverpod). Holds the draft; on commit, seeds every
//    held page through the engine and persists transactionally via the store
//    BEFORE generating day one (single write path — eng-create-riverpod-store).
// ---------------------------------------------------------------------------

final placementControllerProvider =
    NotifierProvider<PlacementController, PlacementDraft>(PlacementController.new);

class PlacementController extends Notifier<PlacementDraft> {
  @override
  PlacementDraft build() => const PlacementDraft();

  // Pass 1 — coverage capture: a fast juz-level toggle (PRD §7.10 step 1).
  void toggleJuz(int juz) {
    final next = {...state.held};
    next.contains(juz) ? next.remove(juz) : next.add(juz);
    // Dropping a juz also clears its confidence/date so state stays consistent.
    final conf = {...state.confidence}..removeWhere((k, _) => !next.contains(k));
    final dates = {...state.memorizedOn}..removeWhere((k, _) => !next.contains(k));
    state = state.copyWith(held: next, confidence: conf, memorizedOn: dates);
  }

  // Pass 2 — per-juz confidence: single mutually-exclusive pick (PRD §7.10 step 2).
  void rate(int juz, Object /* JuzConfidence */ confidence) {
    state = state.copyWith(confidence: {...state.confidence, juz: confidence});
  }

  // Pass 3 — optional stale-time date (PRD §7.10 step 3). Skippable: pass null to clear.
  void setMemorizedOn(int juz, Object? /* CalendarDate? */ date) {
    final next = {...state.memorizedOn};
    date == null ? next.remove(juz) : next[juz] = date;
    state = state.copyWith(memorizedOn: next);
  }

  /// Commit: seed → persist transactionally → THEN trigger day-one (PRD §12.1).
  /// The engine owns (D, S) and the injected "today"; this never invents them.
  Future<void> commitPlacement() async {
    // TODO: read the INJECTED clock — never DateTime.now() (PRD §7.12; eng-define-service-boundary).
    // final today = ref.read(clockProvider).today;            // CalendarDate / SerialDay

    // TODO: for EACH held juz, expand to its page ids, then seed each page via the engine:
    //   final cards = <Card>[
    //     for (final juz in state.held)
    //       for (final pageId in pagesOfJuz(juz))
    //         coldStartCard(
    //           pageId,
    //           state.confidence[juz]! as JuzConfidence, // Solid→D3/S60 · Shaky→D5/S14 · Rusty→D7/S4
    //           today,
    //           memorizedOn: state.memorizedOn[juz] as CalendarDate?, // ages S from that date
    //         ),
    //   ];
    //
    // TODO: persist ALL seeded cards transactionally THROUGH THE REPOSITORY before
    //   republishing in-memory state — a mid-flow kill must leave no half-seeded state
    //   (eng-create-riverpod-store single write path; eng-add-persisted-model).
    //   await ref.read(scheduleRepositoryProvider).seedColdStart(cards);
    //
    // TODO: only AFTER the write commits, generate the first day (PRD §12.1
    //   "Done → first day generated") and route onward.
  }
}

// ---------------------------------------------------------------------------
// 3. Pass 1 — coverage capture grid.
//    A `GridView` in muṣḥaf order (juz 1 at the START/RIGHT in RTL), each cell
//    redundantly encoded: locale-numeral label + selected glyph (never color alone,
//    SC 1.4.1). An un-held juz is calm and un-emphasized — NEVER alarm-red "missing".
//    (07-components §8; eng-rtl-and-bidi-layout for numerals + mirroring.)
// ---------------------------------------------------------------------------

class CoverageCaptureGrid extends ConsumerWidget {
  const CoverageCaptureGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final held = ref.watch(placementControllerProvider).held;
    // final l10n = AppLocalizations.of(context)!;

    // RTL is the app default for fa/ckb/ar — do not force it per-widget; the shell
    // provides Directionality. Use logical start/end + EdgeInsetsDirectional below.
    return GridView.builder(
      padding: const EdgeInsetsDirectional.all(16), // TODO: space.4 token, not a literal
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8, // TODO: space.2 token
        crossAxisSpacing: 8, // TODO: space.2 token
      ),
      itemCount: 30, // 30 juz; muṣḥaf order, juz 1 first (visually start/right in RTL)
      itemBuilder: (context, i) {
        final juz = i + 1;
        final isHeld = held.contains(juz);
        return _JuzCoverageCell(
          juz: juz,
          isHeld: isHeld,
          onTap: () => ref.read(placementControllerProvider.notifier).toggleJuz(juz),
        );
      },
    );
  }
}

class _JuzCoverageCell extends StatelessWidget {
  const _JuzCoverageCell({
    required this.juz,
    required this.isHeld,
    required this.onTap,
  });

  final int juz;
  final bool isHeld;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // TODO: render `juz` in LOCALE numerals (Extended Arabic-Indic fa/ckb, Arabic-Indic ar)
    //   via intl NumberFormat + the type.numeral token — never ASCII concatenation.
    final juzLabel = '$juz';

    return Semantics(
      // TODO: localized "Juz N, held" / "Juz N, not held" (07-components §8; SC 1.3.1).
      label: isHeld ? 'Juz $juzLabel, held' : 'Juz $juzLabel, not held',
      toggled: isHeld,
      button: true,
      child: MergeSemantics(
        child: InkWell(
          onTap: onTap, // whole cell is one ≥48dp target (touch.min; SC 2.5.5/2.5.8)
          // TODO: focusColor / visible focus ring via color.outline (07-components §6; SC 2.4.7)
          child: Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            decoration: BoxDecoration(
              // Calm un-selected ground; selected = a quiet fill — NEVER alarm-red.
              // TODO: surface vs surfaceContainerHighest via color.* tokens (03-color-and-themes).
              color: isHeld ? scheme.secondaryContainer : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              // Redundant encoding: numeral label + a selected glyph, not color alone.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isHeld) const Icon(Icons.check, size: 16),
                  Text(juzLabel), // TODO: type.body / type.numeral token
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Pass 2 — per-juz confidence rater.
//    A single mutually-exclusive pick (SegmentedButton — 07-components §6) on
//    ≥56dp targets, each option = a color family PAIRED WITH a transcreated text
//    label (never color alone). Worded as honest self-report, never praise/score
//    (11-voice-and-tone §2 honest, §8 transcreation). Maps choice → engine enum.
// ---------------------------------------------------------------------------

class JuzConfidenceRater extends ConsumerWidget {
  const JuzConfidenceRater({super.key, required this.juz});

  final int juz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      placementControllerProvider.select((s) => s.confidence[juz]),
    );
    // final l10n = AppLocalizations.of(context)!;

    return SegmentedButton<Object /* JuzConfidence */ >(
      // TODO: replace the placeholder values with engine `JuzConfidence` enum values.
      segments: const [
        // TODO: l10n labels — transcreated self-report, NOT a score, NOT literal-translated:
        //   solid → "I hold this firmly"   (→ D=3, S=60, FAR/manzil)
        //   shaky → "It wobbles"           (→ D=5, S=14, NEAR)
        //   rusty → "It's gone rusty"      (→ D=7, S=4,  active revision)
        ButtonSegment(value: 'solid', label: Text('Solid'), icon: Icon(Icons.shield_outlined)),
        ButtonSegment(value: 'shaky', label: Text('Shaky'), icon: Icon(Icons.timelapse_outlined)),
        ButtonSegment(value: 'rusty', label: Text('Rusty'), icon: Icon(Icons.refresh_outlined)),
      ],
      selected: selected == null ? <Object>{} : {selected},
      emptySelectionAllowed: true,
      onSelectionChanged: (set) {
        if (set.isNotEmpty) {
          ref.read(placementControllerProvider.notifier).rate(juz, set.first);
        }
      },
      // M3 state layers + visible focus ring come from the role color by default;
      // do NOT hand-roll opacity (07-components §6).
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Pass 3 — optional "when memorized".
//    Genuinely skippable (invitation, never command — 11-voice-and-tone §6).
//    Captured as a CalendarDate and shown in the user's calendar (Hijri/Jalālī/
//    Gregorian) with locale numerals — never a raw DateTime (domain-calendars-and-hifzdate).
// ---------------------------------------------------------------------------

class MemorizedOnInput extends ConsumerWidget {
  const MemorizedOnInput({super.key, required this.juz});

  final int juz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(
      placementControllerProvider.select((s) => s.memorizedOn[juz]),
    );
    final notifier = ref.read(placementControllerProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: Text(
            // TODO: if `date != null`, format it in the user's calendar + locale numerals
            //   (domain-calendars-and-hifzdate); else a calm "optional" hint.
            date == null ? 'When did you memorize this? (optional)' : 'memorized: …',
          ),
        ),
        TextButton(
          // TODO: open a locale-calendar picker that yields a CalendarDate, then:
          //   notifier.setMemorizedOn(juz, pickedCalendarDate);
          onPressed: () {/* TODO */},
          child: const Text('Set'), // TODO: l10n verb
        ),
        if (date != null)
          TextButton(
            onPressed: () => notifier.setMemorizedOn(juz, null), // clear = skip, no nag
            child: const Text('Skip'), // TODO: l10n verb
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Calm completion summary + commit.
//    Ends on an informational surface — NO confetti, NO streak, NO completion-%
//    trophy (07-components §1/§8; PRD R3). The summary describes behavior, never
//    a D/S/R / readiness score: "we'll revise everything you hold once, then adjust."
// ---------------------------------------------------------------------------

class PlacementSummary extends ConsumerWidget {
  const PlacementSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(placementControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TODO: l10n, honest + calm. e.g. "You hold N juz. We'll revise each once to
        //   start, then adjust as you recite." NEVER show seeded D/S/R or a "% ready".
        Text('You hold ${draft.held.length} juz.'),
        const SizedBox(height: 16), // TODO: space.4 token
        FilledButton(
          onPressed: draft.canCommit
              ? () => ref.read(placementControllerProvider.notifier).commitPlacement()
              : null, // disabled reads as WAITING ("rate each held juz"), never an error
          child: const Text('Begin'), // TODO: l10n verb ("Start revision")
        ),
      ],
    );
  }
}
