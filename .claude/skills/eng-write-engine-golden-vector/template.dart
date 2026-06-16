// template.dart — copy-paste scaffold for a Hifz Companion engine golden-vector
// + invariant property test. See ./SKILL.md and ./references.md.
//
// Lives in: engine/test/  (pure Dart — NO flutter_test, NO widget binding,
// NO FontLoader, NO HttpOverrides). Run with:  dart test engine/
//
// The engine is pure-Dart, zero-I/O, deterministic: `today` is INJECTED as a
// SerialDay integer; nothing here reads DateTime.now() or Random.
//   - Golden vectors pin the FSRS-style arithmetic (curve, interval, S/D
//     branches, trust clamp, cold-start seeds) to frozen oracle rows,
//     asserted with closeTo(_, 1e-6) — NEVER ==.
//   - glados properties pin every PRD §7.12 invariant over generated histories.
//
// Refs: 11-testing-strategy.md §2/§3/§4 ; 06-scheduling-engine.md §3/§4/§5/§6/§8.

import 'package:test/test.dart';
import 'package:glados/glados.dart';
import 'package:hifz_engine/hifz_engine.dart';

// TODO: confirm these helpers exist in the engine's test harness (06 §8):
//   - SerialDay day(int v)            // construct an injected `today` literal
//   - Card.test({pageId, d, s, lastReview, track})
//   - SchedulingEngine, EngineConfig.defaults()
//   - constants by NAME: kSelfConfidence, kLapseDifficultyBump, kFarMinS,
//     kNearMinS, kDefaultWeights45, kFsrsWeightCount
// Reference every constant by name — never inline 0.5 / 60 / 0.2346 (06 §1/§8).

// ---------------------------------------------------------------------------
// 1. THE FROZEN ORACLE TABLE  (engine/test/vectors/fsrs_vectors.dart)
// ---------------------------------------------------------------------------
// Each row is computed ONCE against an independent reference — the FSRS curve/
// interval identities, or dart-fsrs run with `enableFuzzing: false` and
// kDefaultWeights45 — then frozen here as a human-readable Dart table.
// Regenerated ONLY by `dart run tool/gen_vectors.dart --update-vectors`,
// which a reviewer must approve in the PR diff. CI only ever VERIFIES. (11 §3)

/// One frozen golden row: (input state, grade, elapsed days) -> (expected D, S).
class FsrsVector {
  const FsrsVector(
    this.dIn,
    this.sIn,
    this.grade,
    this.elapsed,
    this.dOut,
    this.sOut,
    this.notes,
  );
  final double dIn;
  final double sIn;
  final Grade grade;
  final int elapsed;
  final double dOut;
  final double sOut;
  final String notes;
}

