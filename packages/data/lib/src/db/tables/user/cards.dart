// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import '../reference/pages.dart';
import 'profiles.dart';

/// The `card` user table — one muṣḥaf page's revision state per profile (05 §2;
/// PRD §10.2, §7.12).
///
/// `due_at` / `last_review_at` are `CalendarDate` serial-day INTEGERs, never
/// `DateTime` instants. The load-bearing table `CHECK (track = 'UNMEMORIZED' OR
/// due_at IS NOT NULL)` defends the engine invariant that a memorized card
/// always has a due day — "nothing decays silently." No derived health/`R` is
/// stored. `STRICT`. Index `card_due (profile_id, track, due_at)` matches the
/// `buildToday()` scan — do not reorder.
@DataClassName('CardRow')
@TableIndex(name: 'card_due', columns: {#profileId, #track, #dueAt})
class Cards extends Table {
  @override
  String get tableName => 'card';

  /// The owning profile (FK, `ON DELETE CASCADE`).
  TextColumn get profileId =>
      text().references(Profiles, #profileId, onDelete: KeyAction.cascade)();

  /// The muṣḥaf page (FK into `page`, no cascade — the page is immutable).
  IntColumn get pageId => integer().references(Pages, #pageId)();

  /// `NEW` / `NEAR` / `FAR` / `UNMEMORIZED`.
  TextColumn get track => text()();

  /// FSRS difficulty `D` (column `d`, 1–10).
  RealColumn get difficulty => real().named('d')();

  /// FSRS stability `S` in days (column `s`, ≥ 0).
  RealColumn get stabilityDays => real().named('s')();

  /// Civil day last reviewed — `CalendarDate` serial day, or null if never.
  IntColumn get lastReviewAt => integer().nullable()();

  /// Civil day next due — `CalendarDate` serial day; null only when unmemorized.
  IntColumn get dueAt => integer().nullable()();

  /// Successful-review count (≥ 0).
  IntColumn get reps => integer().withDefault(const Constant(0))();

  /// Lapse count (≥ 0).
  IntColumn get lapses => integer().withDefault(const Constant(0))();

  /// Whether the engine has flagged this page weak.
  BoolColumn get weakFlag => boolean().withDefault(const Constant(false))();

  /// Teacher (talaqqī) sign-off count — a *sanad* count, never a reward (≥ 0).
  IntColumn get signoffs => integer().withDefault(const Constant(0))();

  /// Whether the user has manually pinned this page's track.
  BoolColumn get manualLock => boolean().withDefault(const Constant(false))();

  /// Whether this page is prayer-critical (prioritized in catch-up).
  BoolColumn get prayerCritical =>
      boolean().withDefault(const Constant(false))();

  /// Whether this card participates in scheduling (dormant, never dropped).
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {profileId, pageId};

  @override
  List<String> get customConstraints => const [
        "CHECK (track IN ('NEW', 'NEAR', 'FAR', 'UNMEMORIZED'))",
        'CHECK (d BETWEEN 1 AND 10)',
        'CHECK (s >= 0)',
        'CHECK (reps >= 0)',
        'CHECK (lapses >= 0)',
        'CHECK (signoffs >= 0)',
        // The engine invariant, defended at the storage layer (PRD §7.12):
        // a memorized card always has a due day.
        "CHECK (track = 'UNMEMORIZED' OR due_at IS NOT NULL)",
      ];

  @override
  bool get isStrict => true;
}
