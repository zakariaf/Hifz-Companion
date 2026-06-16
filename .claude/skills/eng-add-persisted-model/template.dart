// =============================================================================
// eng-add-persisted-model — canonical scaffold for a persisted record + its
// DAO/repository surface in the Hifz Companion app. Add a new persisted domain
// record (or a read/write method for an existing one) by following the layers
// below, each owned by ONE package, with Drift/SQLite held inside `data`.
//
// CONTRACT (docs/engineering):
//   Value type:  models/  — immutable, dart:core/package:meta only        (01 §2, §3.1; 03 §5.1)
//   Table+DAO:   data/    — Drift only; STRICT/CHECK/FK/index in schema    (05 §1, §2)
//   No Drift symbol crosses the data boundary (banned-import gate)         (05 §1; 03 §6, §7.2)
//   Scheduling days = CalendarDate serial INTEGER; instants = UTC          (05 §2; 03 §1.1)
//   review_log is APPEND-ONLY — no UPDATE/DELETE DAO method                (05 §2)
//   One db.transaction per write; AWAIT every query; persist THEN republish (05 §3; 01 §4)
//   Derived health computed on read, never stored                         (05 §2)
//   Pair with a guided stepByStep Drift migration + fixture test          (05 §4)
//
// Replace <Example>, fields, enums, units, and column names. In the real repo
// each numbered block below is its OWN file in its OWN package — this single
// file is a starting point, not a standalone unit (CalendarDate, the generated
// `_$...` Drift code, and package imports resolve only inside the workspace).
// Tokens/strings are referenced by NAME — user-facing words live in `l10n`.
// =============================================================================


// MARK: ─── Layer 0 ── packages/models/lib/src/example_record.dart ───────────
// Pure value type. Imports dart:core / package:meta only — the bottom of the
// graph. NO package:drift, NO package:flutter here, or it is a compile error.
// (01 §2 Layer 0; 03 §5.1 immutable domain types)

import 'package:meta/meta.dart';
// import 'package:hifz_models/hifz_models.dart'; // for CalendarDate, Grade, …

/// A closed value set is an enum so invalid states are unrepresentable (03 §5.1).
/// TODO: replace with the record's actual closed sets, or delete. Mirror the
/// CHECK (... IN (...)) constraint in the Drift table (Layer 2) exactly.
enum ExampleTrack { newPage, near, far, unmemorized }

/// TODO: one-line summary of what this record represents (03 §4 — `///` is mandatory
/// on every public API of models/data/quran). Then document units and edge behavior.
///
/// A persisted domain record: an IMMUTABLE value type (`final` fields, `const`
/// constructor, `copyWith` for derivation). Dates that are SCHEDULING DAYS are
/// `CalendarDate` (a floating calendar day), never a `DateTime` instant (03 §1.1).
/// Quantities name their unit (`stabilityDays`, not `s`); a `DateTime` named like
/// a day is a review-blocking defect.
@immutable
class ExampleRecord {
  /// The next-due scheduling day — a floating `CalendarDate`, never a `DateTime`.
  /// Produced ONLY by the engine's trust clamp; no other layer recomputes it (01 §4).
  final CalendarDate dueAt;

  /// FSRS stability in days (the engine's `S`). Full word + unit in the name (03 §1.1).
  final double stabilityDays;

  /// Which revision track this page is on. A closed set → an enum, not a free String.
  final ExampleTrack track;

  /// Whether this page is flagged weak. Booleans read as assertions (03 §1.1).
  final bool isWeak;

  // TODO: add the record's fields. Every quantity names its unit; closed sets are
  // enums; scheduling days are CalendarDate; instants are DateTime named as instants.

  const ExampleRecord({
    required this.dueAt,
    required this.stabilityDays,
    required this.track,
    this.isWeak = false,
  });

  /// Derivation is a copy, never a mutation — this is what keeps the record golden-
  /// testable and safe to hand to a widget (01 §4 immutability is the precondition).
  ExampleRecord copyWith({
    CalendarDate? dueAt,
    double? stabilityDays,
    ExampleTrack? track,
    bool? isWeak,
  }) {
    return ExampleRecord(
      dueAt: dueAt ?? this.dueAt,
      stabilityDays: stabilityDays ?? this.stabilityDays,
      track: track ?? this.track,
      isWeak: isWeak ?? this.isWeak,
    );
  }
}


