// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//
// SCAFFOLD — this file bundles the canonical Hifz Companion code shapes so you
// can copy the one you need into the right package and fill the // TODO markers.
// It is NOT a standalone Dart file: the blocks belong in different packages
// (models / engine / data / assets / features) and an analysis_options.yaml
// block lives at the repo root. Opening this file alone shows unresolved
// symbols — that is expected; the real symbols resolve only in the workspace.
//
// Tokens, units, and constants are referenced BY NAME — the docs own the
// concrete values; never invent a magic number here without a citation comment.
//
// Governing docs:
//   docs/engineering/03-coding-standards.md
//     §1/§1.1 (Effective Dart casing; full-word, unit-bearing, CalendarDate-vs-
//       DateTime, transliteration, boolean, no-get-prefix naming rules)
//     §3 (dart format + trailing commas), §4 (/// docs; why-not-what comments;
//       covenant comments), §5 (immutability; total engine; sealed I/O errors;
//       no print/log of user data), §6 (engine purity), §7 (analyzer/lints)
//   docs/engineering/01-architecture-overview.md
//     §2 (layer model), §4 (unidirectional flow; immutable; single write path),
//     §5 (pure engine; "today" injected; no DateTime.now()), §6 (offline)
//
// ===========================================================================
// BLOCK A — packages/models/lib/src/page_card.dart   (immutable value type)
// §5.1 immutability + copyWith · §1.1 full-word, unit-bearing names · §4 /// docs
// engine/models import dart:core + package:meta ONLY (architecture §2).
// ---------------------------------------------------------------------------

import 'package:meta/meta.dart';

// import 'package:hifz_models/hifz_models.dart'; // TODO: CalendarDate, ReviewGrade

/// A single muṣḥaf page under revision: its FSRS state and next-due day.
///
/// Immutable value type — derive a changed card with [copyWith], never mutate.
/// Units live in the field names (§1.1 rule 2): [stabilityDays] is days,
/// [dueAt] is a floating calendar day (a [CalendarDate], NOT a [DateTime]).
@immutable
class PageCard {
  /// Creates a page card. All fields are required and final.
  const PageCard({
    required this.pageNumber,
    required this.stabilityDays,
    required this.difficulty,
    required this.dueAt,
    required this.isWeak, // §1.1 rule 5: booleans read as assertions
  });

  /// 1-based muṣḥaf page index. // TODO: confirm 1..604 range with quran package.
  final int pageNumber;

  /// FSRS S: days until retrievability falls to [targetRetention]. // §1.1 rule 2
  final double stabilityDays;

  /// FSRS D: intrinsic difficulty in [1, 10]. Stored full-word, never `d`.
  final double difficulty;

  /// Next revision day — a floating calendar day, never a wall-clock instant.
  final CalendarDate dueAt; // §1.1 rule 3: a day, not a DateTime

  /// Whether this page is flagged weak (recent stumble); drives re-frequency.
  final bool isWeak;

  /// Returns a copy with the given fields replaced. No field is ever mutated.
  PageCard copyWith({
    double? stabilityDays,
    double? difficulty,
    CalendarDate? dueAt,
    bool? isWeak,
  }) {
    return PageCard(
      pageNumber: pageNumber,
      stabilityDays: stabilityDays ?? this.stabilityDays,
      difficulty: difficulty ?? this.difficulty,
      dueAt: dueAt ?? this.dueAt,
      isWeak: isWeak ?? this.isWeak,
    ); // trailing comma → dart format expands vertically (§3)
  }
}

// ===========================================================================
// BLOCK B — packages/engine/lib/src/review_update.dart   (TOTAL pure function)
// §5.2 the engine never throws — uncertainty is an OUTPUT, invariants are
// asserts · §5 "today" is an injected CalendarDate, never DateTime.now() (§5,
// architecture §5) · §4 citation comment maps every constant to its source.
// engine/ imports NO flutter, NO dart:io, NO clock (§6; architecture §2).
// ---------------------------------------------------------------------------

import 'dart:math' as math;

/// Power-law forgetting: retrievability after [elapsedDays] at stability [s].
///
/// R(S, S) == [targetRetention] by definition. Pure and total — defined for
/// every input, never throws (§5.2). The terse `s` is the ONE place the FSRS
/// single-letter math is allowed (§1.1 rule 1), and only because of this doc.
double retrievability(int elapsedDays, double s) {
  // DECAY = -0.5 (FSRS-4.5); FACTOR derived so R(S, S) = 0.9.  // TODO: cite
  // docs/engineering/06-scheduling-engine.md §N — keep the citation current.
  const double decay = -0.5; // TODO: pull from the named engine constant
  const double factor = 19.0 / 81.0; // TODO: derive from decay + targetRetention
  return math.pow(1 + factor * elapsedDays / s, decay).toDouble();
}

/// The whole design in one line: SR may only make a page MORE frequent.
///
/// Returns the clamped next-due day. Total: for any inputs it returns a value
/// and the post-condition holds — programmer invariants use [assert] (stripped
/// in release), never [throw] (§5.2).
CalendarDate clampToCycle(CalendarDate idealDue, CalendarDate ceilingDue) {
  // PRD §7.6: SR may only make a page MORE frequent, never less. // §4 covenant
  final due = idealDue.isBefore(ceilingDue) ? idealDue : ceilingDue;
  assert(!due.isAfter(ceilingDue), 'trust clamp violated: dueAt > cycle ceiling');
  return due;
}

