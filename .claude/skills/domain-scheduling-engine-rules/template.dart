// Template — changing the Hifz scheduling engine
//
// Copy the snippet for the layer you are touching, replace the `TODO` markers,
// and walk the SKILL.md checklist. Every constant referenced by name lives in
// `docs/engineering/06-scheduling-engine.md` §3/§5/§8 — do NOT invent one.
//
// Step 0 — before you start, confirm `engine/` is still pure (this must print nothing):
//   grep -rnE 'DateTime\.now|Random\(|package:flutter|sqflite|drift|http' engine/lib
//
// Step 0b — if your change introduces a user-facing number (a retention %, a
//   cycle guarantee), it MUST already be a graded row in docs/science/CLAIMS.md.
//   If not: STOP and use domain-claims-register-and-science-screen first.

library hifz_engine;

import 'dart:math';

// ---------------------------------------------------------------------------
// Constants — the ONLY place these live (§3, §5, §8). kFactor is COMPUTED.
// ---------------------------------------------------------------------------

const double kDecay = -0.5;
final double kFactor = pow(0.9, 1 / kDecay) - 1; // = 19/81 ; NEVER inline 0.2346

const int kFsrsWeightCount = 19; // FSRS-4.5/5 ; 21 for FSRS-6 (kDecay = -w[20])
const double kMinStability = 0.1;
const int kMaxInterval = 36500;
const double kSelfConfidence = 0.5; // teacher = 1.0  (PRD §8.1/§8.2)
const double kLapseDifficultyBump = 1.0; // PRD §7.7
const double kWeakLineFactor = 0.15; // per chronically-weak line, into D
const double kHardFloorR = 0.85; // load-balance deferral floor (PRD §7.9)

const double kNearMinS = 9.0; // < 9 days  → still solidifying (NEW)
const double kFarMinS = 60.0; // ≥ 60 days → maintenance bulk (FAR)

// Conservative, UNDER-estimating cold-start seeds (§5; PRD §7.10).
const _coldStartSeed = <JuzConfidence, ({double d, double s})>{
  JuzConfidence.solid: (d: 3.0, s: 60.0), // FAR / manzil
  JuzConfidence.shaky: (d: 5.0, s: 14.0), // NEAR
  JuzConfidence.rusty: (d: 7.0, s: 4.0), // active revision
};

// ---------------------------------------------------------------------------
// 1. The curve and the interval (§3) — closed form, NEVER fuzzed.
// ---------------------------------------------------------------------------

/// R(t,S) = (1 + FACTOR·t/S)^DECAY ; R(S,S) = 0.9 by definition of kFactor.
double retrievability(int elapsedDays, double s) =>
    pow(1 + kFactor * elapsedDays / s, kDecay).toDouble();

/// I(r,S) = (S/FACTOR)·(r^(1/DECAY) − 1) ; I(S, 0.9) = S. No fuzzing.
int interval(double s, double targetR) =>
    ((s / kFactor) * (pow(targetR, 1 / kDecay) - 1)).round().clamp(1, kMaxInterval);

// ---------------------------------------------------------------------------
// 2. Phase + stakes-tiered retention (§5). Phase is a pure function of S.
// ---------------------------------------------------------------------------

Track phaseOf(Card c) {
  if (c.track == Track.unmemorized) return Track.unmemorized;
  if (c.manualLock) return c.track; // teacher pin wins over the math
  if (c.s < kNearMinS) return Track.newLesson;
  if (c.s < kFarMinS) return Track.near;
  return Track.far;
}

/// Stakes-tiered; NEVER a global 0.99, NEVER a user-facing slider (§5).
double targetR(Card c) {
  switch (phaseOf(c)) {
    case Track.newLesson:
      return 0.90;
    case Track.near:
      return 0.94;
    case Track.far:
      // TODO: confirm the prayer-critical / weak / lapsed escalation is intended.
      return (c.prayerCritical || c.weakFlag || c.lapses > 0) ? 0.97 : 0.95;
    case Track.unmemorized:
      return 0.95; // unreachable; defensive default
  }
}

// ---------------------------------------------------------------------------
// 3. The trust clamp — the whole engine in one rule (§6).
//    due_at = min(ideal_due, ceiling_due). The earlier date, ALWAYS.
// ---------------------------------------------------------------------------

SerialDay trustClamp(Card card, SerialDay today, EngineConfig config) {
  final idealDue = today.addDays(interval(card.s, targetR(card))); // what the math wants
  final ceilingDue = today.addDays(cycleCeilingDays(card, config)); // what tradition promises
  // SR may only make a page MORE frequent: take the EARLIER of the two.
  // TODO: NEVER change this to max(...). That is the silent-decay failure.
  return idealDue.value <= ceilingDue.value ? idealDue : ceilingDue;
}

/// Pure function of card + config; no clock, no I/O. pureCycleMode is one flag.
int cycleCeilingDays(Card card, EngineConfig config) {
  if (config.pureCycleMode) return config.farCycleDays; // §7.11 fixed rotation only
  switch (phaseOf(card)) {
    case Track.far:
      return config.farCycleDays;
    case Track.near:
      return config.nearCeilingDays;
    default:
      return config.farCycleDays; // never longer than the far cycle
  }
}