// MARK: ─── Layer 2 ── packages/data/lib/src/tables/example_record_table.dart ─
// Drift table class — the ONLY place `package:drift` appears. Invariants live in
// the SCHEMA (STRICT typing, CHECK, foreign keys, indices), not in Dart, so a
// corrupt row is unrepresentable at the storage layer (05 §2). Add this table to
// the @DriftDatabase(tables: [...]) list (05 §1).

// import 'package:drift/drift.dart';   // <- legal ONLY inside the data package.

/*
@DataClassName('ExampleRecordRow')   // generated row type — stays inside data/
class ExampleRecords extends Table {
  // FK to the owning profile; ON DELETE CASCADE so erasing a profile erases its rows.
  TextColumn get profileId =>
      text().references(Profiles, #profileId, onDelete: KeyAction.cascade)();

  // FK into the read-only reference structure (never written at runtime — 05 §2).
  IntColumn get pageId => integer().references(Pages, #pageId)();

  // Scheduling day = CalendarDate SERIAL INTEGER, never a DateTime instant (05 §2; 03 §1.1).
  IntColumn get dueAt => integer().nullable()();

  RealColumn get stabilityDays => real().check(stabilityDays.isBiggerOrEqualValue(0))(); // s >= 0
  // Enum closed-set mirrored as a CHECK (... IN (...)) — mirror ExampleTrack exactly.
  TextColumn get track =>
      text().check(track.isIn(['NEW', 'NEAR', 'FAR', 'UNMEMORIZED']))();
  BoolColumn get isWeak => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {profileId, pageId};

  // The engine invariant, defended at the storage layer (05 §2): a non-memorized
  // card has no due date; a memorized card always does.
  @override
  List<String> get customConstraints =>
      ["CHECK (track = 'UNMEMORIZED' OR due_at IS NOT NULL)"];

  @override
  bool get isStrict => true;   // STRICT: no silent type coercion (05 §2).
}
// Add the buildToday() scan index in the migration: card_due ON (profile_id, track, due_at).
*/


// MARK: ─── Layer 2 ── packages/data/lib/src/dao/example_record_dao.dart ──────
// The DAO maps rows to `models` value types. NO Drift Companion/TableInfo/row
// type escapes the data package (05 §1 "We refuse a Drift import outside /data").
// For an APPEND-ONLY table (review_log) expose NO update()/delete() method — the
// absence is the enforcement, reviewed in CI (05 §2).

// import 'package:drift/drift.dart';

/*
@DriftAccessor(tables: [ExampleRecords])
class ExampleRecordDao extends DatabaseAccessor<HifzDatabase>
    with _$ExampleRecordDaoMixin {
  ExampleRecordDao(super.db);

  /// Reads the due rows for a profile, mapping each Drift row to a `models`
  /// value type at the boundary — callers never see a Drift symbol.
  Future<List<ExampleRecord>> dueFor(ProfileId profileId, CalendarDate today) async {
    final rows = await (select(exampleRecords)
          ..where((t) =>
              t.profileId.equals(profileId.value) &
              t.dueAt.isSmallerOrEqualValue(today.serialDay)))   // CalendarDate serial int
        .get();
    return rows.map(_toModel).toList();
  }

  /// A reactive read model: re-emits on every committed write (01 §4 republish step).
  /// Derived health (juz/page) is computed FROM these cards on read — never stored (05 §2).
  Stream<List<ExampleRecord>> watchDue(ProfileId profileId, CalendarDate today) {
    return (select(exampleRecords)
          ..where((t) => t.dueAt.isSmallerOrEqualValue(today.serialDay)))
        .watch()
        .map((rows) => rows.map(_toModel).toList());
  }

  // NOTE: for an append-only table (review_log) there is NO update()/delete() here.

  ExampleRecord _toModel(ExampleRecordRow r) => ExampleRecord(
        dueAt: CalendarDate.fromSerialDay(r.dueAt!),     // serial int -> CalendarDate (domain-calendars-and-hifzdate)
        stabilityDays: r.stabilityDays,
        track: _trackFrom(r.track),
        isWeak: r.isWeak,
      );
}
*/