// dart format off — column alignment IS the documentation of this table (03 §3).
const fsrsVectors = <FsrsVector>[
  // d_in, s_in, grade,        elapsed, d_out,  s_out,   notes
  // TODO: freeze each row from the reference oracle, not from this engine.
  FsrsVector(5.0, 30.0, Grade.good,  30, /*TODO*/ 0, /*TODO*/ 0, 'on-time Good grows S'),
  FsrsVector(5.0, 30.0, Grade.again, 30, /*TODO*/ 0, /*TODO*/ 0, 'lapse: post-lapse S, D += kLapseDifficultyBump'),
  FsrsVector(3.0, 60.0, Grade.easy,  45, /*TODO*/ 0, /*TODO*/ 0, 'Solid juz, Easy, large gain (w[16])'),
  FsrsVector(7.0,  4.0, Grade.hard,  10, /*TODO*/ 0, /*TODO*/ 0, 'Rusty seed, Hard, modest gain (w[15])'),
  // … one row per branch + each cold-start seed (Solid / Shaky / Rusty).
];
// dart format on

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults());
  final config = EngineConfig.defaults();

  // -------------------------------------------------------------------------
  // 2. CURVE ANCHORS — guaranteed by the FACTOR definition (06 §3/§8).
  //    These pin the curve against any accidental edit to kDecay / kFactor.
  // -------------------------------------------------------------------------
  group('curve & interval anchors', () {
    test('R(S, S) == 0.9 by definition of FACTOR', () {
      const s = 17.0;
      // elapsed == S  =>  retrievability is exactly the 0.9 anchor.
      expect(retrievability(s.round(), s), closeTo(0.9, 1e-9));
    });

    test('interval at target 0.9 equals S (DECAY = -0.5)', () {
      const s = 42.0;
      expect(interval(s, 0.9), equals(s.round()));
    });

    test('tier multipliers: 0.95 ~ 0.448·S, 0.97 ~ 0.266·S', () {
      expect(interval(100.0, 0.95), /*TODO*/ closeTo(45, 1)); // §3 closed form
      expect(interval(100.0, 0.97), /*TODO*/ closeTo(27, 1));
    });

    test('a lapse NEVER grows stability (clamp S\'_f <= S)', () {
      // FSRS clamp — postLapseStability is bounded by the prior S. (06 §4)
      expect(postLapseStability(/*d*/ 5.0, /*s*/ 30.0, /*r*/ 0.7),
          lessThanOrEqualTo(30.0));
    });
  });

  // -------------------------------------------------------------------------
  // 3. THE FROZEN VECTORS — reproduce every oracle row (11 §3).
  //    Tolerance 1e-6, NEVER == : wide enough for benign float rounding,
  //    tight enough that any real arithmetic change fails CI.
  // -------------------------------------------------------------------------
  test('vendored FSRS arithmetic reproduces every frozen vector', () {
    for (final v in fsrsVectors) {
      final out = engine.onReview(
        Card.test(pageId: 1, d: v.dIn, s: v.sIn, lastReview: day(0)),
        ReviewInput(grade: v.grade, errorLines: const [], source: Source.teacher),
        day(v.elapsed),
      );
      expect(out.d, closeTo(v.dOut, 1e-6), reason: v.notes);
      expect(out.s, closeTo(v.sOut, 1e-6), reason: v.notes);
    }
  });

  // -------------------------------------------------------------------------
  // 4. COLD-START SEED VECTORS — pin PRD §7.10 priors exactly (06 §5; 11 §3).
  //    onboarding can never silently drift.
  // -------------------------------------------------------------------------
  group('cold-start seeds', () {
    test('Solid => D==3, S==60, track==far', () {
      final c = engine.coldStartCard(1, JuzConfidence.solid, day(0));
      expect(c.d, closeTo(3.0, 1e-6));
      expect(c.s, closeTo(60.0, 1e-6));
      expect(c.track, equals(Track.far));
    });
    // TODO: add Shaky (D=5, S=14, NEAR) and Rusty (D=7, S=4, active) rows.
  });

  // -------------------------------------------------------------------------
  // 5. INVARIANTS AS glados PROPERTIES — every PRD §7.12 rule over generated
  //    (Card, grade-sequence, today) histories, with shrinking (11 §4; 06 §8).
  //    No fixed lucky seed — let glados explore.
  // -------------------------------------------------------------------------

  // INV-1 — THE TRUST CLAMP: due_at is NEVER later than the cycle ceiling.
  // PRD §7.6: SR may only make a page MORE frequent, never less.
  Glados<ScheduleCase>(any.scheduleCase).test('due_at <= cycle ceiling, always', (c) {
    final card = replay(engine, c); // fold the grade sequence onto the seed card
    if (card.track == Track.unmemorized) return; // ceiling applies to memorized only
    expect(card.dueAt.value - c.today.value,
        lessThanOrEqualTo(cycleCeilingDays(card, config)));
  });

  // INV-2 — FAR/manzil due items are NEVER silently dropped from the day plan.
  Glados<ScheduleCase>(any.scheduleCase).test('manzil due items always appear in the plan', (c) {
    final cards = replayAll(engine, c);
    final plan = engine.buildToday(cards, c.today);
    final dueFar = cards.where(
        (x) => x.track == Track.far && x.dueAt.value <= c.today.value);
    expect(plan.allPageIds, containsAll(dueFar.map((x) => x.pageId)));
  });

  // INV-3 — A LAPSE DEMOTES: Again can only shrink S and lower the phase.
  Glados<ScheduleCase>(any.scheduleCase).test('Again never increases S or promotes track', (c) {
    final before = replay(engine, c);
    final after = engine.onReview(
      before,
      const ReviewInput(grade: Grade.again, errorLines: [], source: Source.teacher),
      c.today,
    );
    expect(after.s, lessThanOrEqualTo(before.s));
    expect(after.track.index, lessThanOrEqualTo(before.track.index));
  });

  // INV-4 — DETERMINISM: identical inputs => byte-identical plan (fuzzing OFF).
  Glados<ScheduleCase>(any.scheduleCase).test('schedule is reproducible', (c) {
    final a = engine.buildToday(replayAll(engine, c), c.today).fingerprint();
    final b = engine.buildToday(replayAll(engine, c), c.today).fingerprint();
    expect(a, equals(b));
  });

  // INV-5 — TEACHER SIGN-OFF supersedes self-rating and prior state for the page.
  Glados<ScheduleCase>(any.scheduleCase).test('teacher grade overrides self for that page', (c) {
    final selfGood = engine.onReview(
      replay(engine, c),
      const ReviewInput(grade: Grade.good, errorLines: [], source: Source.self_),
      c.today,
    );
    final teacherAgain = engine.onReview(
      selfGood,
      const ReviewInput(grade: Grade.again, errorLines: [1], source: Source.teacher),
      c.today,
    );
    expect(teacherAgain.weakFlag, isTrue); // the teacher's verdict wins
    expect(teacherAgain.dueAt.value, lessThanOrEqualTo(selfGood.dueAt.value));
  });

  // INV-6 — NEVER "safe to drop": every memorized card has a finite, non-null
  // dueAt. The non-nullable type forecloses the rest (06 §2) — this asserts
  // the value side, NOT a copy-grep.
  Glados<ScheduleCase>(any.scheduleCase).test('memorized cards always have a finite due day', (c) {
    for (final card in replayAll(engine, c)) {
      if (card.track == Track.unmemorized) continue;
      expect(card.dueAt, isNotNull);
      expect(card.dueAt.value, lessThan(kMaxInterval + c.today.value));
    }
  });
}