// ---------------------------------------------------------------------------
// 4. The review update (§4) — one deterministic path, guards in order.
// ---------------------------------------------------------------------------

Card onReview(Card card, ReviewInput rv, SerialDay today, EngineConfig config) {
  final elapsed = card.lastReview == null ? 0 : today.value - card.lastReview!.value;
  final r = elapsed == 0 ? 1.0 : retrievability(elapsed, card.s);

  // (a) Sacred-text guard: a missed/added/swapped word is NEVER "Good".  R1.
  var grade = rv.missedOrAlteredWord && rv.grade.index > Grade.hard.index
      ? Grade.hard
      : rv.grade;

  // (b) Source confidence: noisy self-rating moves S LESS than a teacher sign-off.
  final conf = rv.source == Source.teacher ? 1.0 : kSelfConfidence;

  double d = nextDifficulty(card.d, grade); // TODO: implement FSRS D' (§4)
  double s;
  var lapses = card.lapses;
  var weak = card.weakFlag;

  if (grade == Grade.again) {
    // ---- lapse branch: demote, NEVER grow stability ----
    lapses += 1;
    d = (d + kLapseDifficultyBump).clamp(1.0, 10.0);
    s = postLapseStability(card.d, card.s, r); // TODO: clamp result ≤ card.s (§4)
    weak = true; // /data lazily creates a line_block; the engine only flags it
  } else {
    // ---- success branch ----
    final gain = (stabilityOnSuccess(card.d, card.s, r, grade) - card.s) * conf;
    s = card.s + gain;
    if ((grade == Grade.good || grade == Grade.easy) && rv.errorLines.isEmpty) {
      weak = false;
    }
  }

  // (c) Weak-line / interference channel: each weak line bumps D; the (11−D)
  //     factor turns that into a shorter interval automatically — no parallel
  //     scheduler. errorLines apply at FULL strength regardless of source.
  d = (d + kWeakLineFactor * weakLineCount(card.pageId)).clamp(1.0, 10.0);

  var next = card.copyWith(
    d: d,
    s: max(s, kMinStability),
    lastReview: today,
    reps: card.reps + 1,
    lapses: lapses,
    weakFlag: weak,
  );
  next = updateGraduation(next, grade, rv.source); // §5 — predictable, sign-off gated
  // (d) The clamp is ALWAYS the last word. due_at is never null for a memorized card.
  return next.copyWith(dueAt: trustClamp(next, today, config));
}

// ---------------------------------------------------------------------------
// 5. Cold start (§5) — conservative priors, every held page due today.
// ---------------------------------------------------------------------------

Card coldStartCard(int pageId, JuzConfidence c, SerialDay today,
    {SerialDay? memorizedOn}) {
  final seed = _coldStartSeed[c]!;
  var s = seed.s;
  if (memorizedOn != null) {
    // Optional stale-time decay: age S from a known memorization date (PRD §7.10.3).
    final ageDays = today.value - memorizedOn.value;
    s = max(kMinStability, s * retrievability(ageDays, seed.s) / 0.9);
  }
  // Calibration: every held page is due NOW so the first weeks review each once.
  return Card.memorized(
    pageId: pageId,
    track: phaseOfSeed(s), // TODO
    d: seed.d,
    s: s,
    lastReview: today,
    reps: 0,
  ).copyWith(dueAt: today);
}

// ===========================================================================
// TEST — golden vector + glados invariants (§8).
// Fixtures come from the FSRS definition and dart-fsrs (enableFuzzing: false),
// NEVER from the engine under test. Harness: eng-write-dart-test.
// ===========================================================================
//
// import 'package:test/test.dart';
// import 'package:glados/glados.dart';
//
// void main() {
//   final engine = SchedulingEngine(/* TODO: EngineConfig with kDefaultWeights45 */);
//   final today = SerialDay(/* TODO: a fixed injected day */);
//
//   // Anchor golden vectors — guaranteed by the FACTOR/DECAY definition (§8).
//   test('curve identity R(S,S) = 0.9', () {
//     expect(retrievability(10, 10.0), closeTo(0.9, 1e-9));
//   });
//   test('interval identity I(S, 0.9) = S', () {
//     expect(interval(10.0, 0.9), 10);
//   });
//   test('tier multiplier interval(100, 0.97) ≈ 27', () {
//     expect(interval(100.0, 0.97), 27); // ≈ 0.266·S, rounded (§3 table)
//   });
//
//   // Invariant 1 — the trust clamp holds for EVERY card after EVERY review.
//   Glados2(/* anyCard */, /* anyReview */).test('due_at never exceeds the ceiling',
//       (Card card, ReviewInput rv) {
//     final out = engine.onReview(card, rv, today /*, config */);
//     expect(out.dueAt.value - today.value,
//         lessThanOrEqualTo(cycleCeilingDays(out, /* config */)));
//   });
//
//   // Invariant 2 — a lapse demotes (never promotes) stability.
//   // Invariant 3 — onReview is pure: identical inputs → byte-identical output.
//   // Invariant 4 — a missed/altered word never yields a Good/Easy outcome.
//   // Invariant 5 — FAR/manzil due items always appear in the built day plan.
//   // TODO: add the remaining four glados invariants (SKILL.md checklist).
// }
