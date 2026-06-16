// domain-grading-pipeline — copy-paste scaffold.
//
// Turns a recitation verdict (reveal-on-tap self-rating OR on-device teacher
// sign-off) into ONE normalized signal — ReviewInput(grade, errorLines, source,
// missedOrAlteredWord) — then writes it append-only to review_log and hands it
// to SchedulingEngine.onReview. NO microphone, NO audio, NO AI (PRD C2/R5).
//
// This layer NEVER computes a due_at, reads a clock, or updates stability — that
// is domain-scheduling-engine-rules. It only NORMALIZES the human verdict.
//
// Boundary rules (eng-create-engine-package): the engine receives an injected
// `today`; the grading layer passes no DateTime.now() into the engine.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The engine value types (Grade, Source, Card, ReviewInput, SchedulingEngine,
// SerialDay) live in the pure-Dart engine package. Import its public surface
// only — never reach into engine internals.
import 'package:hifz_engine/hifz_engine.dart';
// kSelfConfidence (0.5) and teacher 1.0 are NAMED engine constants — never
// inline 0.5/1.0 here. See engine §8 / PRD §8.1–§8.2.

// ---------------------------------------------------------------------------
// 1. The in-progress recitation state the recite flow builds up.
//    (UI chrome — the hidden page, reveal animation, line-tap targets, RTL
//    layout — belongs to ui-recite-grade-flow, NOT here.)
// ---------------------------------------------------------------------------

@immutable
class RecitationDraft {
  const RecitationDraft({
    required this.pageId,
    this.revealed = false,
    this.stumbleLines = const <int>[], // 1-based line indices (PRD §8.1)
    this.missedOrAlteredWord = false, // sacred-text guard flag (R1)
    this.confirmedGrade, // null until the user confirms the suggestion
  });

  final int pageId;
  final bool revealed; // text is shown only AFTER the attempt (science §4/§5)
  final List<int> stumbleLines;
  final bool missedOrAlteredWord;
  final Grade? confirmedGrade;

  RecitationDraft copyWith({
    bool? revealed,
    List<int>? stumbleLines,
    bool? missedOrAlteredWord,
    Grade? confirmedGrade,
  }) =>
      RecitationDraft(
        pageId: pageId,
        revealed: revealed ?? this.revealed,
        stumbleLines: stumbleLines ?? this.stumbleLines,
        missedOrAlteredWord: missedOrAlteredWord ?? this.missedOrAlteredWord,
        confirmedGrade: confirmedGrade ?? this.confirmedGrade,
      );
}

// ---------------------------------------------------------------------------
// 2. Stumble-count -> SUGGESTED grade. The suggestion is always user-confirmable
//    (PRD §8.1). Tune thresholds to the muṣḥaf line layout via R2 config.
// ---------------------------------------------------------------------------

Grade suggestGradeFromStumbles(int stumbleCount, int lineCount) {
  // TODO: replace the placeholder thresholds with the project's mapping.
  if (stumbleCount == 0) return Grade.good; // a clean attempt — never auto-Easy
  if (stumbleCount <= 1) return Grade.hard;
  return Grade.again;
}

// ---------------------------------------------------------------------------
// 3. THE NORMALIZER. The single place a ReviewInput is built. Applies the
//    sacred-text guard and tags the source. Pure: no I/O, no clock.
// ---------------------------------------------------------------------------

class RecitationGrading {
  /// Build the one normalized signal the engine consumes.
  ///
  /// [source] is Source.self_ for reveal-on-tap, Source.teacher for talaqqī.
  /// The per-source confidence weight (kSelfConfidence / 1.0) is applied INSIDE
  /// the engine; here we only LABEL the source correctly.
  static ReviewInput normalize(RecitationDraft draft, Source source) {
    // Sacred-text guard (R1 / PRD §8.3 / engine §4): a dropped/added/swapped
    // word is NEVER "Good". Cap the grade at Grade.hard BEFORE emitting.
    var grade = draft.confirmedGrade ?? Grade.again;
    if (draft.missedOrAlteredWord && grade.index > Grade.hard.index) {
      grade = Grade.hard;
    }

    // errorLines are recorded at FULL strength regardless of source (engine §4):
    // even a self-reported swap is valuable graph data. Only the magnitude of
    // the stability move is confidence-scaled, and that happens in the engine.
    return ReviewInput(
      grade: grade,
      errorLines: List<int>.unmodifiable(draft.stumbleLines),
      source: source,
      missedOrAlteredWord: draft.missedOrAlteredWord,
    );
  }
}

// ---------------------------------------------------------------------------
// 4. The controller that drives the flow and commits the grade.
//    Riverpod Notifier — owns the draft, then commits through the single path:
//    persist append-only review_log -> engine.onReview -> persist new card.
// ---------------------------------------------------------------------------

