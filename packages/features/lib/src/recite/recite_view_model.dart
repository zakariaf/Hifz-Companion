// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:engine/engine.dart' show Card, GradeSource, ReviewGrade;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show ProfileId;

import '../today/today_providers.dart' show reviewRecorderProvider;
import 'reader_surface.dart';

/// What the recite screen is doing right now (07-components §5/§6). The grade
/// band is enabled only once [ReciteState.hasRevealed] — after ≥1 reveal.
enum ReciteStage {
  /// The page is masked; the ḥāfiẓ is reciting from memory.
  hidden,

  /// At least one line has been revealed; stumble lines can be marked.
  revealing,
}

/// The immutable recite-flow view state. It collects the user's taps — how many
/// lines are revealed, which lines stumbled (1-based), whether a teacher is
/// present, and the sacred-text flag — and holds **no** scheduling math. The
/// grade cap is applied downstream in the pipeline (E12-T06), never here.
@immutable
class ReciteState {
  /// Creates the state.
  const ReciteState({
    required this.stage,
    required this.revealedLineCount,
    required this.stumbleLines,
    required this.teacherPresent,
    required this.missedOrAlteredWord,
  });

  /// The hidden initial state: nothing revealed, no stumbles, self-rated.
  const ReciteState.initial()
      : stage = ReciteStage.hidden,
        revealedLineCount = 0,
        stumbleLines = const <int>{},
        teacherPresent = false,
        missedOrAlteredWord = false;

  /// The current stage.
  final ReciteStage stage;

  /// How many lines from the top are revealed.
  final int revealedLineCount;

  /// The 1-based line indices the user marked as stumbles.
  final Set<int> stumbleLines;

  /// True when a teacher is present (source = teacher); E12-T08 owns the marker.
  final bool teacherPresent;

  /// True when a word was dropped/added/swapped — the pipeline caps the grade.
  final bool missedOrAlteredWord;

  /// The grade band gates on a real recall attempt: enabled only after a reveal.
  bool get hasRevealed => revealedLineCount > 0;

  /// Returns a copy with the given fields replaced.
  ReciteState copyWith({
    ReciteStage? stage,
    int? revealedLineCount,
    Set<int>? stumbleLines,
    bool? teacherPresent,
    bool? missedOrAlteredWord,
  }) =>
      ReciteState(
        stage: stage ?? this.stage,
        revealedLineCount: revealedLineCount ?? this.revealedLineCount,
        stumbleLines: stumbleLines ?? this.stumbleLines,
        teacherPresent: teacherPresent ?? this.teacherPresent,
        missedOrAlteredWord: missedOrAlteredWord ?? this.missedOrAlteredWord,
      );

  @override
  bool operator ==(Object other) =>
      other is ReciteState &&
      other.stage == stage &&
      other.revealedLineCount == revealedLineCount &&
      setEquals(other.stumbleLines, stumbleLines) &&
      other.teacherPresent == teacherPresent &&
      other.missedOrAlteredWord == missedOrAlteredWord;

  @override
  int get hashCode => Object.hash(
        stage,
        revealedLineCount,
        Object.hashAll(stumbleLines),
        teacherPresent,
        missedOrAlteredWord,
      );
}

/// The handle the screen holds to reverse a just-committed grade (07 §5). It
/// carries the pre-commit card snapshot so undo restores it through the single
/// write path (appending a corrective row, never mutating the append-only log).
@immutable
class ReciteUndoHandle {
  /// Creates the undo handle.
  const ReciteUndoHandle({
    required this.profile,
    required this.pageId,
    required this.priorCard,
    required this.grade,
  });

  /// The profile the review was committed against.
  final ProfileId profile;

  /// The muṣḥaf page that was graded.
  final int pageId;

  /// The card state before the commit, to restore on undo.
  final Card priorCard;

  /// The grade that was committed (recorded on the corrective audit row).
  final ReviewGrade grade;
}

/// The 1:1 recite view-model (`family` by `pageId`, `autoDispose`). It collects
/// taps and drives the stage machine; it does **no** stability math, **never**
/// caps the grade, and **never** reads `DateTime.now()` — "today" enters only
/// through the injected `todayProvider` when the grade rides the single write
/// path (E12-T06). The reader geometry comes from the injected reader surface.
class ReciteController extends Notifier<ReciteState> {
  /// Creates the controller for [pageId] (the family key).
  ReciteController(this.pageId);

  /// The muṣḥaf page being recited.
  final int pageId;

  ReciteUndoHandle? _lastHandle;

  @override
  ReciteState build() => const ReciteState.initial();

  /// Reveals the next line, after the recall attempt — never a teleprompter
  /// (C-020). Clamps to the page's line count; first reveal enters `revealing`.
  void revealNextLine() {
    final lines = ref.read(reciteReaderSurfaceProvider).lineCount(pageId);
    if (state.revealedLineCount >= lines) return;
    state = state.copyWith(
      stage: ReciteStage.revealing,
      revealedLineCount: state.revealedLineCount + 1,
    );
  }

  /// Toggles a 1-based stumble [line]; raises [ReciteState.missedOrAlteredWord]
  /// while any stumble is marked (the pipeline applies the sacred-text cap).
  void toggleStumbleLine(int line) {
    final next = Set<int>.of(state.stumbleLines);
    next.contains(line) ? next.remove(line) : next.add(line);
    state = state.copyWith(
      stumbleLines: next,
      missedOrAlteredWord: next.isNotEmpty,
    );
  }

  /// Sets whether a teacher is present (source self↔teacher); E12-T08 owns the
  /// teacher-sourced marker and the override semantics.
  void setTeacherPresent({required bool present}) =>
      state = state.copyWith(teacherPresent: present);

  /// Commits the (user-confirmed) [grade] through the single write path and
  /// returns an undo handle. The pipeline normalizes the taps and applies the
  /// sacred-text cap; this method forwards the raw taps and never caps them.
  Future<ReciteUndoHandle?> submitGrade(ReviewGrade grade) async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return null;
    final today = ref.read(todayProvider);
    final priorCard = await ref.read(cardRepositoryProvider).byId(
          profile,
          pageId,
        );
    final s = state;
    await ref.read(reviewRecorderProvider).recordReview(
          profile: profile,
          pageId: pageId,
          grade: grade,
          today: today,
          errorLines: s.stumbleLines.toList()..sort(),
          source: s.teacherPresent ? GradeSource.teacher : GradeSource.self,
          missedOrAlteredWord: s.missedOrAlteredWord,
        );
    if (priorCard == null) return null;
    final handle = ReciteUndoHandle(
      profile: profile,
      pageId: pageId,
      priorCard: priorCard,
      grade: grade,
    );
    _lastHandle = handle;
    return handle;
  }

  /// Reverses the just-committed grade through the single write path: it appends
  /// a corrective row and restores the prior card — it never mutates the
  /// append-only `review_log` (07 §5; R1 recoverability).
  Future<void> undoLastGrade() async {
    final handle = _lastHandle;
    if (handle == null) return;
    await ref.read(reviewRecorderProvider).undoReview(
          profile: handle.profile,
          pageId: handle.pageId,
          restoredCard: handle.priorCard,
          undoneGrade: handle.grade,
          today: ref.read(todayProvider),
        );
    _lastHandle = null;
  }
}
