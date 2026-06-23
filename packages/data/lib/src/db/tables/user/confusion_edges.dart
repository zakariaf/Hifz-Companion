// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import '../reference/ayat.dart';
import 'profiles.dart';

/// The `confusion_edge` user table — one profile's personal mutashābihāt
/// confusion log (05 §2; PRD §10.2).
///
/// Bookkeeping, not ML. The canonical `CHECK (ayah_a < ayah_b)` keeps exactly
/// one row per unordered pair and forbids a self-loop. `last_confused_at` is a
/// `CalendarDate` serial **day** (INTEGER) — a swap belongs to the civil day it
/// happened on, never a wall-clock instant (07 §1; PRD §10.2). `STRICT`.
@DataClassName('ConfusionEdgeRow')
class ConfusionEdges extends Table {
  @override
  String get tableName => 'confusion_edge';

  /// The owning profile (FK, `ON DELETE CASCADE`).
  TextColumn get profileId =>
      text().references(Profiles, #profileId, onDelete: KeyAction.cascade)();

  /// The smaller āyah id of the pair (FK into `ayah`, no cascade).
  @ReferenceName('confusionEdgesAsA')
  TextColumn get ayahA => text().references(Ayat, #ayahId)();

  /// The larger āyah id of the pair (FK into `ayah`, no cascade).
  @ReferenceName('confusionEdgesAsB')
  TextColumn get ayahB => text().references(Ayat, #ayahId)();

  /// How strongly this profile confuses the pair — a running count, default 0.
  RealColumn get weight => real().withDefault(const Constant(0))();

  /// The civil day last confused — a `CalendarDate` serial-day INTEGER, or null.
  IntColumn get lastConfusedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {profileId, ayahA, ayahB};

  @override
  List<String> get customConstraints => const [
        'CHECK (ayah_a < ayah_b)',
      ];

  @override
  bool get isStrict => true;
}
