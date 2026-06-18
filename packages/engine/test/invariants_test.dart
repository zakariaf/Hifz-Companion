// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The full PRD §7.12 invariant register as six glados properties over generated
// (Card, grade-sequence, today) histories (06 §8; engineering 11 §4). This suite
// IS PRD §20 gate 4. Pure `package:glados` — no clock, no RNG, no fixed lucky
// seed; `today` is a constructed CalendarDate; rely on shrinking for the minimal
// counterexample. Each property restates its covenant at the assertion.
//
// Each was confirmed to fail-then-shrink against a deliberately inverted engine
// stub (a max-clamp → INV-1; an S-growing lapse → INV-3; a self-wins branch →
// INV-5; a manzil-dropping buildToday → INV-2; a Random-fuzzed plan → INV-4)
// before passing against the real T01–T10 engine.

import 'package:engine/engine.dart';
import 'package:glados/glados.dart';

import 'support/fixtures.dart';

/// A seed card + a random graded-review sequence + an injected `today`.
class ScheduleCase {
  ScheduleCase(this.seed, this.reviews, this.today);

  /// The starting card the history folds onto.
  final Card seed;

  /// The random graded reviews applied in order.
  final List<ReviewInput> reviews;

  /// The injected civil day every step runs against.
  final CalendarDate today;

  /// The engine configuration the invariants read.
  EngineConfig get config => EngineConfig.defaults();
}

extension AnySchedule on Any {
  /// A memorized seed card whose stored track matches its `S`-band (so the seed
  /// is internally consistent), due now, last reviewed at epoch day 0.
  Generator<Card> get cardSeed => combine2(
        any.intInRange(1, 605), // page id 1..604
        any.intInRange(1, 300), // stability days
        (id, s) => testCard(
          pageId: id,
          track: bandForStability(s.toDouble()),
          stabilityDays: s.toDouble(),
          lastReviewedDay: day(0),
          dueAt: day(0),
        ),
      );

  /// A human-produced graded review (grade + source); errorLines empty (the
  /// sacred-text guard has its own dedicated cases).
  Generator<ReviewInput> get gradedReview => combine2(
        any.intInRange(0, ReviewGrade.values.length),
        any.intInRange(0, GradeSource.values.length),
        (gi, si) => ReviewInput(
          grade: ReviewGrade.values[gi],
          source: GradeSource.values[si],
        ),
      );

  /// A constructed `today` within ~10 years — never a clock read.
  Generator<CalendarDate> serialDayInRange(int lo, int hi) =>
      any.intInRange(lo, hi).map(day);

  /// A card seed plus a random graded-review sequence and an injected today.
  Generator<ScheduleCase> get scheduleCase => combine3(
        any.cardSeed,
        any.listWithLengthInRange(0, 100, any.gradedReview),
        any.serialDayInRange(0, 3650),
        ScheduleCase.new,
      );
}

/// Folds the whole grade sequence onto the seed card, returning the final state.
Card replay(SchedulingEngine engine, ScheduleCase c) {
  var card = c.seed;
  for (final rv in c.reviews) {
    card = engine.onReview(card, rv, c.today, weakLineCount: 0);
  }
  return card;
}

/// The card set `buildToday` consumes — the replayed seed (a one-card deck; the
/// multi-card balancer behaviour is exercised by load_balance_test).
List<Card> replayAll(SchedulingEngine engine, ScheduleCase c) =>
    [replay(engine, c)];

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults());

  // INV-1 — THE TRUST CLAMP. PRD §7.6: SR may only make a page MORE frequent,
  // never push it past the cycle.
  Glados<ScheduleCase>(any.scheduleCase)
      .test('INV-1 due_at − today ≤ cycle ceiling, always', (c) {
    final card = replay(engine, c);
    if (card.track == ReviewTrack.unmemorized) return; // memorized only
    expect(
      card.dueAt!.epochDay - c.today.epochDay,
      lessThanOrEqualTo(cycleCeilingDays(card, c.config)),
    );
  });

  // INV-2 — FAR/manzil due items are NEVER silently dropped. PRD §7.9.
  Glados<ScheduleCase>(any.scheduleCase)
      .test('INV-2 every due FAR page appears in the plan', (c) {
    final cards = replayAll(engine, c);
    final plan = engine.buildToday(cards, c.today);
    final dueFar = cards.where(
      (x) =>
          x.track == ReviewTrack.far &&
          x.dueAt != null &&
          x.dueAt!.epochDay <= c.today.epochDay,
    );
    expect(plan.allPageIds, containsAll(dueFar.map((x) => x.pageId)));
  });

  // INV-3 — A LAPSE DEMOTES. PRD §7.7; science 03 §4: Again sets S back and
  // re-derives a weaker phase; it never grows S or promotes a track.
  Glados<ScheduleCase>(any.scheduleCase)
      .test('INV-3 Again ⇒ S\' ≤ S ∧ track\' ≤ track', (c) {
    final before = replay(engine, c);
    final after = engine.onReview(
      before,
      ReviewInput(grade: ReviewGrade.again, source: GradeSource.teacher),
      c.today,
      weakLineCount: 0,
    );
    expect(after.stabilityDays, lessThanOrEqualTo(before.stabilityDays));
    expect(
      trackStrength(after.track),
      lessThanOrEqualTo(trackStrength(before.track)),
    );
  });

  // INV-4 — DETERMINISM: identical inputs → byte-identical plan; fuzzing is OFF.
  Glados<ScheduleCase>(any.scheduleCase)
      .test('INV-4 the schedule is reproducible', (c) {
    final cards = replayAll(engine, c);
    final a = engine.buildToday(cards, c.today).fingerprint();
    final b = engine.buildToday(cards, c.today).fingerprint();
    expect(a, b);
  });

  // INV-5 — TEACHER SIGN-OFF supersedes self-rating and prior state. PRD §8.2.
  Glados<ScheduleCase>(any.scheduleCase)
      .test('INV-5 a teacher Again overrides a prior self Good', (c) {
    final base = replay(engine, c);
    final selfGood = engine.onReview(
      base,
      ReviewInput(grade: ReviewGrade.good, source: GradeSource.self),
      c.today,
      weakLineCount: 0,
    );
    final teacherAgain = engine.onReview(
      selfGood,
      ReviewInput(
        grade: ReviewGrade.again,
        source: GradeSource.teacher,
        errorLines: const [1],
      ),
      c.today,
      weakLineCount: 0,
    );
    expect(teacherAgain.isWeak, isTrue); // the teacher's verdict wins
    expect(
      teacherAgain.dueAt!.epochDay,
      lessThanOrEqualTo(selfGood.dueAt!.epochDay), // and pulls the page forward
    );
  });

  // INV-6 — the permastore still slopes; no memorized page is ever "safe to
  // drop". PRD §7.12; science 06 §6. Asserted as a finite, bounded dueAt — not a
  // copy-grep; the non-nullable-for-memorized invariant forecloses the rest.
  Glados<ScheduleCase>(any.scheduleCase)
      .test('INV-6 every memorized card keeps a finite, bounded due day', (c) {
    for (final card in replayAll(engine, c)) {
      if (card.track == ReviewTrack.unmemorized) continue;
      expect(card.dueAt, isNotNull);
      expect(
        card.dueAt!.epochDay,
        lessThanOrEqualTo(c.today.epochDay + cycleCeilingDays(card, c.config)),
      );
    }
  });
}