// ---------------------------------------------------------------------------
// 6. GENERATORS — build plausible random review histories for the properties.
//    (engine/test/support/generators.dart)  (11 §4)
// ---------------------------------------------------------------------------

/// A seed card + a random graded-review sequence + an injected `today`.
class ScheduleCase {
  ScheduleCase(this.seed, this.reviews, this.today);
  final Card seed;
  final List<ReviewInput> reviews;
  final SerialDay today;
  EngineConfig get config => EngineConfig.defaults();
}

extension AnySchedule on Any {
  /// A card plus a random sequence of graded reviews and an injected today.
  Generator<ScheduleCase> get scheduleCase => combine3(
        any.cardSeed, // page 1..604, random D∈[1,10], S>0, plausible track
        any.listWithLengthInRange(0, 200, any.gradedReview), // Again/Hard/Good/Easy + error lines
        any.serialDayInRange(0, 3650), // today within ~10 years
        ScheduleCase.new,
      );

  // TODO: implement the leaf generators against the engine value types:
  //   Generator<Card>        get cardSeed       => ... // draw Track/D/S/pageId
  //   Generator<ReviewInput> get gradedReview   => ... // draw Grade + errorLines + Source
  //   Generator<SerialDay>   get serialDayInRange(int lo, int hi) => ...
}

/// Fold the whole grade sequence onto the seed card, returning the final state.
Card replay(SchedulingEngine engine, ScheduleCase c) {
  var card = c.seed;
  for (final rv in c.reviews) {
    card = engine.onReview(card, rv, c.today);
  }
  return card;
}

/// Same as [replay] but returns the full card set buildToday() consumes.
List<Card> replayAll(SchedulingEngine engine, ScheduleCase c) {
  // TODO: fold reviews onto each card in a small generated deck, not just one.
  return [replay(engine, c)];
}