// MARK: ─── Layer 2 ── packages/data/lib/src/repository/example_repository.dart
// The single write path. EVERY mutation is ONE db.transaction, all-or-nothing,
// AWAIT every query inside it (a missing await closes the txn → data loss; this
// is a release-blocking review item — 05 §3 the await footgun). The Future
// resolves only after the WAL commit (synchronous=FULL) — the controller
// republishes AFTER, never before (01 §4; "We refuse persist-after-publish").

/// One sealed error type for this I/O boundary; surfaced to the feature layer to
/// handle exhaustively. The engine never throws; the data layer may (03 §5.3).
/// Errors carry codes/counts only — never record contents (03 §5.4).
sealed class PersistenceError {
  const PersistenceError();
}

final class WriteFailed extends PersistenceError {
  const WriteFailed(this.reason);
  final String reason; // a code/category, never user data
}

/*
class ExampleRepository {
  ExampleRepository(this._db, this._dao);
  final HifzDatabase _db;
  final ExampleRecordDao _dao;

  /// The ONLY way an ExampleRecord (and its review_log row) is written anywhere
  /// in the app — the single write path. One transaction; commit BEFORE the
  /// controller republishes (01 §4; 05 §3). No `try?`, no swallowed errors,
  /// no debounced/"save later" write for a review or sign-off (03 §5.4).
  Future<void> commitExampleReview(ReviewOutcome outcome) async {
    try {
      await _db.transaction(() async {
        // 1. APPEND the immutable audit row first (append-only review_log — 05 §2).
        await _db.into(_db.reviewLog).insert(outcome.logRow);          // await — required
        // 2. UPSERT the card's engine state (D/S/due_at/flags) produced by the
        //    PURE engine; this layer does NO interval math (domain-scheduling-engine-rules).
        await (_db.update(_db.exampleRecords)
              ..where((t) =>
                  t.profileId.equals(outcome.profileId.value) &
                  t.pageId.equals(outcome.pageId)))
            .write(outcome.cardCompanion);                              // await — required
        // 3. (lazy) line_block rows / 4. (conditional) confusion_edge bumps —
        //    same transaction, all-or-nothing (05 §3).
      });
      // When this returns, every row is durably on disk (synchronous=FULL). The
      // Riverpod controller republishes here — see eng-create-riverpod-store.
    } on DriftWrappedException catch (e) {
      throw WriteFailed(e.cause.runtimeType.toString());   // typed catch, no record data leaks
    }
  }
}
*/


// =============================================================================
// REMINDERS
//  - PAIR with a guided Drift migration (05 §4): bump schemaVersion, run
//    `dart run drift_dev schema dump` (committed drift_schemas/ JSON) and
//    `dart run drift_dev make-migrations` (the .steps.dart), and ship a fixture
//    test that builds a populated v(n-1) DB, migrates, and asserts content AND
//    `PRAGMA integrity_check`. A shipped migration is NEVER edited;
//    `eraseDatabaseOnSchemaChange` is DEBUG-only.
//  - due_at is produced ONLY by the engine's trust clamp `min(ideal, ceiling)` —
//    no DAO/repository/SQL view re-derives it (01 §4 one sink, one truth).
//  - Derived state (juz/page/hizb health, R) is computed from `card` on read,
//    never stored (05 §2). Reference tables (page/line/ayah/surah/mushaf/
//    mutashabih_*) have NO write DAO.
//  - No DateTime.now()/clock read in the engine, DAO, or repository logic —
//    "today" is the injected CalendarDate (eng-define-service-boundary;
//    domain-calendars-and-hifzdate). Instants are UTC.
//  - No print/debugPrint/logging of user data; no `!`/`late` on persistence
//    values; no bare `catch (_)` (03 §5).
//  - User-facing strings (sabaq/sabqi/manzil terms, verdict labels) live in the
//    l10n package (ar template, fa/ckb), RTL via Directionality — never in a
//    record/DAO/repository. No streak/badge/score and no Quran/factual claim
//    encoded in a record (PRD R3/C6; domain-adab-and-religious-integrity).
//  - Round-trip test under plain `dart test`: value -> row -> value is identity,
//    including the CalendarDate-serial conversion (eng-write-dart-test).
// =============================================================================
