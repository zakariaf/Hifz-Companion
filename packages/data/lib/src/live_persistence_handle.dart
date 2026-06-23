// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';

import 'db/connection.dart';
import 'db/database.dart';
import 'persistence_handle.dart';
import 'repositories/cold_start_repository.dart';
import 'repositories/confusion_repository.dart';
import 'repositories/repositories.dart';
import 'repositories/review_repository.dart';

/// The live [PersistenceHandle] over the Drift [HifzDatabase] — the one place a
/// Drift handle lives behind the interface (05 §1).
///
/// It is a thin facade: it implements the repository interfaces directly and
/// hands `this` back for each, so E03-T06 fills the read/append methods on the
/// same object and the single write path (E03-T07) opens its one transaction on
/// the held [database]. [database] is intentionally **not** on
/// [PersistenceHandle] — the public seam leaks no Drift symbol; the getter is
/// data-internal, used by the transaction body and the schema tests.
final class LivePersistenceHandle
    implements
        PersistenceHandle,
        CardRepository,
        ReviewLogRepository,
        ProfileRepository,
        ReferenceRepository,
        AppMetaRepository {
  /// Wraps the given Drift [database] (a file-backed connection in the app, an
  /// in-memory store in tests).
  LivePersistenceHandle(HifzDatabase database)
      : _database = database,
        reviews = LiveReviewRepository(database),
        coldStart = LiveColdStartRepository(database),
        confusion = LiveConfusionRepository(database);

  final HifzDatabase _database;

  @override
  final ReviewRepository reviews;

  @override
  final ColdStartRepository coldStart;

  @override
  final ConfusionRepository confusion;

  /// The underlying Drift database — data-internal only (never on the
  /// interface). The single write path (E03-T07) runs `database.transaction`.
  HifzDatabase get database => _database;

  @override
  CardRepository get cards => this;

  @override
  ReviewLogRepository get reviewLog => this;

  @override
  ProfileRepository get profiles => this;

  @override
  ReferenceRepository get reference => this;

  @override
  AppMetaRepository get meta => this;

  // --- CardRepository reads (over the data-internal CardDao) ---

  @override
  Future<Card?> byId(ProfileId profileId, int pageId) =>
      _database.cardDao.byId(profileId, pageId);

  @override
  Future<List<Card>> forProfile(ProfileId profileId) =>
      _database.cardDao.forProfile(profileId);

  @override
  Stream<List<Card>> watchForProfile(ProfileId profileId) =>
      _database.cardDao.watchForProfile(profileId);

  // --- ProfileRepository reads ---

  @override
  Future<List<Profile>> all() => _database.profileDao.all();

  // --- ReferenceRepository reads ---

  @override
  Future<List<int>> pageIdsForJuz(int juz) =>
      _database.referenceReadDao.pageIdsForJuz(juz);

  @override
  Future<List<Line>> linesForPage(int pageNumber) =>
      _database.referenceReadDao.linesForPage(pageNumber);

  @override
  Future<int?> firstPageOf(JumpTarget target) async {
    if (!target.isInRange) return null;
    final dao = _database.referenceReadDao;
    return switch (target.unit) {
      // A page resolves to itself (works before the reference is loaded).
      JumpUnit.page => target.index,
      JumpUnit.juz => dao.firstPageInJuz(target.index),
      JumpUnit.hizb => dao.firstPageInHizb(target.index),
      JumpUnit.surah => dao.firstPageOfSurah(target.index),
    };
  }

  // --- AppMetaRepository reads ---

  @override
  Future<String?> read(String key) => _database.appMetaDao.get(key);

  @override
  Future<void> close() => _database.close();
}

/// Opens the live, file-backed persistence handle — called **only** from the
/// composition root (`main`), never at import or in a provider body, so no IO
/// opens on a stray read (05 §1; 04 §1.2).
Future<PersistenceHandle> openLivePersistence() async =>
    LivePersistenceHandle(HifzDatabase(openConnection()));
