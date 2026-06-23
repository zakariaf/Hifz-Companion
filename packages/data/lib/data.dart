// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The local single source of truth for Hifz Companion: the Drift/SQLite schema,
/// DAOs, and the repositories that are the only public write path (transactional,
/// persist-before-republish, over an append-only review_log).
///
/// This barrel exports the persistence boundary — the [PersistenceHandle]
/// interface, the value-type repository interfaces, and the live `openLivePersistence`
/// constructor — and never the raw Drift `HifzDatabase`/DAOs/companions. The
/// in-memory test double lives in the separate `package:data/testing.dart`
/// barrel. The schema, DAOs, migrations, and repository bodies (WAL +
/// synchronous=FULL) are authored across E03.
library;

export 'src/app_meta_keys.dart' show kAppMetaKeyTextChecksumVerifiedAt;
export 'src/dates/today_for.dart' show todayFor;
export 'src/live_persistence_handle.dart' show openLivePersistence;
export 'src/reference/edition_bootstrap.dart' show registerBundledEdition;
export 'src/encryption/secret_key_store.dart'
    show FlutterSecureKeyStore, SecretKeyStore;
export 'src/persistence_exception.dart'
    show
        ColdStartConstraintViolated,
        ColdStartRollbackFailed,
        ColdStartSeedFailed,
        ColdStartWriteException,
        ConfusionConstraintViolated,
        ConfusionRollbackFailed,
        ConfusionTransactionFailed,
        ConfusionWriteException,
        EncryptionNotLiveException,
        MappingException,
        PersistenceException,
        ReviewConstraintViolated,
        ReviewRollbackFailed,
        ReviewTransactionFailed,
        ReviewWriteException,
        WrongDatabaseKeyException;
export 'src/persistence_handle.dart' show PersistenceHandle;
export 'src/repositories/cold_start_repository.dart' show ColdStartRepository;
export 'src/repositories/confusion_repository.dart' show ConfusionRepository;
export 'src/repositories/repositories.dart'
    show
        AppMetaRepository,
        CardRepository,
        ProfileRepository,
        ReferenceRepository,
        ReviewLogRepository;
export 'src/repositories/review_repository.dart' show ReviewRepository;
