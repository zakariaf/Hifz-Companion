// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import '../dates/calendar_date.dart';
import 'ids.dart';

/// One profile's personal confusion edge between two near-identical āyāt — the
/// bookkeeping behind the mutashābihāt trainer (05 §2 `confusion_edge`; PRD
/// §10.2).
///
/// Plain per-profile bookkeeping, **not** machine learning: [weight] counts how
/// often this ḥāfiẓ has swapped the pair. The pair is stored in a single
/// canonical order — [ayahA] strictly less than [ayahB] — so there is exactly
/// one row per unordered pair (the schema `CHECK (ayah_a < ayah_b)` defends it
/// on disk, E03-T03). Construct through [ConfusionEdge.between], which orders
/// the pair for you; the default constructor's `ayahA < ayahB` precondition is
/// the caller's to uphold.
@immutable
class ConfusionEdge {
  /// The owning profile (FK, `ON DELETE CASCADE`).
  final ProfileId profileId;

  /// The lexicographically smaller āyah id of the pair (e.g. `'2:1'`).
  ///
  /// By contract `ayahA.compareTo(ayahB) < 0`. FK into the read-only `ayah`
  /// table (no cascade).
  final String ayahA;

  /// The lexicographically larger āyah id of the pair (e.g. `'2:2'`).
  ///
  /// By contract strictly greater than [ayahA]. FK into the read-only `ayah`
  /// table (no cascade).
  final String ayahB;

  /// How strongly this profile confuses the pair — a running count, default 0.
  final double weight;

  /// The civil **day** the pair was last confused — a [CalendarDate] serial day
  /// stamped from the injected `today` (E14-T03), or null if never.
  ///
  /// A swap belongs to the calendar day it happened on, not a wall-clock
  /// instant: stored as a serial-day integer, never a `DateTime` (the DST
  /// off-by-one class the engine's date discipline forbids — 07 §1; PRD §10.2).
  final CalendarDate? lastConfusedAt;

  /// Creates an edge whose [ayahA] is already canonically less than [ayahB].
  ///
  /// Prefer [ConfusionEdge.between] unless the pair is known to be ordered; the
  /// canonical-ordering precondition is the caller's responsibility here (the
  /// schema `CHECK` is the on-disk guard).
  const ConfusionEdge({
    required this.profileId,
    required this.ayahA,
    required this.ayahB,
    this.weight = 0,
    this.lastConfusedAt,
  });

  /// Builds a canonically-ordered edge from an unordered pair, swapping the two
  /// āyah ids if needed so the result always satisfies `ayahA < ayahB`.
  ///
  /// The recommended construction path: it makes a reversed pair impossible to
  /// represent. A degenerate self-pair (`ayahOne == ayahTwo`) is left as-is and
  /// refused on disk by the schema `CHECK` — the model stays total and throws
  /// nothing.
  factory ConfusionEdge.between(
    ProfileId profileId,
    String ayahOne,
    String ayahTwo, {
    double weight = 0,
    CalendarDate? lastConfusedAt,
  }) {
    final inOrder = ayahOne.compareTo(ayahTwo) <= 0;
    return ConfusionEdge(
      profileId: profileId,
      ayahA: inOrder ? ayahOne : ayahTwo,
      ayahB: inOrder ? ayahTwo : ayahOne,
      weight: weight,
      lastConfusedAt: lastConfusedAt,
    );
  }

  /// Returns a copy with the given fields replaced; every omitted field is
  /// preserved unchanged.
  ConfusionEdge copyWith({
    ProfileId? profileId,
    String? ayahA,
    String? ayahB,
    double? weight,
    CalendarDate? lastConfusedAt,
  }) {
    return ConfusionEdge(
      profileId: profileId ?? this.profileId,
      ayahA: ayahA ?? this.ayahA,
      ayahB: ayahB ?? this.ayahB,
      weight: weight ?? this.weight,
      lastConfusedAt: lastConfusedAt ?? this.lastConfusedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ConfusionEdge &&
      other.profileId == profileId &&
      other.ayahA == ayahA &&
      other.ayahB == ayahB &&
      other.weight == weight &&
      other.lastConfusedAt == lastConfusedAt;

  @override
  int get hashCode => Object.hash(
        profileId,
        ayahA,
        ayahB,
        weight,
        lastConfusedAt,
      );
}
