// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:engine/engine.dart' show ReviewGrade;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../recite/recite_providers.dart';
import '../recite/recite_view_model.dart';
import '../today/today_providers.dart' show reviewRecorderProvider;
import '../today/today_session.dart';

/// Where the session stands.
enum SessionStage {
  /// Waiting for the day's plan (the queue is not built yet).
  preparing,

  /// Reciting the page at [SessionState.index].
  running,

  /// Every queued page was graded (or the queue was empty) — the plain close.
  done,
}

/// The immutable state of one revision session: the ordered page queue, the
/// cursor, and the grades committed so far. It carries no engine number and no
/// wall-clock date — the elapsed time is a display stopwatch owned by the
/// controller, never a scheduling input.
@immutable
class SessionState {
  /// Creates the state.
  SessionState({
    required this.stage,
    required List<int> queue,
    required this.index,
    required Map<int, ReviewGrade> grades,
  })  : queue = List<int>.unmodifiable(queue),
        grades = Map<int, ReviewGrade>.unmodifiable(grades);

  /// The state before the plan is known.
  const SessionState.preparing()
      : stage = SessionStage.preparing,
        queue = const <int>[],
        index = 0,
        grades = const <int, ReviewGrade>{};

  /// The stage.
  final SessionStage stage;

  /// The page ids in recitation order.
  final List<int> queue;

  /// The position of the page being recited (0-based).
  final int index;

  /// The grade committed per page id, in this session.
  final Map<int, ReviewGrade> grades;

  /// The page being recited, or null when not running.
  int? get currentPageId =>
      stage == SessionStage.running && index < queue.length
          ? queue[index]
          : null;

  /// How many pages were graded in this session.
  int get reviewedCount => grades.length;

  /// The pages graded Again/Hard — the engine pulls them forward, so they come
  /// back sooner (a calm maintenance fact, never "failed").
  List<int> get comesBackSooner => [
        for (final entry in grades.entries)
          if (entry.value == ReviewGrade.again ||
              entry.value == ReviewGrade.hard)
            entry.key,
      ];

  /// Returns a copy with the given fields replaced.
  SessionState copyWith({
    SessionStage? stage,
    List<int>? queue,
    int? index,
    Map<int, ReviewGrade>? grades,
  }) =>
      SessionState(
        stage: stage ?? this.stage,
        queue: queue ?? this.queue,
        index: index ?? this.index,
        grades: grades ?? this.grades,
      );

  @override
  bool operator ==(Object other) =>
      other is SessionState &&
      other.stage == stage &&
      listEquals(other.queue, queue) &&
      other.index == index &&
      mapEquals(other.grades, grades);

  @override
  int get hashCode => Object.hash(
        stage,
        Object.hashAll(queue),
        index,
        Object.hashAll(grades.entries.map((e) => Object.hash(e.key, e.value))),
      );
}

/// Orders the day's pages for the session: the catch-up plan when one exists,
/// else Far → Near → New in the engine's recitation order; [startPageId] (a
/// Today row tap) rotates the queue so that page comes first and the rest
/// follow in order — nothing is dropped or re-sorted.
List<int> sessionQueueFor(TodaySession session, {int? startPageId}) {
  final catchUp = session.catchUp;
  final ordered = <int>[
    if (catchUp != null)
      for (final card in catchUp.items) card.pageId
    else ...[
      for (final card in session.far) card.pageId,
      for (final card in session.near) card.pageId,
      for (final card in session.newSabaq) card.pageId,
    ],
  ];
  if (startPageId == null) return ordered;
  final start = ordered.indexOf(startPageId);
  if (start <= 0) return ordered;
  return [...ordered.sublist(start), ...ordered.sublist(0, start)];
}

/// The session controller: walks the queue, commits each grade through the
/// page's [ReciteController] (the single write path), and closes with the plain
/// summary. It does no scheduling math and reads no wall-clock date; the
/// [Stopwatch] is monotonic elapsed time for the end-of-session line only.
class SessionController extends Notifier<SessionState> {
  final Stopwatch _elapsed = Stopwatch();
  ReciteUndoHandle? _lastHandle;

  @override
  SessionState build() => const SessionState.preparing();

  /// Elapsed whole minutes since [begin] (a display value).
  int get elapsedMinutes => _elapsed.elapsed.inMinutes;

  /// Starts the session over [queue]; an empty queue closes immediately.
  void begin(List<int> queue) {
    if (state.stage != SessionStage.preparing) return;
    _elapsed
      ..reset()
      ..start();
    state = SessionState(
      stage: queue.isEmpty ? SessionStage.done : SessionStage.running,
      queue: queue,
      index: 0,
      grades: const <int, ReviewGrade>{},
    );
    if (queue.isEmpty) _elapsed.stop();
  }

  /// Commits [grade] for the current page through its recite controller and
  /// advances; the last page closes the session. Returns the undo handle.
  Future<ReciteUndoHandle?> grade(ReviewGrade grade) async {
    final pageId = state.currentPageId;
    if (pageId == null) return null;
    final handle = await ref
        .read(reciteControllerProvider(pageId).notifier)
        .submitGrade(grade);
    _lastHandle = handle;
    final next = state.index + 1;
    final finished = next >= state.queue.length;
    if (finished) _elapsed.stop();
    state = state.copyWith(
      stage: finished ? SessionStage.done : SessionStage.running,
      index: finished ? state.index : next,
      grades: {...state.grades, pageId: grade},
    );
    return handle;
  }

  /// Reverses the last committed grade through the single write path (a
  /// corrective row, never a `review_log` mutation) and drops it from the
  /// session's tally. The cursor is not moved back — the page stays graded
  /// "undone" in the record and returns to Today on its own.
  Future<void> undoLast() async {
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
    final grades = Map<int, ReviewGrade>.of(state.grades)
      ..remove(handle.pageId);
    state = state.copyWith(grades: grades);
  }
}

/// The session controller — `autoDispose`, so leaving the route discards the
/// in-memory cursor (every committed grade is already durable).
final sessionControllerProvider =
    NotifierProvider.autoDispose<SessionController, SessionState>(
  SessionController.new,
);

/// How many pages fall due by tomorrow for the active profile — the honest
/// "tomorrow" line on the session close. Reads the card store once; a page
/// left ungraded today counts too (it is still due), never hidden.
final tomorrowDueCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return 0;
  final tomorrow = ref.watch(todayProvider).addDays(1);
  final cards = await ref.read(cardRepositoryProvider).forProfile(profile);
  return cards
      .where((c) => c.dueAt != null && !c.dueAt!.isAfter(tomorrow))
      .length;
});
