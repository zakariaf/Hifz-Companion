// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'db/connection.dart';
import 'db/database.dart';
import 'persistence_handle.dart';
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
        ProfileRepository {
  /// Wraps the given Drift [database] (a file-backed connection in the app, an
  /// in-memory store in tests).
  LivePersistenceHandle(HifzDatabase database)
      : _database = database,
        reviews = LiveReviewRepository(database);

  final HifzDatabase _database;

  @override
  final ReviewRepository reviews;

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
  Future<void> close() => _database.close();
}

/// Opens the live, file-backed persistence handle — called **only** from the
/// composition root (`main`), never at import or in a provider body, so no IO
/// opens on a stray read (05 §1; 04 §1.2).
Future<PersistenceHandle> openLivePersistence() async =>
    LivePersistenceHandle(HifzDatabase(openConnection()));
