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
