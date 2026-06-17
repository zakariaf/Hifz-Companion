// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The one sealed error type the `data` layer raises — surfaced to the feature
/// layer to handle exhaustively, never swallowed, never logged with user data.
///
/// Mapping is total in the normal case: a row that passed its `CHECK`s decodes
/// cleanly, so a [MappingException] is the schema/enum-drift escape hatch only.
/// The single write path (E03-T07) reuses this type — it does not invent a
/// parallel one.
sealed class PersistenceException implements Exception {
  /// Creates a persistence exception with a human-readable [message] (never
  /// shown to the user — UI copy is localized at the feature layer).
  const PersistenceException(this.message);

  /// A developer-facing description of the failure.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A stored row could not be decoded into its `models` value type — an
/// out-of-set enum token or a malformed `*_json` payload that bypassed its
/// `CHECK` (schema/enum drift).
final class MappingException extends PersistenceException {
  /// Creates a mapping exception describing the offending column/value.
  const MappingException(super.message);
}

/// The single write path (`commitReview`, E03-T07) could not durably commit a
/// review transaction — a *sanad* act is never acknowledged before its commit,
/// so this surfaces to the feature layer to handle exhaustively (a calm retry,
/// localized in `l10n`, never a guilt message). A subtree of the one sealed
/// [PersistenceException], not a parallel error type.
sealed class ReviewWriteException extends PersistenceException {
  /// Creates a write exception with a developer-facing [message].
  const ReviewWriteException(super.message);
}

/// The review transaction failed and was rolled back; nothing was committed.
final class ReviewTransactionFailed extends ReviewWriteException {
  /// Creates the transaction-failed write exception.
  const ReviewTransactionFailed()
      : super('the review transaction failed and was rolled back');
}

/// Even the rollback failed — the store is left needing recovery (logged
/// locally only, never transmitted).
final class ReviewRollbackFailed extends ReviewWriteException {
  /// Creates the rollback-failed write exception.
  const ReviewRollbackFailed()
      : super('the review transaction rollback failed; the store needs '
            'recovery');
}

/// The review violated a storage `CHECK`/constraint and was rejected whole — a
/// malformed `ReviewOutcome` is refused, never partially stored.
final class ReviewConstraintViolated extends ReviewWriteException {
  /// Creates the constraint-violated write exception.
  const ReviewConstraintViolated()
      : super('the review violated a storage constraint and was rejected');
}

/// The cold-start seed (`seedColdStart`, E03-T08) could not durably provision a
/// profile — all-or-nothing, so on failure the store holds zero rows and no
/// partially-provisioned profile. A subtree of the one sealed
/// [PersistenceException], surfaced to onboarding (a calm retry, never a guilt
/// message).
sealed class ColdStartWriteException extends PersistenceException {
  /// Creates a cold-start write exception with a developer-facing [message].
  const ColdStartWriteException(super.message);
}

/// The seed transaction failed and was rolled back to zero rows.
final class ColdStartSeedFailed extends ColdStartWriteException {
  /// Creates the seed-failed exception.
  const ColdStartSeedFailed()
      : super('the cold-start seed failed and was rolled back to zero rows');
}

/// Even the rollback failed — the store is left needing recovery.
final class ColdStartRollbackFailed extends ColdStartWriteException {
  /// Creates the rollback-failed exception.
  const ColdStartRollbackFailed()
      : super('the cold-start seed rollback failed; the store needs recovery');
}

/// A seed row violated a storage `CHECK`/constraint (e.g. a held card with a
/// null due day); the whole seed rolled back to zero rows.
final class ColdStartConstraintViolated extends ColdStartWriteException {
  /// Creates the constraint-violated exception.
  const ColdStartConstraintViolated()
      : super('a cold-start seed row violated a storage constraint');
}

/// The encryption flavor is active but the cipher is **not live** — `PRAGMA
/// cipher;` returned no rows, so `sqlite3mc` fell back to stock SQLite and
/// `PRAGMA key` was a no-op (a build defect). The store is refused at open so a
/// plaintext database that only *looks* encrypted can never ship (05 §5).
final class EncryptionNotLiveException extends PersistenceException {
  /// Creates the cipher-not-live exception.
  const EncryptionNotLiveException()
      : super('encryption build active but the cipher is not live; refusing to '
            'open a plaintext store');
}

/// The database could not be opened with the supplied key — a `SQLITE_NOTADB`
/// ("file is encrypted or is not a database") means a **wrong or missing key**,
/// **not** corruption. The feature layer surfaces a calm key-recovery flow,
/// never a "your data is corrupted" message (05 §5).
final class WrongDatabaseKeyException extends PersistenceException {
  /// Creates the wrong-key exception.
  const WrongDatabaseKeyException()
      : super('the database key is wrong or missing (SQLITE_NOTADB) — a '
            'key-recovery situation, not corruption');
}
