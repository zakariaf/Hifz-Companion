// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import '../dates/calendar_date.dart';
import 'enums.dart';
import 'ids.dart';

/// One muṣḥaf page's revision state for one profile — the engine's unit of
/// scheduling and the row the single write path persists (05 §2 `card`; PRD
/// §10.2).
///
/// Immutable: the engine reads a [Card], computes the next state, and the
/// repository writes a fresh row (E03-T07). It carries only the FSRS-style
/// state (`difficulty`, `stabilityDays`) and bookkeeping flags — **no** stored
/// retrievability or health roll-up: `R` and per-juz/per-page health are
/// recomputed from these fields on read, never persisted, so there is one
/// authority (05 §2; PRD §10.3). It encodes no streak, score, or badge.
@immutable
class Card {
  /// The owning profile (FK `card.profile_id`, `ON DELETE CASCADE`).
  final ProfileId profileId;

  /// The muṣḥaf page this card tracks (1–604; FK into the read-only `page`
  /// table, no cascade — the page is immutable).
  final int pageId;

  /// Which revision track the page is on (sabaq/sabqi/manzil/unmemorized).
  final ReviewTrack track;

  /// The FSRS difficulty `D` — how hard this page is for this profile.
  ///
  /// Constrained `1 ≤ difficulty ≤ 10` by the schema `CHECK (d BETWEEN 1 AND
  /// 10)` (E03-T03); the value type carries it as a plain `double` and does not
  /// re-validate (a record is total, never throws).
  final double difficulty;

  /// The FSRS stability `S` in **days** — the interval at which retrievability
  /// has decayed to the target.
  ///
  /// Constrained `≥ 0` by the schema `CHECK (s >= 0)` (E03-T03).
  final double stabilityDays;

  /// The civil day this page was last reviewed, or null if never reviewed.
  ///
  /// A [CalendarDate] serial day, never a `DateTime` instant — the DST
  /// off-by-one this epic exists to remove (05 §2).
  final CalendarDate? lastReviewedDay;

  /// The civil day this page is next due.
  ///
  /// Null **exactly** when [track] is [ReviewTrack.unmemorized] — an unmemorized
  /// page has no due day. Once memorized it is always non-null; the schema
  /// `CHECK (track = 'UNMEMORIZED' OR due_at IS NOT NULL)` (E03-T03) defends
  /// that invariant on disk. A [CalendarDate] serial day, never a `DateTime`.
  final CalendarDate? dueAt;

  /// The number of successful reviews so far (`≥ 0`).
  final int reps;

  /// The number of lapses (again-grades) so far (`≥ 0`).
  final int lapses;

  /// Whether the engine has flagged this page as weak (pulled forward).
  final bool isWeak;

  /// The number of teacher (talaqqī) sign-offs on this page (`≥ 0`).
  ///
  /// A *sanad* count, never a gamified reward tally — no surface presents it as
  /// a score (PRD C6).
  final int signoffs;

  /// Whether the user has manually pinned this page's track (engine respects
  /// the lock).
  final bool hasManualLock;

  /// Whether this page is needed for the five daily prayers (prioritized in
  /// catch-up).
  final bool isPrayerCritical;

  /// Whether this card participates in scheduling (a disabled card is dormant,
  /// never dropped).
  final bool isEnabled;

  /// Creates a card. Counters and flags default to the schema's column defaults
  /// (counters `0`, flags `false`, [isEnabled] `true`).
  const Card({
    required this.profileId,
    required this.pageId,
    required this.track,
    required this.difficulty,
    required this.stabilityDays,
    this.lastReviewedDay,
    this.dueAt,
    this.reps = 0,
    this.lapses = 0,
    this.isWeak = false,
    this.signoffs = 0,
    this.hasManualLock = false,
    this.isPrayerCritical = false,
    this.isEnabled = true,
  });

  /// Returns a copy with the given fields replaced; every omitted field is
  /// preserved unchanged.
  Card copyWith({
    ProfileId? profileId,
    int? pageId,
    ReviewTrack? track,
    double? difficulty,
    double? stabilityDays,
    CalendarDate? lastReviewedDay,
    CalendarDate? dueAt,
    int? reps,
    int? lapses,
    bool? isWeak,
    int? signoffs,
    bool? hasManualLock,
    bool? isPrayerCritical,
    bool? isEnabled,
  }) {
    return Card(
      profileId: profileId ?? this.profileId,
      pageId: pageId ?? this.pageId,
      track: track ?? this.track,
      difficulty: difficulty ?? this.difficulty,
      stabilityDays: stabilityDays ?? this.stabilityDays,
      lastReviewedDay: lastReviewedDay ?? this.lastReviewedDay,
      dueAt: dueAt ?? this.dueAt,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      isWeak: isWeak ?? this.isWeak,
      signoffs: signoffs ?? this.signoffs,
      hasManualLock: hasManualLock ?? this.hasManualLock,
      isPrayerCritical: isPrayerCritical ?? this.isPrayerCritical,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Card &&
      other.profileId == profileId &&
      other.pageId == pageId &&
      other.track == track &&
      other.difficulty == difficulty &&
      other.stabilityDays == stabilityDays &&
      other.lastReviewedDay == lastReviewedDay &&
      other.dueAt == dueAt &&
      other.reps == reps &&
      other.lapses == lapses &&
      other.isWeak == isWeak &&
      other.signoffs == signoffs &&
      other.hasManualLock == hasManualLock &&
      other.isPrayerCritical == isPrayerCritical &&
      other.isEnabled == isEnabled;

  @override
  int get hashCode => Object.hash(
        profileId,
        pageId,
        track,
        difficulty,
        stabilityDays,
        lastReviewedDay,
        dueAt,
        reps,
        lapses,
        isWeak,
        signoffs,
        hasManualLock,
        isPrayerCritical,
        isEnabled,
      );
}