final recitationGradingProvider =
    NotifierProvider<RecitationGradingController, RecitationDraft?>(
  RecitationGradingController.new,
);

class RecitationGradingController extends Notifier<RecitationDraft?> {
  @override
  RecitationDraft? build() => null;

  void start(int pageId) => state = RecitationDraft(pageId: pageId);

  /// Reveal happens ONLY after the recitation attempt — never as a cue
  /// (science §4/§5). The UI must not surface the next line before the
  /// ḥāfiẓ has tried to recall it (no teleprompter).
  void reveal() => state = state?.copyWith(revealed: true);

  void toggleStumbleLine(int lineIndex) {
    final d = state;
    if (d == null) return;
    final lines = [...d.stumbleLines];
    lines.contains(lineIndex) ? lines.remove(lineIndex) : lines.add(lineIndex);
    state = d.copyWith(stumbleLines: lines..sort());
  }

  void setMissedOrAlteredWord(bool value) =>
      state = state?.copyWith(missedOrAlteredWord: value);

  void confirmGrade(Grade grade) =>
      state = state?.copyWith(confirmedGrade: grade);

  /// Commit a self-rating. `today` is injected by the caller (the one place
  /// "now" enters), never read here — keeps the engine deterministic.
  Future<void> commitSelfRating(SerialDay today) =>
      _commit(Source.self_, today, teacherLabel: null);

  /// Commit an on-device teacher sign-off (talaqqī). Same shape, authoritative
  /// (PRD §8.2 / R6): conf 1.0 inside the engine; overrides self-rating + state.
  Future<void> commitTeacherSignoff(SerialDay today, {String? teacherLabel}) =>
      _commit(Source.teacher, today, teacherLabel: teacherLabel);

  Future<void> _commit(
    Source source,
    SerialDay today, {
    required String? teacherLabel,
  }) async {
    final draft = state;
    if (draft == null) return;

    final review = RecitationGrading.normalize(draft, source);

    // TODO: load the current Card for draft.pageId (via the card repository).
    final Card card = ref.read(/* TODO cardProvider(draft.pageId) */ throw UnimplementedError());

    // TODO: append-only write to review_log — (grade, error_lines, source) plus
    // optional teacher label. NEVER overwrite a prior row (PRD §8.2, §10.2).
    // Use eng-add-persisted-model's repository; wrap the log-write and the
    // card-write in ONE transaction.
    // await ref.read(reviewLogRepoProvider).append(
    //   pageId: draft.pageId, review: review, teacherLabel: teacherLabel, on: today);

    // Hand the normalized signal to the engine. This is the ONLY math entry
    // point; the engine computes due_at via the trust clamp, not this layer.
    final SchedulingEngine engine = ref.read(/* TODO schedulingEngineProvider */ throw UnimplementedError());
    final Card updated = engine.onReview(card, review, today);

    // TODO: persist `updated` (same transaction as the review_log append).
    // await ref.read(cardRepoProvider).save(updated);

    state = null; // a logged grade is a calm receipt — no streak/confetti (C6).
  }
}

// ---------------------------------------------------------------------------
// 5. A minimal grade bar. RTL + localized; sect-/madhhab-neutral wording.
//    (Full recite/reveal screen + glyph rendering = ui-recite-grade-flow.)
// ---------------------------------------------------------------------------

class GradeBar extends ConsumerWidget {
  const GradeBar({super.key, required this.onGraded});

  /// Self-rating commit (teacher mode wires to commitTeacherSignoff instead).
  final ValueChanged<Grade> onGraded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(recitationGradingProvider);

    // Reveal-gate: grading is offered only AFTER the attempt + reveal.
    if (draft == null || !draft.revealed) return const SizedBox.shrink();

    // RTL for fa/ckb/ar (C4). Resolve the actual direction from the active
    // locale via Directionality higher in the tree; forced here for the demo.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        spacing: 8, // TODO: use the design-system space token, not a literal.
        children: [
          for (final g in Grade.values)
            FilledButton.tonal(
              // TODO: localize each verdict label for fa / ckb / ar; never
              // truncate load-bearing text; numerals locale-appropriate.
              onPressed: () => onGraded(g),
              child: Text(_localizedGradeLabel(context, g)),
            ),
        ],
      ),
    );
  }

  String _localizedGradeLabel(BuildContext context, Grade g) {
    // TODO: pull from AppLocalizations (fa/ckb/ar). Placeholder English only.
    switch (g) {
      case Grade.again:
        return 'Again';
      case Grade.hard:
        return 'Hard';
      case Grade.good:
        return 'Good';
      case Grade.easy:
        return 'Easy';
    }
  }
}

// NOTE: There is deliberately NO microphone, recorder, ASR, or model anywhere
// in this file (PRD C2/R5). Correctness is judged by a human — the ḥāfiẓ or the
// physically-present teacher — exactly as the tradition (talaqqī) does.