/// The single review update. Same inputs → same [PageCard], always.
///
/// `today` is the LAST argument and is INJECTED — the engine reads no clock
/// (architecture §5). // TODO: implement the S/D update, weak-flag, graduation,
/// and the sacred-text guard (PRD §7.7: a dropped/altered word is never "Good").
PageCard onReview(
  PageCard card,
  ReviewGrade grade,
  List<int> errorLines,
  CalendarDate today,
) {
  // TODO: compute newStabilityDays / newDifficulty (BLOCK B math) and the
  // clamped dueAt via clampToCycle(...). Return card.copyWith(...). No I/O here.
  throw UnimplementedError('TODO — engine logic: domain-scheduling-engine-rules');
}

// ===========================================================================
// BLOCK C — packages/assets/lib/src/asset_integrity_error.dart  (sealed I/O)
// §5.3 ONE sealed error type per I/O boundary, surfaced for exhaustive
// handling · §5.4 typed `on … catch`, never bare; no swallowed write errors.
// Throwing is legal ONLY at I/O boundaries (persistence, downloader, backup).
// ---------------------------------------------------------------------------

/// Failure modes of asset-pack verification. Fail-closed: any mismatch rejects.
sealed class AssetIntegrityError {
  const AssetIntegrityError();
}

/// The downloaded bytes did not match the pinned SHA-256 baked into the binary.
final class ChecksumMismatch extends AssetIntegrityError {
  /// Records the expected vs actual hash for an honest, surfaced error.
  const ChecksumMismatch(this.expected, this.actual);

  /// Pinned SHA-256 from the binary's manifest.
  final String expected;

  /// SHA-256 of the bytes actually downloaded.
  final String actual;
}

/// The requested pack could not be fetched at all.
final class PackUnavailable extends AssetIntegrityError {
  const PackUnavailable();
}

/// Verifies a downloaded pack, surfacing one sealed error on failure.
///
/// // TODO: implement the hash check. `catch` clauses MUST carry an `on` clause
/// (§5.4) — a bare `catch (_) {}` on a write/verify path is a review reject.
Future<void> verifyPack(/* TODO: bytes, expectedHash */) async {
  try {
    // TODO: compute the SHA-256 and compare to the pinned manifest value.
  } on FormatException catch (e) {
    // Typed catch only (avoid_catches_without_on_clauses is an error, §7.1).
    throw ChecksumMismatch('TODO-expected', e.message);
  }
  // NEVER: catch (_) {}  — swallowing a verify/write error is forbidden (§5.4).
  // NEVER: print(...) / debugPrint(...) of user data anywhere (§5.5, avoid_print).
}

// ===========================================================================
// BLOCK D — packages/features/<feature>/.../today_view_model.dart
// §5.1 Riverpod state is read-only, mutated ONLY through the single write path
// (architecture §4: persist transactionally BEFORE republishing) · §1.1 rule 6
// expose fields, not get-prefixed accessors · user strings come from l10n ARB.
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today's revision queue and the one command that records a review.
///
/// The view never mutates persisted state — it invokes [gradePage], which
/// routes through the repository's single write path (architecture §4).
class TodayViewModel extends Notifier<TodayState> {
  @override
  TodayState build() {
    // TODO: read the immutable DaySession from the repository provider.
    return const TodayState.loading();
  }

  /// Records a grade for one page through the single write path.
  ///
  /// Persists transactionally BEFORE republishing — there is no code path
  /// where in-memory state is newer than disk (architecture §4).
  Future<void> gradePage(int pageNumber, ReviewGrade grade) async {
    // TODO: call cardRepository.recordReview(...); it reads the immutable card,
    //       calls the pure engine.onReview(card, grade, errorLines, today),
    //       commits the ReviewLog + new card in ONE transaction, THEN emits.
    // today is an injected CalendarDate (never DateTime.now()).
    // Do NOT compute due_at here — the engine's trust clamp is the only sink.
  }

  // §1.1 rule 6: expose a field/getter, never `getDueCards()`.
  // List<PageCard> get dueCards => state.dueCards;  // TODO
}

// ===========================================================================
// BLOCK E — analysis_options.yaml (repo root) — copy into the YAML file.
// §3 formatter page width · §7.1 errors + lints you must satisfy · §7.2 the
// path-scoped import bans (NEVER `// ignore:` a §7.2 gate). For reference only.
// ---------------------------------------------------------------------------
//   include: package:flutter_lints/flutter.yaml
//   formatter:
//     page_width: 80                       # the one formatting authority (§3)
//   analyzer:
//     language:
//       strict-casts: true                 # no implicit dynamic→T
//       strict-raw-types: true             # no bare List/Map
//     errors:
//       avoid_print: error                 # no print/log of user data (§5.5)
//       avoid_dynamic_calls: error
//       avoid_catches_without_on_clauses: error   # typed catch only (§5.4)
//       public_member_api_docs: error      # /// on every public API (§4)
//       dangling_library_doc_comments: error
//   linter:
//     rules:
//       prefer_const_constructors: true
//       prefer_final_locals: true
//       require_trailing_commas: true      # vertical expansion → clean diffs (§3)
//       prefer_is_empty: true              # not .length == 0 (Effective Dart)
//       prefer_is_not_empty: true
//       avoid_positional_boolean_parameters: true
//   # dcm: avoid-banned-imports — engine purity, no-network-outside-assets,
//   #   legacy-Riverpod ban, all severity: error. NEVER `// ignore:` these (§7.2).

// ===========================================================================
// Placeholder declarations so editor errors point at YOUR // TODOs, not these.
// Delete this block — the real types come from the models package.
// ---------------------------------------------------------------------------
class CalendarDate {
  bool isBefore(CalendarDate other) => throw UnimplementedError();
  bool isAfter(CalendarDate other) => throw UnimplementedError();
}

enum ReviewGrade { again, hard, good, easy }

class TodayState {
  const TodayState.loading();
}
